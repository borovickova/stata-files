* EARNINGS LOSSES OF DISPLACED WORKERS
* CONSIDER ONLY UND AND UNA TYPES
* REGRESSIONS
local path "C:\katka\NYU\projects\earnings losses\stata\130714"

	use "`path'\control_treatment_UStype_all_1980_subsample.dta", clear
	gen annual_income = income/30*btag
	gen annual_income_coded = income_coded/30*btag 
/*
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


	save "C:\katka\NYU\projects\earnings losses\stata\130714\control_treatment_UStype_all_1980_subsample_x1.dta", replace


forval ii=5/5{
	use "C:\katka\NYU\projects\earnings losses\stata\130714\control_treatment_UStype_all_1980_subsample_x1.dta", clear
	*keep if TG`ii'_men==1 | CG`ii'_men==1
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

}
