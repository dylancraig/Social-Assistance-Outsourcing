* ============================================
* Build Merge-Ready LAUS Unemployment (Annual)
* ============================================
* Author: Dylan Craig
* Date Created: 08/11/2025
* Date Updated: 08/11/2025
* Name: LAUS_State_Unemp_Annual_1995_2023
* Purpose: Create a merge-ready dataset of statewide unemployment
*          rate (NSA) annual averages for 1995–2023, keyed by State & Year.
* ============================================


* ============================================
* Section 0: Setup and Configuration
* ============================================
di "* Section 0: Setting up and configuring the environment"

clear all
set more off
version 16

* Project paths
global project_path "C:/Users/dscra/Box/Social Assistance Outsourcing Project"
global raw_dir  "${project_path}/Raw_Data/BLS_LAUS"
global out_dir  "${project_path}/Data Outputs/BLS_LAUS"
capture mkdir "${raw_dir}"
capture mkdir "${out_dir}"

di "Section 0: Set Up and Configuration completed."


* ============================================
* Section 1: Import cleaned CSV from Excel
* ============================================
di "* Section 1: Importing LAUS CSV saved from Excel"

* File saved from Excel as: la_allstatesu_clean.csv (UTF-8)
import delimited using "${raw_dir}/la_allstatesu_clean.csv", ///
    varnames(1) case(lower) encoding("utf-8") stringcols(1 3 5) clear
* Expect variables: series_id  year  period  value  footnote_codes

* Normalize series_id (strip non-breaking/regular spaces)
replace series_id = subinstr(series_id, char(160), "", .)
replace series_id = strtrim(series_id)

di "Section 1: Import completed. Observations: " _N


* ============================================
* Section 2: Filter to statewide NSA unemployment (annual averages)
* ============================================
di "* Section 2: Filtering to statewide NSA unemployment, annual averages (M13)"

* Statewide unemployment rate series: starts with LAUST ... ends with 003
gen str20 _sid = series_id
keep if substr(_sid,1,5)=="LAUST" & substr(_sid, strlen(_sid)-2, 3)=="003"
drop _sid

* Annual averages and target years
keep if period == "M13"
destring year value, replace
keep if inrange(year, 1995, 2023)

di "Section 2: Filter complete. Observations: " _N


* ============================================
* Section 3: Build merge keys and tidy
* ============================================
di "* Section 3: Building State/Year keys and labels"

* Extract 2-digit state FIPS from series_id (positions 6–7)
gen str2 stfips2 = substr(series_id, 6, 2)
destring stfips2, gen(StateFips) force
drop stfips2

* State labels (include DC & PR so decode works; drop later)
label define stlbl 1 "Alabama" 2 "Alaska" 4 "Arizona" 5 "Arkansas" 6 "California" ///
    8 "Colorado" 9 "Connecticut" 10 "Delaware" 11 "District of Columbia" 12 "Florida" ///
    13 "Georgia" 15 "Hawaii" 16 "Idaho" 17 "Illinois" 18 "Indiana" 19 "Iowa" 20 "Kansas" ///
    21 "Kentucky" 22 "Louisiana" 23 "Maine" 24 "Maryland" 25 "Massachusetts" 26 "Michigan" ///
    27 "Minnesota" 28 "Mississippi" 29 "Missouri" 30 "Montana" 31 "Nebraska" 32 "Nevada" ///
    33 "New Hampshire" 34 "New Jersey" 35 "New Mexico" 36 "New York" 37 "North Carolina" ///
    38 "North Dakota" 39 "Ohio" 40 "Oklahoma" 41 "Oregon" 42 "Pennsylvania" 44 "Rhode Island" ///
    45 "South Carolina" 46 "South Dakota" 47 "Tennessee" 48 "Texas" 49 "Utah" 50 "Vermont" ///
    51 "Virginia" 53 "Washington" 54 "West Virginia" 55 "Wisconsin" 56 "Wyoming" ///
    72 "Puerto Rico", modify
label values StateFips stlbl
decode StateFips, gen(State)
replace State = strtrim(State)

* Keep only 50 states (drop DC=11 and PR=72)
drop if inlist(StateFips, 11, 72)

* Final shape & labels
keep State StateFips year value
rename year  Year
rename value UnempRate_AnnNSA
label var UnempRate_AnnNSA "Unemployment rate, annual avg (NSA, percent)"
order State StateFips Year UnempRate_AnnNSA
sort State Year
compress

* Ensure unemployment rate is numeric for regressions
destring UnempRate_AnnNSA, replace ignore(" ,%")
format UnempRate_AnnNSA %9.2f

* (Optional) sanity checks
* isid State Year
* bys State: assert _N==29
* assert inrange(UnempRate_AnnNSA, 0, 30)

di "Section 3: Keys and tidy completed. Observations: " _N


* ============================================
* Section 4: Export merge-ready files
* ============================================
di "* Section 4: Exporting DTA and CSV outputs"

save "${out_dir}/laus_state_unemp_annual_1995_2023.dta", replace
export delimited using "${out_dir}/laus_state_unemp_annual_1995_2023.csv", replace

di "Files saved:"
di as result "  ${out_dir}/laus_state_unemp_annual_1995_2023.dta"
di as result "  ${out_dir}/laus_state_unemp_annual_1995_2023.csv"

di "Section 4: Export completed."


* ============================================
* Script Execution Complete
* ============================================
di "LAUS_State_Unemp_Annual_1995_2023.do execution completed."
