CREATE DATABASE Hotel

CREATE TABLE Employees
(
	Id INT PRIMARY KEY,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	Title VARCHAR(20) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Employees (Id, FirstName, LastName, Title, Notes) VALUES
(1, 'Petyr', 'Petrov', 'CEO', NULL),
(2, 'Ivan', 'Petrov', 'CFO', NULL),
(3, 'Mincho', 'Petrov', 'CTO', NULL)

CREATE TABLE Customers
(
	AccountNumber INT PRIMARY KEY,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	PhoneNumber VARCHAR(10) NOT NULL,
	EmergencyName VARCHAR(20) NOT NULL,
	EmergencyNumber VARCHAR(10) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Customers (AccountNumber, FirstName, LastName, PhoneNumber, EmergencyName, EmergencyNumber, Notes) VALUES
(1, 'Petyr', 'Petrov', '1234567890', 'Petyr', '1234567890', NULL),
(2, 'Ivan', 'Petrov', '1234567890', 'Ivan', '1234567890', NULL),
(3, 'Dragan', 'Petrov', '1234567890', 'Dragan', '1234567890', NULL)

CREATE TABLE RoomStatus
(
	RoomStatus VARCHAR(20) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO RoomStatus (RoomStatus, Notes) VALUES
('Under Maitanance', NULL),
('Cleaning', NULL),
('Free', NULL)

CREATE TABLE RoomTypes
(
	RoomType VARCHAR(20) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO RoomTypes (RoomType, Notes) VALUES
('Single', NULL),
('Double', NULL),
('Triple', NULL)


CREATE TABLE BedTypes
(
	BedType VARCHAR(20) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO BedTypes (BedType, Notes) VALUES
('Small', NULL),
('Medium', NULL),
('King Size', NULL)

CREATE TABLE Rooms
(
	RoomNumber INT PRIMARY KEY,
	RoomType VARCHAR(20) NOT NULL,
	BedType VARCHAR(20) NOT NULL,
	Rate VARCHAR(20),
	RoomStatus VARCHAR(20) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Rooms (RoomNumber, RoomType, BedType, Rate, RoomStatus, Notes) VALUES
(1, 'Single', 'Small', NULL, 'Free', NULL),
(2, 'Double', 'Medium', NULL, 'Cleaning', NULL),
(3, 'Triple', 'King Size', NULL, 'Free', NULL)

CREATE TABLE Payments
(
	Id INT PRIMARY KEY,
	EmployeeId INT NOT NULL,
	PaymentDate DATETIME NOT NULL,
	AccountNumber INT NOT NULL,
	FirstDateOccupied DATETIME,
	LastDateOccupied DATETIME,
	TotalDays INT NOT NULL,
	AmaountCharged DECIMAL NOT NULL,
	TaxRate DECIMAL NOT NULL,
	TaxAmount DECIMAL NOT NULL,
	PaymentTotal DECIMAL NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Payments (Id, EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, LastDateOccupied, TotalDays, AmaountCharged, TaxRate, TaxAmount, PaymentTotal, Notes) VALUES
(1, 1, GETDATE(), 1, '12/20/2020', '12/30/2020', 10, 250.50, 20, 5.50, 300, NULL),
(2, 1, GETDATE(), 1, '5/5/2020', '5/10/2020', 5, 250.50, 20, 5.50, 300, NULL),
(3, 1, GETDATE(), 1, '12/20/2020', '12/30/2020', 10, 250.50, 20, 5.50, 300, NULL)

CREATE TABLE Occupancies
(
	Id INT PRIMARY KEY,
	EmployeeId INT NOT NULL,
	DateOccupied DATETIME NOT NULL,
	AccountNumber INT NOT NULL,
	RoomNumber INT NOT NULL,
	RateApplied INT,
	PhoneCharge DECIMAL,
	Notes VARCHAR(20)
)

INSERT INTO Occupancies VALUES
(1, 1, GETDATE(), 1, 6, NULL, NULL, NULL),
(2, 2, GETDATE(), 2, 4, NULL, NULL, NULL),
(3, 3, GETDATE(), 3, 20, NULL, NULL, NULL)