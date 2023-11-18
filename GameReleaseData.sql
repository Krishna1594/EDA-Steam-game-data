# -------Gaining access for file privildges in the host to export results into a .csv format-------
SHOW VARIABLES LIKE 'secure_file_priv';
GRANT FILE ON *.* TO root@localhost;
# -------------------------------------------------------------------------------------------------
USE steamgamedata;
CREATE TEMPORARY TABLE GameRelease
AS
SELECT 
	GameID,
    Title,
    ReleaseDate
FROM steamgamedata.steam_data;


SELECT *
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/GameRelease.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
FROM GameRelease;

DROP TEMPORARY TABLE IF EXISTS GameRelease;