// set cd to working directory!!!!!
dropbox
cd "Keith and Adam Projects/Conspiracy!/Stata Stuff/replication_materials"
//
use "CSAF_2020.dta", clear

local dv covid_behav
local iv idea_Q covid_cons
local control ///
		COV_con_self ///
		partyid female ///
		_30_49 _50_64 _65more ///
		less_HS Some_college HS Associates Post_Grad ///
		midincome ///
		Black Hispanic Asian Other ///
		Northeast Midwest West ///
		Literally Interpreted Human_error ///
		religiosity 


local vars `dv'	`iv' `control'

***Betas
foreach std of local vars {
	egen `std'_std =std(`std')
	la var `std'_std "`: var label `std''"
}

local iv idea_Q_std covid_cons_std
local control ///
		female_std midincome_std ///
		_30_49_std _50_64_std _65more_std ///
		less_HS_std  HS_std Some_college_std Associates_std Post_Grad_std ///
		Black_std Hispanic_std Asian_std Other_std ///
		Northeast_std Midwest_std West_std ///
		Literally_std Interpreted_std Human_error_std ///
		religiosity_std ///
		partyid_std COV_con_self_std
	
regress covid_behav_std  ///
	`iv' `control' 
est sto covid_behav_std_full

* COVID PUBLIC ATTITUDES

coefplot ///
	covid_behav_std_full, ///
	msymbol(Oh) mcolor(edkblue) ciopts(lc(edkblue)) ///
	drop(_cons) grid(none)	///
	coeflabels( ///
	idea_Q_std = "Conspiratorial Ideation" ///
	covid_cons_std = "COVID Conspiracy" ///
	female_std = "Female" ///
	midincome_std = "Income" ///
	_30_49_std = "30-49" ///
	_50_64_std = "50-64" ///
	_65more_std = "65+" ///
	less_HS_std = "< HS" ///
	HS_std = "HS Degree" ///
	Some_college_std = "Some College" ///
	Associates_std = "Associates" ///
	Post_Grad_std = "Post-Grad" ///
	Black_std = "Black" ///
	Hispanic_std = "Hispanic" ///
	Asian_std = "Asian" ///
	Other_std = "Other Race" ///
	Literally_std = "Literally" ///
	Interpreted_std = "Interpreted" ///
	Human_error_std = "Human Error" ///
	religiosity_std = "Religiosity" ///
	COV_con_self_std = "COVID-19 Risk Perception"  ///
	partyid_std  = "GOP Affilation") ///	
	groups( ///
		idea_Q_std covid_cons_std female_std midincome_std ///
		=" " ///
		_30_49_std _50_64_std _65more_std ///
		= `""{bf:Age}" "{it:ref:18-29}"' ///
		less_HS_std Some_college_std HS_std Associates_std Post_Grad_std ///
		= `""{bf:Education}" "{it:ref:College}"' ///
		midincome_std ///
		Black_std Hispanic_std Asian_std Other_std ///
		= `""{bf:Ethnicity}" "{it:ref:White}"' ///
		Northeast_std Midwest_std West_std ///
		= `""{bf:Region}" "{it:ref:South}"' ///
		Literally_std Interpreted_std Human_error_std religiosity_std ///
		= `""{bf:Religious}" "{bf:Factors}"' ///
		, labs(vsmall) nogap angle(90))  ///
	title("COVID-19 Public Attitudes Scale", s(medium) c(black)) ///
	xtitle("{&beta} Coefficients", s(medsmall)) ///
	ylabel(, gmin gmax ///
	labsize(small) labcolor(black) glcolor(gs14)) /// 
	yline(4.5, lp(dash) lc(gs14)) ///
	yline(7.5, lp(dash) lc(gs14)) ///
	yline(12.5, lp(dash) lc(gs14)) ///
	yline(16.5, lp(dash) lc(gs14)) ///
	yline(19.5, lp(dash) lc(gs14)) ///
	yline(23.5, lp(dash) lc(gs14)) ///
	xline(0, lc(gs3)) ///
	graphregion(color(white) lcolor(white)) ///
	name(COVID_Behaviors, replace)

graph export "graphs/supplementary/Chapman_COVID_Behaviors.pdf", as(pdf) replace
