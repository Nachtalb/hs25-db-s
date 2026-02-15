USE weathercrash;

-- Load raw CSV into staging table

DROP TABLE IF EXISTS weather_measurements;
DROP TABLE IF EXISTS weather_stations;
DROP TABLE IF EXISTS weatherdata_raw;

CREATE TABLE weatherdata_raw (
                                 datum VARCHAR(20),
                                 aesch_bl_temp_avg VARCHAR(10),
                                 aesch_bl_precipitation_intensity VARCHAR(10),
                                 amburnex_temp_avg VARCHAR(10),
                                 amburnex_precipitation_intensity VARCHAR(10),
                                 amburnex_combe_temp_avg VARCHAR(10),
                                 amburnex_combe_precipitation_intensity VARCHAR(10),
                                 anieres_temp_avg VARCHAR(10),
                                 anieres_precipitation_intensity VARCHAR(10),
                                 antagnes_temp_avg VARCHAR(10),
                                 antagnes_precipitation_intensity VARCHAR(10),
                                 arth_temp_avg VARCHAR(10),
                                 arth_precipitation_intensity VARCHAR(10),
                                 aubonne_temp_avg VARCHAR(10),
                                 aubonne_precipitation_intensity VARCHAR(10),
                                 baar_temp_avg VARCHAR(10),
                                 baar_precipitation_intensity VARCHAR(10),
                                 bad_ragaz_temp_avg VARCHAR(10),
                                 bad_ragaz_precipitation_intensity VARCHAR(10),
                                 begnins_temp_avg VARCHAR(10),
                                 begnins_precipitation_intensity VARCHAR(10),
                                 berg_temp_avg VARCHAR(10),
                                 berg_precipitation_intensity VARCHAR(10),
                                 berneck_feuerbrand_temp_avg VARCHAR(10),
                                 berneck_feuerbrand_precipitation_intensity VARCHAR(10),
                                 berneck_indermaur_temp_avg VARCHAR(10),
                                 berneck_indermaur_precipitation_intensity VARCHAR(10),
                                 bernex_temp_avg VARCHAR(10),
                                 bernex_precipitation_intensity VARCHAR(10),
                                 bex_temp_avg VARCHAR(10),
                                 bex_precipitation_intensity VARCHAR(10)
) ENGINE=InnoDB;

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'hs25-db-s/weatherdata/Wetterdaten.csv'
    INTO TABLE weatherdata_raw
    CHARACTER SET utf8mb4
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES;

-- Create stations lookup table

CREATE TABLE weather_stations (
                                  uid INT AUTO_INCREMENT PRIMARY KEY,
                                  name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

INSERT INTO weather_stations (name) VALUES
                                        ('Aesch BL'),
                                        ('Amburnex'),
                                        ('Amburnex-Combe'),
                                        ('Anières'),
                                        ('Antagnes'),
                                        ('Arth'),
                                        ('Aubonne'),
                                        ('Baar'),
                                        ('Bad Ragaz'),
                                        ('Begnins'),
                                        ('Berg'),
                                        ('Berneck-Feuerbrand'),
                                        ('Berneck-Indermaur'),
                                        ('Bernex'),
                                        ('Bex');

-- Unpivot raw wide-format data into normalized rows
--
-- Each station column pair (temp_avg, precipitation_intensity)
-- becomes a row in weather_measurements.
--
-- Missing/invalid values are converted to NULL:
--   'x'     = explicitly marked as unavailable
--   ''      = empty field (station offline or data gap)
--   '-7999' = sentinel value (only in ANTAGNES temp_avg, 2024-04-08)

CREATE TABLE weather_measurements (
                                      uid INT AUTO_INCREMENT PRIMARY KEY,
                                      station_uid INT NOT NULL,
                                      weather_date DATE NOT NULL,
                                      temp_avg DECIMAL(5,2),
                                      precipitation_intensity DECIMAL(5,2),
                                      FOREIGN KEY (station_uid) REFERENCES weather_stations(uid),
                                      INDEX idx_date (weather_date),
                                      INDEX idx_station_date (station_uid, weather_date)
) ENGINE=InnoDB;

-- Cleanup: NULLIF(NULLIF(val, 'x'), '')
-- Antagnes temp_avg additionally checks for '-7999'

INSERT INTO weather_measurements (station_uid, weather_date, temp_avg, precipitation_intensity)
SELECT s.uid, STR_TO_DATE(r.datum, '%d/%m/%Y'), NULLIF(NULLIF(r.aesch_bl_temp_avg, 'x'), ''), NULLIF(NULLIF(r.aesch_bl_precipitation_intensity, 'x'), '')
FROM weatherdata_raw r CROSS JOIN weather_stations s WHERE s.name = 'Aesch BL'
UNION ALL
SELECT s.uid, STR_TO_DATE(r.datum, '%d/%m/%Y'), NULLIF(NULLIF(r.amburnex_temp_avg, 'x'), ''), NULLIF(NULLIF(r.amburnex_precipitation_intensity, 'x'), '')
FROM weatherdata_raw r CROSS JOIN weather_stations s WHERE s.name = 'Amburnex'
UNION ALL
SELECT s.uid, STR_TO_DATE(r.datum, '%d/%m/%Y'), NULLIF(NULLIF(r.amburnex_combe_temp_avg, 'x'), ''), NULLIF(NULLIF(r.amburnex_combe_precipitation_intensity, 'x'), '')
FROM weatherdata_raw r CROSS JOIN weather_stations s WHERE s.name = 'Amburnex-Combe'
UNION ALL
SELECT s.uid, STR_TO_DATE(r.datum, '%d/%m/%Y'), NULLIF(NULLIF(r.anieres_temp_avg, 'x'), ''), NULLIF(NULLIF(r.anieres_precipitation_intensity, 'x'), '')
FROM weatherdata_raw r CROSS JOIN weather_stations s WHERE s.name = 'Anières'
UNION ALL
SELECT s.uid, STR_TO_DATE(r.datum, '%d/%m/%Y'), NULLIF(NULLIF(NULLIF(r.antagnes_temp_avg, 'x'), ''), '-7999'), NULLIF(NULLIF(r.antagnes_precipitation_intensity, 'x'), '')
FROM weatherdata_raw r CROSS JOIN weather_stations s WHERE s.name = 'Antagnes'
UNION ALL
SELECT s.uid, STR_TO_DATE(r.datum, '%d/%m/%Y'), NULLIF(NULLIF(r.arth_temp_avg, 'x'), ''), NULLIF(NULLIF(r.arth_precipitation_intensity, 'x'), '')
FROM weatherdata_raw r CROSS JOIN weather_stations s WHERE s.name = 'Arth'
UNION ALL
SELECT s.uid, STR_TO_DATE(r.datum, '%d/%m/%Y'), NULLIF(NULLIF(r.aubonne_temp_avg, 'x'), ''), NULLIF(NULLIF(r.aubonne_precipitation_intensity, 'x'), '')
FROM weatherdata_raw r CROSS JOIN weather_stations s WHERE s.name = 'Aubonne'
UNION ALL
SELECT s.uid, STR_TO_DATE(r.datum, '%d/%m/%Y'), NULLIF(NULLIF(r.baar_temp_avg, 'x'), ''), NULLIF(NULLIF(r.baar_precipitation_intensity, 'x'), '')
FROM weatherdata_raw r CROSS JOIN weather_stations s WHERE s.name = 'Baar'
UNION ALL
SELECT s.uid, STR_TO_DATE(r.datum, '%d/%m/%Y'), NULLIF(NULLIF(r.bad_ragaz_temp_avg, 'x'), ''), NULLIF(NULLIF(r.bad_ragaz_precipitation_intensity, 'x'), '')
FROM weatherdata_raw r CROSS JOIN weather_stations s WHERE s.name = 'Bad Ragaz'
UNION ALL
SELECT s.uid, STR_TO_DATE(r.datum, '%d/%m/%Y'), NULLIF(NULLIF(r.begnins_temp_avg, 'x'), ''), NULLIF(NULLIF(r.begnins_precipitation_intensity, 'x'), '')
FROM weatherdata_raw r CROSS JOIN weather_stations s WHERE s.name = 'Begnins'
UNION ALL
SELECT s.uid, STR_TO_DATE(r.datum, '%d/%m/%Y'), NULLIF(NULLIF(r.berg_temp_avg, 'x'), ''), NULLIF(NULLIF(r.berg_precipitation_intensity, 'x'), '')
FROM weatherdata_raw r CROSS JOIN weather_stations s WHERE s.name = 'Berg'
UNION ALL
SELECT s.uid, STR_TO_DATE(r.datum, '%d/%m/%Y'), NULLIF(NULLIF(r.berneck_feuerbrand_temp_avg, 'x'), ''), NULLIF(NULLIF(r.berneck_feuerbrand_precipitation_intensity, 'x'), '')
FROM weatherdata_raw r CROSS JOIN weather_stations s WHERE s.name = 'Berneck-Feuerbrand'
UNION ALL
SELECT s.uid, STR_TO_DATE(r.datum, '%d/%m/%Y'), NULLIF(NULLIF(r.berneck_indermaur_temp_avg, 'x'), ''), NULLIF(NULLIF(r.berneck_indermaur_precipitation_intensity, 'x'), '')
FROM weatherdata_raw r CROSS JOIN weather_stations s WHERE s.name = 'Berneck-Indermaur'
UNION ALL
SELECT s.uid, STR_TO_DATE(r.datum, '%d/%m/%Y'), NULLIF(NULLIF(r.bernex_temp_avg, 'x'), ''), NULLIF(NULLIF(r.bernex_precipitation_intensity, 'x'), '')
FROM weatherdata_raw r CROSS JOIN weather_stations s WHERE s.name = 'Bernex'
UNION ALL
SELECT s.uid, STR_TO_DATE(r.datum, '%d/%m/%Y'), NULLIF(NULLIF(r.bex_temp_avg, 'x'), ''), NULLIF(NULLIF(r.bex_precipitation_intensity, 'x'), '')
FROM weatherdata_raw r CROSS JOIN weather_stations s WHERE s.name = 'Bex';

-- Clean up

DROP TABLE IF EXISTS weatherdata_raw;

SET GLOBAL local_infile = 0;
