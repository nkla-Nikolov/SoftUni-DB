CREATE TABLE Students
(
	StudentID INT IDENTITY PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Exams
(
	ExamID INT IDENTITY(101, 1) PRIMARY KEY,
	[Name] VARCHAR(20) NOT NULL
)

CREATE TABLE StudentsExams
(
	StudentID INT REFERENCES Students(StudentID) NOT NULL,
	ExamID INT REFERENCES Exams(ExamID) NOT NULL,
	PRIMARY KEY (StudentID, ExamID)
)

INSERT INTO Students VALUES
('Mila'),
('Toni'),
('Ron')

INSERT INTO Exams VALUES
('SringMVC'),
('Neo4j'),
('Oracle 11g')

INSERT INTO StudentsExams VALUES
(1, 101),
(1, 102),
(2, 101),
(3, 103),
(2, 103)
