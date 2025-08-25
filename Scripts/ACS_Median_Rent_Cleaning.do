* ============================================
* Author: Dylan Craig
* Date Created: 12/10/2024
* Date Updated: 5/14/2024
* Name: ACS_Median_Rent_Cleaning
* Purpose: Combine annual median rent data into a single dataset
* ============================================

* ============================================
* 1. Set Global Path and Clear Workspace
* ============================================
clear all
* global project_path "C:/Users/dscra/OneDrive - University of Virginia/Social Assistance Outsourcing Project"

* Set the working directory to the ACS State Median Rent folder
cd "${project_path}/Raw_Data/ACS State Median Rent"

* List all .csv files in the directory
local files : dir "." files "*.csv"

* Create an empty master dataset to store combined data
tempfile master_data
save `master_data', emptyok

* ============================================
* 2. Process Each File and Append Data
* ============================================
foreach file of local files {
    * Display the file being processed
    display "Processing file: `file'"

    * Extract the year from the filename (e.g., ACSDT5Y2023.B25064-Data.csv -> 2023)
    local year = substr("`file'", 8, 4)
    display "Extracted year: `year'"

    * Import the file, skipping the first row (metadata)
    import delimited "`file'", varnames(2) clear

    * Add a variable for the year
    gen Year = real("`year'")

    * Append the data to the master dataset
    append using `master_data', force
    save `master_data', replace
}

* ============================================
* 3. Clean and Process Data
* ============================================
* Load the combined master dataset
use `master_data', clear

* Drop unnecessary variables
drop v5 marginoferrormediangrossrent geography

* Rename variables for clarity
rename geographicareaname State
rename estimatemediangrossrent A_Med_Gross_Rent

* Add labels to variables
label variable State "State Name"
label variable A_Med_Gross_Rent "Annual Median Gross Rent for Each State"
label variable Year "Year"

* ============================================
* 4. Save Final Dataset
* ============================================
* Save the cleaned and processed dataset to the output path
save "${project_path}/Data Outputs/ACS State Median Rent/ACS_State_Median_Rent_Cleaned.dta", replace
display "Final dataset saved as: ACS_State_Median_Rent_Cleaned.dta"