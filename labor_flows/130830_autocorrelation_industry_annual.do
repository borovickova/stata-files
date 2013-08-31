
*set memory 14000m
local filepath "/scratch/kb103/stata/labor_flows"

use "`filepath'/autocorrelation_industry.dta"
xtset, clear

drop if empQ==0
drop if empQ==.
keep if quarter==1

set fid year
xtset fid year
drop lnemp_lag
gen lnemp_lag = L1.lnemp

gen int ind2 = floor(indclass/100)
matrix ALL = J(99,1,.)
matrix A1990 = J(99,1,.)
matrix A2007 = J(99,1,.)

forval jj = 1/10{
	local kk1 = (`jj'-1)*10
	local kk2 = `jj'*10
	
*forval ii = 1/99{
forval ii = `kk1'/`kk2'{
	xi: xtreg lnemp lnemp_lag i.time i.size_cat i.age_cat if ind2==`ii', fe	
	matrix Bx = e(b)
	matrix ALL[`ii',1]=Bx[1,1] 
 
	xi: xtreg lnemp lnemp_lag i.size_cat i.age_cat if ind2==`ii' & year<=1990, fe
	matrix Bx = e(b)
	matrix A1990[`ii',1]=Bx[1,1] 
	
	xi: xtreg lnemp lnemp_lag i.size_cat i.age_cat if ind2==`ii' & year>1990, fe
	matrix Bx = e(b)
	matrix A2007[`ii',1]=Bx[1,1] 

}
svmat ALL
svmat A1990 
svmat A2007
save "`filepath'/autocorrelation_industry_matrix_`jj'.dta", replace
}
