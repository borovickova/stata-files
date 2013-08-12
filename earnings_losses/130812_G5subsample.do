local filepath "/scratch/kb103/stata/earnings_losses"
use "`filepath'/regression_annual_income_year_CTG51982.dta"
keep if _n<5000
saveold "regression_annual_income_year_CTG51982_subsample.dta", replace
