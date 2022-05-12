SELECT SUM([Second].DepositAmount - [First].DepositAmount) AS [Difference] FROM WizzardDeposits AS [First]
	JOIN WizzardDeposits AS [Second] ON [Second].Id + 1 = [First].Id