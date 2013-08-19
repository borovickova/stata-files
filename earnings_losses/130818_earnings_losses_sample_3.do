* EARNINGS LOSSES OF DISPLACED WORKERS
* CONSIDER ONLY UND AND UNA TYPES

* USE A CONTROL GROUP WHICH DID NOT SEPARATE IN YEAR y

local filepath "/scratch/kb103/stata/earnings_losses"

forval ii = 1/10{

	use "`filepath'/130508employed_UStype_EL_`ii'_0.dta", clear
	append using "`filepath'/130508employed_UStype_EL_`ii'_1.dta"	
	merge m:1 fid year using "`filepath'/130508_firms_stats_EL_merged_25.dta"

	keep if _merge==3
	drop _merge

	gen byte A1=0
	replace A1 = 1 if age<=50 & age>=16

	gen byte T3 = 0
	replace T3  = 1 if FEyM1==1 & FEyM2==1 & FEyM3==1

	gen byte T4 = 0
	replace T4  = 1 if FEyM1==1 & FEyM2==1

	gen byte T5 = 0
	replace T5 = 1 if days_worked_beginning > 1095
	
	gen byte T6 = 0
	replace T6  = 1 if days_worked_break > 1095

	* control and treatment group
	
	gen byte sepD = 1 if FEyP1~= 1 & edate~=17531
	
	* control and treatment group
	drop if emp==.
	
	* control group
	gen byte CG7_men = 1 if A1==1 & sex==1 & T3==1 & FEyP1== 1 & emp>=25
	gen byte CG8_men = 1 if A1==1 & sex==1 & T4==1 & FEyP1== 1 & emp>=25
	gen byte CG9_men = 1 if A1==1 & sex==1 & T5==1 & FEyP1== 1 & emp>=25
		
	gen byte CG7_women = 1 if A1==1 & sex==2 & T3==1 & FEyP1== 1 & emp>=25
	gen byte CG8_women = 1 if A1==1 & sex==2 & T4==1 & FEyP1== 1 & emp>=25
	gen byte CG9_women = 1 if A1==1 & sex==2 & T5==1 & FEyP1== 1 & emp>=25
	
	gen byte CG_men =1 if CG7_men==1 | CG8_men==1 | CG9_men==1
	gen byte CG_women =1 if CG7_women==1 | CG8_women==1 | CG9_women==1
	
	keep if CG_men==1 | CG_women==1 
	
	keep year pid fid age sex FE* days* CG* days_worked_beginning days_worked_break
	compress
	save  "`filepath'/control_789_ind_`ii'.dta", replace
}

