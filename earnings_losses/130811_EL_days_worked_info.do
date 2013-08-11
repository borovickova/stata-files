* ADD INFO TO THE REGRESSION FILES
* ADD DAYS WORKED AND AVERAGE DAILY WAGE IN A GIVEN YEAR

local filepath "/scratch/kb103/stata/earnings_losses"

* GENERATE AVERAGE DAILY WAGE AND NUMBER OF DAYS WORKED
forval yy = 1976/2004{
	
	* TREATMENT AND CONTROL IN A GIVEN DISPLACEMENT YEAR
	use "`filepath'/EL_ind_year`yy'.dta"
	drop if income==.
	gen daily_wage = income/30/(cpi/100)
	gen daily_wage_coded = income_coded/30/(cpi/100)

	sort pid year
	by pid year: gen int index = _n
	by pid year: egen daily_wage_mean = mean(daily_wage)
	by pid year: egen daily_wage_mean_coded = mean(daily_wage_coded)
	by pid year: egen annual_days_worked = total(btag)
	keep if index == 1
	drop index
	keep year pid daily_wage_mean daily_wage_mean_coded annual_days_worked
	save "`filepath'/EL_daily_wage`yy'.dta", replace
	
	* TREATMENT DAVIS MEASURE
	
	use "`filepath'/EL_Davis_ind_year`yy'.dta", clear
	drop if income==.
	gen daily_wage = income/30/(cpi/100)
	gen daily_wage_coded = income_coded/30/(cpi/100)

	sort pid year
	by pid year: gen int index = _n
	by pid year: egen daily_wage_mean = mean(daily_wage)
	by pid year: egen daily_wage_mean_coded = mean(daily_wage_coded)
	by pid year: egen annual_days_worked = total(btag)
	keep if index == 1
	drop index
	keep year pid daily_wage_mean daily_wage_mean_coded annual_days_worked

	save "`filepath'/EL_Davis_daily_wage`yy'.dta", replace		
}

