---
title: Global Energy Transition Dashboard
---

# 🌍 Global Energy Transition (1900–2026)

*Tracking how 200+ countries shifted their energy mix — built with Bruin + DuckDB*

## Global Renewable vs Fossil Trends
```sql global_trend
SELECT 
    year,
    avg_renewables_share,
    avg_fossil_share,
    global_solar_twh,
    global_wind_twh
FROM energy.global_summary
WHERE year >= 2000
ORDER BY year
```

<LineChart 
    data={global_trend}
    x=year
    y={["avg_renewables_share", "avg_fossil_share"]}
    title="Average Renewables vs Fossil Share (%)"
    yAxisTitle="Share of Electricity (%)"
/>

## Solar & Wind Explosion

<BarChart
    data={global_trend}
    x=year
    y={["global_solar_twh", "global_wind_twh"]}
    title="Global Solar & Wind Generation (TWh)"
    yAxisTitle="TWh"
/>

## 🏆 Top Renewable Transition Leaders (since 2000)
```sql leaders
SELECT 
    country,
    renewables_2000,
    renewables_latest,
    transition_gain_pct,
    transition_status
FROM energy.top_renewables
ORDER BY transition_gain_pct DESC
LIMIT 15
```

<DataTable data={leaders} />

## 🌍 Africa Energy Snapshot (2023)
```sql africa_2023
SELECT 
    country,
    renewables_share_elec,
    fossil_share_elec,
    transition_status
FROM energy.africa_energy
WHERE year = 2023
ORDER BY renewables_share_elec DESC
```

<BarChart
    data={africa_2023}
    x=country
    y=renewables_share_elec
    title="Africa Renewable Share by Country (2023)"
    yAxisTitle="Renewables %"
    swapXY=true
/>

<DataTable data={africa_2023} />