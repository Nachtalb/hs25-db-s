USE weathercrash;

-- Load raw data with local infile

DROP TABLE IF EXISTS accidents_raw;
CREATE TABLE accidents_raw (
    AccidentUID VARCHAR(50),
    AccidentType VARCHAR(10),
    AccidentType_de VARCHAR(255),
    AccidentType_fr VARCHAR(255),
    AccidentType_it VARCHAR(255),
    AccidentType_en VARCHAR(255),
    AccidentSeverityCategory VARCHAR(10),
    AccidentSeverityCategory_de VARCHAR(255),
    AccidentSeverityCategory_fr VARCHAR(255),
    AccidentSeverityCategory_it VARCHAR(255),
    AccidentSeverityCategory_en VARCHAR(255),
    AccidentInvolvingPedestrian VARCHAR(10),
    AccidentInvolvingBicycle VARCHAR(10),
    AccidentInvolvingMotorcycle VARCHAR(10),
    RoadType VARCHAR(10),
    RoadType_de VARCHAR(255),
    RoadType_fr VARCHAR(255),
    RoadType_it VARCHAR(255),
    RoadType_en VARCHAR(255),
    AccidentLocation_CHLV95_E VARCHAR(10),
    AccidentLocation_CHLV95_N VARCHAR(10),
    CantonCode VARCHAR(2),
    MunicipalityCode VARCHAR(4),
    AccidentYear INT,
    AccidentMonth INT,
    AccidentMonth_de VARCHAR(50),
    AccidentMonth_fr VARCHAR(50),
    AccidentMonth_it VARCHAR(50),
    AccidentMonth_en VARCHAR(50),
    AccidentWeekDay VARCHAR(10),
    AccidentWeekDay_de VARCHAR(50),
    AccidentWeekDay_fr VARCHAR(50),
    AccidentWeekDay_it VARCHAR(50),
    AccidentWeekDay_en VARCHAR(50),
    AccidentHour INT,
    AccidentHour_text VARCHAR(20)
) ENGINE=InnoDB;

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'hs25-db-s/road-accidents/RoadTrafficAccidentLocations.csv'
INTO TABLE accidents_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Extract lookup tables from raw data

DROP TABLE IF EXISTS accident_types;
DROP TABLE IF EXISTS severity_categories;
DROP TABLE IF EXISTS road_types;

CREATE TABLE accident_types (
    uid VARCHAR(10) PRIMARY KEY,
    name_de VARCHAR(255),
    name_fr VARCHAR(255),
    name_it VARCHAR(255),
    name_en VARCHAR(255)
) ENGINE=InnoDB;

INSERT INTO accident_types (uid, name_de, name_fr, name_it, name_en)
SELECT DISTINCT
    AccidentType,
    AccidentType_de,
    AccidentType_fr,
    AccidentType_it,
    AccidentType_en
FROM accidents_raw;

CREATE TABLE severity_categories (
    uid VARCHAR(10) PRIMARY KEY,
    name_de VARCHAR(255),
    name_fr VARCHAR(255),
    name_it VARCHAR(255),
    name_en VARCHAR(255)
) ENGINE=InnoDB;

INSERT INTO severity_categories (uid, name_de, name_fr, name_it, name_en)
SELECT DISTINCT
    AccidentSeverityCategory,
    AccidentSeverityCategory_de,
    AccidentSeverityCategory_fr,
    AccidentSeverityCategory_it,
    AccidentSeverityCategory_en
FROM accidents_raw;

CREATE TABLE road_types (
    uid VARCHAR(10) PRIMARY KEY,
    name_de VARCHAR(255),
    name_fr VARCHAR(255),
    name_it VARCHAR(255),
    name_en VARCHAR(255)
) ENGINE=InnoDB;

INSERT INTO road_types (uid, name_de, name_fr, name_it, name_en)
SELECT DISTINCT
    RoadType,
    RoadType_de,
    RoadType_fr,
    RoadType_it,
    RoadType_en
FROM accidents_raw;

-- Create accidents table with computed timestamps
--
-- Timestamp logic:
--   Find the first day in (year, month) matching the weekday,
--   combine with hour, convert to Unix epoch.
--
--   MySQL DAYOFWEEK(): 1=Sunday, 2=Monday, ..., 7=Saturday
--   offset = (target_dow - DAYOFWEEK(first_of_month) + 7) % 7
--   first_matching_day = 1 + offset

DROP TABLE IF EXISTS accidents;

CREATE TABLE accidents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    accident_type_uid VARCHAR(10),
    severity_category_uid VARCHAR(10),
    road_type_uid VARCHAR(10),
    involving_pedestrian BOOLEAN,
    involving_bicycle BOOLEAN,
    involving_motorcycle BOOLEAN,
    swiss_e VARCHAR(10),
    swiss_n VARCHAR(10),
    canton_code VARCHAR(2),
    municipality_code VARCHAR(4),
    accident_datetime DATETIME,
    FOREIGN KEY (accident_type_uid) REFERENCES accident_types(uid),
    FOREIGN KEY (severity_category_uid) REFERENCES severity_categories(uid),
    FOREIGN KEY (road_type_uid) REFERENCES road_types(uid),
    INDEX idx_datetime (accident_datetime)
) ENGINE=InnoDB;

INSERT INTO accidents (
    accident_type_uid,
    severity_category_uid,
    road_type_uid,
    involving_pedestrian,
    involving_bicycle,
    involving_motorcycle,
    swiss_e,
    swiss_n,
    canton_code,
    municipality_code,
    accident_datetime
)
SELECT
    r.AccidentType,
    r.AccidentSeverityCategory,
    r.RoadType,
    (r.AccidentInvolvingPedestrian = 'true'),
    (r.AccidentInvolvingBicycle = 'true'),
    (r.AccidentInvolvingMotorcycle = 'true'),
    r.AccidentLocation_CHLV95_E,
    r.AccidentLocation_CHLV95_N,
    r.CantonCode,
    r.MunicipalityCode,
    DATE_ADD(
        -- Base date: 1st of the month at the accident hour (e.g. 2011-01-01 14:00:00)
        STR_TO_DATE(
            CONCAT(r.AccidentYear, '-', LPAD(r.AccidentMonth, 2, '0'), '-01 ',
                   LPAD(r.AccidentHour, 2, '0'), ':00:00'),
            '%Y-%m-%d %H:%i:%s'
        ),
        -- Add days to reach the first matching weekday in the month
        INTERVAL MOD(
            weekday_map.target_dow                       -- desired weekday number
            - DAYOFWEEK(                                 -- minus weekday of the 1st
                STR_TO_DATE(CONCAT(r.AccidentYear, '-', LPAD(r.AccidentMonth, 2, '0'), '-01'), '%Y-%m-%d')
            )
            + 7, 7                                       -- mod 7 to keep offset in 0-6
        ) DAY
    )
FROM accidents_raw r
INNER JOIN (
    SELECT 'Monday'    AS name, 2 AS target_dow UNION ALL
    SELECT 'Tuesday',            3 UNION ALL
    SELECT 'Wednesday',          4 UNION ALL
    SELECT 'Thursday',           5 UNION ALL
    SELECT 'Friday',             6 UNION ALL
    SELECT 'Saturday',           7 UNION ALL
    SELECT 'Sunday',             1
) weekday_map ON r.AccidentWeekDay_en = weekday_map.name
;

-- Clean up

DROP TABLE IF EXISTS accidents_raw;

SET GLOBAL local_infile = 0;
