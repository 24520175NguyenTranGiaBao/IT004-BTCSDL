CREATE DATABASE QLCS
USE QLCS

CREATE TABLE CASI (
	MaCS CHAR(5) PRIMARY KEY,
	HoTen VARCHAR(30),
	NgaySinh SMALLDATETIME,
	SoDT VARCHAR(15)
)

CREATE TABLE BAIHAT (
	MaBH CHAR(5) PRIMARY KEY,
	TenBH VARCHAR(25),
	NgayST SMALLDATETIME,
	MaTG CHAR(5)
)

CREATE TABLE TACGIA (
	MaTG CHAR(5) PRIMARY KEY,
	HoTen VARCHAR(20),
	NgSinh SMALLDATETIME,
	SoDT INT
)

CREATE TABLE LICHDIEN (
	NgayDien SMALLDATETIME,
	MaCS CHAR(5),
	MaBH CHAR(5),
	PRIMARY KEY (NgayDien, MaCS, MaBH),
	DiaDiem VARCHAR(50),
	TenSK VARCHAR(20)
)

ALTER TABLE BAIHAT
ADD CONSTRAINT FK_MaTG
FOREIGN KEY (MaTG)
REFERENCES TACGIA(MaTG)

ALTER TABLE LICHDIEN
ADD CONSTRAINT FK_MaCS
FOREIGN KEY (MaCS)
REFERENCES CASI(MaCS)

ALTER TABLE LICHDIEN
ADD CONSTRAINT FK_MaBH
FOREIGN KEY (MaBH)
REFERENCES BAIHAT(MaBH)

-- Trong cùng một ngày diễn, mỗi ca sĩ phải hát ít nhất 2 bài trở lên
GO
CREATE TRIGGER TG_2a ON LICHDIEN FOR INSERT, UPDATE
AS 
BEGIN 
    IF EXISTS (
        SELECT LD.MaCS, LD.NgayDien
        FROM LICHDIEN LD
        JOIN INSERTED I ON LD.MaCS = I.MaCS AND LD.NgayDien = I.NgayDien
        GROUP BY LD.MaCS, LD.NgayDien
        HAVING COUNT(*) < 2
    )
    BEGIN 
        PRINT N'Mỗi ca sĩ phải hát ít nhất 2 bài trong một ngày diễn'
        ROLLBACK TRAN
    END
END
-- Ngày diễn của một ca sĩ phải lớn hơn ngày sinh của ca sĩ đó. 
GO
CREATE OR ALTER TRIGGER trg_ngaydien2
ON LICHDIEN
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT *
		FROM inserted I
		JOIN CASI CS ON I.MaCS = CS.MaCS
		WHERE I.NgayDien <= CS.NgaySinh
	)
	BEGIN
		PRINT N'Ngày diễn của một ca sĩ phải lớn hơn ngày sinh'
		ROLLBACK TRANSACTION
	END
END

-- Liệt kê các bài hát (MaBH, TenBH) do nhạc sĩ ‘Trịnh Công Sơn’ sáng tác được biểu
-- diễn trong đêm nhạc ngày ‘26/09/2021’. Kết quả xuất ra theo tên bài hát có thứ tự
-- tăng dần

SELECT BH.MaBH, BH.TenBH
FROM BAIHAT BH
JOIN TACGIA TG ON BH.MaTG = TG.MaTG
JOIN LICHDIEN LD ON LD.MaBH = BH.MaBH
WHERE TG.HoTen = N'Trịnh Công Sơn'
AND LD.NgayDien = '2021-09-26'
ORDER BY BH.TenBH ASC

-- Tìm tác giả (MaTG,HoTen) đã sáng tác bài hát ‘Nối vòng tay lớn’ được ca sĩ ‘Tạ
-- Minh Tâm’ trình bày trong đêm nhạc ngày ‘26/09/2021’. 

SELECT TG.MaTG, TG.HoTen
FROM TACGIA TG
JOIN BAIHAT BH ON TG.MaTG = BH.MaTG
JOIN LICHDIEN LD ON LD.MaBH = BH.MaBH
JOIN CASI CS ON CS.MaCS = LD.MaCS
WHERE CS.HoTen = N'Tạ Minh Tâm'
AND LD.NgayDien = '2021-09-26'
AND BH.TenBH = N'Nối vòng tay lớn'

-- Thống kê số lượng bài hát trình bày của từng ca sĩ trong đêm nhạc ngày ‘26/09/2021’.
-- Thông tin thống kê gồm: mã ca sĩ, tên ca sĩ và số lượng bài hát trình bày

SELECT CS.MaCS, CS.HoTen, COUNT(LD.MaBH) AS SoLuongBaiHat
FROM LICHDIEN LD
JOIN CASI CS ON CS.MaCS = LD.MaCS
WHERE LD.NgayDien = '2021-09-26'
GROUP BY CS.MaCS, CS.HoTen

-- Liệt kê ca sĩ (HoTen) trong đêm nhạc ngày ‘22/12/2023’ tại ‘sân vận động Mỹ Đình
-- Hà Nội’ (TenSK) đã trình diễn bài hát của nhạc sĩ ‘Văn Cao’ nhưng không trình
-- diễn bài hát của nhạc sĩ ‘Hoàng Quý’.

SELECT CS.HoTen
FROM CASI CS
JOIN LICHDIEN LD ON LD.MaCS = CS.MaCS
JOIN BAIHAT BH ON BH.MaBH = LD.MaBH
JOIN TACGIA TG ON TG.MaTG = BH.MaTG
WHERE LD.NgayDien = '2023-12-22'
AND LD.TenSK = N'sân vận động Mỹ Đình Hà Nội'
AND TG.HoTen = N'Văn Cao'
EXCEPT
SELECT CS.HoTen
FROM CASI CS
JOIN LICHDIEN LD ON LD.MaCS = CS.MaCS
JOIN BAIHAT BH ON BH.MaBH = LD.MaBH
JOIN TACGIA TG ON TG.MaTG = BH.MaTG
WHERE LD.NgayDien = '2023-12-22'
AND LD.TenSK = N'sân vận động Mỹ Đình Hà Nội'
AND TG.HoTen = N'Hoàng Quý'

-- Tìm ca sĩ (HoTen) đã hát tất cả các bài hát do nhạc sĩ ‘Trịnh Công Sơn’ sáng tác sau
-- năm 1990. 
SELECT CS.HoTen
FROM CASI CS
JOIN LICHDIEN LD ON LD.MaCS = CS.MaCS
JOIN BAIHAT BH ON BH.MaBH = LD.MaBH
JOIN TACGIA TG ON TG.MaTG = BH.MaTG
WHERE TG.HoTen = N'Trịnh Công Sơn'
AND YEAR(BH.NgayST) > 1990
GROUP BY CS.HoTen, CS.MaCS
HAVING COUNT (DISTINCT BH.MaBH) = (
	SELECT COUNT (BH2.MaBH)
	FROM BAIHAT BH2
	JOIN TACGIA TG2 ON TG2.MaTG = BH2.MaTG
	WHERE TG2.HoTen = N'Trịnh Công Sơn'
	AND YEAR (BH2.NgayST) > 1990
)

-- Tìm ca sĩ (MaCS,HoTen) đã hát nhiều bài hát nhất của nhạc sĩ ‘Trịnh Công Sơn
SELECT CS.MaCS, CS.HoTen
FROM CASI CS
JOIN LICHDIEN LD ON LD.MaCS = CS.MaCS
JOIN BAIHAT BH ON BH.MaBH = LD.MaBH
JOIN TACGIA TG ON TG.MaTG = BH.MaTG
WHERE TG.HoTen = N'Trịnh Công Sơn'
GROUP BY CS.MaCS, CS.HoTen
HAVING COUNT (DISTINCT BH.MaBH) >= ALL (
	SELECT COUNT (LD2.MaBH)
	FROM LICHDIEN LD2
	JOIN BAIHAT BH2 ON LD2.MaBH = BH2.MaBH
	JOIN TACGIA TG2 ON TG2.MaTG = BH2.MaTG
	WHERE TG2.HoTen = N'Trịnh Công Sơn'
	GROUP BY LD2.MaCS
)
