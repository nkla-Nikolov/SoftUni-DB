CREATE DATABASE CarRental

CREATE TABLE Categories
(
	Id INT PRIMARY KEY,
	CategoryName VARCHAR(20) NOT NULL,
	DailyRate VARCHAR(20),
	WeeklyRate VARCHAR(20),
	MonthlyRate VARCHAR(20),
	WeekendRate VARCHAR(20)
)

INSERT INTO Categories VALUES
(1, 'Car', NULL, NULL, NULL, NULL),
(2, 'Mini Bus', NULL, NULL, NULL, NULL),
(3, 'Truck', NULL, NULL, NULL, NULL)


CREATE TABLE Cars
(
	Id INT PRIMARY KEY,
	PlateNumber VARCHAR(10) NOT NULL,
	Manufacturer VARCHAR(20) NOT NULL,
	Model VARCHAR(20) NOT NULL,
	CarYear DATETIME NOT NULL,
	CategoryId INT,
	Doors TINYINT,
	Picture VARCHAR(MAX),
	Condition VARCHAR(20) NOT NULL,
	Available BIT NOT NULL
)

INSERT INTO Cars VALUES
(1, 'SV5050AR', 'Audi', 'S8', '10/10/2014', 1, 4, NULL, 'Used', 1),
(2, 'TX3030CH', 'Audi', 'S5', '10/10/2014', 1, 4, NULL, 'Used', 1),
(3, 'SV6966PB', 'BMW', 'M5', '10/10/2022', 1, 4, NULL, 'Brand New', 1)


CREATE TABLE Employees
(
	Id INT PRIMARY KEY,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	Title VARCHAR(20) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Employees VALUES
(1, 'Nikola', 'Nikolov', 'CEO', NULL),
(2, 'Mario', 'Ivanov', 'CTO', NULL),
(3, 'Petko', 'Sokolov', 'CTO', NULL)


CREATE TABLE Customers
(
	Id INT PRIMARY KEY,
	DriverLicenseNumber VARCHAR(10) NOT NULL,
	FullName VARCHAR(30) NOT NULL,
	Adress VARCHAR(50),
	City VARCHAR(20) NOT NULL,
	ZIPCode VARCHAR(10) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Customers VALUES
(1, 'SV5050AR', 'Nikola Nikolov', NULL, 'Sofia', 1000, NULL),
(2, 'SV5842AR', 'Mario Ivanov', NULL, 'Varna', 2984, NULL),
(3, 'SV4878AR', 'Petko Sokolov', NULL, 'Kaspichan', 3663, NULL)


CREATE TABLE RentalOrders
(
	Id INT PRIMARY KEY,
	EmployeeId INT NOT NULL,
	CustomerId INT NOT NULL,
	CarId INT NOT NULL,
	TankLevel INT,
	KilometrageStart INT NOT NULL,
	KilometrageEnd INT NOT NULL,
	TotalKilometrage INT NOT NULL,
	StartDate DATETIME NOT NULL,
	EndDate DATETIME NOT NULL,
	TotalDays INT NOT NULL,
	RateApplied INT,
	TaxRate DECIMAL NOT NULL,
	OrderStatus VARCHAR(20) NOT NULL,
	Note VARCHAR(MAX)
)

INSERT INTO RentalOrders VALUES
(1, 1, 1, 2, 10, 1000, 2000, 1000, '5/5/2012', '5/10/2012', 5, NULL, 12.50, 'Available', NULL),
(2, 2, 2, 2, 10, 1000, 2000, 1000, '5/5/2012', '5/10/2012', 5, NULL, 12.50, 'Available', NULL),
(3, 3, 3, 2, 10, 1000, 2000, 1000, '5/5/2012', '5/10/2012', 5, NULL, 12.50, 'Available', NULL)