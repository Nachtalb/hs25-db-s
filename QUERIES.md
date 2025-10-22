# Queries

## Total accidents per canton over time

⚠️ Not adjusted to population size per canton in relations to others. Just a total per canton.

Visualize with an Area graph. Keep default settings.

```sql
SELECT
  DATE_FORMAT(FROM_UNIXTIME(`timestamp`), '%Y-%m') AS period,
  canton_code,
  COUNT(*) AS accidents
FROM accidents
GROUP BY period, canton_code
ORDER BY period DESC, canton_code;
```
