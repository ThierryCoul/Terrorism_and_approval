// STATISTICAL ANALYSES ********************************************************
* Loading the data
use "../Output/Gallup_merged_with_conflicts_regions_altern.dta", clear

* Setting the variables
global dependent_variable Leader_approval confidence_Gvt honesty_election corruption_Gvt
global interest_variable Post_GTDB
global controls female age married lnindinc number_child_under_15 edu_* home_country_birth muslim urban Unemployed
global test_variables optimism satis_income satis_health confidence_local_police confidence_military 


//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

*F3* Visual representation terrorist attacks by year ***************************
use "../Temporary/GTDB_merged_GWP.dta", clear
rename ISO COUNTRY_ISO3
rename iyear year
drop _merge
merge m:1 COUNTRY_ISO3 using  "../Temporary/Income_group.dta"
drop if _merge==2

gen nbr_attack = 1
drop if missing(IncomeGroup)
keep if year>2008
collapse (sum) nbr_attack, by(year IncomeGroup)
*/
* use "../Temporary/Armed_conflicts_GTDB.dta", replace

* Collapsiong the dataset by year and income group

* Reshaping the data by year
replace IncomeGroup = "H" if IncomeGroup=="High income"
replace IncomeGroup = "L" if IncomeGroup=="Low income"
replace IncomeGroup = "LM" if IncomeGroup=="Lower middle income"
replace IncomeGroup = "UM" if IncomeGroup=="Upper middle income"

reshape wide nbr_attack, i(year) j(IncomeGroup) string

* Creating percentage values
egen total_nbr_attack = rowtotal(nbr_attackH nbr_attackL nbr_attackLM nbr_attackUM)

foreach var in nbr_attackH nbr_attackL nbr_attackLM nbr_attackUM {
	replace `var' = 0 if missing(`var')
	gen perc_`var' = `var' / total_nbr_attack
}


* Graphing the data
graph bar (mean) perc_nbr_attackL perc_nbr_attackLM perc_nbr_attackUM perc_nbr_attackH , over(year) percentage ///
bargap(-30) ///
b1title("Year") ///
legend(order(1 "Low income" 2 "Lower middle income" 3 "Upper middle income" 4 "High income")) ///
graphregion(color(white)) ///
saving("../Output/Attacks_by_country_type.gph", replace)

graph export "G:/My Drive/Gallup_survey/Manuscript/Figures/AttacksByCountryType.png", replace width(5000)


use "../Output/Gallup_merged_with_conflicts_regions_altern.dta", clear
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


*T1 * Summary statistics *******************************************************
est clear

label var Leader_approval "Leader's approval (Yes=1; No=0)"
label var confidence_Gvt "Confidence in national governement (Yes=1; No=0)"
label var honesty_election "Perception of honest elections (Yes=1; No=0)"
label var corruption_Gvt "Perception of corruption national governement (Yes=1; No=0)"
label var Post_GTDB "Post-attack (Yes=1; No=1)"
label var edu_primary "Primary education or less (Yes=1; No=0)"
label var edu_second "Secondary education (Yes=1; No=0)"
label var edu_college "College education (Yes=1; No=0)"
label var home_country_birth "Born in home country (Yes=1; No=0)"
label var muslim "Muslim (Yes=1; No=0)"
label var urban "Urban resident (Yes=1; No=0)"
label var Unemployed "Unemployed = 1; Employed = 0"
label var optimism "Satisfaction with living conditions (Yes=1; No=0)"
label var satis_income "Satisfaction with income (Yes=1; No=0)"
label var satis_health "Satisfaction with health (Yes=1; No=0)"
label var confidence_local_police "Satisfaction with local police (Yes=1; No=0)"
label var confidence_military "Confidence in military (Yes=1; No=0)"


estpost sum $dependent_variable year $interest_variable $controls $test_variables if dummy_all_var==1 & tero_success==1

esttab using "G:\My Drive\Gallup_survey\Manuscript\Tables\SummaryStatistics.tex", replace ///
cells("mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min(fmt(%6.0fc)) max(fmt(%15.0fc)) count(fmt(%15.0fc))") nonumber ///
nomtitle nonote noobs label collabels("Mean" "SD" "Min" "Max" "N")
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

 
/// Full regession analyses ****************************************************
* Loading the data
use "../Output/Gallup_merged_with_conflicts_regions_altern.dta", clear

global controls female age age_sq lnindinc married number_child_under_15 home_country_birth edu_primary edu_second edu_college muslim urban Unemployed
label var lnindinc "Log(income)"

est clear

sum Leader_approval if Post_GTDB == 0
local mean = round(r(mean),0.001)

di `mean'

* Impact with all fixed effects and control variables
qui eststo: reghdfe Leader_approval Post_GTDB $controls if dummy_all_var==1 & success==1, absorb(id_date_terro) cluster(leader_group_ISO regionid_m)
*qui estadd local Mean_dependent_var "`mean'"
qui estadd local Attack_FE "Yes"
qui estadd local Ind_contr_var "Yes"
qui estadd local Sample "+/-15 days"

* Impact with all fixed effects
qui eststo: reghdfe Leader_approval Post_GTDB if dummy_all_var==1 & success==1, absorb(id_date_terro) cluster(leader_group_ISO regionid_m)
*qui estadd local Mean_dependent_var "`mean'"
qui estadd local Attack_FE "Yes"
qui estadd local Ind_contr_var "No"
qui estadd local Sample "+/-15 days"

* Impact of terrorist attacks on institutions with regional time trends to account for omited variables bias
qui eststo: reghdfe Leader_approval Post_GTDB $controls c.year#i.regionid_m if dummy_all_var==1 & success==1, absorb(year regionid_m id_date_terro) cluster(leader_group_ISO regionid_m)
*qui estadd local Mean_dependent_var "`mean'"
qui estadd local Attack_FE "Yes"
qui estadd local Ind_contr_var "Yes"
qui estadd local Sample "+/-15 days"

* Impact with all fixed effects and logit regression technique
qui eststo: logit Leader_approval Post_GTDB $controls i.id_date_terro if dummy_all_var==1 & success==1, vce(cluster double_cluster)
*qui estadd local Mean_dependent_var "`mean'"
qui estadd local Attack_FE "Yes"
qui estadd local Ind_contr_var "Yes"
qui estadd local Sample "+/-15 days"

* Impact with all fixed effects and multilevel linear logit regression technique
qui eststo: melogit Leader_approval Post_GTDB $controls if dummy_all_var==1 & success==1 || regionid_m: || leader_group_ISO: || id_date_terro:, vce(r)
*qui estadd local Mean_dependent_var "`mean'"
qui estadd local Attack_FE "Yes"
qui estadd local Ind_contr_var "Yes"
qui estadd local Sample "+/-15 days"

* Impact with all fixed effects for sample within 5 days
qui eststo: reghdfe Leader_approval Post_GTDB $controls if dummy_all_var==1 & date_5==1 & success==1, absorb(year regionid_m id_date_terro) cluster(leader_group_ISO regionid_m)
*qui estadd local Mean_dependent_var "`mean'"
qui estadd local Attack_FE "Yes"
qui estadd local Ind_contr_var "Yes"
qui estadd local Sample "+/-5 days"

* Impact with all fixed effects  for sample within 1 day
qui eststo: reghdfe Leader_approval Post_GTDB $controls if dummy_all_var==1 & date_1==1 & success==1, absorb(year regionid_m id_date_terro) cluster(leader_group_ISO regionid_m)
*qui estadd local Mean_dependent_var "`mean'"
qui estadd local Attack_FE "Yes"
qui estadd local Ind_contr_var "Yes"
qui estadd local Sample "+/-1 day"

* Impact with all fixed effects for sample experiencing failed terrorist attacks
eststo: reghdfe Leader_approval Post_GTDB $controls if dummy_all_var==1 & tero_success==0, absorb(i.id_date_terro) cluster(leader_group_ISO regionid_m)
*qui estadd local Mean_dependent_var "`mean'"
qui estadd local Attack_FE "Yes"
qui estadd local Ind_contr_var "Yes"
qui estadd local Sample "+/-15 day"

esttab using "G:\My Drive\Gallup_survey\Manuscript\Tables\Regression1.tex", replace ///
keep(Post_GTDB $controls _cons) ///
se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ar2 pr2 ///
label nonotes collabels(none) compress ///
mtitles("Baseline" ///
"\shortstack{No\\controls}" ///
"\shortstack{With\\Region\\X Year\\Fixed\\Effects}" ///
"Logit" ///
"\shortstack{Multilevel\\linear\\logit\\regression}" ///
"\shortstack{Sample\\within\\5 days\\of an\\attack}" ///
"\shortstack{Sample\\within\\1 day\\of an\\attack}" ///
"\shortstack{Sample\\experiencing\\failed\\terrorist\\attack}") ///
scalars("Attack_FE Attack FE" "Ind_contr_var Controls" "Sample Sample") sfmt(%9.3f)

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


/// Regession analyses *********************************************************
global controls female age age_sq lnindinc married number_child_under_15 home_country_birth edu_primary edu_second edu_college muslim urban Unemployed
label var lnindinc "Log(income)"

est clear

sum Leader_approval if Post_GTDB == 0
local mean = round(r(mean),0.001)

di `mean'

* Impact with all fixed effects and control variables
qui eststo: reghdfe Leader_approval Post_GTDB $controls if dummy_all_var==1 & success==1, absorb(id_date_terro) cluster(leader_group_ISO regionid_m)
qui estadd local Mean_dependent_var "`mean'"
qui estadd local Attack_FE "Yes"
qui estadd local Ind_contr_var "Yes"
qui estadd local Sample "+/-15 days"

* Impact with all fixed effects without individual control variables
qui eststo: reghdfe Leader_approval Post_GTDB if dummy_all_var==1 & success==1, absorb(id_date_terro) cluster(leader_group_ISO regionid_m)
qui estadd local Mean_dependent_var "`mean'"
qui estadd local Attack_FE "Yes"
qui estadd local Ind_contr_var "No"
qui estadd local Sample "+/-15 days"

* Impact of terrorist attacks on institutions with regional time trends to account for omited variables bias
qui eststo: reghdfe Leader_approval Post_GTDB $controls c.year#i.regionid_m if dummy_all_var==1 & success==1, absorb(year regionid_m id_date_terro) cluster(leader_group_ISO regionid_m)
qui estadd local Mean_dependent_var "`mean'"
qui estadd local Attack_FE "Yes"
qui estadd local Ind_contr_var "Yes"
qui estadd local Sample "+/-15 days"


esttab using "G:\My Drive\Gallup_survey\Manuscript\Tables\Regression1Short.tex", replace ///
keep(Post_GTDB _cons) ///
se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ar2 ///
label nonotes collabels(none) compress ///
mtitles("Baseline" ///
"\shortstack{No\\controls}" ///
"\shortstack{With Region\\X Year-Fixed\\Effects}") ///
scalars("Mean_dependent_var Mean Approval pre-attack" "Attack_FE Attack FE" "Ind_contr_var Controls" "Sample Sample") sfmt(%9.3f)

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


// Event study *****************************************************************
est clear

gen L_5_10_days = (date_data_GTDB < -5 & date_data_GTDB >= -10)
label var L_5_10_days "-10"

gen L_10_15_days = (date_data_GTDB < -10 & date_data_GTDB >= -15)
label var L_10_15_days "-15"

gen L_15_20_days = (date_data_GTDB < -15 & date_data_GTDB >= -20)
label var L_15_20_days "-20"

gen L_20_25_days = (date_data_GTDB < -20 & date_data_GTDB >= -25)
label var L_20_25_days "-25"

gen L_25_30_days = (date_data_GTDB < -25)
label var L_25_30_days "-30"

gen F_1_5_days = (date_data_GTDB > 0 & date_data_GTDB <=5)
label var F_1_5_days "+5"

gen F_5_10_days = (date_data_GTDB >5 & date_data_GTDB <= 10)
label var F_5_10_days "+10"

gen F_10_15_days = (date_data_GTDB >10 & date_data_GTDB <= 15)
label var F_10_15_days "+15"

gen F_15_20_days = (date_data_GTDB > 15 & date_data_GTDB <= 20)
label var F_15_20_days "+20"

gen F_20_25_days = (date_data_GTDB > 20 & date_data_GTDB <= 25)
label var F_20_25_days "+25"

gen F_25_30_days = (date_data_GTDB >25)
label var F_25_30_days "+30"

gen base = 0
label var base "-5"

gen L_10 = (date_data_GTDB <-9)
label var L_10 "<-9"

gen F_10 = (date_data_GTDB >9)
label var F_10 ">+9"

gen L0 = 0
label var L0 "0"


reghdfe Leader_approval L_10_15_days L_5_10_days base F_1_5_days F_5_10_days F_10_15_days $controls if dummy_all_var==1 & success==1 , absorb(wave regionid_m id_date_terro) cluster(leader_group_ISO regionid_m)

estimates store event_study

coefplot event_study, drop(_cons $controls) vert ///
levels(95) ///
mcolor(red) ///
ciopts(recast(rcap) color(navy)) ///
mlabel(cond(@pval<.01, "***", cond(@pval<.05, "**", cond(@pval<.1, "*", "")))) ///
yline(0) ///
ytit("Approval of national leader" " ") ///
xtit(" " "Number of days relative to terrorist attack") ///
graphr(color(white)) ///
saving("../Output/event_study_group_days.gph", replace)

graph export "G:\My Drive\Gallup_survey\Manuscript\Figures\EventStudy.png", replace width(5000)

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


// Further evidence for causation claim ****************************************
global defeatism_variables optimism satis_income satis_health

// Impact of terrorist attacks on defeatism 
est clear

foreach var in $defeatism_variables {
	di "`var'"
	// Impact of terrorist attacks on control variables
	qui eststo: reghdfe `var' Post_GTDB $controls if dummy_all_var==1 & success==1, absorb(i.id_date_terro) cluster(leader_group_ISO regionid_m)
	qui estadd local Attack_FE "Yes"
}

esttab using "G:\My Drive\Gallup_survey\Manuscript\Tables\Defeatism.tex",  replace ///
keep(Post_GTDB $controls _cons) ///
se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ar2 ///
label notes collabels(none) ///
mtitles("\shortstack{Satisfaction\\with living\\conditions}" ///
"\shortstack{Satisfaction\\with\\income}" ///
"\shortstack{Subjective\\satisfaction\\with\\health}") ///
scalars("Attack_FE Attack FE") sfmt(4 0)

// Impact of terrorist attacks on scapegoating *
global scapegoating_variables honesty_election corruption_Gvt confidence_Gvt confidence_local_police confidence_military

est clear

foreach var in $scapegoating_variables {
	di "`var'"
	// Impact of terrorist attacks on control variables
	qui eststo: reghdfe `var' Post_GTDB $controls if dummy_all_var==1 & success==1, absorb(i.id_date_terro) cluster(leader_group_ISO regionid_m)
	qui estadd local Attack_FE "Yes"
}

esttab using "G:\My Drive\Gallup_survey\Manuscript\Tables\Scapegoats.tex",  replace ///
keep(Post_GTDB $controls _cons) ///
se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ar2 ///
mtitles("\shortstack{Belief of\\honesty in\\elections}" ///
"\shortstack{Belief that\\Government\\is corrupt}" ///
"\shortstack{Confidence\\in\\Government}" ///
"\shortstack{Confidence\\in local\\police}" ///
"\shortstack{Confidence\\in\\military}") ///
label notes collabels(none) ///
scalars("Attack_FE Attack FE") sfmt(4 0)

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// Further causation claim : impact of terrorist attacks on controls ***********
est clear

* Loading the data
use "../Output/Gallup_merged_with_conflicts_regions_altern.dta", clear

global controls female age lnindinc married number_child_under_15 home_country_birth education muslim urban 

foreach var in $controls  {
	di "`var'"
	// Impact of terrorist attacks on control variables
	qui eststo: reghdfe `var' Post_GTDB if dummy_all_var==1 & success==1, absorb(i.id_date_terro) cluster(leader_group_ISO regionid_m)
	qui estadd local Attack_FE "Yes"
	qui estadd local Ind_contr_var "No"
}

esttab using "G:\My Drive\Gallup_survey\Manuscript\Tables\RegressionOnControls.tex",  replace ///
keep(Post_GTDB _cons) ///
se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ar2 ///
label notes collabels(none) ///
scalars("Attack_FE Attack FE" "Ind_contr_var Individual Controls") sfmt(4 0)

global controls female age age_sq lnindinc married number_child_under_15 home_country_birth edu_primary edu_second edu_college muslim urban Unemployed

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// Further evidence for causation claim (2) ************************************

g beta    = .
g beta_hi = .
g beta_lo = .
gen p =.
loc row = 1

qui levelsof countrynew, local(levels)
foreach l of local levels {
    reghdfe Leader_approval Post_GTDB $controls if dummy_all_var==1 & success==1 & countrynew!="`l'", absorb(year regionid_m id_date_terro leader_group_ISO) cluster(leader_group_ISO regionid_m)
	replace beta    = _b[Post_GTDB]                         in `row'
	replace beta_hi = _b[Post_GTDB] + invttail(e(df_r),0.025) *_se[Post_GTDB] in `row'
	replace beta_lo = _b[Post_GTDB] - invttail(e(df_r),0.025) *_se[Post_GTDB] in `row'
	local t = _b[Post_GTDB]/_se[Post_GTDB]
	replace p =2*ttail(e(df_r),abs(`t')) in `row'
	
	label define labels `row' "`l'", add
	
	loc row = `row' + 1
}

gen x = _n

label values x labels

gen Color = "red"

replace p = round(p, 0.001)

gen stars=""
replace stars="*" if p > 0.05 & p <=0.1
replace stars="**" if p > 0.01 & p<=0.05
replace stars="***" if p<=0.01

gen Labels = string(round(beta, 0.01)) + stars 

keep in 1/18
tw (rcap beta_hi beta_lo x, horizontal) ///
	(sc x beta, mlabel(Labels) mlabposition(12) mcolor(red)) , ///
	ytit(" Regressions excluding countries one by one" " ") graphr(color(white)) ///
	yscale(noline) xline(0, lcolor(black)) ylab(1(1)18, valuelabels angle(0) labsize(small)) ///
	xscale(noline) xtit("") legend(rows(1) order(1 "95% C.I." 2 "Effect of terror" 3)) ///
	yscale(reverse) saving("F4_dropping_countries_one_by_one.gph", replace)

graph export "G:/My Drive/Gallup_survey/Manuscript/Figures/DroppingCountriesOneByOne.png", replace width(5000)

* Reloading the original data *
use "../Output/Gallup_merged_with_conflicts_regions_altern.dta", clear

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


// Countries with the highest impact *******************************************
est clear
label var lnindinc "Log(income)"
label var number_child_under_15 "Children"
label var home_country_birth "Native-born"
label var home_country_birth "Native-born"
label var edu_primary "Prim. educ"
label var edu_second "Sec. educ"
label var edu_college "College"
label var urban "Urban"

// By level of income

foreach i in 1 4 3 2 {
	qui eststo: reghdfe Leader_approval Post_GTDB $controls if dummy_all_var==1 & IncomeGroup_enc == `i', absorb(i.id_date_terro) cluster(leader_group_ISO regionid_m)
	qui estadd local Attack_FE "Yes"
}

// Differences by recurrence of terrorist attacks per country
foreach i in 1 2 {
	qui eststo: reghdfe Leader_approval Post_GTDB $controls if dummy_all_var==1 & success==1 & terro_country==`i', absorb(i.id_date_terro) cluster(leader_group_ISO regionid_m)
	qui estadd local Attack_FE "Yes"

	}
	
// By level of democracy
foreach i in 1 2 {
	qui eststo: reghdfe Leader_approval Post_GTDB $controls if dummy_all_var==1 & success==1 & Democracy_group==`i', absorb(i.id_date_terro) cluster(leader_group_ISO regionid_m)
	qui estadd local Attack_FE "Yes"
}

esttab using "G:\My Drive\Gallup_survey\Manuscript\Tables\RegressionByCountry1.tex", replace ///
keep(Post_GTDB $controls _cons) ///
coeflabel(1.Post_GTDB "Post attack" ) ///
se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ar2 ///
label notes collabels(none) compress ///
mtitles("\shortstack{High\\income\\countries}" ///
"\shortstack{Upper\\middle\\income\\countries}" ///
"\shortstack{Lower\\middle\\income\\countries}" ///
"\shortstack{Low\\income\\countries}" ///
"\shortstack{Countries\\with\\low\\terrorism}" ///
"\shortstack{Countries\\with\\high\\terrorism}" ///
"\shortstack{Countries\\with\\low\\democracy\\index}" ///
"\shortstack{Countries\\with\\high\\democracy\\index}" ) ///
scalars("Attack_FE Attack FE") sfmt(%9.3f)

est clear

// By level of corruption
foreach i in 1 2 {
	qui eststo: reghdfe Leader_approval Post_GTDB $controls if dummy_all_var==1 & success==1 & corruption_leader_ISO_cat==`i', absorb(i.id_date_terro) cluster(leader_group_ISO regionid_m)
	qui estadd local Attack_FE "Yes"
	
}

// By level of political orientation of the leader
foreach i in 1 5 {
	qui eststo: reghdfe Leader_approval Post_GTDB $controls if dummy_all_var==1 & success==1 & self_code==`i', absorb(i.id_date_terro) cluster(leader_group_ISO regionid_m)
	qui estadd local Attack_FE "Yes"

}

esttab using "G:\My Drive\Gallup_survey\Manuscript\Tables\RegressionByCountry2.tex", replace ///
keep(Post_GTDB $controls _cons) ///
coeflabel(1.Post_GTDB "Post attack" ) ///
se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ar2 ///
label notes collabels(none) compress ///
mtitles("\shortstack{Leaders with\\low\\corruption index}" ///
"\shortstack{Leaders with\\high\\corruption index}" ///
"\shortstack{Leaders\\self-identified\\right leaning}" ///
"\shortstack{Leaders\\self-identified\\left leaning}" ) ///
scalars("Attack_FE Attack FE") sfmt(%9.3f)

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// Further investigation of the effect of leader ideoloy ***********************
est clear 

loc number = 1

// By level of political orientation of the leader
foreach var in vanilla_code FK_code RILE_code speech_code policy_code {
	
	est clear
	
	di "Right - wing"
	eststo: reghdfe Leader_approval Post_GTDB  $controls if dummy_all_var==1 & success==1 & `var'==1, absorb(i.id_date_terro) cluster(leader_group_ISO regionid_m)
	qui estadd local Attack_FE "Yes"
	qui estadd local Ind_contr_var "Yes"
	
	di "Centrist"
	eststo: reghdfe Leader_approval Post_GTDB  $controls if dummy_all_var==1 & success==1 & `var'==3, absorb(i.id_date_terro) cluster(leader_group_ISO regionid_m)
	qui estadd local Attack_FE "Yes"
	qui estadd local Ind_contr_var "Yes"
	
	
	di "Left - wing"
	eststo: reghdfe Leader_approval Post_GTDB  $controls if dummy_all_var==1 & success==1 & `var'==5, absorb(i.id_date_terro) cluster(leader_group_ISO regionid_m)
	qui estadd local Attack_FE "Yes"
	qui estadd local Ind_contr_var "Yes"
	
	esttab using "G:\My Drive\Gallup_survey\Manuscript\Tables\RegressionIdeologies`number'.tex", replace ///
	keep(Post_GTDB ///
	_cons) ///
	coeflabel(Post_GTDB "Post attack") ///
	se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ar2 ///
	label collabels(none)  ///
	mtitles("Right" "Centre" "Left") ///
	scalars("Attack_FE Attack FE"  "Ind_contr_var Individual Controls") sfmt(4 0)
	
	loc number = `number' + 1
	}


// Regressions at the country level *******************************************
use "../Output/Gallup_merged_with_conflicts_regions_altern_country_level.dta", clear

global controls female age age_sq lnindinc married number_child_under_15 home_country_birth edu_primary edu_second edu_college muslim urban Unemployed

label var lnindinc "Log(income)"
label var urban "Urban resident"
est clear

qui eststo: reghdfe Leader_approval Post_GTDB $controls if tero_success==1, absorb(id_date_terro) cluster(leader_group_ISO regionid_m)
qui estadd local Attack_FE "Yes"

qui eststo: reghdfe Leader_approval Post_GTDB $controls if regionid_m_survey!=districtid, absorb(id_date_terro) cluster(leader_group_ISO)
qui estadd local Attack_FE "Yes"

esttab using "G:\My Drive\Gallup_survey\Manuscript\Tables\NationalAnalysis.tex", replace ///
keep(Post_GTDB $controls _cons) ///
se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ar2 ///
label collabels(none) notes ///
mtitles("\shortstack{Sample in countries with\\a terrorist attack}" ///
"\shortstack{Sample in countries with\\ a terrorist attack \\and excluding region attacked}") ///
scalars("Attack_FE Attack FE") sfmt(4 0)

use "../Output/Gallup_merged_with_conflicts_regions_altern.dta", clear

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// Regressions at the regional level *******************************************
use "../Output/Gallup_merged_with_conflicts_regions_altern_country_level.dta", clear

gen count = 1
gen attack=(regionid_m_survey==districtid)
keep if tero_success==1

collapse (sum) count Leader_approval (mean) attack nkill nkillter nkillat, by(regionid_m Post_GTDB WP4 leader_group_ISO COUNTRY_ISO3 year id_date_terro)

replace Leader_approval = Leader_approval / count 
bysort regionid_m (year): gen lag_Leader_approval = Leader_approval[_n-1] 
label var lag_Leader_approval "Leader approval \({t-1}\)"
label var Leader_approval "Leader's approval"

label var attack "Attack"

est clear 

qui eststo: reghdfe attack lag_Leader_approval, absorb(id_date_terro) cluster(leader_group_ISO)
qui estadd local Attack_FE "Yes"
qui estadd local Ind_contr_var "No"

esttab using "G:\My Drive\Gallup_survey\Manuscript\Tables\RegionalAnalysis.tex", replace ///
keep(lag_Leader_approval _cons) ///
se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) ar2 ///
label collabels(none) notes ///
scalars("Attack_FE Attack FE"  "Ind_contr_var Individual Controls") sfmt(4 0)



use "../Output/Gallup_merged_with_conflicts_regions_altern.dta", clear

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

//  PART 7 (ACLED GTDB ANALYSES) ***********************************************
* Reformating the data at the week levels
use "../Temporary/Armed_conflicts_GTDB.dta", clear
gen count=1
collapse (sum) count nkill nkillter nkillat, by(week year regionid_m ISO)
save "../Temporary/GTDB_week.dta", replace

use "../Temporary/Armed_conflicts_ACLED.dta", clear
collapse (sum) fatalities fatalities_1 fatalities_2, by(week year regionid_m)

gen date_data_GTDB =.
label var date_data_GTDB "Number of weeks relative to an attack"

* Merging the survey with the conflicts that occured anteriously
forvalues i=1(1)12 {
	replace week = week - `i'

	merge m:1 regionid_m year week using "..\Temporary\GTDB_week.dta", update
	drop if _merge == 2
	
	replace date_data_GTDB = `i' if _merge == 5 & missing(date_data_GTDB) | _merge == 4
	drop _merge
	
	replace week = week + `i'
}

* Merging the survey with the conflicts that occured posteriously
forvalues i=1(1)12 {
	replace week = week + `i'

	merge m:1 regionid_m year week using "..\Temporary\GTDB_week.dta", update
	drop if _merge == 2
	
	replace date_data_GTDB = - `i' if _merge == 5 & missing(date_data_GTDB) | _merge == 4
	drop _merge
	
	replace week = week - `i'
}

* Creating a post-conflict variable
gen Post_GTDB = (date_data_GTDB > 0)
label var Post_GTDB "Post-attack"

replace count=0 if missing(count)
label var count "Number of Riots/protest"

* Using standard double clustering
encode ISO, gen(ISO_encoded)

egen double_custer=group(ISO_encoded year)

est clear
qui eststo: nbreg count date_data_GTDB i.year i.regionid_m, cluster(double_custer)
qui estadd local Region_FE "Yes"
qui estadd local Year_FE "Yes"

qui eststo: nbreg count Post_GTDB i.year i.regionid_m, cluster(double_custer)
qui estadd local Region_FE "Yes"
qui estadd local Year_FE "Yes"

esttab using "G:\My Drive\Gallup_survey\Manuscript\Tables\Regression9.tex", replace ///
keep(Post_GTDB date_data_GTDB Post_GTDB _cons) ///
se star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) se(%9.3f) pr2 ///
label collabels(none) notes ///
scalars("Region_FE Region FE" "Year_FE Year FE") sfmt(4 0)

use "../Output/Gallup_merged_with_conflicts_regions_altern.dta", clear

//!!!!!!!!!!!!!!!!  END   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!