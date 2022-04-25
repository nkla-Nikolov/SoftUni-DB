SELECT Mountains.MountainRange, PeakName, Elevation FROM Peaks
	JOIN Mountains ON Mountains.Id = MountainId
	WHERE MountainRange = 'Rila'
	ORDER BY Elevation DESC