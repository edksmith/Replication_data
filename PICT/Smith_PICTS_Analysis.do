clear all
*Set CD for analyses



//How prevalent are Extremist Conspiracy beliefs in the US?
local irt q vote
loc vote_lab "{bf:A)}"
loc q_lab "{bf:B)}"

foreach x of local irt {
use "US_Summer_2021_recoded.dta",clear
kict ls `x'_total, ///
estimator(linear) condition(`x'_group) level(80) ///
nnonkey(5) auxiliary(`x'_dir) monotony(positive) 
mat delta_tab=r(table)
est sto `x'_delta
matrix `x'_dz = J(3,2,.)
matrix rownames `x'_dz = b ll ul
matrix colnames `x'_dz = delta zeta
local i 0 
foreach t in 1 2 {
mat kb_`t' = el(delta_tab,1,`t')
mat kll_`t' = el(delta_tab,5,`t')	
mat kul_`t' = el(delta_tab,6,`t')          
local ++ i
matrix `x'_dz[1,`i'] = kb_`t' \ kll_`t' \ kul_`t'
test _b[DeltaA0:_cons]=0
}
putexcel set graphs/data_backends/item_list, modify sheet(`x'_dz_dir) 
	foreach n in 1 2  {
	putexcel A`n'=`n'
	putexcel B`n'=`x'_dz[1,`n']
	putexcel C`n'=`x'_dz[2,`n']
	putexcel D`n'=`x'_dz[3,`n']
	}
qui sum `x'_dir
local `x'_mean=r(mean)	
local `x'_sd=r(sd)/sqrt(800)
local `x'_lowci=``x'_mean'-1.96*``x'_sd'
local `x'_highci=``x'_mean'+1.96*``x'_sd'
putexcel set graphs/data_backends/item_list, modify sheet(`x'_dz_dir) 
	putexcel A3=3
	putexcel B3=``x'_mean'
	putexcel C3=``x'_lowci'
	putexcel D3=``x'_highci'
coefplot (matrix(`x'_dz), ci((2 3))), ///
	byopts(row(1)) ///
	title(`: variable label `x'_dir', s(medium)) ///
	xtitle("Estimated Proportion", s(small)) ///
	xlab(0(0.1)0.4) ///
	ylab(0 " " 1 "Experimental Item {&delta}" ///
	2 "Direct Item {&zeta}" 3 " ") ///
	name(`x'_list, replace) nodraw
local title "`: variable label `x'_dir'"
import excel "graphs/data_backends/item_list.xlsx", sheet("`x'_dz_dir") clear
save "graphs/data_backends/`x'_dz_dir.dta", replace
local overline = uchar(773)
twoway ///
	bar B A if A==1, bcolor(forest_green) barwidt(0.8) || ///
	rcap D C A if A==1, lc(gs6) || ///
	bar B A if A==2, bcolor(maroon) barwidt(0.8)  || ///
	rcap D C A if A==2, lc(gs6) || ///
	bar B A if A==3, bcolor(sand) barwidt(0.8) || ///
	rcap D C A if A==3, lc(gs6)||, ///	
	title(`title', s(medium)) ///
	ytitle("Estimated Proportion", s(small)) ///
	xtitle("") ///
	ylab(0(0.1)0.4, format(%2.1f)) ///
	xlab(0 " " 1 `""Experimental" "Item ({&delta})""' ///
	2 `""Direct" "Item ({&zeta})""' ///
	3 `""Direct" "Item (y`overline')""' 4 " ", glc(white)) ///
	note("``x'_lab'", pos(10) ring(12) size(vsmall)) ///
	legend(off) name(`x'_list_full, replace) nodraw
}
gr combine ///
	vote_list_full q_list_full, ///
	name(item_list_full, replace)	

gr save "final_figs/item_list_full.gph", replace
gr export "final_figs/item_list_full.png", ///
	as(png) name("item_list_full") replace	

gr export "final_figs/item_list_full.pdf", ///
	as(pdf) name("item_list_full") replace	
	
//Misreporting
use "US_Summer_2021_recoded.dta",clear	
local ivlist ///
	party_id_lr neg_part expressive ///
	media_oan media_fnc ///
	female ///
	age educ income ///
	white ///
	rural south 

local exps q vote

*Loops to set up matrices
local varnum=0
foreach var in `ivlist' {
local varnum=`varnum'+1
}
local kvarlow=`varnum'+2
local kvarhigh=`varnum'+`varnum'+1

local dvarlow=1
local dvarhigh=`varnum'

foreach x of local exps {
matrix `x'_k = J(3,`varnum',.)
matrix rownames `x'_k = b ll ul
matrix colnames `x'_k = `ivlist'
}

foreach x of local exps {
matrix `x'_d = J(3,`varnum',.)
matrix rownames `x'_d = b ll ul
matrix colnames `x'_d = `ivlist'
}

*Loops to calculate and save Eady-Tsai estimates
foreach x of local exps {
kict ml `x'_total ///
	`ivlist', ///
estimator(tsaieady) condition(`x'_group) level(80) ///
nnonkey(5) auxiliary(`x'_dir) monotony(positive) ///
constraints(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18) iter(1000) dif nolog
mat kap_tab=r(table)
local i 0  
foreach z of numlist `dvarlow'/`dvarhigh' {
mat db_`z' = el(kap_tab,1,`z')
mat dll_`z' = el(kap_tab,5,`z')	
mat dul_`z' = el(kap_tab,6,`z')          
local ++ i
matrix `x'_d[1,`i'] = db_`z' \ dll_`z' \ dul_`z'
}
local i 0 
foreach z of numlist `kvarlow'/`kvarhigh' {
mat kb_`z' = el(kap_tab,1,`z')
mat kll_`z' = el(kap_tab,5,`z')	
mat kul_`z' = el(kap_tab,6,`z')          
local ++ i
matrix `x'_k[1,`i'] = kb_`z' \ kll_`z' \ kul_`z'
}

postsim, saving(graphs/data_backends/estb_sim_`x', replace) reps(10000):kict ml `x'_total ///
	`ivlist', ///
estimator(tsaieady) condition(`x'_group) ///
nnonkey(5) auxiliary(`x'_dir) monotony(positive) ///
constraints(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18) iter(1000) dif nolog

coefplot (matrix(`x'_d), ci((2 3)) ///
	mc(forest_green) ciopts(lc(forest_green))) ///
	(matrix(`x'_k), ci((2 3)) ///
	mc(edkblue) ciopts(lc(edkblue))), ///
	title(`: variable label `x'_dir') ///
	xline(0, lc(gs2)) ///
	xlab(-4(1)3, format(%1.0f)) ///
	xtitle("Log-odds Ratio ({it:e{sup:b}})", s(small)) ///
	legend(rows(1) pos(6) ///
	order(1 "Experimental Item ({&delta})" ///
	3 "Misreporting ({&kappa}{subscript:0})")) ///
	note("``x'_lab'", pos(10) ring(12) size(vsmall)) ///
	name(`x'_over,replace) nodraw
}

grc1leg  ///
	vote_over q_over, ///
	name(item_over, replace)
	
gr save "final_figs/item_over.gph", replace
gr export "final_figs/item_over.png", ///
	as(png) name("item_over") replace

//Calculate Simulated Probabilities for Delta	
use "US_Summer_2021_recoded.dta",clear
local exps q vote
local ivlist ///
	party_id_lr neg_part expressive ///
	media_oan media_fnc ///
	female ///
	age educ income ///
	white ///
	rural south 
	
foreach e of local exps{
foreach c of local ivlist {
	sum `c' if `e'_dir==0|`e'_dir==1
	local mean_`c'_`e'=r(mean)
}
}

local vote_title "2020 Election was Stolen"
local q_title "QAnon Support"

*Party Affiliation
preserve
foreach e of local exps {
use "graphs/data_backends/estb_sim_`e'.dta", clear
foreach n of numlist 1/7{ 
gen d_par_`e'_`n' = invlogit( ///
	Delta_b_party_id_lr*`n' ///
	+ Delta_b_neg_part*`mean_neg_part_`e'' ///
	+ Delta_b_expressive*`mean_expressive_`e'' ///
	+ Delta_b_media_oan*`mean_media_oan_`e'' ///
	+ Delta_b_media_fnc*`mean_media_fnc_`e'' ///
	+ Delta_b_female*`mean_female_`e'' ///
	+ Delta_b_age*`mean_age_`e'' ///
	+ Delta_b_educ*`mean_educ_`e'' ///
	+ Delta_b_income*`mean_income_`e'' ///
	+ Delta_b_white*`mean_white_`e'' ///
	+ Delta_b_rural*`mean_rural_`e'' ///
	+ Delta_b_south*`mean_south_`e'' ///
	+ Delta_b_cons)
	qui sum d_par_`e'_`n', d
	putexcel set graphs/data_backends/sim_pp, modify sheet(d_par_`e') 
	putexcel A`n'=`n'
	putexcel B`n'=`r(mean)'
	putexcel C`n'=`r(p5)'
	putexcel D`n'=`r(p95)'
	}
	import excel "graphs/data_backends/sim_pp.xlsx", sheet("d_par_`e'") clear
	foreach abc in A B C D {
		rename `abc' `abc'_d_par_`e'	
	}
	save "graphs/data_backends/d_par_`e'.dta", replace
	twoway (connected B A, lc(forest_green) lp(solid) m(none)) ///
	(line C A, lc(forest_green%30) lp(dash)) ///
	(line D A, lc(forest_green%30) lp(dash)), ///
	title(" ") ///
	ytitle("Predicted Probability") ///
	xtitle("Party Affiliation") ///
	xlab(1 `""Strong" "Democrat""' /// 
	2 " " 3" " ///
	4 "Independent" ///
	5 " " 6 " " ///
	7 `""Strong" "GOP""', glc(white)) ///
	ylab(, glc(white)) ///
	legend(off) nodraw ///
	name(d_par_`e', replace)
	}
restore

*Expressive Partisanship
preserve
foreach e of local exps {
use "graphs/data_backends/estb_sim_`e'.dta", clear
foreach n of numlist 1/5{
	if invlogit( ///
	Delta_b_expressive*`n' ///
	+ Delta_b_party_id_lr*`mean_party_id_lr_`e'' ///
	+ Delta_b_neg_part*`mean_neg_part_`e'' ///
	+ Delta_b_media_oan*`mean_media_oan_`e'' ///
	+ Delta_b_media_fnc*`mean_media_fnc_`e'' ///
	+ Delta_b_female*`mean_female_`e'' ///
	+ Delta_b_age*`mean_age_`e'' ///
	+ Delta_b_educ*`mean_educ_`e'' ///
	+ Delta_b_income*`mean_income_`e'' ///
	+ Delta_b_white*`mean_white_`e'' ///
	+ Delta_b_rural*`mean_rural_`e'' ///
	+ Delta_b_south*`mean_south_`e'' ///
	+ Delta_b_cons)>0	{
	gen d_expressive_`e'_`n' = invlogit( ///
	Delta_b_expressive*`n' ///
	+ Delta_b_party_id_lr*`mean_party_id_lr_`e'' ///
	+ Delta_b_neg_part*`mean_neg_part_`e'' ///
	+ Delta_b_media_oan*`mean_media_oan_`e'' ///
	+ Delta_b_media_fnc*`mean_media_fnc_`e'' ///
	+ Delta_b_female*`mean_female_`e'' ///
	+ Delta_b_age*`mean_age_`e'' ///
	+ Delta_b_educ*`mean_educ_`e'' ///
	+ Delta_b_income*`mean_income_`e'' ///
	+ Delta_b_white*`mean_white_`e'' ///
	+ Delta_b_rural*`mean_rural_`e'' ///
	+ Delta_b_south*`mean_south_`e'' ///
	+ Delta_b_cons)
	qui sum d_expressive_`e'_`n', d
	putexcel set graphs/data_backends/sim_pp, modify sheet(d_expressive_`e') 
	putexcel A`n'=`n'
	putexcel B`n'=`r(mean)'
	putexcel C`n'=`r(p5)'
	putexcel D`n'=`r(p95)'
	}
	else {
	gen d_expressive_`e'_`n' = 0
	}
	sum d_expressive_`e'_`n', d
	est sto d_expressive_`e'_`n'
}
	import excel "graphs/data_backends/sim_pp.xlsx", sheet("d_expressive_`e'") clear
	foreach abc in A B C D {
	rename `abc' `abc'_d_expressive_`e'	
	}
	save "graphs/data_backends/d_expressive_`e'.dta", replace
	twoway (connected B A, lc(forest_green) lp(solid) m(none)) ///
	(line C A, lc(forest_green%30) lp(dash)) ///
	(line D A, lc(forest_green%30) lp(dash)), ///
	title(" ") ///
	ytitle(" ") ///
	xtitle("Expressive") ///
	xlab(1 "Low" /// 
	2 " " 3 "Moderate" ///
	4 " " ///
	5 "High", glc(white)) ///
	ylab(, glc(white)) ///
	legend(off) nodraw  ///
	name(d_expressive_`e', replace)
}	
restore	
	
*Negative partisanship	
preserve
foreach e of local exps {
use "graphs/data_backends/estb_sim_`e'.dta", clear
foreach n of numlist 1/5{
	if invlogit( ///
	Delta_b_neg_part*`n' ///
	+ Delta_b_party_id_lr*`mean_party_id_lr_`e'' ///
	+ Delta_b_expressive*`mean_expressive_`e'' ///
	+ Delta_b_media_oan*`mean_media_oan_`e'' ///
	+ Delta_b_media_fnc*`mean_media_fnc_`e'' ///
	+ Delta_b_female*`mean_female_`e'' ///
	+ Delta_b_age*`mean_age_`e'' ///
	+ Delta_b_educ*`mean_educ_`e'' ///
	+ Delta_b_income*`mean_income_`e'' ///
	+ Delta_b_white*`mean_white_`e'' ///
	+ Delta_b_rural*`mean_rural_`e'' ///
	+ Delta_b_south*`mean_south_`e'' ///
	+ Delta_b_cons)>0	{
	gen d_neg_part_`e'_`n' = invlogit( ///
	Delta_b_neg_part*`n' ///
	+ Delta_b_party_id_lr*`mean_party_id_lr_`e'' ///
	+ Delta_b_expressive*`mean_expressive_`e'' ///
	+ Delta_b_media_oan*`mean_media_oan_`e'' ///
	+ Delta_b_media_fnc*`mean_media_fnc_`e'' ///
	+ Delta_b_female*`mean_female_`e'' ///
	+ Delta_b_age*`mean_age_`e'' ///
	+ Delta_b_educ*`mean_educ_`e'' ///
	+ Delta_b_income*`mean_income_`e'' ///
	+ Delta_b_white*`mean_white_`e'' ///
	+ Delta_b_rural*`mean_rural_`e'' ///
	+ Delta_b_south*`mean_south_`e'' ///
	+ Delta_b_cons)
	qui sum d_neg_part_`e'_`n', d
	putexcel set graphs/data_backends/sim_pp, modify sheet(d_neg_part_`e') 
	putexcel A`n'=`n'
	putexcel B`n'=`r(mean)'
	putexcel C`n'=`r(p5)'
	putexcel D`n'=`r(p95)'
	}
	else {
	gen d_neg_part_`e'_`n' = 0
	}
	sum d_neg_part_`e'_`n', d
	est sto d_neg_part_`e'_`n'
}
	import excel "graphs/data_backends/sim_pp.xlsx", sheet("d_neg_part_`e'") clear
	foreach abc in A B C D {
	rename `abc' `abc'_d_neg_part_`e'	
	}
	save "graphs/data_backends/d_neg_part_`e'.dta", replace
	twoway (connected B A, lc(forest_green) lp(solid) m(none)) ///
	(line C A, lc(forest_green%30) lp(dash)) ///
	(line D A, lc(forest_green%30) lp(dash)), ///
	title(" ") ///
	ytitle(" ") ///
	xtitle("Negative Partisanship") ///
	xlab(1 "Low" /// 
	2 " " 3 "Moderate" ///
	4 " " ///
	5 "High", glc(white)) ///
	ylab(, glc(white)) ///
	legend(off) nodraw  ///
	name(d_neg_part_`e', replace)
}	
restore	

*Female	
preserve
foreach e of local exps {
use "graphs/data_backends/estb_sim_`e'.dta", clear
foreach n of numlist 1/2{
	if invlogit( ///
	Delta_b_female*`n' ///
	+ Delta_b_party_id_lr*`mean_party_id_lr_`e'' ///
	+ Delta_b_expressive*`mean_expressive_`e'' ///
	+ Delta_b_neg_part*`mean_neg_part_`e'' ///
	+ Delta_b_media_oan*`mean_media_oan_`e'' ///
	+ Delta_b_media_fnc*`mean_media_fnc_`e'' ///
	+ Delta_b_age*`mean_age_`e'' ///
	+ Delta_b_educ*`mean_educ_`e'' ///
	+ Delta_b_income*`mean_income_`e'' ///
	+ Delta_b_white*`mean_white_`e'' ///
	+ Delta_b_rural*`mean_rural_`e'' ///
	+ Delta_b_south*`mean_south_`e'' ///
	+ Delta_b_cons)>0	{
	gen d_female_`e'_`n' = invlogit( ///
	Delta_b_female*`n' ///
	+ Delta_b_party_id_lr*`mean_party_id_lr_`e'' ///
	+ Delta_b_expressive*`mean_expressive_`e'' ///
	+ Delta_b_neg_part*`mean_neg_part_`e'' ///
	+ Delta_b_media_oan*`mean_media_oan_`e'' ///
	+ Delta_b_media_fnc*`mean_media_fnc_`e'' ///
	+ Delta_b_age*`mean_age_`e'' ///
	+ Delta_b_educ*`mean_educ_`e'' ///
	+ Delta_b_income*`mean_income_`e'' ///
	+ Delta_b_white*`mean_white_`e'' ///
	+ Delta_b_rural*`mean_rural_`e'' ///
	+ Delta_b_south*`mean_south_`e'' ///
	+ Delta_b_cons)
	qui sum d_female_`e'_`n', d
	putexcel set graphs/data_backends/sim_pp, modify sheet(d_female_`e') 
	putexcel A`n'=`n'
	putexcel B`n'=`r(mean)'
	putexcel C`n'=`r(p5)'
	putexcel D`n'=`r(p95)'
	}
	else {
	gen d_female_`e'_`n' = 0
	}
	sum d_female_`e'_`n', d
	est sto d_female_`e'_`n'
}
	import excel "graphs/data_backends/sim_pp.xlsx", sheet("d_female_`e'") clear
	foreach abc in A B C D {
	rename `abc' `abc'_d_female_`e'	
	}
	save "graphs/data_backends/d_female_`e'.dta", replace
	twoway (connected B A, lc(forest_green) lp(solid) m(none)) ///
	(line C A, lc(forest_green%30) lp(dash)) ///
	(line D A, lc(forest_green%30) lp(dash)), ///
	title(" ") ///
	ytitle(" ") ///
	xtitle("Gender Identification") ///
	xlab(1 "Male" 2 "Female", glc(white)) ///
	ylab(, glc(white)) ///
	legend(off) nodraw ///
	name(d_female_`e', replace)
}	
restore	

*OANN	
preserve
foreach e of local exps {
use "graphs/data_backends/estb_sim_`e'.dta", clear
foreach n of numlist 1/5{
	if invlogit( ///
	Delta_b_media_oan*`n' ///
	+ Delta_b_party_id_lr*`mean_party_id_lr_`e'' ///
	+ Delta_b_expressive*`mean_expressive_`e'' ///
	+ Delta_b_neg_part*`mean_neg_part_`e'' ///
	+ Delta_b_media_fnc*`mean_media_fnc_`e'' ///
	+ Delta_b_female*`mean_female_`e'' ///
	+ Delta_b_age*`mean_age_`e'' ///
	+ Delta_b_educ*`mean_educ_`e'' ///
	+ Delta_b_income*`mean_income_`e'' ///
	+ Delta_b_white*`mean_white_`e'' ///
	+ Delta_b_rural*`mean_rural_`e'' ///
	+ Delta_b_south*`mean_south_`e'' ///
	+ Delta_b_cons)>0	{
	gen d_media_oan_`e'_`n' = invlogit( ///
	Delta_b_media_oan*`n' ///
	+ Delta_b_party_id_lr*`mean_party_id_lr_`e'' ///
	+ Delta_b_expressive*`mean_expressive_`e'' ///
	+ Delta_b_neg_part*`mean_neg_part_`e'' ///
	+ Delta_b_media_fnc*`mean_media_fnc_`e'' ///
	+ Delta_b_female*`mean_female_`e'' ///
	+ Delta_b_age*`mean_age_`e'' ///
	+ Delta_b_educ*`mean_educ_`e'' ///
	+ Delta_b_income*`mean_income_`e'' ///
	+ Delta_b_white*`mean_white_`e'' ///
	+ Delta_b_rural*`mean_rural_`e'' ///
	+ Delta_b_south*`mean_south_`e'' ///
	+ Delta_b_cons)
	qui sum d_media_oan_`e'_`n', d
	putexcel set graphs/data_backends/sim_pp, modify sheet(d_media_oan_`e') 
	putexcel A`n'=`n'
	putexcel B`n'=`r(mean)'
	putexcel C`n'=`r(p5)'
	putexcel D`n'=`r(p95)'
	}
	else {
	gen d_media_oan_`e'_`n' = 0
	}
	sum d_media_oan_`e'_`n', d
	est sto d_media_oan_`e'_`n'
}
	import excel "graphs/data_backends/sim_pp.xlsx", sheet("d_media_oan_`e'") clear
	foreach abc in A B C D {
	rename `abc' `abc'_d_media_oan_`e'	
	}
	save "graphs/data_backends/d_media_oan_`e'.dta", replace
	twoway (connected B A, lc(forest_green) lp(solid) m(none)) ///
	(line C A, lc(forest_green%30) lp(dash)) ///
	(line D A, lc(forest_green%30) lp(dash)), ///
	title(" ") ///
	ytitle(" ") ///
	xtitle("OANN Viewership") ///
	xlab(1 "Never" /// 
	2 " " 3 "Sometimes" ///
	4 " " ///
	5 "Frequently", glc(white)) ///
	ylab(, glc(white)) ///
	legend(off) nodraw  ///
	name(d_media_oan_`e', replace)
}	
restore	

*Fox News	
preserve
foreach e of local exps {
use "graphs/data_backends/estb_sim_`e'.dta", clear
foreach n of numlist 1/5{
	if invlogit( ///
	Delta_b_media_fnc*`n' ///
	+ Delta_b_party_id_lr*`mean_party_id_lr_`e'' ///
	+ Delta_b_expressive*`mean_expressive_`e'' ///
	+ Delta_b_neg_part*`mean_neg_part_`e'' ///
	+ Delta_b_media_oan*`mean_media_oan_`e'' ///
	+ Delta_b_female*`mean_female_`e'' ///
	+ Delta_b_age*`mean_age_`e'' ///
	+ Delta_b_educ*`mean_educ_`e'' ///
	+ Delta_b_income*`mean_income_`e'' ///
	+ Delta_b_white*`mean_white_`e'' ///
	+ Delta_b_rural*`mean_rural_`e'' ///
	+ Delta_b_south*`mean_south_`e'' ///
	+ Delta_b_cons)>0	{
	gen d_media_fnc_`e'_`n' = invlogit( ///
	Delta_b_media_fnc*`n' ///
	+ Delta_b_party_id_lr*`mean_party_id_lr_`e'' ///
	+ Delta_b_expressive*`mean_expressive_`e'' ///
	+ Delta_b_neg_part*`mean_neg_part_`e'' ///
	+ Delta_b_media_oan*`mean_media_oan_`e'' ///
	+ Delta_b_female*`mean_female_`e'' ///
	+ Delta_b_age*`mean_age_`e'' ///
	+ Delta_b_educ*`mean_educ_`e'' ///
	+ Delta_b_income*`mean_income_`e'' ///
	+ Delta_b_white*`mean_white_`e'' ///
	+ Delta_b_rural*`mean_rural_`e'' ///
	+ Delta_b_south*`mean_south_`e'' ///
	+ Delta_b_cons)
	qui sum d_media_fnc_`e'_`n', d
	putexcel set graphs/data_backends/sim_pp, modify sheet(d_media_fnc_`e') 
	putexcel A`n'=`n'
	putexcel B`n'=`r(mean)'
	putexcel C`n'=`r(p5)'
	putexcel D`n'=`r(p95)'
	}
	else {
	gen d_media_fnc_`e'_`n' = 0
	}
	sum d_media_fnc_`e'_`n', d
	est sto d_media_fnc_`e'_`n'
}
	import excel "graphs/data_backends/sim_pp.xlsx", sheet("d_media_fnc_`e'") clear
	foreach abc in A B C D {
	rename `abc' `abc'_d_media_fnc_`e'	
	}
	save "graphs/data_backends/d_media_fnc_`e'.dta", replace
	twoway (connected B A, lc(forest_green) lp(solid) m(none)) ///
	(line C A, lc(forest_green%30) lp(dash)) ///
	(line D A, lc(forest_green%30) lp(dash)), ///
	title(" ") ///
	ytitle(" ") ///
	xtitle("FNC Viewership") ///
	xlab(1 "Never" /// 
	2 " " 3 "Sometimes" ///
	4 " " ///
	5 "Frequently", glc(white)) ///
	ylab(, glc(white)) ///
	legend(off) nodraw  ///
	name(d_media_fnc_`e', replace)
}	
restore	

//Calculate Direct Predicted Probabilities	
local exps q vote

local ivlist ///
	party_id_lr neg_part expressive ///
	media_oan media_fnc ///
	female ///
	age educ income ///
	white ///
	rural south  
preserve 
foreach e of local exps {
*party affiliation
use "US_Summer_2021_recoded.dta",clear	
logit `e'_dir `ivlist'
est sto log_`e'
margins, at(party_id_lr=(1(1)7))
mat marg=r(table)
foreach n of numlist 1/7{
	putexcel set graphs/data_backends/sim_pp, modify sheet(dir_par_`e') 
	putexcel A`n'=`n'
	putexcel B`n'=marg[1,`n']
	putexcel C`n'=marg[5,`n']
	putexcel D`n'=marg[6,`n']
	}	
import excel "graphs/data_backends/sim_pp.xlsx", sheet("dir_par_`e'") clear
foreach abc in A B C D {
rename `abc' `abc'_dir_par_`e'	
}
save "graphs/data_backends/dir_par_`e'.dta", replace
	twoway (connected B A, lc(sand) lp(solid) m(none)) ///
	(line C A, lc(sand%30) lp(dash)) ///
	(line D A, lc(sand%30) lp(dash)), ///
	title(" ") ///
	ytitle("Predicted Probability") ///
	xtitle("Party Affiliation") ///
	xlab(1 `""Strong" "Democrat""' /// 
	2 " " 3" " ///
	4 "Independent" ///
	5 " " 6 " " ///
	7 `""Strong" "GOP""', glc(white)) ///
	ylab(, glc(white)) ///
	legend(off) nodraw  ///
	name(dir_par_`e', replace)

*negative	
use "US_Summer_2021_recoded.dta",clear	
logit `e'_dir `ivlist'
margins, at(neg_part=(1(1)5))
mat marg=r(table)
foreach n of numlist 1/5{
	putexcel set graphs/data_backends/sim_pp, modify sheet(dir_neg_part_`e') 
	putexcel A`n'=`n'
	putexcel B`n'=marg[1,`n']
	putexcel C`n'=marg[5,`n']
	putexcel D`n'=marg[6,`n']
	}
import excel "graphs/data_backends/sim_pp.xlsx", sheet("dir_neg_part_`e'") clear
foreach abc in A B C D {
rename `abc' `abc'_dir_neg_part_`e'	
}
save "graphs/data_backends/dir_neg_part_`e'.dta", replace
	twoway (connected B A, lc(sand) lp(solid) m(none)) ///
	(line C A, lc(sand%30) lp(dash)) ///
	(line D A, lc(sand%30) lp(dash)), ///
	title(" ") ///
	ytitle(" ") ///
	xtitle("Negative Partisanship") ///
	xlab(1 "Low" /// 
	2 " " 3 "Moderate" ///
	4 " " ///
	5 "High", glc(white)) ///
	ylab(, glc(white)) ///
	legend(off) nodraw  ///
	name(dir_neg_part_`e', replace)	

*expressive
use "US_Summer_2021_recoded.dta",clear	
logit `e'_dir `ivlist'
margins, at(expressive=(1(1)5))
mat marg=r(table)
foreach n of numlist 1/5{
	putexcel set graphs/data_backends/sim_pp, modify sheet(dir_expressive_`e') 
	putexcel A`n'=`n'
	putexcel B`n'=marg[1,`n']
	putexcel C`n'=marg[5,`n']
	putexcel D`n'=marg[6,`n']
	}
import excel "graphs/data_backends/sim_pp.xlsx", sheet("dir_expressive_`e'") clear
foreach abc in A B C D {
rename `abc' `abc'_dir_expressive_`e'	
}
save "graphs/data_backends/dir_expressive_`e'.dta", replace
	twoway (connected B A, lc(sand) lp(solid) m(none)) ///
	(line C A, lc(sand%30) lp(dash)) ///
	(line D A, lc(sand%30) lp(dash)), ///
	title(" ") ///
	ytitle(" ") ///
	xtitle("Expressive Partisanship") ///
	xlab(1 "Low" /// 
	2 " " 3 "Moderate" ///
	4 " " ///
	5 "High", glc(white)) ///
	ylab(, glc(white)) ///
	legend(off) ///
	name(dir_expressive_`e', replace) nodraw

*OAN
use "US_Summer_2021_recoded.dta",clear	
logit `e'_dir `ivlist'
margins, at(media_oan=(1(1)5))
mat marg=r(table)
foreach n of numlist 1/5{
	putexcel set graphs/data_backends/sim_pp, modify sheet(dir_media_oan_`e') 
	putexcel A`n'=`n'
	putexcel B`n'=marg[1,`n']
	putexcel C`n'=marg[5,`n']
	putexcel D`n'=marg[6,`n']
	}
import excel "graphs/data_backends/sim_pp.xlsx", sheet("dir_media_oan_`e'") clear
foreach abc in A B C D {
rename `abc' `abc'_dir_media_oan_`e'	
}
save "graphs/data_backends/dir_media_oan_`e'.dta", replace
	twoway (connected B A, lc(sand) lp(solid) m(none)) ///
	(line C A, lc(sand%30) lp(dash)) ///
	(line D A, lc(sand%30) lp(dash)), ///
	title(" ") ///
	ytitle(" ") ///
	xtitle("OAN Viewership") ///
	xlab(1 "Never" /// 
	2 " " 3 "Sometimes" ///
	4 " " ///
	5 "Frequently", glc(white)) ///
	ylab(, glc(white)) ///
	legend(off) ///
	name(dir_media_oan_`e', replace) nodraw

*FNC
use "US_Summer_2021_recoded.dta",clear	
logit `e'_dir `ivlist'
margins, at(media_fnc=(1(1)5))
mat marg=r(table)
foreach n of numlist 1/5{
	putexcel set graphs/data_backends/sim_pp, modify sheet(dir_media_fnc_`e') 
	putexcel A`n'=`n'
	putexcel B`n'=marg[1,`n']
	putexcel C`n'=marg[5,`n']
	putexcel D`n'=marg[6,`n']
	}
import excel "graphs/data_backends/sim_pp.xlsx", sheet("dir_media_fnc_`e'") clear
foreach abc in A B C D {
rename `abc' `abc'_dir_media_fnc_`e'	
}
save "graphs/data_backends/dir_media_fnc_`e'.dta", replace
	twoway (connected B A, lc(sand) lp(solid) m(none)) ///
	(line C A, lc(sand%30) lp(dash)) ///
	(line D A, lc(sand%30) lp(dash)), ///
	title(" ") ///
	ytitle(" ") ///
	xtitle("FNC Viewership") ///
	xlab(1 "Never" /// 
	2 " " 3 "Sometimes" ///
	4 " " ///
	5 "Frequently", glc(white)) ///
	ylab(, glc(white)) ///
	legend(off) ///
	name(dir_media_fnc_`e', replace) nodraw

*Female
use "US_Summer_2021_recoded.dta",clear	
logit `e'_dir `ivlist'
margins, at(female=(1 2))
mat marg=r(table)
foreach n of numlist 1/2{
	putexcel set graphs/data_backends/sim_pp, modify sheet(dir_female_`e') 
	putexcel A`n'=`n'
	putexcel B`n'=marg[1,`n']
	putexcel C`n'=marg[5,`n']
	putexcel D`n'=marg[6,`n']
	}
import excel "graphs/data_backends/sim_pp.xlsx", sheet("dir_female_`e'") clear
foreach abc in A B C D {
rename `abc' `abc'_dir_female_`e'	
}
save "graphs/data_backends/dir_female_`e'.dta", replace
	twoway (connected B A, lc(sand) lp(solid) m(none)) ///
	(line C A, lc(sand%30) lp(dash)) ///
	(line D A, lc(sand%30) lp(dash)), ///
	title(" ") ///
	ytitle(" ") ///
	xtitle("Gender Identification") ///
	xlab(1 "Male" 2 "Female", glc(white)) ///
	ylab(, glc(white)) ///
	legend(off) ///
	name(dir_female_`e', replace) nodraw
}
restore 


//Combine Delta and Direct Estimates
preserve
local exps q vote
foreach e of local exps {
*Party affiliation
use "graphs/data_backends/dir_par_`e'.dta", clear
append using "graphs/data_backends/d_par_`e'.dta"
local hat = uchar(770)
twoway ///
	(connected B_dir_par_`e' A_dir_par_`e', lc(sand) lp(solid) m(none)) ///
	(line C_dir_par_`e' A_dir_par_`e', lc(sand%30) lp(dash)) ///
	(line D_dir_par_`e' A_dir_par_`e', lc(sand%30) lp(dash)) ///
	(connected B_d_par_`e' A_d_par_`e', lc(forest_green) lp(solid) m(none)) ///
	(line C_d_par_`e' A_d_par_`e', lc(forest_green%30) lp(dash)) ///
	(line D_d_par_`e' A_d_par_`e', lc(forest_green%30) lp(dash)), ///
	title(" ") ///
	ytitle("Predicted Probability") ///
	xtitle("Party Affiliation") ///
	xlab(1 `""Strong" "Democrat""' /// 
	2 " " 3" " ///
	4 "Independent" ///
	5 " " 6 " " ///
	7 `""Strong" "GOP""', glc(white)) ///
	ylab(, glc(white) format(%2.1f)) ///
	legend(order(4 "Experimental Item ({&delta})" 1 "Direct Item (y`hat')") pos(6) row(1)) ///
	name(d_dir_par_`e', replace) nodraw

*Negative
use "graphs/data_backends/dir_neg_part_`e'.dta", clear
append using "graphs/data_backends/d_neg_part_`e'.dta"

twoway ///
	(connected B_dir_neg_part_`e' A_dir_neg_part_`e', lc(sand) lp(solid) m(none)) ///
	(line C_dir_neg_part_`e' A_dir_neg_part_`e', lc(sand%30) lp(dash)) ///
	(line D_dir_neg_part_`e' A_dir_neg_part_`e', lc(sand%30) lp(dash)) ///
	(connected B_d_neg_part_`e' A_d_neg_part_`e', lc(forest_green) lp(solid) m(none)) ///
	(line C_d_neg_part_`e' A_d_neg_part_`e', lc(forest_green%30) lp(dash)) ///
	(line D_d_neg_part_`e' A_d_neg_part_`e', lc(forest_green%30) lp(dash)), ///
	title(" ") ///
	ytitle("") ///
	xtitle("Negative Partisanship") ///
	xlab(1 "Low" /// 
	2 " " 3 "Modeate" ///
	4 " " ///
	5 "High", glc(white)) ///
	ylab(, glc(white) format(%2.1f)) ///
	legend(order(4 "Experimental Item ({&delta})" 1 "Direct Item (y`hat')") pos(6) row(1)) ///
	name(d_dir_neg_part_`e', replace) nodraw

*Expressive
use "graphs/data_backends/dir_expressive_`e'.dta", clear
append using "graphs/data_backends/d_expressive_`e'.dta"

twoway ///
	(connected B_dir_expressive_`e' A_dir_expressive_`e', lc(sand) lp(solid) m(none)) ///
	(line C_dir_expressive_`e' A_dir_expressive_`e', lc(sand%30) lp(dash)) ///
	(line D_dir_expressive_`e' A_dir_expressive_`e', lc(sand%30) lp(dash)) ///
	(connected B_d_expressive_`e' A_d_expressive_`e', lc(forest_green) lp(solid) m(none)) ///
	(line C_d_expressive_`e' A_d_expressive_`e', lc(forest_green%30) lp(dash)) ///
	(line D_d_expressive_`e' A_d_expressive_`e', lc(forest_green%30) lp(dash)), ///
	title(" ") ///
	ytitle("") ///
	xtitle("Expressive Partisanship") ///
	xlab(1 "Low" /// 
	2 " " 3 "Modeate" ///
	4 " " ///
	5 "High", glc(white)) ///
	ylab(, glc(white) format(%2.1f)) ///
	legend(order(4 "Experimental Item ({&delta})" 1 "Direct Item (y`hat')") pos(6) row(1)) ///
	name(d_dir_expressive_`e', replace) nodraw

*Female
use "graphs/data_backends/dir_female_`e'.dta", clear
append using "graphs/data_backends/d_female_`e'.dta"

twoway ///
	(connected B_dir_female_`e' A_dir_female_`e', lc(sand) lp(solid) m(none)) ///
	(line C_dir_female_`e' A_dir_female_`e', lc(sand%30) lp(dash)) ///
	(line D_dir_female_`e' A_dir_female_`e', lc(sand%30) lp(dash)) ///
	(connected B_d_female_`e' A_d_female_`e', lc(forest_green) lp(solid) m(none)) ///
	(line C_d_female_`e' A_d_female_`e', lc(forest_green%30) lp(dash)) ///
	(line D_d_female_`e' A_d_female_`e', lc(forest_green%30) lp(dash)), ///
	title(" ") ///
	ytitle("Predicted Probability") ///
	xtitle("Gender Identification") ///
	xlab(1 "Male" /// 
	2 "Female", glc(white)) ///
	ylab(, glc(white) format(%2.1f)) ///
	legend(order(4 "Experimental Item ({&delta})" ///
	1 "Direct Item (y`hat')") pos(6) row(1)) ///
	name(d_dir_female_`e', replace) nodraw	

*OANN	
use "graphs/data_backends/dir_media_oan_`e'.dta", clear
append using "graphs/data_backends/d_media_oan_`e'.dta"

twoway ///
	(connected B_dir_media_oan_`e' A_dir_media_oan_`e', lc(sand) lp(solid) m(none)) ///
	(line C_dir_media_oan_`e' A_dir_media_oan_`e', lc(sand%30) lp(dash)) ///
	(line D_dir_media_oan_`e' A_dir_media_oan_`e', lc(sand%30) lp(dash)) ///
	(connected B_d_media_oan_`e' A_d_media_oan_`e', lc(forest_green) lp(solid) m(none)) ///
	(line C_d_media_oan_`e' A_d_media_oan_`e', lc(forest_green%30) lp(dash)) ///
	(line D_d_media_oan_`e' A_d_media_oan_`e', lc(forest_green%30) lp(dash)), ///
	title(" ") ///
	ytitle("") ///
	xtitle("OAN Viewership") ///
	xlab(1 "Never" /// 
	2 " " 3 "Sometimes" ///
	4 " " ///
	5 "Frequently", glc(white)) ///
	ylab(, glc(white) format(%2.1f)) ///
	legend(order(4 "Experimental Item ({&delta})" 1 "Direct Item (y`hat')") pos(6) row(1)) ///
	name(d_dir_media_oan_`e', replace) nodraw
	
*FNC	
use "graphs/data_backends/dir_media_fnc_`e'.dta", clear
append using "graphs/data_backends/d_media_fnc_`e'.dta"

twoway ///
	(connected B_dir_media_fnc_`e' A_dir_media_fnc_`e', lc(sand) lp(solid) m(none)) ///
	(line C_dir_media_fnc_`e' A_dir_media_fnc_`e', lc(sand%30) lp(dash)) ///
	(line D_dir_media_fnc_`e' A_dir_media_fnc_`e', lc(sand%30) lp(dash)) ///
	(connected B_d_media_fnc_`e' A_d_media_fnc_`e', lc(forest_green) lp(solid) m(none)) ///
	(line C_d_media_fnc_`e' A_d_media_fnc_`e', lc(forest_green%30) lp(dash)) ///
	(line D_d_media_fnc_`e' A_d_media_fnc_`e', lc(forest_green%30) lp(dash)), ///
	title(" ") ///
	ytitle("") ///
	xtitle("FNC Viewership") ///
	xlab(1 "Never" /// 
	2 " " 3 "Sometimes" ///
	4 " " ///
	5 "Frequently", glc(white)) ///
	ylab(, glc(white) format(%2.1f)) ///
	legend(order(4 "Experimental Item ({&delta})" 1 "Direct Item (y`hat')") pos(6) row(1)) ///
	name(d_dir_media_fnc_`e', replace) nodraw
	}
restore


grc1leg d_dir_par_vote d_dir_neg_part_vote d_dir_expressive_vote ///
	d_dir_female_vote d_dir_media_oan_vote d_dir_media_fnc_vote, ///
	ycomm ///
	title("2020 Election was Stolen") ///
	note("{bf:A)}", pos(10) ring(12) size(vsmall)) ///
	row(2) ///
	name(d_dir_vote,replace)	

grc1leg d_dir_par_q d_dir_neg_part_q d_dir_expressive_q ///
	d_dir_female_q d_dir_media_oan_q d_dir_media_fnc_q, ///
	ycomm ///
	title("QAnon Support") ///
	note("{bf:B)}", pos(10) ring(12) size(vsmall)) ///
	row(2) ///
	name(d_dir_q,replace)
	
grc1leg d_dir_vote d_dir_q, ///
	ycomm row(2) ///
	title("") ///
	ysize(10) xsize(6) ///
	name(d_dir_combined,replace)
graph display, ysize(10) xsize(6)


graph close d_dir_q d_dir_vote
	
gr save "d_dir_combined" "final_figs/d_dir_combined.gph", replace
gr export "final_figs/d_dir_combined.png", as(png) name("d_dir_combined") replace
gr export "final_figs/d_dir_combined.pdf", as(pdf) name("d_dir_combined") replace

/*
*Combine graphs of PNAS Brief Reports Format
gr combine ///
	"final_figs/item_list_full_brief.gph" ///
	"final_figs/d_dir_combined_brief.gph", ///
	name(brief_results, replace)
	
gr save "brief_results" "final_figs/brief_results.gph", replace
gr export "final_figs/brief_results.pdf", as(pdf) name("brief_results") replace
*/

//Interaction of Partisanship
foreach y in q vote {
qui logit `y'_dir ///
	c.(party_id_lr)##c.(neg_part expressive) ///
	media_oan media_fnc ///
	female ///
	age educ income ///
	white ///
	rural south	
foreach x in neg_part expressive {
	qui sum `x', d
	loc `x'_low = r(p10)
	loc `x'_med = r(p50)
	loc `x'_high = r(p90)
qui margins, at( ///
	party_id_lr=(1(1)7) ///
	`x'=(``x'_low' ``x'_med' ``x'_high'))
marginsplot, ///
	ti("`: var label `x''") ///
	yti("") xti("") ///
	plot1opts( ///
		lc(maroon) lp(shortdash) ///
		mc(maroon) ms(triangle_hollow)) ///
	ci1opts( ///
		lc(maroon%30)) ///
	plot2opts( ///
		lc(forest_green) lp(shortdash_dot) ///
		mc(forest_green) ms(circle_hollow)) ///
	ci2opts( ///
		lc(forest_green%30)) ///
	plot3opts( ///
		lc(edkblue) lp(solid) /// 
		mc(edkblue) ms(square_hollow)) ///
	ci3opts( ///
		lc(edkblue%30)) ///
	xlab(1 `""Strong" "Democrat""' /// 
	2 " " 3" " ///
	4 "Independent" ///
	5 " " 6 " " ///
	7 `""Strong" "GOP""', glc(white)) ///
	ylab(, glc(white)) ///
	legend(order( ///
			4 "Low" ///
			5 "Moderate" ///
			6 "High") si(small) ///
		ti("Partisanship", s(small)) ///
		row(1) pos(6)) ///
	name(`y'_`x', replace) nodraw
}
grc1leg ///
	`y'_neg_part ///
	`y'_expressive, ///
	row(1) ///
	ti("`: var label `y'_dir'") ///
	note("``y'_lab'", pos(10) ring(12) size(vsmall)) ///
	name(`y'_dir_int, replace)
gr close `y'_dir_int
}

grc1leg ///
	vote_dir_int q_dir_int, ///
	row(2) ///
	name(partisan_int, replace)
	
gr save "partisan_int" "final_figs/partisan_int.gph", replace
gr export "final_figs/partisan_int.pdf", as(pdf) name("partisan_int") replace

//PICT Attitudes and Pro-social behaviors

use "US_Summer_2021_recoded.dta",clear
pca Qonspire_satan Qonspire_storm Qonspire_patriots, fac(1)
predict drop_q_atts
egen q_atts = std(drop_q_atts)
la var q_atts "QAnon Conspiracy Attitudes"

pca cap_riot_trump cap_riot_peace cap_riot_lwing, fac(1)
predict drop_vote_atts
egen vote_atts = std(drop_vote_atts)
la var vote_atts "January 6th Conspiracy Attitudes"

loc vote_lab "{bf:A)}"
loc q_lab "{bf:B)}"


foreach x in ///
	party_id_lr neg_part expressive ///
	media_oan media_fnc ///
	female ///
	age educ income ///
	white ///
	rural south {
		egen `x'_std=std(`x')
	}

foreach y in ///
		boycott ///
		volunteer charity ///
		vote vax fff {
			rename prosoc_`y' `y'
				egen `y'_std=std(`y')	
		}
	
local ivlist ///
	party_id_lr_std neg_part_std expressive_std ///
	media_oan_std media_fnc_std ///
	female_std ///
	age_std educ_std income_std ///
	white_std ///
	rural_std south_std 


local dvlist ///
		boycott_std ///
		volunteer_std charity_std ///
		vote_std vax_std fff_std
	
foreach y of local dvlist {	
foreach x in q vote {
ologit `y' `x'_atts `ivlist'
est sto olo_`y'_`x'
}
}

foreach x in q vote {
coefplot ///
	(olo_vote_std_`x', ///
		recast(bar)  ///
		col(sand%60))  ///
	(olo_vax_std_`x', ///
		recast(bar)  ///
		col(teal%60))  ///
	(olo_fff_std_`x', ///
		recast(bar)  ///
		col(sienna%60)) ///
	(olo_boycott_std_`x', ///
		recast(bar)  ///
		col(forest_green%60)) ///
	(olo_volunteer_std_`x', ///
		recast(bar)  ///
		col(edkblue%60)) ///
	(olo_charity_std_`x', ///
		recast(bar)  ///
		col(maroon%60))	, ///
	keep(`x'_atts) vert ///
	barw(0.1) ///
	ti("`: var label `x'_atts'") ///
	ciopts(lc(gs3) ///
	recast(rcap)) ///
	yline(0, lc(red)) ///
	ylab(-0.8(0.4)0.8, nogrid format(%2.1f)) ///
	yti(e({&beta})) ///
	b1ti("{bf:Political behaviors                    Pro-social behaviors}", ///
		s(small)) ///
	xlab( ///
	0.63 `""Voting" "Intention""' ///
	0.78 `""COVID-19" "vaccine""' ///
	0.93 `""Environmental" "protest""' ///
	1.08 `""Participate" "in boycott""' ///
	1.23 "Volunteer" ///
	1.38 `""Give to" "charity""', ///
	angle(90)) ///
	leg(off) ///
	note("``x'_lab'", pos(10) ring(12) size(vsmall)) ///
	name(prosoc_`x', replace) nodraw
}

gr combine ///
	prosoc_vote ///
	prosoc_q, ///
	ycomm ///
	name(prosoc_atts, replace)
	
gr save "prosoc_atts" "final_figs/prosoc_atts.gph", replace
gr export "final_figs/prosoc_atts.pdf", as(pdf) name("prosoc_atts") replace
