clear
cd C:\Users\econuser\Downloads\stata
capture log close
log using statademo.log, replace text
set more off


insheet using "country.csv"
/* Summary statistics */
summarize
// Check part of the data
list country* year pop in 5/10
* Summarize population by year
tab year, sum(pop)
bysort year: sum pop

// Recode -999 to missing
recode pop cgdp (-999 = .)

// Prepare for merging
sort countrycode year
save country, replace

// Input another data set
clear
insheet using "country2.csv"
sort countrycode year

// Merge data
merge 1:1 countrycode year using country.dta
tab _merge
keep if _merge==3 
drop _merge
save country2, replace

// Collapse to get summary statistics
preserve
collapse (sum) cgdp, by(country)
restore

// Calculate the difference between 2008 and 2005 population
gen temp1=pop if year==2005
egen temp2=max(temp1), by(countrycode)
gen temp3=pop-temp2 if year==2008
egen diff=max(temp3), by(countrycode)
drop temp*

// Create a new variable ctyno which takes numerical values
encode country, gen(ctyno)
codebook ctyno

// Generate dummy
gen largepop=(pop>=100000000) if pop!=.
tab largepop, m

// fillin missing country or year
fillin countrycode year

// Reshape from long to wide
keep countrycode year pop
reshape wide pop, i(countrycode) j(year)
reshape long pop, i(countrycode) j(year)



log close
