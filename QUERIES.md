# Queries

## Total accidents per canton over time

⚠️ Not adjusted to population size per canton in relations to others. Just a total per canton.

Visualized with an Area graph. Keep default settings.

```sql
SELECT
  DATE_FORMAT(FROM_UNIXTIME(`timestamp`), '%Y-%m') AS period,
  canton_code,
  COUNT(*) AS accidents
FROM accidents
GROUP BY period, canton_code
ORDER BY period DESC, canton_code;
```

## Mapping Accidents

```sql
WITH computed AS (
  SELECT
    a.longitude,
    a.latitude,
    at.name_en as accident_type,
    sc.name_en as severity,
    a.timestamp,
    FROM_UNIXTIME(a.timestamp) AS datetime
  FROM
    accidents a
    JOIN accident_types at ON a.accident_type_uid = at.uid
    JOIN severity_categories sc ON a.severity_category_uid = sc.uid
)
SELECT
  longitude AS "Long",
  latitude AS "Lat",
  accident_type AS "Type",
  severity AS "Severity",
  DATE_FORMAT(datetime, '%d-%m-%Y ~%H:00') AS "Time of accident"
FROM
  computed
WHERE 1=1
  [[AND YEAR(datetime) = {{ year }}]]
  [[AND MONTH(datetime) = {{ month }}]]
  [[AND DAY(datetime) = {{ day }}]]
  [[AND HOUR(datetime) = {{ hour }}]]
ORDER BY
  "Time of accident"
LIMIT 2000;
```
