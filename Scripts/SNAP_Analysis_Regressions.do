* ============================================
* Regression Analysis of SNAP State Admin Spending
* ============================================
* Author: Dylan Craig
* Date Created: 12/10/2024
* Date Updated: 05/14/2025
* Name: SNAP_Analysis_Regressions
* Purpose: Perform regression analysis of state administrative spending
* against various evaluation metrics.
* ============================================

* ============================================
* Section 1: Simple Regressions - Admin Costs and Evaluation Metrics
* ============================================
di "* Section 1: Running Simple Regressions (Admin Costs and Evaluation Metrics)"

* Convert State from string to numeric
encode State, gen(State_num)

* Define the panel structure
xtset State_num Year

* Variables of interest
local eval_metrics Over_Payments Under_Payments Payment_Error_Rate Program_Access_Index Case_Proc_Err_Rate App_Proc_Tmln

* Define directories
local results_dir "${project_path}/Plots_Charts/SNAP Plots_Charts/Admin_Spending/Regressions"
local sub_dir "`results_dir'/Regression_Results"

* Ensure directories exist
capture mkdir "`results_dir'"
capture mkdir "`sub_dir'"

* Loop through each evaluation metric
foreach metric in `eval_metrics' {
    di "Running regression: `metric' vs. Admin Cost per Case"

    * Fixed-effects regression
    xtreg `metric' Tot_Admn_Cost_Per_Case_Per_Mnth, fe robust

    * Generate a descriptive file name
    local file_name "`sub_dir'/`metric'_vs_Admin_Costs.doc"

    * Save regression results to a separate file
    outreg2 using "`file_name'", replace ctitle("`metric' vs. Admin Costs") ///
        addstat("Within R-squared", e(r2_w), "Between R-squared", e(r2_b), ///
                "Overall R-squared", e(r2_o), "F-test", e(F), "Prob > F", e(p))
}

di "Section 1: Simple Regressions - Admin Costs and Evaluation Metrics completed."
di "Regression results saved in `sub_dir'"

* ============================================
* Script Execution Complete
* ============================================
di "SNAP_Data_Analysis_Regressions.do execution completed."