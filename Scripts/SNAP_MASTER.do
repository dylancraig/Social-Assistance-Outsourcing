* ============================================
* Master Do-File for Data Processing and Analysis
* ============================================
* Author: Dylan Craig
* Date Created: 11/25/2024
* Date Updated: 8/20/2025
* Name: SNAP_MASTER
* Purpose: Set global path and execute all scripts in order.
* ============================================

* ============================================
* 0. (Optional) Install Required Packages
* ============================================
/*
ssc install reghdfe
ssc install estout
ssc install coefplot
ssc install csdid
ssc install drdid
ssc install outreg2
ssc install moremata
*/

* ============================================
* 1. Set Global Path
* ============================================
global project_path "C:/Users/dscra/Box/Social Assistance Outsourcing Project"
di "Global project path set to: ${project_path}"

* Change this to your global path
//global project_path "C:/Insert/Your/Path/Here/Social Assistance Outsourcing Project"
// di "Global project path set to: ${project_path}"

* ============================================
* 2. QCEW Data Cleaning
* ============================================
di "Running QCEW_Data_Cleaning script..."
do "${project_path}/Scripts/QCEW_Data_Cleaning.do"
di "QCEW_Data_Cleaning completed."

* ============================================
* 3. ACS Median Rent Data Cleaning
* ============================================
di "Running ACS_Median_Rent_Cleaning script..."
do "${project_path}/Scripts/ACS_Median_Rent_Cleaning.do"
di "ACS_Median_Rent_Cleaning completed."

* ============================================
* 4. SNAP Policy Database Cleaning
* ============================================
di "Running SNAP_Policy_Database_Cleaning script..."
do "${project_path}/Scripts/SNAP_Policy_Database_Cleaning.do"
di "SNAP_Policy_Database_Cleaning completed."

* ============================================
* 5. BLS LAUS Annual Unemployment
* ============================================
di "Running BLS_LAUS_Ann_Unemployment script..."
do "${project_path}/Scripts/BLS_LAUS_Ann_Unemployment.do"
di "BLS_LAUS_Ann_Unemployment completed."

* ============================================
* 6. SNAP Data Cleaning
* ============================================
di "Running SNAP_Data_Cleaning script..."
do "${project_path}/Scripts/SNAP_Data_Cleaning.do"
di "SNAP_Data_Cleaning completed."

* ============================================
* 7. SNAP Data Analysis
* ============================================
di "Running SNAP Data Analysis scripts..."

di "Running SNAP_Analysis_Admin_Performance_Graphs..."
do "${project_path}/Scripts/SNAP_Analysis_Admin_Performance_Graphs.do"
di "SNAP_Analysis_Admin_Performance_Graphs completed."

di "Running SNAP_Analysis_Admin_Spending_Growth_Graphs..."
do "${project_path}/Scripts/SNAP_Analysis_Admin_Spending_Growth_Graphs.do"
di "SNAP_Analysis_Admin_Spending_Growth_Graphs completed."

di "Running SNAP_Analysis_Admin_Spending_Shares_Graphs..."
do "${project_path}/Scripts/SNAP_Analysis_Admin_Spending_Shares_Graphs.do"
di "SNAP_Analysis_Admin_Spending_Shares_Graphs completed."

di "Running SNAP_Analysis_Regressions..."
do "${project_path}/Scripts/SNAP_Analysis_Regressions.do"
di "SNAP_Analysis_Regressions completed."

di "All SNAP Data Analysis scripts completed."

* ============================================
* 7. SNAP Modernization Regressions
* ============================================
di "Running SNAP_Modernization_Regressions script..."
do "${project_path}/Scripts/SNAP_Modernization_Regressions.do"
di "SNAP_Modernization_Regressions completed."

* ============================================
* Script Execution Complete
* ============================================
di "All scripts executed successfully."
