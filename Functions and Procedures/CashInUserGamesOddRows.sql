CREATE FUNCTION ufn_CashInUsersGames (@gameName VARCHAR(MAX))
RETURNS TABLE
AS
RETURN SELECT SUM(Cash) AS SumCash FROM
(
	SELECT g.Name, ug.Cash, ROW_NUMBER() OVER (PARTITION BY g.[Name] ORDER BY ug.[Cash] DESC) AS rowNumber
		FROM Games AS g
		JOIN UsersGames AS ug ON g.Id = ug.GameId
		WHERE g.[Name] = @gameName
) AS oddRowQuery
	WHERE rowNumber % 2 != 0