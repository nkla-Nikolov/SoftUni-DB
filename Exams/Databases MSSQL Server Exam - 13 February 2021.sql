-- 1.DDL
CREATE TABLE Users
(
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL,
	[Password] VARCHAR(30) NOT NULL,
	Email VARCHAR(50) NOT NULL
)

CREATE TABLE Repositories
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors
(
	RepositoryId INT NOT NULL REFERENCES Repositories(Id),
	ContributorId INT NOT NULL REFERENCES Users(Id)
	PRIMARY KEY(RepositoryId, ContributorId)
)

CREATE TABLE Issues
(
	Id INT PRIMARY KEY IDENTITY,
	Title VARCHAR(255) NOT NULL,
	IssueStatus VARCHAR(6) NOT NULL,
	RepositoryId INT NOT NULL REFERENCES Repositories(Id),
	AssigneeId INT NOT NULL REFERENCES Users(Id)
)

CREATE TABLE Commits
(
	Id INT PRIMARY KEY IDENTITY,
	[Message] VARCHAR(255) NOT NULL,
	IssueId INT REFERENCES Issues(Id),
	RepositoryId INT NOT NULL REFERENCES Repositories(Id),
	ContributorId INT NOT NULL REFERENCES Users(Id)
)

CREATE TABLE Files
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(100) NOT NULL,
	[Size] DECIMAL(15,2) NOT NULL,
	ParentId INT REFERENCES Files(Id),
	CommitId INT NOT NULL REFERENCES Commits(Id)
)

-- 02. INSERT
INSERT INTO Files ([Name], Size, ParentId, CommitId) VALUES
('Trade.idk', 2598, 1, 1),
('menu.net', 9238.31, 2, 2),
('Administrate.soshy', 1246.93, 3, 3),
('Controller.php', 7353.15, 4, 4),
('Find.java', 9957.86, 5, 5),
('Controller.json', 14034.87, 3, 6),
('Operate.xix', 7662.92, 7, 7)

INSERT INTO Issues (Title, IssueStatus, RepositoryId, AssigneeId) VALUES
('Critical Problem with HomeController.cs file', 'open', 1, 4),
('Typo fix in Judge.html', 'open', 4, 3),
('Implement documentation for UsersService.cs', 'closed', 8, 2),
('Unreachable code in Index.cs', 'open', 9, 8)

-- 03. UPDATE
UPDATE Issues
	SET IssueStatus = 'closed'
	WHERE AssigneeId = 6

-- 04. DELETE
DELETE FROM RepositoriesContributors
	WHERE RepositoryId = 3

DELETE FROM Repositories
	WHERE [Name] = 'Softuni-Teamwork'

DELETE FROM Issues
	WHERE RepositoryId = 3

DELETE FROM Commits
	WHERE RepositoryId = 3

-- 05. Commits
SELECT Id, [Message], RepositoryId, ContributorId FROM Commits
	ORDER BY Id, [Message], RepositoryId, ContributorId


-- 06. Front-end
SELECT Id, [Name], [Size] FROM Files
	WHERE [Size] > 1000 AND
	[Name] LIKE '%html%'
	ORDER BY [Size] DESC, Id, [Name]


-- 07. Issue Assignment
SELECT i.Id, CONCAT(u.Username, ' : ', i.Title) AS IssueAssignee FROM Issues AS i
	JOIN Users AS u ON u.Id = i.AssigneeId
	ORDER BY i.Id DESC, u.Username


-- 08. Single Files
SELECT f1.Id, f1.[Name], CAST(f1.[Size] AS VARCHAR) + 'KB' AS [Size] FROM Files AS f1
	LEFT JOIN Files AS f2 ON f2.ParentId = f1.Id
	WHERE f2.ParentId IS NULL
	ORDER BY f1.Id, f1.[Name], f1.[Size] DESC


-- 09. Commits in Repositories
SELECT TOP(5) r.Id, r.[Name], COUNT(*) AS Commits FROM Repositories AS r
	JOIN Commits AS c ON c.RepositoryId = r.Id
	JOIN RepositoriesContributors AS rc ON r.Id = rc.RepositoryId
	GROUP BY r.Id, r.[Name]
	ORDER BY Commits DESC, r.Id, r.[Name]


-- 10. Average Size
SELECT u.Username, AVG(f.[Size]) AS [Size] FROM Users AS u
	JOIN Commits AS c ON c.ContributorId = u.Id
	JOIN Files AS f ON f.CommitId = c.Id
	GROUP BY u.Username
	ORDER BY [Size] DESC, u.Username

-- 11. All User Commits
CREATE FUNCTION udf_AllUserCommits(@username VARCHAR(50))
RETURNS INT
AS 
BEGIN
	RETURN (SELECT COUNT(*) FROM Commits AS c
		JOIN Users AS u ON c.ContributorId = u.Id
		WHERE u.Username = @username)
END

-- 12. Search for Files
CREATE PROC usp_SearchForFiles(@fileExtension VARCHAR(10))
AS
BEGIN
	SELECT Id, [Name], CONCAT([Size], 'KB') AS [Size]
		FROM Files
	WHERE [Name] LIKE '%.' + @fileExtension
	ORDER BY Id, [Name], [Size] DESC
END