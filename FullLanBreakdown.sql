# -------Gaining access for file privildges in the host to export results into a .csv format-------
SHOW VARIABLES LIKE 'secure_file_priv';
GRANT FILE ON *.* TO root@localhost;
# -------------------------------------------------------------------------------------------------
USE steamgamedata;
CREATE TEMPORARY TABLE GameLanguages
AS
SELECT 
    InLanguages,
    COUNT(*) AS GameCount
FROM 
	steamgamedata.steam_data
GROUP BY
	InLanguages
HAVING
	InLanguages = '1' OR InLanguages = '5' OR InLanguages > '15';


SELECT *
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/GameLanguages.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
FROM GameLanguages;

DROP TEMPORARY TABLE IF EXISTS GameLanguages;