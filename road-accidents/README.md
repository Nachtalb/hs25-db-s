# Data

## RoadTrafficAccidentLocations

- Total features: 249735
- Valid accidents: 249730
- Dropped accidents: 5
- Unique accident types: 11
- Unique severity categories: 3
- Unique road types: 6

### Source

`RoadTrafficAccidentLocations.csv` — raw CSV export from the Swiss Federal Roads Office.
All data transformation (lookup table extraction, boolean conversion, datetime computation) is done in SQL via `import.sql`.

### Tables

#### accident_types

Extracted from raw data via `SELECT DISTINCT`.

- **uid**: Short code (e.g., "at0") for the accident type.
- **name_de**: German name.
- **name_fr**: French name.
- **name_it**: Italian name.
- **name_en**: English name.

#### severity_categories

Extracted from raw data via `SELECT DISTINCT`.

- **uid**: Short code (e.g., "as3") for the severity category.
- **name_de**: German name.
- **name_fr**: French name.
- **name_it**: Italian name.
- **name_en**: English name.

#### road_types

Extracted from raw data via `SELECT DISTINCT`.

- **uid**: Short code (e.g., "rt432") for the road type.
- **name_de**: German name.
- **name_fr**: French name.
- **name_it**: Italian name.
- **name_en**: English name.

#### accidents

- **accident_type_uid**: Foreign key to accident_types.uid.
- **severity_category_uid**: Foreign key to severity_categories.uid.
- **road_type_uid**: Foreign key to road_types.uid.
- **involving_pedestrian**: Boolean (1 if pedestrian involved, else 0).
- **involving_bicycle**: Boolean (1 if bicycle involved, else 0).
- **involving_motorcycle**: Boolean (1 if motorcycle involved, else 0).
- **swiss_e**: Swiss CHLV95 easting coordinate.
- **swiss_n**: Swiss CHLV95 northing coordinate.
- **canton_code**: Two-letter Swiss canton code (e.g., "GE").
- **municipality_code**: Four-digit Swiss municipality code (e.g., "6621").
- **accident_datetime**: Estimated datetime of the accident. Computed from
  year, month, hour, and weekday — the day is the first occurrence of that
  weekday in the given month. 5 entries with invalid date fields are dropped.
