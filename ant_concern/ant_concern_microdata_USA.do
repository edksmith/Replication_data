*Set CD for analyses
cd "" \\ADD IN YOUR CD HERE
graph set window fontface "Helvetica"
****Tipping Classes***********
local behav ///
	behav_pre_meat ///
	prosoc_ev ///
	prosoc_fff ///
	clim_pol_fftax 
	 
local controls ///
	party_id ///
	i.gndr b6.age b1.racethn b3.region ///
	b2.educ income b1.rural_urb ///
	i.ant_time_scen ///
	i.ant_time_year


local prosoc_fff_ylab 0.3
local prosoc_ev_ylab 0.5
local clim_pol_fftax_ylab 0.4
local behav_pre_meat_ylab 0.7


foreach y of local behav {
use "US_Summer_2021_recoded.dta",replace
la var prosoc_fff "Participate in Environmental Protest"
la var prosoc_ev "Purchase Electric Vehicle"
la var clim_pol_fftax "Support Increased Fossil Fuel Taxes"
la var behav_pre_meat "Reduce Meat Consumption"
local `y'_title "`:variable label `y''"
replace behav_pre_meat=5 if behav_pre_meat==6

qui ologit `y' ///
	c.clim_con##c.clim_ant_con ///
	`controls'
	est sto `y'_int
	qui sum `y'
local max=r(max)	
qui margins, at(clim_con=(1 5) clim_ant_con=(1 5))	///
	pr(out(`max')) post
local class_I_b = r(table)[1,4]
local class_II_b = r(table)[1,3]
local class_III_b = r(table)[1,1]
local class_I_low = r(table)[5,4]
local class_II_low = r(table)[5,3]
local class_III_low = r(table)[5,1]
local class_I_hi = r(table)[6,4]
local class_II_hi = r(table)[6,3]
local class_III_hi = r(table)[6,1]
	putexcel set graphs/data_backends/action_pp, modify sheet(`y') 
	putexcel A1="place"
	putexcel B1="class_I_b"
	putexcel C1="class_I_low"
	putexcel D1="class_I_hi"
	putexcel E1="class_II_b"
	putexcel F1="class_II_low"
	putexcel G1="class_II_hi"
	putexcel H1="class_III_b"
	putexcel I1="class_III_low"
	putexcel J1="class_III_hi"
	putexcel A2=2
	putexcel A3=2
	putexcel A4=1
	putexcel B2=`class_I_b'
	putexcel C2=`class_I_low'
	putexcel D2=`class_I_hi'
	putexcel E3=`class_II_b'
	putexcel F3=`class_II_low'
	putexcel G3=`class_II_hi'
	putexcel H4=`class_III_b'
	putexcel I4=`class_III_low'
	putexcel J4=`class_III_hi'
	
preserve
import excel "graphs/data_backends/action_pp.xlsx", ///
	sheet("`y'") firstrow clear
save "graphs/data_backends/`y'.dta", replace

twoway ///
	(scatter class_I_b place, ///
		yaxis(1) m(Sh) mc(edkblue) ///
		text(`class_I_b' 2.05 "[I]", ///
		place(e) s(small))) ///
	(rcap class_I_low class_I_hi  place, ///
		yaxis(1) lc(edkblue%80)) || ///
	(scatter class_II_b place, ///
		yaxis(1) m(Oh) mc(maroon) ///
		text(`class_II_b' 2.05 "[II]", ///
		place(e) s(small))) ///
	(rcap class_II_low class_II_hi  place, ///
		yaxis(1) lc(maroon%80)) || ///
	(scatter class_III_b place, ///
		yaxis(2) m(Dh) mc(forest_green) ///
		text(`class_III_b' 0.95 "[III]", ///
		place(w) s(small))) ///
	(rcap class_III_low class_III_hi  place, ///
		yaxis(2) lc(forest_green%80)) ||, ///
	title({bf:``y'_title'}, s(small)) ///
	ytitle(" ", s(vsmall) axis(1)) ///
	ytitle("Anticipation of SLR", axis(2) s(small)) ///
	xlabel(0.75 " " 1 "Low" 2 "High" 2.25 " ", glc(white) labs(vsmall)) ///
	ylabel(0 "Low" ``y'_ylab' "High", axis(2) labs(vsmall)) ///
	ylabel(0.0(0.1)``y'_ylab', format(%2.1f)axis(1) gmax labs(vsmall)) ///
	xtitle("Climate Change Concern", s(small)) ///
		legend(order(1 "Class I" 3 "Class II" 5 "Class III") ///
	pos(6) row(1)) ///
	name(`y', replace) nodraw
	addplot `y': pcarrowi `class_II_b' 2.2 `class_I_b' 2.2 ///
		`class_III_b' 1.1 `class_III_b' 1.9, ///
	lp(dash) lc(gs10) mc(gs10) msize(small) ///
		xlabel(0.75 " " 1 "Low" 2 "High" 2.25 " ", glc(white) labs(vsmall)) ///
	ylabel(0 " " `class_II_b' "Low" `class_I_b' ///
		"High" ``y'_ylab' " ", axis(2) labs(vsmall)) ///
	ylabel(0.0(0.1)``y'_ylab', format(%2.1f)axis(1) gmax labs(vsmall)) ///
	legend(order(1 "Tipping Class I" 3 "Tipping Class II" 6 "Tipping Class III") ///
		pos(6) row(1))
	gr close `y'
	restore
		}

	grc1leg `behav', name(tipping_classes, replace)
gr play "graphs/fig7_AtoD.grec"

gr export "figure7_tipping_classes.pdf", ///
	as(pdf) name("tipping_classes") replace

//Ologit interaction tables
esttab behav_pre_meat_int ///
	prosoc_ev_int ///
	prosoc_fff_int ///
	clim_pol_fftax_int ///
	using "tables/ologit_int.tex", ///
	label replace booktabs nobaselevels ///
	b(%3.2f) se(%3.2f) ///
	starlevels(* 0.05 ** 0.01) ///
	drop(cut*) ///
	nonumbers nonotes eqlabels(" " " ") ///
	title(\textbf{Ordered Logistic regression of four ///
	measures of climate actions on the direct and interactive ///
	effects of climate change concern and anticipation of SLR, ///
	controlling for party affiliation, socio-demographics, ///
	and anticipation experimental conditions. ///
	Reporting log(odds) with estimated standard errors in parentheses.\label{tab:ologit_int}})

****TOTAL EFFECTS***********
use "US_Summer_2021_recoded.dta",replace

replace behav_pre_meat=5 if behav_pre_meat==6

foreach x in ///
	clim_con clim_ant_con ///
	behav_pre_meat ///
	prosoc_ev ///
	prosoc_fff ///
	clim_pol_fftax ///
	party_id ///
	ind_eff ///
	trust_soc trust_sci ///
	gndr age racethn region ///
	educ income rural_urb ///
	ant_time_scen ///
	ant_time_year {
		egen `x'_std=std(`x')
	}

local behav_std ///
	behav_pre_meat_std ///
	prosoc_ev_std ///
	prosoc_fff_std ///
	clim_pol_fftax_std 

la var prosoc_fff_std "Participate in Environmental Protest"
la var prosoc_ev_std "Purchase Electric Vehicle"
la var clim_pol_fftax_std "Support Increased Fossil Fuel Taxes"
la var behav_pre_meat_std "Reduce Meat Consumption"	

local iv_std ///
	clim_ant_con_std clim_con_std ///
	party_id_std ///
	ind_eff_std  ///
	trust_soc_std trust_sci_std
	
local controls_std ///
	gndr_std age_std ///
	racethn_std region_std ///
	educ_std income_std rural_urb_std ///
	ant_time_scen_std ///
	ant_time_year_std
	
foreach y of local behav_std {	
	ologit `y' ///
	`iv_std' ///
	`controls_std'
	est sto olo_`y'
	
coefplot ///
	(olo_`y', ///
		keep( ///
		clim_ant_con_std) ///
		recast(bar) ///
		col(forest_green%70) ///
		ciopts(lc(gs3) ///
		recast(rcap)) ///
		ylab(, glc(white))) ///
	(olo_`y', ///
		keep( ///
		clim_con_std) ///
		recast(bar) ///
		col(edkblue%70) ///
		ciopts(lc(gs3) ///
		recast(rcap)) ///
		ylab(, glc(white))) ///
	(olo_`y', ///
		keep( ///
		party_id_std) ///
		recast(bar) ///
		col(sand%70) ///
		ciopts(lc(gs3) ///
		recast(rcap)) ///
		ylab(, glc(white)))	///
	(olo_`y', ///
		keep( ///
		ind_eff_std) ///
		recast(bar) ///
		col(maroon%70) ///
		ciopts(lc(gs3) ///
		recast(rcap)) ///
		ylab(, glc(white))) ///
	(olo_`y', ///
		keep( ///
		trust_soc_std) ///
		recast(bar) ///
		col(teal%70) ///
		ciopts(lc(gs3) ///
		recast(rcap)) ///
		ylab(, glc(white))) ///
	(olo_`y', ///
		keep( ///
		trust_sci_std) ///
		recast(bar) ///
		col(olive%70)  ///
		ciopts(lc(gs3) ///
		recast(rcap)) ///
		ylab(, glc(white)))	, ///
	title(`:variable label `y'') ///
	barwidth(0.7) ///
	xline(0, lc(black) lp(solid)) ///
	xtitle("Standardized Coefficients, e(b)", size(small)) ///
	xlab(-1.0 -0.5 0 0.5 1.0) ///
	ylab(0.5 " " ///
		1 `""Anticipation" "of SLR""' ///
		2 `""Climate Change" "Concern""' ///
		3 `""Perceived" "Efficacy""' ///
		4 `""Party" "Affiliation""' ///
		5 `""Social" "Trust""' ///
		6 `""Scientific" "Trust""' ///
		6.5 " ",  ///
		labs(vsmall) glc(white)) ///
	legend(off) ///
	name(`y', replace) nodraw
}
gr combine `behav_std', ///
	name(total_effect, replace)

gr play "graphs/fig8_AtoD.grec"
	
gr export "figure8_total_effect.pdf", ///
	as(pdf) name("total_effect") replace


//Ologit standardized effects tables
esttab ///
	olo_behav_pre_meat_std ///
	olo_prosoc_ev_std ///
	olo_prosoc_fff_std ///
	olo_clim_pol_fftax_std  ///
	using "tables/ologit_std.tex", ///
	label replace booktabs nobaselevels ///
	b(%3.2f) se(%3.2f) ///
	starlevels(* 0.05 ** 0.01) ///
	drop(cut*) ///
	nonumbers nonotes eqlabels(" " " ") ///
	title(\textbf{Ordered Logistic regression of four ///
	measures of climate actions on the direct ///
	effects of climate change concern, anticipation of SLR, party affiliation, ///
	perceived efficacy, social and scientific trust controlling for  socio-demographics, ///
	and anticipation experimental conditions. ///
	Reporting log(odds) with estimated standard errors in parentheses.\label{tab:ologit_std}})	
