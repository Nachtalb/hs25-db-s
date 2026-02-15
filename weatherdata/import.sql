USE weathercrash;

DROP TABLE IF EXISTS weatherdata_raw;
DROP TABLE IF EXISTS weatherdata;

-- Load raw data into temporary table

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

-- Import data into final table
-- Transformations:
-- - Convert date text into DATE
-- - Convert missing values "x" into NULL

CREATE TABLE weatherdata (
    uid INT AUTO_INCREMENT PRIMARY KEY,
    weather_date DATE,
    aesch_bl_temp_avg DECIMAL(5,2),
    aesch_bl_precipitation_intensity DECIMAL(5,2),
    amburnex_temp_avg DECIMAL(5,2),
    amburnex_precipitation_intensity DECIMAL(5,2),
    amburnex_combe_temp_avg DECIMAL(5,2),
    amburnex_combe_precipitation_intensity DECIMAL(5,2),
    anieres_temp_avg DECIMAL(5,2),
    anieres_precipitation_intensity DECIMAL(5,2),
    antagnes_temp_avg DECIMAL(5,2),
    antagnes_precipitation_intensity DECIMAL(5,2),
    arth_temp_avg DECIMAL(5,2),
    arth_precipitation_intensity DECIMAL(5,2),
    aubonne_temp_avg DECIMAL(5,2),
    aubonne_precipitation_intensity DECIMAL(5,2),
    baar_temp_avg DECIMAL(5,2),
    baar_precipitation_intensity DECIMAL(5,2),
    bad_ragaz_temp_avg DECIMAL(5,2),
    bad_ragaz_precipitation_intensity DECIMAL(5,2),
    begnins_temp_avg DECIMAL(5,2),
    begnins_precipitation_intensity DECIMAL(5,2),
    berg_temp_avg DECIMAL(5,2),
    berg_precipitation_intensity DECIMAL(5,2),
    berneck_feuerbrand_temp_avg DECIMAL(5,2),
    berneck_feuerbrand_precipitation_intensity DECIMAL(5,2),
    berneck_indermaur_temp_avg DECIMAL(5,2),
    berneck_indermaur_precipitation_intensity DECIMAL(5,2),
    bernex_temp_avg DECIMAL(5,2),
    bernex_precipitation_intensity DECIMAL(5,2),
    bex_temp_avg DECIMAL(5,2),
    bex_precipitation_intensity DECIMAL(5,2),
    INDEX idx_date (weather_date)
) ENGINE=InnoDB;

INSERT INTO weatherdata (
    weather_date,
    aesch_bl_temp_avg, aesch_bl_precipitation_intensity,
    amburnex_temp_avg, amburnex_precipitation_intensity,
    amburnex_combe_temp_avg, amburnex_combe_precipitation_intensity,
    anieres_temp_avg, anieres_precipitation_intensity,
    antagnes_temp_avg, antagnes_precipitation_intensity,
    arth_temp_avg, arth_precipitation_intensity,
    aubonne_temp_avg, aubonne_precipitation_intensity,
    baar_temp_avg, baar_precipitation_intensity,
    bad_ragaz_temp_avg, bad_ragaz_precipitation_intensity,
    begnins_temp_avg, begnins_precipitation_intensity,
    berg_temp_avg, berg_precipitation_intensity,
    berneck_feuerbrand_temp_avg, berneck_feuerbrand_precipitation_intensity,
    berneck_indermaur_temp_avg, berneck_indermaur_precipitation_intensity,
    bernex_temp_avg, bernex_precipitation_intensity,
    bex_temp_avg, bex_precipitation_intensity
)
SELECT
    -- Convert dd/mm/yyyy to DATE
    STR_TO_DATE(datum, '%d/%m/%Y'),
    -- Convert missing/invalid values to NULL:
    --   'x'     = explicitly marked as unavailable
    --   ''      = empty field (station offline or data gap)
    --   '-7999' = sentinel value found once in raw data (ANTAGNES, 2024-04-08)
    NULLIF(NULLIF(NULLIF(aesch_bl_temp_avg, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(aesch_bl_precipitation_intensity, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(amburnex_temp_avg, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(amburnex_precipitation_intensity, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(amburnex_combe_temp_avg, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(amburnex_combe_precipitation_intensity, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(anieres_temp_avg, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(anieres_precipitation_intensity, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(antagnes_temp_avg, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(antagnes_precipitation_intensity, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(arth_temp_avg, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(arth_precipitation_intensity, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(aubonne_temp_avg, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(aubonne_precipitation_intensity, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(baar_temp_avg, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(baar_precipitation_intensity, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(bad_ragaz_temp_avg, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(bad_ragaz_precipitation_intensity, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(begnins_temp_avg, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(begnins_precipitation_intensity, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(berg_temp_avg, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(berg_precipitation_intensity, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(berneck_feuerbrand_temp_avg, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(berneck_feuerbrand_precipitation_intensity, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(berneck_indermaur_temp_avg, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(berneck_indermaur_precipitation_intensity, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(bernex_temp_avg, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(bernex_precipitation_intensity, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(bex_temp_avg, 'x'), ''), '-7999'),
    NULLIF(NULLIF(NULLIF(bex_precipitation_intensity, 'x'), ''), '-7999')
FROM weatherdata_raw;

-- Clean up

DROP TABLE IF EXISTS weatherdata_raw;

SET GLOBAL local_infile = 0;
