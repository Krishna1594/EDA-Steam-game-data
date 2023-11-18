# -------Gaining access for file privildges in the host to export results into a .csv format-------
SHOW VARIABLES LIKE 'secure_file_priv';
GRANT FILE ON *.* TO root@localhost;
# -------------------------------------------------------------------------------------------------
USE steamgamedata;
CREATE TEMPORARY TABLE AllgameVP
AS
SELECT * 
FROM steamgamedata.steam_data AS V
WHERE V.AllReviewsSummary = 'Very Positive';

SELECT *
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/AllGameVP_response.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
FROM AllgameVP;

DROP TEMPORARY TABLE IF EXISTS AllgameVP;