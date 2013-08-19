* REGRESSIONS IN ALL YEARS
* USE THE DEFINITION OF TENURE BASED ON THE DAYS WORKED and SEPARATION IN THAT YEAR

local filepath "/scratch/kb103/stata/earnings_losses"

* CREATE FILES THE REGRESSIONS

forval yy = 1976/2005{

	use "`filepath'/control_treatment_ind_year`yy'.dta"
	keep if CG5_men==1 | CG5_women==1
	keep pid CG5*
	by pid: gen int index = _n
	keep if index==1
	drop index
	saveold "`filepath'/EL_pid_CG5`yy'.dta", replace

	use "`filepath'/control_treatment_ind_year`yy'.dta"
	keep if TG5_men==1 | TG5_women==1
	by pid: gen int index = _n
	keep if index == 1
	drop index
	keep pid TG5*
	saveold "`filepath'/EL_pid_TG5`yy'.dta", replace
	
}

* REGRESSION FILES

forval yy = 1976/2003{	

	* DEAL WITH DUPLICATE OBSERVATIONS - IF A WORKER IS IN MORE THAN ONE TREATMENT/CONTROL GROUP
	local endy = `yy'+2
	local begy = `yy'+1
	use "`filepath'/EL_pid_CG5`yy'.dta"	
	forval yy1 = `yy'/`endy'{
		append using "`filepath'/EL_pid_TG5`yy'.dta"
	}
	keep pid 
	sort pid
	by pid: gen int index = _n
	by pid: egen int maxindex = max(index)
	drop if maxindex>1
	keep if index==1
	keep pid
	save  "`filepath'/EL_`yy'_CTG5tokeep.dta", replace
	
	* CREATE A FILE FOR REGRESSION
	clear
	use "`filepath'/EL_annual_income_year`yy'.dta" 
	keep if CG5_men==1 | CG5_women==1 | TG5_men==1 | TG5_women==1
	forval yy1 = `begy'/`endy'{
		append using "`filepath'/EL_Davis_annual_income_year`yy1'.dta"
	}
	merge m:1 pid using "`filepath'/EL_`yy'_CTG5tokeep.dta"
	keep if _merge==3
	drop _merge
  
	save "`filepath'/regression_annual_income_year_CTG5`yy'.dta" , replace
	
}

***** REGRESSIONS **************************************************

forval yy = 1976/2003{	 	
	use "`filepath'/regression_annual_income_year_CTG5`yy'.dta" , clear
	gen byte treatment =1 if TG5_men ==1 |TG5_women ==1
	
	* GENERATE Dtk dummies
	
	gen int current_year = .
	local maxround = 2007-`yy'
	
	forval kk = -6/`maxround'{
		
		replace current_year = year_mass_layoff +`kk' 
		
		local kx = `kk' + 6
		
		gen byte D_`kx' = 0
		replace D_`kx' = 1 if treatment == 1 & year == current_year
			
	}
	drop current_year
	gen age1 = year - year_mass_layoff + age
	gen age2 = age1^2
	gen age3 = age1^3
	gen age4 = age1^4
	
	sort pid year
	xtset pid year
	save "`filepath'/regression_annual_income_year_CTG5`yy'.dta" , replace	
	
	drop if age1>55
	drop if year==2008
	
	local lastD = `maxround'+6
	
	xi: xtreg real_annual_income_coded i.year age1 age2 age3 age4 D_0 - D_`lastD' if sex==1, fe
	xi: xtreg real_annual_income_coded i.year age1 age2 age3 age4 D_0 - D_`lastD' if sex==2, fe
	
}	

