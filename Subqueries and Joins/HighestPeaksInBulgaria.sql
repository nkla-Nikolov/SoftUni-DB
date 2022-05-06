SELECT c.CountryCode, m.MountainRange, p.PeakName, p.Elevation FROM Peaks AS p
	JOIN Mountains AS m ON p.MountainId = m.Id
	JOIN MountainsCountries AS mc ON m.Id = mc.MountainId
	JOIN Countries AS c ON mc.CountryCode = c.CountryCode AND c.CountryCode = 'BG'
	WHERE p.Elevation > 2835
	ORDER BY p.Elevation DESC