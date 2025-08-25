* ============================================
* Regression Analysis of SNAP Modernization Effects
* ============================================
* Author: Dylan Craig
* Date Created: 08/01/2025
* Date Updated: 08/05/2025
* Name: SNAP_Modernization_TWFE_Analysis
* Purpose: Analyze the effects of attempted and actual SNAP
* modernization on program participation and administrative
* costs using traditional causal inference methods.
* ============================================


* ============================================
* Section 0: Setup and Configuration
* ============================================
di "* Section 0: Setting up and configuring the environment"

clear all
set more off
version 16

/*
* REQUIRED PACKAGES:
* You may need to install the following packages. Run these lines in the
* Stata command window if you do not have them:
* ssc install estout
* ssc install reghdfe
* ssc install coefplot, replace
* ssc install drdid, replace
*/

* --- Define Dependent and Control Variables for Analysis ---
local participation "Part_Prsn_Mnthly_Avg"
local admin_costs "Tot_Admn_Cost"
local controls "A_MEDIAN A_Med_Gross_Rent bbce oapp reportsimple vehexclall"

di "Section 0: Set Up and Configuration completed."


* ============================================
* Section 1: Data Loading and Panel Setup
* ============================================
di "* Section 1: Loading data and setting up panel structure"

* global project_path is assumed to be set by a master calling script
* global project_path "C:/Users/dscra/Box/Social Assistance Outsourcing Project"

* Load the dataset from the specified file path
use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear

* --- DATA CLEANING ---
* Drop national aggregate data and territories to focus on the 50 states
drop if State == "US" | State == "District of Columbia" | State == "Guam" | State == "Puerto Rico" | State == "Virgin Islands"

* Convert State from string to numeric for panel analysis
encode State, gen(State_num)

* Convert Year from string to numeric.
destring Year, replace

* Ensure all control variables are numeric
foreach var of local controls {
	capture destring `var', replace force
}

* Define the panel structure
xtset State_num Year

di "Section 1: Data Loading and Panel Setup completed."


* ============================================
* Section 2: Create SNAP Modernization Variables
* ============================================
di "* Section 2: Creating SNAP modernization indicator variables"

/*
* INSTRUCTIONS:
* The state numbers below have been corrected to reflect the 50-state dataset.
*/
gen snap_init_yr = .
gen snap_comp_yr = .
label var snap_init_yr "SNAP Modernization Initiation Year"
label var snap_comp_yr "SNAP Modernization Completion Year"

replace snap_init_yr = 2020 if State_num == 1  // Alabama
* replace snap_comp_yr = . if State_num == 1
replace snap_init_yr = 2011 if State_num == 2  // Alaska
* replace snap_comp_yr = . if State_num == 2
* replace snap_init_yr = . if State_num == 3  // Arizona
* replace snap_comp_yr = . if State_num == 3
replace snap_init_yr = 2019 if State_num == 4  // Arkansas
replace snap_comp_yr = 2021 if State_num == 4
replace snap_init_yr = 2018 if State_num == 5  // California
replace snap_comp_yr = 2023 if State_num == 5
replace snap_init_yr = 1996 if State_num == 6  // Colorado
replace snap_comp_yr = 2004 if State_num == 6
replace snap_init_yr = 2013 if State_num == 7  // Connecticut
replace snap_comp_yr = 2017 if State_num == 7
replace snap_init_yr = 1995 if State_num == 8  // Delaware
replace snap_comp_yr = 2016 if State_num == 8
replace snap_init_yr = 2019 if State_num == 9 // Florida
* replace snap_comp_yr = . if State_num == 9
replace snap_init_yr = 2016 if State_num == 10 // Georgia
replace snap_comp_yr = 2017 if State_num == 10
* replace snap_init_yr = . if State_num == 11 // Hawaii
* replace snap_comp_yr = . if State_num == 11
replace snap_init_yr = 2007 if State_num == 12 // Idaho
replace snap_comp_yr = 2009 if State_num == 12
replace snap_init_yr = 2017 if State_num == 13 // Illinois
* replace snap_init_yr = . if State_num == 13
replace snap_init_yr = 2006 if State_num == 14 // Indiana
replace snap_comp_yr = 2020 if State_num == 14
replace snap_init_yr = 2012 if State_num == 15 // Iowa
* replace snap_comp_yr = . if State_num == 15
replace snap_init_yr = 2009 if State_num == 16 // Kansas
replace snap_comp_yr = 2017 if State_num == 16
replace snap_init_yr = 2016 if State_num == 17 // Kentucky
* replace snap_init_yr = . if State_num == 17
replace snap_init_yr = 2017 if State_num == 18 // Louisiana
replace snap_comp_yr = 2020 if State_num == 18
replace snap_init_yr = 1999 if State_num == 19 // Maine
replace snap_comp_yr = 2002 if State_num == 19
replace snap_init_yr = 2017 if State_num == 20 // Maryland
replace snap_comp_yr = 2021 if State_num == 20
replace snap_init_yr = 2007 if State_num == 21 // Massachusetts
replace snap_comp_yr = 2010 if State_num == 21
replace snap_init_yr = 2006 if State_num == 22 // Michigan
replace snap_comp_yr = 2009 if State_num == 22
replace snap_init_yr = 2013 if State_num == 23 // Minnesota
* replace snap_comp_yr = . if State_num == 23
replace snap_init_yr = 2021 if State_num == 24 // Mississippi
* replace snap_comp_yr = . if State_num == 24
replace snap_init_yr = 2021 if State_num == 25 // Missouri
replace snap_comp_yr = 2025 if State_num == 25
replace snap_init_yr = 2007 if State_num == 26 // Montana
replace snap_comp_yr = 2012 if State_num == 26
replace snap_init_yr = 2014 if State_num == 27 // Nebraska
* replace snap_comp_yr = . if State_num == 27
replace snap_init_yr = 2012 if State_num == 28 // Nevada
* replace snap_comp_yr = . if State_num == 28
replace snap_init_yr = 1995 if State_num == 29 // New Hampshire
replace snap_comp_yr = 1998 if State_num == 29
replace snap_init_yr = 2009 if State_num == 30 // New Jersey
replace snap_comp_yr = 2013 if State_num == 30
replace snap_init_yr = 2011 if State_num == 31 // New Mexico
replace snap_comp_yr = 2014 if State_num == 31
replace snap_init_yr = 2021 if State_num == 32 // New York
* replace snap_comp_yr = . if State_num == 32
replace snap_init_yr = 1999 if State_num == 33 // North Carolina
replace snap_comp_yr = 2013 if State_num == 33
replace snap_init_yr = 2013 if State_num == 34 // North Dakota
replace snap_comp_yr = 2019 if State_num == 34
replace snap_init_yr = 2012 if State_num == 35 // Ohio
replace snap_comp_yr = 2018 if State_num == 35
* replace snap_init_yr = . if State_num == 36 // Oklahoma
* replace snap_comp_yr = . if State_num == 36
replace snap_init_yr = 2015 if State_num == 37 // Oregon
replace snap_comp_yr = 2020 if State_num == 37
replace snap_init_yr = 2008 if State_num == 38 // Pennsylvania
replace snap_comp_yr = 2020 if State_num == 38
replace snap_init_yr = 2013 if State_num == 39 // Rhode Island
replace snap_comp_yr = 2016 if State_num == 39
* replace snap_init_yr = . if State_num == 40 // South Carolina
* replace snap_comp_yr = . if State_num == 40
* replace snap_init_yr = . if State_num == 41 // South Dakota
* replace snap_comp_yr = . if State_num == 41
replace snap_init_yr = 2014 if State_num == 42 // Tennessee
replace snap_comp_yr = 2023 if State_num == 42
replace snap_init_yr = 1997 if State_num == 43 // Texas
replace snap_comp_yr = 2011 if State_num == 43
replace snap_init_yr = 2002 if State_num == 44 // Utah
replace snap_comp_yr = 2010 if State_num == 44
replace snap_init_yr = 2022 if State_num == 45 // Vermont
* replace snap_comp_yr = . if State_num == 45
replace snap_init_yr = 2012 if State_num == 46 // Virginia
replace snap_comp_yr = 2017 if State_num == 46
replace snap_init_yr = 2022 if State_num == 47 // Washington
* replace snap_comp_yr = . if State_num == 47
replace snap_init_yr = 2017 if State_num == 48 // West Virginia
replace snap_comp_yr = 2024 if State_num == 48
* replace snap_init_yr = . if State_num == 49 // Wisconsin
* replace snap_comp_yr = . if State_num == 49
replace snap_init_yr = 2021 if State_num == 50 // Wyoming
replace snap_comp_yr = 2023 if State_num == 50

* --- Create Binary Indicators ---
gen snap_initiated = (Year >= snap_init_yr) if !missing(snap_init_yr)
replace snap_initiated = 0 if missing(snap_initiated)
label var snap_initiated "1 if SNAP Modernization Attempted"

gen snap_completed = (Year >= snap_comp_yr) if !missing(snap_comp_yr)
replace snap_completed = 0 if missing(snap_completed)
label var snap_completed "1 if SNAP Modernization Actual"

di "Section 2: Create SNAP Modernization Variables completed."


* ============================================
* Section 3: Simple TWFE Regressions - Both Attempted and Completed
* ============================================
di "* Section 3: Running Simple Two-Way Fixed Effects Regressions"

* Set up results directory
local results_dir "${project_path}/Plots_Charts/SNAP Regression Outputs"
capture mkdir "`results_dir'"

* --- A. Attempted Modernization Effects ---
eststo part_attempted: reghdfe `participation' snap_initiated `controls', absorb(State_num Year) vce(cluster State_num)
esttab part_attempted using "`results_dir'/TWFE_Participation_Attempted.doc", replace ///
	title("Effect of Attempted SNAP Modernization on Participation") ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2_within, fmt(%9.0f %9.3f) labels("Observations" "Within R-sq."))

eststo costs_attempted: reghdfe `admin_costs' snap_initiated `controls', absorb(State_num Year) vce(cluster State_num)
esttab costs_attempted using "`results_dir'/TWFE_Admin_Costs_Attempted.doc", replace ///
	title("Effect of Attempted SNAP Modernization on Admin Costs") ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2_within, fmt(%9.0f %9.3f) labels("Observations" "Within R-sq."))

* --- B. Completed Modernization Effects ---
eststo part_completed: reghdfe `participation' snap_completed `controls', absorb(State_num Year) vce(cluster State_num)
esttab part_completed using "`results_dir'/TWFE_Participation_Completed.doc", replace ///
	title("Effect of Completed SNAP Modernization on Participation") ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2_within, fmt(%9.0f %9.3f) labels("Observations" "Within R-sq."))

eststo costs_completed: reghdfe `admin_costs' snap_completed `controls', absorb(State_num Year) vce(cluster State_num)
esttab costs_completed using "`results_dir'/TWFE_Admin_Costs_Completed.doc", replace ///
	title("Effect of Completed SNAP Modernization on Admin Costs") ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2_within, fmt(%9.0f %9.3f) labels("Observations" "Within R-sq."))

di "Section 3: Simple TWFE Regressions completed. Results saved to `results_dir'"


* ============================================
* Section 4: Traditional Event Study Analysis (TWFE) - Both Attempted and Completed
* ============================================
di "* Section 4: Running Traditional Event Study Analysis"

* --- Part A: Event Study for ATTEMPTED Modernization ---
gen time_to_event_init = Year - snap_init_yr if !missing(snap_init_yr)
gen E_init_m5 = (time_to_event_init <= -5) & !missing(time_to_event_init)
forval i = 4(-1)2 {
	gen E_init_m`i' = (time_to_event_init == -`i') & !missing(time_to_event_init)
}
gen E_init_0 = (time_to_event_init == 0) & !missing(time_to_event_init)
forval i = 1/4 {
	gen E_init_p`i' = (time_to_event_init == `i') & !missing(time_to_event_init)
}
gen E_init_p5 = (time_to_event_init >= 5) & !missing(time_to_event_init)
local event_dummies_init "E_init_m5 E_init_m4 E_init_m3 E_init_m2 E_init_0 E_init_p1 E_init_p2 E_init_p3 E_init_p4 E_init_p5"

eststo clear
eststo event_part_attempted: reghdfe `participation' `event_dummies_init' `controls' if !missing(time_to_event_init), absorb(State_num Year) vce(cluster State_num)
esttab event_part_attempted using "`results_dir'/Traditional_Event_Study_Participation_Attempted.doc", replace ///
	title("Traditional Event Study: Effect of Attempted Modernization on Participation") ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2_within, fmt(%9.0f %9.3f) labels("Observations" "Within R-sq."))

eststo event_costs_attempted: reghdfe `admin_costs' `event_dummies_init' `controls' if !missing(time_to_event_init), absorb(State_num Year) vce(cluster State_num)
esttab event_costs_attempted using "`results_dir'/Traditional_Event_Study_Admin_Costs_Attempted.doc", replace ///
	title("Traditional Event Study: Effect of Attempted Modernization on Admin Costs") ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2_within, fmt(%9.0f %9.3f) labels("Observations" "Within R-sq."))

* Plot for participation (attempted)
coefplot event_part_attempted, keep(`event_dummies_init') vertical omitted baselevels yline(0, lcolor(black)) ciopts(recast(rcap)) ///
	title("Traditional Event Study (Attempted): Effect on Participation") ytitle("Change in Participants") xtitle("Years Relative to Modernization Attempt") graphregion(color(white)) ///
	rename(E_init_m5 = -5 E_init_m4 = -4 E_init_m3 = -3 E_init_m2 = -2 E_init_0 = 0 E_init_p1 = 1 E_init_p2 = 2 E_init_p3 = 3 E_init_p4 = 4 E_init_p5 = 5) ///
	ylabel(, format(%12.0f))
graph export "`results_dir'/Event_Study_Traditional_Participation_Attempted.png", width(1000) replace

* Plot for admin costs (attempted)
coefplot event_costs_attempted, keep(`event_dummies_init') vertical omitted baselevels yline(0, lcolor(black)) ciopts(recast(rcap)) ///
	title("Traditional Event Study (Attempted): Effect on Admin Costs") ytitle("Change in Admin Costs") xtitle("Years Relative to Modernization Attempt") graphregion(color(white)) ///
	rename(E_init_m5 = -5 E_init_m4 = -4 E_init_m3 = -3 E_init_m2 = -2 E_init_0 = 0 E_init_p1 = 1 E_init_p2 = 2 E_init_p3 = 3 E_init_p4 = 4 E_init_p5 = 5) ///
	ylabel(, format(%12.0f))
graph export "`results_dir'/Event_Study_Traditional_Admin_Costs_Attempted.png", width(1000) replace

* --- Part B: Event Study for COMPLETED Modernization ---
gen time_to_event_comp = Year - snap_comp_yr if !missing(snap_comp_yr)
gen E_comp_m5 = (time_to_event_comp <= -5) & !missing(time_to_event_comp)
forval i = 4(-1)2 {
	gen E_comp_m`i' = (time_to_event_comp == -`i') & !missing(time_to_event_comp)
}
gen E_comp_0 = (time_to_event_comp == 0) & !missing(time_to_event_comp)
forval i = 1/4 {
	gen E_comp_p`i' = (time_to_event_comp == `i') & !missing(time_to_event_comp)
}
gen E_comp_p5 = (time_to_event_comp >= 5) & !missing(time_to_event_comp)
local event_dummies_comp "E_comp_m5 E_comp_m4 E_comp_m3 E_comp_m2 E_comp_0 E_comp_p1 E_comp_p2 E_comp_p3 E_comp_p4 E_comp_p5"

eststo clear
eststo event_part_completed: reghdfe `participation' `event_dummies_comp' `controls' if !missing(time_to_event_comp), absorb(State_num Year) vce(cluster State_num)
esttab event_part_completed using "`results_dir'/Traditional_Event_Study_Participation_Completed.doc", replace ///
	title("Traditional Event Study: Effect of Completed Modernization on Participation") ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2_within, fmt(%9.0f %9.3f) labels("Observations" "Within R-sq."))

eststo event_costs_completed: reghdfe `admin_costs' `event_dummies_comp' `controls' if !missing(time_to_event_comp), absorb(State_num Year) vce(cluster State_num)
esttab event_costs_completed using "`results_dir'/Traditional_Event_Study_Admin_Costs_Completed.doc", replace ///
	title("Traditional Event Study: Effect of Completed Modernization on Admin Costs") ///
	b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2_within, fmt(%9.0f %9.3f) labels("Observations" "Within R-sq."))

* Plot for participation (completed)
coefplot event_part_completed, keep(`event_dummies_comp') vertical omitted baselevels yline(0, lcolor(black)) ciopts(recast(rcap)) ///
	title("Traditional Event Study (Completed): Effect on Participation") ytitle("Change in Participants") xtitle("Years Relative to Modernization Completion") graphregion(color(white)) ///
	rename(E_comp_m5 = -5 E_comp_m4 = -4 E_comp_m3 = -3 E_comp_m2 = -2 E_comp_0 = 0 E_comp_p1 = 1 E_comp_p2 = 2 E_comp_p3 = 3 E_comp_p4 = 4 E_comp_p5 = 5) ///
	ylabel(, format(%12.0f))
graph export "`results_dir'/Event_Study_Traditional_Participation_Completed.png", width(1000) replace

* Plot for admin costs (completed)
coefplot event_costs_completed, keep(`event_dummies_comp') vertical omitted baselevels yline(0, lcolor(black)) ciopts(recast(rcap)) ///
	title("Traditional Event Study (Completed): Effect on Admin Costs") ytitle("Change in Admin Costs") xtitle("Years Relative to Modernization Completion") graphregion(color(white)) ///
	rename(E_comp_m5 = -5 E_comp_m4 = -4 E_comp_m3 = -3 E_comp_m2 = -2 E_comp_0 = 0 E_comp_p1 = 1 E_comp_p2 = 2 E_comp_p3 = 3 E_comp_p4 = 4 E_comp_p5 = 5) ///
	ylabel(, format(%12.0f))
graph export "`results_dir'/Event_Study_Traditional_Admin_Costs_Completed.png", width(1000) replace

di "Section 4: Traditional Event Study Analysis completed. Plots and tables saved to `results_dir'"


* ============================================
* Script Execution Complete
* ============================================
di "SNAP_Analysis_Regressions.do execution completed."
di "All results saved to: `results_dir'"
