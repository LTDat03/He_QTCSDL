use AdventureWorks2008R2
go
--I) Batch 
--Function
-- 1) Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của sản phẩm 
--có ProductID=’778’; nếu @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có 
--trên 500 đơn hàng”, ngược lại thì in ra chuỗi “Sản phẩm 778 có ít đơn đặt 
--hàng” 
DECLARE @tongsoHD INT
SELECT @tongsoHD = COUNT(SalesOrderID) FROM Sales.SalesOrderDetail
WHERE ProductID = 778
IF(@tongsoHD > 500)
	PRINT CONCAT('Sản phẩm 778 có trên  500  đơn  hàng ', @tongsoHD)
ELSE
	PRINT CONCAT('Sản  phẩm  778  có  ít  đơn  đặt hàng ', @tongsoHD)
--2) Viết một đoạn Batch với tham số @makh và @n chứa số hóa đơn của khách 
--hàng @makh, tham số @nam chứa năm lập hóa đơn (ví dụ @nam=2008),   nếu 
--@n>0 thì in ra chuỗi: “Khách hàng @makh có @n hóa đơn trong năm 2008” 
--ngược lại nếu @n=0 thì in ra chuỗi “Khách hàng @makh không có hóa đơn nào 
--trong năm 2008” 
DECLARE @makh INT, @n INT, @nam INT
SET @makh = 1
SET @nam = 2008
SELECT @n = COUNT(SalesOrderID)
FROM Sales.SalesOrderHeader
WHERE CustomerID = @makh AND YEAR(OrderDate) = @nam
IF(@n > 0)
	PRINT CONCAT('Khách hàng ', @makh, ' có ', @n, ' hóa đơn trong năm ', @nam)
ELSE
	PRINT CONCAT('Khách hàng ', @makh,' không có hóa đơn nào năm ', @nam)
--3) Viết một batch tính số tiền giảm cho những hóa đơn (SalesOrderID) có tổng 
--tiền>100000, thông tin gồm [SalesOrderID], SubTotal=SUM([LineTotal]), 
--Discount (tiền giảm), với Discount được tính như sau: 
-- Những hóa đơn có SubTotal<100000 thì không giảm, 
-- SubTotal từ 100000 đến <120000 thì giảm 5% của SubTotal 
-- SubTotal từ 120000 đến <150000 thì giảm 10% của SubTotal 
-- SubTotal từ 150000 trở lên thì giảm 15% của SubTotal - 16- 
--Bài tập Thực hành  Hệ Quản Trị Cơ sở Dữ Liệu 
--(Gợi ý: Dùng cấu trúc Case… When …Then …) 
DECLARE @subTotal INT
SELECT  SalesOrderID, Subtotal = SUM(LineTotal), discount =
CASE
	WHEN SUM(LineTotal) < 100000 THEN 0
	WHEN SUM(LineTotal) < 120000 THEN 0.05*SUM(LineTotal)
	WHEN SUM(LineTotal) < 150000 THEN 0.1*SUM(LineTotal)
	ELSE 0.15*SUM(LineTotal)
END
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID, LineTotal
--4) Viết một Batch với 3 tham số: @mancc, @masp, @soluongcc, chứa giá trị của 
--các field [ProductID],[BusinessEntityID],[OnOrderQty], với giá trị truyền cho 
--các biến @mancc, @masp (vd: @mancc=1650, @masp=4), thì chương trình sẽ 
--gán  giá  trị  tương  ứng  của  field  [OnOrderQty]  cho  biến  @soluongcc,  nếu 
--@soluongcc trả về giá trị là null thì in ra chuỗi “Nhà cung cấp 1650 không cung 
--cấp sản phẩm 4”, ngược lại (vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650 
--cung cấp sản phẩm 4 với số lượng là 5” 
--(Gợi ý: Dữ liệu lấy từ [Purchasing].[ProductVendor]) 
DECLARE @mancc INT, @masp INT, @soluongcc INT
SET @mancc=1650
SET @masp=4	
SELECT @soluongcc = OnOrderQty FROM Purchasing.ProductVendor
WHERE ProductID = @masp AND BusinessEntityID = @mancc
IF(@soluongcc IS NULL)
	PRINT CONCAT('Nhà cung cấp', @mancc,' không cung cấp sản phẩm',@masp)
ELSE
	PRINT CONCAT('Nhà cung cấp', @mancc,'cung cấp sản phẩm',@masp,' với số lượng là ',@soluongcc)
--5) Viết một batch thực hiện tăng lương giờ (Rate) của nhân viên trong 
--[HumanResources].[EmployeePayHistory] theo điều kiện sau: Khi tổng lương 
--giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%, 
--nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì dừng. 
HILE (SELECT SUM(rate) FROM [HumanResources].[EmployeePayHistory])<6000 
BEGIN
	UPDATE [HumanResources].[EmployeePayHistory] 
	SET rate = rate*1.1
	IF (SELECT MAX(rate)FROM [HumanResources].[EmployeePayHistory]) > 150 
	BREAK
	ELSE
	CONTINUE
END