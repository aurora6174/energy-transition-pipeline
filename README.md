# 🌍 Global Energy Transition Pipeline
### Data Engineering Zoomcamp 2026 — Capstone Project

> *"In 2000, only 15.5% of Denmark's electricity was renewable. Today it's 91.2% — a gain of 75.7 percentage points, making Denmark the world's fastest energy transition country since 2000."*

> *Meanwhile in Africa: DR Congo and Ethiopia already run on 100% renewable electricity. Kenya hits 89.8%. The energy transition story is far more surprising than the headlines suggest.*

> *This pipeline ingests, transforms, and analyses energy data for 200+ countries from 1900–2026 — built with Bruin and visualised with Evidence.dev — to uncover stories like these and rank every country's progress in the global race to renewables.*

---

## 🏆 Key Findings

- 🇩🇰 **Denmark** made the biggest leap: from **15% → 91% renewables** since 2000 (+75 points)
- ☀️ **Global solar** grew nearly **5x in 8 years**: 3,220 TWh (2016) → 14,972 TWh (2024)
- 💨 **Global wind** doubled in 8 years: 9,222 TWh (2016) → 18,495 TWh (2024)
- 🛢️ **Fossil share** dropping steadily: 54% (2017) → 33% (2024)
- 🌍 **Africa surprises**: DR Congo & Ethiopia run on 100% renewable electricity — Kenya hits 89.8% via geothermal & hydro
- 🇳🇬 **Nigeria** still 77% fossil dependent — but solar capacity is growing (0.1 TWh and rising)

---

## 🗺️ Architecture

```
Kaggle CSV (owid-energy-data.csv)
            │
            ▼
┌──────────────────────┐
│   raw.global_energy  │  ← Seed asset — 23,232 rows ingested
│       (DuckDB)       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  staging.stg_energy  │  ← Cleaned, typed, 6 quality checks
│       (DuckDB)       │
└───┬───────┬──────┬───┘
    │            │             │                │
    ▼            ▼             ▼                ▼
┌─────────┐ ┌──────────┐ ┌───────────┐ ┌────────────┐
│  mart.  │ │  mart.   │ │   mart.   │ │   mart.    │
│ country_│ │ global_  │ │   top_    │ │  africa_   │
│ energy_ │ │ summary  │ │renewables │ │  energy    │
│ trends  │ │          │ │           │ │35 countries│
└─────────┘ └──────────┘ └───────────┘ └────────────┘
                    │
                    ▼
       ┌────────────────────────┐
       │     Evidence.dev       │  ← Interactive dashboard
       │      Dashboard         │     Charts + DataTables
       └────────────────────────┘
                    │
                    ▼
       ┌────────────────────────┐
       │   GitHub Actions       │  ← CI/CD: validates pipeline
       │   CI/CD Workflow       │     on every push to main
       └────────────────────────┘
```

**Total: 6 assets · 54 quality checks · All passing ✅**

---

## Pipeline Screenshots

### Pipeline Lineage (VS Code)
![Pipeline Lineage](screenshots/Updated%20Pipeline%20Lineage.png)

### Full Bruin Pipeline Run — 54 checks passing
![Full Pipeline Run](screenshots/Full%20Pipeline%20Run%20Bruin.png)

### AI Enhancement Output
![Mart Country Energy Trends](screenshots/AI%20Enhancement%20-%20Mart%20Country%20Energy%20Trends.png)
![Mart Top Renewables](screenshots/AI%20Enhancement%20-%20Mart%20Top%20Renewables.png)
![Mart Global Summary](screenshots/AI%20Enhancement-Marts%20Global%20Summary.png)

### Renewables Leaderboard
![Renewables Leaderboard](screenshots/Renewables%20Leaderboard.png)


## GitHub Actions CI/CD — Green Pipeline
![GitHub Actions](screenshots/Github%20Actions.png)

---

## 📊 Data Visualization with Evidence.dev

### Global Energy Transition (1900–2026)
![Global Energy Transition](screenshots/Global%20Energy%20Transition%201900%20-2026.png)

### Solar & Wind Explosion (2000–2025)
![Solar and Wind Explosion](screenshots/Solar%20and%20Wind%20Explosion.png)

### Top Renewable Transition Leaders since 2000
![Top Renewable Leaders](screenshots/Top%20Renewable%20Transion%20Leaders%20Since%202000.png)

### Africa Energy Snapshot (2023)
![Africa Energy Snapshot](screenshots/Africa%20Energy%20Snapshot.png)

---

## 🛠️ Tech Stack

| Tool | Role |
|------|------|
| [Bruin](https://getbruin.com) | Ingestion + Transformation + Orchestration + AI Analysis |
| [DuckDB](https://duckdb.org) | Local analytical database |
| [Evidence.dev](https://evidence.dev) | Interactive data dashboard |
| [GitHub Actions](https://github.com/features/actions) | CI/CD — validates pipeline on every push |
| Our World in Data | Energy dataset (1900–2026, 200+ countries) |
| Git + GitHub | Version control |

---

## 📦 Dataset

- **Source**: [Global Energy Transition & Renewables (1900–2026)](https://www.kaggle.com/datasets/waddahali/global-energy-transition-and-renewables-1900-2026)
- **Provider**: Our World in Data (OWID)
- **Size**: 23,232 rows × 122 columns
- **Coverage**: 200+ countries and regions, 1900–2026
- **Key metrics**: Primary energy consumption, electricity mix, renewable shares, fossil fuel dependency, solar/wind/hydro/nuclear generation, CO2 intensity, greenhouse gas emissions

---

## 🏗️ Pipeline Layers

### Layer 1 — Raw (`raw.global_energy`)
Ingests the OWID CSV directly into DuckDB via a Bruin seed asset. No transformations — preserves the source exactly as downloaded.

### Layer 2 — Staging (`staging.stg_energy`)
Cleans and standardises the raw data:
- Trims whitespace from country names
- Casts all numeric columns with `TRY_CAST` to handle mixed types safely
- Replaces NULLs with 0 using `COALESCE` for numeric columns
- Filters to valid year range (1900–2026)
- Applies 6 quality checks including custom checks for percentage validity and row count

### Layer 3 — Mart (4 tables)

| Table | Description |
|-------|-------------|
| `mart.country_energy_trends` | Full time-series per country with YoY renewable growth and decade grouping |
| `mart.global_summary` | Global aggregates by year — total energy, solar/wind/hydro/nuclear TWh, avg CO2 intensity |
| `mart.top_renewables` | Leaderboard of countries ranked by renewable transition gain since 2000 |
| `mart.africa_energy` | 35 African countries from 1990–2026 — reveals Africa's surprising renewable leaders |

---

## ✅ Data Quality

**54 quality checks — all passing**, including:

- Column-level: `not_null`, `non_negative`, `positive` on key metrics
- Custom checks: percentage validity (0–100%), no future years, minimum row counts
- AI-generated checks via `bruin ai enhance`: energy generation consistency, valid transition status categories, year range validity

---

## 🤖 Bruin AI Enhancement

Used `bruin ai enhance` (powered by Claude) to automatically enrich all mart assets with:
- Meaningful column descriptions
- Domain tags (`domain:energy`, `domain:climate`, `pipeline_role:mart`)
- Data-driven quality checks based on actual column statistics
- Asset-level documentation

---

## 🔄 CI/CD with GitHub Actions

The pipeline validates automatically on every push to `main`:
- Installs Bruin CLI
- Validates all SQL assets
- Displays pipeline lineage
- Runs on a daily cron schedule (6am UTC)

To extend to full cloud execution: upload the dataset to S3/GCS, replace DuckDB with MotherDuck or BigQuery, and store credentials in GitHub Secrets.

---

## 🚀 How to Reproduce

### Prerequisites
- Git
- VS Code with Bruin extension
- WSL2 / Linux / macOS
- Node.js (for Evidence.dev dashboard)

### 1. Clone the repo
```bash
git clone https://github.com/aurora6174/energy-transition-pipeline.git
cd energy-transition-pipeline
```

### 2. Install Bruin CLI
```bash
curl -LsSf https://getbruin.com/install/cli | sh
```

### 3. Download the dataset
Download `owid-energy-data.csv` from [Kaggle](https://www.kaggle.com/datasets/waddahali/global-energy-transition-and-renewables-1900-2026) and place it in:
```
bruin/energy-transition-pipeline/seeds/owid-energy-data.csv
```

### 4. Run the full pipeline
```bash
cd bruin
bruin run energy-transition-pipeline --config-file .bruin.yml
```

Expected output:
```
✓ Assets executed      6 succeeded
✓ Quality checks       54 succeeded
```

### 5. Query the results
```bash
# Top renewable energy transition countries
bruin query --config-file .bruin.yml --connection duckdb-default --query \
  "SELECT country, renewables_latest, transition_gain_pct, transition_status
   FROM mart.top_renewables ORDER BY transition_gain_pct DESC LIMIT 10"

# Africa renewable leaders
bruin query --config-file .bruin.yml --connection duckdb-default --query \
  "SELECT country, renewables_share_elec, fossil_share_elec, transition_status
   FROM mart.africa_energy WHERE year = 2023
   ORDER BY renewables_share_elec DESC LIMIT 10"

# Global solar & wind growth
bruin query --config-file .bruin.yml --connection duckdb-default --query \
  "SELECT year, global_solar_twh, global_wind_twh, avg_renewables_share
   FROM mart.global_summary WHERE year >= 2010 ORDER BY year"
```

### 6. Launch the Evidence.dev dashboard
```bash
cd evidence-dashboard
npm install
cp ../bruin/energy.duckdb sources/energy/
npm run sources
npm run dev
```

Open http://localhost:3000 in your browser.

---

## 📊 Sample Results

### Top 5 Renewable Transition Leaders (since 2000)

| Country | Renewables 2000 | Renewables Latest | Gain | Status |
|---------|----------------|-------------------|------|--------|
| Denmark | 15.5% | 91.2% | +75.7pp | 🟢 Green Leader |
| Lithuania | 3.1% | 77.4% | +74.3pp | 🟢 Strong Transition |
| Estonia | 0.1% | 59.5% | +59.4pp | 🟡 Strong Transition |
| Germany | 6.2% | 58.8% | +52.6pp | 🟡 Strong Transition |
| Portugal | 29.8% | 81.0% | +51.2pp | 🟢 Green Leader |

### Africa Renewable Leaders (2023)

| Country | Renewables % | Status |
|---------|-------------|--------|
| DR Congo | 100% | 🟢 Green Leader |
| Ethiopia | 100% | 🟢 Green Leader |
| Namibia | 97.9% | 🟢 Green Leader |
| Sierra Leone | 95.2% | 🟢 Green Leader |
| Kenya | 89.8% | 🟢 Green Leader |

### Global Solar & Wind Growth (2016–2024)

| Year | Solar TWh | Wind TWh | Avg Renewables Share |
|------|-----------|----------|---------------------|
| 2016 | 3,220 | 9,223 | 24.9% |
| 2018 | 5,379 | 12,029 | 27.6% |
| 2020 | 7,855 | 15,067 | 29.2% |
| 2022 | 12,032 | 19,474 | 30.8% |
| 2024 | 14,972 | 18,495 | 26.6% |

---

## 📁 Project Structure

```
bruin-zoomcamp/
├── README.md
├── .gitignore
├── screenshots/
├── .github/
│   └── workflows/
│       └── bruin-pipeline.yml
├── bruin/
│   ├── .bruin.yml
│   └── energy-transition-pipeline/
│       ├── pipeline.yml
│       ├── seeds/
│       │   └── owid-energy-data.csv
│       └── assets/
│           ├── raw/
│           │   └── raw_energy.asset.yml
│           ├── staging/
│           │   └── stg_energy.sql
│           └── mart/
│               ├── mart_country_energy_trends.sql
│               ├── mart_global_summary.sql
│               ├── mart_top_renewables.sql
│               └── mart_africa_energy.sql
└── evidence-dashboard/
    ├── pages/
    │   └── index.md
    └── sources/
        └── energy/
            ├── connection.yaml
            ├── global_summary.sql
            ├── top_renewables.sql
            └── africa_energy.sql
```

| File/Folder | Description |
|-------------|-------------|
| `.github/workflows/bruin-pipeline.yml` | GitHub Actions CI/CD workflow |
| `bruin/.bruin.yml` | DuckDB connection config |
| `pipeline.yml` | Daily schedule & orchestration |
| `seeds/owid-energy-data.csv` | Source dataset (download from Kaggle) |
| `assets/raw/` | Seed ingestion asset |
| `assets/staging/` | Cleaning & type casting |
| `assets/mart/` | 4 analytics-ready tables |
| `evidence-dashboard/` | Interactive Evidence.dev dashboard |
| `screenshots/` | Pipeline & dashboard screenshots |

---

## 🔗 Resources

- [Bruin Documentation](https://getbruin.com/docs/bruin/)
- [Dataset — Our World in Data Energy](https://ourworldindata.org/energy)
- [Competition Page](https://getbruin.com/zoomcamp-project/)
- [Bruin GitHub](https://github.com/bruin-data/bruin)
- [Evidence.dev Documentation](https://docs.evidence.dev)

---

*Built for the Data Engineering Zoomcamp 2026 — Bruin Project Competition*