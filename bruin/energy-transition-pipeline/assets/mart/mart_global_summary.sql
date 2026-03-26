/* @bruin

name: mart.global_summary
type: duckdb.sql
description: |
  Global annual energy transition summary table that aggregates key energy metrics across all reporting countries. This mart provides a comprehensive view of worldwide energy production, consumption, and transition trends by year.
  Built from Our World in Data's energy dataset, this table enables tracking global progress toward renewable energy adoption, carbon intensity reduction, and overall energy transition goals. The data covers multiple energy sources including fossil fuels, renewables (solar, wind, hydro), and nuclear power.
  Key insights: - Tracks countries_reporting field shows data coverage by year (more countries reporting over time) - Average percentage fields (renewables_share, fossil_share) are unweighted by population or consumption - All energy values are in TWh (terawatt-hours) for consistency - CO2 intensity represents average carbon emissions per kWh of electricity across reporting countries - Total GHG emissions aggregates all greenhouse gas emissions from reporting countries
tags:
  - domain:energy
  - domain:climate
  - data_type:fact_table
  - pipeline_role:mart
  - update_pattern:snapshot
  - source:owid
  - granularity:annual
  - geography:global

materialization:
  type: table

depends:
  - staging.stg_energy

columns:
  - name: year
    type: INTEGER
    description: Calendar year for the aggregated energy data
    checks:
      - name: not_null
      - name: non_negative
  - name: countries_reporting
    type: BIGINT
    description: Number of distinct countries/regions providing data for this year (indicates data coverage quality)
    checks:
      - name: not_null
      - name: non_negative
  - name: global_energy_twh
    type: DOUBLE
    description: Total global primary energy consumption in terawatt-hours (TWh) across all reporting countries
    checks:
      - name: not_null
      - name: non_negative
  - name: avg_renewables_share
    type: DOUBLE
    description: Unweighted average percentage of renewables in electricity generation across reporting countries (0-100%)
    checks:
      - name: not_null
  - name: avg_fossil_share
    type: DOUBLE
    description: Unweighted average percentage of fossil fuels in electricity generation across reporting countries (0-100%)
    checks:
      - name: not_null
  - name: global_solar_twh
    type: DOUBLE
    description: Total global solar electricity generation in terawatt-hours (TWh)
    checks:
      - name: not_null
  - name: global_wind_twh
    type: DOUBLE
    description: Total global wind electricity generation in terawatt-hours (TWh)
    checks:
      - name: not_null
  - name: global_hydro_twh
    type: DOUBLE
    description: Total global hydroelectric electricity generation in terawatt-hours (TWh)
    checks:
      - name: not_null
  - name: global_nuclear_twh
    type: DOUBLE
    description: Total global nuclear electricity generation in terawatt-hours (TWh)
    checks:
      - name: not_null
  - name: global_electricity_twh
    type: DOUBLE
    description: Total global electricity generation from all sources in terawatt-hours (TWh)
    checks:
      - name: not_null
      - name: non_negative
  - name: avg_co2_intensity
    type: DOUBLE
    description: Unweighted average carbon intensity of electricity generation in gCO2/kWh across reporting countries
    checks:
      - name: not_null
  - name: total_ghg_emissions
    type: DOUBLE
    description: Total global greenhouse gas emissions across all reporting countries (units from source dataset)
    checks:
      - name: not_null

custom_checks:
  - name: year_range_validity
    description: Year should be within reasonable historical and near-future range
    value: 0
    query: SELECT COUNT(*) FROM mart.global_summary WHERE year < 1900 OR year > 2030
  - name: minimum_data_coverage
    description: Each year should have meaningful country representation
    value: 0
    query: SELECT COUNT(*) FROM mart.global_summary WHERE countries_reporting < 10

@bruin */

SELECT
    year,
    COUNT(DISTINCT country)                     AS countries_reporting,
    SUM(primary_energy_consumption)             AS global_energy_twh,
    ROUND(AVG(renewables_share_elec), 2)        AS avg_renewables_share,
    ROUND(AVG(fossil_share_elec), 2)            AS avg_fossil_share,
    SUM(solar_electricity)                      AS global_solar_twh,
    SUM(wind_electricity)                       AS global_wind_twh,
    SUM(hydro_electricity)                      AS global_hydro_twh,
    SUM(nuclear_electricity)                    AS global_nuclear_twh,
    SUM(electricity_generation)                 AS global_electricity_twh,
    ROUND(AVG(carbon_intensity_elec), 2)        AS avg_co2_intensity,
    SUM(greenhouse_gas_emissions)               AS total_ghg_emissions
FROM staging.stg_energy
GROUP BY year
ORDER BY year
