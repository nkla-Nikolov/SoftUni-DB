CREATE TABLE Clients
(
	ClientId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Phone NVARCHAR(12) CHECK(LEN(Phone) = 12)
)

CREATE TABLE Mechanics
(
	MechanicId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	[Address] VARCHAR(255) NOT NULL
)

CREATE TABLE Models
(
	ModelId INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL UNIQUE
)

CREATE TABLE Jobs
(
	JobId INT PRIMARY KEY IDENTITY,
	ModelId INT NOT NULL REFERENCES Models(ModelId),
	[Status] VARCHAR(11) NOT NULL CHECK([Status] = 'Pending' OR
	[Status] = 'In Progress' OR [Status] = 'Finished')
	DEFAULT 'Pending',
	ClientId INT NOT NULL REFERENCES Clients(ClientId),
	MechanicId INT REFERENCES Mechanics(MechanicId),
	IssueDate DATE NOT NULL,
	FinishDate DATE
)

CREATE TABLE Orders
(
	OrderId INT PRIMARY KEY IDENTITY,
	JobId INT NOT NULL REFERENCES Jobs(JobId),
	IssueDate DATE,
	Delivered BIT NOT NULL DEFAULT 0
)

CREATE TABLE Vendors
(
	VendorId INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL UNIQUE
)

CREATE TABLE Parts
(
	PartId INT PRIMARY KEY IDENTITY,
	SerialNumber VARCHAR(50) NOT NULL UNIQUE,
	[Description] VARCHAR(255),
	Price DECIMAL(6,2) NOT NULL CHECK(Price >= 0),
	VendorId INT NOT NULL REFERENCES Vendors(VendorId),
	StockQty INT NOT NULL CHECK(StockQty >= 0) DEFAULT 0
)

CREATE TABLE OrderParts
(
	OrderId INT NOT NULL REFERENCES Orders(OrderId),
	PartId INT NOT NULL REFERENCES Parts(PartId),
	Quantity INT NOT NULL CHECK(Quantity > 0) DEFAULT 1
	PRIMARY KEY(OrderId, PartId)
)

CREATE TABLE PartsNeeded
(
	JobId INT NOT NULL REFERENCES Jobs(JobId),
	PartId INT NOT NULL REFERENCES Parts(PartId),
	Quantity INT NOT NULL CHECK(Quantity > 0) DEFAULT 1
	PRIMARY KEY(JobId, PartId)
)

-- 2. INSERT
INSERT INTO Clients (FirstName, LastName, Phone) VALUES
('Teri', 'Ennaco', '570-889-5187'),
('Merlyn', 'Lawler', '201-588-7810'),
('Georgene', 'Montezuma', '925-615-5185'),
('Jettie', 'Mconnell', '908-802-3564'),
('Lemuel', 'Latzke', '631-748-6479'),
('Melodie', 'Knipp', '805-690-1682'),
('Candida', 'Corbley', '908-275-8357')

INSERT INTO Parts (SerialNumber, [Description], Price, VendorId) VALUES
('WP8182119', 'Door Boot Seal', 117.86, 2),
('W10780048', 'Suspension Rod', 42.81, 1),
('W10841140', 'Silicone Adhesive', 6.77, 4),
('WPY055980', 'High Temperature Adhesive', 13.94, 3)

-- 3. UPDATE
UPDATE Jobs
	SET MechanicId = 3
	WHERE [Status] = 'Pending'

UPDATE Jobs
	SET [Status] = 'In Progress'
	WHERE [Status] = 'Pending' AND
	MechanicId = 3


-- 4. DELETE
DELETE FROM OrderParts
	WHERE OrderId = 19

DELETE FROM Orders
	WHERE OrderId = 19

-- 5. Mechanic Assignments
SELECT FirstName + ' ' + LastName AS [Mechanic], 
	[Status], IssueDate
		FROM Mechanics AS m
	JOIN Jobs AS j ON j.MechanicId = m.MechanicId
	ORDER BY m.MechanicId, IssueDate, JobId

-- 6. Current Clients
SELECT c.FirstName + ' ' + c.LastName AS [Client],
	DATEDIFF(DAY, j.IssueDate, '04/24/2017') AS [Days going], j.[Status]
		FROM Clients AS c
	JOIN Jobs AS j ON j.ClientId = c.ClientId
	WHERE j.[Status] != 'Finished'
	ORDER BY [Days going] DESC, c.ClientId

-- 7. Mechanic Performance
SELECT m.FirstName + ' ' + m.LastName AS [Mechanic],
	AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) AS [Average days]
		FROM Mechanics AS m
	JOIN Jobs AS j ON j.MechanicId = m.MechanicId
	GROUP BY m.FirstName + ' ' + m.LastName, m.MechanicId
	ORDER BY m.MechanicId


-- 8. Available Mechanics
SELECT FirstName + ' ' + LastName AS [Available] FROM Mechanics
	WHERE MechanicId NOT IN
	(
		SELECT MechanicId FROM Jobs
			WHERE [Status] = 'In Progress' OR
				[Status] IS NULL
			GROUP BY MechanicId
	)
	ORDER BY MechanicId

-- 09. Past Expenses
SELECT j.JobId, ISNULL(SUM(p.Price * op.Quantity), 0) AS [Total]
		FROM Jobs AS j
	LEFT JOIN Orders AS o ON o.JobId = j.JobId
	LEFT JOIN OrderParts AS op ON op.OrderId = o.OrderId
	LEFT JOIN Parts AS p ON op.PartId = p.PartId
	WHERE j.FinishDate IS NOT NULL
	GROUP BY j.JobId
	ORDER BY Total DESC, j.JobId


-- 10. Missing Parts
SELECT p.PartId, p.[Description],
	pn.Quantity AS [Required], 
	p.StockQty AS [In Stock], ISNULL(op.Quantity, 0) AS [Ordered]
		FROM PartsNeeded AS pn
	LEFT JOIN Jobs AS j ON pn.JobId = j.JobId
	LEFT JOIN Parts AS p ON p.PartId = pn.PartId
	LEFT JOIN OrderParts AS op ON op.PartId = p.PartId
	LEFT JOIN Orders AS o ON o.OrderId = op.OrderId
	WHERE j.[Status] != 'Finished' AND
	pn.Quantity > p.StockQty AND
	op.Quantity IS NULL
	GROUP BY p.PartId, p.[Description], pn.Quantity, p.StockQty, op.Quantity, pn.PartId
	ORDER BY pn.PartId

-- 11. Place Order
CREATE PROC usp_PlaceOrder (@jobId INT, @serialNumber VARCHAR(50), @quantity INT)
AS
BEGIN
	IF(@quantity <= 0)
		THROW 50012, 'Part quantity must be more than zero!', 1
	ELSE IF((SELECT [Status] FROM Jobs WHERE JobId = @jobId) = 'Finished')
		THROW 50011, 'This job is not active!', 1
	ELSE IF((SELECT JobId FROM Jobs WHERE JobId = @jobId) IS NULL)
		THROW 50013, 'Job not found!', 1
	ELSE IF((SELECT SerialNumber FROM Parts WHERE SerialNumber = @serialNumber) IS NULL)
		THROW 50014, 'Part not found!', 1

	DECLARE @order INT = (SELECT OrderId FROM Orders WHERE JobId = @jobId AND IssueDate IS NULL)
	DECLARE @partId INT = (SELECT PartId FROM Parts WHERE SerialNumber = @serialNumber)

	IF(@order IS NULL )
	BEGIN
		DECLARE @orderId INT = (SELECT [OrderId] FROM [Orders] WHERE [JobId] = @jobId AND [IssueDate] IS NULL)

		INSERT INTO Orders(JobId, IssueDate) VALUES
		(@jobId, NULL)

		INSERT INTO OrderParts (OrderId, PartId, Quantity) VALUES
		(@orderId, @partId, @quantity)
	END
	ELSE IF((SELECT Quantity FROM OrderParts WHERE OrderId = @order AND PartId = @partId) IS NOT NULL)
	BEGIN
		UPDATE OrderParts
			SET Quantity += @quantity
			WHERE OrderId = @order AND
			PartId = @partId
	END
	ELSE
	BEGIN
		INSERT INTO OrderParts (OrderId, PartId, Quantity) VALUES
		(@order, @partId, @quantity)
	END
END


-- 12. Cost Of Order
CREATE FUNCTION udf_GetCost (@jobId INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
	RETURN ISNULL((SELECT SUM(p.Price * op.Quantity) FROM Jobs AS j
		JOIN Orders AS o ON o.JobId = j.JobId
		JOIN OrderParts AS op ON op.OrderId = o.OrderId
		JOIN Parts AS p ON op.PartId = p.PartId
		WHERE j.JobId = @jobId), 0)
END