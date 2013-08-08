* EARNINGS LOSSES OF DISPLACED WORKERS
* CONSIDER ONLY UND AND UNA TYPES
* REGRESSIONS

* FIRST, IDENTIFY CONTROL AND TREATMENT GROUP
/*
forval ii=1/10{

	use "/mnt/ide0/home/kotovova/stata/Synthesis2010/earnings_losses/130508employed_UStype_EL_`ii'_0.dta", clear
	append using "/mnt/ide0/home/kotovova/stata/Synthesis2010/earnings_losses/130508employed_UStype_EL_`ii'_1.dta"	
	*use "/mnt/ide0/home/kotovova/stata/Synthesis2010/earnings_losses/130508employed_UStype_EL_1_0.dta", clear
	*append using "/mnt/ide0/home/kotovova/stata/Synthesis2010/earnings_losses/130508employed_UStype_EL_1_1.dta"
	merge m:1 fid year using "/mnt/ide0/home/kotovova/stata/Synthesis2010/earnings_losses/130508_firms_stats_EL_merged_25.dta"

	keep if _merge==3
	drop _merge

	gen byte A1=0
	replace A1 = 1 if age<=50 & age>=16

	gen byte T1= 0
	replace T1 = 1 if tenure_ps>= 4

	gen byte T2 = 0
	replace T2 = 1 if tenure_current >1095 & tenure_current~=.
	
	gen byte T3= 0
	replace T3 = 1 if FEyM1==1 & FEyM2==1 & FEyM3==1

	gen byte T4= 0
	replace T4 = 1 if FEyM1==1 & FEyM2==1

	gen byte T5 = 0
	replace T5 = 1 if days_worked_beginning > 1095
	
	gen byte T6 = 0
	replace T6 = 1 if days_worked_break >1095

	* control and treatment group
	
	gen byte sepD = 1 if FEyP1~= 1 & edate~=17531
	
	
	* control and treatment group
	drop if emp==.
	* control group
	gen byte CG3_men = 1 if A1==1 & sex==1 & T3==1 & sepD==1 & mass_layoff_indic ==1
	gen byte CG4_men = 1 if A1==1 & sex==1 & T4==1 & sepD==1 & mass_layoff_indic ==1
	gen byte CG5_men = 1 if A1==1 & sex==1 & T5==1 & sepD==1 & mass_layoff_indic ==1
	
	gen byte CG3_women = 1 if A1==1 & sex==2 & T3==1 & sepD==1 & mass_layoff_indic ==1
	gen byte CG4_women = 1 if A1==1 & sex==2 & T4==1 & sepD==1 & mass_layoff_indic ==1
	gen byte CG5_women = 1 if A1==1 & sex==2 & T5==1 & sepD==1 & mass_layoff_indic ==1
	
	* treatment group
	gen byte TG3_men = 1 if A1==1 & sex==1 & T3==1 & FEyP1== 1 & mass_layoff_indic ~=1 & emp>=25
	gen byte TG4_men = 1 if A1==1 & sex==1 & T4==1 & FEyP1== 1 & mass_layoff_indic ~=1 & emp>=25
	gen byte TG5_men = 1 if A1==1 & sex==1 & T5==1 & FEyP1== 1 & mass_layoff_indic ~=1 & emp>=25
	
	gen byte TG3_women = 1 if A1==1 & sex==2 & T3==1 & FEyP1== 1 & mass_layoff_indic ~=1 & emp>=25
	gen byte TG4_women = 1 if A1==1 & sex==2 & T4==1 & FEyP1== 1 & mass_layoff_indic ~=1 & emp>=25
	gen byte TG5_women = 1 if A1==1 & sex==2 & T5==1 & FEyP1== 1 & mass_layoff_indic ~=1 & emp>=25
	
	gen byte CG_men =1 if CG3_men==1 | CG4_men==1 | CG5_men==1
	gen byte CG_women =1 if CG3_women==1 | CG4_women==1 | CG5_women==1
	gen byte TG_men =1 if TG3_men==1 | TG4_men==1 | TG5_men==1
	gen byte TG_women =1 if TG3_women==1 | TG4_women==1 | TG5_women==1

	keep if CG_men==1 | CG_women==1 | TG_men==1 | TG_women==1
	
	keep year pid fid age sex FE* days* T* CG* TG* days_worked_beginning days_worked_break
	compress
	save  "/mnt/ide0/home/kotovova/stata/Synthesis2010/earnings_losses/control_treatment_ind_`ii'.dta", replace
}

* YEAR 1980
forval ii=1/10{
	use "/mnt/ide0/home/kotovova/stata/Synthesis2010/earnings_losses/control_treatment_ind_`ii'.dta", clear
	keep if year==1980
	sort pid
	by pid: gen int index = _n
	keep if index==1
	drop index
	rename fid fid_group
	rename year year_group
	save "/mnt/ide0/home/kotovova/stata/Synthesis2010/earnings_losses/control_treatment_ind_`ii'_1980.dta", replace
}

forval ii=1/10{
	*use "/mnt/ide0/home/kotovova/stata/Synthesis2010/employed_UStype_1_0.dta"
	*append using "/mnt/ide0/home/kotovova/stata/Synthesis2010/employed_UStype_1_1.dta"
	use "/mnt/ide0/home/kotovova/stata/Synthesis2010/employed_UStype_`ii'_0.dta"
	append using "/mnt/ide0/home/kotovova/stata/Synthesis2010/employed_UStype_`ii'_1.dta"
	sort pid 
	merge m:1 pid using "/mnt/ide0/home/kotovova/stata/Synthesis2010/earnings_losses/control_treatment_ind_`ii'_1980.dta"
	keep if _merge==3
	drop _merge
	save "/mnt/ide0/home/kotovova/stata/Synthesis2010/control_treatment_UStype_`ii'_1980.dta", replace
}
*/
/*
use "/mnt/ide0/home/kotovova/stata/Synthesis2010/control_treatment_UStype_1_1980.dta"
forval ii=2/10{
	append using "/mnt/ide0/home/kotovova/stata/Synthesis2010/control_treatment_UStype_`ii'_1980.dta"
}
save "/mnt/ide0/home/kotovova/stata/Synthesis2010/control_treatment_UStype_all_1980.dta", replace


* REGRESSIONS
*use control_treatment_UStype_all_1980_subsample.dta
use "/mnt/ide0/home/kotovova/stata/Synthesis2010/control_treatment_UStype_all_1980.dta"
/*sort pid year
by pid: egen int TG3_mena = total(TG3_men)
by pid: egen int TG4_mena = total(TG4_men)
by pid: egen int TG5_mena = total(TG5_men)
by pid: egen int TG3_womena = total(TG3_women)
by pid: egen int TG4_womena = total(TG4_women)
by pid: egen int TG5_womena = total(TG5_women)
by pid: egen int CG3_mena = total(CG3_men)
by pid: egen int CG4_mena = total(CG4_men)
by pid: egen int CG5_mena = total(CG5_men)
by pid: egen int CG3_womena = total(CG3_women)
by pid: egen int CG4_womena = total(CG4_women)
by pid: egen int CG5_womena = total(CG5_women)
compress
*/

gen annual_income = income/30*btag
gen annual_income_coded = income_coded/30*btag 

sort pid year
by pid year: egen total_annual_income = total(annual_income)
by pid year: egen total_annual_income_coded = total(annual_income_coded)

replace CG3_men = 0 if CG3_men~=1
replace CG4_men = 0 if CG4_men~=1
replace CG5_men = 0 if CG5_men~=1
replace CG3_women = 0 if CG3_women~=1
replace CG4_women = 0 if CG4_women~=1
replace CG5_women = 0 if CG5_women~=1

gen byte BC = 1 if type =="UNA"
gen age2 = age^2
gen age3 = age^3
gen age4 = age^4

save "/mnt/ide0/home/kotovova/stata/Synthesis2010/control_treatment_UStype_all_1980.dta", replace
*save control_treatment_UStype_all_1980_subsample_x1.dta, replace

*/

forval ii=5/5{
	use "/mnt/ide0/home/kotovova/stata/Synthesis2010/control_treatment_UStype_all_1980.dta", clear
	keep if TG`ii'_men==1 | CG`ii'_men==1
	by pid year: gen index = _n
	keep if index ==1
	drop index
	sort pid year
	xtset pid year
	xi: reg total_annual_income_coded age age2 age3 age4 BC i.year*CG`ii'_men
	xi: reg total_annual_income age age2 age3 age4 BC i.year*CG`ii'_men
	xi: xtreg total_annual_income_coded age age2 age3 age4 BC i.year*CG`ii'_men, fe
	xi: xtreg total_annual_income_coded age age2 age3 age4 BC i.year*CG`ii'_men, fe
	
	xi: reg total_annual_income_coded age age2 age3 age4 i.year*CG`ii'_men if BC==1
	xi: reg total_annual_income age age2 age3 age4 i.year*CG`ii'_men if BC==1
	xi: xtreg total_annual_income_coded age age2 age3 age4 i.year*CG`ii'_men if BC==1, fe
	xi: xtreg total_annual_income_coded age age2 age3 age4 i.year*CG`ii'_men if BC==1, fe

	xi: reg total_annual_income_coded age age2 age3 age4 i.year*CG`ii'_men if BC~=1
	xi: reg total_annual_income age age2 age3 age4 i.year*CG`ii'_men if BC~=1
	xi: xtreg total_annual_income_coded age age2 age3 age4 i.year*CG`ii'_men if BC~=1, fe
	xi: xtreg total_annual_income_coded age age2 age3 age4 i.year*CG`ii'_men if BC~=1, fe

	clear
	use "/mnt/ide0/home/kotovova/stata/Synthesis2010/control_treatment_UStype_all_1980.dta", clear
	keep if TG`ii'_women==1 | CG`ii'_women==1
	by pid year: gen index = _n
	keep if index ==1
	drop index
	sort pid year
	xtset pid year
	*xi: regress total_annual_income_coded age age2 age3 age4 i.year*CG`ii'_women
	*xi: regress total_annual_income age age2 age3 age4 i.year*CG`ii'_women	
	
	xi: reg total_annual_income_coded age age2 age3 age4 BC i.year*CG`ii'_women
	xi: reg total_annual_income age age2 age3 age4 BC i.year*CG`ii'_women
	xi: xtreg total_annual_income_coded age age2 age3 age4 BC i.year*CG`ii'_women, fe
	xi: xtreg total_annual_income_coded age age2 age3 age4 BC i.year*CG`ii'_women, fe
	
	xi: reg total_annual_income_coded age age2 age3 age4 i.year*CG`ii'_women if BC==1
	xi: reg total_annual_income age age2 age3 age4 i.year*CG`ii'_women if BC==1
	xi: xtreg total_annual_income_coded age age2 age3 age4 i.year*CG`ii'_women if BC==1, fe
	xi: xtreg total_annual_income_coded age age2 age3 age4 i.year*CG`ii'_women if BC==1, fe

	xi: reg total_annual_income_coded age age2 age3 age4 i.year*CG`ii'_women if BC~=1
	xi: reg total_annual_income age age2 age3 age4 i.year*CG`ii'_women if BC~=1
	xi: xtreg total_annual_income_coded age age2 age3 age4 i.year*CG`ii'_women if BC~=1, fe
	xi: xtreg total_annual_income_coded age age2 age3 age4 i.year*CG`ii'_women if BC~=1, fe

}
