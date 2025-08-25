* ============================================
* Generate Graphs for SNAP Admin Spending Breakdown
* ============================================
* Author: Dylan Craig
* Date Created: 12/10/2024
* Date Updated: 05/15/2025
* Name: SNAP_Analysis_Admin_Spending_Shares_Graphs
* Purpose: Generate various graphs illustrating SNAP administrative spending shares and breakdowns.
* ============================================

* ============================================
* Section 1: Set Up - Load and Prepare Dataset
* ============================================
di "* Section 1: Setting up - Loading and Preparing Dataset"
* global project_path is assumed to be set by a master calling script
// global project_path "C:/Users/dscra/OneDrive - University of Virginia/Social Assistance Outsourcing Project"

* Load the SNAP dataset
use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear

* Convert `Year` to numeric if stored as a string
destring Year, replace
di "Section 1: Set Up - Load and Prepare Dataset completed."

* ============================================
* Section 2: Bar Chart - Administrative Costs Per Case Per Month by State
* ============================================
di "* Section 2: Generating Bar Charts for Admin Costs Per Case Per Month by State"

* Define the directory for saving the bar charts
local output_dir_per_case "${project_path}/Plots_Charts/SNAP Plots_Charts/Admin_Spending/Per_Case_Per_Month"
capture mkdir "`output_dir_per_case'" // Ensure directory exists

* Generate bar chart for 2008
graph bar Tot_Admn_Cost_Per_Case_Per_Mnth if Year == 2008, ///
    over(State_Abbrev, sort(1) descending label(angle(45) labsize(vsmall))) /// // Smaller label size
    bar(1, color(blue)) ///
    title("Administrative Costs Per Case Per Month by State (2008)") ///
    ytitle("Admin Costs Per Case Per Month ($)") ///
    graphregion(color(white)) ///
    bargap(20) // Adjust spacing between bars
graph export "`output_dir_per_case'/AdminCosts_Per_Case_Per_Month_BarChart_2008.png", replace

* Generate bar chart for 2012
graph bar Tot_Admn_Cost_Per_Case_Per_Mnth if Year == 2012, ///
    over(State_Abbrev, sort(1) descending label(angle(45) labsize(vsmall))) /// // Smaller label size
    bar(1, color(blue)) ///
    title("Administrative Costs Per Case Per Month by State (2012)") ///
    ytitle("Admin Costs Per Case Per Month ($)") ///
    graphregion(color(white)) ///
    bargap(20) // Adjust spacing between bars
graph export "`output_dir_per_case'/AdminCosts_Per_Case_Per_Month_BarChart_2012.png", replace

* Generate bar chart for 2019
graph bar Tot_Admn_Cost_Per_Case_Per_Mnth if Year == 2019, ///
    over(State_Abbrev, sort(1) descending label(angle(45) labsize(vsmall))) /// // Smaller label size
    bar(1, color(blue)) ///
    title("Administrative Costs Per Case Per Month by State (2019)") ///
    ytitle("Admin Costs Per Case Per Month ($)") ///
    graphregion(color(white)) ///
    bargap(20) // Adjust spacing between bars
graph export "`output_dir_per_case'/AdminCosts_Per_Case_Per_Month_BarChart_2019.png", replace
di "Section 2: Bar Charts for Admin Costs Per Case Per Month by State completed."

* ============================================
* Section 3: Bar Chart - Federal Share of Admin Costs by Percentage, By State, By Year
* ============================================
di "* Section 3: Generating Bar Charts for Federal Share of Admin Costs by Percentage, By State, By Year"

* Define the output directory
local outdir_fed_shr_typ_st "${project_path}/Plots_Charts/SNAP Plots_Charts/Admin_Spending/Federal_Share_By_Type_By_State"
capture mkdir "`outdir_fed_shr_typ_st'" // Ensure directory exists

* Loop for the year 2008
use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
destring Year, replace
keep if Year == 2008
levelsof State, local(states_2008)
* generate rank = _n // This variable 'rank' is not used below, kept as per original

foreach state of local states_2008 {
    di "Processing Federal Share Percentage Chart for `state', Year 2008"
    preserve
    use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
    destring Year, replace
    keep if Year == 2008
    keep if State == "`state'"

    if _N == 0 {
        restore
        continue
    }

    replace Fed_Share_Admn_Cost = . if Fed_Share_Admn_Cost <= 0

    gen cert_cost_pct = (Fed_Share_Cert_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
    gen iss_cost_pct = (Fed_Share_Iss_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
    gen fraud_control_pct = (Fed_Share_Fraud_Control_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
    gen adp_dev_pct = (Fed_Share_ADP_Dev_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
    gen adp_oper_pct = (Fed_Share_ADP_Oper_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .

    if cert_cost_pct == . & iss_cost_pct == . & fraud_control_pct == . & adp_dev_pct == . & adp_oper_pct == . {
        restore
        continue
    }

    graph bar cert_cost_pct iss_cost_pct fraud_control_pct adp_dev_pct adp_oper_pct, ///
        over(State, label(angle(45))) ///
        bar(1, color(blue)) ///
        bargap(20) ///
        title("Federal Share of Admin Costs by Type - `state' (2008)") ///
        ytitle("Cost Share (%)") ///
        graphregion(color(white)) ///
        legend(order(1 "Certification Costs" 2 "Issuance Costs" ///
                        3 "Fraud Control Costs" 4 "ADP Development Costs" 5 "ADP Operations Costs")) ///
        ylab(0(20)100, format(%9.0f)) ///
        blabel(bar)
    graph export "`outdir_fed_shr_typ_st'/`state'_2008_Admin_Costs_Percentage.png", replace
    restore
}

* Repeat for the year 2012
use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
destring Year, replace
keep if Year == 2012
levelsof State, local(states_2012)
foreach state of local states_2012 {
    di "Processing Federal Share Percentage Chart for `state', Year 2012"
    preserve
    use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
    destring Year, replace
    keep if Year == 2012
    keep if State == "`state'"

    if _N == 0 {
        restore
        continue
    }
    replace Fed_Share_Admn_Cost = . if Fed_Share_Admn_Cost <= 0

    gen cert_cost_pct = (Fed_Share_Cert_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
    gen iss_cost_pct = (Fed_Share_Iss_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
    gen fraud_control_pct = (Fed_Share_Fraud_Control_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
    gen adp_dev_pct = (Fed_Share_ADP_Dev_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
    gen adp_oper_pct = (Fed_Share_ADP_Oper_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .

    if cert_cost_pct == . & iss_cost_pct == . & fraud_control_pct == . & adp_dev_pct == . & adp_oper_pct == . {
        restore
        continue
    }

    graph bar cert_cost_pct iss_cost_pct fraud_control_pct adp_dev_pct adp_oper_pct, ///
        over(State, label(angle(45))) ///
        bar(1, color(blue)) ///
        bargap(20) ///
        title("Federal Share of Admin Costs by Type - `state' (2012)") ///
        ytitle("Cost Share (%)") ///
        graphregion(color(white)) ///
        legend(order(1 "Certification Costs" 2 "Issuance Costs" ///
                        3 "Fraud Control Costs" 4 "ADP Development Costs" 5 "ADP Operations Costs")) ///
        ylab(0(20)100, format(%9.0f)) ///
        blabel(bar)
    graph export "`outdir_fed_shr_typ_st'/`state'_2012_Admin_Costs_Percentage.png", replace
    restore
}

* Repeat for the year 2019
use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
destring Year, replace
keep if Year == 2019
levelsof State, local(states_2019)
foreach state of local states_2019 {
    di "Processing Federal Share Percentage Chart for `state', Year 2019"
    preserve
    use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
    destring Year, replace
    keep if Year == 2019
    keep if State == "`state'"

    if _N == 0 {
        restore
        continue
    }
    replace Fed_Share_Admn_Cost = . if Fed_Share_Admn_Cost <= 0

    gen cert_cost_pct = (Fed_Share_Cert_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
    gen iss_cost_pct = (Fed_Share_Iss_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
    gen fraud_control_pct = (Fed_Share_Fraud_Control_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
    gen adp_dev_pct = (Fed_Share_ADP_Dev_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
    gen adp_oper_pct = (Fed_Share_ADP_Oper_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .

    if cert_cost_pct == . & iss_cost_pct == . & fraud_control_pct == . & adp_dev_pct == . & adp_oper_pct == . {
        restore
        continue
    }

    graph bar cert_cost_pct iss_cost_pct fraud_control_pct adp_dev_pct adp_oper_pct, ///
        over(State, label(angle(45))) ///
        bar(1, color(blue)) ///
        bargap(20) ///
        title("Federal Share of Admin Costs by Type - `state' (2019)") ///
        ytitle("Cost Share (%)") ///
        graphregion(color(white)) ///
        legend(order(1 "Certification Costs" 2 "Issuance Costs" ///
                        3 "Fraud Control Costs" 4 "ADP Development Costs" 5 "ADP Operations Costs")) ///
        ylab(0(20)100, format(%9.0f)) ///
        blabel(bar)
    graph export "`outdir_fed_shr_typ_st'/`state'_2019_Admin_Costs_Percentage.png", replace
    restore
}
di "Section 3: Bar Charts for Federal Share of Admin Costs by Percentage, By State, By Year completed."

* ============================================
* Section 4: Stacked Bar Chart - Federal Share of Admin Costs by Percentage (All States)
* ============================================
di "* Section 4: Generating Stacked Bar Charts for Federal Share of Admin Costs by Percentage (All States)"

local output_dir_fed_share_summary "${project_path}/Plots_Charts/SNAP Plots_Charts/Admin_Spending/Federal_Share_By_Type_Summary"
capture mkdir "`output_dir_fed_share_summary'" // Ensure directory exists

* Section 4A: Chart for Year 2008
use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
destring Year, replace
keep if Year == 2008
replace Fed_Share_Admn_Cost = . if Fed_Share_Admn_Cost <= 0
gen cert_cost_pct_2008 = (Fed_Share_Cert_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
gen iss_cost_pct_2008 = (Fed_Share_Iss_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
gen fraud_control_pct_2008 = (Fed_Share_Fraud_Control_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
gen adp_dev_pct_2008 = (Fed_Share_ADP_Dev_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
gen adp_oper_pct_2008 = (Fed_Share_ADP_Oper_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
gen misc_pct_2008 = 100 - (cert_cost_pct_2008 + iss_cost_pct_2008 + fraud_control_pct_2008 + adp_dev_pct_2008 + adp_oper_pct_2008) if Fed_Share_Admn_Cost != .
graph bar cert_cost_pct_2008 iss_cost_pct_2008 fraud_control_pct_2008 adp_dev_pct_2008 adp_oper_pct_2008 misc_pct_2008, ///
    stack over(State_Abbrev, sort(Fed_Share_Admn_Cost) label(angle(90))) /// Sort by Total Federal Admin Costs
    title("Federal Share of Admin Costs by Type - 2008") ///
    ytitle("Cost Share (%)", margin(medium)) ///
    legend(order(1 "Certification Costs" 2 "Issuance Costs" 3 "Fraud Control Costs" ///
                4 "ADP Development Costs" 5 "ADP Operations Costs" 6 "Miscellaneous") ///
           position(bottom) rows(2)) ///
    bar(1, color(blue)) bar(2, color(red)) bar(3, color(green)) ///
    bar(4, color(yellow)) bar(5, color(purple)) bar(6, color(orange)) ///
    graphregion(color(white)) ylab(0(20)100, format(%9.0f))
graph export "`output_dir_fed_share_summary'/AdminCosts_Shares_AllStates_2008.png", replace

* Section 4B: Chart for Year 2012
use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
destring Year, replace
keep if Year == 2012
replace Fed_Share_Admn_Cost = . if Fed_Share_Admn_Cost <= 0
gen cert_cost_pct_2012 = (Fed_Share_Cert_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
gen iss_cost_pct_2012 = (Fed_Share_Iss_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
gen fraud_control_pct_2012 = (Fed_Share_Fraud_Control_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
gen adp_dev_pct_2012 = (Fed_Share_ADP_Dev_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
gen adp_oper_pct_2012 = (Fed_Share_ADP_Oper_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
gen misc_pct_2012 = 100 - (cert_cost_pct_2012 + iss_cost_pct_2012 + fraud_control_pct_2012 + adp_dev_pct_2012 + adp_oper_pct_2012) if Fed_Share_Admn_Cost != .
graph bar cert_cost_pct_2012 iss_cost_pct_2012 fraud_control_pct_2012 adp_dev_pct_2012 adp_oper_pct_2012 misc_pct_2012, ///
    stack over(State_Abbrev, sort(Fed_Share_Admn_Cost) label(angle(90))) ///
    title("Federal Share of Admin Costs by Type - 2012") ///
    ytitle("Cost Share (%)", margin(medium)) ///
    legend(order(1 "Certification Costs" 2 "Issuance Costs" 3 "Fraud Control Costs" ///
                4 "ADP Development Costs" 5 "ADP Operations Costs" 6 "Miscellaneous") ///
           position(bottom) rows(2)) ///
    bar(1, color(blue)) bar(2, color(red)) bar(3, color(green)) ///
    bar(4, color(yellow)) bar(5, color(purple)) bar(6, color(orange)) ///
    graphregion(color(white)) ylab(0(20)100, format(%9.0f))
graph export "`output_dir_fed_share_summary'/AdminCosts_Shares_AllStates_2012.png", replace

* Section 4C: Chart for Year 2019
use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
destring Year, replace
keep if Year == 2019
replace Fed_Share_Admn_Cost = . if Fed_Share_Admn_Cost <= 0
gen cert_cost_pct_2019 = (Fed_Share_Cert_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
gen iss_cost_pct_2019 = (Fed_Share_Iss_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
gen fraud_control_pct_2019 = (Fed_Share_Fraud_Control_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
gen adp_dev_pct_2019 = (Fed_Share_ADP_Dev_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
gen adp_oper_pct_2019 = (Fed_Share_ADP_Oper_Cost / Fed_Share_Admn_Cost) * 100 if Fed_Share_Admn_Cost != .
gen misc_pct_2019 = 100 - (cert_cost_pct_2019 + iss_cost_pct_2019 + fraud_control_pct_2019 + adp_dev_pct_2019 + adp_oper_pct_2019) if Fed_Share_Admn_Cost != .
graph bar cert_cost_pct_2019 iss_cost_pct_2019 fraud_control_pct_2019 adp_dev_pct_2019 adp_oper_pct_2019 misc_pct_2019, ///
    stack over(State_Abbrev, sort(Fed_Share_Admn_Cost) label(angle(90))) ///
    title("Federal Share of Admin Costs by Type - 2019") ///
    ytitle("Cost Share (%)", margin(medium)) ///
    legend(order(1 "Certification Costs" 2 "Issuance Costs" 3 "Fraud Control Costs" ///
                4 "ADP Development Costs" 5 "ADP Operations Costs" 6 "Miscellaneous") ///
           position(bottom) rows(2)) ///
    bar(1, color(blue)) bar(2, color(red)) bar(3, color(green)) ///
    bar(4, color(yellow)) bar(5, color(purple)) bar(6, color(orange)) ///
    graphregion(color(white)) ylab(0(20)100, format(%9.0f))
graph export "`output_dir_fed_share_summary'/AdminCosts_Shares_AllStates_2019.png", replace
di "Section 4: Stacked Bar Charts for Federal Share of Admin Costs by Percentage (All States) completed."

* ============================================
* Section 5: Stacked Bar Chart - Federal Share of Admin Costs by Absolute Value (All States)
* ============================================
di "* Section 5: Generating Stacked Bar Charts for Federal Share of Admin Costs by Absolute Value (All States)"
* Define the output directory (same as previous section for these summary charts)
* local output_dir_fed_share_summary "${project_path}/Plots_Charts/SNAP Plots_Charts/Admin_Spending/Federal_Share_By_Type_Summary" // Already defined and created

* Section 5A: Chart for Year 2008
use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
destring Year, replace
keep if Year == 2008
keep if State_Abbrev != "US" // Drop the US row
replace Fed_Share_Admn_Cost = . if Fed_Share_Admn_Cost <= 0
gen misc_cost = Fed_Share_Admn_Cost - (Fed_Share_Cert_Cost + Fed_Share_Iss_Cost + Fed_Share_Fraud_Control_Cost + Fed_Share_ADP_Dev_Cost + Fed_Share_ADP_Oper_Cost) if Fed_Share_Admn_Cost != .
graph bar Fed_Share_Cert_Cost Fed_Share_Iss_Cost Fed_Share_Fraud_Control_Cost Fed_Share_ADP_Dev_Cost Fed_Share_ADP_Oper_Cost misc_cost, ///
    stack over(State_Abbrev, sort(Fed_Share_Admn_Cost) label(angle(90))) ///
    title("Federal Share of Admin Costs by Type (Absolute Values) - 2008") ///
    ytitle("Cost ($)", margin(medium)) ///
    legend(order(1 "Certification Costs" 2 "Issuance Costs" 3 "Fraud Control Costs" ///
                4 "ADP Development Costs" 5 "ADP Operations Costs" 6 "Miscellaneous") ///
           position(bottom) rows(2)) ///
    bar(1, color(blue)) bar(2, color(red)) bar(3, color(green)) ///
    bar(4, color(yellow)) bar(5, color(purple)) bar(6, color(orange)) ///
    graphregion(color(white)) ylab(0(100000000)1000000000, format(%9.0f))
graph export "`output_dir_fed_share_summary'/AdminCosts_Absolute_AllStates_2008.png", replace

* Section 5B: Chart for Year 2012
use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
destring Year, replace
keep if Year == 2012
keep if State_Abbrev != "US" // Drop the US row
replace Fed_Share_Admn_Cost = . if Fed_Share_Admn_Cost <= 0
gen misc_cost = Fed_Share_Admn_Cost - (Fed_Share_Cert_Cost + Fed_Share_Iss_Cost + Fed_Share_Fraud_Control_Cost + Fed_Share_ADP_Dev_Cost + Fed_Share_ADP_Oper_Cost) if Fed_Share_Admn_Cost != .
graph bar Fed_Share_Cert_Cost Fed_Share_Iss_Cost Fed_Share_Fraud_Control_Cost Fed_Share_ADP_Dev_Cost Fed_Share_ADP_Oper_Cost misc_cost, ///
    stack over(State_Abbrev, sort(Fed_Share_Admn_Cost) label(angle(90))) ///
    title("Federal Share of Admin Costs by Type (Absolute Values) - 2012") ///
    ytitle("Cost ($)", margin(medium)) ///
    legend(order(1 "Certification Costs" 2 "Issuance Costs" 3 "Fraud Control Costs" ///
                4 "ADP Development Costs" 5 "ADP Operations Costs" 6 "Miscellaneous") ///
           position(bottom) rows(2)) ///
    bar(1, color(blue)) bar(2, color(red)) bar(3, color(green)) ///
    bar(4, color(yellow)) bar(5, color(purple)) bar(6, color(orange)) ///
    graphregion(color(white)) ylab(0(100000000)1000000000, format(%9.0f))
graph export "`output_dir_fed_share_summary'/AdminCosts_Absolute_AllStates_2012.png", replace

* Section 5C: Chart for Year 2019
use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
destring Year, replace
keep if Year == 2019
keep if State_Abbrev != "US" // Drop the US row
replace Fed_Share_Admn_Cost = . if Fed_Share_Admn_Cost <= 0
gen misc_cost = Fed_Share_Admn_Cost - (Fed_Share_Cert_Cost + Fed_Share_Iss_Cost + Fed_Share_Fraud_Control_Cost + Fed_Share_ADP_Dev_Cost + Fed_Share_ADP_Oper_Cost) if Fed_Share_Admn_Cost != .
graph bar Fed_Share_Cert_Cost Fed_Share_Iss_Cost Fed_Share_Fraud_Control_Cost Fed_Share_ADP_Dev_Cost Fed_Share_ADP_Oper_Cost misc_cost, ///
    stack over(State_Abbrev, sort(Fed_Share_Admn_Cost) label(angle(90))) ///
    title("Federal Share of Admin Costs by Type (Absolute Values) - 2019") ///
    ytitle("Cost ($)", margin(medium)) ///
    legend(order(1 "Certification Costs" 2 "Issuance Costs" 3 "Fraud Control Costs" ///
                4 "ADP Development Costs" 5 "ADP Operations Costs" 6 "Miscellaneous") ///
           position(bottom) rows(2)) ///
    bar(1, color(blue)) bar(2, color(red)) bar(3, color(green)) ///
    bar(4, color(yellow)) bar(5, color(purple)) bar(6, color(orange)) ///
    graphregion(color(white)) ylab(0(100000000)1000000000, format(%9.0f))
graph export "`output_dir_fed_share_summary'/AdminCosts_Absolute_AllStates_2019.png", replace
di "Section 5: Stacked Bar Charts for Federal Share of Admin Costs by Absolute Value (All States) completed."

* ============================================
* Section 6: Stacked Bar Chart - Federal Share of Admin Costs Per Case Per Month by Type (All States)
* ============================================
di "* Section 6: Generating Stacked Bar Charts for Federal Share of Admin Costs Per Case Per Month by Type (All States)"

local output_dir_fed_share_per_case "${project_path}/Plots_Charts/SNAP Plots_Charts/Admin_Spending/Federal_Share_Per_Case_By_Type"
capture mkdir "`output_dir_fed_share_per_case'" // Ensure directory exists

* Section 6A: Chart for Year 2008
use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
destring Year, replace
keep if Year == 2008
keep if State_Abbrev != "US" & State_Abbrev != "GU" & State_Abbrev != "VI" & State_Abbrev != "PR"
gen Cert_Cost_Per_Case_Mnth = round((Fed_Share_Cert_Cost / 12) / Part_HH_Mnthly_Avg, 0.01)
gen Iss_Cost_Per_Case_Mnth = round((Fed_Share_Iss_Cost / 12) / Part_HH_Mnthly_Avg, 0.01)
gen Fraud_Cost_Per_Case_Mnth = round((Fed_Share_Fraud_Control_Cost / 12) / Part_HH_Mnthly_Avg, 0.01)
gen ADP_Dev_Cost_Per_Case_Mnth = round((Fed_Share_ADP_Dev_Cost / 12) / Part_HH_Mnthly_Avg, 0.01)
gen ADP_Oper_Cost_Per_Case_Mnth = round((Fed_Share_ADP_Oper_Cost / 12) / Part_HH_Mnthly_Avg, 0.01)
gen Misc_Cost_Per_Case_Mnth = Fed_Admn_Cost_Per_Case_Per_Mnth - ///
                                (Cert_Cost_Per_Case_Mnth + Iss_Cost_Per_Case_Mnth + ///
                                 Fraud_Cost_Per_Case_Mnth + ADP_Dev_Cost_Per_Case_Mnth + ///
                                 ADP_Oper_Cost_Per_Case_Mnth)
replace Misc_Cost_Per_Case_Mnth = round(Misc_Cost_Per_Case_Mnth, 0.01)
sort Fed_Admn_Cost_Per_Case_Per_Mnth
graph bar Cert_Cost_Per_Case_Mnth Iss_Cost_Per_Case_Mnth Fraud_Cost_Per_Case_Mnth ADP_Dev_Cost_Per_Case_Mnth ADP_Oper_Cost_Per_Case_Mnth Misc_Cost_Per_Case_Mnth, ///
    stack over(State_Abbrev, sort(Fed_Admn_Cost_Per_Case_Per_Mnth) label(angle(90))) ///
    title("Federal Share of Admin Costs Per Case Per Month by Type - 2008") ///
    ytitle("Cost ($)", margin(medium)) ///
    legend(order(1 "Certification Costs" 2 "Issuance Costs" 3 "Fraud Control Costs" ///
                4 "ADP Development Costs" 5 "ADP Operations Costs" 6 "Miscellaneous") ///
           position(bottom) rows(2)) ///
    bar(1, color(blue)) bar(2, color(red)) bar(3, color(green)) ///
    bar(4, color(yellow)) bar(5, color(purple)) bar(6, color(orange)) ///
    graphregion(color(white)) ylab(0(10)100, format(%9.2f))
graph export "`output_dir_fed_share_per_case'/AdminCosts_PerCase_AllStates_2008.png", replace

* Section 6B: Chart for Year 2012
use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
destring Year, replace
keep if Year == 2012
keep if State_Abbrev != "US" & State_Abbrev != "GU" & State_Abbrev != "VI" & State_Abbrev != "PR"
gen Cert_Cost_Per_Case_Mnth = round((Fed_Share_Cert_Cost / 12) / Part_HH_Mnthly_Avg, 0.01)
gen Iss_Cost_Per_Case_Mnth = round((Fed_Share_Iss_Cost / 12) / Part_HH_Mnthly_Avg, 0.01)
gen Fraud_Cost_Per_Case_Mnth = round((Fed_Share_Fraud_Control_Cost / 12) / Part_HH_Mnthly_Avg, 0.01)
gen ADP_Dev_Cost_Per_Case_Mnth = round((Fed_Share_ADP_Dev_Cost / 12) / Part_HH_Mnthly_Avg, 0.01)
gen ADP_Oper_Cost_Per_Case_Mnth = round((Fed_Share_ADP_Oper_Cost / 12) / Part_HH_Mnthly_Avg, 0.01)
gen Misc_Cost_Per_Case_Mnth = Fed_Admn_Cost_Per_Case_Per_Mnth - ///
                                (Cert_Cost_Per_Case_Mnth + Iss_Cost_Per_Case_Mnth + ///
                                 Fraud_Cost_Per_Case_Mnth + ADP_Dev_Cost_Per_Case_Mnth + ///
                                 ADP_Oper_Cost_Per_Case_Mnth)
replace Misc_Cost_Per_Case_Mnth = round(Misc_Cost_Per_Case_Mnth, 0.01)
sort Fed_Admn_Cost_Per_Case_Per_Mnth
graph bar Cert_Cost_Per_Case_Mnth Iss_Cost_Per_Case_Mnth Fraud_Cost_Per_Case_Mnth ADP_Dev_Cost_Per_Case_Mnth ADP_Oper_Cost_Per_Case_Mnth Misc_Cost_Per_Case_Mnth, ///
    stack over(State_Abbrev, sort(Fed_Admn_Cost_Per_Case_Per_Mnth) label(angle(90))) ///
    title("Federal Share of Admin Costs Per Case Per Month by Type - 2012") ///
    ytitle("Cost ($)", margin(medium)) ///
    legend(order(1 "Certification Costs" 2 "Issuance Costs" 3 "Fraud Control Costs" ///
                4 "ADP Development Costs" 5 "ADP Operations Costs" 6 "Miscellaneous") ///
           position(bottom) rows(2)) ///
    bar(1, color(blue)) bar(2, color(red)) bar(3, color(green)) ///
    bar(4, color(yellow)) bar(5, color(purple)) bar(6, color(orange)) ///
    graphregion(color(white)) ylab(0(10)100, format(%9.2f))
graph export "`output_dir_fed_share_per_case'/AdminCosts_PerCase_AllStates_2012.png", replace

* Section 6C: Chart for Year 2019
use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
destring Year, replace
keep if Year == 2019
keep if State_Abbrev != "US" & State_Abbrev != "GU" & State_Abbrev != "VI" & State_Abbrev != "PR"
gen Cert_Cost_Per_Case_Mnth = round((Fed_Share_Cert_Cost / 12) / Part_HH_Mnthly_Avg, 0.01)
gen Iss_Cost_Per_Case_Mnth = round((Fed_Share_Iss_Cost / 12) / Part_HH_Mnthly_Avg, 0.01)
gen Fraud_Cost_Per_Case_Mnth = round((Fed_Share_Fraud_Control_Cost / 12) / Part_HH_Mnthly_Avg, 0.01)
gen ADP_Dev_Cost_Per_Case_Mnth = round((Fed_Share_ADP_Dev_Cost / 12) / Part_HH_Mnthly_Avg, 0.01)
gen ADP_Oper_Cost_Per_Case_Mnth = round((Fed_Share_ADP_Oper_Cost / 12) / Part_HH_Mnthly_Avg, 0.01)
gen Misc_Cost_Per_Case_Mnth = Fed_Admn_Cost_Per_Case_Per_Mnth - ///
                                (Cert_Cost_Per_Case_Mnth + Iss_Cost_Per_Case_Mnth + ///
                                 Fraud_Cost_Per_Case_Mnth + ADP_Dev_Cost_Per_Case_Mnth + ///
                                 ADP_Oper_Cost_Per_Case_Mnth)
replace Misc_Cost_Per_Case_Mnth = round(Misc_Cost_Per_Case_Mnth, 0.01)
sort Fed_Admn_Cost_Per_Case_Per_Mnth
graph bar Cert_Cost_Per_Case_Mnth Iss_Cost_Per_Case_Mnth Fraud_Cost_Per_Case_Mnth ADP_Dev_Cost_Per_Case_Mnth ADP_Oper_Cost_Per_Case_Mnth Misc_Cost_Per_Case_Mnth, ///
    stack over(State_Abbrev, sort(Fed_Admn_Cost_Per_Case_Per_Mnth) label(angle(90))) ///
    title("Federal Share of Admin Costs Per Case Per Month by Type - 2019") ///
    ytitle("Cost ($)", margin(medium)) ///
    legend(order(1 "Certification Costs" 2 "Issuance Costs" 3 "Fraud Control Costs" ///
                4 "ADP Development Costs" 5 "ADP Operations Costs" 6 "Miscellaneous") ///
           position(bottom) rows(2)) ///
    bar(1, color(blue)) bar(2, color(red)) bar(3, color(green)) ///
    bar(4, color(yellow)) bar(5, color(purple)) bar(6, color(orange)) ///
    graphregion(color(white)) ylab(0(10)100, format(%9.2f))
graph export "`output_dir_fed_share_per_case'/AdminCosts_PerCase_AllStates_2019.png", replace
di "Section 6: Stacked Bar Charts for Federal Share of Admin Costs Per Case Per Month by Type (All States) completed."

* ============================================
* Section 7: List of States with Significant Non-50/50 Admin Cost Splits
* ============================================
di "* Section 7: Identifying States with Significant Non-50/50 Admin Cost Splits"

use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
destring Year, replace // Ensure Year is numeric

drop if missing(State_Share_Admn_Cost, Fed_Share_Admn_Cost, Tot_Admn_Cost)

gen state_share_pct = (State_Share_Admn_Cost / Tot_Admn_Cost) * 100
gen fed_share_pct = (Fed_Share_Admn_Cost / Tot_Admn_Cost) * 100

gen state_deviation = abs(state_share_pct - 50)
gen fed_deviation = abs(fed_share_pct - 50)

gen flag_deviation = state_deviation > 5 | fed_deviation > 5

levelsof State if flag_deviation, local(flagged_states)

// Display the flagged states in a way that avoids the error
di "States with admin cost shares deviating >5pp from 50/50:"
foreach state of local flagged_states {
    di "  `state'" // Displaying each state on a new line, indented
}

// The commented-out list below was in the original script, retained for reference if needed.
// // Arizona, Connecticut, Delaware, District of Columbia, Florida, Georgia, Guam, Hawaii,
// // Missouri, New Hampshire, New Mexico, New York, Oklahoma, South Dakota, Washington, West Virginia, Wyoming
di "Section 7: List of States with Significant Non-50/50 Admin Cost Splits identified."

* ============================================
* Section 8: Generate Time-Series Graphs for Federal and State Admin Cost Shares
* ============================================
di "* Section 8: Generating Time-Series Graphs for Federal and State Admin Cost Shares"

local output_dir_fed_state_share "${project_path}/Plots_Charts/SNAP Plots_Charts/Admin_Spending/Federal_Vs_State_Share"
capture mkdir "`output_dir_fed_state_share'" // Ensure directory exists

use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear
destring Year, replace

drop if missing(State_Share_Admn_Cost, Fed_Share_Admn_Cost, Tot_Admn_Cost)

gen state_share_pct_ts = (State_Share_Admn_Cost / Tot_Admn_Cost) * 100
gen fed_share_pct_ts = (Fed_Share_Admn_Cost / Tot_Admn_Cost) * 100

levelsof State, local(states_all_ts)
foreach state of local states_all_ts {
    di "Generating Admin Cost Shares Time-Series for state: `state'"
    preserve
    keep if State == "`state'"
    sort Year

    twoway (line state_share_pct_ts Year, lcolor(blue) lwidth(medium) lpattern(solid)) ///
            (line fed_share_pct_ts Year, lcolor(red) lwidth(medium) lpattern(dash)) ///
            , title("Admin Cost Shares Over Time: `state'") ///
              ytitle("Share of Total Admin Cost (%)") ///
              xtitle("Year") ///
              legend(order(1 "State Share" 2 "Federal Share")) ///
              graphregion(color(white)) ///
              yline(50, lcolor(black) lpattern(shortdash)) ///
              ylab(35(5)65)
    graph export "`output_dir_fed_state_share'/AdminCostShares_OverTime_`state'.png", replace
    restore
}
di "Time-series graphs for all states have been saved in `output_dir_fed_state_share'."
di "Section 8: Time-Series Graphs for Federal and State Admin Cost Shares completed."

* ============================================
* Script Execution Complete
* ============================================
di "SNAP_Data_Analysis_Admin_Spending_Shares_Graphs.do execution completed."