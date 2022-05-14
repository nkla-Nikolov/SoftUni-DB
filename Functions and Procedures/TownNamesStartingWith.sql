CREATE PROC usp_GetTownsStartingWith @startingWithText NVARCHAR(MAX)
AS
BEGIN
	SELECT [Name] AS Town FROM Towns
	WHERE [Name] LIKE @startingWithText + '%'
END