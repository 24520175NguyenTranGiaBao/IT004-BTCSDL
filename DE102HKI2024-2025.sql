USE QLPT

--Giá thuê phòng trọ có giá trị trong khoảng từ 500,000 VNĐ đến 20,000,000 VNĐ. (0.5
--điểm)
ALTER TABLE PHONGTRO
ADD CONSTRAINT CK_GiaPT
CHECK(GiaPT BETWEEN 500000 AND 20000000)

-- Trạng thái cư dân chỉ nhận một trong hai giá trị ‘Đang ở’ hoặc ‘Đã rời đi’. (0.5 điểm)
ALTER TABLE CUDAN
ADD CONSTRAINT CK_TTCD
CHECK(TrangThaiCD IN (N'Đang ở', N'Đã rời đi'))

-- Số tiền của mỗi dịch vụ đã sử dụng (ThanhTien) trong chi tiết tính tiền được tính bằng
-- chỉ số đã sử dụng (ChiSoDV) nhân với đơn giá (DonGia) của dịch vụ đó. Hãy viết trigger để
-- tạo ràng buộc trên cho thao tác sửa một chi tiết sử dụng dịch vụ. 
GO
CREATE OR ALTER TRIGGER TRG_THANHTIEN
ON CHITIETTTDV
FOR UPDATE 
AS
BEGIN
	IF EXISTS (
		SELECT 1
		FROM inserted I
		JOIN DICHVU DV ON I.MADV = DV.MaDV
		WHERE ThanhTien <> ChiSoDV * DonGia
	)
	BEGIN 
		PRINT N'Lỗi: ThanhTien != ChiSoDV * DonGia'
		ROLLBACK TRANSACTION
	END
END

-- Liệt kê thông tin các cư dân (mã, họ tên) cùng thông tin phòng trọ (mã, tên phòng) mà
-- cư dân đó đã ký hợp đồng với trạng thái hợp đồng ‘Đã hết hạn’ trong năm 2024.
SELECT CD.MaCD, CD.HoTen, PT.MaPT, PT.TenPT
FROM CUDAN CD
JOIN HOPDONG HD ON CD.MaCD = HD.MaCD
JOIN PHONGTRO PT ON PT.MaPT = HD.MaPT
WHERE TrangThaiHD = N'Đã hết hạn'
AND YEAR (NgayHetHan) = 2024

-- Tìm các hợp đồng (mã hợp đồng, mã phòng trọ) đã thanh toán các phiếu tính tiền trong
-- năm 2024 nhưng không sử dụng dịch vụ nào có chỉ số từ 5 trở lên trong những chi tiết của
-- phiếu tính tiền đó.
SELECT DISTINCT HD.MaHD, HD.MaPT
FROM HOPDONG HD
JOIN PHIEUTINHTIEN PTT ON PTT.MaHD = HD.MaHD
WHERE YEAR(PTT.NgayTinhTien) = 2024
EXCEPT
SELECT HD.MaHD, HD.MaPT
FROM HOPDONG HD
JOIN PHIEUTINHTIEN PTT ON PTT.MaHD = HD.MaHD
JOIN CHITIETTTDV CT ON CT.MaPTT = PTT.MaPTT
WHERE CT.ChiSoDV >= 5 

-- Tìm thông tin các dịch vụ (mã, tên dịch vụ) có đơn giá trên 10,000 VNĐ và có trong chi
-- tiết của tất cả các phiếu tính tiền ngày 15/12/2024.
SELECT DV.MaDV, DV.TenDV
FROM DICHVU DV
JOIN CHITIETTTDV CT ON CT.MADV = DV.MaDV
JOIN PHIEUTINHTIEN PTT ON PTT.MaPTT = CT.MaPTT
WHERE DV.DonGia > 10000
AND PTT.NgayTinhTien = '2024-12-15'
GROUP BY DV.MaDV, DV.TenDV
HAVING COUNT (DISTINCT PTT.MaPTT) = (
	SELECT COUNT (MaPTT)
	FROM PHIEUTINHTIEN
	WHERE NgayTinhTien = '2024-12-15' 
)

-- Với mỗi hợp đồng đã hết hạn, hãy cho biết số lượng phiếu tính tiền trong năm 2024 đã
-- được thanh toán. Thông tin hiển thị: Mã hợp đồng, mã cư dân, số lượng.
SELECT HD.MaHD, HD.MaCD, COUNT (PTT.MaPTT) AS SoLuongPTT
FROM HOPDONG HD
LEFT JOIN PHIEUTINHTIEN PTT ON PTT.MaHD = HD.MaHD
AND PTT.TinhTrangTT = N'Đã thanh toán'
AND YEAR(PTT.NgayTinhTien) = 2024
WHERE HD.TrangThaiHD = N'Đã hết hạn'
GROUP BY HD.MaHD, Hd.MaCD
-- Trong các cư dân có số lần ký hợp đồng ít nhất, tìm cư dân (mã, họ tên) có tổng số tiền
-- đã thanh toán trong năm 2024 nhiều hơn 5,000,000 VNĐ
SELECT CD.MaCD, CD.HoTen
FROM CUDAN CD
JOIN HOPDONG HD ON HD.MaCD = CD.MaCD
JOIN PHIEUTINHTIEN PTT ON PTT.MaHD = HD.MaHD
WHERE PTT.TinhTrangTT = N'Đã thanh toán'
AND YEAR(PTT.NgayTinhTien) = 2024
AND CD.MaCD IN (
	SELECT TOP 1 WITH TIES MaCD
	FROM HOPDONG
	GROUP BY MaCD
	ORDER BY COUNT(MaHD) ASC
)
GROUP BY CD.MaCD, CD.HoTen
HAVING SUM(PTT.TongTienTT) > 5000000
