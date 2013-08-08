local filepath "/scratch/kb103/stata"
use "`filepath'/merger_fid_pid_seg_epi.dta"
keep if lfstatus==1
keep if _n<1000
save "`filepath'/merged_subsample.dta"
