* Setting the working directory
cd "D:\Working_projects\04_The_Gallup_042722\Code"

// Cleaning the Gallup data and generating the District id variable ************

* Loading the data.
use "..\Input\The_Gallup_042722.dta", clear

decode WP5, gen(WP5_label)
gen country_gwp = WP5
label variable country_gwp "Country code (GWP)"
label variable WP5 "Country code (GWP)"
gen country_gwp_label = WP5_label
label variable country_gwp_label "Country name (GWP)"
label variable WP5_label "Country name (GWP)"

decode REGION_BEL, gen(region_name)
label variable region_name "Name of subnational region"

foreach reg in REGION2_BWA REGION2_UGA REGION2_ZMB REGION2_DNK REGION1_PAN REGION1_TWN REGION2_PHL REGION_AUT REGION_DEU REGION_NLD REGION_AFG REGION_AGO REGION_ALB REGION_ARE REGION_ARG REGION_ARM REGION_AUS REGION_AZE REGION_BDI REGION_BEN REGION_BFA REGION_BGD REGION_BGR REGION_BHR REGION_BIH REGION_BLR REGION_BLZ REGION_BOL REGION_BRA REGION_BTN REGION_BWA REGION_CAM REGION_CAN REGION_CAR REGION_CHE REGION_CHL REGION_CHN REGION_CIV REGION_COG REGION_COL REGION_COM REGION_CRI REGION_CYP REGION_CZE REGION_DJI REGION_DOM REGION_DRC REGION_DZA REGION_ECU REGION_EGY REGION_ESP REGION_EST REGION_ETH REGION_FIN REGION_FRA REGION_GAB REGION_GBR REGION_GEO REGION_GHA REGION_GMB REGION_GRC REGION_GTM REGION_GUI REGION_HKG REGION_HND REGION_HRV REGION_HTI REGION_HUN REGION_ICL REGION_IDN REGION_IND REGION_IRL REGION_IRN REGION_IRQ REGION_ISR REGION_ITA REGION_JMC REGION_JOR REGION_JPN REGION_KAZ REGION_KEN REGION_KGZ REGION_KHM REGION_KOR REGION_KOS REGION_KWT REGION_LAO REGION_LBN REGION_LBR REGION_LKA REGION_LSO REGION_LTU REGION_LUX REGION_LVA REGION_LYB REGION_MAR REGION_MDA REGION_MDG REGION_MEX REGION_MKD REGION_MLI REGION_MLT REGION_MLW REGION_MMR REGION_MNE REGION_MNG REGION_MOZ REGION_MRT REGION_MUS REGION_MYS REGION_NAM REGION_NCY REGION2_NER REGION_NGA REGION_NIC REGION_NKR REGION_NLD REGION_NOR REGION_NPL REGION_NZL REGION_OMN REGION_PAK REGION_PAN REGION_PER REGION_PHL REGION_POL REGION_PRI REGION_PRT REGION_PRY REGION_PSE REGION_QAT REGION_ROU REGION_RUS REGION_RWA REGION_SAU REGION_SDN REGION_SEN REGION_SLE REGION_SLV REGION_SOL REGION_SOM REGION_SRB REGION_SRI REGION_SSD REGION_SVK REGION_SVN REGION_SWE REGION_SWZ REGION_SYR REGION_TCD REGION_THA REGION_TJK REGION_TKM REGION_TOG REGION_TTO REGION_TUN REGION_TUR REGION_TWN REGION_TZA REGION_UKR REGION_URY REGION_USA REGION_UZB REGION_VEN REGION_VNM REGION_YEM REGION_ZAF REGION_ZWE{
	decode `reg', gen(reg_label)
	replace region_name = reg_label if !missing(`reg')
	drop reg_label
}

replace REGION_AUT = . if REGION_AUT == 99999 | REGION_AUT == 99998
replace REGION_AUT = REGION_AUT - 18000

replace REGION_DEU = . if REGION_DEU == 9999 | REGION_DEU == 9998
replace REGION_DEU = REGION_DEU - 4000

replace REGION_NLD = REGION_NLD - 17000

gen countdistrict = country_gwp*1000
gen regid = 0


foreach reg in REGION_AFG REGION_AGO REGION_ALB REGION_ARE REGION_ARG REGION_ARM REGION_AUS REGION_AZE REGION_BDI REGION_BEN REGION_BFA REGION_BGD REGION_BGR REGION_BHR REGION_BIH REGION_BLR REGION_BLZ REGION_BOL REGION_BRA REGION_BTN REGION_BWA REGION_CAM REGION_CAN REGION_CAR REGION_CHE REGION_CHL REGION_CHN REGION_CIV REGION_COG REGION_COL REGION_COM REGION_CRI REGION_CYP REGION_CZE REGION_DJI REGION_DOM REGION_DRC REGION_DZA REGION_ECU REGION_EGY REGION_ESP REGION_EST REGION_ETH REGION_FIN REGION_FRA REGION_GAB REGION_GBR REGION_GEO REGION_GHA REGION_GMB REGION_GRC REGION_GTM REGION_GUI REGION_HKG REGION_HND REGION_HRV REGION_HTI REGION_HUN REGION_ICL REGION_IDN REGION_IND REGION_IRL REGION_IRN REGION_IRQ REGION_ISR REGION_ITA REGION_JMC REGION_JOR REGION_JPN REGION_KAZ REGION_KEN REGION_KGZ REGION_KHM REGION_KOR REGION_KOS REGION_KWT REGION_LAO REGION_LBN REGION_LBR REGION_LKA REGION_LSO REGION_LTU REGION_LUX REGION_LVA REGION_LYB REGION_MAR REGION_MDA REGION_MDG REGION_MEX REGION_MKD REGION_MLI REGION_MLT REGION_MLW REGION_MMR REGION_MNE REGION_MNG REGION_MOZ REGION_MRT REGION_MUS REGION_MYS REGION_NAM REGION_NCY REGION2_NER REGION_NGA REGION_NIC REGION_NKR REGION_NLD REGION_NOR REGION_NPL REGION_NZL REGION_OMN REGION_PAK REGION_PAN REGION_PER REGION_PHL REGION_POL REGION_PRI REGION_PRT REGION_PRY REGION_PSE REGION_QAT REGION_ROU REGION_RUS REGION_RWA REGION_SAU REGION_SDN REGION_SEN REGION_SLE REGION_SLV REGION_SOL REGION_SOM REGION_SRB REGION_SRI REGION_SSD REGION_SVK REGION_SVN REGION_SWE REGION_SWZ REGION_SYR REGION_TCD REGION_THA REGION_TJK REGION_TKM REGION_TOG REGION_TTO REGION_TUN REGION_TUR REGION_TWN REGION_TZA REGION_UKR REGION_URY REGION_USA REGION_UZB REGION_VEN REGION_VNM REGION_YEM REGION_ZAF REGION_ZWE{
replace `reg'= . if `reg' == 98 | `reg' == 99
replace regid = `reg' if missing(`reg') == 0
}

replace REGION_AUT = . if REGION_AUT == 99999
replace regid = REGION_AUT if missing(REGION_AUT) == 0

replace REGION_BEL = . if REGION_BEL == 998 | REGION_BEL == 999
replace regid = REGION_BEL if missing(REGION_BEL) == 0

replace REGION2_BWA = . if REGION2_BWA == 98 | REGION2_BWA == 99
replace regid = REGION2_BWA if missing(REGION2_BWA) == 0
replace REGION2_UGA = . if REGION2_UGA == 98 | REGION2_UGA == 99
replace regid = REGION2_UGA if missing(REGION2_UGA) == 0
replace REGION2_ZMB = . if REGION2_ZMB == 98 | REGION2_ZMB == 99
replace regid = REGION2_ZMB if missing(REGION2_ZMB) == 0

replace REGION_DEU = . if REGION_DEU == 9998 | REGION_DEU == 9999
replace regid = REGION_DEU if missing(REGION_DEU) == 0

*replace REGION_DNK = . if REGION_DNK == 100 | REGION_DNK == 99
*replace regid = REGION_DNK if missing(REGION_DNK) == 0

replace REGION1_PAN = . if REGION1_PAN == 98 | REGION1_PAN == 99
replace regid = REGION1_PAN if missing(REGION1_PAN) == 0

replace REGION1_TWN = . if REGION1_TWN == 98 | REGION1_TWN == 99
replace regid = REGION1_TWN if missing(REGION1_TWN) == 0

replace REGION2_PHL = . if REGION2_PHL == 98 | REGION2_PHL == 99
replace regid = REGION2_PHL if missing(REGION2_PHL) == 0

replace regid = . if regid == 0
gen districtid = countdistrict + regid
label variable districtid "Subnational region ID"

drop countdistrict regid

* Combine Dix-Huit Montagnes and Moyen-Cavally, Ivory Coast because they are now one region. 
replace districtid = 134005 if districtid == 134011

* Distrito Capital, Paraguay missing districtid
replace districtid = 164000 if REGION_PRY == 0

* Add Sanaa city to Sanaa Governorate, no separate map for Sanaa city
replace districtid = 197012 if districtid == 197001

* Drop Crimea and Sevastopol in Ukraine
replace districtid = . if districtid == 77023 | districtid == 77027

* Combine all of Tobago into one, otherwise only 8 observations per region.
replace districtid = 189015 if districtid == 189016 | districtid == 189018 | districtid == 189019 | districtid == 189020

* Drop Crimea and Sevastopol in Russia
replace districtid = . if districtid == 76084 | districtid == 76085

* Combine Kavango East and West in Namibia, no map for East and West separately
replace districtid = 155006 if districtid == 155005

* Combine Riga and Pieriga, no map for Pieriga
replace districtid = 138001 if districtid == 138006

* Combining parts of regions (with very few observations) into regions in Jamaica
* Kingston
replace districtid = 135001 if districtid == 135002
* St.Andrew
replace districtid = 135003 if districtid == 135004 | districtid == 135005 | districtid == 135006 | districtid == 135007 | districtid == 135008 | districtid == 135009 | districtid == 135010 | districtid == 135011 | districtid == 135012 | districtid == 135013 | districtid == 135014 | districtid == 135015 | districtid == 135016
* St.Thomas
replace districtid = 135017 if districtid == 135018
* Portland
replace districtid = 135019 if districtid == 135020
* St.Mary
replace districtid = 135021 if districtid == 135022
* St. Ann
replace districtid = 135023 if districtid == 135024
* St. James
replace districtid = 135026 if districtid == 135027 | districtid == 135028
* Hanover
replace districtid = 135029 if districtid == 135030
* Westmoreland
replace districtid = 135031 if districtid == 135032 | districtid == 135033
* St.Elizabeth
replace districtid = 135034 if districtid == 135035
* Manchester
replace districtid = 135036 if districtid == 135037 | districtid == 135038
* Clarendon
replace districtid = 135039 if districtid == 135040 | districtid == 135041 | districtid == 135042
* St.Catherine
replace districtid = 135043 if districtid == 135044 | districtid == 135045 | districtid == 135046 | districtid == 135047 | districtid == 135048


* Combine North Tipperary and South Tipperary
replace districtid = 132022 if districtid == 132023

* Combine Ceuta and Melilla (otherwise few observations) in Spain
replace districtid = 17017 if districtid == 17018

* Delete DK and Refused "regions" in Cyprus
replace districtid = . if districtid == 111008 | districtid == 111009

* Delete Bilesuvar-Lerik, AZE because it seems to be a mix of other districts
replace districtid = . if districtid == 90008

* Combine Halabja with the rest of Sulaymaniya
replace districtid = 131006 if districtid == 131019

* No map for Gusinje, Montenegro

* Arta, Djibouti not available on map

* Combine Golfe and Lome (only map for combined region)
replace districtid = 187014 if districtid == 187016

* Map missing for Abalak (64001) Cumaradi (64024) Cutahoua (64034) Cuzinder (64041), Niger

* Combine Berkane and Taourirt, Morocco (only map for combined region)
replace districtid = 3027 if districtid == 3032

* Mediouna is a part of Casablanca (Morocco)
replace districtid = 3033 if districtid == 3034

* Nouaceur is a part of Casablanca (Morocco)
replace districtid = 3033 if districtid == 3036

* Tinghir is a part of Ouarzazate (Morocco)
replace districtid = 3013 if districtid == 3062

* Berrechid is a part of Settat (Morocco)
replace districtid = 3021 if districtid == 3063

* Sidi Bennour is a part of El Jadida (Morocco)
replace districtid = 3041 if districtid == 3064

* Youssoufia is a part of Safi (Morocco)
replace districtid = 3042 if districtid == 3065

* Driouch is a part of Nador (Morocco)
replace districtid = 3030 if districtid == 3066

* Fquih Ben Salah is a part of Beni Mellal (Morocco)
replace districtid = 3044 if districtid == 3067

* Ouezzane is a part of Sidi Kacem (Morocco)
replace districtid = 3018 if districtid == 3068

* Sidi Ifni is a part of Tiznit (Morocco)
replace districtid = 3015 if districtid == 3069

* Sidi Slimane is a part of Kenitra (Morocco)
replace districtid = 3017 if districtid == 3070

* M'diq and Fnideq are a part of Tetouan (Morocco)
replace districtid = 3061 if districtid == 3072

* Combine the two parts of Beirut, Lebanon
replace districtid = 4001 if districtid == 4003

* Mitrovice e Veriut was created in 2013, before that was a part of Mitrovica (Kosovo)
replace districtid = 198011 if districtid == 198037

* Klokot was created in 2010, before that was a part of Vitina, only 8 observations (Kosovo)
replace districtid = 198025 if districtid == 198035

* Gracanica, Junik, Partes do not have maps, very few observations (16 at most) (Kosovo)

* Map missing Aland, Finland (21 observations)

* Map missing for Lokossa, Benin

* Combine the parts of Republika Srpska (Bosnia and Herzegovina)
replace districtid = 97011 if districtid == 97012 | districtid == 97013

* Add Republika Srpska from REGION2_BIH
replace districtid = 97011 if REGION2_BIH == 3 & districtid != 97014

* Add Federation of Bosnia and Herzegovina from REGION2_BIH
replace districtid = 97001 if REGION2_BIH == 1 & districtid != 97014
replace districtid = 97001 if REGION2_BIH == 2 & districtid != 97014

* Combine Astana and Akmola region because the map does not have Astana separately
replace districtid = 73006 if districtid == 73002

* Combine Chukyo and Tokai, Japan because the prefectures overlap. 
replace districtid = 29006 if districtid == 29007

* Combine Bogota and Cundinamarca, Bogota (Columbia)
replace districtid = 105025 if districtid == 105011

* Combine Kaohsiung County and Kaohsiung Municipality, Taiwan
replace districtid = 69007 if districtid == 69008

* Combine Taichung County and Taichung Municipality, Taiwan
replace districtid = 69016 if districtid == 69017

* Combine Tainan County and Tainan Municipality, Taiwan
replace districtid = 69018 if districtid == 69019

* Combine Minsk and Minsk Oblast, Belarus
replace districtid = 71002 if districtid == 71001

* Combine Almaty and Almaty Oblast, Kazakhstan
replace districtid = 73001 if districtid == 73009

* Combine Douala and rest of Littoral region, Cameroon
replace districtid = 79005 if districtid == 79011

* Combine Yaounde and rest of Centre region, Cameroon
replace districtid = 79002 if districtid == 79012

* Combine Nord and Sud Kivu, Congo (Kinshasa)
replace districtid = 107011 if districtid == 107009

* Combine parts of Hong Kong
replace districtid = 27001 if districtid == 27002
replace districtid = 27001 if districtid == 27003

* Combine parts of Iceland
replace districtid = 130001 if districtid == 130002

* Combine Baku and rest of Absheron, Azerbaijan
replace districtid = 90002 if districtid == 90001

* Combine parts of regions, Ivory Coast
replace districtid = 134007 if districtid == 134010
replace districtid = 134002 if districtid == 134018
replace districtid = 134006 if districtid == 134015
replace districtid = 134012 if districtid == 134016
replace districtid = 134005 if districtid == 134011
replace districtid = 134008 if districtid == 134013
replace districtid = 134009 if districtid == 134001

* Combine Kathmandu with rest of Bagmati, Nepal
replace districtid = 157001 if districtid == 157002

* Combine all regions of Malta
replace districtid = 148001 if country_gwp == 148

* Combine all regions of Singapore
replace districtid = 28001 if country_gwp == 28

* Combine parts of one state, Australia
replace districtid = 47002 if districtid == 47001
replace districtid = 47004 if districtid == 47003
replace districtid = 47006 if districtid == 47005
replace districtid = 47008 if districtid == 47007
replace districtid = 47010 if districtid == 47009
replace districtid = 47012 if districtid == 47011
replace districtid = 47015 if districtid == 47014

* Combine parts of one state, Canada
replace districtid = 46003 if districtid == 46002
replace districtid = 46005 if districtid == 46004
replace districtid = 46008 if districtid == 46007

replace region_name = "Singapore" if districtid == 28001
replace region_name = "Federation of Bosnia and Herzegovina" if districtid == 97001
replace region_name = "Republika Srpska" if districtid == 97011
replace region_name = "Malta" if districtid == 148001

gen year = year(WP4)
label variable year "Year"
gen month = month(WP4)
label variable month "Month"
gen day = day(WP4)
label variable day "Day"

* Merging the district_id to the unique identifier of the conflicts
merge m:1 districtid using "..\Input\map_to_gallup_level1.dta"
drop _merge
merge m:1 districtid using "..\Input\map_to_gallup_level2.dta", update
drop _merge

* Generating a variable of leaders names
gen leader_name=""

* Decoding the president values and replacing it in the empty variable
foreach var in  WP6879_2008 WP6879_2009 WP6879_2010 WP6879_2011 WP13125_2012 WP13125_2013 WP13125_2014 WP13125_2015 WP13125_2016 WP13125_2017 WP13125_2018 WP13125_2019 WP13125_2020 WP13125_2021 {
	* Decoding from integer to string
	decode `var', generate(`var'_dec)
	
	* Replacing the decoded values in the main variable
	replace leader_name = `var'_dec if missing(leader_name)
	
	* Dropping the intermediary variable
	drop `var'_dec
}

* Generating a dummy for observations with leader approval rating
gen approval_dummy =(!missing( WP6879) | !missing(WP13125))

* Filling the name of countries' leaders where missing
replace leader_name = "Paraguay - Fernando Lugo" if missing(leader_name) & COUNTRY_ISO3=="PRY" & approval_dummy ==1
replace leader_name = "Dominican Republic - Leonel Fernandez" if missing(leader_name) & COUNTRY_ISO3=="DOM" & approval_dummy ==1

sort leader_name
encode leader_name, gen(id_leader_name)
gen id = id_leader_name

save "../Temporary/Gallup_merged.dta", replace
//!!!!!!!!!!!!!!!!!!!!!!!!!!!   END  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!