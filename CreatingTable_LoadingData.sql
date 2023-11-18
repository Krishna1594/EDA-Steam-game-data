SET GLOBAL local_infile=1;
show global variables like 'local_infile';

Show Databases;
#------------------------------------------
USE steamgamedata;
SHOW TABLES;
CREATE TABLE `steamgamedata`.`steam_data` (
  `GameID` INT NOT NULL,
  `Title` VARCHAR(255) NOT NULL,
  `OriginalPrice` INT NOT NULL,
  `DiscountedPrice` INT NOT NULL,
  `ReleaseDate` TEXT(45) NULL,
  `RecentReviewsSummary` TEXT(45) NULL,
  `AllReviewsSummary` TEXT(45) NULL,
  `Developer` TEXT(255) NULL,
  `Publisher` TEXT(255) NULL,
  `ReviewPercent` INT NULL,
  `Reviews` INT NULL,
  `OS` VARCHAR(255) NULL,
  `Processor` VARCHAR(255) NULL,
  `Memory` VARCHAR(45) NULL,
  `Graphics` VARCHAR(255) NULL,
  `DirectX` VARCHAR(45) NULL,
  `Storage` VARCHAR(45) NULL,
  `InLanguages` INT NULL,
  `Shooter` TEXT(45) NOT NULL,
  `Action` TEXT(45) NOT NULL,
  `Adventure` TEXT(45) NOT NULL,
  `Simulation` TEXT(45) NOT NULL,
  `Racing` TEXT(45) NOT NULL,
  `Strategy` TEXT(45) NOT NULL,
  `RPG` TEXT(45) NOT NULL,
  `BattleRoyale` TEXT(45) NOT NULL,
  `MOBA` TEXT(45) NOT NULL,
  `Horror` TEXT(45) NOT NULL,
  PRIMARY KEY (`GameID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci
COMMENT = 'Information of Steam games and Game data';
ALTER TABLE `steamgamedata`.`steam_data`
CHANGE COLUMN `ReviewPercent` `ReviewPercent` VARCHAR(255) NULL DEFAULT NULL ,
CHANGE COLUMN `Reviews` `Reviews` VARCHAR(255) NULL DEFAULT NULL,
CHANGE COLUMN `ReleaseDate` `ReleaseDate` VARCHAR(255) NULL DEFAULT NULL ;


LOAD DATA LOCAL INFILE 'D:/Professional Data Analytics Cert-GOOGLE/EDA/Steam_Data/SteamData.csv'
INTO TABLE steam_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
