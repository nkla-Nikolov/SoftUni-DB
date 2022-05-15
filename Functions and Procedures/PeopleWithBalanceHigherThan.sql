CREATE PROC usp_GetHoldersWithBalanceHigherThan @number MONEY
AS
BEGIN
	SELECT ah.FirstName, ah.LastName FROM AccountHolders AS ah
	JOIN Accounts AS a ON ah.Id = a.AccountHolderId
	GROUP BY ah.Id, ah.FirstName, ah.LastName
	HAVING  CAST(SUM(Balance) AS MONEY) > @number
	ORDER BY ah.FirstName, ah.LastName
END