-- Đề 101 HK1 2024-2025
CREATE DATABASE QUANLYPHONGTRO
USE QUANLYPHONGTRO

CREATE TABLE PHONGTRO(
	MaPT CHAR(5) PRIMARY KEY,
	TenPT NVARCHAR(50),
	DienTich FLOAT,
	GiaPT MONEY,
	TinhTrangPT NVARCHAR(20)
)

CREATE TABLE CUDAN(
	MaCD CHAR(5) PRIMARY KEY,
	HoTen NVARCHAR(50),
	CCCD NVARCHAR(12),
	DiaChi NVARCHAR(100),
	SoDT VARCHAR(15),
	NgayThue SMALLDATETIME,
	TrangThaiCD NVARCHAR(15)
)

CREATE TABLE HOPDONG (
	MaHD CHAR(5) PRIMARY KEY,
	MaCD CHAR(5),
	MaPT CHAR(5),
	NgayKy SMALLDATETIME,
	NgayHetHan SMALLDATETIME,
	TrangThaiHD NVARCHAR(20)
)

CREATE TABLE DICHVU (
	MaDV CHAR(5) PRIMARY KEY,
	TenDV NVARCHAR(50),
	DonGia MONEY
)

CREATE TABLE PHIEUTINHTIEN (
	MaPTT CHAR(5) PRIMARY KEY,
	MaHD CHAR(5),
	SoTienDichVu MONEY,
	SoTienThuePT MONEY,
	TongTienTT MONEY,
	NgayTinhTien SMALLDATETIME,
	TinhTrangTT NVARCHAR(20),
	PhuongThucTT NVARCHAR(20)
)

CREATE TABLE CHITIETTTDV (
	MaPTT CHAR(5),
	MADV CHAR(5),
	PRIMARY KEY (MaPTT, MADV),
	ChiSoDV FLOAT,
	ThanhTien MONEY
)

ALTER TABLE HOPDONG
ADD CONSTRAINT FK_MaPT
FOREIGN KEY (MaPT)
REFERENCES PHONGTRO (MaPT)

ALTER TABLE HOPDONG
ADD CONSTRAINT FK_MaCD
FOREIGN KEY (MaCD)
REFERENCES CUDAN (MaCD)

ALTER TABLE CHITIETTTDV
ADD CONSTRAINT FK_MaPTT
FOREIGN KEY (MaPTT)
REFERENCES PHIEUTINHTIEN (MaPTT)

ALTER TABLE CHITIETTTDV
ADD CONSTRAINT FK_MADV
FOREIGN KEY (MADV)
REFERENCES DICHVU (MaDV)

ALTER TABLE PHIEUTINHTIEN
ADD CONSTRAINT FK_MaHD
FOREIGN KEY (MaHD)
REFERENCES HOPDONG (MaHD)

--Diện tích của một căn phòng trọ có giá trị từ 10 đến 50 m2
ALTER TABLE PHONGTRO
ADD CONSTRAINT CK_DT
CHECK (DienTich BETWEEN 10 AND 50)

-- Tình trạng thanh toán của phiếu tính tiền chỉ nhận một trong hai giá trị ‘Chưa thanh 
-- toán’ hoặc ‘Đã thanh toán’.
ALTER TABLE PHIEUTINHTIEN
ADD CONSTRAINT CK_TrangThaiTT
CHECK (TinhTrangTT IN (N'Chưa thanh toán', N'Đã thanh toán'))

-- Số tiền của mỗi dịch vụ đã sử dụng (ThanhTien) trong chi tiết tính tiền được tính bằng 
--chỉ số đã sử dụng (ChiSoDV) nhân với đơn giá (DonGia) của dịch vụ đó. Hãy viết trigger để 
--tạo ràng buộc trên cho thao tác thêm mới một chi tiết sử dụng dịch vụ.
CREATE OR ALTER TRIGGER trg_insert_chitietttdv
ON CHITIETTTDV
FOR INSERT
AS
BEGIN
	IF EXISTS (
		SELECT *
		FROM inserted I
		JOIN DICHVU DV ON DV.MaDV = I.MADV
		WHERE ThanhTien <> (ChiSoDV * DonGia)
	)
	BEGIN 
		PRINT N'Không thêm thành công'
		ROLLBACK TRANSACTION
	END
END

-- Liệt kê thông tin các phòng trọ (mã, tên phòng) có giá thuê trên 5,000,000 VNĐ cùng 
-- với thông tin cư dân (mã, họ tên) đã ký hợp đồng thuê các phòng đó trong năm 2024
SELECT PT.MaPT, PT.TenPT, CD.MaCD, CD.HoTen
FROM PHONGTRO PT
JOIN HOPDONG HD ON HD.MaPT = PT.MaPT
JOIN CUDAN CD ON CD.MaCD = HD.MaCD
WHERE PT.GiaPT > 5000000
AND YEAR(HD.NgayKy) = 2024
--Liệt kê các dịch vụ (mã, tên dịch vụ) đã được thanh toán trong các phiếu tính tiền của 
--cả hai tháng 11 và tháng 12 năm 2024 cho hợp đồng có mã ‘HD002’. (1 điểm)
-- Dịch vụ tháng 11
SELECT DV.MaDV, DV.TenDV
FROM DICHVU DV
JOIN CHITIETTTDV CT ON CT.MADV = DV.MaDV
JOIN PHIEUTINHTIEN PTT ON PTT.MaPTT = CT.MaPTT
WHERE PTT.MaHD = 'HD002' 
  AND PTT.TinhTrangTT = N'Đã thanh toán'
  AND YEAR(PTT.NgayTinhTien) = 2024 AND MONTH(PTT.NgayTinhTien) = 11
INTERSECT
SELECT DV.MaDV, DV.TenDV
FROM DICHVU DV
JOIN CHITIETTTDV CT ON CT.MADV = DV.MaDV
JOIN PHIEUTINHTIEN PTT ON PTT.MaPTT = CT.MaPTT
WHERE PTT.MaHD = 'HD002' 
  AND PTT.TinhTrangTT = N'Đã thanh toán'
  AND YEAR(PTT.NgayTinhTien) = 2024 AND MONTH(PTT.NgayTinhTien) = 12
-- Tìm thông tin các phiếu tính tiền (mã phiếu tính tiền, mã hợp đồng) trong năm 2024 và 
-- đã sử dụng tất cả các dịch vụ có đơn giá từ 150,000 VNĐ trở xuống
SELECT PTT.MaPTT, PTT.MaHD
FROM PHIEUTINHTIEN PTT
JOIN CHITIETTTDV CT ON CT.MaPTT = PTT.MaPTT
JOIN DICHVU DV ON DV.MaDV = CT.MADV
WHERE YEAR(PTT.NgayTinhTien) = 2024
AND DV.DonGia <= 150000
GROUP BY PTT.MaPTT, PTT.MaHD
HAVING COUNT (DISTINCT CT.MADV) = (
	SELECT COUNT (MaDV)
	FROM DICHVU
	WHERE DonGia <= 150000
)
-- Với mỗi hợp đồng, hãy cho biết số lượng phiếu tính tiền đã được thanh toán bằng phương 
-- thức ‘Chuyển khoản’ trong năm 2024. Thông tin hiển thị: Mã hợp đồng, mã cư dân, số lượng
SELECT HD.MaHD, HD.MaCD, COUNT (PTT.MaPTT) AS SoLuong
FROM HOPDONG HD
LEFT JOIN PHIEUTINHTIEN PTT ON PTT.MaHD = HD.MaHD
AND YEAR(PTT.NgayTinhTien) = 2024
AND PTT.TinhTrangTT = N'Đã thanh toán'
AND PTT.PhuongThucTT = N'Chuyển khoản'
GROUP BY HD.MaHD, HD.MaCD
-- Trong các cư dân có số lần ký hợp đồng nhiều nhất, tìm cư dân (mã, họ tên) có tổng số
-- tiền đã thanh toán trong năm 2024 nhiều hơn 15,000,000 VNĐ
SELECT CD.MaCD, CD.HoTen
FROM CUDAN CD
JOIN HOPDONG HD ON CD.MaCD = HD.MaCD
JOIN PHIEUTINHTIEN PTT ON PTT.MaHD = HD.MaHD
WHERE YEAR(PTT.NgayTinhTien) = 2024
AND PTT.TinhTrangTT = N'Đã thanh toán'
AND CD.MaCD IN (
    SELECT TOP 1 WITH TIES MaCD
    FROM HOPDONG
    GROUP BY MaCD
    ORDER BY COUNT(MaHD) DESC
)
GROUP BY CD.MaCD, CD.HoTen
HAVING SUM(PTT.TongTienTT) > 15000000;
