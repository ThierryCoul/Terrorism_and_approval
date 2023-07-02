// 1. Importing control varibles of other sources

* Importing the district average population ***********************************
foreach index in 1 2 {
	forvalues year=2008(1)2020{
		import dbase "../Temporary/Table_GWP_`index'_`year'.dbf", clear
		keep regionid_m MEAN SUM 
		rename MEAN population_density
		label var population_density "Population density"
		rename SUM population_total
		label var population_total "Total population"
		gen year = `year'
		
		save "..\Temporary\Pop_`index'_`year'.dta", replace
	}
}

* Appending the files
clear
cd "../Temporary"
local theFiles: dir . files "Pop_*.dta"
di `theFiles'
append using `theFiles'

* Deleting intermediary files from memory
save "..\Temporary\Population.dta", replace
foreach file in `theFiles' {
	erase `file'
}

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// Exporting leaders' names to ChatGPT importing their ideologies **************
use "../Temporary/Gallup_merged.dta", clear

* Keeping the leader name variable
keep leader_name id

*dropping missing values
drop if missing(leader_name)

* Keeping unique values
duplicates drop leader_name, force
sort leader_name

* Exporting the output to a csv file
export delimited "..\Temporary\Leader_name.csv", replace

/*
After classifying leader with ChatGPT, we resume our work here.
*/

* Saving the file containing the list of presidents
tempfile Leaders
save `Leaders'

* Importing the file with presidents and their vanilla ideologies 
import delimited "C:\Users\Coulibaly Yerema\OneDrive - Kyushu University\Desktop\Works_with_jupyter_notebook\Political_orientation.csv", varnames(1) clear
rename leader_name leader_1 

* Merging the vanilla ideologies with leaders
merge 1:1 id using `Leaders'
drop _merge

* Generating a group variable that split leaders into unique observations
strgroup leader_1, gen(leader_group_ISO) threshold(0.25) force

* Renaming the variables
rename political_orientation_1 pol_ori_vanilla
rename political_orientation_2 pol_ori_FK
rename political_orientation_3 pol_ori_RILE
rename political_orientation_4 pol_ori_speech
rename political_orientation_5 pol_ori_policy
rename political_orientation_6 pol_ori_self

label var pol_ori_vanilla "Political orientation - vanilla method"
label var pol_ori_FK "Political orientation - Franzmann and Kaiser method"
label var pol_ori_RILE "Political orientation - RILE method"
label var pol_ori_speech "Political orientation - speech content"
label var pol_ori_policy "Political orientation - political actions"
label var pol_ori_self "Political orientation - self-identification"

* Saving saving the new variables
save "../Temporary/Political_orientation.dta", replace

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// Importing the democracy index variable **************************************
* Importing the table from csv
import delimited "../Input/democracy.csv", clear

* Dropping useless variables
keep code year electdem_vdem_owid

* Renaming variables for merging
rename code COUNTRY_ISO3 
rename electdem_vdem_owid Elect_demoncracy
label var Elect_demoncracy

* Dropping useless observations
drop if missing(COUNTRY_ISO3)

* Saving the file as a dta format
save "../Temporary/democracy.dta", replace

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// Importing the classifcation of countries by income level
import excel "../Input/Income_level_country.xlsx", firstrow clear
save "../Temporary/Income_group.dta", replace

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


// 2. Merging the control variables ********************************************

** Policitical orientation of the national leader*******************************
use "../Temporary/Gallup_merged.dta", clear
merge m:1 id using "../Temporary/Political_orientation.dta"
drop _merge

** Corruption scandals from IMF ***********************************************
merge m:1 COUNTRY_ISO3 year using "..\Input\corruption_incidents_IMF.dta"
drop if _merge==2
drop _merge weo_code country_name

rename ratio2 corruption
label variable corruption "Actual corruption incidents (GICI)"

** Democracy index *************************************************************
merge m:1 COUNTRY_ISO3 year using "..\Input\polity5.dta"
drop if _merge==2
drop _merge cyear polityIV_ccode polityIV_country flag fragment democ  ///
polity autoc durable xrreg xrcomp xropen xconst parreg parcomp exrec /// 
exconst polcomp prior emonth eday eyear eprec interim bmonth bday byear bprec ///
post change d4 sf regtrans extended_country_name GWn cown in_GW_system

** The centroids of the regions of the respondent ******************************
merge m:1 districtid using "../Input/centroid_coord.dta"
drop if _merge==2
drop _merge

** Countries' level of democracy **********************************************
merge m:1 COUNTRY_ISO3 year using "../Temporary/democracy.dta"
drop if _merge ==2 
drop _merge
rename Elect_demoncracy Elect_democracy

* Saving the file
save "../Temporary/Gallup_merged.dta", replace
//!!!!!!!!!!!!!!!!!!!!!!!!!!!   END  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
