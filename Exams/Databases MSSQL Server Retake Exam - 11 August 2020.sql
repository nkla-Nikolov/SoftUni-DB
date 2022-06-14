-- 01. DDL
CREATE TABLE Countries
(
	Id iNT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL UNIQUE
)

CREATE TABLE Customers
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(25) NOT NULL,
	LastName VARCHAR(25) NOT NULL,
	Gender VARCHAR(1) NOT NULL,
	Age INT NOT NULL,
	PhoneNumber VARCHAR(10) CHECK(LEN(PhoneNumber) = 10),
	CountryId INT NOT NULL REFERENCES Countries(Id)
)

CREATE TABLE Products
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(25) NOT NULL UNIQUE,
	[Description] VARCHAR(255) NOT NULL,
	Recipe VARCHAR(MAX) NOT NULL,
	Price MONEY NOT NULL CHECK(Price > 0)
)

CREATE TABLE Feedbacks
(
	Id INT PRIMARY KEY IDENTITY,
	[Description] VARCHAR(255),
	Rate DECIMAL(15,2) NOT NULL CHECK(Rate BETWEEN 0 AND 10),
	ProductId INT NOT NULL REFERENCES Products(Id),
	CustomerId INT NOT NULL REFERENCES Customers(Id)
)

CREATE TABLE Distributors
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(25) NOT NULL UNIQUE,
	AddressText VARCHAR(30) NOT NULL,
	Summary VARCHAR(200) NOT NULL,
	CountryId INT NOT NULL REFERENCES Countries(Id)
)

CREATE TABLE Ingredients
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	[Description] VARCHAR(200) NOT NULL,
	OriginCountryId INT NOT NULL REFERENCES Countries(Id),
	DistributorId INT NOT NULL REFERENCES Distributors(Id)
)

CREATE TABLE ProductsIngredients
(
	ProductId INT NOT NULL REFERENCES Products(Id),
	IngredientId INT NOT NULL REFERENCES Ingredients(Id)
	PRIMARY KEY(ProductId, IngredientId)
)

-- 02. INSERT
INSERT INTO Distributors ([Name], CountryId, AddressText, Summary) VALUES
('Deloitte & Touche', 2, '6 Arch St #9757', 'Customizable neutral traveling'),
('Congress Title', 13, '58 Hancock St', 'Customer loyalty'),
('Kitchen People', 1, '3 E 31st St #77', 'Triple-buffered stable delivery'),
('General Color Co Inc', 21, '6185 Bohn St #72', 'Focus group'),
('Beck Corporation', 23, '21 E 64th Ave', 'Quality-focused 4th generation hardware')

INSERT INTO Customers (FirstName, LastName, Age, Gender, PhoneNumber, CountryId) VALUES
('Francoise', 'Rautenstrauch', 25, 'M', '0195698399', 5),
('Kendra', 'Loud', 22, 'F', '0063631526', 11),
('Lourdes', 'Bauswell', 50, 'M', '0139037043', 8),
('Hannah', 'Edmison', 18, 'F', '0043343686', 1),
('Tom', 'Loeza', 31, 'M', '0144876096', 23),
('Queenie', 'Kramarczyk', 30, 'F', '0064215793', 29),
('Hiu', 'Portaro', 25, 'M', '0068277755', 16),
('Josefa', 'Opitz', 43, 'F', '0197887645', 17)

-- 03. Update
UPDATE Ingredients
SET DistributorId = 35
	WHERE [Name] IN ('Bay Leaf', 'Paprika', 'Poppy')

UPDATE Ingredients
SET OriginCountryId = 14
	WHERE OriginCountryId = 8

-- 04. Delete
DELETE FROM Feedbacks
	WHERE CustomerId = 14 OR
	ProductId = 5


-- 05. Products By Price
SELECT [Name], Price, [Description] FROM Products
	ORDER BY Price DESC, [Name]

-- 06. Negative Feedback
SELECT f.ProductId, f.Rate, f.[Description], c.Id AS CustomerId, c.Age, c.Gender
		FROM Feedbacks AS f
	JOIN Customers AS c ON f.CustomerId = c.Id
	WHERE f.Rate < 5
	ORDER BY f.ProductId DESC, f.Rate


-- 07. Customers without Feedback
SELECT CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName, c.PhoneNumber, c.Gender
		FROM Customers AS c
	LEFT JOIN Feedbacks AS f ON f.CustomerId = c.Id
	WHERE f.Id IS NULL
	ORDER BY c.Id


-- 08. Customers by Criteria
SELECT c.FirstName, c.Age, c.PhoneNumber
		FROM Customers AS c
	JOIN Countries AS co ON c.CountryId = co.Id
	WHERE (c.Age >= 21 AND
	c.FirstName LIKE '%an%') OR
	(c.PhoneNumber LIKE '%38' AND
	co.[Name] != 'Greece')
	ORDER BY c.FirstName, c.Age DESC


-- 09. Middle Range Distributors
SELECT d.[Name] AS DistributorName, i.[Name] AS IngredientName,
	p.[Name] AS ProductName, AVG(f.Rate) AS AverageRate
		FROM Distributors AS d
	JOIN Ingredients AS i ON i.DistributorId = d.Id
	JOIN ProductsIngredients AS [pi] ON [pi].IngredientId = i.Id
	JOIN Products AS p ON p.Id = [pi].ProductId
	JOIN Feedbacks AS f ON f.ProductId = p.Id
	GROUP BY d.[Name], i.[Name], p.[Name]
	HAVING AVG(f.Rate) BETWEEN 5 AND 8
	ORDER BY DistributorName, IngredientName, ProductName


-- 10. Country Representative

SELECT subquery.CountryName, subquery.DistributorName 
	FROM 
	(
		SELECT c.[Name] AS CountryName, d.[Name] AS DistributorName,
			DENSE_RANK() OVER(PARTITION BY c.[Name] ORDER BY COUNT(i.Id) DESC) AS ranked
				FROM Distributors AS d
		LEFT JOIN Ingredients AS i ON i.DistributorId = d.Id
		LEFT JOIN Countries AS c ON d.CountryId = c.Id
		GROUP BY c.[Name], d.[Name]
	) AS subquery
	WHERE subquery.ranked = 1
	ORDER BY subquery.CountryName, subquery.DistributorName


-- 11. Customers With Countries
CREATE VIEW v_UserWithCountries AS
SELECT CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName, 
	c.Age, c.Gender, co.[Name] AS CountryName
		FROM Customers AS c
	JOIN Countries AS co ON co.Id = c.CountryId

-- 12. Delete Products
CREATE TRIGGER tr_DeleteRelations
 ON Products
 INSTEAD OF DELETE
 AS
 BEGIN
	DECLARE @productId INT = 
	(
		SELECT p.Id FROM Products p
			JOIN deleted d ON p.Id = d.Id
	)
	
	DELETE FROM Feedbacks
		WHERE ProductId = @productId

	DELETE FROM ProductsIngredients
		WHERE ProductId = @productId

	DELETE FROM Products
		WHERE Id = @productId
 END 