/* @bruin

name: staging.stg_energy
type: duckdb.sql
materialization:
  type: table
depends:
  - raw.global_energy

columns:
  - name: country
    type: string
    description: Country or region name
    checks:
      - name: not_null
  - name: year
    type: integer
    description: Year of observation
    checks:
      - name: not_null
      - name: positive
  - name: iso_code
    type: string
    description: ISO 3-letter country code
  - name: population
    type: float
    description: Population
  - name: gdp
    type: float
    description: GDP in USD
  - name: primary_energy_consumption
    type: float
    description: Total primary energy consumption in TWh
  - name: renewables_share_elec
    type: float
    description: Share of renewables in electricity mix (%)
  - name: fossil_share_elec
    type: float
    description: Share of fossil fuels in electricity mix (%)
  - name: solar_electricity
    type: float
    description: Solar electricity generation in TWh
  - name: wind_electricity
    type: float
    description: Wind electricity generation in TWh
  - name: hydro_electricity
    type: float
    description: Hydro electricity generation in TWh
  - name: nuclear_electricity
    type: float
    description: Nuclear electricity generation in TWh
  - name: carbon_intensity_elec
    type: float
    description: Carbon intensity of electricity (gCO2/kWh)
  - name: greenhouse_gas_emissions
    type: float
    description: Greenhouse gas emissions
  - name: electricity_generation
    type: float
    description: Total electricity generation in TWh
  - name: energy_per_capita
    type: float
    description: Energy consumption per capita
  - name: fossil_fuel_consumption
    type: float
    description: Total fossil fuel consumption in TWh

custom_checks:
  - name: minimum row count
    description: Table must have data loaded
    query: SELECT COUNT(*) > 0 FROM staging.stg_energy
    value: 1

  - name: renewables and fossil shares are valid percentages
    description: Share values must be between 0 and 100
    query: >
      SELECT COUNT(*) FROM staging.stg_energy
      WHERE renewables_share_elec > 100
         OR fossil_share_elec > 100
    value: 0

  - name: no future years beyond 2026
    description: Year must not exceed 2026
    query: SELECT COUNT(*) FROM staging.stg_energy WHERE year > 2026
    value: 0

@bruin */

SELECT
    TRIM(country)                                                   AS country,
    TRY_CAST(year AS INTEGER)                                       AS year,
    iso_code,
    TRY_CAST(population AS DOUBLE)                                  AS population,
    TRY_CAST(gdp AS DOUBLE)                                         AS gdp,
    COALESCE(TRY_CAST(primary_energy_consumption AS DOUBLE), 0)     AS primary_energy_consumption,
    COALESCE(TRY_CAST(renewables_share_elec AS DOUBLE), 0)          AS renewables_share_elec,
    COALESCE(TRY_CAST(fossil_share_elec AS DOUBLE), 0)              AS fossil_share_elec,
    COALESCE(TRY_CAST(solar_electricity AS DOUBLE), 0)              AS solar_electricity,
    COALESCE(TRY_CAST(wind_electricity AS DOUBLE), 0)               AS wind_electricity,
    COALESCE(TRY_CAST(hydro_electricity AS DOUBLE), 0)              AS hydro_electricity,
    COALESCE(TRY_CAST(nuclear_electricity AS DOUBLE), 0)            AS nuclear_electricity,
    COALESCE(TRY_CAST(carbon_intensity_elec AS DOUBLE), 0)          AS carbon_intensity_elec,
    COALESCE(TRY_CAST(greenhouse_gas_emissions AS DOUBLE), 0)       AS greenhouse_gas_emissions,
    COALESCE(TRY_CAST(electricity_generation AS DOUBLE), 0)         AS electricity_generation,
    COALESCE(TRY_CAST(energy_per_capita AS DOUBLE), 0)              AS energy_per_capita,
    COALESCE(TRY_CAST(fossil_fuel_consumption AS DOUBLE), 0)        AS fossil_fuel_consumption
FROM raw.global_energy
WHERE country IS NOT NULL
  AND TRY_CAST(year AS INTEGER) BETWEEN 1900 AND 2026