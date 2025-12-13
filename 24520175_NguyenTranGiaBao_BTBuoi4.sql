CREATE DATABASE QLBAOHIEM
USE QLBAOHIEM

CREATE TABLE KHACHHANG(
	MaKH CHAR(10) PRIMARY KEY,
	HoTen NVARCHAR(100) NOT NULL,
	NgSinh DATE NOT NULL,
	CCCD CHAR(12) UNIQUE NOT NULL,
	NgheNghiep NVARCHAR(100)
)

CREATE TABLE LOAIBAOHIEM(
	MaLBH CHAR(10) PRIMARY KEY,
	TenLBH NVARCHAR(100) NOT NULL,
	STBaoHiem DECIMAL(18,2) NOT NULL,
	STDongDinhKy DECIMAL(18,2) NOT NULL,
	KyThanhToan NVARCHAR(20)
)

CREATE TABLE HOPDONG(
	SoHD CHAR(10) PRIMARY KEY,
	MaKHDaiDien CHAR(10) NOT NULL,
	NgKyHD DATE NOT NULL,
	NgHieuLuc DATE NOT NULL,
	NgHetHan DATE NOT NULL,
	TriGia DECIMAL(18,2)
)

CREATE TABLE CHITIETHD(
	MaCTHD CHAR(10) PRIMARY KEY,
    SoHD CHAR(10) NOT NULL,
    MaKHThuHuong CHAR(10) NOT NULL,
    MaLBH CHAR(10) NOT NULL
)

CREATE TABLE LSDONGTIEN(
	MaGD CHAR(10) PRIMARY KEY,
    MaCTHD CHAR(10) NOT NULL,
    NgDongTien DATE NOT NULL,
    STDong DECIMAL(18,2),
    PhuongThuc NVARCHAR(30)
)

CREATE TABLE YEUCAUBAOHIEM(
	MaYC CHAR(10) PRIMARY KEY,
    MaCTHD CHAR(10) NOT NULL,
    STYeuCau DECIMAL(18,2),
    STDuyetChi DECIMAL(18,2),
    NgYeuCau DATE,
    TrangThai NVARCHAR(20)
)

ALTER TABLE HOPDONG
ADD CONSTRAINT FK_MaKHDaiDien FOREIGN KEY(MaKHDaiDien)
REFERENCES KHACHHANG(MaKH)

ALTER TABLE CHITIETHD 
ADD CONSTRAINT FK_SoHD FOREIGN KEY (SoHD) 
REFERENCES HOPDONG(SoHD)

ALTER TABLE CHITIETHD
ADD CONSTRAINT FK_MaKHThuHuong FOREIGN KEY (MaKHThuHuong) 
REFERENCES KHACHHANG(MaKH)

ALTER TABLE CHITIETHD
ADD CONSTRAINT FK_MaLBH FOREIGN KEY(MaLBH)
REFERENCES LOAIBAOHIEM(MaLBH)

ALTER TABLE LSDONGTIEN
ADD CONSTRAINT FK_MaCTHDDONGTIEN FOREIGN KEY (MaCTHD)
REFERENCES CHITIETHD(MaCTHD)

ALTER TABLE YEUCAUBAOHIEM
ADD CONSTRAINT FK_MaCTHDYCBH FOREIGN KEY (MaCTHD)
REFERENCES CHITIETHD(MaCTHD)

--1a. Tạo ràng buộc cho thuộc tính trạng thái của yêu cầu bảo hiểm chỉ nhận các giá trị: ‘Đang
--xét duyệt’, ‘Đã chi trả’, ‘Đã từ chối’, ‘Đã hủy’.
ALTER TABLE YEUCAUBAOHIEM
ADD CONSTRAINT CHECK_TrangThai
CHECK (TrangThai IN (N'Đang xét duyệt', N'Đã chi trả', N'Đã từ chối', N'Đã hủy'))

--1b. Tạo ràng buộc sau: Khách hàng đại diện ký hợp đồng cũng là một khách hàng.
ALTER TABLE HOPDONG
ADD CONSTRAINT FK_HOPDONG_KHACHHANG FOREIGN KEY (MaKHDaiDien)
REFERENCES KHACHHANG(MaKH)

--1c. Cập nhật giảm 10% số tiền bảo hiểm tối đa và số tiền đóng định kỳ đối với loại bảo hiểm
--có tên là ‘Bảo hiểm sức khỏe nha khoa’
UPDATE LOAIBAOHIEM
SET STBaoHiem = STBaoHiem * 0.9,
	STDongDinhKy = STDongDinhKy * 0.9
WHERE TenLBH = N'Bảo hiểm sức khỏe nha khoa'

-- DU LIEU KHACHHANG
INSERT INTO KHACHHANG VALUES
('KH001', N'Nguyễn Văn A', '1980-05-12', '012345678901', N'Công nhân'),
('KH002', N'Trần Thị B', '1985-07-21', '023456789012', N'Giáo viên'),
('KH003', N'Lê Văn C', '1990-02-15', '034567890123', N'Nhân viên văn phòng'),
('KH004', N'Phạm Thị D', '1993-11-30', '045678901234', N'Kế toán'),
('KH005', N'Hoàng Văn E', '1988-09-19', '056789012345', N'Bác sĩ');

-- DU LIEU LOAIBAOHIEM
INSERT INTO LOAIBAOHIEM VALUES
('LBH201', N'Bảo hiểm nhân thọ cơ bản', 500000000, 5000000, N'Hàng năm'),
('LBH202', N'Bảo hiểm sức khỏe nha khoa', 300000000, 3000000, N'Hàng năm'),
('LBH203', N'Bảo hiểm tai nạn cá nhân', 200000000, 2000000, N'Tháng'),
('LBH204', N'Bảo hiểm xe cơ giới', 150000000, 1500000, N'Quý'),
('LBH205', N'Bảo hiểm tài sản', 400000000, 4000000, N'Hàng năm');

-- DU LIEU HOPDONG
INSERT INTO HOPDONG VALUES
('HD001', 'KH001', '2023-12-01', '2024-01-01', '2027-01-01', 300000000),
('HD002', 'KH002', '2024-05-10', '2024-06-01', '2027-06-01', 200000000),
('HD003', 'KH003', '2025-02-20', '2025-03-01', '2028-03-01', 500000000),
('HD004', 'KH004', '2024-10-15', '2024-11-01', '2027-11-01', 250000000),
('HD005', 'KH005', '2025-01-25', '2025-02-01', '2028-02-01', 450000000);

-- DU LIEU CHITIETHD
INSERT INTO CHITIETHD VALUES
('CT001', 'HD001', 'KH001', 'LBH201'),
('CT002', 'HD001', 'KH001', 'LBH202'),
('CT003', 'HD002', 'KH002', 'LBH203'),
('CT004', 'HD003', 'KH003', 'LBH202'),
('CT005', 'HD004', 'KH004', 'LBH204'),
('CT006', 'HD005', 'KH005', 'LBH205');

-- DU LIEU LSDONGTIEN
INSERT INTO LSDONGTIEN VALUES
('GD001', 'CT001', '2025-01-05', 5000000, N'Chuyển khoản'),
('GD002', 'CT002', '2025-03-01', 3000000, N'Tiền mặt'),
('GD003', 'CT003', '2025-04-10', 2000000, N'Chuyển khoản'),
('GD004', 'CT004', '2025-07-01', 3000000, N'Chuyển khoản'),
('GD005', 'CT005', '2025-09-01', 1500000, N'Tiền mặt'),
('GD006', 'CT006', '2025-11-05', 4000000, N'Chuyển khoản');

-- DU LIEU YEUCAUBAOHIEM
INSERT INTO YEUCAUBAOHIEM VALUES
('YC001', 'CT002', 5000000, 5000000, '2025-11-02', N'Đã chi trả'),
('YC002', 'CT003', 8000000, 0, '2025-10-01', N'Đang xét duyệt'),
('YC003', 'CT004', 10000000, 10000000, '2025-11-10', N'Đã chi trả'),
('YC004', 'CT005', 7000000, 0, '2025-09-15', N'Đã từ chối'),
('YC005', 'CT006', 9000000, 0, '2025-12-01', N'Đã hủy');

-- 2a.Liệt kê thông tin mã giao dịch, mã chi tiết hợp đồng của các lịch sử đóng tiền bảo hiểm
--trong năm 2025 và có phương thức đóng tiền là ‘Chuyển khoản’
SELECT MaGD, MaCTHD
FROM LSDONGTIEN
WHERE YEAR(NgDongTien) = 2025 AND PhuongThuc = N'Chuyển khoản'

-- 2b. Liệt kê thông tin số hợp đồng, mã chi tiết hợp đồng, họ tên khách hàng đại diện ký hợp
-- đồng của các hợp đồng có hiệu lực sau ngày 01/01/2025 và đã mua loại bảo hiểm có mã là ‘LBH202’
SELECT HOPDONG.SoHD, CHITIETHD.MaCTHD, KHACHHANG.HoTen
FROM HOPDONG
JOIN KHACHHANG ON HOPDONG.MaKHDaiDien = KHACHHANG.MaKH
JOIN CHITIETHD ON HOPDONG.SoHD = CHITIETHD.SoHD
WHERE HOPDONG.NgHieuLuc > '2025-01-01'
AND CHITIETHD.MaLBH = 'LBH202'

--2c. Liệt kê mã và họ tên khách hàng thụ hưởng, cùng với các mã yêu cầu giải quyết bảo hiểm
--trong tháng 11/2025 và có trạng thái là ‘Đã chi trả’ của các chi tiết hợp đồng mà họ đã tham gia

-- Cách 1
SELECT CTHD.MaKHThuHuong, KH.HoTen, YC.MaYC
FROM CHITIETHD CTHD JOIN KHACHHANG KH ON KH.MaKH = CTHD.MaKHThuHuong
LEFT JOIN YEUCAUBAOHIEM YC
	ON CTHD.MaCTHD = YC.MaCTHD
	AND YC.TrangThai = N'Đã chi trả'
	AND YEAR(NgYeuCau) = 2025
	AND MONTH(NgYeuCau) = 11

-- Cách 2
SELECT CTHD.MaKHThuHuong, KH.HoTen, YC.MaYC
FROM CHITIETHD CTHD JOIN KHACHHANG KH ON KH.MaKH = CTHD.MaKHThuHuong
LEFT JOIN
	(SELECT MaYC,MaCTHD
	FROM YEUCAUBAOHIEM
	WHERE TrangThai = N'Đã chi trả' 
	AND YEAR(NgYeuCau) = 2025
	AND MONTH(NgYeuCau)= 11
	) AS YC ON YC.MaCTHD = CTHD.MaCTHD

--2d.Liệt kê số hợp đồng, mã và họ tên khách hàng đại diện của các hợp đồng không có yêu cầu
-- giải quyết bảo hiểm nào trong năm 2025 có trạng thái là ‘Đã hủy’
SELECT HD.SoHD, MaKHDaiDien, HoTen
FROM HOPDONG HD, KHACHHANG KH
WHERE KH.MaKH = HD.MaKHDaiDien
EXCEPT
	SELECT HD.SoHD, MaKHDaiDien, HoTen
	FROM HOPDONG HD, KHACHHANG KH, CHITIETHD CTHD, YEUCAUBAOHIEM YC
	WHERE KH.MaKH = HD.MaKHDaiDien
	AND CTHD.SoHD = HD.SoHD
	AND YEAR(NgYeuCau) = 2025
	AND TrangThai = N'Đã hủy'
	AND YC.MaCTHD = CTHD.MaCTHD

--2e. Tìm số hợp đồng có lịch sử đóng tiền trong năm 2025 bằng phương thức 'Chuyển khoản'
--cho tất cả các loại bảo hiểm có kỳ thanh toán là ‘Hàng năm’
SELECT SoHD
FROM HOPDONG HD
WHERE NOT EXISTS (
	SELECT *
	FROM LOAIBAOHIEM LBH
	WHERE KyThanhToan = N'Hàng năm'
		AND NOT EXISTS (
			SELECT *
			FROM LSDONGTIEN LS, CHITIETHD CT
			WHERE LS.MaCTHD = CT.MaCTHD
			AND CT.MaLBH = LBH.MaLBH
			AND YEAR(LS.NgDongTien) = 2025
			AND PhuongThuc = N'Chuyển khoản'
			AND HD.SoHD = CT.SoHD
		)
)
-- 2f. Tìm số hợp đồng có số lượng yêu cầu giải quyết bảo hiểm trong năm 2025 với trạng thái
--‘Đã chi trả’ chiếm từ 80% trở lên trong tổng số yêu cầu giải quyết bảo hiểm trong năm 2025 của
--hợp đồng đó.
SELECT A.SoHD
FROM (
    SELECT CTHD.SoHD, COUNT(*) AS SLYC
    FROM YEUCAUBAOHIEM YC
    JOIN CHITIETHD CTHD ON YC.MaCTHD = CTHD.MaCTHD
    WHERE YEAR(YC.NgYeuCau) = 2025
    GROUP BY CTHD.SoHD
) A
JOIN (
    SELECT CTHD.SoHD, COUNT(*) AS SoDCT
    FROM YEUCAUBAOHIEM YC
    JOIN CHITIETHD CTHD ON YC.MaCTHD = CTHD.MaCTHD
    WHERE YEAR(YC.NgYeuCau) = 2025
      AND YC.TrangThai = N'Đã chi trả'
    GROUP BY CTHD.SoHD
) B ON A.SoHD = B.SoHD
WHERE B.SoDCT >= 0.8 * A.SLYC;
