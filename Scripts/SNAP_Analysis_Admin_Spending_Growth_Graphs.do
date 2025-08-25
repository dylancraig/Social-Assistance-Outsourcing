* ============================================
* Calculate Growth Rates for SNAP Admin Spending and Error Rates
* ============================================
* Author: Dylan Craig
* Date Created: 12/10/2024
* Date Updated: 05/15/2025
* Name: SNAP_Analysis_Admin_Spending_Growth_Graphs
* Purpose: Calculate and log year-over-year growth rates for SNAP
* administrative spending and selected performance metrics.
* ============================================

* ============================================
* Section 1: Setup - Load and Prepare Dataset
* ============================================
di "* Section 1: Setting up - Loading and Preparing Dataset"
* global project_path is assumed to be set by a master calling script
// global project_path "C:/Users/dscra/OneDrive - University of Virginia/Social Assistance Outsourcing Project"

* Load the SNAP dataset
use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear

* Convert `Year` to numeric if stored as a string
destring Year, replace
di "Section 1: Setup - Load and Prepare Dataset completed."

* ============================================
* Section 2: Calculate and Log Year-Over-Year Growth Rates
* ============================================

* ============================================
* Section 2A: Calculate Year-Over-Year Growth Rates For Admin Spending and Some Performance Metrics
* ============================================
di "* Section 2A: Calculating Year-Over-Year Growth Rates"

* Sort dataset to prepare for calculations
sort State Year

* Manually assign short prefixes for variables
local vars_with_prefixes "Tot_Admn_Cost TCost Tot_Admn_Cost_Per_Case_Per_Mnth TCase Over_Payments OPay Under_Payments UPay Payment_Error_Rate PErr"

* Calculate growth rates for each variable
local i = 1
while `i' <= wordcount("`vars_with_prefixes'") {
    local var = word("`vars_with_prefixes'", `i')
    local short_var = word("`vars_with_prefixes'", `i' + 1)

    di "Processing variable: `var' with short prefix: `short_var'"

    * Year-over-year growth rates (1, 2, 3 years ago)
    gen `short_var'G1 = (`var' - `var'[_n-1]) / `var'[_n-1] if _n > 1 & State == State[_n-1]
    gen `short_var'G2 = (`var' - `var'[_n-2]) / `var'[_n-2] if _n > 2 & State == State[_n-2]
    gen `short_var'G3 = (`var' - `var'[_n-3]) / `var'[_n-3] if _n > 3 & State == State[_n-3]

    * Flags for growth thresholds
    gen `short_var'G1_5 = `short_var'G1 > 0.05 if !missing(`short_var'G1)
    gen `short_var'G1_50 = `short_var'G1 > 0.5 if !missing(`short_var'G1)
    gen `short_var'G1_100 = `short_var'G1 > 1 if !missing(`short_var'G1)
    gen `short_var'G1_200 = `short_var'G1 > 2 if !missing(`short_var'G1)

    gen `short_var'G2_5 = `short_var'G2 > 0.05 if !missing(`short_var'G2)
    gen `short_var'G2_50 = `short_var'G2 > 0.5 if !missing(`short_var'G2)
    gen `short_var'G2_100 = `short_var'G2 > 1 if !missing(`short_var'G2)
    gen `short_var'G2_200 = `short_var'G2 > 2 if !missing(`short_var'G2)

    gen `short_var'G3_5 = `short_var'G3 > 0.05 if !missing(`short_var'G3)
    gen `short_var'G3_50 = `short_var'G3 > 0.5 if !missing(`short_var'G3)
    gen `short_var'G3_100 = `short_var'G3 > 1 if !missing(`short_var'G3)
    gen `short_var'G3_200 = `short_var'G3 > 2 if !missing(`short_var'G3)

    * Label the new variables
    label variable `short_var'G1 "1-year growth for `var'"
    label variable `short_var'G2 "2-year growth for `var'"
    label variable `short_var'G3 "3-year growth for `var'"

    label variable `short_var'G1_5 "5% increase (1 year) in `var'"
    label variable `short_var'G1_50 "50% increase (1 year) in `var'"
    label variable `short_var'G1_100 "100% increase (1 year) in `var'"
    label variable `short_var'G1_200 "200% increase (1 year) in `var'"

    label variable `short_var'G2_5 "5% increase (2 years) in `var'"
    label variable `short_var'G2_50 "50% increase (2 years) in `var'"
    label variable `short_var'G2_100 "100% increase (2 years) in `var'"
    label variable `short_var'G2_200 "200% increase (2 years) in `var'"

    label variable `short_var'G3_5 "5% increase (3 years) in `var'"
    label variable `short_var'G3_50 "50% increase (3 years) in `var'"
    label variable `short_var'G3_100 "100% increase (3 years) in `var'"
    label variable `short_var'G3_200 "200% increase (3 years) in `var'"

    * Move to the next variable and prefix
    local i = `i' + 2
}
di "Section 2A: Calculate Year-Over-Year Growth Rates completed."

* ============================================
* Section 2B: Count Indicators
* ============================================
di "* Section 2B: Counting Growth Rate Indicators"

* Create a list of indicator variables
local indicators TCostG1_5 TCostG1_50 TCostG1_100 TCostG1_200 TCostG2_5 TCostG2_50 TCostG2_100 TCostG2_200 ///
                 TCostG3_5 TCostG3_50 TCostG3_100 TCostG3_200 TCaseG1_5 TCaseG1_50 TCaseG1_100 TCaseG1_200 ///
                 TCaseG2_5 TCaseG2_50 TCaseG2_100 TCaseG2_200 TCaseG3_5 TCaseG3_50 TCaseG3_100 TCaseG3_200 ///
                 OPayG1_5 OPayG1_50 OPayG1_100 OPayG1_200 OPayG2_5 OPayG2_50 OPayG2_100 OPayG2_200 ///
                 OPayG3_5 OPayG3_50 OPayG3_100 OPayG3_200 UPayG1_5 UPayG1_50 UPayG1_100 UPayG1_200 ///
                 UPayG2_5 UPayG2_50 UPayG2_100 UPayG2_200 UPayG3_5 UPayG3_50 UPayG3_100 UPayG3_200 ///
                 PErrG1_5 PErrG1_50 PErrG1_100 PErrG1_200 PErrG2_5 PErrG2_50 PErrG2_100 PErrG2_200 ///
                 PErrG3_5 PErrG3_50 PErrG3_100 PErrG3_200

* Loop over each variable to count the number of 1s
foreach var of local indicators {
    count if `var' == 1
    display "`var': " r(N)
}
di "Section 2B: Count Indicators completed."

* ============================================
* Section 2C: Log Year-Over-Year Growth Results
* ============================================
di "* Section 2C: Logging Year-Over-Year Growth Results"

* Generate a clean output with variable counts and labels
* local indicators is already defined from Section 2B

* Define log file path
local log_file "${project_path}/Plots_Charts/SNAP Plots_Charts/Admin_Spending/Year_Over_Year_Growth/Year_Over_Year_Growth.txt"

* Ensure directory exists
capture mkdir "${project_path}/Plots_Charts"
capture mkdir "${project_path}/Plots_Charts/SNAP Plots_Charts"
capture mkdir "${project_path}/Plots_Charts/SNAP Plots_Charts/Admin_Spending"
capture mkdir "${project_path}/Plots_Charts/SNAP Plots_Charts/Admin_Spending/Year_Over_Year_Growth"


* Start logging
capture log close
log using "`log_file'", text replace

* Print header
display "Variable Counts and Labels:"
display "===================================="

* Loop through each variable, count `1`s, and include its label
foreach var of local indicators {
    count if `var' == 1
    local count_val = r(N) // Renamed to avoid conflict with `count` command
    local label_text : variable label `var' // Renamed to avoid conflict with `label` command
    display "`var': `count_val' (`label_text')"
}

* Close log file
log close
di "Section 2C: Log Year-Over-Year Growth Results completed. Log saved to: `log_file'"
di "Section 2: Calculate and Log Year-Over-Year Growth Rates completed."

* ============================================
* Script Execution Complete
* ============================================
di "SNAP_Data_Analysis_Admin_Spending_Growth_Graphs.do execution completed."
