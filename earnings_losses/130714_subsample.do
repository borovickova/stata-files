use "/mnt/ide0/home/kotovova/stata/Synthesis2010/control_treatment_UStype_all_1980.dta"

keep if _n<2000
save "/mnt/ide0/home/kotovova/stata/Synthesis2010/control_treatment_UStype_all_1980_subsample.dta"

