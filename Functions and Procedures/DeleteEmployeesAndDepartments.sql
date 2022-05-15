CREATE PROC usp_DeleteEmployeesFromDepartment @departmentID INT
AS
BEGIN

DELETE FROM EmployeesProjects
	WHERE EmployeeID IN (SELECT EmployeeID FROM Employees
	WHERE DepartmentID = 1)

UPDATE Employees 
	SET ManagerID = NULL
	WHERE ManagerID IN (SELECT ManagerID FROM Employees
	WHERE DepartmentID = 1)

ALTER TABLE Departments
	ALTER COLUMN ManagerID INT

UPDATE Departments
	SET ManagerID = NULL
	WHERE ManagerID IN (SELECT EmployeeID FROM Employees
	WHERE DepartmentID = 1)

DELETE FROM Employees
	WHERE DepartmentID = 1

DELETE FROM Departments
	WHERE DepartmentID = 1

SELECT COUNT(*) FROM Employees
	WHERE DepartmentID = 1

END