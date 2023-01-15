-- TASK 1
-- GETTING INFO ABOUT DATA FOR FN_CHECKAGE FUNTION (USE NORTHWIND)
select FirstName, LastName, BirthDate from Employees


-- CREATING FUNCTION FOR CHECKING AGE
CREATE OR ALTER FUNCTION fn_CheckAge(@birtdate datetime)
RETURNS bit
AS
	BEGIN
		DECLARE @Result bit;

		-- CHECK MONTH
		IF MONTH(@birtdate) >= MONTH(GETDATE())
			BEGIN
				-- CHECK DAY
				IF DAY(@birtdate) >= DAY(GETDATE())
					BEGIN
						SET @Result = 1;
					END
				ELSE
					BEGIN
						SET @Result = 0
					END
			END
		ELSE
			BEGIN 
				SET @Result = 0;
			END

		RETURN @Result
	END	
GO


-- CALLING FUNTION AND CHECKING DATA.
-- V1
SELECT dbo.fn_CheckAge(GETDATE()) AS Result

-- V2
SELECT dbo.fn_CheckAge((SELECT BirthDate FROM Employees WHERE EmployeeID = 1)) AS Result

-- V3 (MONTH TRUE BUT DAY FALSE. THAT'S WHY IT SHOW FALSE)
DECLARE @Birtday DATETIME = '01-01-2023'
SELECT dbo.fn_CheckAge(@Birtday) AS Result













-- TASK 2
-- CREATE DB
CREATE DATABASE Homework

-- SWITCH
USE HomeWork


-- CREATE TABLES (COUNTRIES, CITIES, TOWNS)
CREATE TABLE Countries (
	CountryID INT PRIMARY KEY IDENTITY(1,1),
	CountryName VARCHAR(20) NOT NULL,
	CountryCode varchar(20)
)

CREATE TABLE Cities (
	CityID INT PRIMARY KEY IDENTITY(1,1),
	CityName VARCHAR(20) NOT NULL,
	CityCode varchar(20),

	CountryID int FOREIGN KEY REFERENCES Countries(CountryID)
)

CREATE TABLE Towns (
	TownID INT PRIMARY KEY IDENTITY(1,1),
	TownName VARCHAR(20) NOT NULL,
	TownCode varchar(20),

	CityID int FOREIGN KEY REFERENCES Cities(CityID)
)


-- CREATE PROCEDURE
CREATE OR ALTER PROCEDURE sp_Geography
@Country varchar(20),
@City varchar(20),
@Town varchar(20)
AS
	-- CHECK COUNTRY
	check_country:
	IF EXISTS (SELECT * FROM Countries WHERE CountryName LIKE @Country)
		BEGIN
			DECLARE @CountryID int = (SELECT CountryID FROM Countries WHERE CountryName LIKE @Country)
			
			-- CHECK CITY
			check_city:
			IF EXISTS (SELECT * FROM Cities WHERE CityName LIKE @City)
				BEGIN
					DECLARE @CityID int = (SELECT CityID FROM Cities WHERE CityName LIKE @City)

					-- CHECK TOWN
					check_town:
					IF EXISTS (SELECT * FROM Towns WHERE TownName LIKE @Town)
						BEGIN
							PRINT 'ALL DATA ALREADY EXISTS IN DATABASE!';
						END
					ELSE
						BEGIN
							INSERT INTO Towns(TownName, CityID) VALUES(@Town, @CityID)

							PRINT UPPER(@Town) + ' HAS BEEN ADDED TO DATABASE!'

							GOTO check_town
						END
					-- END CHECK TOWN
				END
			ELSE
				BEGIN
					INSERT INTO Cities(CityName, CountryID) VALUES(@City, @CountryID)

					PRINT UPPER(@City) + ' HAS BEEN ADDED TO DATABASE!'

					GOTO check_city
				END
			-- END CHECK CITY
		END
	ELSE
		BEGIN
			INSERT INTO Countries(CountryName, CountryCode) VALUES(@Country, 'AZE')
			
			PRINT UPPER(@Country) + ' HAS BEEN ADDED TO DATABASE!'

			GOTO check_country
		END
	-- END CHECK COUNTRY
GO


-- CALL PROCEDURE
EXEC sp_Geography 
	@Country = 'Azerbaijan', 
	@City = 'Baku',
	@Town = 'Yasamal';



-- CHECK DATA
select * from Countries
select * from Cities
select * from Towns