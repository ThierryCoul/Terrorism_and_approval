## The file describes the code used in the manuscript "We perceive national leaders as incompetent post-terrorism: The case of ISIL and al-Qaeda"

#### The names of the code files are self-explanitory.

* 1_Cleaning_Gallup_data.do (This code mostly stems from study 3G INTERNET AND CONFIDENCE IN GOVERNMENT, whose code is public, thanks to Sergei Guriev, Nikita Melnikov and Ekaterina Zhuravskaya)
* 2_Cleaning_additional_control_variables.do
* 3_Cleaning_violence_variables.do
* 4_0_Cleaning_final_dataset.do
* 4_1_Cleaning_final_dataset_country_level.do
* 5_statistical_analysis.do
* 6_statistical_analysis_coefplot.do

#### Dataset used in the analyses are provided in the folder Input:
* "The_Gallup_042722.dta" It is result of the survey carried out by Gallup World Poll (GWP). This dataset is not public. One can contact Gallup to purchase the data here: https://www.gallup.com/270188/contact-us-general.aspx (accessed June 30, 2022). When downloaded, the file should be placed in the input folder and titled "The_Gallup_042722.dta"

* "map_to_gallup_level1.dta": Subnational regions id for countries whose survey data came from subdivisions of the country at the first level administratively.

* "map_to_gallup_level2.dta": Subnational regions id for countries whose survey data came from subdivisions of the country at the second level administratively.

* "democracy.csv": Index of the average level of democracy per country derived from Polity2 score of the Polity IV dataset.

* "Income_level_country.xlsx": Income level of countries. The data come from the World Bank.

* "corruption_incidents_IMF.dta": level of corruption of countries per year. The data come from IMF.

* "ACLED.csv": Numbers of riots and conflicts across the world. The data can be downloaded from https://acleddata.com/ and should be uploaded if the input folder and named "globalterrorismdb_0522dist.xlsx"

* "globalterrorismdb_0522dist.xlsx": Terrorist events and information. The data can be downloaded from https://www.start.umd.edu/gtd/ and should be uploaded if the input folder and named "globalterrorismdb_0522dist.xlsx"
