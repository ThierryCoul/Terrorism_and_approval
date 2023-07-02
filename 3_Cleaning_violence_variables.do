// Exporting the geospatial variables of the conflicts data ********************
* Using the ACLED data
use "../Input/Armed_conflicts_ACLED.dta", clear

* Keeping the geospatial data
keep data_id longitude latitude

* Exporting the data to csv
export delimited "../Temporary/ACLED.csv", replace

* Using the GTD data
import excel "../Input/globalterrorismdb_0522dist.xlsx", firstrow clear

* Saving the data as a stata file
save globalterrorism, replace

* Keeping the geospatial data
keep eventid longitude latitude

* Exporting the data to csv
export delimited "../Temporary/GTDB.csv", replace
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

/*
After this step, geospatial analyses were performed on ArcGIS to merge violence 
data with regional level of analses used by Gallup
*/

// Importing the ACLED and GTDB data spatially merged with GWP to stata ********
* Looping over the GTDB files corresponing to different regional levels of Gallup
foreach i in "1" "2" {
 
	* Importing the GTDB data merged with level 1 subnational data
	import dbase "..\Temporary\GTDB_level`i'.dbf", clear

	* Merging with the GTDB variables
	merge 1:1 eventid using "../Input/globalterrorism.dta"

	* Keeping observations with non-missing correspondance with GWP
	keep if regionid_m != 0 & !missing(regionid_m)

	* Saving the file
	save "../Temporary/GTDB_level`i'.dta", replace
	}

* Appending the GTDB levels 1 and 2 files
append using "../Temporary/GTDB_level1.dta"

* Saving the file
save "../Temporary/GTDB_merged_GWP.dta", replace

* Deleting the GTDB intermediary files
erase "../Temporary/GTDB_level1.dta"
erase "../Temporary/GTDB_level2.dta"

* Looping over ACLED files corresponing to different regional levels of Gallup
foreach i in "1" "2" {
    if "`i'" == "1" {
		local var_to_drop Join_Count TARGET_FID ID_0 ISO ID_1 HASC_1 CCN_1 CCA_1 TYPE_1 ENGTYPE_1 NL_NAME_1 VARNAME_1 NAME_ENGLI _merge admin3 admin2 admin1 event_date_month event_date_year ADM1_EN ADM1_REF ADM0_EN ADM0_PCODE REGION timestamp event_id_cnty event_id_no_cnty region country iso3
		}
	else {
	    local var_to_drop Join_Count TARGET_FID ID_0 ISO ID_1 ID_2 TYPE_2 ENGTYPE_2 event_id_cnty event_id_no_cnty region country timestamp iso3 event_date_year event_date_month layer _merge
	}
	
	* Importing the ACLED data with countries with level 1 subnational data
	import dbase "..\Temporary\ACLED_leveL_`i'.dbf", clear

	* Merging with the ACLED variables
	merge 1:1 data_id using Armed_conflicts_ACLED

	* Keeping observations with non-missing correspondance with GWP
	keep if regionid_m != 0 & !missing(regionid_m)

	* Removing unecessary variables
	drop `var_to_drop'
		
	* Saving the file
	save "../Temporary/ACLED_leveL_`i'.dta", replace
} 

* Appending the ACLED levels 1 and 2 files
append using "../Temporary/ACLED_level1.dta"

* Saving the file
save "../Temporary/ACLED_merged_GWP.dta", replace

* Further cleaning of the data_id
drop admin1 admin2 admin3

* Deleting the ACLED intermediary files
erase "../Temporary/ACLED_level1.dta"
erase "../Temporary/ACLED_level2.dta"

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


// Cleaning the GTDB ***********************************************************
* Loading the terrorism dataset
use "../Temporary/GTDB_merged_GWP.dta", clear

* Filternig the data
keep if iyear >=2008

* Dropping observations where the responsible is not associated to a group terrorist
*drop if individual==1

* generating a variable to investigate the count the number of times the name of terrorist group appears
bysort gname: egen count_gname=count(gname)

* Coding the terrorist organizations
/*
// From literature
gen Alquaeda_code = .
replace Alquaeda_code = 1 if strpos(gname, "Al-Qaida") > 0
replace Alquaeda_code = 1 if strpos(gname, "Al-Nusrah Front") > 0
replace Alquaeda_code = 1 if strpos(gname, "Hay'at Tahrir al-Sham") > 0
replace Alquaeda_code = 1 if strpos(gname, "JNIM") > 0
replace Alquaeda_code = 1 if strpos(gname, "Al-Shabaab") > 0 & iyear >= 2012
replace Alquaeda_code = 1 if strpos(gname, "Mujahedeen Shura") > 0

gen ISIL_code = .
replace ISIL_code = 1 if strpos(gname, "Islamic State in the Greater Sahara") > 0
replace ISIL_code = 1 if strpos(gname, "Boko Haram") > 0
replace ISIL_code = 1 if strpos(gname, "ASG") > 0
replace ISIL_code = 1 if strpos(summary, "ISIL") > 0
replace ISIL_code = 1 if strpos(summary, "Daesh") > 0
replace ISIL_code = 1 if strpos(summary, "ISIS") > 0 & strpos(summary, "anti-ISIS") == 0

//Self-made

gen Alquaeda_code = .
replace Alquaeda_code = 1 if strpos(gname, "Al-Qaida") > 0
replace Alquaeda_code = 1 if strpos(gname, "Al-Shabaab") > 0
replace Alquaeda_code = 1 if strpos(gname, "Al-Nusrah Front") > 0
replace Alquaeda_code = 1 if strpos(gname, "Jamaat") > 0
replace Alquaeda_code = 1 if strpos(gname, "al-Sharia") > 0
replace Alquaeda_code = 1 if strpos(gname, "Ansar al-Islam") > 0
replace Alquaeda_code = 1 if strpos(gname, "Tehrik-i-Taliban Pakistan") > 0
replace Alquaeda_code = 1 if strpos(gname, "Nusrat") > 0


gen ISIL_code = .
replace ISIL_code = 1 if strpos(gname, "Boko Haram") > 0
replace ISIL_code = 1 if strpos(gname, "Khilafah") > 0
replace ISIL_code = 1 if strpos(gname, "Ansar al-Tawhid") > 0
replace ISIL_code = 1 if strpos(gname, "Islamic State in the Greater Sahara") > 0
replace ISIL_code = 1 if strpos(gname, "Sinai") > 0
replace ISIL_code = 1 if strpos(gname, "Khorasan Chapter") > 0
replace ISIL_code = 1 if strpos(gname, "Khorasan jihadi") > 0
replace ISIL_code = 1 if strpos(gname, "Islamic State") > 0
replace ISIL_code = 1 if strpos(gname, "ASG") > 0
*/

gen Alquaeda_code = .
replace Alquaeda_code = 1 if strpos(gname, "Al-Qaida") > 0
replace Alquaeda_code = 1 if strpos(gname, "Al-Nusrah Front") > 0
replace Alquaeda_code = 1 if strpos(gname, "Hay'at Tahrir al-Sham") > 0
replace Alquaeda_code = 1 if strpos(gname, "JNIM") > 0
replace Alquaeda_code = 1 if strpos(gname, "Al-Shabaab") > 0 & iyear >= 2012
replace Alquaeda_code = 1 if strpos(gname, "Mujahedeen Shura") > 0
replace Alquaeda_code = 1 if strpos(gname, "al-Sharia") > 0
replace Alquaeda_code = 1 if strpos(gname, "Imam Shamil Battalion") > 0
replace Alquaeda_code = 1 if strpos(gname, "Tawhid and Jihad (Palestine") > 0

gen ISIL_code = .
replace ISIL_code = 1 if strpos(gname, "Islamic State in the Greater Sahara") > 0
replace ISIL_code = 1 if strpos(gname, "Boko Haram") > 0
replace ISIL_code = 1 if strpos(gname, "ASG") > 0
replace ISIL_code = 1 if strpos(summary, "ISIL") > 0
replace ISIL_code = 1 if strpos(summary, "Daesh") > 0
replace ISIL_code = 1 if strpos(gname, "Islamic State") > 0
*replace ISIL_code = 1 if strpos(summary, "ISIS") > 0 & strpos(summary, "anti-ISIS") == 0
replace ISIL_code = 1 if strpos(gname, "Jund al-Khilafah (Tunisia") > 0
replace ISIL_code = 1 if strpos(gname, "Khorasan jihadi") > 0


keep if ISIL_code==1 | Alquaeda_code==1


replace Alquaeda_code = 1 if strpos(summary, "Al-Qaida") > 0
* We do not put the 2nd condition for ISIL because

replace ISIL_code = 1 if strpos(summary, "ISIL") > 0
replace ISIL_code = 1 if strpos(summary, "Daesh") > 0
replace ISIL_code = 1 if strpos(summary, "ISIS") > 0 & strpos(summary, "anti-ISIS") == 0
*replace ISIL_code = 1 if strpos(summary, "Jihad") > 0

keep if ISIL_code==1 | Alquaeda_code==1

* Dropping in the day of the event is unknown
drop if iday==0

* Keeping observations the best geo-localisation
keep if specificity<5
*keep if targtype1==14 | 

* Generating a varaible equal to 1
gen nbr_attack = 1
label var nbr_attack "Number of attack"

* Collapsing the data at the regional level
collapse (sum) nkill nkillter nwound nwoundte nbr_attack success Alquaeda_code ISIL_code, by(ISO regionid_m iyear imonth iday)

* Estimating the nummber of victims
gen nkillat = nkill - nkillter
gen nwoundat = nwound - nwoundte

* Generating a variable containing the number of attacks per country
bysort ISO: egen sum_country_terro = sum(nbr_attack)

* Generating a date variable
egen date = concat(iday imonth iyear), punct("/")
generate conflict_date = date( date , "DMY")
format conflict_date %tdD_m_Y
label var conflict_date "date"
gen week = week(conflict_date)
label var week "Week"

* Dropping observations that seem inconsistent
*drop if nwoundat < 0 | nkillat < 0
bysort regionid_m (conflict_date): gen cum_attacks = nbr_attack[1]
bysort regionid_m (conflict_date): replace cum_attacks = nbr_attack[_n]+ cum_attacks[_n-1] if _n>1

* Relabeling variables
label var nkillat "Fatalities from victims"
label var nwoundat "Wounded from victims"
label var nkill "Fatalities total"
label var nkillter "Fatalities from assiallants"
label var nwound "Wounded total"
label var nwoundte "Wounded from assiallants"
rename iyear year
rename imonth month
rename iday day

gen id_date_terro = _n

* Saving the GTDB conflict variable
save "../Temporary/Armed_conflicts_GTDB.dta", replace

* Renaming the country variable
rename ISO COUNTRY_ISO3
drop if COUNTRY_ISO3=="0"

* Merging the data with the county income level classification
merge m:1 COUNTRY_ISO3 using  "../Temporary/Income_group.dta"
drop if _merge==2
drop _merge Country
label var IncomeGroup "WBG Income Group"

* Collapsing the data by country and date
collapse (sum) nkill nkillter nkillat nwound nwoundte nbr_attack success Alquaeda_code ISIL_code sum_country_terro, by(COUNTRY_ISO3 conflict_date IncomeGroup)

gen id_date_terro = _n

* Saving country level dataset of conflicts
save "../Temporary/Armed_conflicts_GTDB_ISO.dta", replace

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// Cleaning variables from the ACLED conflicts data ****************************
* Loading the conflict dataset
use "../Temporary/ACLED_merged_GWP.dta", clear

* Keeping observations where the exact date the attack is known
keep if time_precision==1

* Keeping protest variables
keep if event_type=="Protests" | event_type=="Riots"

* Creating a variable by event type
encode event_type, gen(violence_type)
gen violence_type_figure = violence_type
 
levelsof violence_type_figure, local(levels)
foreach l of local levels {
	gen fatalities_`l' =.
	replace fatalities_`l' = fatalities if violence_type_figure ==`l'
}

* Collapsing the data at the regional level
collapse (sum) fatalities*, by(regionid_m year event_date_day month)

* Attributing proper format to variables
format year %9.0g

* Generating a date variable
egen date = concat(event_date_day month year), punct("/")
generate conflict_date = date( date , "DMY")
format conflict_date %tdD_m_Y
label var conflict_date "date"
gen week = week(conflict_date)
label var week "Week of the year"

* Relabeling variables
label var fatalities_1 "Fatalities from Protests"
label var fatalities_2 "Fatalities from Riots"
rename event_date_day day
destring day, replace
drop date

* Saving the ACELD conflict variable
save "../Temporary/Armed_conflicts_ACLED.dta", replace

//!!!!!!!!!!!!!!!!!!!!!!!!!!!   END  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!