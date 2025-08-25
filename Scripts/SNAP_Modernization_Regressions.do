* ============================================
* Regression Analysis of SNAP Modernization Effects
* ============================================
* Author: Dylan Craig
* Date Created: 08/01/2025
* Date Updated: 08/18/2025
* Name: SNAP_Modernization_TWFE_Analysis_Final
* Purpose: Analyze the effects of attempted and actual SNAP
* modernization on program participation and administrative
* costs per recipient (in logs) using traditional causal
* inference methods and generate descriptive figures.
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
*/

* --- Define Dependent Variables for Analysis ---
* Using logged outcome variables to estimate percentage changes
local participation "log_participation"
local admin_costs "log_admin_costs_pr"

* Set up a results directory EARLY (moved up so later sections can export)
// global project_path "C:/Users/dscra/Box/Social Assistance Outsourcing Project"
local results_dir "${project_path}/Plots_Charts/SNAP Regression Outputs"
capture mkdir "`results_dir'"

di "Section 0: Set Up and Configuration completed."


* ============================================
* Section 1: Data Loading and Panel Setup
* ============================================
di "* Section 1: Loading data and setting up panel structure"

* Load the dataset from the specified file path
use "${project_path}/Data Outputs/SNAP Dataset/SNAP_Data.dta", clear

* --- DATA CLEANING ---
* Drop national aggregate data and territories to focus on the 50 states
drop if State == "US" | State == "District of Columbia" | State == "Guam" | State == "Puerto Rico" | State == "Virgin Islands"

* Convert State from string to numeric for panel analysis
encode State, gen(State_num)

* Convert Year from string to numeric
destring Year, replace

* Define the panel structure
xtset State_num Year

* --- Generate New Outcome Variables ---
* 1. Admin Cost Per Recipient
gen admin_cost_per_recipient = Tot_Admn_Cost / Part_Prsn_Mnthly_Avg
label var admin_cost_per_recipient "Administrative Cost per Recipient (Monthly Avg)"

* 2. Logged Outcome Variables
gen log_participation = ln(Part_Prsn_Mnthly_Avg)
label var log_participation "Log of Monthly Avg Participants"

gen log_admin_costs_pr = ln(admin_cost_per_recipient)
label var log_admin_costs_pr "Log of Admin Cost per Recipient"

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

replace snap_init_yr = 2020 if State_num == 1  // Alabama https://dhr.alabama.gov/wp-content/uploads/2022/04/STIS-DDI-RFP.pdf (p. 7)
* replace snap_comp_yr = . if State_num == 1 // Alabama https://dhr.alabama.gov/wp-content/uploads/2022/05/Pre-Proposal-Conference-FINAL-2022-5-5.pdf (p. 4)

replace snap_init_yr = 2017 if State_num == 2  // Alaska https://github.com/akhealth/EIS-Modernization#:~:text=First%20solicitation%20%2D%20RFP%20released%20November%203%2C%202017 (Link to Highlight)
* replace snap_comp_yr = . if State_num == 2 // Alaska https://virginia.box.com/s/y887fvu6gmyavtd8znrbngrww0872r6j (pp. 1, 8)

* replace snap_init_yr = . if State_num == 3  // Arizona
* replace snap_comp_yr = . if State_num == 3

replace snap_init_yr = 2013 if State_num == 4  // Arkansas https://humanservices.arkansas.gov/wp-content/uploads/710-19-1008_FINAL_UAT.pdf (p. 2)
replace snap_comp_yr = 2021 if State_num == 4 // Arkansas https://arkleg.state.ar.us/Home/FTPDocument?path=%2FAssembly%2FMeeting+Attachments%2F430%2F4616%2FExhibit+E+-+ARIES+Overview+Presentation.pdf#:~:text=%E2%80%94%20ARIES%20Release%202%20%E2%80%94,be%20implemented%20in%20December%202021 (p. 8)

replace snap_init_yr = 2018 if State_num == 5  // California https://virginia.box.com/s/v7lq746cykhterut9cby0ki24z6slr9y (pp. 1-2)
replace snap_comp_yr = 2023 if State_num == 5  // California https://virginia.box.com/s/v7lq746cykhterut9cby0ki24z6slr9y (pp. 1-2)

replace snap_init_yr = 1996 if State_num == 6  // Colorado https://virginia.box.com/s/c5q7rdd6gsc1u12e0eyxrpgdil6mu6ah (p. 2)
replace snap_comp_yr = 2004 if State_num == 6  // Colorado https://virginia.box.com/s/ixhk0qv60z5kul1yaanzrvphylgwrfdk (p. 2)

replace snap_init_yr = 2013 if State_num == 7  // Connecticut https://www.nascio.org/wp-content/uploads/2020/09/CTDSS-NASCIO-Submission-2018.pdf (p. 1)
replace snap_comp_yr = 2017 if State_num == 7  // Connecticut https://virginia.box.com/s/zttxc0b38fc6ylcs5uj7dez8rsa9daaz (p. 2)

* replace snap_init_yr = . if State_num == 8  // Delaware
replace snap_comp_yr = 2016 if State_num == 8  // Delaware https://bidcondocs.delaware.gov/HSS/HSS_15063ASSISTMaintAndOps_SPEC_CORRECTED.pdf (p. 1)

replace snap_init_yr = 2019 if State_num == 9 // Florida https://www.myflorida.com/apps/vbs/adoc/F481701437_DCFITN2021001EBTEFTPartI.pdf (p. 29)
* replace snap_comp_yr = . if State_num == 9 // Florida

replace snap_init_yr = 2014 if State_num == 10 // Georgia https://kffhealthnews.org/news/article/medicaid-deloitte-run-eligibility-systems-plagued-by-errors/#:~:text=Georgia%E2%80%99s%20contract%20with%20Deloitte%20to%20build%20and%20maintain%20its%20system%20for%20health%20and%20social%20service%20programs%2C%20inked%20in%202014%2C%20as%20of%20January%202023%20was%20worth%20%24528%20million. (Link to Highlight)
replace snap_comp_yr = 2017 if State_num == 10 // Georgia https://dhs.georgia.gov/sites/dhs.georgia.gov/files/DHS Quick Facts Book SFY 2017FINAL.pdf (p. 7)

replace snap_init_yr = 2021 if State_num == 11 // Hawaii https://hiepro.ehawaii.gov/public-display-solicitation.html?rfid=22000002&resetCookie#:~:text=Management%20Consulting%20Services%20for%20State%20of%20Hawaii%20DHS%20SNAP/TANF%20Benefits%20Eligibility%20System%20(BES)%20Project (Link to Highlight)
* replace snap_comp_yr = . if State_num == 11

replace snap_init_yr = 2007 if State_num == 12 // Idaho https://fns-prod.azureedge.us/sites/default/files/EnhancedCertification_Vol2Final.pdf (p. 31)
replace snap_comp_yr = 2009 if State_num == 12 // Idaho https://virginia.box.com/s/3wnzcrj2uasaxi479aygj6ql8jgerofk (p. 3)

replace snap_init_yr = 2013 if State_num == 13 // Illinois https://hfs.illinois.gov/content/dam/soi/en/web/hfs/sitecollectiondocuments/fy2014annualreport.pdf (p. 5)
replace snap_comp_yr = 2017 if State_num == 13 // Illinois https://virginia.box.com/s/9cfenz7gygpypbplzd710med228lqchg (p. 6)

replace snap_init_yr = 2006 if State_num == 14 // Indiana https://vksapp.com/blog/automating-inequality#:~:text=In%202006%2C%20Indiana%20decided%20to%20revamp%20the%20FSSA%20in%20order%20to%20streamline%20services%20and%20better%20prevent%20welfare%20fraud.%20They%20awarded%20a%20contract%2C%20which%20included%20instituting%20an%20automated%20eligibility%20system%2C%20to%20companies%20IBM%20and%20ACS. (Link to Highlight)
replace snap_comp_yr = 2020 if State_num == 14 // Indiana https://humanservices.arkansas.gov/wp-content/uploads/Ikaso-Response-to-RFP-710-24-076.pdf (p. 5)

replace snap_init_yr = 2012 if State_num == 15 // Iowa https://virginia.box.com/s/lvbvthdbk4m9noymrf7302gdiwfnhkfx (p. 1)
replace snap_comp_yr = 2014 if State_num == 15 // Iowa https://virginia.box.com/s/lvbvthdbk4m9noymrf7302gdiwfnhkfx (p. 6)

replace snap_init_yr = 2009 if State_num == 16 // Kansas https://rockinst.org/wp-content/uploads/2018/02/2014-12-Kansas_Baseline_report.pdf (p. 17)
replace snap_comp_yr = 2017 if State_num == 16 // Kansas https://virginia.box.com/s/qfhb7q4u7nhxw19tzdjxvadqso6i9661 (p. 7)

replace snap_comp_yr = 2016 if State_num == 17 // Kentucky https://virginia.box.com/s/qfhb7q4u7nhxw19tzdjxvadqso6i9661 (p. 2)
replace snap_init_yr = 2012 if State_num == 17 // Kentucky https://virginia.box.com/s/uvru92emelil6xvfxl54t3xe2dm4i68m (p. 4)

replace snap_init_yr = 2017 if State_num == 18 // Louisiana https://public.powerdms.com/LADCFS/documents/393900 (p. 1)
replace snap_comp_yr = 2020 if State_num == 18 // Louisiana https://app.lla.state.la.us/publicreports.nsf/0/81a8cf9a2ac671bb86258965005b5181/$file/00000d26a.pdf?openelement&.7773098 (p. 10)

replace snap_init_yr = 1999 if State_num == 19 // Maine https://www.nextgov.com/digital-government/2002/12/maine-sees-benefits-in-system/200389/#:~:text=The%20system%20took,system. (Link to Highlight)
replace snap_comp_yr = 2002 if State_num == 19 // Maine https://virginia.box.com/s/tmfs0js4cjvnui3pp8t1lywsur5vz8gy (p. 1)

replace snap_init_yr = 2017 if State_num == 20 // Maryland https://humanservices.vermont.gov/sites/ahsnew/files/doc_library/RFI November 2022 All Vendor Responses.pdf (p. 96)
replace snap_comp_yr = 2021 if State_num == 20 // Maryland https://www.ssw.umaryland.edu/media/ssw/fwrtg/welfare-research/life-on-welfare-special-issues/Partial-Sanctions-in-Maryland's-TCA-Program-(1).pdf (p. 2)

replace snap_init_yr = 2007 if State_num == 21 // Massachusetts https://virginia.box.com/s/xniwnv4ay12a61k75wfzj4vz2dhfogmn (p. I.50)
replace snap_comp_yr = 2010 if State_num == 21 // Massachusetts https://virginia.box.com/s/xniwnv4ay12a61k75wfzj4vz2dhfogmn (p. 136)

replace snap_init_yr = 2006 if State_num == 22 // Michigan https://www.michigan.gov/-/media/Project/Websites/dtmb/Procurement/Contracts/Folder10/1300256.pdf?rev=c23f8781228c494baedade617190b5ed (p. 149)
replace snap_comp_yr = 2009 if State_num == 22 // Michigan https://www.michigan.gov/-/media/Project/Websites/dtmb/Procurement/Contracts/Folder10/1300256.pdf?rev=c23f8781228c494baedade617190b5ed (p. 151)

replace snap_init_yr = 2013 if State_num == 23 // Minnesota https://assets.senate.mn/committees/2017-2018/3095_Committee_on_Health_and_Human_Services_Finance_and_Policy/DHS IT Systems Transformation Presentation.pdf (p. 11)
* replace snap_comp_yr = . if State_num == 23 // Minnesota

replace snap_init_yr = 2021 if State_num == 24 // Mississippi https://www.mdhs.ms.gov/wp-content/uploads/2023/08/mdhs-annual-report-2021.pdf (p. 25)
* replace snap_comp_yr = . if State_num == 24 // Mississippi

replace snap_init_yr = 2021 if State_num == 25 // Missouri https://oa.mo.gov/sites/default/files/FY26_DSS_Programs_Book.pdf (p. 127)
replace snap_comp_yr = 2025 if State_num == 25 // Missouri https://oa.mo.gov/sites/default/files/FY26_DSS_Programs_Book.pdf (p. 143)

replace snap_init_yr = 2007 if State_num == 26 // Montana https://archive.legmt.gov/content/Publications/fiscal/interim/2013_financecmty_Sept/CHIMES.pdf (p. 2)
replace snap_comp_yr = 2012 if State_num == 26 // Montana https://virginia.box.com/s/h6hxe9tsxq5a321jkpjhueagp8mnrp8w (p. 11)

replace snap_init_yr = 2014 if State_num == 27 // Nebraska https://nebraskalegislature.gov/FloorDocs/104/PDF/Agencies/Health_and_Human_Services__Department_of/107_20151228-101834.pdf (p. 18)
* replace snap_comp_yr = . if State_num == 27 // Nebraska

replace snap_init_yr = 2012 if State_num == 28 // Nevada https://www.leg.state.nv.us/Session/76th2011/Minutes/Assembly/WM/Final/480.pdf (p. 5)
replace snap_comp_yr = 2013 if State_num == 28 // Nevada https://www.leg.state.nv.us/Session/76th2011/Minutes/Assembly/WM/Final/480.pdf (p. 5)

replace snap_init_yr = 1995 if State_num == 29 // New Hampshire https://medicaid.pr.gov/pdf/Deloitte_RFIResponse_PuertoRico_Final.pdf (p. 2)
replace snap_comp_yr = 1998 if State_num == 29 // New Hampshire https://virginia.box.com/s/qhtquo4lm3b5ee6sryydtjxc86hti45h (p. 1)

replace snap_init_yr = 2009 if State_num == 30 // New Jersey (Find source)
replace snap_comp_yr = 2013 if State_num == 30 // New Jersey https://www.nj.gov/humanservices/documents/cass_connect_0912.pdf

replace snap_init_yr = 2011 if State_num == 31 // New Mexico https://www.nmlegis.gov/Entity/LFC/Documents/Program_Evaluation_Reports/Human Services Department - Automated System Program and Eligibility Network (ASPEN).pdf (p. 7)
replace snap_comp_yr = 2014 if State_num == 31 // New Mexico https://virginia.box.com/s/1ioorz565l7z6yg2gmf6k2cnibki3ysz (p. 8)

replace snap_init_yr = 2021 if State_num == 32 // New York https://www.macpac.gov/wp-content/uploads/2018/11/Assessment-and-Synthesis-of-Selected-Medicaid-Eligibility-Enrollment-and-Renewal-Processes-and-Systems-in-Six-States.pdf (p. 27)
* replace snap_comp_yr = . if State_num == 32 // New York

replace snap_init_yr = 1999 if State_num == 33 // North Carolina https://www.macpac.gov/wp-content/uploads/2018/11/North-Carolina-Summary-Report.pdf (p. 6)
replace snap_comp_yr = 2013 if State_num == 33 // North Carolina https://en.wikipedia.org/wiki/North_Carolina_Department_of_Health_and_Human_Services#:~:text=In%20July%202013%2C%20NCDHHS%20went%20live%20with%20its%20NCTracks%20system%20for%20managing%20Medicaid%20billings.%5B31%5D%20Also%20that%20month%2C%5B32%5D%20after%20three%20years%20in%20development%5B33%5D%20NCDHHS%20oversaw%20the%20statewide%20rollout%20of%20NC%20Fast%2C%20a%20new%20system%20meant%20to%20manage%20the%20state%27s%20food%20stamps. (p. 4)

replace snap_init_yr = 2013 if State_num == 34 // North Dakota https://www.nd.gov/dhs/info/testimony/2019-2020-interim/info-tech/2020-9-30-spaces-update.pdf (p. 6)
replace snap_comp_yr = 2019 if State_num == 34 // North Dakota https://www.nd.gov/dhs/info/testimony/2019-2020-interim/info-tech/2020-9-30-spaces-update.pdf (p. 6)

replace snap_init_yr = 2012 if State_num == 35 // Ohio https://opra.simplelists.com/opra_members/cache/890735/2.pdf/ (p. 1)
replace snap_comp_yr = 2018 if State_num == 35 // Ohio https://www.communitysolutions.com/resources/ohio-counties-modernize-work-supports-programs-community-engagement-critical-success#:~:text=Figure%201%3A%20Ohio%20Benefits%20Project%20Timeline (p. 16)

* replace snap_init_yr = . if State_num == 36 // Oklahoma
* replace snap_comp_yr = . if State_num == 36 // Oklahoma

replace snap_init_yr = 2015 if State_num == 37 // Oregon https://virginia.box.com/s/ltiaol2mfhg9pnkf1hrt0ztaifktbdzg (p. 5)
replace snap_comp_yr = 2020 if State_num == 37 // Oregon https://www.nascio.org/wp-content/uploads/2020/09/Oregon-OHA-2017-Oregon_ONEligibility_System.pdf (p. 5)

replace snap_init_yr = 2008 if State_num == 38 // Pennsylvania https://contracts.patreasury.gov/Admin/Upload/212624_Pages from 4000016622 part 3d 2Attachment B-2.pdf (p. 268)
replace snap_comp_yr = 2020 if State_num == 38 // Pennsylvania https://palms-awss3-repository.s3-us-west-2.amazonaws.com/Communications/ODP/2019/ODPANN+19-137+Additional+Information+for+eCIS+Business+Partner+Transition.pdf (p. 3)

replace snap_init_yr = 2013 if State_num == 39 // Rhode Island https://virginia.box.com/s/9ew0og72c2350fsdzyc4rm05gsjn50vr (p. 1)
replace snap_comp_yr = 2016 if State_num == 39 // https://eohhs.ri.gov/press-releases/new-health-and-human-services-eligibility-system-launches-tuesday-september-13th#:~:text=Make%20government%20work,Supplemental%20Payments%20(SSP) (Link to Highlight)

* replace snap_init_yr = . if State_num == 40 // South Carolina
* replace snap_comp_yr = . if State_num == 40

* replace snap_init_yr = . if State_num == 41 // South Dakota
* replace snap_comp_yr = . if State_num == 41

replace snap_init_yr = 2014 if State_num == 42 // Tennessee https://humanservices.arkansas.gov/wp-content/uploads/Ikaso-Response-to-RFP-710-24-076.pdf (p. 62)
replace snap_comp_yr = 2023 if State_num == 42 // Tennessee https://www.wbir.com/article/news/community/delays-in-snap-benefits-in-tennessee/51-c8315a17-78fc-40ef-8a69-a6b0fe56b7c2#:~:text=In%20June%2C%20TDHS,TDHS%20team%20members. (Link to Highlight)

replace snap_init_yr = 1997 if State_num == 43 // Texas https://issuelab.org/resources/11129/11129.pdf (p. 4)
replace snap_comp_yr = 2011 if State_num == 43 // Texas https://virginia.box.com/s/h3cwbkrirpo4ziioa88278grkkyxplau (p. 2)

replace snap_init_yr = 2002 if State_num == 44 // Utah https://www.urban.org/sites/default/files/publication/22961/413231-examples-of-promising-practices-for-integrating-and-coordinating-eligibility-enrollment-and-retention-human-services-and-health-programs-under-the-affordable-care-act.pdf (p. 2)
replace snap_comp_yr = 2010 if State_num == 44 // Utah https://virginia.box.com/s/1bn47m0boxcg48f94qjz805u7xsutu51 (p. 4)

replace snap_init_yr = 2022 if State_num == 45 // Vermont https://bgs.vermont.gov/sites/bgs/files/files/purchasing-contracting/VT IES Documents/MITA 3.0 State Self-Assessment Detailed Report_2023.pdf (p. 25)
* replace snap_comp_yr = . if State_num == 45 // Vermont

replace snap_init_yr = 2012 if State_num == 46 // Virginia https://rga.lis.virginia.gov/Published/2017/RD181/PDF (p. 11)
replace snap_comp_yr = 2017 if State_num == 46 // Virginia https://rga.lis.virginia.gov/Published/2017/RD181/PDF (Link to Highlight)

replace snap_init_yr = 2022 if State_num == 47 // Washington https://waportal.org/system/files/team_documents/2024-10/20240918_IE%26E TAD_Del_5.1_v1.5.pdf (p. 77)
* replace snap_comp_yr = . if State_num == 47 // Washington

replace snap_init_yr = 2017 if State_num == 48 // West Virginia https://wvpublic.org/story/health-science/lawmakers-question-w-va-paths-progress/#:~:text=In%202017%2C%20West%20Virginia%20contracted%20with%20Optum%20to%20develop%20a%20system%20to%20help%20the%20agency%20efficiently%20manage%20public%20access. (Link to Highlight)
replace snap_comp_yr = 2024 if State_num == 48 // West Virginia https://dhhr.wv.gov/News/2023/Pages/DHHR-Begins-Transition-of-Family-Assistance-Programs-Eligibility-System-to-West-Virginia-People's-Access-to-Help-(WV-PATH).aspx#:~:text=The%20West%20Virginia%20Department%20of%20Health%20and%20Human%20Resources%20(DHHR)%20is%20transitioning%20its%20eligibility%20system%20for%20family%20assistance%20programs%20from%20the%20Recipient%20Automated%20Payment%20and%20Information%20Data%20System%20(RAPIDS)%20to%20West%20Virginia%20People%27s%20Access%20to%20Help%20(WV%20PATH). (Link to Highlight)

* replace snap_init_yr = . if State_num == 49 // Wisconsin
* replace snap_comp_yr = . if State_num == 49

replace snap_init_yr = 2018 if State_num == 50 // Wyoming https://wyoleg.gov/InterimCommittee/2023/02-2023071015-01_EPICSCCWISReporttoJAC2023Interim.pdf (p. 2)
replace snap_comp_yr = 2023 if State_num == 50 // Wyoming https://virginia.box.com/s/g51il5w6p2vdgt3gakalakqhfg8y2ig8 (p. 3)

* --- Create Binary Indicators ---
gen snap_initiated = (Year >= snap_init_yr) if !missing(snap_init_yr)
replace snap_initiated = 0 if missing(snap_initiated)
label var snap_initiated "1 if SNAP Modernization Attempted"

gen snap_completed = (Year >= snap_comp_yr) if !missing(snap_comp_yr)
replace snap_completed = 0 if missing(snap_completed)
label var snap_completed "1 if SNAP Modernization Actual"

di "Section 2: Create SNAP Modernization Variables completed."


* ============================================
* Section 3: Descriptive Figures of Modernization Timing
* ============================================
di "* Section 3: Generating descriptive figures"

* --- Figure 1: States Attempting Modernization by Year ---
preserve
    keep State_num snap_init_yr
    duplicates drop State_num, force
    drop if missing(snap_init_yr)

    * Use contract for proper frequency counting
    contract snap_init_yr, freq(n_initiated)
    rename snap_init_yr Year

    * Display data for verification
    list Year n_initiated, sepby(Year)

    twoway bar n_initiated Year, ///
        title("Number of States Initiating SNAP Modernization by Year") ///
        ytitle("Number of States") xtitle("Year") ///
        graphregion(color(white)) ///
        xlabel(1995(5)2025, angle(45)) ///
        ylabel(0(1)6, nogrid)
    graph export "`results_dir'/Modernization_Initiation_by_Year.png", width(1000) replace
restore

* --- Figure 2: States Completing Modernization by Year ---
preserve
    keep State_num snap_comp_yr
    duplicates drop State_num, force
    drop if missing(snap_comp_yr)

    * Use contract for proper frequency counting
    contract snap_comp_yr, freq(n_completed)
    rename snap_comp_yr Year

    * Display data for verification
    list Year n_completed, sepby(Year)

    twoway bar n_completed Year, ///
        title("Number of States Completing SNAP Modernization by Year") ///
        ytitle("Number of States") xtitle("Year") ///
        graphregion(color(white)) ///
        xlabel(1995(5)2025, angle(45)) ///
        ylabel(0(1)6, nogrid)
    graph export "`results_dir'/Modernization_Completion_by_Year.png", width(1000) replace
restore

* --- Summary Statistics for Verification ---
preserve
    keep State_num snap_init_yr snap_comp_yr
    duplicates drop State_num, force

    count if !missing(snap_init_yr)
    local total_init = r(N)
    count if !missing(snap_comp_yr)
    local total_comp = r(N)
    count
    local total_states = r(N)

    di "Summary of SNAP Modernization Data:"
    di "Total states in dataset: `total_states'"
    di "States with initiation data: `total_init'"
    di "States with completion data: `total_comp'"

    * Show states without any modernization data
    count if missing(snap_init_yr) & missing(snap_comp_yr)
    local no_modern = r(N)
    di "States with no modernization data: `no_modern'"

    if `no_modern' > 0 {
        di "States without modernization:"
        list State_num if missing(snap_init_yr) & missing(snap_comp_yr)
    }
restore

di "Section 3: Descriptive Figures completed. Plots saved to `results_dir'"


* ============================================
* Section 4: Creating cohort-based event study plots
* ============================================
di "* Section 4: Creating cohort-based event study plots"

* ---------------------------------------------------------
* Part A: Cohort Analysis for ATTEMPTED Modernization
* ---------------------------------------------------------
preserve
    * Placebo year for never-modernized states (attempted) and indicator
    gen placebo_init_yr = 2015 if missing(snap_init_yr)
    replace snap_init_yr = placebo_init_yr if missing(snap_init_yr)
    gen is_placebo_init = !missing(placebo_init_yr)

    * Relative time (ensure variable exists in this new order)
    capture confirm variable time_to_event_init
    if _rc {
        gen time_to_event_init = Year - snap_init_yr if !missing(snap_init_yr)
    }
    else {
        replace time_to_event_init = Year - snap_init_yr if !missing(snap_init_yr)
    }

    * Keep -5..+5 window
    keep if time_to_event_init >= -5 & time_to_event_init <= 5

    * Collapse to cohort-time means (keep placebo flag)
    collapse (mean) Part_Prsn_Mnthly_Avg admin_cost_per_recipient, ///
        by(snap_init_yr time_to_event_init is_placebo_init)

    * ----- Attempted: Participation -----
    twoway ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 1996,  lcolor(red)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 1997,  lcolor(blue)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 1999,  lcolor(green)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2002,  lcolor(orange)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2006,  lcolor(purple)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2007,  lcolor(brown)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2008,  lcolor(pink)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2009,  lcolor(gray)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2011,  lcolor(navy)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2012,  lcolor(maroon)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2013,  lcolor(forest_green)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2014,  lcolor(dkorange)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2015 & is_placebo_init == 0, lcolor(cranberry)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2015 & is_placebo_init == 1, lcolor(black) lpattern(dash) lwidth(thick)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2017,  lcolor(teal)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2018,  lcolor(khaki)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2019,  lcolor(lavender)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2020,  lcolor(gold)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2021,  lcolor(sienna)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_init if snap_init_yr == 2022,  lcolor(magenta)), ///
        title("Cohort Analysis: SNAP Participation by Attempted Modernization Year", size(medium)) ///
        ytitle("Monthly Average Participants", size(small)) ///
        xtitle("Years Relative to Modernization Attempt", size(small)) ///
        xlabel(-5(1)5, labsize(small)) ///
        ylabel(, format(%12.0gc) labsize(small)) ///
        xline(0, lcolor(black) lwidth(medthin)) ///
        graphregion(color(white)) ///
        legend( ///
            order(1 "1996" 2 "1997" 3 "1999" 4 "2002" 5 "2006" 6 "2007" 7 "2008" 8 "2009" ///
                  9 "2011" 10 "2012" 11 "2013" 12 "2014" 13 "2015" 14 "Never Modernized (Placebo 2015)" ///
                  15 "2017" 16 "2018" 17 "2019" 18 "2020" 19 "2021" 20 "2022") ///
            title("Initiation Year") cols(8) rows(3) size(vsmall) position(12) ring(1) region(lstyle(none)))
    graph export "`results_dir'/Cohort_Analysis_Participation_Attempted.png", width(1800) replace

    * ----- Attempted: Admin Cost per Recipient -----
    twoway ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 1996,  lcolor(red)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 1997,  lcolor(blue)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 1999,  lcolor(green)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2002,  lcolor(orange)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2006,  lcolor(purple)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2007,  lcolor(brown)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2008,  lcolor(pink)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2009,  lcolor(gray)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2011,  lcolor(navy)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2012,  lcolor(maroon)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2013,  lcolor(forest_green)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2014,  lcolor(dkorange)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2015 & is_placebo_init == 0, lcolor(cranberry)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2015 & is_placebo_init == 1, lcolor(black) lpattern(dash) lwidth(thick)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2017,  lcolor(teal)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2018,  lcolor(khaki)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2019,  lcolor(lavender)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2020,  lcolor(gold)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2021,  lcolor(sienna)) ///
        (line admin_cost_per_recipient time_to_event_init if snap_init_yr == 2022,  lcolor(magenta)), ///
        title("Cohort Analysis: Admin Cost per Recipient by Attempted Modernization Year", size(medium)) ///
        ytitle("Administrative Cost per Recipient", size(small)) ///
        xtitle("Years Relative to Modernization Attempt", size(small)) ///
        xlabel(-5(1)5, labsize(small)) ///
        ylabel(, format(%9.0fc) labsize(small)) ///
        xline(0, lcolor(black) lwidth(medthin)) ///
        graphregion(color(white)) ///
        legend( ///
            order(1 "1996" 2 "1997" 3 "1999" 4 "2002" 5 "2006" 6 "2007" 7 "2008" 8 "2009" ///
                  9 "2011" 10 "2012" 11 "2013" 12 "2014" 13 "2015" 14 "Never Modernized (Placebo 2015)" ///
                  15 "2017" 16 "2018" 17 "2019" 18 "2020" 19 "2021" 20 "2022") ///
            title("Initiation Year") cols(8) rows(3) size(vsmall) position(12) ring(1) region(lstyle(none)))
    graph export "`results_dir'/Cohort_Analysis_Admin_Costs_Attempted.png", width(1800) replace
restore

* ---------------------------------------------------------
* Part B: Cohort Analysis for COMPLETED Modernization
* ---------------------------------------------------------
preserve
    * Placebo year for states without completion and indicator
    gen placebo_comp_yr = 2015 if missing(snap_comp_yr)
    replace snap_comp_yr = placebo_comp_yr if missing(snap_comp_yr)
    gen is_placebo_comp = !missing(placebo_comp_yr)

    * Relative time (ensure variable exists in this new order)
    capture confirm variable time_to_event_comp
    if _rc {
        gen time_to_event_comp = Year - snap_comp_yr if !missing(snap_comp_yr)
    }
    else {
        replace time_to_event_comp = Year - snap_comp_yr if !missing(snap_comp_yr)
    }

    * Keep -5..+5 window
    keep if time_to_event_comp >= -5 & time_to_event_comp <= 5

    * Collapse to cohort-time means (keep placebo flag)
    collapse (mean) Part_Prsn_Mnthly_Avg admin_cost_per_recipient, ///
        by(snap_comp_yr time_to_event_comp is_placebo_comp)

    * ----- Completed: Participation -----
    twoway ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 1998, lcolor(red)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2002, lcolor(blue)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2004, lcolor(green)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2009, lcolor(orange)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2010, lcolor(purple)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2011, lcolor(brown)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2012, lcolor(pink)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2013, lcolor(gray)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2014, lcolor(navy)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2015 & is_placebo_comp==1, lcolor(black) lpattern(dash) lwidth(thick)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2016, lcolor(maroon)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2017, lcolor(forest_green)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2018, lcolor(dkorange)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2019, lcolor(cranberry)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2020, lcolor(teal)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2021, lcolor(khaki)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2023, lcolor(lavender)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2024, lcolor(gold)) ///
        (line Part_Prsn_Mnthly_Avg time_to_event_comp if snap_comp_yr == 2025, lcolor(magenta)), ///
        title("Cohort Analysis: SNAP Participation by Completion Year", size(medium)) ///
        ytitle("Monthly Average Participants", size(small)) ///
        xtitle("Years Relative to Modernization Completion", size(small)) ///
        xlabel(-5(1)5, labsize(small)) ///
        ylabel(, format(%12.0gc) labsize(small)) ///
        xline(0, lcolor(black) lwidth(medthin)) ///
        graphregion(color(white)) ///
        legend( ///
            order(1 "1998" 2 "2002" 3 "2004" 4 "2009" 5 "2010" 6 "2011" 7 "2012" 8 "2013" 9 "2014" ///
                  10 "Never Modernized (Placebo 2015)" 11 "2016" 12 "2017" 13 "2018" 14 "2019" 15 "2020" 16 "2021" 17 "2023" 18 "2024" 19 "2025") ///
            title("Completion Year") cols(8) rows(3) size(vsmall) position(12) ring(1) region(lstyle(none)))
    graph export "`results_dir'/Cohort_Analysis_Participation_Completed.png", width(1800) replace

    * ----- Completed: Admin Cost per Recipient -----
    twoway ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 1998, lcolor(red)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2002, lcolor(blue)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2004, lcolor(green)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2009, lcolor(orange)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2010, lcolor(purple)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2011, lcolor(brown)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2012, lcolor(pink)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2013, lcolor(gray)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2014, lcolor(navy)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2015 & is_placebo_comp==1, lcolor(black) lpattern(dash) lwidth(thick)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2016, lcolor(maroon)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2017, lcolor(forest_green)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2018, lcolor(dkorange)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2019, lcolor(cranberry)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2020, lcolor(teal)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2021, lcolor(khaki)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2023, lcolor(lavender)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2024, lcolor(gold)) ///
        (line admin_cost_per_recipient time_to_event_comp if snap_comp_yr == 2025, lcolor(magenta)), ///
        title("Cohort Analysis: Admin Cost per Recipient by Completion Year", size(medium)) ///
        ytitle("Administrative Cost per Recipient", size(small)) ///
        xtitle("Years Relative to Modernization Completion", size(small)) ///
        xlabel(-5(1)5, labsize(small)) ///
        ylabel(, format(%9.0fc) labsize(small)) ///
        xline(0, lcolor(black) lwidth(medthin)) ///
        graphregion(color(white)) ///
        legend( ///
            order(1 "1998" 2 "2002" 3 "2004" 4 "2009" 5 "2010" 6 "2011" 7 "2012" 8 "2013" 9 "2014" ///
                  10 "Never Modernized (Placebo 2015)" 11 "2016" 12 "2017" 13 "2018" 14 "2019" 15 "2020" 16 "2021" 17 "2023" 18 "2024" 19 "2025") ///
            title("Completion Year") cols(8) rows(3) size(vsmall) position(12) ring(1) region(lstyle(none)))
    graph export "`results_dir'/Cohort_Analysis_Admin_Costs_Completed.png", width(1800) replace
restore

* ---------------------------------------------------------
* Part C: Raw trends by cohort-year (treated vs controls)
* ---------------------------------------------------------

di "* Part C: Exporting per-cohort raw trend figures (treated vs controls)"

* Output folders
local raw_dir "`results_dir'/Raw_Trends_By_Cohort"
capture mkdir "`raw_dir'"
capture mkdir "`raw_dir'/attempted_participation"
capture mkdir "`raw_dir'/attempted_admin"
capture mkdir "`raw_dir'/completed_participation"
capture mkdir "`raw_dir'/completed_admin"

* ===== C.1 Attempted cohorts =====
* Use actual attempted cohort years (no placebo here)
levelsof snap_init_yr if !missing(snap_init_yr), local(init_years)

foreach y of local init_years {
    preserve
        tempvar tte grp
        gen `tte' = Year - `y'
        keep if inrange(`tte', -5, 5)

        * Treated = states initiating in year y
        * Controls = never-initiated or initiated in year >= y+6 (clean for full -5..+5)
        gen `grp' = .
        replace `grp' = 1 if snap_init_yr == `y'
        replace `grp' = 0 if missing(snap_init_yr) | (snap_init_yr >= `y' + 6)
        drop if missing(`grp')

        collapse (mean) Part_Prsn_Mnthly_Avg admin_cost_per_recipient, by(`tte' `grp')

        * Participation
        twoway ///
            (line Part_Prsn_Mnthly_Avg `tte' if `grp'==1, lpattern(solid)) ///
            (line Part_Prsn_Mnthly_Avg `tte' if `grp'==0, lpattern(dash)), ///
            title("Raw Trend — Participation | Attempted Cohort `y'", size(medium)) ///
            ytitle("Monthly Avg Participants", size(small)) ///
            xtitle("Years Relative to Attempt (`y')", size(small)) ///
            xline(0, lcolor(black)) xlabel(-5(1)5, labsize(small)) ///
            ylabel(, format(%12.0gc) labsize(small)) ///
            graphregion(color(white)) plotregion(margin(small)) ///
            legend(order(1 "Treated (`y')" 2 "Controls (never or ≥`= `y'+6')") ///
                   size(small) cols(2) pos(12) ring(1) region(lstyle(none)))
        graph export "`raw_dir'/attempted_participation/part_attempted_`y'.png", width(1400) replace

        * Admin cost per recipient
        twoway ///
            (line admin_cost_per_recipient `tte' if `grp'==1, lpattern(solid)) ///
            (line admin_cost_per_recipient `tte' if `grp'==0, lpattern(dash)), ///
            title("Raw Trend — Admin Cost/Recip | Attempted Cohort `y'", size(medium)) ///
            ytitle("Admin Cost per Recipient", size(small)) ///
            xtitle("Years Relative to Attempt (`y')", size(small)) ///
            xline(0, lcolor(black)) xlabel(-5(1)5, labsize(small)) ///
            ylabel(, format(%9.0fc) labsize(small)) ///
            graphregion(color(white)) plotregion(margin(small)) ///
            legend(order(1 "Treated (`y')" 2 "Controls (never or ≥`= `y'+6')") ///
                   size(small) cols(2) pos(12) ring(1) region(lstyle(none)))
        graph export "`raw_dir'/attempted_admin/admin_attempted_`y'.png", width(1400) replace
    restore
}

* =========================
* C.2 Completed cohorts  (controls: no completion or initiation within -5..+5)
* =========================

* Use actual completion cohort years (no placebo here)
levelsof snap_comp_yr if !missing(snap_comp_yr), local(comp_years)

foreach y of local comp_years {
    preserve
        tempvar tte grp
        gen `tte' = Year - `y'
        keep if inrange(`tte', -5, 5)

        * Treated = states completing in year y
        * Controls = (never-completed OR completed in >= y+6)  AND  (never-initiated OR initiated in >= y+6)
        gen `grp' = .
        replace `grp' = 1 if snap_comp_yr == `y'
        replace `grp' = 0 if (missing(snap_comp_yr) | snap_comp_yr >= `y' + 6) ///
                           & (missing(snap_init_yr) | snap_init_yr >= `y' + 6)
        drop if missing(`grp')

        collapse (mean) Part_Prsn_Mnthly_Avg admin_cost_per_recipient, by(`tte' `grp')

        * Participation
        twoway ///
            (line Part_Prsn_Mnthly_Avg `tte' if `grp'==1, lpattern(solid)) ///
            (line Part_Prsn_Mnthly_Avg `tte' if `grp'==0, lpattern(dash)), ///
            title("Raw Trend — Participation | Completed Cohort `y'", size(medium)) ///
            ytitle("Monthly Avg Participants", size(small)) ///
            xtitle("Years Relative to Completion (`y')", size(small)) ///
            xline(0, lcolor(black)) xlabel(-5(1)5, labsize(small)) ///
            ylabel(, format(%12.0gc) labsize(small)) ///
            graphregion(color(white)) plotregion(margin(small)) ///
            legend(order(1 "Treated (`y')" 2 "Controls (init & comp ≥`= `y'+6' or never)") ///
                   size(small) cols(2) pos(12) ring(1) region(lstyle(none)))
        graph export "`raw_dir'/completed_participation/part_completed_`y'.png", width(1400) replace

        * Admin cost per recipient
        twoway ///
            (line admin_cost_per_recipient `tte' if `grp'==1, lpattern(solid)) ///
            (line admin_cost_per_recipient `tte' if `grp'==0, lpattern(dash)), ///
            title("Raw Trend — Admin Cost/Recip | Completed Cohort `y'", size(medium)) ///
            ytitle("Admin Cost per Recipient", size(small)) ///
            xtitle("Years Relative to Completion (`y')", size(small)) ///
            xline(0, lcolor(black)) xlabel(-5(1)5, labsize(small)) ///
            ylabel(, format(%9.0fc) labsize(small)) ///
            graphregion(color(white)) plotregion(margin(small)) ///
            legend(order(1 "Treated (`y')" 2 "Controls (init & comp ≥`= `y'+6' or never)") ///
                   size(small) cols(2) pos(12) ring(1) region(lstyle(none)))
        graph export "`raw_dir'/completed_admin/admin_completed_`y'.png", width(1400) replace
    restore
}


* ============================================
* Section 6: Traditional Event Study Analysis (TWFE) - Both Attempted and Completed
* ============================================
di "* Section 6: Running Traditional Event Study Analysis"

* --- Part A: Event Study for ATTEMPTED Modernization ---
capture drop time_to_event_init
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
eststo event_part_attempted: reghdfe `participation' `event_dummies_init' if !missing(time_to_event_init), absorb(State_num Year) vce(cluster State_num)
eststo event_costs_attempted: reghdfe `admin_costs' `event_dummies_init' if !missing(time_to_event_init), absorb(State_num Year) vce(cluster State_num)

* Plot for participation (attempted, logged)
coefplot event_part_attempted, keep(`event_dummies_init') vertical omitted baselevels yline(0, lcolor(black)) ciopts(recast(rcap)) ///
    title("Traditional Event Study (Attempted): Effect on Participation (in Logs)", size(large)) ///
    ytitle("Change in Log Participants (Approx. % Change)", size(medium)) ///
    xtitle("Years Relative to Modernization Attempt", size(medium)) ///
    graphregion(color(white)) ///
    rename(E_init_m5 = -5 E_init_m4 = -4 E_init_m3 = -3 E_init_m2 = -2 E_init_0 = 0 E_init_p1 = 1 E_init_p2 = 2 E_init_p3 = 3 E_init_p4 = 4 E_init_p5 = 5) ///
    ylabel(, format(%9.2f) labsize(medium)) xlabel(, labsize(medium))
graph export "`results_dir'/Event_Study_Traditional_Participation_Attempted_Logged.png", width(1000) replace

* Plot for admin costs per recipient (attempted, logged)
coefplot event_costs_attempted, keep(`event_dummies_init') vertical omitted baselevels yline(0, lcolor(black)) ciopts(recast(rcap)) ///
    title("Traditional Event Study (Attempted): Effect on Admin Costs per Recipient (in Logs)", size(medium)) ///
    ytitle(`"Change in Log Admin Costs per Recipient"' `"(Approx. % Change)"', size(medium)) ///
    xtitle("Years Relative to Modernization Attempt", size(medium)) ///
    graphregion(color(white)) ///
    rename(E_init_m5 = -5 E_init_m4 = -4 E_init_m3 = -3 E_init_m2 = -2 E_init_0 = 0 E_init_p1 = 1 E_init_p2 = 2 E_init_p3 = 3 E_init_p4 = 4 E_init_p5 = 5) ///
    ylabel(, format(%9.2f) labsize(medium)) xlabel(, labsize(medium))
graph export "`results_dir'/Event_Study_Traditional_Admin_Costs_Per_Recipient_Attempted_Logged.png", width(1000) replace

* --- Part B: Event Study for COMPLETED Modernization ---
capture drop time_to_event_comp
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
eststo event_part_completed: reghdfe `participation' `event_dummies_comp' if !missing(time_to_event_comp), absorb(State_num Year) vce(cluster State_num)
eststo event_costs_completed: reghdfe `admin_costs' `event_dummies_comp' if !missing(time_to_event_comp), absorb(State_num Year) vce(cluster State_num)

* Plot for participation (completed, logged)
coefplot event_part_completed, keep(`event_dummies_comp') vertical omitted baselevels yline(0, lcolor(black)) ciopts(recast(rcap)) ///
    title("Traditional Event Study (Completed): Effect on Participation (in Logs)", size(large)) ///
    ytitle("Change in Log Participants (Approx. % Change)", size(medium)) ///
    xtitle("Years Relative to Modernization Completion", size(medium)) ///
    graphregion(color(white)) ///
    rename(E_comp_m5 = -5 E_comp_m4 = -4 E_comp_m3 = -3 E_comp_m2 = -2 E_comp_0 = 0 E_comp_p1 = 1 E_comp_p2 = 2 E_comp_p3 = 3 E_comp_p4 = 4 E_comp_p5 = 5) ///
    ylabel(, format(%9.2f) labsize(medium)) xlabel(, labsize(medium))
graph export "`results_dir'/Event_Study_Traditional_Participation_Completed_Logged.png", width(1000) replace

* Plot for admin costs per recipient (completed, logged)
coefplot event_costs_completed, keep(`event_dummies_comp') vertical omitted baselevels yline(0, lcolor(black)) ciopts(recast(rcap)) ///
    title("Traditional Event Study (Completed): Effect on Admin Costs per Recipient (in Logs)", size(medium)) ///
    ytitle(`"Change in Log Admin Costs per Recipient"' `"(Approx. % Change)"', size(medium)) ///
    xtitle("Years Relative to Modernization Completion", size(medium)) ///
    graphregion(color(white)) ///
    rename(E_comp_m5 = -5 E_comp_m4 = -4 E_comp_m3 = -3 E_comp_m2 = -2 E_comp_0 = 0 E_comp_p1 = 1 E_comp_p2 = 2 E_comp_p3 = 3 E_comp_p4 = 4 E_comp_p5 = 5) ///
    ylabel(, format(%9.2f) labsize(medium)) xlabel(, labsize(medium))
graph export "`results_dir'/Event_Study_Traditional_Admin_Costs_Per_Recipient_Completed_Logged.png", width(1000) replace

di "Section 6: Traditional Event Study Analysis completed. Plots and tables saved to `results_dir'"


* ============================================
* Section 7: Callaway-Sant'Anna CSDID Analysis
* ============================================
di "* Section 7: Running Callaway-Sant'Anna Difference-in-Differences Analysis"

 /*
 * REQUIRED PACKAGE:
 * ssc install csdid, replace
 */

* --------------------------------------------
* Controls macro
* --------------------------------------------
local csdid_ctrl UnempRate_AnnNSA bbce

* --- Part A: CSDID for ATTEMPTED Modernization ---

* Prepare cohort variable for attempted modernization (never-treated -> 0)
capture drop cohort_init
gen cohort_init = snap_init_yr
replace cohort_init = 0 if missing(snap_init_yr)

* =========================
* NO CONTROLS (Attempted)
* =========================

* Participation (attempted, logged)
csdid `participation', ivar(State_num) time(Year) gvar(cohort_init) notyet
estat event, window(-5 5) estore(cs_part_attempted_nc)

esttab cs_part_attempted_nc using "`results_dir'/CS_DID_Participation_Attempted_Logged_NC.doc", replace ///
    title("CSDID (No Controls): Attempted Modernization on Participation (Logs)") ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N, fmt(%9.0f) labels("Observations"))

graph drop _all
estat event, window(-5 5)
csdid_plot, group(pooled) ///
    title("CSDID Event Study (Attempted, No Controls): Participation (Logs)", size(medium)) ///
    ytitle("Change in Log Participants" "(Approx. % Change)", size(medium) linegap(2)) ///
    xtitle("Years Relative to Modernization Attempt", size(medium)) ///
    graphregion(color(white)) ///
    ylabel(, format(%9.2f) labsize(medium)) xlabel(, labsize(medium)) ///
    name(csdid_part_att_nc, replace)
graph export "`results_dir'/CS_DID_Event_Study_Participation_Attempted_Logged_NC.png", width(1000) replace

* Admin costs per recipient (attempted, logged)
csdid `admin_costs', ivar(State_num) time(Year) gvar(cohort_init) notyet
estat event, window(-5 5) estore(cs_costs_attempted_nc)

esttab cs_costs_attempted_nc using "`results_dir'/CS_DID_Admin_Costs_Per_Recipient_Attempted_Logged_NC.doc", replace ///
    title("CSDID (No Controls): Attempted Modernization on Admin Costs per Recipient (Logs)") ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N, fmt(%9.0f) labels("Observations"))

estat event, window(-5 5)
csdid_plot, group(pooled) ///
    title("CSDID Event Study (Attempted, No Controls): Admin Costs per Recipient (Logs)", size(medium)) ///
    ytitle("Change in Log Admin Costs per Recipient" "(Approx. % Change)", size(medium) linegap(2)) ///
    xtitle("Years Relative to Modernization Attempt", size(medium)) ///
    graphregion(color(white)) ///
    ylabel(, format(%9.2f) labsize(medium)) xlabel(, labsize(medium)) ///
    name(csdid_costs_att_nc, replace)
graph export "`results_dir'/CS_DID_Event_Study_Admin_Costs_Per_Recipient_Attempted_Logged_NC.png", width(1000) replace


* ======================
* WITH CONTROLS (Attempted)
* ======================

* Participation (attempted, logged) + controls
csdid `participation' `csdid_ctrl', ivar(State_num) time(Year) gvar(cohort_init) notyet
estat event, window(-5 5) estore(cs_part_attempted_wc)

esttab cs_part_attempted_wc using "`results_dir'/CS_DID_Participation_Attempted_Logged_WC.doc", replace ///
    title("CSDID (With Controls): Attempted Modernization on Participation (Logs)") ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N, fmt(%9.0f) labels("Observations"))

graph drop _all
estat event, window(-5 5)
csdid_plot, group(pooled) ///
    title("CSDID Event Study (Attempted, With Controls): Participation (Logs)", size(medium)) ///
    ytitle("Change in Log Participants" "(Approx. % Change)", size(medium) linegap(2)) ///
    xtitle("Years Relative to Modernization Attempt", size(medium)) ///
    graphregion(color(white)) ///
    ylabel(, format(%9.2f) labsize(medium)) xlabel(, labsize(medium)) ///
    name(csdid_part_att_wc, replace)
graph export "`results_dir'/CS_DID_Event_Study_Participation_Attempted_Logged_WC.png", width(1000) replace

* Admin costs per recipient (attempted, logged) + controls
csdid `admin_costs' `csdid_ctrl', ivar(State_num) time(Year) gvar(cohort_init) notyet
estat event, window(-5 5) estore(cs_costs_attempted_wc)

esttab cs_costs_attempted_wc using "`results_dir'/CS_DID_Admin_Costs_Per_Recipient_Attempted_Logged_WC.doc", replace ///
    title("CSDID (With Controls): Attempted Modernization on Admin Costs per Recipient (Logs)") ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N, fmt(%9.0f) labels("Observations"))

estat event, window(-5 5)
csdid_plot, group(pooled) ///
    title("CSDID Event Study (Attempted, With Controls): Admin Costs per Recipient (Logs)", size(medium)) ///
    ytitle("Change in Log Admin Costs per Recipient" "(Approx. % Change)", size(medium) linegap(2)) ///
    xtitle("Years Relative to Modernization Attempt", size(medium)) ///
    graphregion(color(white)) ///
    ylabel(, format(%9.2f) labsize(medium)) xlabel(, labsize(medium)) ///
    name(csdid_costs_att_wc, replace)
graph export "`results_dir'/CS_DID_Event_Study_Admin_Costs_Per_Recipient_Attempted_Logged_WC.png", width(1000) replace


* --- Part B: CSDID for COMPLETED Modernization ---

* Prepare cohort variable for completed modernization (never-treated -> 0)
capture drop cohort_comp
gen cohort_comp = snap_comp_yr
replace cohort_comp = 0 if missing(snap_comp_yr)

* =========================
* NO CONTROLS (Completed)
* =========================

* Participation (completed, logged)
csdid `participation', ivar(State_num) time(Year) gvar(cohort_comp) notyet
estat event, window(-5 5) estore(cs_part_completed_nc)

esttab cs_part_completed_nc using "`results_dir'/CS_DID_Participation_Completed_Logged_NC.doc", replace ///
    title("CSDID (No Controls): Completed Modernization on Participation (Logs)") ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N, fmt(%9.0f) labels("Observations"))

graph drop _all
estat event, window(-5 5)
csdid_plot, group(pooled) ///
    title("CSDID Event Study (Completed, No Controls): Participation (Logs)", size(medium)) ///
    ytitle("Change in Log Participants" "(Approx. % Change)", size(medium) linegap(2)) ///
    xtitle("Years Relative to Modernization Completion", size(medium)) ///
    graphregion(color(white)) ///
    ylabel(, format(%9.2f) labsize(medium)) xlabel(, labsize(medium)) ///
    name(csdid_part_comp_nc, replace)
graph export "`results_dir'/CS_DID_Event_Study_Participation_Completed_Logged_NC.png", width(1000) replace

* Admin costs per recipient (completed, logged)
csdid `admin_costs', ivar(State_num) time(Year) gvar(cohort_comp) notyet
estat event, window(-5 5) estore(cs_costs_completed_nc)

esttab cs_costs_completed_nc using "`results_dir'/CS_DID_Admin_Costs_Per_Recipient_Completed_Logged_NC.doc", replace ///
    title("CSDID (No Controls): Completed Modernization on Admin Costs per Recipient (Logs)") ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N, fmt(%9.0f) labels("Observations"))

estat event, window(-5 5)
csdid_plot, group(pooled) ///
    title("CSDID Event Study (Completed, No Controls): Admin Costs per Recipient (Logs)", size(medium)) ///
    ytitle("Change in Log Admin Costs per Recipient" "(Approx. % Change)", size(medium) linegap(2)) ///
    xtitle("Years Relative to Modernization Completion", size(medium)) ///
    graphregion(color(white)) ///
    ylabel(, format(%9.2f) labsize(medium)) xlabel(, labsize(medium)) ///
    name(csdid_costs_comp_nc, replace)
graph export "`results_dir'/CS_DID_Event_Study_Admin_Costs_Per_Recipient_Completed_Logged_NC.png", width(1000) replace


* ======================
* WITH CONTROLS (Completed)
* ======================

* Participation (completed, logged) + controls
csdid `participation' `csdid_ctrl', ivar(State_num) time(Year) gvar(cohort_comp) notyet
estat event, window(-5 5) estore(cs_part_completed_wc)

esttab cs_part_completed_wc using "`results_dir'/CS_DID_Participation_Completed_Logged_WC.doc", replace ///
    title("CSDID (With Controls): Completed Modernization on Participation (Logs)") ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N, fmt(%9.0f) labels("Observations"))

graph drop _all
estat event, window(-5 5)
csdid_plot, group(pooled) ///
    title("CSDID Event Study (Completed, With Controls): Participation (Logs)", size(medium)) ///
    ytitle("Change in Log Participants" "(Approx. % Change)", size(medium) linegap(2)) ///
    xtitle("Years Relative to Modernization Completion", size(medium)) ///
    graphregion(color(white)) ///
    ylabel(, format(%9.2f) labsize(medium)) xlabel(, labsize(medium)) ///
    name(csdid_part_comp_wc, replace)
graph export "`results_dir'/CS_DID_Event_Study_Participation_Completed_Logged_WC.png", width(1000) replace

* Admin costs per recipient (completed, logged) + controls
csdid `admin_costs' `csdid_ctrl', ivar(State_num) time(Year) gvar(cohort_comp) notyet
estat event, window(-5 5) estore(cs_costs_completed_wc)

esttab cs_costs_completed_wc using "`results_dir'/CS_DID_Admin_Costs_Per_Recipient_Completed_Logged_WC.doc", replace ///
    title("CSDID (With Controls): Completed Modernization on Admin Costs per Recipient (Logs)") ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N, fmt(%9.0f) labels("Observations"))

estat event, window(-5 5)
csdid_plot, group(pooled) ///
    title("CSDID Event Study (Completed, With Controls): Admin Costs per Recipient (Logs)", size(medium)) ///
    ytitle("Change in Log Admin Costs per Recipient" "(Approx. % Change)", size(medium) linegap(2)) ///
    xtitle("Years Relative to Modernization Completion", size(medium)) ///
    graphregion(color(white)) ///
    ylabel(, format(%9.2f) labsize(medium)) xlabel(, labsize(medium)) ///
    name(csdid_costs_comp_wc, replace)
graph export "`results_dir'/CS_DID_Event_Study_Admin_Costs_Per_Recipient_Completed_Logged_WC.png", width(1000) replace


* --- Part C: Summary & Cleanup ---
di "Summary of Attempted Modernization Cohorts:"
tab cohort_init, missing

di "Summary of Completed Modernization Cohorts:"
tab cohort_comp, missing

drop cohort_init cohort_comp

di "Section 7 complete: 8 plots (NC & WC) and 4 tables saved to `results_dir'."
