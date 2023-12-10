/***************************************
 *                                     *
 *   Created by Elias & Kobe           *
 *   Visit https://eliasdh.com         *
 *                                     *
 ***************************************/



/*********************************************************************/
/********************* Creation Of Datawarehouse *********************/
/*********************************************************************/
CREATE TABLE "weatherHistory" ( --  (Dit is geen dimensie!)
    city VARCHAR(100),
    weatherCode INT,
    weatherType VARCHAR(100),
    humidity INT,
    hour INT,
    day INT,
    month INT,
    year INT
);

CREATE TABLE "dimDay" (
    dimDay_key INT PRIMARY KEY,
    date DATE,
    day INT,
    hour INT,
    week INT,
    month INT,
    year INT,
    season VARCHAR(20)
);

CREATE TABLE "dimUser" (
    dimUser_key BINARY(16) PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    streetnumber INT,
    street VARCHAR(255),
    city VARCHAR(400),
    country VARCHAR(255),
    experience_level VARCHAR(50),
    dedicator VARCHAR(50),
    dimUser_SK INT,             -- Auto Generated Talend
    scd_start DATETIME,         -- Auto Generated Talend
    scd_end DATETIME,           -- Auto Generated Talend
    scd_version INT,            -- Auto Generated Talend
    scd_active BIT              -- Auto Generated Talend
);

CREATE TABLE "dimRain" (
    dimRain_key INT PRIMARY KEY,
    weather_type VARCHAR(10)
);

CREATE TABLE "dimTreasureType" (
    dimTreasureType_key INT,
    difficulty INT,
    terrain INT,
    size INT
);

CREATE TABLE "treasureFound" (
    treasureFound_key INT PRIMARY KEY,
    dimDay_key INT,
    dimUser_key INT,
    dimRain_key INT,
    dimTreasureType_key INT,

    defaultValue INT,
    durationQuest VARCHAR(30),
    creationDate DATETIME2(7)
);
/*********************************************************************/