
SELECT 
	InLanguages,
	COUNT(*) AS GameCount
FROM steamgamedata.steam_data
WHERE 
	InLanguages > '5'