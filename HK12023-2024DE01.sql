CREATE DATABASE QLSV
USE QLSV

CREATE TABLE SINHVIEN (
	MaSV VARCHAR(10) PRIMARY KEY,
	HoTen VARCHAR(50),
	NamSinh SMALLINT,
	MaLop VARCHAR(10)
)

CREATE TABLE KHOA (
	MaKhoa VARCHAR(10) PRIMARY KEY,
	TenKhoa VARCHAR(50)
)

CREATE TABLE DANGKY (
	MaSV VARCHAR(10),
	MaMH VARCHAR(10),
	HocKy TINYINT,
	NamHoc SMALLINT
	PRIMARY KEY(MaSV, MaMH, HocKy, NamHoc)
)

CREATE TABLE MON (
	MaMH VARCHAR(10) PRIMARY KEY,
	TenMH VARCHAR(50),
	SoTC TINYINT,
	MaKhoa VARCHAR(10)
)

ALTER TABLE DANGKY
ADD CONSTRAINT FK_MaSV
FOREIGN KEY (MaSV)
REFERENCES SINHVIEN(MaSV)

ALTER TABLE DANGKY
ADD CONSTRAINT FK_MaMH
FOREIGN KEY (MaMH)
REFERENCES MON (MaMH)

ALTER TABLE MON
ADD CONSTRAINT FK_MaKhoa
FOREIGN KEY (MaKhoa)
REFERENCES KHOA (MaKhoa)

-- Số tín chỉ của một môn học phải nằm trong khoảng từ 2 đến 4
ALTER TABLE MON
ADD CONSTRAINT CHECK_TC
CHECK (SoTC IN(2,3,4))

-- Năm đăng ký học của một sinh viên phải lớn hơn năm sinh của sinh viên đó.
GO
CREATE OR ALTER TRIGGER trg_namhoc
ON DANGKY
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT 1
		FROM inserted i
		JOIN SINHVIEN SV ON SV.MaSV = i.MaSV
		WHERE i.NamHoc <= SV.NamSinh
	)
	BEGIN
		PRINT N'Năm đăng ký học của một sinh viên phải lớn hơn năm sinh của sinh viên đó'
		ROLLBACK TRANSACTION
	END
END

-- Liệt kê danh sách các sinh viên lớp “HTCL2022”. Sắp xếp theo họ tên tăng dần.
SELECT MaSV, HoTen
FROM SINHVIEN
WHERE MaLop = 'HTCL2022'
ORDER BY HoTen ASC

-- Thống kê số lượng môn học đăng ký của từng sinh viên trong học kỳ 1 năm 2023.
-- Thông tin thống kê gồm: mã sinh viên, tên sinh viên và số lượng môn học đăng ký.
SELECT SV.MaSV, SV.HoTen, COUNT (DK.MaMH) AS SoLuongMonHoc
FROM SINHVIEN SV
LEFT JOIN DANGKY DK ON SV.MaSV = DK.MaSV
WHERE DK.HocKy = 1
AND Dk.NamHoc = 2023
GROUP BY SV.MaSV, SV.HoTen

-- Liệt kê những sinh viên lớp “HTCL2021” chưa đăng ký học môn “Hệ quản trị Cơ
--sở dữ liệu” trong năm 2023
SELECT SV.MaSV, SV.HoTen
FROM SINHVIEN SV
WHERE SV.MaLop = 'HTCL2021'
EXCEPT
SELECT SV.MaSV, SV.HoTen
FROM SINHVIEN SV
JOIN DANGKY DK ON SV.MaSV = DK.MaSV
JOIN MON M ON M.MaMH =DK.MaMH
WHERE SV.MaLop = 'HTCL2021'
AND M.TenMH = N'Hệ quản trị cơ sở dữ liệu'
AND DK.NamHoc = 2023
-- Liệt kê sinh viên (HoTen) lớp “HTCL2021” đăng ký học môn “Hệ quản trị Cơ sở
-- dữ liệu” và “Lập trình Java” trong học kỳ 2 năm 2023
SELECT SV.HoTen
FROM SINHVIEN SV
JOIN DANGKY DK ON SV.MaSV = DK.MaSV
JOIN MON M ON M.MaMH = DK.MaMH
WHERE SV.MaLop = 'HTCL2021'
AND M.TenMH = N'Hệ quản trị cơ sở dữ liệu'
AND DK.HocKy = 2
AND NamHoc = 2023
INTERSECT
SELECT SV.HoTen
FROM SINHVIEN SV
JOIN DANGKY DK ON SV.MaSV = DK.MaSV
JOIN MON M ON M.MaMH = DK.MaMH
WHERE SV.MaLop = 'HTCL2021'
AND M.TenMH = N'Lập trình Java'
AND DK.HocKy = 2
AND NamHoc = 2023

-- Tìm sinh viên (HoTen) đã đăng ký học tất cả các môn của Khoa ‘Hệ thống thông
-- tin’.
SELECT SV.HoTen
FROM SINHVIEN SV
JOIN DANGKY DK On SV.MaSV = DK.MaSV
JOIN MON M ON M.MaMH = DK.MaMH
JOIN KHOA K ON K.MaKhoa = M.MaKhoa
WHERE K.TenKhoa = N'Hệ thống thông tin'
GROUP BY SV.MaSV, SV.HoTen
HAVING COUNT (DISTINCT DK.MaMH) = (
	SELECT COUNT (M2.MaMH)
	FROM MON M2
	JOIN KHOA K2 ON K2.MaKhoa = M2.MaKhoa
	WHERE K2.TenKhoa = N'Hệ thống thông tin'
)

-- Tìm môn học (MaMH, TenMH) được sinh viên đăng ký học nhiều nhất trong học
-- kỳ 1 năm 2023
-- cách 1
SELECT MH.MaMH, MH.TenMH
FROM MON MH
JOIN DANGKY DK ON MH.MaMH = DK.MaMH
WHERE DK.HocKy = 1
AND DK.NamHoc = 2023
GROUP BY MH.MaMH, MH.TenMH
HAVING COUNT (DK.MaSV) >= ALL (
	SELECT COUNT (DK2.MaSV)
	FROM DANGKY DK2
	WHERE DK2.HocKy = 1
	AND DK2.NamHoc = 2023
	GROUP BY DK2.MaMH
)

--cách 2
SELECT TOP 1 WITH TIES MH.MaMH, MH.TenMH, COUNT(DK.MaSV) as SoLuong
FROM MON MH
JOIN DANGKY DK ON MH.MaMH = DK.MaMH
WHERE DK.HocKy = 1 AND DK.NamHoc = 2023
GROUP BY MH.MaMH, MH.TenMH
ORDER BY COUNT(DK.MaSV) DESC






















