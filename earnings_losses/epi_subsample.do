
local filepath "/scratch/kb103/stata/synthesis2010"
use "`filepath'/epi1-1.dta", clear
gen r=runiform()
keep if r<0.1
save "`filepath'/epi1-1_subsample.dta", replace
