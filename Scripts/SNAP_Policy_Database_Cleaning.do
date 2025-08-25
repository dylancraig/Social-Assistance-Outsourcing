* ============================================
* Author: Dylan Craig
* Date Created: 12/30/2024
* Data Updated: 5/14/2025
* Title: SNAP_Policy_Database_Cleaning
* Purpose: Import and preprocess SNAP Policy Database data for analysis
* ============================================

// ============================================
// 1. Set Global Paths and Initialize
// ============================================
** global project_path "C:/Users/dscra/OneDrive - University of Virginia/Social Assistance Outsourcing Project"
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

// Convert variables to string types
tostring State, replace
label variable State "State"
tostring StateFIPS, replace
label variable StateFIPS "State FIPS Code"
tostring Year, replace
label variable Year "Year"

* ============================================
* 4. Convert to Federal Fiscal Year (Oct-Sep)
* ============================================

gen fiscal_year = real(Year)
replace fiscal_year = fiscal_year - 1 if Month <= 9
tostring fiscal_year, replace

* Drop the existing Year variable before renaming
drop Year
rename fiscal_year Year

* ============================================
* 5. Collapse to Federal Fiscal Year-Level Data (Max Value)
* ============================================
collapse (max) bbce bbce_asset bbce_a_amt bbce_a_veh bbce_inclmt ///
    bbce_child bbce_elddisinclmt bbce_multiple call_any cap ///
    certearn0103 certearn0406 certearn0712 certearn1399 certearnavg certearnmed ///
    certeld0103 certeld0406 certeld0712 certeld1399 certeldavg certeldmed ///
    certnonearn0103 certnonearn0406 certnonearn0712 certnonearn1399 certnonearnavg certnonearnmed ///
    ebtissuance faceini facerec fingerprint noncitadultfull noncitadultpart ///
    noncitchildfull noncitchildpart nonciteldfull nonciteldpart oapp outreach ///
    reportsimple transben vehexclall vehexclamt vehexclone, by(StateFIPS State_Abbrev State Year)

// Variable labels
label variable State_Abbrev "State Postal Abbreviation"
label variable bbce "Broad-Based Categorical Eligibility"
label variable bbce_asset "BBCE Asset Test Elimination"
label variable bbce_a_amt "BBCE Asset Limit (Thousands)"
label variable bbce_inclmt "BBCE Gross Income Limit (FPL %)"
label variable bbce_child "BBCE for Households with Children"
label variable bbce_elddisinclmt "BBCE for Senior/Disabled Income Limit"
label variable bbce_multiple "Multiple BBCE Guidelines"
label variable bbce_a_veh "BBCE Vehicle Exemption"
label variable call_any "Statewide or Regional Call Centers"
label variable cap "Combined Application Project"
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
label variable facerec "Waiver for Telephone Interview at Recertification"
label variable fingerprint "Fingerprinting Requirement"
label variable noncitadultfull "Eligibility for All Legal Noncitizen Adults"
label variable noncitadultpart "Eligibility for Some Legal Noncitizen Adults"
label variable noncitchildfull "Eligibility for All Legal Noncitizen Children"
label variable noncitchildpart "Eligibility for Some Legal Noncitizen Children"
label variable nonciteldfull "Eligibility for All Legal Noncitizen Seniors"
label variable nonciteldpart "Eligibility for Some Legal Noncitizen Seniors"
label variable oapp "Online SNAP Application Availability"
label variable outreach "Outreach Spending (Thousands)"
label variable reportsimple "Simplified Reporting for Earners"
label variable transben "Transitional Benefits for TANF Leavers"
label variable vehexclall "Excludes All Vehicles from Asset Test"
label variable vehexclamt "Higher Vehicle Value Exemption"
label variable vehexclone "Excludes One or More Vehicles"

// Value labels
label define bbce 0 "No" 1 "Yes"
label values bbce bbce

label define bbce_asset -9 "No BBCE" 0 "Asset Limit Increased" 1 "Asset Limit Eliminated"
label values bbce_asset bbce_asset

label define bbce_child -9 "No BBCE" 0 "Applies to All Households" 1 "Applies to Households with Children"
label values bbce_child bbce_child

label define bbce_elddisinclmt -9 "No BBCE" -8 "No Gross Income Test" -7 "200% FPL for All Senior/Disabled"
label values bbce_elddisinclmt bbce_elddisinclmt

label define bbce_multiple -9 "No BBCE" 0 "Single Set of Guidelines" 1 "Multiple Guidelines"
label values bbce_multiple bbce_multiple

label define call_any 0 "No Call Centers" 1 "Call Centers Available"
label values call_any call_any

label define cap 0 "No" 1 "Yes"
label values cap cap

label define faceini 0 "No Waiver" 1 "Waiver Granted"
label values faceini faceini

label define facerec 0 "No Waiver" 1 "Waiver Granted"
label values facerec facerec

label define fingerprint 0 "No" 1 "Statewide" 2 "Select Areas"
label values fingerprint fingerprint

label define noncitadultfull 0 "No" 1 "Yes"
label values noncitadultfull noncitadultfull

label define noncitadultpart 0 "No" 1 "Yes"
label values noncitadultpart noncitadultpart

label define noncitchildfull 0 "No" 1 "Yes"
label values noncitchildfull noncitchildfull

label define noncitchildpart 0 "No" 1 "Yes"
label values noncitchildpart noncitchildpart

label define nonciteldfull 0 "No" 1 "Yes"
label values nonciteldfull nonciteldfull

label define nonciteldpart 0 "No" 1 "Yes"
label values nonciteldpart nonciteldpart

label define oapp 0 "No" 1 "Statewide" 2 "Select Areas"
label values oapp oapp

label define reportsimple 0 "No" 1 "Yes"
label values reportsimple reportsimple

label define transben 0 "No" 1 "Yes"
label values transben transben

label define vehexclall 0 "No" 1 "Yes"
label values vehexclall vehexclall

label define vehexclamt 0 "No" 1 "Yes"
label values vehexclamt vehexclamt

label define vehexclone 0 "No" 1 "Yes"
label values vehexclone vehexclone

label define bbce_a_veh -9 "No BBCE" 1 "Exempts Fair Market Value" 2 "Excludes One Vehicle" 3 "Excludes All Vehicles"
label values bbce_a_veh bbce_a_veh

// ============================================
// 4. Save as .dta
// ============================================
destring Year, replace
destring StateFIPS, replace

save "$data_outputs_path", replace

// ============================================
// 5. Clean Up
// ============================================
clear
display "SNAP Policy Database successfully imported, transformed, and saved as .dta format!"
* ============================================
* Name: Dylan Craig
* Date: 12/30/2024
* Title: SNAP State Options
* Purpose: Import and preprocess SNAP Policy Database data for analysis
* ============================================

* ============================================
* 1. Set Global Paths and Initialize
* ============================================
// global project_path "C:/Users/dscra/OneDrive - University of Virginia/Social Assistance Outsourcing Project"
global raw_data_path "$project_path/Raw_Data/SNAP State Options/SNAPPolicyDatabase.xlsx"
global data_outputs_path "$project_path/Data Outputs/SNAP Policy Database/SNAP_Policy_Database.dta"

* ============================================
* 2. Import Excel Data
* ============================================
import excel "$raw_data_path", sheet("SNAP Policy Database") firstrow clear

* ============================================
* 3. Data Cleaning and Transformation (Initial)
* ============================================
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

* Convert variables to string types for manipulation
tostring State, replace
label variable State "State" // Re-labeling after tostring is good practice if type changes interpretation
tostring StateFIPS, replace
label variable StateFIPS "State FIPS Code" // Re-label
tostring Year, replace
label variable Year "Year" // Re-label

* ============================================
* 4. Convert to Federal Fiscal Year (Oct-Sep)
* ============================================
gen fiscal_year = real(Year) // Temporarily convert Year back to numeric for calculation
replace fiscal_year = fiscal_year - 1 if Month <= 9
tostring fiscal_year, replace // Convert new fiscal_year to string

* Drop the existing calendar Year variable before renaming
drop Year
rename fiscal_year Year
label variable Year "Federal Fiscal Year" // Update label for clarity

* ============================================
* 5. Collapse to Federal Fiscal Year-Level Data (Max Value)
* ============================================
collapse (max) bbce bbce_asset bbce_a_amt bbce_a_veh bbce_inclmt ///
    bbce_child bbce_elddisinclmt bbce_multiple call_any cap ///
    certearn0103 certearn0406 certearn0712 certearn1399 certearnavg certearnmed ///
    certeld0103 certeld0406 certeld0712 certeld1399 certeldavg certeldmed ///
    certnonearn0103 certnonearn0406 certnonearn0712 certnonearn1399 certnonearnavg certnonearnmed ///
    ebtissuance faceini facerec fingerprint noncitadultfull noncitadultpart ///
    noncitchildfull noncitchildpart nonciteldfull nonciteldpart oapp outreach ///
    reportsimple transben vehexclall vehexclamt vehexclone, ///
    by(StateFIPS State_Abbrev State Year)

* ============================================
* 6. Apply Variable and Value Labels Post-Collapse
* ============================================
* Variable labels (many are preserved by collapse, but good to ensure or re-apply if needed)
label variable State_Abbrev "State Postal Abbreviation" // Often preserved by `by()`
* label variable State "State Name" // Already a `by()` variable, label should persist
* label variable StateFIPS "State FIPS Code" // Already a `by()` variable, label should persist
* label variable Year "Federal Fiscal Year" // Already a `by()` variable, label should persist

label variable bbce "Broad-Based Categorical Eligibility (Max)"
label variable bbce_asset "BBCE Asset Test Elimination (Max)"
label variable bbce_a_amt "BBCE Asset Limit (Thousands) (Max)"
label variable bbce_inclmt "BBCE Gross Income Limit (FPL %) (Max)"
label variable bbce_child "BBCE for Households with Children (Max)"
label variable bbce_elddisinclmt "BBCE for Senior/Disabled Income Limit (Max)"
label variable bbce_multiple "Multiple BBCE Guidelines (Max)"
label variable bbce_a_veh "BBCE Vehicle Exemption (Max)"
label variable call_any "Statewide or Regional Call Centers (Max)"
label variable cap "Combined Application Project (Max)"
label variable certearn0103 "1–3 Month Recertification, Earners (Max)"
label variable certearn0406 "4–6 Month Recertification, Earners (Max)"
label variable certearn0712 "7–12 Month Recertification, Earners (Max)"
label variable certearn1399 "13+ Month Recertification, Earners (Max)"
label variable certearnavg "Average Recertification Period, Earners (Max)"
label variable certearnmed "Median Recertification Period, Earners (Max)"
label variable certeld0103 "1–3 Month Recertification, Seniors (Max)"
label variable certeld0406 "4–6 Month Recertification, Seniors (Max)"
label variable certeld0712 "7–12 Month Recertification, Seniors (Max)"
label variable certeld1399 "13+ Month Recertification, Seniors (Max)"
label variable certeldavg "Average Recertification Period, Seniors (Max)"
label variable certeldmed "Median Recertification Period, Seniors (Max)"
label variable certnonearn0103 "1–3 Month Recertification, Non-Earners (Max)"
label variable certnonearn0406 "4–6 Month Recertification, Non-Earners (Max)"
label variable certnonearn0712 "7–12 Month Recertification, Non-Earners (Max)"
label variable certnonearn1399 "13+ Month Recertification, Non-Earners (Max)"
label variable certnonearnavg "Average Recertification Period, Non-Earners (Max)"
label variable certnonearnmed "Median Recertification Period, Non-Earners (Max)"
label variable ebtissuance "Proportion SNAP Benefits via EBT (Max)"
label variable faceini "Waiver for Telephone Interview at Initial Certification (Max)"
label variable facerec "Waiver for Telephone Interview at Recertification (Max)"
label variable fingerprint "Fingerprinting Requirement (Max)"
label variable noncitadultfull "Eligibility for All Legal Noncitizen Adults (Max)"
label variable noncitadultpart "Eligibility for Some Legal Noncitizen Adults (Max)"
label variable noncitchildfull "Eligibility for All Legal Noncitizen Children (Max)"
label variable noncitchildpart "Eligibility for Some Legal Noncitizen Children (Max)"
label variable nonciteldfull "Eligibility for All Legal Noncitizen Seniors (Max)"
label variable nonciteldpart "Eligibility for Some Legal Noncitizen Seniors (Max)"
label variable oapp "Online SNAP Application Availability (Max)"
label variable outreach "Outreach Spending (Thousands) (Max)"
label variable reportsimple "Simplified Reporting for Earners (Max)"
label variable transben "Transitional Benefits for TANF Leavers (Max)"
label variable vehexclall "Excludes All Vehicles from Asset Test (Max)"
label variable vehexclamt "Higher Vehicle Value Exemption (Max)"
label variable vehexclone "Excludes One or More Vehicles (Max)"

* Value labels
label define bbce 0 "No" 1 "Yes"
label values bbce bbce

label define bbce_asset -9 "No BBCE" 0 "Asset Limit Increased" 1 "Asset Limit Eliminated"
label values bbce_asset bbce_asset

label define bbce_child -9 "No BBCE" 0 "Applies to All Households" 1 "Applies to Households with Children"
label values bbce_child bbce_child

label define bbce_elddisinclmt -9 "No BBCE" -8 "No Gross Income Test" -7 "200% FPL for All Senior/Disabled"
label values bbce_elddisinclmt bbce_elddisinclmt

label define bbce_multiple -9 "No BBCE" 0 "Single Set of Guidelines" 1 "Multiple Guidelines"
label values bbce_multiple bbce_multiple

label define call_any 0 "No Call Centers" 1 "Call Centers Available"
label values call_any call_any

label define cap 0 "No" 1 "Yes"
label values cap cap

label define faceini 0 "No Waiver" 1 "Waiver Granted"
label values faceini faceini

label define facerec 0 "No Waiver" 1 "Waiver Granted"
label values facerec facerec

label define fingerprint 0 "No" 1 "Statewide" 2 "Select Areas"
label values fingerprint fingerprint

label define noncitadultfull 0 "No" 1 "Yes"
label values noncitadultfull noncitadultfull

label define noncitadultpart 0 "No" 1 "Yes"
label values noncitadultpart noncitadultpart

label define noncitchildfull 0 "No" 1 "Yes"
label values noncitchildfull noncitchildfull

label define noncitchildpart 0 "No" 1 "Yes"
label values noncitchildpart noncitchildpart

label define nonciteldfull 0 "No" 1 "Yes"
label values nonciteldfull nonciteldfull

label define nonciteldpart 0 "No" 1 "Yes"
label values nonciteldpart nonciteldpart

label define oapp 0 "No" 1 "Statewide" 2 "Select Areas"
label values oapp oapp

label define reportsimple 0 "No" 1 "Yes"
label values reportsimple reportsimple

label define transben 0 "No" 1 "Yes"
label values transben transben

label define vehexclall 0 "No" 1 "Yes"
label values vehexclall vehexclall

label define vehexclamt 0 "No" 1 "Yes"
label values vehexclamt vehexclamt

label define vehexclone 0 "No" 1 "Yes"
label values vehexclone vehexclone

label define bbce_a_veh -9 "No BBCE" 1 "Exempts Fair Market Value" 2 "Excludes One Vehicle" 3 "Excludes All Vehicles"
label values bbce_a_veh bbce_a_veh

* ============================================
* 7. Finalize Data Types and Save
* ============================================
* Ensure `by()` variables for merge/analysis are numeric if appropriate
destring Year, replace
destring StateFIPS, replace

save "$data_outputs_path", replace

* ============================================
* 8. Clean Up
* ============================================
clear
display "SNAP Policy Database successfully imported, transformed, collapsed, and saved as .dta format!"