-- 01. DDL
CREATE TABLE Planets
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
)

CREATE TABLE Spaceports
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	PlanetId INT NOT NULL REFERENCES Planets(Id)
)

CREATE TABLE Spaceships
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Manufacturer VARCHAR(30) NOT NULL,
	LightSpeedRate INT DEFAULT(0)
)

CREATE TABLE Colonists
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	Ucn VARCHAR(10) NOT NULL UNIQUE,
	BirthDate DATE NOT NULL
)

CREATE TABLE Journeys
(
	Id INT PRIMARY KEY IDENTITY,
	JourneyStart DATETIME NOT NULL,
	JourneyEnd DATETIME NOT NULL,
	Purpose VARCHAR(11) CHECK(Purpose IN ('Medical', 'Technical', 'Educational', 'Military')),
	DestinationSpaceportId INT NOT NULL REFERENCES Spaceports(Id),
	SpaceshipId INT NOT NULL REFERENCES Spaceships(Id)
)

CREATE TABLE TravelCards
(
	Id INT PRIMARY KEY IDENTITY,
	CardNumber VARCHAR(10) NOT NULL UNIQUE CHECK(LEN(CardNumber) = 10),
	JobDuringJourney VARCHAR(8) CHECK(JobDuringJourney IN ('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')),
	ColonistId INT NOT NULL REFERENCES Colonists(Id),
	JourneyId INT NOT NULL REFERENCES Journeys(Id)
)

-- 02. Insert
INSERT INTO Planets([Name]) VALUES
('Mars'),
('Earth'),
('Jupiter'),
('Saturn')

INSERT INTO Spaceships([Name], Manufacturer, LightSpeedRate) VALUES
('Golf', 'VW', 3),
('WakaWaka', 'Wakanda', 4),
('Falcon9', 'SpaceX', 1),
('Bed', 'Vidolov', 6)

-- 03. Update
UPDATE Spaceships
	SET LightSpeedRate += 1
	WHERE Id BETWEEN 8 AND 12

-- 04. Delete 
DELETE FROM TravelCards
	WHERE JourneyId IN (1, 2, 3)

DELETE FROM Journeys
	WHERE Id IN (1, 2, 3)


-- 05. Select All Military Journeys
SELECT Id, FORMAT(JourneyStart, 'dd/MM/yyyy') AS JourneyStart,
	FORMAT(JourneyEnd, 'dd/MM/yyyy') AS JourneyEnd
		FROM Journeys
	WHERE Purpose = 'Military'
	ORDER BY JourneyStart


-- 06. Select All Pilots
SELECT c.Id, CONCAT(c.FirstName, ' ', c.LastName) AS full_name
		FROM Colonists AS c
	JOIN TravelCards AS tc ON c.Id = tc.ColonistId
	WHERE tc.JobDuringJourney = 'Pilot'
	ORDER BY c.Id


-- 07. Count Colonists
SELECT COUNT(c.Id) AS [count]
		FROM Journeys AS j
	JOIN TravelCards AS tc ON tc.JourneyId = j.Id
	JOIN Colonists AS c ON c.Id = tc.ColonistId
	WHERE j.Purpose = 'Technical'


-- 08. Select Spaceships With Pilots
SELECT s.[Name], s.Manufacturer
		FROM Spaceships AS s
	JOIN Journeys AS j ON s.Id = j.SpaceshipId
	JOIN TravelCards AS tc ON tc.JourneyId = j.Id
	JOIN Colonists AS c ON c.Id = tc.ColonistId
	WHERE tc.JobDuringJourney = 'Pilot' AND
	2019 - YEAR(c.BirthDate) < 30
	ORDER BY s.[Name]


-- 09. Planets And Journeys
SELECT p.[Name] AS PlanetName, COUNT(p.Id) AS JourneysCount
		FROM Planets AS p
	JOIN Spaceports AS s ON s.PlanetId = p.Id
	JOIN Journeys AS j ON s.Id = j.DestinationSpaceportId
	GROUP BY p.[Name]
	ORDER BY JourneysCount DESC, PlanetName
	

-- 10. Select Special Colonists
SELECT sub.JobDuringJourney, sub.FullName, sub.ranked AS JobRank
	FROM 
	(
		SELECT CONCAT(c.FirstName, ' ', c.LastName) AS FullName, c.BirthDate, tc.JobDuringJourney,
			DENSE_RANK() OVER (PARTITION BY tc.JobDuringJourney ORDER BY c.BirthDate) AS ranked
			FROM Colonists AS c
			JOIN TravelCards AS tc ON tc.ColonistId = c.Id
	) AS sub
	WHERE sub.ranked = 2


-- 11. Get Colonist Count
CREATE FUNCTION udf_GetColonistsCount(@PlanetName VARCHAR (30))
RETURNS INT
AS
BEGIN
	RETURN (SELECT COUNT(c.Id) FROM Planets AS p
		JOIN Spaceports AS s ON s.PlanetId = p.Id
		JOIN Journeys AS j ON j.DestinationSpaceportId = s.Id
		JOIN TravelCards AS tc ON tc.JourneyId = j.Id
		JOIN Colonists AS c ON c.Id = tc.ColonistId
			WHERE p.[Name] = @PlanetName)
END


-- 12. Change Journey Purpose
CREATE PROC  usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(MAX))
AS
BEGIN
	IF((SELECT Id FROM Journeys WHERE Id = @JourneyId) IS NULL)
		THROW 50001, 'The journey does not exist!', 1

	DECLARE @currentJourneyPurpose VARCHAR(MAX) = (SELECT Purpose FROM Journeys WHERE Id = @JourneyId)

	IF(@currentJourneyPurpose = @NewPurpose)
		THROW 50002, 'You cannot change the purpose!', 1

	UPDATE Journeys
		SET Purpose = @NewPurpose
		WHERE Id = @JourneyId
END