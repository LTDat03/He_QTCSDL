--1.Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng 6 năm 2008 có tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate, SubTotal, trong đó SubTotal =SUM(OrderQty*UnitPrice)
select A.SalesOrderID, OrderDate,SubTotal = SUM(OrderQty*UnitPrice) 
from Sales.SalesOrderDetail A inner join Sales.SalesOrderHeader B on A.SalesOrderID = B.SalesOrderID
where MONTH(OrderDate) = 6 and YEAR(OrderDate) = 2008
group by A.SalesOrderID, OrderDate
having SUM(OrderQty*UnitPrice)  > 70000

--2.Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia có mã vùng là US (lấy thông tin từ các bảng Sales.SalesTerritory, Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail). Thông tin bao gồm TerritoryID, tổng số khách hàng (CountOfCust), tổng tiền (SubTotal) với SubTotal = SUM(OrderQty*UnitPrice)
select B.TerritoryID, CountOfCust = COUNT(distinct A.CustomerID),SubTotal = SUM(TotalDue)
from Sales.Customer A join Sales.SalesTerritory B on A.TerritoryID = B.TerritoryID 
	join Sales.SalesOrderHeader C on A.CustomerID = C.CustomerID 
	--join Sales.SalesOrderDetail D on C.SalesOrderID = D.SalesOrderID
where CountryRegionCode ='US'
group by B.TerritoryID	

--3.Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng(CarrierTrackingNumber) có 3 ký tự đầu là 4BD, thông tin bao gồm SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice)
select SalesOrderID, CarrierTrackingNumber, SubTotal = SUM(OrderQty *UnitPrice)
from Sales.SalesOrderDetail 
where CarrierTrackingNumber like '4BD%'
group by SalesOrderID, CarrierTrackingNumber

--4.Liệt kê các sản phẩm (Product) có đơn giá (UnitPrice)<25 và số lượng bán trung bình >5, thông tin gồm ProductID, Name, AverageOfQty.
select A.ProductID, Name,UnitPrice,AverageofQty = AVG(OrderQty)
from Production.Product A join Sales.SalesOrderDetail B on A.ProductID = B.ProductID
where UnitPrice < 25 
group by A.ProductID, Name,UnitPrice
having AVG(OrderQty) > 5

--5.Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm JobTitle,CountOfPerson=Count(*)
select JobTitle,CountOfPerson = COUNT(*)
from HumanResources.Employee
group by JobTitle
having COUNT(*) > 20

--6.Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên kết thúc bằng ‘Bicycles’ và tổng trị giá > 800000, thông tin gồm BusinessEntityID, Vendor_Name, ProductID, SumOfQty, SubTotal
select BusinessEntityID, Name Product_Name,ProductID,SubTotal = SUM(OrderQty * UnitPrice),SumofQty = SUM(*) 
from Purchasing.Vendor V join Purchasing.PurchaseOrderHeader POH on V.ModifiedDate=POH.ModifiedDate
	join Purchasing.PurchaseOrderDetail POD on POD.PurchaseOrderID = POH.PurchaseOrderID
where Name like '%Bicycles'
group by BusinessEntityID,Name,ProductID,SubTotal
having SUM(OrderQty * UnitPrice) > 800000

select p.ProductID, p.Name, CountOfOrderID = count(soh.SalesOrderID), sum(sod.LineTotal) as SubTotal from [Production].[Product] p inner join Sales.SalesOrderDetail sod on p.ProductID= sod.ProductID
inner join Sales.SalesOrderHeader soh on sod.SalesOrderID = soh.SalesOrderID 
where DATEPART(QQ,soh.OrderDate) = 1 and YEAR(soh.OrderDate) = 2008 
group by p.ProductID,p.Name
having count(soh.SalesOrderID) > 500 and sum(sod.LineTotal) >10000

--8)  Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến 
--2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +'   '+ LastName 
--as FullName), Số hóa đơn  (CountOfOrders).
select p.BusinessEntityID ,p.FirstName +'   '+ p.LastName as FullName , CountOfOrders = count(soh.SalesOrderID)  from [Person].[Person] p inner join 
[Sales].[SalesOrderHeader] soh on p.BusinessEntityID = soh.CustomerID
where year(soh.OrderDate) between 2007  and 2008
group by p.BusinessEntityID,p.FirstName, p.LastName
having count(soh.SalesOrderID) > 25


--9)  Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng 
--bán  trong  mỗi  năm  trên  500  sản  phẩm,  thông  tin  gồm  ProductID,  Name, 
--CountOfOrderQty,  Year.  (Dữ  liệu  lấy  từ  các  bảng  Sales.SalesOrderHeader, 
--Sales.SalesOrderDetail  và Production.Product)

SELECT 
    p.ProductID, 
    p.Name, 
    SUM(d.OrderQty) AS CountOfOrderQty, 
    YEAR(h.OrderDate) AS Year
FROM 
    [Sales].[SalesOrderHeader] AS h
    JOIN [Sales].[SalesOrderDetail] AS d 
        ON h.SalesOrderID = d.SalesOrderID
    JOIN [Production].[Product] AS p 
        ON d.ProductID = p.ProductID
WHERE 
    (p.Name LIKE 'Bike%' OR p.Name LIKE 'Sport%') 
GROUP BY 
    p.ProductID, 
    p.Name, 
    YEAR(h.OrderDate)
HAVING 
    SUM(d.OrderQty) > 500

--10)  Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông 
--tin  gồm  Mã  phòng  ban  (DepartmentID),  tên  phòng  ban  (Name),  Lương  trung
--bình (AvgofRate).  Dữ  liệu  từ  các  bảng
--[HumanResources].[Department], 
--[HumanResources].[EmployeeDepartmentHistory], 
--[HumanResources].[EmployeePayHistory].

select d.DepartmentID,Name,AvgofRate = AVG(Rate) from [HumanResources].[Department] d inner join [HumanResources].[EmployeeDepartmentHistory] edh
on d.DepartmentID = edh.DepartmentID inner join [HumanResources].[EmployeePayHistory] eph on eph.BusinessEntityID = edh.BusinessEntityID
group by d.DepartmentID,Name
having AVG(Rate) > 30


--SubQuery

--1)  Liệt kê các sản phẩm  gồm các thông tin  Product  Names  và  Product ID  có 
--trên 100 đơn đặt hàng trong tháng 7 năm  2008
select  ProductID , Name
from Production.Product
where ProductID in 
		(  select ProductID
			from Sales.SalesOrderDetail sod join Sales.SalesOrderHeader soh 
			on sod.SalesOrderID = soh.SalesOrderID
			where month(OrderDate) = 7 and year(OrderDate) = 2011
			group by ProductID
			having count(*) > 30 )

--2)  Liệt  kê  các  sản  phẩm  (ProductID,  Name)  có  số  hóa  đơn  đặt  hàng  nhiều  nhất
--trong tháng  7/2008
select top 1 p.ProductID, p.Name from  [Production].[Product]  p
where ProductID in
(
select p.ProductID from [Production].[Product] p inner join [Sales].[SalesOrderDetail] sod on sod.ProductID = p.ProductID
inner join [Sales].[SalesOrderHeader] soh on sod.SalesOrderID = soh.SalesOrderID 
where month(soh.OrderDate) = 7 and YEAR(soh.OrderDate) = 2008
)
--3)  Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm: 
--CustomerID, Name,  Co[Production].[Product]untOfOrder
select top 1 c.CustomerID, Name = ps.FirstName +' '+ps.LastName from [Sales].[Customer] c inner join  [Person].[Person] ps on ps.BusinessEntityID = c.CustomerID
where exists
(
select top 1 c.CustomerID, Name from [Sales].[Customer] c inner join [Sales].[SalesTerritory] ss on c.TerritoryID = ss.TerritoryID inner join [Sales].[SalesOrderHeader]
soh on ss.TerritoryID = soh.TerritoryID inner join [Sales].[SalesOrderDetail] sod on soh.SalesOrderID = sod.SalesOrderDetailID
order by sod.OrderQty desc
)
select * from Sales.SalesTerritory

----4) Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với
----tên bắt đầu với “Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS, (sử dụng
----bảng Production.Product và Production.ProductModel)Bài tập Thực hành Hệ Quản Trị Cơ sở Dữ Liệu
SELECT p.ProductID, Name
FROM Production.Product p
WHERE exists
(
    SELECT ProductID, p.Name
    FROM Production.ProductModel pm inner join Production.Product p on pm.ProductModelID = p.ProductModelID 
    WHERE p.Name LIKE 'Long-Sleeve Logo Jersey%'
 )


----5) Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối
----đa cao hơn giá trung bình của tất cả các mô hình.
SELECT DISTINCT ProductModelID
FROM Production.Product
WHERE ListPrice > (SELECT AVG(ListPrice) FROM Production.Product)

----6) Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng
----đặt hàng > 5000 (dùng IN, EXISTS)
SELECT ProductID, Name
FROM Production.Product
WHERE ProductID IN (
  SELECT ProductID
  FROM Sales.SalesOrderDetail
  GROUP BY ProductID
  HAVING SUM(OrderQty) > 5000
)

----7) Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao
----nhất trong bảng Sales.SalesOrderDetail
select p.ProductID, UnitPrice from Production.Product p inner join Sales.SalesOrderDetail sod on p.ProductID = sod.ProductID
where UnitPrice >= all
(
select  UnitPrice from Production.Product p inner join Sales.SalesOrderDetail sod on p.ProductID = sod.ProductID
)
group by p.ProductID, UnitPrice

----8) Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID,
----Nam; dùng 3 cách Not in, Not exists và Left join.
select p.ProductID,Name from Production.Product p 
where not exists
(
select p.ProductID from [Production].[Product] p inner join Sales.SalesOrderDetail sod on p.ProductID = sod.ProductID
inner join Sales.SalesOrderHeader soh on sod.SalesOrderID = soh.SalesOrderID 
)

select p.ProductID,Name from Production.Product p 
where p.ProductID not in
(
select p.ProductID from Production.Product p inner join Sales.SalesOrderDetail sod on p.ProductID = sod.ProductID
inner join Sales.SalesOrderHeader soh on sod.SalesOrderID = soh.SalesOrderID 
)

select P.ProductID,Name from Production.Product p left join Sales.SalesOrderDetail sod on p.ProductID = sod.ProductID

----9) Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008, thông tin gồm
----BusinessEntityID, FirstName, LastName (dữ liệu từ 2 bảng)

----HumanResources.Employees và Sales.SalesOrdersHeader)
----10)Liệt kê danh sách các khách hàng (CustomerID, Name) có hóa đơn dặt hàng
----trong năm 2007 nhưng không có hóa đơn đặt hàng trong năm 2008

SELECT distinct c.CustomerID, Name =  p.FirstName+' '+p.LastName
FROM Sales.Customer c inner join Person.Person p on c.TerritoryID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID 
WHERE YEAR(soh.OrderDate) = 2007 AND c.CustomerID NOT IN 
    (SELECT DISTINCT CustomerID FROM Sales.SalesOrderHeader WHERE YEAR(OrderDate) = 2008)
