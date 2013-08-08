* EARNINGS LOSSES OF DISPLACED WORKERS
* CONSIDER ONLY UND AND UNA TYPES
* REGRESSIONS

* IDENTIFY CONTROL AND TREATMENT GROUP

local filepath "/scratch/kb103/stata/earnings_losses"

forval ii = 1/10{

	use "`filepath'/130508employed_UStype_EL_`ii'_0.dta", clear
	append using "`filepath'/130508employed_UStype_EL_`ii'_1.dta"	
	merge m:1 fid year using "`filepath'/130508_firms_stats_EL_merged_25.dta"

	keep if _merge==3
	drop _merge

	gen byte A1=0
	replace A1 = 1 if age<=50 & age>=16

	gen byte T1= 0
	replace T1 = 1 if tenure_ps>= 4

	gen byte T2 = 0
	replace T2 = 1 if tenure_current >1095 & tenure_current~=.
	
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
	* treatment group
	gen byte TG3_men = 1 if A1==1 & sex==1 & T3==1 & sepD==1 & mass_layoff_indic ==1
	gen byte TG4_men = 1 if A1==1 & sex==1 & T4==1 & sepD==1 & mass_layoff_indic ==1
	gen byte TG5_men = 1 if A1==1 & sex==1 & T5==1 & sepD==1 & mass_layoff_indic ==1
	
	gen byte TG3_women = 1 if A1==1 & sex==2 & T3==1 & sepD==1 & mass_layoff_indic ==1
	gen byte TG4_women = 1 if A1==1 & sex==2 & T4==1 & sepD==1 & mass_layoff_indic ==1
	gen byte TG5_women = 1 if A1==1 & sex==2 & T5==1 & sepD==1 & mass_layoff_indic ==1
	
	* treatment group
	gen byte CG3_men = 1 if A1==1 & sex==1 & T3==1 & FEyP1== 1 & FEyP2== 1 & emp>=25
	gen byte CG4_men = 1 if A1==1 & sex==1 & T4==1 & FEyP1== 1 & FEyP2== 1 & emp>=25
	gen byte CG5_men = 1 if A1==1 & sex==1 & T5==1 & FEyP1== 1 & FEyP2== 1 & emp>=25
	
	gen byte CG3_women = 1 if A1==1 & sex==2 & T3==1 & FEyP1== 1 & FEyP2== 1 & emp>=25
	gen byte CG4_women = 1 if A1==1 & sex==2 & T4==1 & FEyP1== 1 & FEyP2== 1 & emp>=25
	gen byte CG5_women = 1 if A1==1 & sex==2 & T5==1 & FEyP1== 1 & FEyP2== 1 & emp>=25

	
	gen byte TG_men =1 if TG3_men==1 | TG4_men==1 | TG5_men==1
	gen byte TG_women =1 if TG3_women==1 | TG4_women==1 | TG5_women==1
	gen byte CG_men =1 if CG3_men==1 | CG4_men==1 | CG5_men==1
	gen byte CG_women =1 if CG3_women==1 | CG4_women==1 | CG5_women==1
	
	keep if CG_men==1 | CG_women==1 | TG_men==1 | TG_women==1 
	
	keep year pid fid age sex FE* days* T* CG* TG* days_worked_beginning days_worked_break
	compress
	save  "`filepath'/control_treatment_ind_`ii'.dta", replace
}

