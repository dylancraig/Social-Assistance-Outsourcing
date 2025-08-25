# Social Assistance Outsourcing Project

This project builds a **state-year** panel (approx. 2003–2023) to study the impact of **SNAP, TANF, and Medicaid eligibility system modernization** on administrative costs, error rates, and program outcomes.
The entire workflow is managed in **Stata** (cleaning → merge → analysis → visualization).

---

## 📂 Project Structure
- `Raw_Data/` – Source datasets (ACS Rent, BLS LAUS/QCEW, various FNS SNAP reports)
- `Scripts/` – All Stata `.do` files for cleaning, analysis, and visualization
- `Data_Outputs/` – Cleaned datasets (`.dta`), merged panel, and other data products
- `Plots_Charts/` – Exported regression tables, plots, and charts
- `Write-Ups/` – Compiled databases, reports, and supporting documentation

---

## ⚙️ Workflow Overview
1.  **Cleaning scripts** (`*_Cleaning.do`) process each raw dataset, standardize keys (State, Year), and prepare them for merging.
2.  **Merge**: `SNAP_Data_Cleaning.do` combines all cleaned files into the main analytical panel, `SNAP_Data.dta`.
3.  **Analysis**: `SNAP_Analysis_*.do` scripts generate descriptive graphs, summary tables, and run fixed-effects regressions.
4.  **Causal Analysis**: `SNAP_Modernization_Regressions.do` estimates modernization effects using TWFE and CSDID models.

---

## 🚀 Running the Project
The project is designed to run from a single entry point in Stata.

- Open `Scripts/SNAP_MASTER.do`
- **Edit the global `project_path` at the top** to point to the project's root folder
  *(e.g., `global project_path "C:/Users/YourName/Box/Social Assistance Outsourcing Project"`)*
- Run the entire script → this executes all cleaners, the merge, and all analysis scripts in order.
- **Outputs**:
    - `Data_Outputs/SNAP Dataset/SNAP_Data.dta`
    - All graphs and tables will be saved in the `Plots_Charts/` directory.

---

## 🧾 Key Scripts
- `SNAP_MASTER.do` → **Main driver** (runs the entire Stata pipeline)
- `SNAP_Data_Cleaning.do` → Merges all cleaned datasets into the final panel
- `SNAP_Analysis_Regressions.do` → Runs baseline fixed-effects regressions
- `SNAP_Modernization_Regressions.do` → Runs TWFE & CSDID event studies
- `SNAP_Analysis_*_Graphs.do` → Generates all descriptive plots and charts
- `*_Cleaning.do` → Individual cleaners for each raw dataset (ACS, QCEW, SNAP Policy, etc.)

---

## ✅ Quick Check
After a successful run:
- `SNAP_Data.dta` should exist in `Data_Outputs/SNAP Dataset/`
- The `Plots_Charts/` directory should be populated with `.png` graphs and `.doc` tables.
