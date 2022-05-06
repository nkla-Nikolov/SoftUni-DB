SELECT TOP(1) AVG(Salary) AS MinAverageSalary
FROM Employees AS e
	JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
	GROUP BY d.DepartmentID
	ORDER BY MinAverageSalary