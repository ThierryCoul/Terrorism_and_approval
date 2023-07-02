// Merging the Gallup data to the terrorism dataset ****************************
use "../Temporary/Gallup_merged.dta", clear

* Merging the variable
cap drop if missing(WP4)
sort COUNTRY_ISO3 WP4

rename regionid_m regionid_m_survey

* Lopping over the GTDB and ACLED dataset
foreach conflict_id in GTDB {
	gen date_data_`conflict_id' =.
	label var date_data_`conflict_id' "Number of days before `conflict_id' conflict occured before the interview"

	* Merging the survey with the conflicts that occured anteriously upto 31 days
	forvalues i=1(1)31 {
		gen conflict_date = WP4 - `i'
		format conflict_date %tdD_m_Y
		label var conflict_date "date of the interview minus `i' day"

		merge m:1 COUNTRY_ISO3 conflict_date using "..\Temporary\Armed_conflicts_`conflict_id'_ISO.dta", update
		cap drop if _merge == 2
		replace date_data_`conflict_id' = `i' if _merge == 5 & missing(date_data_`conflict_id') | _merge == 4
		cap drop _merge conflict_date
	*
	}
	
	* Merging the survey with the conflicts that occured posteriously upto 31 days
	forvalues i=1(1)31 {
	*
		gen conflict_date = WP4 + `i'
		format conflict_date %tdD_m_Y
		label var conflict_date "date of the interview plus `i' day"

		merge m:1 COUNTRY_ISO3 conflict_date using "..\Temporary\Armed_conflicts_`conflict_id'_ISO.dta", update
		cap drop if _merge == 2
		replace date_data_`conflict_id' = -`i' if _merge == 5 & missing(date_data_`conflict_id') | _merge == 4
		cap drop _merge conflict_date
	}
	
	* Creating a post-conflict variable
	gen Post_`conflict_id' =.
	replace Post_`conflict_id' = 0 if date_data_`conflict_id' < 0 & !missing(date_data_`conflict_id')
	replace Post_`conflict_id' = 1 if date_data_`conflict_id' > 0 & !missing(date_data_`conflict_id')
}

label var Post_GTDB "Post-attack"
label var date_data_GTDB "Number of days relative to the attack"

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// Cleaning the main variables of the dataset **********************************
* Dropping observations where all values of variables of interest are missing
cap drop if missing(date_data_GTDB) & missing(Post_GTDB)

* Restricting the analyses to countries with respondents before and after terrorist attack
* Generating a variable containing the largest number of days after the attacks per country
bysort COUNTRY_ISO3: egen max_date_conflict = max(date_data_GTDB)

* Generating a variable containing the largest number of days before the attacks per country
bysort COUNTRY_ISO3: egen min_date_conflict = min(date_data_GTDB)

* Generating a dummy variable checking whether all interviewees are selected before or after an attack per country
* Countries where this dummy is negative are balanced
gen dummy = max_date_conflict * min_date_conflict
tab COUNTRY_ISO3 if dummy < 0

* Dropping observations where samples are not balanced by days within countries 
cap drop if dummy > 0

* Generating a President approval variable
gen Leader_approval = 0
lab var Leader_approval "Leader's approval"
replace Leader_approval = 1 if !missing(WP13125) & WP13125 == 1
replace Leader_approval = 1 if !missing(WP6879) & WP6879 == 1
replace Leader_approval = . if missing(WP6879) & missing(WP13125)

* Generating a variable for confidence in honesty of election
gen honesty_election = .
replace honesty_election = 1 if !missing(WP144) & WP144 == 1
replace honesty_election = 0 if !missing(WP144) & WP144 == 2
lab var honesty_election "Honesty of elections"

* Generating a variable for perception of corruption
gen corruption_Gvt = .
replace corruption_Gvt = 1 if !missing(WP146) & WP146 == 1
replace corruption_Gvt = 0 if !missing(WP146) & WP146 == 2
lab var corruption_Gvt "Corruption in government"

* Confidence in the national government
gen confidence_Gvt = .
replace confidence_Gvt = 1 if !missing(WP139) & WP139 == 1
replace confidence_Gvt = 0 if !missing(WP139) & WP139 == 2
lab var confidence_Gvt "Confidence in national government"

* Reformating the following control variables
* Gender
gen female =(WP1219==2)
label var female "Female"

* Age and age squared
rename WP1220 age
label var age "Age"
gen age_sq = age*age
label var age_sq "Age squared"

* Generating a variable containing three groups of equal sizes by age
xtile age_qtl = age, nq(3)

label define age_qtl 1 "15 - 26" 2 "27 - 40" 3 "41 - 97+", modify
label values age_qtl age_qtl

* Marital status
gen married =(WP1223 ==2 | WP1223 ==8)
replace married=. if WP1223 ==6 | WP1223 ==7 
label var married "Married"

* Number of children
rename WP1230 number_child_under_15
replace number_child_under_15 =. if number_child_under_15 > 97
label var number_child_under_15 "Children under 15"

* Education level
gen edu_primary = (WP3117==1)
label var edu_primary "Primary education or less"

gen edu_second = (WP3117==2)
label var edu_second "Secondary education"

gen edu_college = (WP3117==3)
label var edu_college "College education"

* Generating a variable containing the levels of education
gen education = edu_primary * 1 + edu_second * 2 + edu_college* 3
replace education =. if education==0

label define education 1 "Primary" 2 "Secondary" 3 "Tertiary", modify
label values education education 

* Income (logarithm of income)
gen lnindinc=ln(1+INCOME_4)
label var lnindinc "Log of household income plus one"

* Religion (Muslima and christian). There are the most frequent in the data
gen muslim = (WP1233RECODED==2)
label var muslim "Muslim"

gen christian = (WP1233RECODED==1)
label var christian "Christian"

* Generating an unemployment variable
gen Unemployed = (EMP_2010==4)
label var Unemployed "Unemployed"

* Generating a variable for perception of corruption in the private sector
gen corruption_Business = .
replace corruption_Business = 1 if !missing(WP146) & WP145 == 1
replace corruption_Business = 0 if !missing(WP146) & WP145 == 2
lab var corruption_Business "Corruption in business"

* Generating a variable for urban-dwellers
gen urban =.
replace urban = 0 if WP14 <=2
replace urban = 1 if WP14 ==3 | WP14 ==6 
label var urban "Urban residents (WP14==3 | WP14==6)"

* Generating a variable denoting birth in country of interviews
gen home_country_birth =(WP4657==1)
replace home_country_birth=. if home_country_birth >2
label var home_country_birth "Born in home country"

* Generating an optimism variable
gen optimism =.
replace optimism = 0 if WP30 == 2
replace optimism = 1 if WP30 == 1
label var optimism "Satisfaction with living condition"

* Generating a variable denoting the satisfaction with income
gen satis_income = (WP2319 < 3)
replace satis_income =. if WP2319>=5
label var satis_income "Satisfaction with income"

* Generating a satisfaction with health variable
rename WP23 satis_health
replace satis_health = 0 if satis_health == 2
label var satis_health "Satisfaction with health"

* Generating a feeling of security variable
rename WP113 safety_night_walk
replace safety_night_walk =. if safety_night_walk >= 3
gen security_feeling =(safety_night_walk==1)
label var security_feeling "Neighborhood safety"

* Generating a statisfaction with health variable
replace satis_health =. if satis_health >= 3
replace satis_health =0 if satis_health==2
label var satis_health "Satisfied with health"

* Generating a condidence with police variable
rename WP112 confidence_local_police
replace confidence_local_police =. if confidence_local_police >= 3
replace confidence_local_police = 0 if confidence_local_police==2
label var confidence_local_police "Confidence in local police"

* Generating an importance of religion variable
rename WP119 religious_important
replace religious_important =. if religious_important >= 3
label var religious_important "Importance of religion"

* Generating a confidence in military variable
rename WP137 confidence_military
replace confidence_military =. if confidence_military >= 3
label var confidence_military "Confidence in military nationally (yes= 1, no=2) - WP137"

* Generating a confidence in justice variable
rename WP138 confidence_justice
replace confidence_justice =. if confidence_justice >= 3
replace confidence_justice = 0 if confidence_justice ==2
label var confidence_justice "Confidence in judicial system"

* Generating a variable for approval of foreign leadership
rename WP151 approval_US
replace approval_US =. if approval_US >= 3
replace approval_US = 0 if approval_US==2
label define approval_US 0 "Disapprove" 1 "Approve", modify
label values approval_US approval_US
label var approval_US "Approval of U.S. leadership"

rename WP156 approval_China
replace approval_China =. if approval_China >= 3
replace approval_China = 0 if approval_China==2
label define approval_China 0 "Disapprove" 1 "Approve", modify
label values approval_China approval_China
label var approval_China "Approval of China leadership"

rename WP155 approval_Russia
replace approval_Russia =. if approval_Russia >= 3
replace approval_Russia = 0 if approval_Russia==2
label define approval_Russia 0 "Disapprove" 1 "Approve", modify
label values approval_Russia approval_Russia
label var approval_Russia "Approval of Russia leadership"



* Replace the value of the variables
foreach var in vanilla FK RILE speech policy self {
	gen `var'_code = .
	label var `var'_code "1=right; 2=center-right; 3=center; 4=center-left; 5=left"
	replace `var'_code = 4 if strpos(pol_ori_`var', "-left") > 0
	replace `var'_code = 2 if strpos(pol_ori_`var', "-right") > 0
	replace `var'_code = 1 if strpos(pol_ori_`var', "Right") > 0 | strpos(pol_ori_`var', "Conservative") > 0
	replace `var'_code = 5 if strpos(pol_ori_`var', "Left") > 0
	replace `var'_code = 3 if strpos(pol_ori_`var', "Centrist") > 0 | strpos(pol_ori_`var', "Center.") > 0

	* This part is used to correct values of leaders with several occurence
	bysort leader_group_ISO: egen `var'_code_2 = mean(`var'_code)
	replace `var'_code = `var'_code_2
	cap drop `var'_code_2
}

* Rounding the values of political ideoligies
foreach var in vanilla_code FK_code RILE_code speech_code policy_code self_code {
	replace `var' = round(`var')
	replace `var' = 1 if `var' < 3
	replace `var' = 5 if `var' > 3
}

* Generating a variable denoting the average level of democracy of countries 
egen mpolity2 = mean(polity2), by(leader_group_ISO)
label var mpolity2 "Average Polity2 score over the year"

* At the level 5 - dummy 5
gen democ5=(polity2>5)
replace democ5=. if polity2==.
label var democ5 "Polity2 score > 5"

* At the level 7 - dummy 7
gen democ7=(polity2>7)
replace democ7=. if polity2==.
label var democ7 "Polity2 score > 7"

* Performing a Principal Component Analysis (PCA) for all dependent variables
pca Leader_approval corruption_Gvt honesty_election
predict score
sum score
scalar M=r(min)
scalar M2=r(max)
gen pr_component=(score-M)/(M2-M)
label var pr_component "1st principal component of government approval variables"

* Generating a double cluster
egen double_cluster=group(leader_group_ISO regionid_m)

* Generating a variable describing the levels of terrorism in countries in 3 groups
xtile terro_country = sum_country_terro, nq(3)

* Generating a variable denoting the success of terrorist attacks
gen tero_success = (success > 0)

* Reformating the variables of the intensity of the attack
gen ln_nkillat = ln(nkillat)
label var ln_nkillat "Log of number of victim"

gen ln_nbr_attack = ln(nbr_attack)
label var ln_nkillat "Log of number of attack"

* Creating a corruption level category
bysort leader_group_ISO: egen mean_corruption = mean(corruption)
xtile corruption_leader_ISO_cat = mean_corruption, nq(3)


//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// Dropping useless variables **************************************************
* Dropping variables where all observations are missing
missings dropvars, force

cap drop REG*
cap drop WP10*
cap drop WP11*
cap drop WP5034 WP5035 WP5036 WP5037 WP5038 WP5039 WP52 WP5243 WP5244 WP5245 WP5249 WP5250 WP53 WP5319 WP5331 WP5354 WP5475 WP5530 WP5751 WP5767 WP5884 WP59 WP5AA
cap drop WP9*
cap drop WP40 WP4181 WP4207 WP4223 WP4224 WP4225 WP4226 WP4227 WP4228 WP4229 WP4230 WP4231 WP4232 WP4233 WP4234 WP43 WP44 WP4633 WP4645 WP4646 WP4647 WP4648 WP4649 WP4650 WP4652 WP4653 WP4654 WP4655 WP4656 WP4754 WP4755 WP4759 WP4765 WP4826 WP4827 WP4828 WP4829 WP4830 WP4831 WP4832 WP4833 WP4834 WP4835 WP4837 WP4839 WP4847 WP4868 WP4869 WP4870 WP4871 WP4872 WP4890 WP4891 WP4893 WP4899 WP4941 WP4944 WP4996 WP4997
cap drop INDEX*
cap drop EMP_FTEMP EMP_FTEMP_POP EMP_LFPR EMP_UNDER EMP_UNEMP EMP_WORK_HOURS WP12233 WP21758 WP21761 WP697 WP800
cap drop WP144

* Creating a continental variables
kountry COUNTRY_ISO3, from(iso3c) geo(un)

rename GEO global_region_5
label var global_region_5 "Five continents"
cap drop NAMES_STD

kountry COUNTRY_ISO3, from(iso3c) geo(undet)
rename GEO  global_region_11
label var global_region_11 "World in 11 blocks"

* Generating a dummy variable for time period 
gen date_5 = (date_data_GTDB>=-5 & date_data_GTDB<= 5)
gen date_1 = (date_data_GTDB>=-1 & date_data_GTDB<= 1)

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// Dropping useless observations ***********************************************
keep if !missing(leader_group_ISO) & !missing(WP4)

gen dummy_all_var =.

replace dummy_all_var = 1 if !missing(Leader_approval) & !missing(confidence_Gvt) & !missing(honesty_election) & !missing(corruption_Gvt) & !missing(Post_GTDB) & !missing(female) & !missing(age) & !missing(married) & !missing(INCOME_4) & !missing(number_child_under_15) & !missing(edu_primary) & !missing(edu_second) & !missing(edu_college) & !missing(home_country_birth) & !missing(muslim) & !missing(optimism) & !missing(satis_income) & !missing(security_feeling) & !missing(satis_health) & !missing(confidence_justice) & !missing(confidence_local_police)

keep if dummy_all_var==1
keep if date_data_GTDB <= 15 & date_data_GTDB >= -15 

save "../Output/Gallup_merged_with_conflicts_regions_altern_country_level.dta", replace

//!!!!!!!!!!!!!!!!  END   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
