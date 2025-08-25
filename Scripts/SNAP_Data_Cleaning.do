* ============================================
* Stata Script: Main SNAP Data Cleaning and Merging
* ============================================
* Author: Dylan Craig
* Date Created: 11/24/2024
* Date Updated: 05/14/2025
* Name: SNAP_Data_Cleaning
* Purpose: Clean and merge core SNAP data with QCEW, ACS, Participation, LAUS, and SNAP Policy datasets.
* ============================================

* ============================================
* Section 1: Define Input File Paths and Initialize
* ============================================
clear all
* global project_path is assumed to be set by a master calling script
// global project_path "C:/Users/dscra/OneDrive - University of Virginia/Social Assistance Outsourcing Project"

* Define paths to pre-existing input datasets
local policy_data_input_path "${project_path}/Data Outputs/SNAP Policy Database/SNAP_Policy_Database.dta"
local snap_participation_input_path "${project_path}/Data Outputs/SNAP Participation/SNAP Participation.dta"
local qcew_path "${project_path}/Data Outputs/QCEW State Wages/QCEW_State_Wages_Cleaned.dta"
local acs_rent_path "${project_path}/Data Outputs/ACS State Median Rent/ACS_State_Median_Rent_Cleaned.dta"
local snap_outsourcing_excel "${project_path}/Data Outputs/SNAP Dataset/SNAP Data_Outsourcing.xlsx"
local laus_path                "${project_path}/Data Outputs/BLS_LAUS/laus_state_unemp_annual_1995_2023.dta"

di "Using pre-existing SNAP Policy Database: `policy_data_input_path'"
di "Using pre-existing SNAP Participation data: `snap_participation_input_path'"
di "Section 1: Paths defined and workspace initialized."

* ============================================
* Section 2: Import and Clean Individual Sheets from SNAP Data_Outsourcing.xlsx
* ============================================
di "* Section 2: Importing and cleaning sheets from SNAP Data_Outsourcing.xlsx"

capture mkdir "${project_path}/Data Outputs/SNAP Dataset/"
cd "${project_path}/Data Outputs/SNAP Dataset"
di "* Changed directory to: ${project_path}/Data Outputs/SNAP Dataset"

local temp_participation_fn "temp_participation.dta"
local temp_fairhearings_fn "temp_fairhearings.dta"
local temp_recipient_fn "temp_recipient.dta"
local temp_fraudhearings_fn "temp_fraudhearings.dta"
local temp_administrativecost_fn "temp_administrativecost.dta"
local temp_errorrates_fn "temp_errorrates.dta"
local temp_pai_fn "temp_pai.dta"
local temp_proceduralerror_fn "temp_proceduralerror.dta"
local temp_apt_fn "temp_apt.dta"

import excel using "`snap_outsourcing_excel'", sheet("SAR Participation and Issuance") firstrow cellrange(A2) clear
foreach var of varlist _all {
    if !inlist("`var'", "State", "State FIPS", "Year") {
        destring `var', ignore("NA") replace force
    }
}
save "`temp_participation_fn'", replace

import excel using "`snap_outsourcing_excel'", sheet("SAR_Fair Hearings") firstrow cellrange(A2) clear
foreach var of varlist _all {
    if !inlist("`var'", "State", "State FIPS", "Year") {
        destring `var', ignore("NA") replace force
    }
}
save "`temp_fairhearings_fn'", replace

import excel using "`snap_outsourcing_excel'", sheet("SAR_Recipient") firstrow cellrange(A2) clear
foreach var of varlist _all {
    if !inlist("`var'", "State", "State FIPS", "Year") {
        destring `var', ignore("NA") replace force
    }
}
save "`temp_recipient_fn'", replace

import excel using "`snap_outsourcing_excel'", sheet("SAR_Fraud_Hearings") firstrow cellrange(A2) clear
foreach var of varlist _all {
    if !inlist("`var'", "State", "State FIPS", "Year") {
        destring `var', ignore("NA") replace force
    }
}
save "`temp_fraudhearings_fn'", replace

import excel using "`snap_outsourcing_excel'", sheet("SAR_Administrative_Cost") firstrow cellrange(A2) clear
foreach var of varlist _all {
    if !inlist("`var'", "State", "State FIPS", "Year") {
        destring `var', ignore("NA") replace force
    }
}
save "`temp_administrativecost_fn'", replace

import excel using "`snap_outsourcing_excel'", sheet("SNAP Error Rates") firstrow cellrange(A1) clear
foreach var of varlist _all {
    if !inlist("`var'", "State", "State FIPS", "Year") {
        destring `var', ignore("NA") replace force
    }
}
save "`temp_errorrates_fn'", replace

import excel using "`snap_outsourcing_excel'", sheet("SNAP PAI") firstrow cellrange(A1) clear
foreach var of varlist _all {
    if !inlist("`var'", "State", "State FIPS", "Year") {
        destring `var', ignore("NA") replace force
    }
}
save "`temp_pai_fn'", replace

import excel using "`snap_outsourcing_excel'", sheet("SNAP Case Procedural Error Rate") firstrow cellrange(A1) clear
foreach var of varlist _all {
    if !inlist("`var'", "State", "State FIPS", "Year") {
        destring `var', ignore("NA") replace force
    }
}
save "`temp_proceduralerror_fn'", replace

import excel using "`snap_outsourcing_excel'", sheet("SNAP APT") firstrow cellrange(A1) clear
foreach var of varlist _all {
    if !inlist("`var'", "State", "State FIPS", "Year") {
        destring `var', ignore("NA") replace force
    }
}
save "`temp_apt_fn'", replace
di "* All sheets from SNAP Data_Outsourcing.xlsx imported to temporary files."
di "Section 2: Import and Clean Individual Sheets completed."

* ============================================
* Section 3: Merge Datasets
* ============================================
di "* Section 3: Merging datasets"

use "`temp_participation_fn'", clear

merge 1:1 State Year using "`temp_fairhearings_fn'", nogenerate
merge 1:1 State Year using "`temp_recipient_fn'", nogenerate
merge 1:1 State Year using "`temp_fraudhearings_fn'", nogenerate
merge 1:1 State Year using "`temp_administrativecost_fn'", nogenerate
merge 1:1 State Year using "`temp_errorrates_fn'", nogenerate
merge 1:1 State Year using "`temp_pai_fn'", nogenerate
merge 1:1 State Year using "`temp_proceduralerror_fn'", nogenerate
merge 1:1 State Year using "`temp_apt_fn'", nogenerate

merge 1:1 State Year using "`qcew_path'", nogenerate
merge 1:1 State Year using "`acs_rent_path'", nogenerate
merge 1:1 State Year using "`snap_participation_input_path'", nogenerate
merge 1:1 State Year using "`laus_path'", keepusing(UnempRate_AnnNSA) nogenerate


* Prepare for policy data merge
capture destring Year, replace
sort State Year

preserve
    use "`policy_data_input_path'", clear
    capture destring Year, replace
    sort State Year
    save "`policy_data_input_path'", replace
restore

di "* Merging with SNAP Policy Database."
merge 1:1 State Year using "`policy_data_input_path'"
di "* Merge results with policy data:"
tab _merge
drop _merge

* Ensure State, State FIPS, and Year are string variables after merging
foreach var_to_str in State StateFIPS Year {
    capture confirm variable `var_to_str'
    if _rc == 0 {
        capture confirm string variable `var_to_str'
        if _rc != 0 {
            tostring `var_to_str', replace
        }
    }
}
di "* Key identifiers ensured as string type."
di "Section 3: Merge Datasets completed."

* ============================================
* Section 4: Add State Abbreviations
* ============================================
di "* Section 4: Adding state abbreviations"

cap gen State_Abbrev = ""
replace State_Abbrev = "AL" if State == "Alabama"
replace State_Abbrev = "AK" if State == "Alaska"
replace State_Abbrev = "AZ" if State == "Arizona"
replace State_Abbrev = "AR" if State == "Arkansas"
replace State_Abbrev = "CA" if State == "California"
replace State_Abbrev = "CO" if State == "Colorado"
replace State_Abbrev = "CT" if State == "Connecticut"
replace State_Abbrev = "DE" if State == "Delaware"
replace State_Abbrev = "FL" if State == "Florida"
replace State_Abbrev = "GA" if State == "Georgia"
replace State_Abbrev = "HI" if State == "Hawaii"
replace State_Abbrev = "ID" if State == "Idaho"
replace State_Abbrev = "IL" if State == "Illinois"
replace State_Abbrev = "IN" if State == "Indiana"
replace State_Abbrev = "IA" if State == "Iowa"
replace State_Abbrev = "KS" if State == "Kansas"
replace State_Abbrev = "KY" if State == "Kentucky"
replace State_Abbrev = "LA" if State == "Louisiana"
replace State_Abbrev = "ME" if State == "Maine"
replace State_Abbrev = "MD" if State == "Maryland"
replace State_Abbrev = "MA" if State == "Massachusetts"
replace State_Abbrev = "MI" if State == "Michigan"
replace State_Abbrev = "MN" if State == "Minnesota"
replace State_Abbrev = "MS" if State == "Mississippi"
replace State_Abbrev = "MO" if State == "Missouri"
replace State_Abbrev = "MT" if State == "Montana"
replace State_Abbrev = "NE" if State == "Nebraska"
replace State_Abbrev = "NV" if State == "Nevada"
replace State_Abbrev = "NH" if State == "New Hampshire"
replace State_Abbrev = "NJ" if State == "New Jersey"
replace State_Abbrev = "NM" if State == "New Mexico"
replace State_Abbrev = "NY" if State == "New York"
replace State_Abbrev = "NC" if State == "North Carolina"
replace State_Abbrev = "ND" if State == "North Dakota"
replace State_Abbrev = "OH" if State == "Ohio"
replace State_Abbrev = "OK" if State == "Oklahoma"
replace State_Abbrev = "OR" if State == "Oregon"
replace State_Abbrev = "PA" if State == "Pennsylvania"
replace State_Abbrev = "RI" if State == "Rhode Island"
replace State_Abbrev = "SC" if State == "South Carolina"
replace State_Abbrev = "SD" if State == "South Dakota"
replace State_Abbrev = "TN" if State == "Tennessee"
replace State_Abbrev = "TX" if State == "Texas"
replace State_Abbrev = "UT" if State == "Utah"
replace State_Abbrev = "VT" if State == "Vermont"
replace State_Abbrev = "VA" if State == "Virginia"
replace State_Abbrev = "WA" if State == "Washington"
replace State_Abbrev = "WV" if State == "West Virginia"
replace State_Abbrev = "WI" if State == "Wisconsin"
replace State_Abbrev = "WY" if State == "Wyoming"
replace State_Abbrev = "DC" if State == "District of Columbia"
replace State_Abbrev = "DC" if State == "District Of Columbia"
replace State_Abbrev = "PR" if State == "Puerto Rico"
replace State_Abbrev = "GU" if State == "Guam"
replace State_Abbrev = "VI" if State == "Virgin Islands"
replace State_Abbrev = "US" if State == "US"
di "Section 4: Add State Abbreviations completed."

* ============================================
* Section 5: Label Variables
* ============================================
di "* Section 5: Labeling variables"

label variable State "State observed"
label variable StateFIPS "State FIPS Code"
label variable Year "Year"
label variable Part_Prsn_Mnthly_Avg "Persons Participating (Monthly Average)"
label variable Part_HH_Mnthly_Avg "Households Participating (Monthly Average)"
label variable Ttl_Iss "Total Issuance (dollars)"
label variable Avg_Mnthly_Benefit_Per_Prsn "Average Monthly Benefit Per Person (dollars)"
label variable Avg_Mnthly_Benefit_Per_HH "Average Monthly Benefit Per Household (dollars)"
label variable Part_EBT_Prsn "Persons Participating by EBT Benefits"
label variable Part_Cash_Prsn "Persons Participating by Cash Benefits"
label variable Part_Food_Pckges_Prsn "Persons Participating by Food Packages Benefits"
label variable Part_Other_Prsn "Persons Participating by Other Benefit Type"
label variable Part_Food_Coupn_Prsn "Persons Participating by Food Coupon Benefits"
label variable Part_Grp_Housing_Prsn "Persons Participating by Group Housing Benefits"
label variable Part_Ttl_Prsn "Total Persons Participating"
label variable Part_Emerg_Allot_Prsn "Persons Participating by Emergency Allotment Benefits"
label variable Part_EBT_HH "Households Participating by EBT Benefits"
label variable Part_Other_HH "Households Participating by Other Benefit Type"
label variable Part_Food_Pckges_HH "Households Participating by Food Packages Benefits"
label variable Part_Food_Coupn_HH "Households Participating by Food Coupon Benefits"
label variable Part_Grp_Housing_HH "Households Participating by Group Housing Benefits"
label variable Part_Ttl_HH "Total Households Participating"
label variable Part_Emerg_Allot_HH "Households Participating by Emergency Allotment Benefits"
label variable Iss_EBT "Total Issuance for EBT Benefits (dollars)"
label variable Iss_Cash "Total Issuance for Cash Benefits (dollars)"
label variable Iss_Other "Total Issuance for Other Benefits (dollars)"
label variable Iss_Food_Pckges "Total Issuance for Food Packages Benefits (dollars)"
label variable Iss_Food_Coupns "Total Issuance for Food Coupons Benefits (dollars)"
label variable Iss_Grp_Housing "Total Issuance for Group Housing Benefits (dollars)"
label variable Iss_Emerg_Allot "Total Issuance for Emergency Allotment Benefits (dollars)"
label variable Iss_Ttl "Total Issuance (dollars)"
label variable Fair_Hearings_Upheld "Fair Hearings Upheld"
label variable Fair_Hearings_Reversed "Fair Hearings Reversed"
label variable Fair_Hearings_Percent_Upheld "Percent of Fair Hearings Upheld (percent)"
label variable Frd_Claims_Estab_Dol "Fraud Claims Established (dollars)"
label variable HH_Err_Claims_Estab_Dol "Household Error Claims Established (dollars)"
label variable Agency_Err_Claims_Estab_Dol "Agency Error Claims Established (dollars)"
label variable Total_Claims_Estab_Dol "Total Claims Established (dollars)"
label variable Frd_Claims_Estab "Fraud Claims Established"
label variable HH_Err_Claims_Estab "Household Error Claims Established"
label variable Agency_Err_Claims_Estab "Agency Error Claims Established"
label variable Total_Claims_Estab "Total Claims Established"
label variable Avg_Dol_Amt_New_Frd_Claims_Estab "Average Dollar Amount for Fraud Claims Established (dollars)"
label variable Avg_Dol_Amt_HH_Err_Claims_Estab "Average Dollar Amount for Household Error Claims Established (dollars)"
label variable Avg_Dol_Amt_Agncy_Err_Claim_Estb "Average Dollar Amount for Agency Error Claims Established (dollars)"
label variable Avg_Dol_Amt_All_New_Claims_Estab "Average Dollar Amount for All New Claims Established (dollars)"
label variable Frd_Claims_Collected "Fraud Claims Collected (dollars)"
label variable HH_Err_Claims_Collected "Household Error Claims Collected (dollars)"
label variable Agency_Err_Claims_Collected "Agency Error Claims Collected (dollars)"
label variable Total_Claims_Collected "Total Claims Collected (dollars)"
label variable Frd_Claims_Recouped "Fraud Claims Recouped (dollars)"
label variable HH_Err_Recouped "Household Error Claims Recouped (dollars)"
label variable Agency_Err_Recouped "Agency Error Claims Recouped (dollars)"
label variable Total_Claims_Recouped "Total Claims Recouped (dollars)"
label variable Treasury_Offset_Program "Claims Collected by Treasury Offset Program (dollars)"
label variable Federal_Debt_Collction "Claims Collected by Federal Debt Collection (dollars)"
label variable Othr_State_Means_Collction "Claims Collected by Other State Means (dollars)"
label variable Othr_Collction_Mthds_And_Refnds "Claims Collected by Other Collection Methods and Refunds (dollars)"
label variable Neg_Pre_Cert_Invst "Pre-Certification Investigations Negative"
label variable Pos_Pre_Cert_Invst "Pre-Certification Investigations Positive"
label variable Neg_Post_Cert_Invst "Post-Certification Investigations Negative"
label variable Pos_Post_Cert_Invst "Post-Certification Investigations Positive"
label variable Tot_Invst_Complt "Total Investigations Completed"
label variable Fraud_Dol_Det_Pre_Cert_Invst "Fraud Dollars Determined by Pre-Certification Investigations"
label variable Fraud_Dol_Det_Post_Cert_Invst "Fraud Dollars Determined by Post-Certification Investigations"
label variable ADH_Intntnl_Prgram_Vlation_Fnd "ADH Intentional Program Violation Found"
label variable ADH_Waiver_Signed "ADH Waivers Signed"
label variable ADH_No_Intnl_Prgrm_Vltion_Fnd "ADH No Intentional Program Violation Found"
label variable Asct_Prgram_Loss_ADH "ADH Associated Program Loss (dollars)"
label variable Avg_Amt_Fraud_Per_Dis_From_ADH "Average Amount of Fraud Per Disqualification from ADH (dollars)"
label variable Elgblty_Frd_Invst_Rf_ADH_or_Pros "Eligibility Fraud Investigations Referred for ADH or Prosecution"
label variable Traf_Invst_Ref_ADH_or_Pros "Trafficking Investigations Referred for ADH or Prosecution"
label variable Tot_Fraud_Invst_Ref_ADH_or_Pros "Total Fraud Investigations Referred for ADH or Prosecution"
label variable Pros_Convictions "Prosecution Convictions"
label variable Pros_Dis_Consnt_Agreemnts_Signed "Prosecution Disqualification Consent Agreements Signed"
label variable Pros_Acquittals "Prosecution Acquittals"
label variable Pros_Asct_Prgrm_Loss "Prosecution Associated Program Loss (dollars)"
label variable Pros_Avg_Amt_Fraud_Per_DQ "Prosecution Average Amount Fraud Per Disqualification (dollars)"
label variable Dis_ADH "Disqualifications from ADH"
label variable Dis_From_Pros "Disqualifications from Prosecution"
label variable Tot_Dis "Total Disqualifications"
label variable Tot_Recipients_in_Database "Total Recipients in Database"
label variable Tot_Dis_in_Database "Total Disqualifications in Database"
label variable State_Share_Admn_Cost "State Share of Total Admin Cost (dollars)"
label variable Fed_Share_Admn_Cost "Federal Share of Total Admin Cost (dollars)"
label variable Tot_Admn_Cost "Total Admin Cost (dollars)"
label variable Part_HH_Mnthly_Average "Household Monthly Average Participation"
label variable Tot_Admn_Cost_Per_Case_Per_Mnth "Total Admin Cost Per Case Per Month (dollars)"
label variable Fed_Admn_Cost_Per_Case_Per_Mnth "Federal Admin Cost Per Case Per Month (Dollars)"
label variable Fed_Share_Cert_Cost "Federal Share of Certification Costs (Dollars)"
label variable Fed_Share_Iss_Cost "Federal Share of Issuance Costs (Dollars)"
label variable Fed_Share_Fraud_Control_Cost "Federal Share of Fraud Control Costs (Dollars)"
label variable Fed_Share_ADP_Dev_Cost "Federal Share of ADP Development Costs (Dollars)"
label variable Fed_Share_ADP_Oper_Cost "Federal Share of ADP Operations Costs (Dollars)"
label variable Fed_Costs_Per_Case_Per_Mnth_Cert "Federal Certification Costs Per Case Per Month (Dollars)"
label variable Over_Payments "Overpayment Error Rate (Percent)"
label variable Under_Payments "Underpayment Error Rate (Percent)"
label variable Payment_Error_Rate "Payment Error Rate (Percent)"
label variable Program_Access_Index "Program Access Index (Index Score)"
label variable Case_Proc_Err_Rate "Case and Procedural Error Rate (Percent)"
label variable App_Proc_Tmln "Application Processing Timeliness Rates (Percent)"
label variable SNAP_Part_Perc "SNAP Participation Percentage (Percent)"
label variable SNAP_Eligibles "SNAP Eligible Participants (in thousands)"
di "Section 5: Label Variables completed."

* ============================================
* Section 6: Save Final Dataset
* ============================================
di "* Section 6: Sorting and saving the final dataset SNAP_Data.dta"

sort State Year State_Abbrev

local final_snap_data_path "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta"
save "`final_snap_data_path'", replace
di "* Final dataset for analysis saved as: `final_snap_data_path'"
di "Section 6: Save Final Dataset completed."

* ============================================
* Section 7: Final Clean Up
* ============================================
di "* Section 7: Cleaning up temporary files"

capture erase "`temp_participation_fn'"
capture erase "`temp_fairhearings_fn'"
capture erase "`temp_recipient_fn'"
capture erase "`temp_fraudhearings_fn'"
capture erase "`temp_administrativecost_fn'"
capture erase "`temp_errorrates_fn'"
capture erase "`temp_pai_fn'"
capture erase "`temp_proceduralerror_fn'"
capture erase "`temp_apt_fn'"
di "* Named temporary files erased from: ${project_path}/Data Outputs/SNAP Dataset/"

cd "$project_path" // Return to project directory
di "* Changed directory back to project root: ${project_path}"

clear
di "* Main SNAP data cleaning and merging complete. Final dataset is SNAP_Data.dta."
di "Section 7: Final Clean Up completed."