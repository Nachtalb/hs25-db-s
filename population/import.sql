USE weathercrash;

DROP TABLE population;

CREATE TABLE IF NOT EXISTS population (
    year INT,
    canton_code VARCHAR(2),
    population_start INT,
    population_end INT,
    PRIMARY KEY (year, canton_code)
) ENGINE=InnoDB;

SET GLOBAL local_infile = 1;  -- Enable loading local flies

LOAD DATA LOCAL INFILE 'C:/Users/labadmin/Desktop/Project/population/Population.csv'
INTO TABLE population
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(year, @canton_code, population_start, population_end)
SET canton_code = UPPER(@canton_code);

SET GLOBAL local_infile = 0;  -- Disable loading local flies
