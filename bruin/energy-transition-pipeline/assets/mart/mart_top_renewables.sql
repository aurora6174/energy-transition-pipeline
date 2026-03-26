/* @bruin

name: mart.top_renewables
type: duckdb.sql
description: |
  Renewable energy transition analytics mart that compares country performance between 2000 baseline and latest available year. Calculates transition gains and categorizes countries by renewable energy adoption progress. Only includes countries with valid renewable energy data in 2000 to ensure meaningful transition comparisons. Ordered by transition gain to highlight top performers in the global energy transition. Based on Our World in Data energy statistics.
tags:
  - energy
  - fact_table
  - mart
  - snapshot
  - time_series_comparison
  - renewable_energy
  - transition_analytics

materialization:
  type: table

depends:
  - staging.stg_energy

columns:
  - name: country
    type: VARCHAR
    description: Country or region name, sourced from OWID energy dataset
    checks:
      - name: not_null
  - name: renewables_latest
    type: DOUBLE
    description: |
      Renewable energy share of electricity generation (%) in the most recent available year. Represents current renewable energy adoption level.
    checks:
      - name: not_null
  - name: renewables_2000
    type: DOUBLE
    description: |
      Renewable energy share of electricity generation (%) in year 2000, serving as the baseline for transition analysis. Only countries with valid 2000 data are included in this mart.
    checks:
      - name: not_null
      - name: positive
  - name: transition_gain_pct
    type: DOUBLE
    description: |
      Percentage point change in renewable energy share from 2000 to latest year. Calculated as (renewables_latest - renewables_2000). Can be negative for countries that have reduced renewable share over time.
    checks:
      - name: not_null
  - name: transition_status
    type: VARCHAR
    description: |
      Categorical assessment of renewable energy adoption level based on latest renewable share: 'Green Leader' (80%+), 'Strong Transition' (50-79%), 'In Transition' (25-49%), 'Fossil Dependent' (<25%)
    checks:
      - name: not_null

custom_checks:
  - name: valid renewable percentages
    description: Renewable energy shares must be between 0 and 100 percent
    value: 0
    query: |
      SELECT COUNT(*) FROM mart.top_renewables WHERE renewables_latest < 0 OR renewables_latest > 100
        OR renewables_2000 < 0 OR renewables_2000 > 100
  - name: valid transition status categories
    description: Transition status must be one of the four defined categories
    value: 0
    query: |
      SELECT COUNT(*) FROM mart.top_renewables WHERE transition_status NOT IN ('Green Leader', 'Strong Transition', 'In Transition', 'Fossil Dependent')
  - name: minimum row count
    description: Table must contain data showing renewable energy transitions
    value: 1
    query: SELECT COUNT(*) > 0 FROM mart.top_renewables

@bruin */

WITH latest_year AS (
    SELECT MAX(year) AS max_year
    FROM staging.stg_energy
),
recent AS (
    SELECT
        country,
        renewables_share_elec AS renewables_latest,
        year
    FROM staging.stg_energy
    WHERE year = (SELECT max_year FROM latest_year)
),
baseline AS (
    SELECT
        country,
        renewables_share_elec AS renewables_2000
    FROM staging.stg_energy
    WHERE year = 2000
)
SELECT
    r.country,
    r.renewables_latest,
    b.renewables_2000,
    ROUND(r.renewables_latest - b.renewables_2000, 2)   AS transition_gain_pct,
    CASE
        WHEN r.renewables_latest >= 80 THEN 'Green Leader'
        WHEN r.renewables_latest >= 50 THEN 'Strong Transition'
        WHEN r.renewables_latest >= 25 THEN 'In Transition'
        ELSE 'Fossil Dependent'
    END                                                  AS transition_status
FROM recent r
JOIN baseline b ON r.country = b.country
WHERE b.renewables_2000 IS NOT NULL
  AND b.renewables_2000 > 0
ORDER BY transition_gain_pct DESC
