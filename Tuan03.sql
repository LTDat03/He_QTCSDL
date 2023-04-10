use AdventureWorks2008R2
go
--1) Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng 
--Production.Product và bảng Production.ProductCostHistory. Thông tin bao gồm 
--ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate 
create view dbo.vw_Products AS
Select P.ProductID,Name,Color,Size,Style,P.StandardCost,EndDate,StartDate
from Production.Product P join Production.ProductCostHistory PCH on P.ProductID = PCH.ProductID
go
select * from dbo.vw_Products
go
--2) Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt 
--hàng trong quí 1 năm 2008 và có tổng trị giá >10000, thông tin gồm ProductID, 
--Product_Name, CountOfOrderID và SubTotal. 
create view List_Product_View AS
select P.ProductID,P.Name,CountOfOrderID = COUNT(*),SubTotal = Sum(OrderQty*UnitPrice) 
from Production.Product P join Sales.SalesOrderDetail SOD on P.ProductID = SOD.ProductID
	join Sales.SalesOrderHeader SOH on SOD.SalesOrderID = SOH.SalesOrderID
where MONTH(OrderDate) = 1 and YEAR(OrderDate) = 2008
group by P.ProductID,P.Name
having count(*) > 500 and sum(OrderQty*UnitPrice) > 10000
go

select * from List_Product_View

go
--3) Tạo view dbo.vw_CustomerTotals hiển thị tổng tiền bán được (total sales) từ cột 
--TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm 
--CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS 
--OrderMonth, SUM(TotalDue). 
create view dbo.vw_CustomerTotals as
select CustomerID,YEAR(OrderDate) as OrderYear,MONTH(OrderDate) as OrderMonth,SUM(TotalDue) as TotalSales
from Sales.SalesOrderHeader
group by CustomerID,YEAR(OrderDate),MONTH(OrderDate)
go
select * from dbo.vw_CustomerTotals
go
--4) Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân 
--viên theo từng năm. Thông tin gồm SalesPersonID, OrderYear, sumOfOrderQty 
create view dbo.TotalsQuantityYear as
select SalesPersonID,YEAR(OrderDate) as OrderYear,SUM(OrderQty) as sumOfOrderQty
from Sales.SalesOrderHeader SOH join Sales.SalesOrderDetail SOD on SOH.SalesOrderID = SOD.SalesOrderID
group by SalesPersonID,YEAR(OrderDate)
go
select * from dbo.TotalsQuantityYear 
go
--5) Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn 
--đặt hàng từ năm 2007 đến 2008, thông tin gồm mã khách (PersonID) , họ tên 
--(FirstName +'  '+ LastName as FullName), Số hóa đơn (CountOfOrders). 
create view ListCustomer_view as
select SalesPersonID,FirstName + ' ' + LastName as FullName, COUNT(*) as CountOfOrders
from Person.Person P join Sales.SalesOrderHeader SOH on BusinessEntityID = SOH.CustomerID
where YEAR(OrderDate) between 2007 and 2008
group by SalesPersonID,FirstName + ' ' + LastName
having COUNT(*) > 25
go
select * from ListCustomer_view 
go
--6) Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với 
--‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên 50 sản phẩm, thông 
--tin gồm ProductID, Name, SumOfOrderQty, Year. (dữ liệu lấy từ các bảng
-- Sales.SalesOrderHeader,        Sales.SalesOrderDetail,  và      Production.Product)  
create view ListProduct_view as
select P.ProductID,Name,SUM(OrderQty) as SumOfOrderQty,YEAR(OrderDate) as Year
from Sales.SalesOrderHeader SOH join Sales.SalesOrderDetail SOD on SOH.SalesOrderID = SOD.SalesOrderID 
	join Production.Product P on P.ProductID = SOD.ProductID
where Name like 'Bike%' or Name like 'Sport%'
group by P.ProductID,Name,YEAR(OrderDate)
having SUM(OrderQty) > 50
go
select * from List_Product_View
go
--7) Tạo view List_department_View chứa danh sách các phòng ban có lương (Rate: 
--lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID), 
--tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng 
--[HumanResources].[Department],[HumanResources].[EmployeeDepartmentHistory], 
--[HumanResources].[EmployeePayHistory]. 
create view List_department_View as
select D.DepartmentID, Name, AvgOfRate = AVG(Rate)
from HumanResources.Department D join HumanResources.EmployeeDepartmentHistory EDH on D.DepartmentID = EDH.DepartmentID
	join HumanResources.EmployeePayHistory EPH on EDH.BusinessEntityID = EPH.BusinessEntityID
group by D.DepartmentID, Name
having AVG(Rate) > 30
go
select * from List_department_View
go
--8) Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm 
--OrderYear (năm của ngày lập), OrderMonth (tháng của ngày lập), OrderTotal 
--(tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view này 
create view Sales.vw_OrderSummary with encryption as 
select Year(OrderDate) as OrderYear, MONTH(OrderDate) as OrderMonth, OrderTotal = SUM(TotalDue*UnitPrice)
from Sales.SalesOrderHeader SOH join Sales.SalesOrderDetail SOD on SOH.SalesOrderID = SOD.SalesOrderID 
group by Year(OrderDate), MONTH(OrderDate)
go
select * from Sales.vw_OrderSummary
go
--9) Tạo view Production.vwProducts với từ khóa WITH SCHEMABINDING 
--gồm ProductID, Name, StartDate,EndDate,ListPrice của bảng Product và bảng 
--ProductCostHistory. Xem thông tin của View. Xóa cột ListPrice của bảng 
--Product. Có xóa được không? Vì sao? 
create view Production.vwProducts WITH SCHEMABINDING as
select P.ProductID,Name,StartDate,EndDate,ListPrice
from Production.Product P JOIN Production.ProductCostHistory PCH ON P.ProductID = PCH.ProductID
go
select * from Production.vwProducts
go
ALTER TABLE Production.Product
DROP COLUMN ListPrice
--Không xóa được
go
--10) Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các 
--phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality 
--Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
create view view_Department as 
select DepartmentID,Name,GroupName 
from HumanResources.Department
where GroupName = 'Manufacturing' or GroupName = 'Quality Assurance'
WITH CHECK OPTION
go
--a. Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm 
--“Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có 
--chèn được không? Giải thích.
INSERT view_Department VALUES('phong ban', 'a')
go
--DO Group Name không phù hợp với ràng buộc
--b. Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một 
--phòng thuộc nhóm “Quality Assurance”. 
INSERT view_Department VALUES( 'Phong ban', 'Manufacturing')
go
--c. Dùng câu lệnh Select xem kết quả trong bảng Department. 
select * from view_Department