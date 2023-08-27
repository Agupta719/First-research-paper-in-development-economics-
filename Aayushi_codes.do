********************************************************************************
********************************************************************************
clear
set more off
ssc install outreg2

capture log close

cd "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/Stata/

set type double

log using "Aayushi_codes.smcl", replace
********************************************************************************
********************************************************************************

               **************************************************
               ****************Cleaning & Merging****************
               **************************************************

**************************************************
****************List of countries*****************
**************************************************

*import dataset with list of all countries
import delimited "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/all_countries.csv", clear 

set obs `=_N+2'
replace v2 = "Palestine" if _n == _N
replace v2 = "Holy See" if _n == _N-1
drop v1
rename v2 countryList
sort countryList

gen country = countryList

*duplicating rows and generating year column
gen frequency = 22
expand frequency
sort country
bysort country : gen Year = 1999 + _n
drop frequency


*save list of countries
save countryList, replace

**************************************************
**************Rural Population & GDP**************
**************************************************

*import rural population & GDP dataset
import excel "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/GDP_Rural_Urban/P_Data_Extract_From_World_Development_Indicators.xlsx", sheet("Data") firstrow clear

*destring year variables by generating new year variables
foreach item of varlist YR2000-YR2021{
//  di `item'
	gen Year = real(`item')
	rename Year Year`item'
}

*cleaning it
drop YR2000-YR2021 CountryCode SeriesCode
drop if CountryName == ""
drop if SeriesName == "GDP per capita (current US$)" | SeriesName == "GDP per capita growth (annual %)"
rename CountryName country
sort country

*transposing dataset
encode SeriesName, gen (Class)
label list Class
drop SeriesName
drop if Class == .

reshape long YearYR, i(country Class) j(Year)
reshape wide YearYR, i(country Year) j(Class) 

rename YearYR1 GDP_2015
rename YearYR2 RuralPop
rename YearYR3 UrbanPop

*Correcting misspelled countries and dropping non-country values
merge 1:1 country Year using countryList
// keep if Year == 2000
keep if _m != 3
sort country 

drop if country == "Africa Eastern and Southern"
drop if country == "Africa Western and Central"
drop if country == "American Samoa"
drop if country == "Arab World"
drop if country == "Bermuda"
drop if country == "British Virgin Islands"
drop if country == "Caribbean small states"
drop if country == "Cayman Islands"
drop if country == "Central Europe and the Baltics"
drop if country == "Early-demographic dividend"
drop if country == "East Asia & Pacific"
drop if country == "East Asia & Pacific (IDA & IBRD countries)" 
drop if country == "East Asia & Pacific (excluding high income)"
drop if country == "Euro area"
drop if country == "Europe & Central Asia"
drop if country == "Europe & Central Asia (IDA & IBRD countries)"
drop if country == "Europe & Central Asia (excluding high income)"
drop if country == "European Union"
drop if country == "Fragile and conflict affected situations"
drop if country == "Guam"
drop if country == "Heavily indebted poor countries (HIPC)"
drop if country == "High income"
drop if country == "IBRD only"
drop if country == "IDA & IBRD total"
drop if country == "IDA blend"
drop if country == "IDA only"
drop if country == "IDA total"
drop if country == "Late-demographic dividend"
drop if country == "Latin America & Caribbean"
drop if country == "Latin America & Caribbean (excluding high income)"
drop if country == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if country == "Least developed countries: UN classification"
drop if country == "Low & middle income"
drop if country == "Low income"
drop if country == "Lower middle income"
drop if country == "Kosovo"
drop if country == "Middle East & North Africa"
drop if country == "Middle East & North Africa (IDA & IBRD countries)"
drop if country == "Middle East & North Africa (excluding high income)"
drop if country == "Middle income"
drop if country == "New Caledonia"
drop if country == "North America"
drop if country == "North Korea"
drop if country == "Northern Mariana Islands"
drop if country == "Not classified"
drop if country == "OECD members"
drop if country == "Other small states"
drop if country == "Pacific island small states"
drop if country == "Post-demographic dividend"
drop if country == "Pre-demographic dividend"
drop if country == "Puerto Rico"
drop if country == "Réunion"
drop if country == "Saint Helena"
drop if country == "South Asia"
drop if country == "South Asia (IDA & IBRD)"
drop if country == "South Korea"
drop if country == "Sub-Saharan Africa"
drop if country == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if country == "Sub-Saharan Africa (excluding high income)"
drop if country == "Sint Maarten (Dutch part)"
drop if country == "Small states"
drop if country == "St. Martin (French part)"
drop if country == "State of Palestine"
drop if country == "The Bahamas"
drop if country == "Turks and Caicos Islands"
drop if country == "Upper middle income"
drop if country == "Virgin Islands (U.S.)"
drop if country == "West Bank and Gaza"
drop if country == "World"

replace country = "The Bahamas" if country == "Bahamas, The"
replace country = "Brunei" if country == "Brunei Darussalam"
replace country = "Democratic Republic of the Congo" if country == "Congo, Dem. Rep."
replace country = "Republic of the Congo" if country == "Congo, Rep."
replace country = "Côte d'Ivoire" if country == "Cote d'Ivoire"
replace country = "Czech Republic" if country == "Czechia"
replace country = "Egypt" if country == "Egypt, Arab Rep."
replace country = "Faeroe Islands" if country == "Faroe Islands"
replace country = "Gambia" if country == "Gambia, The"
replace country = "Hong Kong" if country == "Hong Kong SAR, China"
replace country = "Iran" if country == "Iran, Islamic Rep."
replace country = "North Korea" if country == "Korea, Dem. People's Rep."
replace country = "South Korea" if country == "Korea, Rep."
replace country = "Kyrgyzstan" if country == "Kyrgyz Republic"
replace country = "Laos" if country == "Lao PDR"
replace country = "Macao" if country == "Macao SAR, China"
replace country = "The Federated States of Micronesia" if country == "Micronesia, Fed. Sts."
replace country = "Russia" if country == "Russian Federation"
replace country = "Slovakia" if country == "Slovak Republic"
replace country = "Syria" if country == "Syrian Arab Republic"
replace country = "Turkey" if country == "Turkiye"
replace country = "Venezuela" if country == "Venezuela, RB"
replace country = "Yemen" if country == "Yemen, Rep."

drop if _m == 2
sort country Year

*checking if there are duplicates 
// quietly by country: gen dup = cond(_N==1,0,_n)

drop countryList _merge

*saving rural and gdp datasets
save RuralUrban_GDP, replace

********************************************
****************Deforestation***************
********************************************

****Note: Deforestation data is from 2000-2010, 2010-2015, & 2015-2020

*import deforestation dataset
import delimited "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/fra2020-forestAreaChange.csv", varnames(1) case(preserve) numericcols(2 3 4 5) clear 

*cleaning it
ren v1 country
ren v3 Deforestation2010
ren v4 Deforestation2015
ren v5 Deforestation2020
drop Deforestation1000hayear
drop if Deforestation2010 == . & Deforestation2015 == . & Deforestation2020 == .
sort country

*transposing dataset
gen deforestation = "Deforestation"
encode deforestation, gen (Deforest)
// label list Class
drop deforestation

reshape long Deforestation, i(country Deforest) j(Year)
reshape wide Deforestation, i(country Year) j(Deforest)

*adding years with duplicate values 
gen freq = 11 if Year == 2010
replace freq = 5 if Year != 2010
expand freq
sort country Year
by country: gen year = 1999 + _n 

*validating the duplication is correct
by country: gen dup = 0 if year <= 2010 & Year == 2010
by country: replace dup = 0 if year >2010 & year <=2015 & Year == 2015
by country: replace dup = 0 if year >2015 & Year == 2020
tab dup
drop dup freq Year

*renaming columns
rename Deforestation1 Deforestation
rename year Year
drop if Deforestation == .

*renaming country observations by removing special characteristics
replace country = regexr(country, "\((.)+\)", "")

*renaming and dropping countries/regions
replace country = "Aruba" if country == "Aruba "
replace country = "Bahrain" if country == "Bahrain "
replace country = "Bolivia" if country == "Bolivia "
replace country = "Cayman Islands" if country == "Cayman Islands "
replace country = "Monaco" if country == "Monaco "
replace country = "North Korea" if country == ///
"Democratic People's Republic of Korea "
replace country = "Dominican Republic" if country == "Dominican Rep"
replace country = "North Macedonia" if country == "FYR Macedonia"
replace country = "Democratic Republic of the Congo" if country == "Congo"
replace country = "Holy See" if country == "Holy See "
replace country = "Côte d'Ivoire" if country == "Côte-d'Ivoire"
replace country = "Czech Republic" if country == "Czech Republik"
replace country = "Kuwait" if country == "Kuwait "
replace country = "Nauru" if country == "Nauru "
replace country = "Qatar" if country == "Qatar "
replace country = "South Korea" if country == "Republic of Korea"
replace country = "Venezuela" if country == "Venezuela "
replace country = "Turkey" if country == "Türkiye"
replace country = "United Kingdom" if country == ///
"United Kingdom of Great Britain and Northern Ireland"
replace country = "Tanzania" if country == "United Republic of Tanzania"
replace country = "USA" if country == "United States of America"
replace country = "Vietnam" if country == "Viet Nam"
replace country = "St. Vincent and the Grenadines" if country == ///
"Saint Vincent and The Grenadines"
replace country = "St. Vincent and the Grenadines" if country == ///
"Saint Vincent and the Grenadines"
replace country = "Serbia and Montenegro" if country == "Serbia & Montenegro"
replace country = "San Marino" if country == "San Marino "
replace country = "Faeroe Islands" if country == "Faroe Islands"
replace country = "Russia" if country == "Russian Federation"
replace country = "Slovakia" if country == "Slovak Republic"
replace country = "Syria" if country == "Syrian Arab Republic"

drop if country == "Africa Eastern and Southern"
drop if country == "Africa Western and Central"
drop if country == "American Samoa"
drop if country == "Arab World"
drop if country == "Bermuda"
drop if country == "British Virgin Islands"
drop if country == "Caribbean small states"
drop if country == "Cayman Islands"
drop if country == "Central Europe and the Baltics"
drop if country == "Early-demographic dividend"
drop if country == "East Asia & Pacific"
drop if country == "East Asia & Pacific (IDA & IBRD countries)" 
drop if country == "East Asia & Pacific (excluding high income)"
drop if country == "Euro area"
drop if country == "Europe & Central Asia"
drop if country == "Europe & Central Asia (IDA & IBRD countries)"
drop if country == "Europe & Central Asia (excluding high income)"
drop if country == "European Union"
drop if country == "Fragile and conflict affected situations"
drop if country == "Guam"
drop if country == "Heavily indebted poor countries (HIPC)"
drop if country == "High income"
drop if country == "IBRD only"
drop if country == "IDA & IBRD total"
drop if country == "IDA blend"
drop if country == "IDA only"
drop if country == "IDA total"
drop if country == "Late-demographic dividend"
drop if country == "Latin America & Caribbean"
drop if country == "Latin America & Caribbean (excluding high income)"
drop if country == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if country == "Least developed countries: UN classification"
drop if country == "Low & middle income"
drop if country == "Low income"
drop if country == "Lower middle income"
drop if country == "Kosovo"
drop if country == "Middle East & North Africa"
drop if country == "Middle East & North Africa (IDA & IBRD countries)"
drop if country == "Middle East & North Africa (excluding high income)"
drop if country == "Middle income"
drop if country == "New Caledonia"
drop if country == "North America"
drop if country == "Northern Mariana Islands"
drop if country == "Not classified"
drop if country == "OECD members"
drop if country == "Other small states"
drop if country == "Pacific island small states"
drop if country == "Post-demographic dividend"
drop if country == "Pre-demographic dividend"
drop if country == "Puerto Rico"
drop if country == "Réunion"
drop if country == "Saint Helena"
drop if country == "South Asia"
drop if country == "South Asia (IDA & IBRD)"
drop if country == "Sub-Saharan Africa"
drop if country == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if country == "Sub-Saharan Africa (excluding high income)"
drop if country == "Sint Maarten (Dutch part)"
drop if country == "Small states"
drop if country == "St. Martin (French part)"
drop if country == "Turks and Caicos Islands"
drop if country == "Upper middle income"
drop if country == "Virgin Islands (U.S.)"
drop if country == "West Bank and Gaza"
drop if country == "World"
drop if country == "Congo"
drop if country == "Congo, Democratic Republic"
drop if country == "Congo, Republic"
drop if country == "Congo Democratic Republic"
drop if country == "Congo Republic"
drop if country == "Congo, Republic of"
drop if country == "Congo, Republic of the"
drop if country == "Congo-Brazzaville"
drop if country == "Congo. Democratic Republic"
drop if country == "Congo. Republic of"
drop if country == "Cote d´Ivoire"
drop if country == "Côte d ́Ivoire"
drop if country == "Cote d'Ivoire"
drop if country == "Côte D'Ivoire"
drop if country == "Côte d´Ivoire"
drop if country == "Democratic Republic of Congo"
drop if country == "Dominica"
drop if country == "Dominican Rep."
drop if country == "Dominican Rep"
drop if country == "GLOBAL AVARAGE"
drop if country == "Korea (North)"
drop if country == "Korea (South)"
drop if country == "Korea, North"
drop if country == "Korea, South"
drop if country == "Kuweit"
drop if country == "Moldovaa"
drop if country == "Palestinian Authority"
drop if country == "Republic of Congo"
drop if country == "Republic of the Congo"
drop if country == "The Democratic Republic of Congo"
drop if country == "United States"
drop if country == "United States of America"
drop if country == "Viet Nam"
drop if country == "Falkland Islands"
drop if country == "French Guyana"
drop if country == "Gibraltar "
drop if country == "Guadeloupe"
drop if country == "Isle of Man "
drop if country == "Jersey "
drop if country == "Martinique"
drop if country == "Mayotte"
drop if country == "Tokelau "

*save deforestation dataset
save deforestation, replace

********************************************
****************Indicators***************
********************************************

*import indicators dataset
import delimited "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/P_Data_Extract_From_Worldwide_Governance_Indicators/690d7d1f-120c-4ac6-bdb8-f8df09f86b22_Data.csv", varnames(1) case(preserve) numericcols(5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27) clear 

*clean it
drop SeriesCode CountryCode YR1998 YR1996
keep if SeriesName == "Control of Corruption: Percentile Rank" | SeriesName == ///
"Political Stability and Absence of Violence/Terrorism: Percentile Rank" | ///
SeriesName == "Government Effectiveness: Percentile Rank"
rename CountryName country

*transposing dataset
encode SeriesName, gen (Class)
label list Class
drop SeriesName

reshape long YR, i(country Class) j(Year)
reshape wide YR, i(country Year) j(Class)

rename YR1 CorrControl
rename YR2 GovtEffect
rename YR3 PoliticStable

drop if country == "Cook Islands"
drop if country == "American Samoa"
drop if country == "Anguilla"
drop if country == "French Guiana"
drop if country == "Bermuda"
drop if country == "Cayman Islands"
drop if country == "Guam"
drop if country == "Kosovo"
drop if country == "Puerto Rico"
drop if country == "Réunion"
drop if country == "Virgin Islands (U.S.)"
drop if country == "West Bank and Gaza"
drop if country == "Jersey, Channel Islands"
drop if country == "Martinique"


replace country = "The Bahamas" if country == "Bahamas, The"
replace country = "Brunei" if country == "Brunei Darussalam"
replace country = "Democratic Republic of the Congo" if country == ///
"Congo, Dem. Rep."
replace country = "Republic of the Congo" if country == "Congo, Rep."
replace country = "Côte d'Ivoire" if country == "Cote d'Ivoire"
replace country = "Egypt" if country == "Egypt, Arab Rep."
replace country = "Gambia" if country == "Gambia, The"
replace country = "Hong Kong" if country == "Hong Kong SAR, China"
replace country = "Iran" if country == "Iran, Islamic Rep."
replace country = "North Korea" if country == "Korea, Dem. People's Rep."
replace country = "South Korea" if country == "Korea, Rep."
replace country = "Kyrgyzstan" if country == "Kyrgyz Republic"
replace country = "Laos" if country == "Lao PDR"
replace country = "Macao" if country == "Macao SAR, China"
replace country = "The Federated States of Micronesia" if country == ///
"Micronesia, Fed. Sts."
replace country = "Russia" if country == "Russian Federation"
replace country = "Taiwan" if country == "Taiwan, China"
replace country = "Slovakia" if country == "Slovak Republic"
replace country = "Turkey" if country == "Turkiye"
replace country = "USA" if country == "United States"
replace country = "Yemen" if country == "Yemen, Rep."
replace country = "Syria" if country == "Syrian Arab Republic"
replace country = "Venezuela" if country == "Venezuela, RB"


*save indicators datasets
save indicators, replace


***************************************
**************CPI Dataset**************
***************************************

*import 2000 CP data
import delimited "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI-2000_200603_083012.csv", clear 
keep country score
gen score_2000 = score/10 * 100
drop score
sort country
save CPI_2000, replace

*import 2001 CP data
import delimited "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI-2001_200603_082938.csv", clear 
keep country score
gen score_2001 = score/10 * 100
drop score
sort country
merge 1:1 country using CPI_2000
drop _m
save CPI_2001, replace

*import 2002 CP data
import delimited "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI-2002_200602_115328.csv", clear 
keep country score
gen score_2002 = score/10 * 100
drop score
sort country
merge 1:1 country using CPI_2001
drop _m
save CPI_2002, replace

*import 2003 CP data
import delimited "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI-2003_200602_113929.csv", clear 
keep country score
gen score_2003 = score/10 * 100
drop score
sort country
merge 1:1 country using CPI_2002
drop _m
save CPI_2003, replace

*import 2004 CP data
import delimited "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI-2004_200602_110140.csv", clear 
keep country score
gen score_2004 = score/10 * 100
drop score
sort country
merge 1:1 country using CPI_2003
drop _m
save CPI_2004, replace

*import 2005 CP data
import delimited "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI-2005_200602_104136.csv", clear 
keep country score
gen cpi_2005 = real(score)
gen score_2005 = cpi_2005/10 * 100
drop score cpi_2005
sort country
merge 1:1 country using CPI_2004
drop _m
save CPI_2005, replace

*import 2006 CP data
import delimited "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI-2006-new_200602_095933.csv", clear 
keep country score
gen score_2006 = score/10 * 100
drop score
sort country
merge 1:1 country using CPI_2005
drop _m
save CPI_2006, replace

*import 2007 CP data
import delimited "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI-2007-new_200602_092501.csv", clear 
keep country score
gen score_2007 = score/10 * 100
drop score
sort country
merge 1:1 country using CPI_2006
drop _m
save CPI_2007, replace

*import 2008 CP data
import delimited "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI-Archive-2008-2.csv", clear 
keep country score
gen score_2008 = score/10 * 100
drop score
sort country
merge 1:1 country using CPI_2007
drop _m
save CPI_2008, replace

*import 2009 CP data
import delimited "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI-2009-new_200601_120052.csv", clear 
keep country score
gen score_2009 = score/10 * 100
drop score
sort country
merge 1:1 country using CPI_2008
drop _m
save CPI_2009, replace

*import 2010 CP data
import delimited "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI-2010-new_200601_105629.csv", clear 
keep country score
gen score_2010 = score/10 * 100
drop score
sort country
merge 1:1 country using CPI_2009
drop _m
save CPI_2010, replace

*import 2011 CP data
import delimited "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI-2011-new_200601_104308.csv", clear 
keep country score
gen score_2011 = score/10 * 100
drop score
sort country
merge 1:1 country using CPI_2010
drop _m
save CPI_2011, replace

*import 2012 CPI data
import excel "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI2012_Results.xlsx", sheet("CPI 2012") cellrange(A1:D178) firstrow clear
keep CountryTerritory CPI2012Score
rename CountryTerritory country
rename CPI2012Score score_2012
sort country
merge 1:1 country using CPI_2011
drop _m
save CPI_2012, replace

*import 2013 CPI data
import excel "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI2013_Results_2022-01-20-183035_stnh.xlsx", sheet("CPI 2013") cellrange(A2:G180) firstrow clear
keep CountryTerritory CPI2013Score
rename CountryTerritory country
rename CPI2013Score score_2013
sort country
merge 1:1 country using CPI_2012
drop _m
save CPI_2013, replace

*import 2014 CPI data
import excel "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI2014_Results.xlsx", sheet("CPI 2014") cellrange(A1:E176) firstrow clear
keep CountryTerritory CPI2014
rename CountryTerritory country
rename CPI2014 score_2014
sort country
merge 1:1 country using CPI_2013
drop _m
save CPI_2014, replace

*import 2015 CPI data
import excel "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI_2015_FullDataSet_2022-01-18-145020_enyn_2022-01-20-180010_mabu.xlsx", sheet("CPI 2015") cellrange(A1:E169) firstrow clear
keep CountryTerritory CPI2015Score
rename CountryTerritory country
rename CPI2015Score score_2015
sort country
merge 1:1 country using CPI_2014
drop _m
save CPI_2015, replace

*import 2016 CPI data
import excel "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI2016_Results.xlsx", sheet("CPI2016_FINAL_16Jan") cellrange(A1:B177) firstrow clear
keep Country CPI2016
rename Country country
rename CPI2016 score_2016
sort country
merge 1:1 country using CPI_2015
drop _m
save CPI_2016, replace

*import 2017 CPI data
import excel "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI2017_Full_DataSet-1801.xlsx", sheet("CPI 2017") cellrange(A3:D185) firstrow clear
keep Country CPIScore2017
rename Country country
rename CPIScore2017 score_2017
sort country
merge 1:1 country using CPI_2016
drop _m
save CPI_2017, replace

*import 2018 CPI data
import excel "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI2018_Full-Results_1801.xlsx", sheet("CPI change 2017-2018") cellrange(A3:D183) firstrow clear
keep Country CPIScore2018
rename Country country
rename CPIScore2018 score_2018
sort country

list country
drop if country == "Hungary" & score == 25

merge 1:1 country using CPI_2017
drop _m
save CPI_2018, replace

*import 2019 CPI data
import excel "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI2019-1.xlsx", sheet("CPI2019") cellrange(A3:D183) firstrow clear
keep Country CPIscore2019
rename Country country
rename CPIscore2019 score_2019
sort country
merge 1:1 country using CPI_2018
drop _m
save CPI_2019, replace

*import 2020 CPI data
import excel "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI2020_GlobalTablesTS_210125.xlsx", sheet("CPI2020") cellrange(A3:D183) firstrow clear
keep Country CPIscore2020
rename Country country
rename CPIscore2020 score_2020
sort country
merge 1:1 country using CPI_2019
drop _m
save CPI_2020, replace

*import 2021 CPI data
import excel "/Users/aashi/Desktop/Developmental Economics/Research Paper/Data/CPI/CPI 2021 Full Data Set/CPI2021_GlobalResults&Trends.xlsx", sheet("CPI 2021") cellrange(A3:D183) firstrow clear
keep CountryTerritory CPIscore2021
rename CountryTerritory country
rename CPIscore2021 score_2021
sort country
merge 1:1 country using CPI_2020
drop _m
drop if country == ""
save CPI_2021, replace

describe 

*transping dataset
gen CPI = "CPI"
encode CPI, gen (cpi)
label list cpi
drop CPI

reshape long score_, i(country cpi) j(Year)
reshape wide score_, i(country Year) j(cpi)

rename score_1 CPIscore


*making changes to only a few countries before merging
replace country = "North Korea" if country == "Korea, North"
replace country = "St. Vincent and the Grenadines" if country == ///
"Saint Vincent and the Grenadines"

drop if country == "Saint Vincent and The Grenadines"
drop if country == "Côte d ́Ivoire"
drop if country == "Cote d'Ivoire"
drop if country == "Côte D'Ivoire"
drop if country == "Côte d´Ivoire"

*saving CPI final dataset
save CPI_final, replace


*Merging all datasets
*1. merge RuralUrban_GDP datset and matching countries of RuralUrban_GDP 
*with CPI_final
merge 1:1 country Year using RuralUrban_GDP
// keep if Year == 2000
// keep if _m != 3
sort country 

drop if country == "Africa Eastern and Southern"
drop if country == "Africa Western and Central"
drop if country == "American Samoa"
drop if country == "Arab World"
drop if country == "Bermuda"
drop if country == "British Virgin Islands"
drop if country == "Caribbean small states"
drop if country == "Cayman Islands"
drop if country == "Central Europe and the Baltics"
drop if country == "Early-demographic dividend"
drop if country == "East Asia & Pacific"
drop if country == "East Asia & Pacific (IDA & IBRD countries)" 
drop if country == "East Asia & Pacific (excluding high income)"
drop if country == "Euro area"
drop if country == "Europe & Central Asia"
drop if country == "Europe & Central Asia (IDA & IBRD countries)"
drop if country == "Europe & Central Asia (excluding high income)"
drop if country == "European Union"
drop if country == "Fragile and conflict affected situations"
drop if country == "Guam"
drop if country == "Heavily indebted poor countries (HIPC)"
drop if country == "High income"
drop if country == "IBRD only"
drop if country == "IDA & IBRD total"
drop if country == "IDA blend"
drop if country == "IDA only"
drop if country == "IDA total"
drop if country == "Late-demographic dividend"
drop if country == "Latin America & Caribbean"
drop if country == "Latin America & Caribbean (excluding high income)"
drop if country == "Latin America & the Caribbean (IDA & IBRD countries)"
drop if country == "Least developed countries: UN classification"
drop if country == "Low & middle income"
drop if country == "Low income"
drop if country == "Lower middle income"
drop if country == "Kosovo"
drop if country == "Middle East & North Africa"
drop if country == "Middle East & North Africa (IDA & IBRD countries)"
drop if country == "Middle East & North Africa (excluding high income)"
drop if country == "Middle income"
drop if country == "New Caledonia"
drop if country == "North America"
drop if country == "Northern Mariana Islands"
drop if country == "Not classified"
drop if country == "OECD members"
drop if country == "Other small states"
drop if country == "Pacific island small states"
drop if country == "Post-demographic dividend"
drop if country == "Pre-demographic dividend"
drop if country == "Puerto Rico"
drop if country == "Réunion"
drop if country == "Saint Helena"
drop if country == "South Asia"
drop if country == "South Asia (IDA & IBRD)"
drop if country == "Sub-Saharan Africa"
drop if country == "Sub-Saharan Africa (IDA & IBRD countries)"
drop if country == "Sub-Saharan Africa (excluding high income)"
drop if country == "Sint Maarten (Dutch part)"
drop if country == "Small states"
drop if country == "St. Martin (French part)"
drop if country == "State of Palestine"
drop if country == "The Bahamas"
drop if country == "Turks and Caicos Islands"
drop if country == "Upper middle income"
drop if country == "Virgin Islands (U.S.)"
drop if country == "West Bank and Gaza"
drop if country == "World"
drop if country == "Congo"
drop if country == "Congo Democratic Republic"
drop if country == "Congo Republic"
drop if country == "Congo, Republic of"
drop if country == "Congo, Republic of the"
drop if country == "Congo-Brazzaville"
drop if country == "Congo. Democratic Republic"
drop if country == "Congo. Republic of"
drop if country == "Cote d´Ivoire"
drop if country == "Cote d'Ivoire"
drop if country == "Côte D'Ivoire"
drop if country == "Democratic Republic of Congo"
drop if country == "Dominica"
drop if country == "Dominican Rep."
drop if country == "Dominican Rep"
drop if country == "GLOBAL AVARAGE"
drop if country == "Korea (North)"
drop if country == "Korea (South)"
drop if country == "Korea, North"
drop if country == "Korea, South"
drop if country == "Kuweit"
drop if country == "Moldovaa"
drop if country == "Palestinian Authority"
drop if country == "Republic of Congo"
drop if country == "Republic of the Congo"
drop if country == "The Democratic Republic of Congo"
drop if country == "United States"
drop if country == "United States of America"
drop if country == "Viet Nam"


replace country = "The Bahamas" if country == "Bahamas"
replace country = "Bosnia and Herzegovina" if country == "Bosnia & Herzegovina"
replace country = "Guinea-Bissau" if country == "Guinea Bissau"
replace country = "Macao" if country == "Macau"
replace country = "North Macedonia" if country == "The FYR of Macedonia"
replace country = "Trinidad and Tobago" if country == "Trinidad & Tobago"
replace country = "USA" if country == "The United States of America"
replace country = "Brunei" if country == "Brunei Darussalam"
replace country = "Czech Republic" if country == "Czechia"
replace country = "Slovakia" if country == "Slovak Republic"

sort country Year

*checking if there are duplicates 
quietly by country Year: gen dup = cond(_N==1,0,_n)
tab dup
tab country dup
drop if dup == 2
drop dup

drop _m

*2. merge deforestation datset
merge 1:1 country Year using deforestation


*checking if there are duplicates 
sort country Year
quietly by country Year: gen dup = cond(_N==1,0,_n)
tab country dup
tab dup
// drop if dup == 2
drop dup

drop _m

*3. merge indicators datset
merge 1:1 country Year using indicators
drop if country == "Serbia & Montenegro" | country == "Serbia and Montenegro"
// keep if Year == 2010

*removing variables from the final dataset
drop if country == "Czech Republik"
drop if country == "Côte d'Ivoire"
drop if country == "Côte-d'Ivoire"
drop if country == "FYR Macedonia"
drop if country == "Kribati"
drop if country == "Sao Tome & Principe"


*checking if there are duplicates 
sort country Year
quietly by country Year: gen dup = cond(_N==1,0,_n)
tab country dup
tab dup

drop _m
drop dup 

*labeling final variables 
label var CPIscore "Score country on a scale of 0 (highly corrupt) to 100 (very clean)"
label var CorrControl "Percentile rank of country on a scale of 0 (highly corrupt) to 100 (very clean)"
label var Deforestation "1000 hectare area of conversion of forest in a year"
label var GDP_2015 "GDP per capita on 2015 constant prices in US dollar"
label var RuralPop "Rural population as % of total population"
label var UrbanPop "Urban population as % of total population"
label var GovtEffect "Percentile rank of country on a scale of 0 (least effective government) to 100 (most effective government)"
label var PoliticStable "Percentile rank of country on a scale of 0 (least politicaly stable) to 100 (most politicaly stable)"
label var Year "Year"

save final, replace

                             **************************************************
                             *****************Summary & Graphs*****************
                             **************************************************
							 
*summary statistics
ssc install asdoc
asdoc summarize CPIscore CorrControl Deforestation GDP_2015 RuralPop ///
UrbanPop GovtEffect PoliticStable, separator(10)

*new log variables generated
gen ln_CorrControl = ln(CorrControl)
label var ln_CorrControl "natural log of CorrControl"

gen ln_Deforestation = ln(Deforestation)
label var ln_Deforestation "natural log of variable Deforestation"

gen ln_GDP_2015 = ln(GDP_2015)
label var ln_GDP_2015 "natural log of variable GDP_2015"

gen ln_RuralPop = ln(RuralPop)
label var ln_RuralPop "natural log of RuralPop"

gen ln_UrbanPop = ln(UrbanPop)
label var ln_UrbanPop "natural log of UrbanPop"

gen ln_GovtEffect = ln(GovtEffect)
label var ln_UrbanPop "natural log of ln_GovtEffect"

gen ln_PoliticStable = ln(PoliticStable)
label var ln_UrbanPop "natural log of PoliticStable"

encode country, gen(Country)

*forming histograms
histogram CPIscore, fcolor("169 145 234") lcolor("136 114 228") normal ///
normopts(lcolor(black%100) lpattern(shortdash_dot)) kdensity ///
kdenopts(lcolor("17 0 240")) xtitle(CPI score) by(, legend(on at(23))) ///
name(G1, replace) by(Year, style(econ) imargin(small) cols(4))

*construct boxplot to observe outliers
graph box CPIscore, box(1, fcolor(forest_green) lcolor(maroon)) ///
medtype(cline) medline(lcolor(dknavy) lpattern(dash)) ///
marker(1, mcolor("185 0 76")) ytitle(CPI score) ylabel(, labsize(vsmall)) ///
by(, title(Box plot depicting outliers in CPI score, size(medsmall)) ///
subtitle((over 21 years), size(small))) by(, legend(off)) by(Year)

histogram ln_CorrControl, fcolor("169 145 234") lcolor("136 114 228") ///
normal normopts(lcolor(black%100) lpattern(shortdash_dot)) kdensity ///
kdenopts(lcolor("17 0 240")) xtitle(Natural log of CorrControl) ///
by(, legend(on at(23))) name(G2, replace) by(Year, style(econ) ///
imargin(small) cols(4))

*construct boxplot to observe outliers
graph box ln_CorrControl, box(1, fcolor(forest_green) lcolor(maroon)) ///
medtype(cline) medline(lcolor(dknavy) lpattern(dash)) ///
marker(1, mcolor("185 0 76")) ytitle(ln_CorrControl) ///
ylabel(, labsize(vsmall)) ///
by(, title(Box plot depicting outliers in ln_CorrControl, size(medsmall)) ///
subtitle((over 21 years), size(small))) by(, legend(off)) by(Year)

histogram ln_Deforestation, fcolor("169 145 234") lcolor("136 114 228") ///
normal normopts(lcolor(black%100) lpattern(shortdash_dot)) kdensity ///
kdenopts(lcolor("17 0 240")) xtitle(Natural log of Deforestation) ///
by(, legend(on at(23))) name(G3, replace) by(Year, style(econ) ///
imargin(small) cols(4))

*building histograms to see the missing rectangle in 2011
histogram ln_Deforestation if Year == 2010, bin(30) start(-5) frequency ///
fcolor(brown) addlabel addlabopts(mlabsize(6-pt)) normal ///
normopts(lpattern(dash_dot)) kdensity xtitle(Natural log of deforestation) ///
xscale(range(-5 10)) title(For 2010) legend(on) name(deforest_2010, replace)
histogram ln_Deforestation if Year == 2011, bin(30) start(-5) frequency ///
fcolor(brown) addlabel addlabopts(mlabsize(6-pt)) normal ///
normopts(lpattern(dash_dot)) kdensity xtitle(Natural log of deforestation) ///
xscale(range(-5 10)) title(For 2011) legend(on) name(deforest_2011, replace)
graph combine deforest_2010 deforest_2011

*construct boxplot to observe outliers
graph box ln_Deforestation, box(1, fcolor(forest_green) lcolor(maroon)) ///
medtype(cline) medline(lcolor(dknavy) lpattern(dash)) ///
marker(1, mcolor("185 0 76")) ytitle(ln_Deforestation) ///
ylabel(, labsize(vsmall)) ///
by(, title(Box plot depicting outliers in ln_Deforestation, size(medsmall)) ///
subtitle((over 21 years), size(small))) by(, legend(off)) by(Year)

*line chart
twoway (line ln_CorrControl Year if Country == 30) ///
(line ln_CorrControl Year if Country == 1) ///
(line ln_CorrControl Year if Country == 49), legend(label(1 "Country = 30") ///
label(2 "Country = 1") label(3 "Country = 49"))

histogram ln_GDP_2015, fcolor("169 145 234") ///
lcolor("136 114 228") normal ///
normopts(lcolor(black%100) lpattern(shortdash_dot)) kdensity ///
kdenopts(lcolor("17 0 240")) xtitle(Natural log of GDP_2015) ///
by(, legend(on at(23))) name(G4, replace) ///
by(Year, style(econ) imargin(small) cols(4))

histogram ln_RuralPop, fcolor("169 145 234") lcolor("136 114 228") normal ///
normopts(lcolor(black%100) lpattern(shortdash_dot)) kdensity ///
kdenopts(lcolor("17 0 240")) xtitle(Natural log of RuralPop) ///
by(, legend(on at(23))) name(G5, replace) ///
by(Year, style(econ) imargin(small) cols(4))

histogram ln_UrbanPop, fcolor("169 145 234") lcolor("136 114 228") normal ///
normopts(lcolor(black%100) lpattern(shortdash_dot)) kdensity ///
kdenopts(lcolor("17 0 240")) xtitle(Natural log of UrbanPop) ///
by(, legend(on at(23))) name(G6, replace) ///
by(Year, style(econ) imargin(small) cols(4))

histogram ln_GovtEffect, fcolor("169 145 234") lcolor("136 114 228") normal ///
normopts(lcolor(black%100) lpattern(shortdash_dot)) kdensity ///
kdenopts(lcolor("17 0 240")) xtitle(Natural log of GovtEffect) ///
by(, legend(on at(23))) name(G7, replace) ///
by(Year, style(econ) imargin(small) cols(4))

histogram ln_PoliticStable, fcolor("169 145 234") lcolor("136 114 228") ///
normal normopts(lcolor(black%100) lpattern(shortdash_dot)) kdensity ///
kdenopts(lcolor("17 0 240")) xtitle(Natural log of PoliticStable) ///
by(, legend(on at(23))) name(G8, replace) ///
by(Year, style(econ) imargin(small) cols(4))

twoway (scatter ln_Deforestation CPIscore, sort mcolor("0 169 24") ///
msize(vsmall) msymbol(circle)) ///
(lfit ln_Deforestation CPIscore, lcolor("0 0 0 %80")), ///
ytitle(Natural log of Deforestation) xtitle(CPI score) ///
title(Scatter plot of ln_deforestation and CPI score)  ///
subtitle((Pooled data)) name(S1, replace)

twoway (scatter ln_Deforestation ln_CorrControl, sort mcolor("0 169 24") ///
msize(vsmall) msymbol(circle)) ///
(lfit ln_Deforestation ln_CorrControl, lcolor("0 0 0 %80")), ///
ytitle(Natural log of Deforestation) xtitle(Natural lof of CorrControl) ///
title(Scatter plot of ln_deforestation and ln_CorrControl) ///
subtitle((Pooled data)) name(S2, replace)

                             **************************************************
                             *****************Regression Analysis**************
                             **************************************************
*correlation matrix
asdoc corr CPIscore ln_CorrControl ln_Deforestation ln_GDP_2015 ln_RuralPop ///
ln_UrbanPop ln_GovtEffect ln_PoliticStable

******CPI score
*pooled method using OLS
reg ln_Deforestation CPIscore, r
outreg2 using Myreg.doc, replace ctitle(Model 1)

reg ln_Deforestation CPIscore ln_GDP_2015, r
outreg2 using Myreg.doc, append ctitle(Model 2)

reg ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop, r
outreg2 using Myreg.doc, append ctitle(Model 3)

reg ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop ln_RuralPop, r
outreg2 using Myreg.doc, append ctitle(Model 4)

reg ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop ln_RuralPop ///
ln_GovtEffect, r
outreg2 using Myreg.doc, append ctitle(Model 5)

reg ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop ln_RuralPop ///
ln_GovtEffect ln_PoliticStable, r
outreg2 using Myreg.doc, append ctitle(Model 6)

*entity fixed effects
xtset Country Year
xtreg ln_Deforestation CPIscore, fe vce(cluster country)
outreg2 using StateOnly.doc, replace ctitle(Model 1) ///
addtext(Country Fixed Effects, Yes)

xtreg ln_Deforestation CPIscore ln_GDP_2015, fe vce(cluster country)
outreg2 using StateOnly.doc, append ctitle(Model 2) ///
addtext(Country Fixed Effects, Yes)

xtreg ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop, fe vce(cluster country)
outreg2 using StateOnly.doc, append ctitle(Model 3) ///
addtext(Country Fixed Effects, Yes)

xtreg ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop ln_RuralPop, fe vce(cluster country)
outreg2 using StateOnly.doc, append ctitle(Model 4) ///
addtext(Country Fixed Effects, Yes)

xtreg ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop ln_RuralPop ln_GovtEffect, fe vce(cluster country)
outreg2 using StateOnly.doc, append ctitle(Model 5) ///
addtext(Country Fixed Effects, Yes)

xtreg ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop ln_RuralPop ln_GovtEffect ln_PoliticStable, fe vce(cluster country)
outreg2 using StateOnly.doc, append ctitle(Model 6) ///
addtext(Country Fixed Effects, Yes)

*time fixed effects
reg ln_Deforestation CPIscore i.Year
outreg2 using TimeOnly.doc, replace ctitle(Model 1) ///
addtext(Time Fixed Effects, Yes) keep(ln_Deforestation CPIscore)

reg ln_Deforestation CPIscore ln_GDP_2015 i.Year
outreg2 using TimeOnly.doc, append ctitle(Model 2) ///
addtext(Time Fixed Effects, Yes) keep(ln_Deforestation CPIscore ln_GDP_2015)

reg ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop i.Year
outreg2 using TimeOnly.doc, append ctitle(Model 3) ///
addtext(Time Fixed Effects, Yes) ///
keep(ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop)

reg ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop ln_RuralPop i.Year
outreg2 using TimeOnly.doc, append ctitle(Model 4) ///
addtext(Time Fixed Effects, Yes) ///
keep(ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop ln_RuralPop)

reg ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop ln_RuralPop ///
ln_GovtEffect i.Year
outreg2 using TimeOnly.doc, append ctitle(Model 5) ///
addtext(Time Fixed Effects, Yes) keep(ln_Deforestation CPIscore ln_GDP_2015 ///
ln_UrbanPop ln_RuralPop ln_GovtEffect)

reg ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop ln_RuralPop ///
ln_GovtEffect ln_PoliticStable i.Year
outreg2 using TimeOnly.doc, append ctitle(Model 6) ///
addtext(Time Fixed Effects, Yes) keep(ln_Deforestation CPIscore ln_GDP_2015 ///
ln_UrbanPop ln_RuralPop ln_GovtEffect ln_PoliticStable) 

*State & time fixed effects
xtreg ln_Deforestation CPIscore i.Year, fe vce(cluster country)
outreg2 using StateTime.doc, replace ctitle(Model 1) ///
addtext(Country Fixed Effects, Yes, Time Fixed Effects, Yes) ///
keep(ln_Deforestation CPIscore)

xtreg ln_Deforestation CPIscore ln_GDP_2015  i.Year, fe vce(cluster country)
outreg2 using StateTime.doc, append ctitle(Model 2) ///
addtext(Country Fixed Effects, Yes, Time Fixed Effects, Yes) ///
keep(ln_Deforestation CPIscore ln_GDP_2015)

xtreg ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop  i.Year, fe vce(cluster country)
outreg2 using StateTime.doc, append ctitle(Model 3) ///
addtext(Country Fixed Effects, Yes, Time Fixed Effects, Yes) ///
keep(ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop)

xtreg ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop ln_RuralPop  i.Year, fe vce(cluster country)
outreg2 using StateTime.doc, append ctitle(Model 4) ///
addtext(Country Fixed Effects, Yes, Time Fixed Effects, Yes) ///
keep(ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop ln_RuralPop)

xtreg ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop ln_RuralPop ln_GovtEffect  i.Year, fe vce(cluster country)
outreg2 using StateTime.doc, append ctitle(Model 5) ///
addtext(Country Fixed Effects, Yes, Time Fixed Effects, Yes) ///
keep(ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop ln_RuralPop ln_GovtEffect)

xtreg ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop ln_RuralPop ///
ln_GovtEffect ln_PoliticStable  i.Year, fe vce(cluster country)
outreg2 using StateTime.doc, append ctitle(Model 6) ///
addtext(Country Fixed Effects, Yes, Time Fixed Effects, Yes) ///
keep(ln_Deforestation CPIscore ln_GDP_2015 ln_UrbanPop ln_RuralPop ///
ln_GovtEffect ln_PoliticStable)

******ln_CorrControl
*pooled method using OLS
reg ln_Deforestation ln_CorrControl, r
outreg2 using Myreg1.doc, replace ctitle(Model 1)

reg ln_Deforestation ln_CorrControl ln_GDP_2015, r
outreg2 using Myreg1.doc, append ctitle(Model 2)

reg ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop, r
outreg2 using Myreg1.doc, append ctitle(Model 3)

reg ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop ln_RuralPop, r
outreg2 using Myreg1.doc, append ctitle(Model 4)

reg ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop ln_RuralPop ///
ln_GovtEffect, r
outreg2 using Myreg1.doc, append ctitle(Model 5)

reg ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop ln_RuralPop ///
ln_GovtEffect ln_PoliticStable, r
outreg2 using Myreg1.doc, append ctitle(Model 6)

*entity fixed effects
xtset Country Year
xtreg ln_Deforestation ln_CorrControl, fe vce(cluster country)
outreg2 using StateOnly1.doc, replace ctitle(Model 1) ///
addtext(Country Fixed Effects, Yes)

xtreg ln_Deforestation ln_CorrControl ln_GDP_2015, fe vce(cluster country)
outreg2 using StateOnly1.doc, append ctitle(Model 2) ///
addtext(Country Fixed Effects, Yes)

xtreg ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop, ///
fe vce(cluster country)
outreg2 using StateOnly1.doc, append ctitle(Model 3) ///
addtext(Country Fixed Effects, Yes)

xtreg ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop ln_RuralPop, ///
fe vce(cluster country)
outreg2 using StateOnly1.doc, append ctitle(Model 4) ///
addtext(Country Fixed Effects, Yes)

xtreg ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop ln_RuralPop ///
ln_GovtEffect, fe vce(cluster country)
outreg2 using StateOnly1.doc, append ctitle(Model 5) ///
addtext(Country Fixed Effects, Yes)

xtreg ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop ln_RuralPop ///
ln_GovtEffect ln_PoliticStable, fe vce(cluster country)
outreg2 using StateOnly1.doc, append ctitle(Model 6) ///
addtext(Country Fixed Effects, Yes)

*time fixed effects
reg ln_Deforestation ln_CorrControl i.Year
outreg2 using TimeOnly1.doc, replace ctitle(Model 1) ///
addtext(Time Fixed Effects, Yes) keep(ln_Deforestation ln_CorrControl)

reg ln_Deforestation ln_CorrControl ln_GDP_2015 i.Year
outreg2 using TimeOnly1.doc, append ctitle(Model 2) ///
addtext(Time Fixed Effects, Yes) ///
keep(ln_Deforestation ln_CorrControl ln_GDP_2015)

reg ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop i.Year
outreg2 using TimeOnly1.doc, append ctitle(Model 3) ///
addtext(Time Fixed Effects, Yes) keep(ln_Deforestation ///
ln_CorrControl ln_GDP_2015 ln_UrbanPop)

reg ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop ln_RuralPop i.Year
outreg2 using TimeOnly1.doc, append ctitle(Model 4) ///
addtext(Time Fixed Effects, Yes) keep(ln_Deforestation ///
ln_CorrControl ln_GDP_2015 ln_UrbanPop ln_RuralPop)

reg ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop ln_RuralPop ///
ln_GovtEffect i.Year
outreg2 using TimeOnly1.doc, append ctitle(Model 5) ///
addtext(Time Fixed Effects, Yes) keep(ln_Deforestation ln_CorrControl ///
ln_GDP_2015 ln_UrbanPop ln_RuralPop ln_GovtEffect)

reg ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop ln_RuralPop ///
ln_GovtEffect ln_PoliticStable i.Year
outreg2 using TimeOnly1.doc, append ctitle(Model 6) ///
addtext(Time Fixed Effects, Yes) ///
keep(ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop ln_RuralPop ln_GovtEffect ln_PoliticStable) 

*State & time fixed effects
xtreg ln_Deforestation ln_CorrControl i.Year, fe vce(cluster country)
outreg2 using StateTime1.doc, replace ctitle(Model 1) ///
addtext(Country Fixed Effects, Yes, Time Fixed Effects, Yes) ///
keep(ln_Deforestation ln_CorrControl)

xtreg ln_Deforestation ln_CorrControl ln_GDP_2015  i.Year, fe vce(cluster country)
outreg2 using StateTime1.doc, append ctitle(Model 2) ///
addtext(Country Fixed Effects, Yes, Time Fixed Effects, Yes) ///
keep(ln_Deforestation ln_CorrControl ln_GDP_2015)

xtreg ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop  ///
i.Year, fe vce(cluster country)
outreg2 using StateTime1.doc, append ctitle(Model 3) ///
addtext(Country Fixed Effects, Yes, Time Fixed Effects, Yes) ///
keep(ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop)

xtreg ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop ///
ln_RuralPop  i.Year, fe vce(cluster country)
outreg2 using StateTime1.doc, append ctitle(Model 4) ///
addtext(Country Fixed Effects, Yes, Time Fixed Effects, Yes) ///
keep(ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop ln_RuralPop)

xtreg ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop ln_RuralPop ///
ln_GovtEffect  i.Year, fe vce(cluster country)
outreg2 using StateTime1.doc, append ctitle(Model 5) ///
addtext(Country Fixed Effects, Yes, Time Fixed Effects, Yes) ///
keep(ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop ln_RuralPop ln_GovtEffect)

xtreg ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop ln_RuralPop ///
ln_GovtEffect ln_PoliticStable  i.Year, fe vce(cluster country)
outreg2 using StateTime1.doc, append ctitle(Model 6) ///
addtext(Country Fixed Effects, Yes, Time Fixed Effects, Yes) ///
keep(ln_Deforestation ln_CorrControl ln_GDP_2015 ln_UrbanPop ln_RuralPop ln_GovtEffect ln_PoliticStable)




log close
