SELECT DISTINCT DepartmentID, Salary AS ThirdHighestSalary FROM
(
	SELECT DepartmentID, Salary,
	DENSE_RANK() OVER(PARTITION BY DepartmentID ORDER BY Salary DESC) AS Ranked
	FROM Employees
) AS s
WHERE s.Ranked = 3