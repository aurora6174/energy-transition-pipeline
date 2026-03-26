/* @bruin

name: mart.country_energy_trends
type: duckdb.sql
description: |
  Comprehensive country-level energy metrics and trends for global energy transition analysis.
  This mart table aggregates key energy indicators by country and year, sourced from Our World in Data's global energy dataset. It provides a focused view on energy consumption, electricity generation mix, carbon intensity, and greenhouse gas emissions to support analysis of national energy transition progress over time.
  The table includes derived metrics for trend analysis: year-over-year renewable energy growth rates and decade groupings for long-term trend identification. Energy generation values are reported in TWh, percentage shares represent electricity mix composition, and carbon intensity measures gCO2/kWh.
  This table is optimized for time-series analysis and comparative studies of energy transition patterns across countries. Note that nuclear electricity is treated as low-carbon but not renewable.
tags:
  - energy
  - climate
  - electricity
  - renewables
  - fact_table
  - time_series

materialization:
  type: table

depends:
  - staging.stg_energy

columns:
  - name: country
    type: VARCHAR
    description: Country or region name (cleaned and trimmed from source data)
    checks:
      - name: not_null
  - name: year
    type: INTEGER
    description: Year of observation (1900-2026 range enforced in staging)
    checks:
      - name: not_null
      - name: non_negative
  - name: primary_energy_consumption
    type: DOUBLE
    description: Total primary energy consumption in terawatt-hours (TWh) - includes all energy sources consumed by the country
  - name: renewables_share_elec
    type: DOUBLE
    description: Share of renewable energy in total electricity generation (percentage, 0-100) - excludes nuclear
  - name: fossil_share_elec
    type: DOUBLE
    description: Share of fossil fuels in total electricity generation (percentage, 0-100) - coal, oil, and gas combined
  - name: solar_electricity
    type: DOUBLE
    description: Solar electricity generation in terawatt-hours (TWh) - photovoltaic and solar thermal
    checks:
      - name: non_negative
  - name: wind_electricity
    type: DOUBLE
    description: Wind electricity generation in terawatt-hours (TWh) - onshore and offshore wind combined
    checks:
      - name: non_negative
  - name: hydro_electricity
    type: DOUBLE
    description: Hydroelectric power generation in terawatt-hours (TWh) - includes pumped storage
    checks:
      - name: non_negative
  - name: nuclear_electricity
    type: DOUBLE
    description: Nuclear electricity generation in terawatt-hours (TWh) - fission-based power generation
    checks:
      - name: non_negative
  - name: carbon_intensity_elec
    type: DOUBLE
    description: Carbon intensity of electricity generation in grams CO2 per kilowatt-hour (gCO2/kWh)
    checks:
      - name: non_negative
  - name: greenhouse_gas_emissions
    type: DOUBLE
    description: Total greenhouse gas emissions from energy sector - includes CO2, methane, and other GHGs
  - name: electricity_generation
    type: DOUBLE
    description: Total electricity generation in terawatt-hours (TWh) - sum of all generation sources
    checks:
      - name: non_negative
  - name: energy_per_capita
    type: DOUBLE
    description: Primary energy consumption per capita - total energy use divided by population
  - name: renewables_yoy_change
    type: DOUBLE
    description: Year-over-year change in renewable electricity share (percentage points) - derived using window function
  - name: decade
    type: DOUBLE
    description: Decade grouping for trend analysis (e.g., 2020 for years 2020-2029) - derived as (year / 10) * 10

@bruin */

SELECT
    country,
    year,
    primary_energy_consumption,
    renewables_share_elec,
    fossil_share_elec,
    solar_electricity,
    wind_electricity,
    hydro_electricity,
    nuclear_electricity,
    carbon_intensity_elec,
    greenhouse_gas_emissions,
    electricity_generation,
    energy_per_capita,
    -- Year-over-year renewable growth
    renewables_share_elec - LAG(renewables_share_elec) OVER (
        PARTITION BY country ORDER BY year
    ) AS renewables_yoy_change,
    -- Decade label for trend grouping
    (year / 10) * 10 AS decade
FROM staging.stg_energy
