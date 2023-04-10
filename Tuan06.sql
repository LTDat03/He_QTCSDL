USE AdventureWorks2008R2
GO
--Table Valued Functions:
--4) Viết hàm SumOfOrder với hai tham số @thang và @nam trả về danh sách các 
--hóa đơn (SalesOrderID) lập trong tháng và năm được truyền vào từ 2 tham số
--@thang và @nam, có tổng tiền >70000, thông tin gồm SalesOrderID, OrderDate,
--SubTotal, trong đó SubTotal =sum(OrderQty*UnitPrice).
GO
CREATE FUNCTION SumOfOrder (@thang INT, @nam INT)
RETURNS TABLE
AS
	RETURN(
		SELECT SOH.SalesOrderID, OrderDate, SubTotal = sum(OrderQty*UnitPrice) 
		FROM Sales.SalesOrderHeader SOH JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
		WHERE YEAR(OrderDate) = @nam AND MONTH(OrderDate) = @thang
		GROUP BY SOH.SalesOrderID, OrderDate
		HAVING sum(OrderQty*UnitPrice) > 70000
	)
GO
DECLARE @thang INT, @nam INT
SET @thang = 10
SET @nam = 2007
SELECT * FROM dbo.SumOfOrder(@thang, @nam)
DROP FUNCTION SumOfOrder
--5) Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng 
--(SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng 
--mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm 
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
-- SumOfSubTotal =sum(SubTotal),
-- NewBonus = Bonus+ sum(SubTotal)*0.01
GO
CREATE FUNCTION NewBonus()
RETURNS TABLE
AS
	RETURN(
		SELECT SalesPersonID, NewBonus = Bonus + sum(SubTotal)*0.01, SumOfSubTotal = sum(SubTotal) 
		FROM Sales.SalesOrderHeader SOH JOIN Sales.SalesPerson SP ON SOH.SalesPersonID = SP.BusinessEntityID
		GROUP BY SalesPersonID,Bonus
	)
GO
SELECT * FROM NewBonus()
WHERE SalesPersonID = 284
GO
DROP FUNCTION NewBonus
GO
--6) Viết hàm tên SumOfProduct với tham số đầu vào là @MaNCC (VendorID),
--hàm dùng để tính tổng số lượng (SumOfQty) và tổng trị giá (SumOfSubTotal)
--của các sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm 
--ProductID, SumOfProduct, SumOfSubTotal
--(sử dụng các bảng [Purchasing].[Vendor] [Purchasing].[PurchaseOrderHeader] 
--và [Purchasing].[PurchaseOrderDetail])
CREATE FUNCTION SumOfProduct(@MaNCC INT)
RETURNS TABLE
AS
	RETURN (
		SELECT ProductID, SumOfProduct = SUM(OrderQty), SumOfSubTotal = SUM(SubTotal)
		FROM Purchasing.Vendor V JOIN Purchasing.PurchaseOrderHeader POH ON V.BusinessEntityID = POH.VendorID
		JOIN Purchasing.PurchaseOrderDetail POD ON POD.PurchaseOrderID = POH.PurchaseOrderID
		WHERE VendorID = @MaNCC
		GROUP BY ProductID
	)
GO
SELECT * FROM SumOfProduct(1658)
DROP FUNCTION SumOfProduct
--7) Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn(SalesOrderID), 
--thông tin gồm SalesOrderID, [SubTotal], Discount; trong đó Discount được tính 
--như sau:
--Nếu [SubTotal]<1000 thì Discount=0 
--Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal]
--Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal] 
--Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal]
GO
CREATE FUNCTION Discount_Func()
RETURNS TABLE
AS
	RETURN (
		SELECT SalesOrderID, SubTotal, Discount = 
		CASE
			WHEN SubTotal<1000 THEN 0
			WHEN SubTotal>=1000 AND SubTotal<5000 THEN SubTotal*0.05 
			WHEN SubTotal>=5000 AND SubTotal<10000 THEN SubTotal*0.1 
			ELSE SubTotal*0.15
		END
		FROM Sales.SalesOrderHeader
		GROUP BY SalesOrderID, SubTotal
	)
GO
SELECT * FROM Discount_Func()
GO
DROP FUNCTION Discount_Func
--8) Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng 
--doanh thu của các nhân viên bán hàng (SalePerson) trong tháng và năm được 
--truyền vào 2 tham số, thông tin gồm [SalesPersonID], Total, với 
--Total=Sum([SubTotal])
-- Multi-statement Table Valued Functions:
GO
CREATE FUNCTION TotalOfEmp (@MonthOrder INT, @YearOrder INT)
RETURNS TABLE
AS
	RETURN(
		SELECT SalesPersonID, TotalDue=SUM(SubTotal) FROM Sales.SalesOrderHeader
		WHERE YEAR(OrderDate) = @YearOrder AND MONTH(OrderDate) = @MonthOrder
		GROUP BY SalesPersonID
	)
GO
SELECT * FROM TotalOfEmp(1,2007)
DROP FUNCTION TotalOfEmp
--9) Viết lại các câu 5,6,7,8 bằng Multi-statement table valued function
--Câu 5
GO
CREATE FUNCTION NewBonus()
RETURNS @newBonus TABLE(SalesPersonID INT, NewBonus MONEY, SumOfSubTotal MONEY)
AS
BEGIN
	INSERT @newBonus
	SELECT SalesPersonID, NewBonus = Bonus + sum(SubTotal)*0.01, SumOfSubTotal = sum(SubTotal) 
	FROM Sales.SalesOrderHeader SOH JOIN Sales.SalesPerson SP ON SOH.SalesPersonID = SP.BusinessEntityID
	GROUP BY SalesPersonID,Bonus
	RETURN
END
GO
SELECT * FROM NewBonus()
WHERE SalesPersonID = 284
DROP FUNCTION NewBonus
--Câu 6
GO
CREATE FUNCTION SumOfProduct(@MaNCC INT)
RETURNS @sumOfProduct TABLE(ProductID INT, SumOfProduct MONEY, SumOfSubTotal MONEY)
AS
BEGIN
	INSERT @sumOfProduct
	SELECT ProductID, SumOfProduct = SUM(OrderQty), SumOfSubTotal = SUM(SubTotal)
	FROM Purchasing.Vendor V JOIN Purchasing.PurchaseOrderHeader POH ON V.BusinessEntityID = POH.VendorID
	JOIN Purchasing.PurchaseOrderDetail POD ON POD.PurchaseOrderID = POH.PurchaseOrderID
	WHERE VendorID = @MaNCC
	GROUP BY ProductID
	RETURN
END
GO
SELECT * FROM SumOfProduct(1658)
DROP FUNCTION SumOfProduct
--Câu 7
GO
CREATE FUNCTION Discount_Func()
RETURNS @discount TABLE (SalesOrderID INT, SubTotal MONEY, Discount MONEY)
AS
BEGIN
	INSERT @discount
	SELECT SalesOrderID, SubTotal, Discount = 
	CASE
		WHEN SubTotal<1000 THEN 0
		WHEN SubTotal>=1000 AND SubTotal<5000 THEN SubTotal*0.05 
		WHEN SubTotal>=5000 AND SubTotal<10000 THEN SubTotal*0.1 
		ELSE SubTotal*0.15
	END
	FROM Sales.SalesOrderHeader
	GROUP BY SalesOrderID, SubTotal
	RETURN
END
GO
SELECT * FROM Discount_Func()
GO
DROP FUNCTION Discount_Func
--Câu 8
GO
CREATE FUNCTION TotalOfEmp (@MonthOrder INT, @YearOrder INT)
RETURNS @total TABLE (SalesPersonID INT, TotalDue MONEY)
AS
BEGIN
	INSERT @total
	SELECT SalesPersonID, TotalDue=SUM(SubTotal)
	FROM Sales.SalesOrderHeader
	WHERE YEAR(OrderDate) = @YearOrder AND MONTH(OrderDate) = @MonthOrder
	GROUP BY SalesPersonID
	RETURN
END
GO
SELECT * FROM TotalOfEmp(1,2007)
DROP FUNCTION TotalOfEmp
--10)Viết hàm tên SalaryOfEmp trả về kết quả là bảng lương của nhân viên, với tham 
--số vào là @MaNV (giá trị của [BusinessEntityID]), thông tin gồm 
--BusinessEntityID, FName, LName, Salary (giá trị của cột Rate).
GO
CREATE FUNCTION SalaryOfEmp (@MaNV INT)
RETURNS @salaryOfEmp Table (BusinessEntityID INT, FName NVARCHAR(50), LName NVARCHAR(50), Salary MONEY)
AS
BEGIN
	INSERT @salaryOfEmp
	SELECT EPH.BusinessEntityID, FirstName, LastName, Rate
	FROM HumanResources.EmployeePayHistory EPH JOIN Person.Person P ON EPH.BusinessEntityID = P.BusinessEntityID
	WHERE EPH.BusinessEntityID = @MaNV
	RETURN
END
GO
SELECT * FROM SalaryOfEmp(282)
DROP FUNCTION SalaryOfEmp