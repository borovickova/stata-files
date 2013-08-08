local filepath "/scratch/kb103/stata/synthesis2010"
/*
forval ii=1/10{
	use "`filepath'/epi`ii'-0.dta"
	append using "`filepath'/epi`ii'-1.dta"
	keep if lfstatus==2
	keep pid bdate edate
	drop if bdate==edate
	save "`filepath'/unemployed_`ii'.dta", replace
}

use "`filepath'/unemployed_1.dta"
forval ii=2/10{
	append using "`filepath'/unemployed_`ii'.dta"
}
save "`filepath'/unemployed_all.dta", replace
*/

clear
set maxvar 1200
use "`filepath'/unemployed_all.dta"
 
gen int ref_date = .
gen int ref_date_prev = .
gen int ref_date_next = .

forval yy = 1975/2007{
*forval yy = 1975/1975{
	forval mm = 1/12{
		
		local mm1 = cond(`mm'<12,`mm'+1,1)
		local yy1 = cond(`mm'<12,`yy',`yy'+1)

		local mmn = cond(`mm'<11,`mm'+2,`mm'-10)
		local yyn = cond(`mm'<11,`yy',`yy'+1)

		replace ref_date = mdy(`mm1',1,`yy1')-1
		replace ref_date_prev = mdy(`mm',1,`yy')-1
		replace ref_date_next = mdy(`mmn',1,`yyn')-1
		
		gen byte U_`yy'_`mm' = 1 if bdate<=ref_date & edate>=ref_date
		gen byte Uin_`yy'_`mm' = 1 if U_`yy'_`mm' ==1 & bdate>ref_date_prev
		gen byte Uou_`yy'_`mm' = 1 if U_`yy'_`mm' ==1 & edate<ref_date_next
	}
}
	
saveold "`filepath'/unemployed_ind_stats.dta", replace

keep bdate U*
collapse (count) bdate U*

saveold "`filepath'/unemployed_stats.dta", replace
