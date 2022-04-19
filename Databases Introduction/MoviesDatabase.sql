CREATE DATABASE MOovies

CREATE TABLE Directors
(
	Id INT PRIMARY KEY,
	DirectorName NVARCHAR(20) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Directors VALUES
(1, 'Peter', NULL),
(2, 'Harry', NULL),
(3, 'Odin', NULL),
(4, 'Sam', NULL),
(5, 'Stephen', NULL)


CREATE TABLE Genres
(
	Id INT PRIMARY KEY,
	GenreName NVARCHAR(20) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Genres VALUES
(1, 'Horror', NULL),
(2, 'Comedy', NULL),
(3, 'Action', NULL),
(4, 'Sci Fi', NULL),
(5, 'Romance', NULL)


CREATE TABLE Categories
(
	Id INT PRIMARY KEY,
	CategoryName NVARCHAR(20) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Categories VALUES
(1, 'Film', NULL),
(2, 'Serial', NULL),
(3, 'TV Show', NULL),
(4, 'News', NULL),
(5, 'Animation', NULL)


CREATE TABLE Movies
(
	Id INT PRIMARY KEY,
	Title NVARCHAR(50) NOT NULL,
	DirectorId INT NOT NULL,
	CopyrightYear DATETIME NOT NULL,
	Length INT,
	GenreId INT NOT NULL,
	CategoryId INT,
	Rating INT,
	Notes NVARCHAR(MAX)
)

INSERT INTO Movies VALUES
(1, 'Battleship', 1, '5/5/2012', NULL, 2, NULL, NULL, NULL),
(2, 'Anabelle', 2, '5/5/2012', NULL, 2, NULL, NULL, NULL),
(3, 'Prison Break', 3, '5/5/2012', NULL, 2, NULL, NULL, NULL),
(4, 'Moonfall', 4, '5/5/2012', NULL, 2, NULL, NULL, NULL),
(5, 'Orange County', 5, '5/5/2012', NULL, 2, NULL, NULL, NULL)