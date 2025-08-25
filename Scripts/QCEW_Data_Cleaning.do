* ============================================
* Author: Dylan Craig
* Date Created: 12/10/2024
* Data Updated: 5/14/2025
* Title: QCEW_Data_Cleaning
* Purpose: Combine annual wage data into a master dataset and clean for analysis
* ============================================

* ============================================
* 1. Set Global Paths and Initialize
* ============================================
* global project_path "C:/Users/dscra/OneDrive - University of Virginia/Social Assistance Outsourcing Project"

* Create an empty master dataset to append processed files
clear
tempfile master_data
save `master_data', emptyok

* ============================================
* 2. Process .xlsx Files (2014-2023)
* ============================================
import excel "${project_path}/Raw_Data/QCEW State Wages/2014.xlsx", firstrow clear
gen Year = 2014 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2015.xlsx", firstrow clear
gen Year = 2015 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2016.xlsx", firstrow clear
gen Year = 2016 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2017.xlsx", firstrow clear
gen Year = 2017 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2018.xlsx", firstrow clear
gen Year = 2018 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2019.xlsx", firstrow clear
gen Year = 2019 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2020.xlsx", firstrow clear
gen Year = 2020 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2021.xlsx", firstrow clear
gen Year = 2021 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2022.xlsx", firstrow clear
gen Year = 2022 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2023.xlsx", firstrow clear
gen Year = 2023 // Add the year
append using `master_data', force
save `master_data', replace

* ============================================
* 3. Process .xls Files (2004-2013)
* ============================================
import excel "${project_path}/Raw_Data/QCEW State Wages/2004.xls", firstrow clear
gen Year = 2004 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2005.xls", firstrow clear
gen Year = 2005 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2006.xls", firstrow clear
gen Year = 2006 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2007.xls", firstrow clear
gen Year = 2007 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2008.xls", firstrow clear
gen Year = 2008 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2009.xls", firstrow clear
gen Year = 2009 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2010.xls", firstrow clear
gen Year = 2010 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2011.xls", firstrow clear
gen Year = 2011 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2012.xls", firstrow clear
gen Year = 2012 // Add the year
append using `master_data', force
save `master_data', replace

import excel "${project_path}/Raw_Data/QCEW State Wages/2013.xls", firstrow clear
gen Year = 2013 // Add the year
append using `master_data', force
save `master_data', replace

* ============================================
* 4. Cleaning and Processing
* ============================================

* Load the master dataset
use `master_data', clear

* Combine duplicate variables into unified names
gen AREA_TITLE_FINAL = ""
replace AREA_TITLE_FINAL = area_title if !missing(area_title)
replace AREA_TITLE_FINAL = AREA_TITLE if !missing(AREA_TITLE)
replace AREA_TITLE_FINAL = STATE if !missing(STATE)

gen A_MEDIAN_FINAL = ""
replace A_MEDIAN_FINAL = a_median if !missing(a_median)
replace A_MEDIAN_FINAL = A_MEDIAN if !missing(A_MEDIAN)

gen OCC_TITLE_FINAL = ""
replace OCC_TITLE_FINAL = OCC_TITLE if !missing(OCC_TITLE)
replace OCC_TITLE_FINAL = occ_title if !missing(occ_title)

* Drop old, redundant variables
drop area_title AREA_TITLE STATE a_median A_MEDIAN OCC_TITLE occ_title

* Rename unified variables
rename AREA_TITLE_FINAL AREA_TITLE
rename A_MEDIAN_FINAL A_MEDIAN
rename OCC_TITLE_FINAL OCC_TITLE

* Filter dataset to keep only relevant observations and variables
keep if OCC_TITLE == "All Occupations" // Only "All Occupations"
keep AREA_TITLE A_MEDIAN Year // Keep only relevant columns

* Rename variables for clarity
rename AREA_TITLE State
label variable A_MEDIAN "Annual Median Salary for All Occupations"

* Ensure `A_MEDIAN` is numeric
destring A_MEDIAN, replace

* ============================================
* 5. Save Final Dataset
* ============================================
save "${project_path}/Data Outputs/QCEW State Wages/QCEW_State_Wages_Cleaned.dta", replace