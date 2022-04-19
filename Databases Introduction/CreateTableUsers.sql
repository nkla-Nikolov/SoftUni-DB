CREATE DATABASE Users

CREATE TABLE Users
(
	Id BIGINT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL,
	[Password] VARCHAR(26) NOT NULL,
	ProfilePicture VARCHAR(MAX),
	LastLoginTime DATETIME,
	IsDeleted BIT
)

INSERT INTO Users (Username, [Password], ProfilePicture, LastLoginTime, IsDeleted) VALUES 
('dsadsadsa', 'fdsfdsfds', 'https://lh3.googleusercontent.com/ogw/ADea4I5TZRb6hbve-6hPIdquKaPOo91XuH0OCrmgBoia=s32-c-mo,', 1/5/2022, 0),
('dsadsadsa', 'fdsfdsfds', 'https://lh3.googleusercontent.com/ogw/ADea4I5TZRb6hbve-6hPIdquKaPOo91XuH0OCrmgBoia=s32-c-mo,', 3/110/2022, 0),
('dsadsadsa', 'fdsfdsfds', 'https://lh3.googleusercontent.com/ogw/ADea4I5TZRb6hbve-6hPIdquKaPOo91XuH0OCrmgBoia=s32-c-mo,', 6/16/2022, 0),
('dsadsadsa', 'fdsfdsfds', 'https://lh3.googleusercontent.com/ogw/ADea4I5TZRb6hbve-6hPIdquKaPOo91XuH0OCrmgBoia=s32-c-mo,', 8/20/2022, 0),
('dsadsadsa', 'fdsfdsfds', 'https://lh3.googleusercontent.com/ogw/ADea4I5TZRb6hbve-6hPIdquKaPOo91XuH0OCrmgBoia=s32-c-mo,', 11/29/2022, 0)

ALTER TABLE Users
DROP CONSTRAINT PK__Users__3214EC0799D5B224

ALTER TABLE Users
ADD CONSTRAINT PK_IdAndUsername PRIMARY KEY (Id, Username)

ALTER TABLE Users
ADD CONSTRAINT CH_PasswordIsMoreThan5Symbols CHECK (LEN([Password]) > 5)

ALTER TABLE Users
ADD CONSTRAINT DF_LastLoginTime DEFAULT GETDATE() FOR LastLoginTime

ALTER TABLE Users
DROP CONSTRAINT PK_IdAndUsername

ALTER TABLE Users
ADD CONSTRAINT PK_Id PRIMARY KEY (Id)

ALTER TABLE Users
ADD CONSTRAINT CH_UsernameIsAtleast3Symbols CHECK (LEN(Username) > 3)