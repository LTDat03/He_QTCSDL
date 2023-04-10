
CREATE DATABASE Sales  
ON   
( NAME = Sales_dat,  
    FILENAME = 'T:\saledat.mdf',  
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5)
LOG ON  
( NAME = Sales_log,  
    FILENAME = 'T:\salelog.ldf',  
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB );
GO
USE Sales
--1. Tạo các kiểu dữ liệu người dùng sau:
EXEC sp_addtype 'Mota', 'NVARCHAR(40)'
EXEC sp_addtype 'IDKH', 'CHAR(10)', 'NOT NULL'
EXEC sp_addtype 'DT', 'CHAR(12)'
GO
--2. Tạo các bảng theo cấu trúc sau:
CREATE TABLE SanPham(
	Masp CHAR(6) NOT NULL,
	TenSp VARCHAR(20),
	NgayNhap DATE,
	DVT char(10),
	SoLuongTon INT,
	DonGiaNhap money
)

CREATE TABLE HoaDon(
	MaHD char(10) NOT NULL,
	NgayLap DATE,
	NgayGiao DATE,
	Makh IDKH,
	DienGiai Mota
)

CREATE TABLE KhachHang(
	MaKH IDKH,
	TenKH NVARCHAR(30),
	DiaChi NVARCHAR(40),
	DienThoai DT
)

CREATE TABLE ChiTietHD(
	MaHD CHAR(10) NOT NULL,
	Masp CHAR(6) NOT NULL,
	Soluong INT
)
GO
--3. Trong Table HoaDon, sửa cột DienGiai thành nvarchar(100)
ALTER TABLE HoaDon
ALTER COLUMN DienGiai NVARCHAR(100)
GO
--4. Thêm vào bảng SanPham cột TyLeHoaHong float
ALTER TABLE SanPham
ADD TyLeHoaHong FLOAT;
GO
--5. Xóa cột NgayNhap trong bảng SanPham
ALTER TABLE SanPham
DROP COLUMN NgayNhap
GO
--6. Tạo các ràng buộc khóa chính và khóa ngoại cho các bảng trên
--khóa chính
ALTER TABLE SanPham 
ADD CONSTRAINT PK_SanPham PRIMARY KEY (MaSp)

ALTER TABLE HoaDon
ADD CONSTRAINT PK_HoaDon PRIMARY KEY (MaHD)

ALTER TABLE KhachHang
ADD CONSTRAINT PK_KhachHang PRIMARY KEY (MAKH)

ALTER TABLE ChiTietHD
ADD CONSTRAINT PK_ChiTietHD PRIMARY KEY (MaHD, Masp)

--khóa phụ
ALTER TABLE HoaDon ADD CONSTRAINT FK_HoaDon FOREIGN KEY (Makh) REFERENCES KhachHang(MaKH)
ALTER TABLE ChiTietHD ADD CONSTRAINT FK_ChiTietHD_MaHD FOREIGN KEY (MaHD) REFERENCES HoaDon(MaHD)
ALTER TABLE ChiTietHD ADD CONSTRAINT FK_ChiTietHD_MaSP FOREIGN KEY (Masp) REFERENCES SanPham(Masp)
GO
--7. Thêm vào bảng HoaDon các ràng buộc sau:
-- NgayGiao >= NgayLap
ALTER TABLE HoaDon ADD CHECK (NgayGiao >= NgayLap)
-- MaHD gồm 6 ký tự, 2 ký tự đầu là chữ, các ký tự còn lại là số
ALTER TABLE HoaDon ADD CHECK (MaHD like '[A-Z][A-Z][0-9][0-9][0-9][0-9]')
-- Giá trị mặc định ban đầu cho cột NgayLap luôn luôn là ngày hiện hành
ALTER TABLE HoaDon ADD DEFAULT GETDATE() FOR NgayLap
GO
--8. Thêm vào bảng Sản phẩm các ràng buộc sau:
-- SoLuongTon chỉ nhập từ 0 đến 500
ALTER TABLE SanPham ADD CHECK (SoLuongTon BETWEEN 0 AND 500)
-- DonGiaNhap lớn hơn 0
ALTER TABLE SanPham ADD CHECK (DonGiaNhap > 0)
-- Giá trị mặc định cho NgayNhap là ngày hiện hành
ALTER TABLE SanPham ADD DEFAULT GETDATE() for NgayNhap
-- DVT chỉ nhập vào các giá trị ‘KG’, ‘Thùng’, ‘Hộp’, ‘Cái’
ALTER TABLE SanPham ADD CHECK(DVT IN (N'KG', N'Thùng', N'Hộp', N'Cái'))
GO
--9. Dùng lệnh T-SQL nhập dữ liệu vào 4 table trên, dữ liệu tùy ý, chú ý các ràng buộc của mỗi Table
INSERT INTO SanPham(Masp, TenSp, DVT, SoLuongTon, DonGiaNhap, TyLeHoaHong)
VALUES ('SP001','Gao', 'KG', 100, 23600, 1)

INSERT INTO KhachHang(MaKH, TenKH, DiaChi, DienThoai)
VALUES ('KH001', N'Nguyễn Văn A', N'Phường 4, Gò Vấp, Tp.HCM', 0915805385)

INSERT INTO HoaDon(MaHD, NgayLap, NgayGiao,Makh,DienGiai)
VALUES ('HD0001', '2022-04-12', '2022-04-12', 'KH001', 'Giao Nhanh')

INSERT INTO ChiTietHD(MaHD, Masp, Soluong)
VALUES ('HD0001','SP001',10)
GO
--10. Xóa 1 hóa đơn bất kỳ trong bảng HoaDon. Có xóa được không? Tại sao? Nếu vẫn muốn xóa thì phải dùng cách nào?
--Không. Vì hóa đơn có tồn tại khóa ngoài trên bảng ChiTietHD. Xóa hóa đơn đấy trên bảng ChiTietHD trước rồi đến bảng HoaDon

--11. Nhập 2 bản ghi mới vào bảng ChiTietHD với MaHD = ‘HD999999999’ và MaHD=’1234567890’. Có nhập được không? Tại sao?
--Không nhập 2 bản ghi mới vào được. vì MaHD không phù hợp với ràng buộc dữ liệu

--12. Đổi tên CSDL Sales thành BanHang
EXEC sp_renamedb 'Sales', 'BanHang'

--13. Tạo thư mục T:\QLBH, chép CSDL BanHang vào thư mục này, bạn có sao chép được không? Tại sao? Muốn sao chép được bạn phải làm gì? Sau khi sao chép, bạn thực hiện Attach CSDL vào lại SQL.
-- Không sao chép được. muốn sao chép có thể offline database, và dùng lệnh di chuyển 2 file .mdf và .log hoặc có thể detach file rồi chép

--14. Tạo bản BackUp cho CSDL BanHang
BACKUP DATABASE BanHang TO DISK = 'C:\Backup\BanHang.bak'

--15. Xóa CSDL BanHang
USE master
DROP DATABASE BanHang

--16. Phục hồi lại CSDL BanHang.
RESTORE DATABASE BanHang FROM DISK = 'C:\Backup\BanHang.bak'
