USE weathercrash;

DROP TABLE IF EXISTS population_raw;

-- Create intermediate table during import process
CREATE TABLE IF NOT EXISTS population_raw (
    year INT,
    canton VARCHAR(100),
    citizenship VARCHAR(100),
    sex VARCHAR(50),
    population_start INT,
    population_end INT
) ENGINE=InnoDB;

SET GLOBAL local_infile = 1;
-- Import raw data into intermediate table
LOAD DATA LOCAL INFILE 'hs25-db-s/population/px-x-0102020000_101_20251021-165023.csv'
INTO TABLE population_raw
CHARACTER SET latin1
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(year, canton, citizenship, sex, population_start, population_end);

DROP TABLE IF EXISTS population;

CREATE TABLE IF NOT EXISTS population (
    uid INT NOT NULL AUTO_INCREMENT,
    year INT,
    canton_code VARCHAR(2),
    population_start INT,
    population_end INT,
    PRIMARY KEY (uid)
) ENGINE=InnoDB;

-- Transform the cantons into their short codes to match the data in other tables
-- allowing us to join tables via these canton codes.
INSERT INTO population (year, canton_code, population_start, population_end)
SELECT
    r.year,
    m.code,
    r.population_start,
    r.population_end
FROM population_raw r
INNER JOIN (
    SELECT 'Zürich' AS name,                            'ZH' AS code UNION ALL
    SELECT 'Bern / Berne',                              'BE' UNION ALL
    SELECT 'Luzern',                                    'LU' UNION ALL
    SELECT 'Uri',                                       'UR' UNION ALL
    SELECT 'Schwyz',                                    'SZ' UNION ALL
    SELECT 'Obwalden',                                  'OW' UNION ALL
    SELECT 'Nidwalden',                                 'NW' UNION ALL
    SELECT 'Glarus',                                    'GL' UNION ALL
    SELECT 'Zug',                                       'ZG' UNION ALL
    SELECT 'Fribourg / Freiburg',                       'FR' UNION ALL
    SELECT 'Solothurn',                                 'SO' UNION ALL
    SELECT 'Basel-Stadt',                               'BS' UNION ALL
    SELECT 'Basel-Landschaft',                          'BL' UNION ALL
    SELECT 'Schaffhausen',                              'SH' UNION ALL
    SELECT 'Appenzell Ausserrhoden',                    'AR' UNION ALL
    SELECT 'Appenzell Innerrhoden',                     'AI' UNION ALL
    SELECT 'St. Gallen',                                'SG' UNION ALL
    SELECT 'Graubünden / Grigioni / Grischun',          'GR' UNION ALL
    SELECT 'Aargau',                                    'AG' UNION ALL
    SELECT 'Thurgau',                                   'TG' UNION ALL
    SELECT 'Ticino',                                    'TI' UNION ALL
    SELECT 'Vaud',                                      'VD' UNION ALL
    SELECT 'Valais / Wallis',                           'VS' UNION ALL
    SELECT 'Neuchâtel',                                 'NE' UNION ALL
    SELECT 'Genève',                                    'GE' UNION ALL
    SELECT 'Jura',                                      'JU'
) m ON r.canton = m.name;

-- Remove the intermediate table again
DROP TABLE IF EXISTS population_raw;

SET GLOBAL local_infile = 0;
