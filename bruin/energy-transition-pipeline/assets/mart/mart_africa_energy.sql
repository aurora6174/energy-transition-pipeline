/* @bruin

name: mart.africa_energy
type: duckdb.sql
description: |
  Regional energy transition analytics mart focused on 35 key African countries from 1990-2026. Reveals surprising insights about Africa's renewable energy leadership, including DR Congo and Ethiopia at 100% renewable electricity, and Kenya at 89.8%. Includes year-over-year renewable progress tracking and categorical transition status assessment. Filtered to 1990+ to focus on modern energy transition period where data quality is highest. Demonstrates that Africa's energy story is more nuanced than headlines suggest, with several countries already achieving world-class renewable adoption.
tags:
  - energy
  - renewable_energy
  - africa
  - regional_analysis
  - fact_table
  - mart
  - time_series
  - transition_analytics

materialization:
  type: table

depends:
  - staging.stg_energy

columns:
  - name: country
    type: VARCHAR
    description: African country name from Our World in Data dataset. Includes 35 major African nations spanning North, West, East, Central, and Southern Africa regions.
    checks:
      - name: not_null
  - name: year
    type: INTEGER
    description: Year of observation, filtered to 1990-2026 period to focus on modern energy transition era with reliable data coverage.
    checks:
      - name: not_null
      - name: positive
  - name: primary_energy_consumption
    type: DOUBLE
    description: Total primary energy consumption in terawatt-hours (TWh). Represents all energy sources consumed including electricity, heat, transport fuels. Zero-filled for missing values.
    checks:
      - name: not_null
  - name: renewables_share_elec
    type: DOUBLE
    description: Share of renewable energy in electricity generation as percentage (0-100%). Includes hydro, solar, wind, geothermal, and biomass sources. Key metric for tracking energy transition progress.
    checks:
      - name: not_null
  - name: fossil_share_elec
    type: DOUBLE
    description: Share of fossil fuels in electricity generation as percentage (0-100%). Includes coal, oil, and gas. Inverse indicator of energy transition progress.
    checks:
      - name: not_null
  - name: solar_electricity
    type: DOUBLE
    description: Solar photovoltaic electricity generation in terawatt-hours (TWh). Fast-growing renewable source across sun-rich African countries.
  - name: wind_electricity
    type: DOUBLE
    description: Wind electricity generation in terawatt-hours (TWh). Growing renewable source particularly in coastal and highland African regions.
  - name: hydro_electricity
    type: DOUBLE
    description: Hydroelectric electricity generation in terawatt-hours (TWh). Dominant renewable source in many African countries with large river systems like the Congo and Nile.
  - name: electricity_generation
    type: DOUBLE
    description: Total electricity generation in terawatt-hours (TWh). Sum of all electricity sources including fossil and renewable. Used as denominator for share calculations.
  - name: energy_per_capita
    type: DOUBLE
    description: Energy consumption per capita in kilowatt-hours per person. Indicator of economic development and energy access levels across African countries.
  - name: carbon_intensity_elec
    type: DOUBLE
    description: Carbon intensity of electricity generation in grams CO2 per kilowatt-hour (gCO2/kWh). Lower values indicate cleaner electricity mix.
  - name: greenhouse_gas_emissions
    type: DOUBLE
    description: Total greenhouse gas emissions. Broader climate impact metric beyond just electricity sector carbon intensity.
  - name: renewables_yoy_change
    type: DOUBLE
    description: |
      Year-over-year change in renewable electricity share percentage points. Calculated as current year renewables_share_elec minus previous year value using window function. Positive values indicate renewable progress, negative values indicate setbacks. NULL for first year per country.
  - name: transition_status
    type: VARCHAR
    description: |
      Categorical assessment of renewable energy adoption level: 'Green Leader' (80%+ renewable), 'Strong Transition' (50-79%), 'In Transition' (25-49%), 'Fossil Dependent' (<25%). Consistent with global analysis for cross-regional comparison.
    checks:
      - name: not_null

custom_checks:
  - name: africa countries filter
    description: All countries must be from the predefined list of 35 African nations
    value: 0
    query: |
      SELECT COUNT(*) FROM mart.africa_energy WHERE country NOT IN (
        'Nigeria', 'South Africa', 'Egypt', 'Kenya', 'Ethiopia',
        'Ghana', 'Tanzania', 'Morocco', 'Algeria', 'Angola',
        'Uganda', 'Mozambique', 'Zambia', 'Zimbabwe', 'Cameroon',
        'Ivory Coast', 'Senegal', 'Tunisia', 'Libya', 'Sudan',
        'Democratic Republic of Congo', 'Rwanda', 'Mali', 'Niger',
        'Burkina Faso', 'Chad', 'Somalia', 'Mauritania', 'Namibia',
        'Botswana', 'Gabon', 'Congo', 'Benin', 'Togo', 'Sierra Leone'
      )
  - name: year range validation
    description: Years must be within the filtered range of 1990-2026
    value: 0
    query: |
      SELECT COUNT(*) FROM mart.africa_energy WHERE year < 1990 OR year > 2026
  - name: valid renewable and fossil shares
    description: Renewable and fossil electricity shares must be valid percentages between 0-100
    value: 0
    query: |
      SELECT COUNT(*) FROM mart.africa_energy
      WHERE renewables_share_elec < 0 OR renewables_share_elec > 100
         OR fossil_share_elec < 0 OR fossil_share_elec > 100
  - name: valid transition status categories
    description: Transition status must be one of the four defined categories
    value: 0
    query: |
      SELECT COUNT(*) FROM mart.africa_energy
      WHERE transition_status NOT IN ('Green Leader', 'Strong Transition', 'In Transition', 'Fossil Dependent')
  - name: minimum row count
    description: Table must contain substantial data for African energy analysis
    value: 1
    query: SELECT COUNT(*) > 100 FROM mart.africa_energy

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
    electricity_generation,
    energy_per_capita,
    carbon_intensity_elec,
    greenhouse_gas_emissions,
    renewables_share_elec - LAG(renewables_share_elec) OVER (
        PARTITION BY country ORDER BY year
    ) AS renewables_yoy_change,
    CASE
        WHEN renewables_share_elec >= 80 THEN 'Green Leader'
        WHEN renewables_share_elec >= 50 THEN 'Strong Transition'
        WHEN renewables_share_elec >= 25 THEN 'In Transition'
        ELSE 'Fossil Dependent'
    END AS transition_status
FROM staging.stg_energy
WHERE country IN (
    'Nigeria', 'South Africa', 'Egypt', 'Kenya', 'Ethiopia',
    'Ghana', 'Tanzania', 'Morocco', 'Algeria', 'Angola',
    'Uganda', 'Mozambique', 'Zambia', 'Zimbabwe', 'Cameroon',
    'Ivory Coast', 'Senegal', 'Tunisia', 'Libya', 'Sudan',
    'Democratic Republic of Congo', 'Rwanda', 'Mali', 'Niger',
    'Burkina Faso', 'Chad', 'Somalia', 'Mauritania', 'Namibia',
    'Botswana', 'Gabon', 'Congo', 'Benin', 'Togo', 'Sierra Leone'
)
AND year >= 1990
ORDER BY country, year
