CREATE PROC usp_GetEmployeesFromTown @town NVARCHAR(MAX)
AS
BEGIN
	SELECT FirstName, LastName FROM Employees AS e
	JOIN Addresses AS a ON e.AddressID = a.AddressID
	JOIN Towns AS t ON a.TownID = t.TownID
	WHERE t.Name = @town
END