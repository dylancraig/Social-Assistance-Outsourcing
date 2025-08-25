* ============================================
* Name: Dylan Craig
* Date: 12/30/2024
* Title: SNAP State Options
* Purpose: Import and preprocess SNAP Policy Database data for analysis
* ============================================

// ============================================
// 1. Set Global Paths and Initialize
// ============================================
* global project_path "C:/Users/dscra/OneDrive - University of Virginia/Social Assistance Outsourcing Project"
global raw_data_path "$project_path/Raw_Data/SNAP State Options/SNAPPolicyDatabase.xlsx"
global data_outputs_path "$project_path/Data Outputs/SNAP Policy Database/SNAP_Policy_Database.dta"

// ============================================
// 2. Import Excel Data
// ============================================
import excel "$raw_data_path", sheet("SNAP Policy Database") firstrow clear

// ============================================
// 3. Data Cleaning and Transformation
// ============================================
rename statename State
label variable State "State Name"
rename state_fips StateFIPS
label variable StateFIPS "State FIPS Code"
rename state_pc State_Abbrev
label variable State_Abbrev "State Postal Abbreviation"

gen Year = floor(yearmonth / 100)
label variable Year "Year"
gen Month = mod(yearmonth, 100)
label variable Month "Month"

drop yearmonth

label variable bbce "Broad-Based Categorical Eligibility"
label define bbce 0 "No" 1 "Yes"
label values bbce bbce

label variable bbce_asset "BBCE Asset Test Elimination"
label define bbce_asset -9 "No BBCE" 0 "Asset Limit Increased" 1 "Asset Limit Eliminated"
label values bbce_asset bbce_asset

label variable bbce_a_amt "BBCE Asset Limit (Thousands)"
label variable bbce_inclmt "BBCE Gross Income Limit (FPL %)"
label variable bbce_child "BBCE for Households with Children"
label variable bbce_elddisinclmt "BBCE for Senior/Disabled Income Limit"
label variable bbce_multiple "Multiple BBCE Guidelines"

label variable call_any "Statewide or Regional Call Centers"
label define call_any 0 "No Call Centers" 1 "Call Centers Available"
label values call_any call_any

label variable cap "Combined Application Project"
label define cap 0 "No" 1 "Yes"
label values cap cap

label variable certearn0103 "1–3 Month Recertification, Earners"
label variable certearn0406 "4–6 Month Recertification, Earners"
label variable certearn0712 "7–12 Month Recertification, Earners"
label variable certearn1399 "13+ Month Recertification, Earners"
label variable certearnavg "Average Recertification Period, Earners"
label variable certearnmed "Median Recertification Period, Earners"

label variable certeld0103 "1–3 Month Recertification, Seniors"
label variable certeld0406 "4–6 Month Recertification, Seniors"
label variable certeld0712 "7–12 Month Recertification, Seniors"
label variable certeld1399 "13+ Month Recertification, Seniors"
label variable certeldavg "Average Recertification Period, Seniors"
label variable certeldmed "Median Recertification Period, Seniors"

label variable certnonearn0103 "1–3 Month Recertification, Non-Earners"
label variable certnonearn0406 "4–6 Month Recertification, Non-Earners"
label variable certnonearn0712 "7–12 Month Recertification, Non-Earners"
label variable certnonearn1399 "13+ Month Recertification, Non-Earners"
label variable certnonearnavg "Average Recertification Period, Non-Earners"
label variable certnonearnmed "Median Recertification Period, Non-Earners"

label variable ebtissuance "Proportion SNAP Benefits via EBT"

label variable faceini "Waiver for Telephone Interview at Initial Certification"
label define faceini 0 "No Waiver" 1 "Waiver Granted"
label values faceini faceini

label variable facerec "Waiver for Telephone Interview at Recertification"
label define facerec 0 "No Waiver" 1 "Waiver Granted"
label values facerec facerec

label variable fingerprint "Fingerprinting Requirement"
label define fingerprint 0 "No" 1 "Statewide" 2 "Select Areas"
label values fingerprint fingerprint

label variable noncitadultfull "Eligibility for All Legal Noncitizen Adults"
label variable noncitadultpart "Eligibility for Some Legal Noncitizen Adults"
label variable noncitchildfull "Eligibility for All Legal Noncitizen Children"
label variable noncitchildpart "Eligibility for Some Legal Noncitizen Children"
label variable nonciteldfull "Eligibility for All Legal Noncitizen Seniors"
label variable nonciteldpart "Eligibility for Some Legal Noncitizen Seniors"

label variable oapp "Online SNAP Application Availability"
label define oapp 0 "No" 1 "Statewide" 2 "Select Areas"
label values oapp oapp

label variable outreach "Outreach Spending (Thousands)"

label variable reportsimple "Simplified Reporting for Earners"
label define reportsimple 0 "No" 1 "Yes"
label values reportsimple reportsimple

label variable transben "Transitional Benefits for TANF Leavers"
label define transben 0 "No" 1 "Yes"
label values transben transben

label variable vehexclall "Excludes All Vehicles from Asset Test"
label define vehexclall 0 "No" 1 "Yes"
label values vehexclall vehexclall

label variable vehexclamt "Higher Vehicle Value Exemption"
label define vehexclamt 0 "No" 1 "Yes"
label values vehexclamt vehexclamt

label variable vehexclone "Excludes One or More Vehicles"
label define vehexclone 0 "No" 1 "Yes"
label values vehexclone vehexclone

// ============================================
// 4. Save as .dta
// ============================================
** save "$data_outputs_path", replace

// ============================================
// 5. Clean Up
// ============================================
clear
display "SNAP Policy Database successfully imported, transformed, and saved as .dta format!"
