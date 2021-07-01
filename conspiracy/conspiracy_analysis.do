// set cd to working directory!!!!!
dropbox
cd "Keith and Adam Projects/Conspiracy!/Stata Stuff/replication_materials"
//
use "conspiracy_june_2020.dta", clear

****Prelim Tables
//Descriptives
*COVID Models
estpost tabstat mask socdist contact ///
	idea flu china ///
	female age education income scilit_sum ///
	Black Other_Race ///
	South Suburban Rural ///
	Protestant Catholic Other_Religion None bornagn ///	
	scitrust govtrust soctrust ///
	partyid Trump ///
	COVcon_gen covid_unstopp covid_redusprd, s(mean sd) columns(statistics)

esttab . ///
	using "tables/supplementary/covid_desc.tex", ///
	cells("mean(fmt(a2)) sd(fmt(a2))") label replace

*Cliamte Change Models
estpost tabstat fftax subrnw banapp ///
	idea coemiss skptk ///
	female age education income scilit_sum ///
	Black Other_Race ///
	South Suburban Rural ///
	Protestant Catholic Other_Religion None bornagn ///	
	scitrust govtrust soctrust ///
	partyid Trump ///
	CCcon_gen ccindff ccskep_unstopp, s(mean sd) columns(statistics)

esttab . ///
	using "tables/supplementary/clim_desc.tex", ///
	cells("mean(fmt(a2)) sd(fmt(a2))") label replace
	
//Factors
*Conspiratorial Ideation
la var con_apollo "Apollo Moon Landing"
la var con_jfkassn "JFK Assassination"
la var con_us911 "9/11"
la var con_cocacola "Coca-cola formula"
la var con_rosewell "Roswell Aliens"
la var con_a51 "Area 51"
    
factor con_apollo con_jfkassn con_us911 con_cocacola con_rosewell con_a51

esttab using "tables/supplementary/cons_factor.tex", ///
	cells("L[Factor1](t f(%9.3f)) L[Factor2](t) L[Factor3](t) Psi[Uniqueness]") ///
	title("Principal Factor Analysis of Conspiratorial Ideation, Factor Loadings") ///
	nogap noobs nonumber nomtitle label replace
*Scientific Trust
factor trstsci_clmchng trstsci_vaccine trstsci_nclpwr trstsci_evolution

esttab using "tables/supplementary/scitrust_factor.tex", ///
	cells("L[Factor1](t f(%9.3f))  Psi[Uniqueness]") ///
	title("Principal Factor Analysis of Trust in Science, Factor Loadings") ///
	nogap noobs nonumber nomtitle label replace

*Social Trust
factor trust_family trust_neigh trust_newppl trust_frnppl

esttab using "tables/supplementary/soctrust_factor.tex", ///
	cells("L[Factor1](t f(%9.3f)) L[Factor2](t) Psi[Uniqueness]") ///
	title("Principal Factor Analysis of Social Trust, Factor Loadings") ///
	nogap noobs nonumber nomtitle label replace
*Governmental Trust
factor trust_potus trust_congress trust_congress

esttab using "tables/supplementary/govtrust_factor.tex", ///
	cells("L[Factor1](t f(%9.3f)) Psi[Uniqueness]") ///
	title("Principal Factor Analysis of Governmental Trust, Factor Loadings") ///
	nogap noobs nonumber nomtitle label replace	

*********Drivers of Conspiratorial Belief

local dvlist idea china skptk ///

local ivlist ///
female age education income scilit_sum ///
Black Other_Race ///
South Suburban Rural ///
Protestant Catholic Other_Religion None bornagn ///	
scitrust govtrust soctrust ///
partyid Trump

local stdlist `dvlist' `ivlist'
foreach x of local stdlist {
	egen std_`x'=std(`x')
la var std_`x' "`: variable label `x''"
}

foreach y of varlist idea china skptk {
regress std_`y' std_`ivlist'
est sto reg_`y'
}

coefplot ///
	(reg_idea, msymbol(Oh) mcolor(edkblue) ciopts(lc(edkblue))) ///
	(reg_china, msymbol(Dh) mcolor(maroon) ciopts(lc(maroon))) ///
	(reg_skptk, msymbol(Th) mcolor(forest_green) ciopts(lc(forest_green))), ///
	title("Drivers of Conspiratorial Beliefs", s(large) c(black)) ///
	groups( ///
		female age education income scilit_sum ///
		= "{bf:Demos}" ///
		Black Other_Race  ///
		= `""{bf:Ethnicity}" "{it:ref:White}"' ///
		South Suburban Rural /// ///
		= `""{bf:Location}" "{it:ref:Urban}"' ///
		Protestant Catholic Other_Religion None bornagn ///
		= `""{bf:Religion}" "{it:ref:Evangelical}"' ///
		scitrust govtrust soctrust  ///
		= "{bf:Trust}"  ///
		partyid Trump  ///
		= "{bf:Political}"  ///
	, labs(small) nogap angle(90)) ///
	xtitle("{&beta} Coefficients", s(medsmall)) ///
	xline(0,lc(black)) ///
	ylabel(, ///
	labsize(small) labcolor(black) nogrid) /// 
	yline(5.5, lp(dash) lc(gs10)) ///
	yline(6.5, lp(dash) lc(gs10)) ///
	yline(10.5, lp(dash) lc(gs10)) ///
	yline(15.5, lp(dash) lc(gs10)) ///
	yline(18.5, lp(dash) lc(gs10)) ///
	legend(region(lc(white)) ///
	order(2 "Conspiratorial ideation" ///
	4 "COVID-19 originated in a laboratory in China" ///
	6 "Climate change seriousness has been exaggerated") rows(3) pos(6)) ///
	ysize(10) xsize(6) drop(_cons) ///
	name(drivers,replace)
graph export "graphs/final/Conspiracy_Drivers.pdf", ///
	as(pdf) name("drivers") replace

**********COVID*************
***Behavioral Intentions	
foreach y of varlist mask socdist contact {
qui ologit `y' ///	
	idea flu china ///
	female age education income scilit_sum ///
	Black Other_Race ///
	South Suburban Rural ///
	Protestant Catholic Other_Religion None bornagn ///	
	scitrust govtrust soctrust ///
	partyid Trump ///
	COVcon_gen covid_unstopp covid_redusprd ///
	, or
	qui r2o
	estadd scalar r2o=r(r2o)
	est sto `y'_conreg
	foreach x of varlist idea flu china {
	qui sum `x' 
	local `x'_m=r(mean)
	local `x'_p1sd=r(mean)+r(sd)
	local `x'_p2sd=r(mean)+(2*r(sd))
	local `x'_m1sd=r(mean)-r(sd)
	local `x'_m2sd=r(mean)-(2*r(sd))	
		
	est res `y'_conreg
	qui	margins, ///
		at(`x'=(``x'_m2sd' ///
		``x'_m1sd' ///
		``x'_m' ///
		``x'_p1sd' ///
		``x'_p2sd')) ///) ///
		post predict(out(5))
	est sto `y'_m_`x'
}

coefplot ///
	(`y'_m_flu, recast(connected) lcolor(forest_green) mcolor(forest_green) ///
	ciopts(lcolor(forest_green))) ///
	(`y'_m_china, recast(connected) lcolor(maroon) mcolor(maroon) ///
	ciopts(lcolor(maroon))),  //// 
	vertical ///
	title("`: var label `y''", c(black) size(medium)) ///
	ytitle("Pred. Prob.", s(small)) ///
	graphregion(color(white) lcolor(white)) ///
	ylabel(0.15(0.05)0.5, gmin gmax format(%3.2f) ///
	labsize(small) labcolor(black)) ///
		xlab(1 "-2SD" ///
		2 "-1SD" ///
		3 "Mean" ///
		4 "+1SD" ///
		5 "+2SD", labsize(small) angle(45) labcolor(black)) ///
	legend(rows(1) region(style(none)) size(small) pos(6) col(2) ///
	order(2 "COVID is no worse than the flu" ///
	4 "COVID-19 originated in a laboratory in China")) ///
	name(`y'_con, replace) nodraw  offset(0)  scheme(plotplain)
	
coefplot ///
	(`y'_m_idea, recast(connected) lcolor(edkblue) mcolor(edkblue) ///
	ciopts(lcolor(edkblue))), /// 
	vertical ///
	title("`: var label `y''", c(black) size(medium)) ///
	ytitle("Pred. Prob.", s(small)) ///
	xtitle("", s(medium)) ///
	graphregion(color(white) lcolor(white)) ///
	ylabel(0.15(0.05)0.5, gmin gmax format(%3.2f) ///
	labsize(small) labcolor(black)) ///
			xlab(1 "-2SD" ///
		2 "-1SD" ///
		3 "Mean" ///
		4 "+1SD" ///
		5 "+2SD", labsize(small) angle(45) labcolor(black)) ///
	name(`y'_idea, replace) nodraw offset(0)  scheme(plotplain)
	}
	
	
***Make Margins Graphs
grc1leg  ///
		mask_con ///
		socdist_con ///
		contact_con, row(1) ycomm ///
		title("COVID-19 Behavioral Intentions", c(black) size(medium)) ///
		graphregion(color(white) lcolor(white)) ///
		name(Con_C19_Act_Margins, replace) 
		
gr combine ///
		mask_idea ///
		socdist_idea ///
		contact_idea , row(1) ycomm ///
		title("COVID-19 Behavioral Intentions", c(black) size(medium)) ///
		graphregion(color(white) lcolor(white)) ///
		name(Idea_C19_Act_Margins, replace) 

****CLIMATE CHANGE
*Actions	
foreach y of varlist fftax subrnw banapp {
qui ologit `y' ///	
	idea coemiss skptk ///
	female age education income scilit_sum ///
	Black Other_Race ///
	South Suburban Rural ///
	Protestant Catholic Other_Religion None bornagn ///	
	scitrust govtrust soctrust ///
	partyid Trump ///
	CCcon_gen ccindff ccskep_unstopp ///
	, or
	qui r2o
	estadd scalar r2o=r(r2o)
	est sto `y'_conreg
	foreach x of varlist idea coemiss skptk {
	qui sum `x' 
	local `x'_m=r(mean)
	local `x'_p1sd=r(mean)+r(sd)
	local `x'_p2sd=r(mean)+(2*r(sd))
	local `x'_m1sd=r(mean)-r(sd)
	local `x'_m2sd=r(mean)-(2*r(sd))	
		
	est res `y'_conreg
	qui	margins, ///
		at(`x'=(``x'_m2sd' ///
		``x'_m1sd' ///
		``x'_m' ///
		``x'_p1sd' ///
		``x'_p2sd')) ///) ///
		post predict(out(5))
	est sto `y'_m_`x'
}

coefplot ///
	(`y'_m_skptk, recast(connected) lcolor(maroon) mcolor(maroon) ///
	ciopts(lcolor(maroon))) ///
	(`y'_m_coemiss, recast(connected) lcolor(forest_green) mcolor(forest_green) ///
	ciopts(lcolor(forest_green))),  //// 
	vertical ///
	title("`: var label `y''", c(black) size(medium)) ///
	ytitle("Pred. Prob.", s(small)) ///
	graphregion(color(white) lcolor(white)) ///
	ylabel(0(0.05)0.3, gmin gmax format(%3.2f) ///
	labsize(small) labcolor(black)) ///
		xlab(1 "-2SD" ///
		2 "-1SD" ///
		3 "Mean" ///
		4 "+1SD" ///
		5 "+2SD", labsize(small) angle(45) labcolor(black)) ///
	legend(rows(1) region(style(none)) size(small) pos(6) col(2) ///
	order(2 "Seriousness of climate change has been exaggerated" ///
	4 "CO2 has only a marginal impact on climate change")) ///
	name(`y'_skep, replace) nodraw  offset(0)  scheme(plotplain)
	
coefplot ///
	(`y'_m_idea, recast(connected) lcolor(edkblue) mcolor(edkblue) ///
	ciopts(lcolor(edkblue))), /// 
	vertical ///
	title("`: var label `y''", c(black) size(medium)) ///
	ytitle("Pred. Prob.", s(small)) ///
	xtitle("", s(medium)) ///
	graphregion(color(white) lcolor(white)) ///
	ylabel(0(0.05)0.3, gmin gmax format(%3.2f) ///
	labsize(small) labcolor(black)) ///
			xlab(1 "-2SD" ///
		2 "-1SD" ///
		3 "Mean" ///
		4 "+1SD" ///
		5 "+2SD", labsize(small) angle(45) labcolor(black)) ///
	name(`y'_idea, replace) nodraw offset(0)  scheme(plotplain)
	}
	
	
	
grc1leg  ///
		fftax_skep ///
		subrnw_skep ///
		banapp_skep , row(1) ycomm ///
		title("Climate Change Policy Support", c(black) size(medium)) ///
		graphregion(color(white) lcolor(white)) ///
		name(Con_CC_Act_Margins, replace)

gr combine ///
		fftax_idea ///
		subrnw_idea ///
		banapp_idea , row(1) ycomm ///
		title("Climate Change Policy Support", c(black) size(medium)) ///
		graphregion(color(white) lcolor(white)) ///
		name(Idea_CC_Act_Margins, replace)
		
*****Combine and Save
*Conspiracy Theories
gr combine ///
	Con_C19_Act_Margins ///
	Con_CC_Act_Margins, row(2) ///
	graphregion(color(white) lcolor(white)) ///
		name(Conspiracy_Actions, replace)
		
gr play "Cons_actions.grec"		

graph export "graphs/final/Conspiracy_Actions.pdf", ///
	as(pdf) name("Conspiracy_Actions") replace

	
*Conspiracy Thinking

gr combine ///
	Idea_C19_Act_Margins ///
	Idea_CC_Act_Margins, row(2) ///
	graphregion(color(white) lcolor(white)) ///
		name(Thinking_Actions, replace)	

gr play "Cons_actions.grec"	

graph export "graphs/final/Thinking_Actions.pdf", ///
	as(pdf) name("Thinking_Actions") replace

**********Sensitivity Analyses*********
la var china "COVID-19 Chinese Lab"
la var flu "COVID-19 Not Dangerous"
la var COVcon_gen "COVID-19 Risk Perception"
la var covid_unstopp "COVID-19 Fatalism"
la var covid_redusprd "COVID-19 Efficacy"
la var coemiss "CO2 Marginal Impact"
la var skptk "Climate Change Exaggerated"
la var CCcon_gen "Climate Change Risk Perception"
la var ccskep_unstopp "Climate Change Fatalism"
la var ccindff "Climate Change Efficacy"

  
****Regression Table*****
esttab ///
	reg_idea reg_china reg_skptk using  "tables/supplementary/drivers_reg.tex", ///
	b(%8.2f)  se(%8.2f) ///
	star(* 0.05 ** 0.01) ///
	nonum label replace ///
	title("Ordinary Least Squares Regression of Key Predictors on Conspiratorial Ideation, COVID-19 and Climate Change Specific Conspiracy Beliefs") ///
	mtitles("Conspiratorial Ideation" "COVID-19 Chinese Lab" "Climate Change Exaggerated") ///
	drop(_cons) stats(r2 N, label("r2" "N"))

esttab ///
	mask_conreg socdist_conreg contact_conreg using  "tables/supplementary/COVID_reg.tex", ///
	b(%8.2f)  se(%8.2f) ///
	star(* 0.05 ** 0.01) ///
	nonum label replace ///
	title("Ordered Logistic Regression of COVID-19 Collective Actions on Conspiratorial Ideation and COVID-19 Specific Conspiracy Beliefs") ///
	mtitles("Wear Mask" "Social Distancing" "Limit Contact") ///
	drop(cut*) stats(r2o N, label("Lacy r2o" "N"))

esttab ///
	fftax_conreg subrnw_conreg banapp_conreg using "tables/supplementary/CC_reg.tex", ///
	b(%8.2f)  se(%8.2f) ///
	star(* 0.05 ** 0.01) ///
	nonum label replace ///
	title("Ordered Logistic Regression of Climate Change Collective Actions on Conspiratorial Ideation and Climate Change Specific Conspiracy Beliefs") ///
	mtitles("Fossil Fuels Tax" "Subsidize Renewables" "Ban Old Appliances") ///
	drop(cut*) stats(r2o N, label("Lacy r2o" "N"))	

**Direct/Indirect Effects
capture program drop te_direct
program te_direct, eclass
    quietly estat teffects
    mat b = r(direct)
    mat V = r(V_direct)
    local N = e(N)
    ereturn post b V, obs(`N')
    ereturn local cmd te_direct 
end

capture program drop te_indirect
program te_indirect, eclass
    quietly estat teffects
    mat b = r(indirect)
    mat V = r(V_indirect)
    ereturn post b V
    ereturn local cmd te_indirect 
end

capture program drop te_total
program te_total, eclass
    quietly estat teffects
    mat b = r(total)
    mat V = r(V_total)
    ereturn post b V
    ereturn local cmd te_total 
end

foreach x of varlist mask socdist contact {
qui sem (idea -> flu, ) ///	
	(idea -> china, ) ///
	(idea flu china ///
	female age education income scilit_sum ///
	Black Other_Race ///
	South Suburban Rural ///
	Protestant Catholic Other_Religion None bornagn ///	
	scitrust govtrust soctrust ///
	partyid Trump ///
	COVcon_gen covid_unstopp covid_redusprd ->  `x'), standardized nocapslatent
est store main
te_direct
est store direct
est restore main
te_indirect
est store indirect
est restore main
te_total
est store total

esttab direct indirect total using "tables/supplementary/`x'_sem.tex", /// 
	b(%8.2f)  se(%8.2f) ///
	star(* 0.05 ** 0.01) ///
	nonum align(l c c c) label replace ///
	title("Direct and Indirect Effects of Conspiratorial Ideation and COVID-19 Specific Conspiracy Beliefs on `: var label `x''") ///
	mtitles(Direct Indirect Total) ///
	drop(female age education income scilit_sum ///
	Black Other_Race ///
	South Suburban Rural ///
	Protestant Catholic Other_Religion None bornagn ///	
	scitrust govtrust soctrust ///
	partyid Trump ///
	COVcon_gen covid_unstopp covid_redusprd)
}

foreach x of varlist fftax subrnw banapp {
qui sem (idea -> coemiss, ) ///	
	(idea -> skptk, ) ///
	(idea coemiss skptk ///
	female age education income scilit_sum ///
	Black Other_Race ///
	South Suburban Rural ///
	Protestant Catholic Other_Religion None bornagn ///	
	scitrust govtrust soctrust ///
	partyid Trump ///
	CCcon_gen ccindff ccskep_unstopp ->  `x'), standardized nocapslatent
est store main
te_direct
est store direct
est restore main
te_indirect
est store indirect
est restore main
te_total
est store total

esttab direct indirect total using "tables/supplementary/`x'_sem.tex", /// 
	b(%8.2f)  se(%8.2f) ///
	star(* 0.05 ** 0.01) ///
	nonum label replace ///
	title("Direct and Indirect Effects of Conspiratorial Ideation and Climate Change Specific Conspiracy Beliefs on `: var label `x''") ///
	mtitles(Direct Indirect Total) ///
	drop(female age education income scilit_sum ///
	Black Other_Race ///
	South Suburban Rural ///
	Protestant Catholic Other_Religion None bornagn ///	
	scitrust govtrust soctrust ///
	partyid Trump ///
	CCcon_gen ccindff ccskep_unstopp)
}

***Konfound
est res mask_conreg
capture konfound idea flu china, non_li(1)

est res socdist_conreg
capture konfound idea flu china, non_li(1)  

est res contact_conreg
capture konfound idea flu china , non_li(1) 

est res fftax_conreg
capture konfound idea coemiss skptk, non_li(1)

est res subrnw_conreg
capture konfound idea coemiss skptk , non_li(1)

est res banapp_conreg
capture konfound idea coemiss skptk , non_li(1)

****Max effects*
local all_key partyid scitrust soctrust age scilit_sum 

***COVID
local COV_addkey idea flu china COVcon_gen

local COV_key `COV_addkey' `all_key'
local COV_dv mask socdist contact

foreach y of local COV_dv {
foreach x of local COV_key {
qui sum `x'
local sd_`x' = r(sd)
local 2sd_`x' = `sd_`x''+`sd_`x''
local mean_`x' = r(mean)

est res `y'_conreg
qui margins, ///
		at(`x' =(`=`mean_`x'' - `2sd_`x''' `=`mean_`x'' + `2sd_`x''')) ///
		post predict(out(5))
local diff_`x' = el(e(b),1,2) - el(e(b),1,1)
}
matrix input Diff_mar_`y' = (`diff_idea',`diff_flu', ///
						`diff_china',`diff_COVcon_gen', ///
						`diff_partyid',`diff_scitrust', ///
						`diff_soctrust', ///
						`diff_age',`diff_scilit_sum')

gen keyvars_COV_`y' = ""
gen marg_diff_COV_`y' = .
tokenize "`: colnames Diff_mar_`y''"
qui forval i = 1/`= colsof(Diff_mar_`y')' {
replace marg_diff_COV_`y' = Diff_mar_`y'[1, `i'] in `i'
replace keyvars_COV_`y' = "``i''" in `i'
}

encode keyvars_COV_`y', gen(keyvar_num_COV_`y')

la def keyvar_COV_`y' ///
	1 "Conspiratorial thinking" ///
	2 "Not more dangerous than flu" ///
	3 "Originated Chinese Lab" ///
	4 "COVID Risk Perception" ///
	5 "Party Affiliation" ///
	6 "Scientific Trust" ///
	7 "Socual Trust" ///
	8 "Age" ///
	9 "Scientific Literacy"


la val keyvar_num_COV_`y' keyvar_COV_`y'
}

****Climate Change
local CC_addkey idea coemiss skptk CCcon_gen
local all_key partyid scitrust soctrust age scilit_sum 

local CC_key `CC_addkey' `all_key'
local CC_dv fftax subrnw banapp

foreach y of local CC_dv {
foreach x of local CC_key {
qui sum `x'
local sd_`x' = r(sd)
local 2sd_`x' = `sd_`x''+`sd_`x''
local mean_`x' = r(mean)

est res `y'_conreg
qui margins, ///
		at(`x' =(`=`mean_`x'' - `2sd_`x''' `=`mean_`x'' + `2sd_`x''')) ///
		post predict(out(5))
local diff_`x' = el(e(b),1,2) - el(e(b),1,1)
}
matrix input Diff_mar_`y' = (`diff_idea',`diff_coemiss', ///
						`diff_skptk',`diff_CCcon_gen', ///
						`diff_partyid',`diff_scitrust', ///
						`diff_soctrust', ///
						`diff_age',`diff_scilit_sum')

gen keyvars_CC_`y' = ""
gen marg_diff_CC_`y' = .
tokenize "`: colnames Diff_mar_`y''"
qui forval i = 1/`= colsof(Diff_mar_`y')' {
replace marg_diff_CC_`y' = Diff_mar_`y'[1, `i'] in `i'
replace keyvars_CC_`y' = "``i''" in `i'
}

encode keyvars_CC_`y', gen(keyvar_num_CC_`y')

la def keyvar_CC_`y' ///
	1 "Conspiratorial thinking" ///
	2 "CO2 marginal impact" ///
	3 "CC Seriousness exaggerated" ///
	4 "CC Risk Perception" ///
	5 "Party Affiliation" ///
	6 "Scientific Trust" ///
	7 "Socual Trust" ///
	8 "Age" ///
	9 "Scientific Literacy"

la val keyvar_num_CC_`y' keyvar_CC_`y'
}


**COVID
graph bar (asis) marg_diff_COV_mask, ///
	over(keyvar_num_COV_mask, label(labs(vsmall) angle(90))) ///
	graphregion(color(white) lcolor(white)) ///
	yline(0, lc(block)) ///
	ylabel(-.2(0.1)0.5, gmin gmax ///
	labsize(vsmall) labcolor(black)) ///
	title("Wear Mask", s(medium) c(black)) ///
	scheme(plotplain)  vert ///
	bar(1, bcolor(edkblue)) nodraw ///
	name(mask_mar_max, replace)	

graph bar (asis) marg_diff_COV_socdist, ///
	over(keyvar_num_COV_socdist, label(labs(vsmall) angle(90))) ///
	graphregion(color(white) lcolor(white)) ///
	yline(0, lc(block))	///
	ylabel(-.2(0.1)0.5, gmin gmax ///
	labsize(vsmall) labcolor(black)) ///
	title("Social Distancing", s(medium) c(black)) ///
	scheme(plotplain) vert ///
	bar(1, bcolor(forest_green)) nodraw ///
	name(socdist_mar_max, replace)
	
graph bar (asis) marg_diff_COV_contact, ///
	over(keyvar_num_COV_contact, label(labs(vsmall) angle(90))) ///
	graphregion(color(white) lcolor(white)) ///
	yline(0, lc(block))	///
	ylabel(-.2(0.1)0.5, gmin gmax ///
	labsize(vsmall) labcolor(black)) ///
	title("Limit Contacts", s(medium) c(black)) ///
	scheme(plotplain) vert  ///
	bar(1, bcolor(maroon))  ///
	name(contact_mar_max, replace)
	
*Combine
gr combine ///
	mask_mar_max ///
	socdist_mar_max ///
	contact_mar_max, r(1) ///
	graphregion(color(white) lcolor(white)) ///
	ycomm name(COV_maxfx, replace)

**Climate
graph bar (asis) marg_diff_CC_fftax, ///
	over(keyvar_num_CC_fftax, label(labs(vsmall) angle(90))) ///
	graphregion(color(white) lcolor(white)) ///
	yline(0, lc(block)) ///
	ylabel(-.2(0.1)0.5, gmin gmax ///
	labsize(vsmall) labcolor(black)) ///
	title("Increase Fossil Fuel Taxes", s(medium) c(black)) ///
	scheme(plotplain)  vert ///
	bar(1, bcolor(edkblue)) nodraw ///
	name(ttfax_mar_max, replace)	

	
graph bar (asis) marg_diff_CC_subrnw, ///
	over(keyvar_num_CC_subrnw, label(labs(vsmall) angle(90))) ///
	graphregion(color(white) lcolor(white)) ///
	yline(0, lc(block))	///
	ylabel(-.2(0.1)0.5, gmin gmax ///
	labsize(vsmall) labcolor(black)) ///
	title("Subsidize Renewables", s(medium) c(black)) ///
	scheme(plotplain) vert ///
	bar(1, bcolor(forest_green)) nodraw ///
	name(subrnw_mar_max, replace)
	
graph bar (asis) marg_diff_CC_banapp, ///
	over(keyvar_num_CC_banapp, label(labs(vsmall) angle(90))) ///
	graphregion(color(white) lcolor(white)) ///
	yline(0, lc(block))	///
	ylabel(-.2(0.1)0.5, gmin gmax ///
	labsize(vsmall) labcolor(black)) ///
	title("Ban Old Appliances", s(medium) c(black)) ///
	scheme(plotplain) vert  ///
	bar(1, bcolor(maroon))  ///
	name(banapp_mar_max, replace)
	
*Combine
gr combine ///
	ttfax_mar_max ///
	subrnw_mar_max ///
	banapp_mar_max, r(1) ///
	graphregion(color(white) lcolor(white)) ///
	ycomm name(CC_maxfx, replace)
	
*Combine the two
gr combine ///
	COV_maxfx ///
	CC_maxfx, r(2) ///
	graphregion(color(white) lcolor(white)) ///
	name(maxfx, replace)
	
graph export "graphs/supplementary/Max_effects_positive.pdf", ///
	as(pdf) replace
