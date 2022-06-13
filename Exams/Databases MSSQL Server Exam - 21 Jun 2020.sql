-- 01. DDL
CREATE TABLE Cities
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	CountryCode VARCHAR(2) NOT NULL
)

CREATE TABLE Hotels
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	CityId INT NOT NULL REFERENCES Cities(Id),
	EmployeeCount INT NOT NULL,
	BaseRate DECIMAL(10,2)
)

CREATE TABLE Rooms
(
	Id INT PRIMARY KEY IDENTITY,
	Price DECIMAL(10,2) NOT NULL,
	[Type] NVARCHAR(20) NOT NULL,
	Beds INT NOT NULL,
	HotelId INT NOT NULL REFERENCES Hotels(Id)
)

CREATE TABLE Trips
(
	Id INT PRIMARY KEY IDENTITY,
	RoomId INT NOT NULL REFERENCES Rooms(Id),
	BookDate DATE NOT NULL,
	ArrivalDate DATE NOT NULL,
	ReturnDate DATE NOT NULL,
	CancelDate DATE,
	CHECK(BookDate < ArrivalDate),
	CHECK(ArrivalDate < ReturnDate)
)

CREATE TABLE Accounts
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(20),
	LastName NVARCHAR(50) NOT NULL,
	CityId INT NOT NULL REFERENCES Cities(Id),
	BirthDate DATE NOT NULL,
	Email VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE AccountsTrips
(
	AccountId INT NOT NULL REFERENCES Accounts(Id),
	TripId INT NOT NULL REFERENCES Trips(Id),
	Luggage INT NOT NULL CHECK(Luggage >= 0),
	PRIMARY KEY(AccountId, TripId)
)

-- 02. INSERT
INSERT INTO Accounts (FirstName, MiddleName, LastName, CityId, BirthDate, Email) VALUES
('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com'),
('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@softuni.bg'),
('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips (RoomId, BookDate, ArrivalDate, ReturnDate, CancelDate) VALUES
(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
(102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
(103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
(104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
(109, '2017-08-07', '2017-08-28', '2017-08-29', NULL)


-- 03. UPDATE
UPDATE Rooms
	SET Price *= 1.14
	WHERE HotelId IN (5, 7, 9)


-- 04. DELETE
DELETE FROM AccountsTrips
	WHERE AccountId = 47

-- 05. EEE-Mails
SELECT a.FirstName, a.LastName, FORMAT(a.BirthDate, 'MM-dd-yyyy'),
	c.[Name] AS Hometown, a.Email
		FROM Accounts a
	JOIN Cities c ON a.CityId = c.Id
	WHERE Email LIKE 'e%'
	ORDER BY c.[Name]


-- 06. City Statistics
SELECT c.[Name] AS City, COUNT(h.Id) AS Hotels
		FROM Cities c
	JOIN Hotels h ON h.CityId = c.Id
	GROUP BY c.[Name]
	HAVING COUNT(h.Id) > 0
	ORDER BY Hotels DESC, c.[Name]


-- 07. Longest and Shortest Trips
SELECT a.Id AS AccountId, CONCAT(a.FirstName, ' ', a.LastName) AS FullName, 
	MAX(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS LongestTrip,
	MIN(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS ShortestTrip
		FROM Accounts AS a
	JOIN AccountsTrips AS [at] ON [at].AccountId = a.Id
	JOIN Trips AS t ON t.Id = [at].TripId
	WHERE a.MiddleName IS NULL AND
		t.CancelDate IS NULL
	GROUP BY a.Id, CONCAT(a.FirstName, ' ', a.LastName)
	ORDER BY LongestTrip DESC, ShortestTrip


-- 08. Metropolis
SELECT TOP(10) c.Id, c.[Name] AS City, c.CountryCode AS Country, 
	COUNT(a.Id) AS Accounts
		FROM Cities c
	JOIN Accounts AS a ON a.CityId = c.Id
	GROUP BY c.Id, c.[Name], c.CountryCode
	ORDER BY Accounts DESC

-- 09. Romantic Getaways
SELECT a.Id, a.Email, homeCity.[Name] AS City, COUNT(*) AS Trips
		FROM Accounts AS a
	JOIN Cities AS c ON a.CityId = c.Id
	JOIN AccountsTrips AS [at] ON [at].AccountId = a.Id
	JOIN Trips AS t ON t.Id = [at].TripId
	JOIN Rooms AS r on r.Id = t.RoomId
	JOIN Hotels AS h ON r.HotelId = h.Id
	JOIN Cities AS homeCity ON h.CityId = homeCity.Id
	WHERE c.Id = homeCity.Id
	GROUP BY a.Id, a.Email, homeCity.[Name]
	HAVING COUNT(*) >= 1
	ORDER BY Trips DESC, a.Id


-- 10. GDPR Violation
SELECT t.Id, CONCAT(a.FirstName, ' ', ISNULL(a.MiddleName + ' ',''), a.LastName) AS FullName,
	homeCity.[Name] AS [From], c.[Name] AS [To],
		CASE
			WHEN t.CancelDate IS NOT NULL THEN 'Canceled'
			ELSE 
			CAST(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)AS VARCHAR) + ' ' + 'days'
		END AS Duration 
			FROM Trips AS t
	JOIN AccountsTrips AS [at] ON [at].TripId = t.Id
	JOIN Accounts AS a ON a.Id = [at].AccountId
	JOIN Cities AS homeCity ON homeCity.Id = a.CityId
	JOIN Rooms AS r ON r.Id = t.RoomId
	JOIN Hotels AS h ON h.Id = r.HotelId
	JOIN Cities AS c ON c.Id = h.CityId
	ORDER BY FullName, t.Id


-- 11. Available Room
CREATE FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATETIME, @People INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @roomId INT = 
	(
		SELECT TOP(1) r.Id FROM Rooms AS r
			JOIN Hotels AS h ON r.HotelId = h.Id
			JOIN Trips AS t ON t.RoomId = r.Id
			WHERE h.Id = @HotelId AND
				t.CancelDate IS NULL AND
				r.Beds >= @People AND
				NOT EXISTS 
				(
					SELECT * 
					FROM Trips AS t 
					WHERE t.[RoomId] = r.[Id] AND 
					@Date BETWEEN t.[ArrivalDate] AND t.[ReturnDate]
				)
			ORDER BY r.Price DESC
	)

	IF(@roomId IS NULL)
		RETURN 'No rooms available'

	DECLARE @roomType NVARCHAR(20) = (SELECT [Type] FROM Rooms WHERE Id = @roomId)
	DECLARE @roomBeds INT = (SELECT Beds FROM Rooms WHERE Id = @roomId)
	DECLARE @roomPrice DECIMAL(18,2) = (SELECT Price FROM Rooms WHERE Id = @roomId)
	DECLARE @hotelBaseRate DECIMAL(18,2) = (SELECT BaseRate FROM Hotels WHERE Id = @HotelId)
	DECLARE @totalPrice DECIMAL(18,2) = (@hotelBaseRate + @roomPrice) * @People

	RETURN 'Room' + ' ' + CAST(@roomId AS NVARCHAR) + ': ' + @roomType + ' (' + 
		CAST(@roomBeds AS NVARCHAR) + ' ' + 'beds)' + ' - ' + '$' + CAST(@totalPrice AS NVARCHAR);
END


-- 12. Switch Room
CREATE PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
BEGIN
	DECLARE @currentHotelId INT = 
	(
		SELECT h.Id FROM Hotels AS h
			JOIN Rooms AS r ON h.Id = r.HotelId
			JOIN Trips AS t ON t.RoomId = r.Id
			WHERE t.Id = @TripId
	)

	DECLARE @targetRoomHotelId INT =
	(
		SELECT h.Id FROM Rooms AS r
			JOIN Hotels AS h ON h.Id = r.HotelId
			WHERE r.Id = @TargetRoomId
	)

	IF(@currentHotelId != @targetRoomHotelId)
		THROW 50001, 'Target room is in another hotel!', 1


	DECLARE @targetRoomBeds INT =(SELECT Beds FROM Rooms WHERE Id = @TargetRoomId)

	DECLARE @peopleCount INT = (SELECT COUNT(*) FROM AccountsTrips WHERE TripId = @TripId)

	IF(@peopleCount > @targetRoomBeds)
		THROW 50002, 'Not enough beds in target room!', 1

	UPDATE Trips
		SET RoomId = @TargetRoomId
		WHERE Id = @TripId
END

EXEC usp_SwitchRoom 10, 7