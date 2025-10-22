import csv

mapping = {
    "Zürich": "ZH",
    "Bern / Berne": "BE",
    "Luzern": "LU",
    "Uri": "UR",
    "Schwyz": "SZ",
    "Obwalden": "OW",
    "Nidwalden": "NW",
    "Glarus": "GL",
    "Zug": "ZG",
    "Fribourg / Freiburg": "FR",
    "Solothurn": "SO",
    "Basel-Stadt": "BS",
    "Basel-Landschaft": "BL",
    "Schaffhausen": "SH",
    "Appenzell Ausserrhoden": "AR",
    "Appenzell Innerrhoden": "AI",
    "St. Gallen": "SG",
    "Graubünden / Grigioni / Grischun": "GR",
    "Aargau": "AG",
    "Thurgau": "TG",
    "Ticino": "TI",
    "Vaud": "VD",
    "Valais / Wallis": "VS",
    "Neuchâtel": "NE",
    "Genève": "GE",
    "Jura": "JU"
}

with open('population/px-x-0102020000_101_20251021-165023.csv', 'r', encoding='iso-8859-1', newline='') as infile:
    reader = csv.reader(infile)
    next(reader)  # Skip header
    rows = []
    for row in reader:
        if row[1] in ['Switzerland', 'No indication']:
            continue
        year = row[0]
        canton = row[1]
        if canton in mapping:
            code = mapping[canton]
            pop_start = int(row[4])
            pop_end = int(row[5])
            rows.append([year, code, pop_start, pop_end])

with open('population/population.csv', 'w', encoding='utf-8', newline='') as outfile:
    writer = csv.writer(outfile)
    writer.writerow(['year', 'canton_code', 'population_start', 'population_end'])
    writer.writerows(rows)
