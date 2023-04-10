use AdventureWorks2008R2
--II) Stored Procedure: 
--1) Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một 
--tháng bất kỳ của một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím, 
--thông tin gồm: CustomerID, SumOfTotalDue =Sum(TotalDue) 
CREATE PROC TotalDue @customerId INT
AS
BEGIN
	SELECT CustomerID, SumOfTotalDue =Sum(TotalDue) FROM Sales.SalesOrderHeader
	WHERE CustomerID = @customerId
	GROUP BY CustomerID
END
EXEC TotalDue 29825
GO

DROP PROC TotalDue
--2) Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của 
--một nhân viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. Tham số 
--@SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số  
--@SalesYTD được sử dụng để chứa giá trị trả về của thủ tục.   

SELECT * FROM Sales.SalesPerson
GO
CREATE PROC subtotalYTD @SalesPerson INT, @SalesYTD money OUTPUT
AS
BEGIN
	SELECT @SalesYTD = SalesYTD FROM Sales.SalesPerson
	WHERE BusinessEntityID = @SalesPerson
END
GO
DECLARE @SalesYTD money
EXEC subtotalYTD 274,@SalesYTD OUTPUT
SELECT @SalesYTD
GO

DROP PROC subtotalYTD
--3) Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản phẩm có 
--giá bán không vượt quá một giá trị chỉ định (tham số input @MaxPrice).  
SELECT * FROM Production.Product
GO
CREATE PROC listProductByPrice @MaxPrice money
AS
BEGIN
	SELECT * FROM Production.Product
	WHERE ListPrice < @MaxPrice
END
GO
EXEC listProductByPrice 5
GO

DROP PROC listProductByPrice
--4) Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân viên bán 
--hàng (SalesPerson), dựa trên tổng doanh thu của nhân viên đó. Mức thưởng mới 
--bằng mức thưởng hiện tại cộng thêm 1% tổng doanh thu. Thông tin bao gồm  
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:  
--SumOfSubTotal =sum(SubTotal)  
--NewBonus = Bonus+ sum(SubTotal)*0.01  
GO
CREATE PROCEDURE NewBonus @salesPersonId INT
AS
BEGIN
	SELECT SalesPersonID, NewBonus = Bonus+ SUM(SubTotal)*0.01 , SumOfSubTotal = SUM(SubTotal) 
	FROM Sales.SalesPerson SP JOIN Sales.SalesOrderHeader SOH ON SP.BusinessEntityID = SOH.SalesPersonID
	WHERE SalesPersonID = @salesPersonId
	GROUP BY SalesPersonID,Bonus
END

EXEC NewBonus 284
GO

DROP PROC NewBonus
--5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory) 
--có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số 
--input), thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng  
--ProductCategory, ProductSubCategory, Product và SalesOrderDetail. 
--(Lưu ý: dùng Sub Query) 
 SELECT PC.ProductCategoryID, PC.Name, SumOfQty = SUM(OrderQty) FROM Production.ProductCategory PC JOIN Production.ProductSubcategory PS 
ON PC.ProductCategoryID = PS.ProductCategoryID JOIN Production.Product P 
ON P.ProductSubcategoryID = PS.ProductSubcategoryID JOIN Sales.SalesOrderDetail SOD
ON SOD.ProductID = P.ProductID JOIN Sales.SalesOrderHeader SOH
ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE YEAR(OrderDate) = 2008
GROUP BY PC.ProductCategoryID, PC.Name
GO
CREATE PROC productCategoryMaxOrderQty @year int
AS
BEGIN
	SELECT PC.ProductCategoryID, PC.Name, SumOfQty = SUM(OrderQty)
	FROM Production.ProductCategory PC JOIN Production.ProductSubcategory PS 
	ON PC.ProductCategoryID = PS.ProductCategoryID JOIN Production.Product P 
	ON P.ProductSubcategoryID = PS.ProductSubcategoryID JOIN Sales.SalesOrderDetail SOD
	ON SOD.ProductID = P.ProductID JOIN Sales.SalesOrderHeader SOH
	ON SOD.SalesOrderID = SOH.SalesOrderID
	WHERE YEAR(OrderDate) = @year AND PC.ProductCategoryID = (SELECT TOP 1 PC.ProductCategoryID
					FROM Production.ProductCategory PC JOIN Production.ProductSubcategory PS 
					ON PC.ProductCategoryID = PS.ProductCategoryID JOIN Production.Product P 
					ON P.ProductSubcategoryID = PS.ProductSubcategoryID JOIN Sales.SalesOrderDetail SOD
					ON SOD.ProductID = P.ProductID JOIN Sales.SalesOrderHeader SOH
					ON SOD.SalesOrderID = SOH.SalesOrderID
					GROUP BY PC.ProductCategoryID, PC.Name
					ORDER BY SUM(OrderQty) DESC)
	GROUP BY PC.ProductCategoryID, PC.Name
END
EXEC productCategoryMaxOrderQty 2008
GO

DROP PROC productCategoryMaxOrderQty
--6) Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra 
--là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả 
--về trạng thái thành công hay thất bại của thủ tục. 
SELECT * FROM Sales.SalesOrderHeader
GO
CREATE PROC TongThu @salesPeronId INT, @sumSubtotal MONEY OUTPUT
AS
BEGIN
	SELECT @sumSubtotal = SUM(SubTotal) FROM Sales.SalesOrderHeader
	WHERE SalesPersonID = @salesPeronId
	GROUP BY SalesPersonID
	IF @sumSubtotal > 0 return 1
	ELSE RETURN 0
END
GO
DECLARE @sumSubtotal MONEY
EXEC TongThu 279, @sumSubtotal OUTPUT
SELECT @sumSubtotal 
GO

DROP PROC TongThu
--7) Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo 
--năm đã cho.
SELECT StoreID FROM Sales.Store S JOIN Sales.Customer C ON S.BusinessEntityID = C.StoreID
JOIN Sales.SalesOrderHeader SOH ON C.CustomerID = SOH.CustomerID
GO
CREATE PROC mostBuyStore @year INT
AS
BEGIN
	SELECT TOP 1 name, SumOfSubTotal = SUM(SubTotal)
	FROM Purchasing.Vendor V JOIN Purchasing.PurchaseOrderHeader POH ON V.BusinessEntityID = POH.VendorID
	WHERE YEAR(OrderDate) = @year
	GROUP BY Name
	ORDER BY SumOfSubTotal DESC
END
GO
EXEC mostBuyStore 2008
GO

DROP PROC mostBuyStore
--8)  Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu tin 
--vào bảng Production.Product. Yêu cầu: chỉ thêm vào các trường có giá trị not 
--null và các field là khóa  ngoại.
SELECT * FROM Production.Product
GO
sp_help 'Production.product'
GO
CREATE PROC Sp_InsertProduct (@name nvarchar(50), @ProductNumber nvarchar(25), @SafetyStockLevel smallint, @ReorderPoint smallint,
@StandardCost money, @ListPrice money, @DaysToManufacture INT, @SellStartDate datetime)
AS
BEGIN
	INSERT Production.product(Name, ProductNumber,SafetyStockLevel, ReorderPoint,
	StandardCost, ListPrice, DaysToManufacture, SellStartDate)
	VALUES ( @name, @ProductNumber , @SafetyStockLevel, @ReorderPoint, @StandardCost, @ListPrice, @DaysToManufacture, @SellStartDate)
END
GO
EXEC Sp_InsertProduct 'LMT', '21023911', 1000, 750, 0, 0, 0, '2002-06-01'
GO

DROP PROC Sp_InsertProduct
--9) Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng Sales.SalesOrderHeader 
--khi biết SalesOrderID. Lưu ý : trước khi xóa mẫu tin trong 
--Sales.SalesOrderHeader thì phải xóa các mẫu tin của hoá đơn đó trong 
--Sales.SalesOrderDetail
SELECT * FROM Sales.SalesOrderHeader
GO
CREATE PROC XoaHD @SalesOrderID INT
AS
BEGIN
	DELETE Sales.SalesOrderHeader
	WHERE SalesOrderID = @SalesOrderID
END
GO
EXEC XoaHD 43659
GO

DROP PROC XoaHD
--10)Viết thủ tục Sp_Update_Product có tham số ProductId dùng để tăng listprice
--lên 10% nếu sản phẩm này tồn tại, ngược lại hiện thông báo không có sản phẩm
--này.
SELECT * FROM Production.Product
GO
CREATE PROC Sp_Update_Product @productId INT
AS
BEGIN
	IF EXISTS (SELECT * FROM Production.Product WHERE ProductID = @productId)
		UPDATE Production.Product
		SET ListPrice = ListPrice*1.1
		WHERE ProductID = @productId
	ELSE
		PRINT 'không có sản phẩm này'
END
GO
EXEC Sp_Update_Product 707
GO

DROP PROC Sp_Update_Product
--III) Function
-- Scalar Function
--1) Viết hàm tên CountOfEmployees (dạng scalar function) với tham số @mapb, 
--giá trị truyền vào lấy từ field [DepartmentID], hàm trả về số nhân viên trong 
--phòng ban tương ứng. Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các
--phòng ban với số nhân viên của mỗi phòng ban, thông tin gồm: [DepartmentID],
--Name, countOfEmp với countOfEmp= CountOfEmployees([DepartmentID]).
--(Dữ liệu lấy từ bảng 
--[HumanResources].[EmployeeDepartmentHistory] và 
--[HumanResources].[Department])
SELECT COUNT(*) FROM HumanResources.EmployeeDepartmentHistory
WHERE DepartmentID = 7
GO
CREATE FUNCTION CountOfEmployees (@mapb INT)
RETURNS INT
AS
BEGIN
	RETURN (
		SELECT COUNT(*) FROM HumanResources.EmployeeDepartmentHistory
		WHERE DepartmentID = @mapb
	)
END
GO

SELECT D.DepartmentID, D.Name, countOfEmp= dbo.CountOfEmployees(D.DepartmentID) 
FROM HumanResources.EmployeeDepartmentHistory EDH JOIN HumanResources.Department D
ON EDH.DepartmentID = D.DepartmentID
GROUP BY D.DepartmentID, D.Name
GO

DROP FUNCTION CountOfEmployees
--2) Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là
--@ProductID và @LocationID trả về số lượng tồn kho của sản phẩm trong khu 
--vực tương ứng với giá trị của tham số
--(Dữ liệu lấy từ bảng[Production].[ProductInventory])
SELECT Quantity FROM Production.ProductInventory
WHERE ProductID = 400 AND LocationID = 20
GO
CREATE FUNCTION InventoryProd (@ProductID INT,@LocationID INT)
RETURNS INT
AS
BEGIN
	RETURN (
		SELECT Quantity FROM Production.ProductInventory
		WHERE ProductID = @ProductID AND LocationID = @LocationID
	)
END
GO

DECLARE @InventoryProd INT, @ProductID INT, @LocationID INT
SET @ProductID = 400
SET @LocationID = 20
SET @InventoryProd = dbo.InventoryProd(@ProductID, @LocationID)
PRINT CONCAT(N'Số lượng tồn kho của mã sản phẩm ', @ProductID, N', có mã địa chỉ ', @LocationID, N' là: ', @InventoryProd)
GO

DROP FUNCTION InventoryProd
--3) Viết hàm tên SubTotalOfEmp (dạng scalar function) trả về tổng doanh thu của 
--một nhân viên trong một tháng tùy ý trong một năm tùy ý, với tham số vào
--@EmplID, @MonthOrder, @YearOrder
--(Thông tin lấy từ bảng [Sales].[SalesOrderHeader])
SELECT sumOfSubTotal = SUM(SubTotal) FROM Sales.SalesOrderHeader
WHERE SalesPersonID = 285 AND MONTH(OrderDate) = 12 AND YEAR(OrderDate) = 2007
GO
CREATE FUNCTION SubTotalOfEmp (@EmplID INT, @MonthOrder INT, @YearOrder INT)
RETURNS INT
AS
BEGIN
	RETURN (
		SELECT SUM(SubTotal) FROM Sales.SalesOrderHeader
		WHERE SalesPersonID = @EmplID AND MONTH(OrderDate) = @MonthOrder AND YEAR(OrderDate) = @YearOrder
	)
END
GO

DECLARE @EmplID INT, @MonthOrder INT, @YearOrder INT, @SubTotalOfEmp MONEY
SET @EmplID = 285
SET @MonthOrder = 12
SET @YearOrder = 2007
SET @SubTotalOfEmp = dbo.SubTotalOfEmp(@EmplID, @MonthOrder, @YearOrder)

PRINT CONCAT(N'Mã nhân viên: ', @EmplID,N', Tháng: ', @MonthOrder,N', Năm: ', @YearOrder,N', Tổng doanh thu: ', @SubTotalOfEmp)
GO

DROP FUNCTION SubTotalOfEmp
