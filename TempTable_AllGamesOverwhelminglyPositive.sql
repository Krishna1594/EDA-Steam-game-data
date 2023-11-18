# -------Gaining access for file privildges in the host to export results into a .csv format-------
SHOW VARIABLES LIKE 'secure_file_priv';
GRANT FILE ON *.* TO root@localhost;
# -------------------------------------------------------------------------------------------------
USE steamgamedata;
CREATE TEMPORARY TABLE AllgameOP
AS
SELECT * 
FROM steamgamedata.steam_data AS B
WHERE B.AllReviewsSummary = 'Overwhelmingly Positive';

SELECT *
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/AllGameOP_response.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
FROM AllgameOP;

DROP TEMPORARY TABLE IF EXISTS AllgameOP;