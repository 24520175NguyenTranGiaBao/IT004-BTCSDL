CREATE DATABASE QLCASI
USE QLCASI

CREATE TABLE CASI (
    MaCS char(5) NOT NULL,
    HoTen varchar(30),
    NgaySinh smalldatetime,
    SoDT varchar(15),
    CONSTRAINT PK_CASI PRIMARY KEY (MaCS)
);

CREATE TABLE TACGIA (
    MaTG char(5) NOT NULL,
    HoTen varchar(20),
    NgSinh smalldatetime,
    SoDT int,
    CONSTRAINT PK_TACGIA PRIMARY KEY (MaTG)
);

CREATE TABLE BAIHAT (
    MaBH char(5) NOT NULL,
    TenBH varchar(25),
    NgayST smalldatetime,
    MaTG char(5),
    CONSTRAINT PK_BAIHAT PRIMARY KEY (MaBH)
);

CREATE TABLE LICHDIEN (
    NgayDien smalldatetime NOT NULL,
    MaCS char(5) NOT NULL,
    MaBH char(5) NOT NULL,
    DiaDiem varchar(50),
    TenSK varchar(20),
    CONSTRAINT PK_LICHDIEN PRIMARY KEY (NgayDien, MaCS, MaBH)
);

ALTER TABLE BAIHAT
ADD CONSTRAINT FK_BAIHAT_TACGIA
FOREIGN KEY (MaTG) REFERENCES TACGIA(MaTG);

ALTER TABLE LICHDIEN
ADD CONSTRAINT FK_LICHDIEN_CASI
FOREIGN KEY (MaCS) REFERENCES CASI(MaCS);

ALTER TABLE LICHDIEN
ADD CONSTRAINT FK_LICHDIEN_BAIHAT
FOREIGN KEY (MaBH) REFERENCES BAIHAT(MaBH);

--a.Liệt kê các bài hát (MaBH, TenBH) do nhạc sĩ ‘Trịnh Công Sơn’ sáng tác được biểu
--diễn trong đêm nhạc ngày ‘26/09/2021’. Kết quả xuất ra theo tên bài hát có thứ tự
-- tăng dần. 

SELECT BH.MaBH, BH.TenBH
FROM BAIHAT BH
JOIN TACGIA TG ON BH.MaTG = TG.MaTG
JOIN LICHDIEN LD ON BH.MaBH = LD.MaBH
WHERE TG.HoTen = N'Trịnh Công Sơn'
AND LD.NgayDien = '2021-09-26'
ORDER BY BH.TenBH ASC

-- b. Tìm tác giả (MaTG,HoTen) đã sáng tác bài hát ‘Nối vòng tay lớn’ được ca sĩ ‘Tạ
-- Minh Tâm’ trình bày trong đêm nhạc ngày ‘26/09/2021’
SELECT TG.MaTG, TG.HoTen
FROM TACGIA TG
JOIN BAIHAT BH ON TG.MaTG = BH.MaTG
JOIN LICHDIEN LD ON LD.MaBH = BH.MaBH
JOIN CASI CS ON CS.MaCS = LD.MaCS
WHERE BH.TenBH = N'Nối vòng tay lớn'
AND CS.HoTen = N'Tạ Minh Tâm'
AND LD.NgayDien = '2021-09-26'

-- c. Thống kê số lượng bài hát trình bày của từng ca sĩ trong đêm nhạc ngày ‘26/09/2021’.
-- Thông tin thống kê gồm: mã ca sĩ, tên ca sĩ và số lượng bài hát trình bày.
SELECT CS.MaCS, CS.HoTen, COUNT(LD.MaBH) AS SoLuongBaiHat
FROM CASI CS
JOIN LICHDIEN LD ON CS.MaCS = LD.MaCS
WHERE LD.NgayDien = '2021-09-26'
GROUP BY CS.MaCS, CS.HoTen;





SELECT DISTINCT CS.HoTen
FROM CASI CS
JOIN LICHDIEN LD ON CS.MaCS = LD.MaCS
JOIN BAIHAT BH ON LD.MaBH = BH.MaBH
JOIN TACGIA TG ON BH.MaTG = TG.MaTG
WHERE LD.NgayDien = '2023-12-22' 
  AND LD.TenSK = N'sân vận động Mỹ Đình Hà Nội'
  AND TG.HoTen = N'Văn Cao'
  AND CS.MaCS NOT IN (
      SELECT CS2.MaCS
      FROM CASI CS2
      JOIN LICHDIEN LD2 ON CS2.MaCS = LD2.MaCS
      JOIN BAIHAT BH2 ON LD2.MaBH = BH2.MaBH
      JOIN TACGIA TG2 ON BH2.MaTG = TG2.MaTG
      WHERE LD2.NgayDien = '2023-12-22'
        AND LD2.TenSK = N'sân vận động Mỹ Đình Hà Nội'
        AND TG2.HoTen = N'Hoàng Quý'
  );


SELECT CS.HoTen
FROM CASI CS
JOIN LICHDIEN LD ON CS.MaCS = LD.MaCS
JOIN BAIHAT BH ON LD.MaBH = BH.MaBH
JOIN TACGIA TG ON BH.MaTG = TG.MaTG
WHERE TG.HoTen = N'Trịnh Công Sơn' 
  AND YEAR(BH.NgayST) > 1990
GROUP BY CS.MaCS, CS.HoTen
HAVING COUNT(DISTINCT BH.MaBH) = (
    SELECT COUNT(*)
    FROM BAIHAT BH2
    JOIN TACGIA TG2 ON BH2.MaTG = TG2.MaTG
    WHERE TG2.HoTen = N'Trịnh Công Sơn' 
      AND YEAR(BH2.NgayST) > 1990
);


SELECT CS.MaCS, CS.HoTen
FROM CASI CS
JOIN LICHDIEN LD ON CS.MaCS = LD.MaCS
JOIN BAIHAT BH ON LD.MaBH = BH.MaBH
JOIN TACGIA TG ON BH.MaTG = TG.MaTG
WHERE TG.HoTen = N'Trịnh Công Sơn'
GROUP BY CS.MaCS, CS.HoTen
HAVING COUNT(LD.MaBH) >= ALL (
    SELECT COUNT(LD2.MaBH)
    FROM CASI CS2
    JOIN LICHDIEN LD2 ON CS2.MaCS = LD2.MaCS
    JOIN BAIHAT BH2 ON LD2.MaBH = BH2.MaBH
    JOIN TACGIA TG2 ON BH2.MaTG = TG2.MaTG
    WHERE TG2.HoTen = N'Trịnh Công Sơn'
    GROUP BY CS2.MaCS
);