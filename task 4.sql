use task2;
CREATE TABLE Customer (Customer_ID INT PRIMARY KEY, Customer_Name VARCHAR(100) NOT NULL);
CREATE TABLE Products (Product_ID INT PRIMARY KEY,Product_Name VARCHAR(100) NOT NULL,Product_Price DECIMAL(10,2) NOT NULL,CHECK (Product_Price >= 0));
CREATE TABLE Inventorys (Inventory_ID INT PRIMARY KEY,Product_ID INT NOT NULL UNIQUE,Stock_Quantity INT NOT NULL,FOREIGN KEY (Product_ID)
REFERENCES Products(Product_ID),CHECK (Stock_Quantity >= 0));
CREATE TABLE Orders (Order_ID INT PRIMARY KEY,Customer_ID INT NOT NULL,Order_Date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
Total_Amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,Order_Status VARCHAR(20) NOT NULL DEFAULT 'Pending',
FOREIGN KEY (Customer_ID)REFERENCES Customer(Customer_ID),CHECK (Total_Amount >= 0),CHECK (Order_Status IN
('Pending', 'Shipped', 'Delivered', 'Cancelled')));
CREATE TABLE Order_Details (Order_Detail_ID INT PRIMARY KEY,Order_ID INT NOT NULL,Product_ID INT NOT NULL,Quantity INT NOT NULL,Price DECIMAL(10,2) NOT NULL,
FOREIGN KEY (Order_ID)REFERENCES Orders(Order_ID)ON DELETE CASCADE,FOREIGN KEY (Product_ID)REFERENCES Products(Product_ID),CHECK (Quantity > 0),
CHECK (Price >= 0),UNIQUE (Order_ID, Product_ID));
INSERT INTO Customer (Customer_ID, Customer_Name)
VALUES(101, 'Rahul'),(102, 'Priya'),(103, 'Amit'),(104, 'Sneha');
INSERT INTO Products(Product_ID, Product_Name, Product_Price)VALUES(201, 'Laptop', 50000.00),(202, 'Mouse', 500.00),(203, 'Mobile Phone', 20000.00),
(204, 'Keyboard', 1500.00);
INSERT INTO Inventorys(Inventory_ID, Product_ID, Stock_Quantity)VALUES(1, 201, 10),(2, 202, 50),(3, 203, 20),(4, 204, 30);
INSERT INTO Orders(Order_ID, Customer_ID, Order_Date,Total_Amount, Order_Status)VALUES(5001, 101, CURRENT_TIMESTAMP, 0.00, 'Pending');
INSERT INTO Order_Details(Order_Detail_ID, Order_ID, Product_ID, Quantity, Price)VALUES(1, 5001, 201, 1, 50000.00),(2, 5001, 202, 2, 500.00);
UPDATE Orders
SET Total_Amount = (SELECT COALESCE(SUM(Quantity * Price), 0)FROM Order_Details WHERE Order_ID = 5001)WHERE Order_ID = 5001;
INSERT INTO Orders(Order_ID, Customer_ID, Total_Amount, Order_Status)VALUES(5002, 102, 0.00, 'Pending');
INSERT INTO Order_Details(Order_Detail_ID, Order_ID, Product_ID, Quantity, Price)VALUES(3, 5002, 203, 1, 20000.00);
UPDATE Orders SET Total_Amount = (SELECT COALESCE(SUM(Quantity * Price), 0)FROM Order_Details WHERE Order_ID = 5002)WHERE Order_ID = 5002;
INSERT INTO Orders(Order_ID, Customer_ID, Total_Amount, Order_Status)VALUES(5003, 103, 0.00, 'Pending');
INSERT INTO Order_Details(Order_Detail_ID, Order_ID, Product_ID, Quantity, Price)VALUES(4, 5003, 204, 2, 1500.00),(5, 5003, 202, 1, 500.00);
UPDATE Orders SET Total_Amount = (SELECT COALESCE(SUM(Quantity * Price), 0)FROM Order_Details WHERE Order_ID = 5003)WHERE Order_ID = 5003;
UPDATE Orders SET Order_Status = 'Delivered' WHERE Order_ID = 5001;
UPDATE Order_Details SET Quantity = 3 WHERE Order_ID = 5001 AND Product_ID = 202; 
UPDATE Orders SET Total_Amount = (SELECT COALESCE(SUM(Quantity * Price), 0)FROM Order_Details WHERE Order_ID = 5001)WHERE Order_ID = 5001;
UPDATE Orders SET Order_Status = 'Cancelled' WHERE Order_ID = 5003;
DELETE FROM Orders WHERE Order_ID = 5003 AND Order_Status = 'Cancelled';
SELECT *FROM Customer;
SELECT *FROM Product;
SELECT *FROM Orders;
SELECT *FROM Order_Details;
SELECT c.Customer_Name,o.Order_ID,o.Order_Date,o.Total_Amount,o.Order_Status FROM Customer AS c JOIN Orders AS o
ON c.Customer_ID = o.Customer_ID ORDER BY o.Order_Date DESC;
SELECT p.Product_ID,p.Product_Name,COUNT(DISTINCT o.Order_ID) AS Times_Ordered,COALESCE(SUM(od.Quantity), 0) AS Total_Quantity_Sold
FROM Product AS p LEFT JOIN Order_Details AS od ON p.Product_ID = od.Product_ID LEFT JOIN Orders AS o ON od.Order_ID = o.Order_ID 
AND o.Order_Status <> 'Cancelled'
GROUP BY
    p.Product_ID,
    p.Product_Name
ORDER BY Total_Quantity_Sold DESC;
WITH CustomerOrderCounts AS (SELECT c.Customer_ID,c.Customer_Name,
COUNT(o.Order_ID) AS Total_Orders FROM Customer AS c LEFT JOIN Orders AS o ON c.Customer_ID = o.Customer_ID AND o.Order_Status <> 'Cancelled'GROUP BY c.Customer_ID,c.Customer_Name)
SELECT *FROM CustomerOrderCounts WHERE Total_Orders = (SELECT MAX(Total_Orders)FROM CustomerOrderCounts);
SELECT c.Customer_ID, c.Customer_Name,COALESCE(SUM(o.Total_Amount), 0) AS Total_Spending FROM Customer AS c LEFT JOIN Orders AS o
ON c.Customer_ID = o.Customer_ID AND o.Order_Status <> 'Cancelled' GROUP BY c.Customer_ID, c.Customer_Name ORDER BY Total_Spending DESC;
SELECT
    c.Customer_ID,
    c.Customer_Name,
    COUNT(o.Order_ID) AS Total_Orders,
    COALESCE(SUM(o.Total_Amount), 0) AS Total_Spending,
    ROUND(AVG(o.Total_Amount), 2) AS Average_Order_Value
FROM Customer AS c
LEFT JOIN Orders AS o
    ON c.Customer_ID = o.Customer_ID
    AND o.Order_Status <> 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Average_Order_Value DESC;
SELECT COALESCE(SUM(Total_Amount), 0) AS Total_Sales FROM Orders WHERE Order_Status <> 'Cancelled';
SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Order_Status,
    p.Product_Name,
    od.Quantity,
    od.Price AS Unit_Price,
    od.Quantity * od.Price AS Subtotal,
    o.Total_Amount
FROM Customer AS c
JOIN Orders AS o
    ON c.Customer_ID = o.Customer_ID
JOIN Order_Details AS od
    ON o.Order_ID = od.Order_ID
JOIN Product AS p
    ON od.Product_ID = p.Product_ID
ORDER BY
    o.Order_ID,
    od.Order_Detail_ID;
SELECT
    p.Product_ID,
    p.Product_Name,
    i.Stock_Quantity
FROM Product AS p
JOIN Inventory AS i
    ON p.Product_ID = i.Product_ID
    ORDER BY p.Product_ID;





