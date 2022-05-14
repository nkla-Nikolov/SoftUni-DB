CREATE PROC usp_GetEmployeesSalaryAboveNumber @minNumber DECIMAL(18, 4)
AS
BEGIN
	SELECT FirstName, LastName FROM Employees
	WHERE Salary >= @minNumber
END