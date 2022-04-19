CREATE TABLE People
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[Name] VARCHAR(200) NOT NULL,
	Picture NVARCHAR(MAX),
	Height DECIMAL(10,2),
	[Weight] DECIMAL(10,2),
	Gender VARCHAR(2) NOT NULL,
	Birthdate DATETIME NOT NULL,
	Biography NVARCHAR(MAX)
)

INSERT INTO People ([Name], Picture, Height, [Weight], Gender, Birthdate, Biography) VALUES
('dhsdhs', NULL, 1.90, 100, 'm', '1996/5/10', NULL),
('gfdgfdg', NULL, 1.80, 100, 'm', '1993/5/10', NULL),
('dhsadsasdhs', NULL, 1.50, 100, 'f', '1995/5/10', NULL),
('dhsdfggdgdhs', NULL, 1.66, 100, 'f', '1999/5/10', NULL),
('fdsfds', NULL, 1.90, 100, 'f', '1998/5/10', NULL)