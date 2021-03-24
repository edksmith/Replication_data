dropbox
cd "Keith Dissertation/Values and Politics Paper/Climatic Change Submission/Stata_stuff"
run "Values_politics_coding.do"

****Descriptive Statistics Table
egen regressmiss=rowmiss(CC_concern reduce_energy increase_FFtax ///
	SchwartzSelfTrans SchwartzSelfEnhance SchwartzOpenness SchwartzConservation polipref ///
	socialtrust politrustraw Indiv_Reduce_Energy Group_Reduce_Energy ///
	female age education income belong_religion attend ///
	gni freexp2016 coal)

estpost tabstat CC_concern reduce_energy increase_FFtax ///
	SchwartzSelfTrans SchwartzSelfEnhance SchwartzOpenness SchwartzConservation polipref ///
	socialtrust politrustraw Indiv_Reduce_Energy Group_Reduce_Energy ///
	female age education income belong_religion attend ///
	gni freexp2016 coal ///
	if transition==0, s(mean sd) columns(statistics)

esttab . ///
	using "raw tables/descriptive_table.tex", replace ///
	cells("mean(fmt(a2)) sd(fmt(a2))") label

***Dependent Variable Distributions
catplot CC_concern  if transition==0, ///
	title(Climate Change Concern, c(black) size(medsmall)) ///
	ytitle(Percent, c(black) size(medsmall)) ///
	graphregion(color(white) lcolor(white)) ///
	perc blabel(bar, position(outside) format(%3.1f)) ///
	scheme(lean2) ylabel(, nogrid) vert ///
	bar(1, bcolor(edkblue)) var1opts(relabel(1 `""Not at all" "worried""' ///
	2 `""Not very" "worried""' 3 `""Somewhat" "worried""' 4 `""Very/Extremely" "worried""') ///
	label( ///
	labsize(vsmall) angle(0))) ///
	name(distribution_concern,replace) nodraw
	
catplot reduce_energy  if transition==0, ///
	title(Reduce Energy, c(black) size(medsmall)) ///
	ytitle(Percent, c(black) size(medsmall)) ///
	graphregion(color(white) lcolor(white)) ///
	perc blabel(bar, position(outside) format(%3.1f)) ///
	scheme(lean2) ylabel(, nogrid) vert ///
	bar(1, bcolor(forest_green)) var1opts(relabel(1 `""Hardly" "ever""' ///
	2 "Sometimes" 3 "Often" 4 `""Very" "Often""' 5 "Always") ///
	label(labsize(vsmall) angle(0)))  ///
	name(distribution_reduce,replace) nodraw


catplot increase_FFtax if transition==0, ///
	title(Increase FF Tax, c(black) size(medsmall)) ///
	ytitle(Percent, c(black) size(medsmall)) ///
	graphregion(color(white) lcolor(white)) ///
	perc blabel(bar, position(outside) format(%3.1f)) ///
	scheme(lean2) ylabel(, nogrid) vert ///
	bar(1, bcolor(cranberry)) var1opts(relabel(1 `""Strongly" "Against""' ///
	2 `""Somewhat" "Against""' 3 `""Neither/nor" "in Favor""' 4 `""Somewhat/Strongly" "Favor""') ///
	label(labsize(vsmall) angle(0)))  ///
	name(distribution_FF,replace) nodraw

gr combine ///
	distribution_concern ///
	distribution_reduce ///
	distribution_FF, ///
	graphregion(color(white) lcolor(white))
gr save "Graphs/Dependent_Descriptives.gph", replace
gr export "Graphs\Dependent_Descriptives.eps", as(eps) preview(off) replace
gr export "Graphs\Dependent_Descriptives.png", as(png) replace


*******Random Effects Ordinal Models
/*XT OLOGIT
xtset country

foreach x in CC_concern	reduce_energy increase_FFtax {
	xtologit `x' SchwartzSelfTrans SchwartzSelfEnhance SchwartzOpenness SchwartzConservation polipref ///
	socialtrust politrustraw Indiv_Reduce_Energy Group_Reduce_Energy ///
	female age education income belong_religion attend ///
	gni country_socialtrust country_politrustraw ///
	gini freexp2016 renewables coal  ///
	if transition==0, or intpoints(7)
	est sto reg_`x'	
}

foreach x in CC_concern	reduce_energy increase_FFtax {
	xtologit `x' c.SchwartzSelfTrans##c.polipref c.SchwartzSelfEnhance##c.polipref ///
	c.SchwartzOpenness##c.polipref c.SchwartzConservation##c.polipref ///
	socialtrust politrustraw Indiv_Reduce_Energy Group_Reduce_Energy ///
	female age education income belong_religion attend ///
	gni country_socialtrust country_politrustraw ///
	gini freexp2016 renewables coal  ///
	if transition==0, or intpoints(7)
	est sto reg_`x'_int	
}
*/

***MEOLOGIT
foreach x in CC_concern	reduce_energy increase_FFtax {
ologit `x' SchwartzSelfTrans SchwartzSelfEnhance SchwartzOpenness SchwartzConservation polipref ///
	socialtrust politrustraw Indiv_Reduce_Energy Group_Reduce_Energy ///
	female age education income belong_religion attend ///
	gni freexp2016 coal  ///
	if transition==0, or 
mat SAVECC1=e(b)	
est sto olo_`x'

meologit `x' SchwartzSelfTrans SchwartzSelfEnhance SchwartzOpenness SchwartzConservation polipref ///
	socialtrust politrustraw Indiv_Reduce_Energy Group_Reduce_Energy ///
	female age education income belong_religion attend ///
	gni freexp2016 coal  ///
	if transition==0 || country:, intmethod(mv) evaltype(gf0) ///
	intpoints(7) or from(SAVECC1) cov(un)
mat SAVECC2=e(b)	
est sto reg_`x'
estat ic 

meologit `x' c.SchwartzSelfTrans##c.polipref c.SchwartzSelfEnhance##c.polipref ///
	c.SchwartzOpenness##c.polipref c.SchwartzConservation##c.polipref ///
	socialtrust politrustraw Indiv_Reduce_Energy Group_Reduce_Energy ///
	female age education income belong_religion attend ///
	gni freexp2016 coal  ///
	if transition==0 || country:, intmethod(mv) evaltype(gf0) ///
	intpoints(7) or from(SAVECC2) cov(un)
mat SAVECC3=e(b)	
est sto reg_int_`x'
estat ic
}

**Make Regression Table
esttab reg_* using "raw tables/regression_all.tex", ///
 se(2) b(2) star(* 0.05 ** 0.01) ///
	title(Multilevel Ordered Logistic Regression Table) ///
	mtitle("Climate Change Concern" "" "Reduce Energy" "" "Increase Fossil Fuel Taxes" "") ///
	replace	label

*********Margins for Main Effects*****
foreach x in CC_concern increase_FFtax {
est res reg_`x'
margins, ///
	at(SchwartzSelfTrans=(3.8 5 6)) ///
	at(SchwartzSelfEnhance=(2.33 3.67 5)) ///
	at(SchwartzOpenness=(2.75 4.25 5.5)) ///
	at(SchwartzConservation=(2.83 4.33 5.5)) ///
	at(polipref=(1 3 5)) predict(outcome(4) fixed) post
	est sto marg_`x'
}

foreach x in reduce_energy {
est res reg_`x'
margins, ///
	at(SchwartzSelfTrans=(3.8 5 6)) ///
	at(SchwartzSelfEnhance=(2.33 3.67 5)) ///
	at(SchwartzOpenness=(2.75 4.25 5.5)) ///
	at(SchwartzConservation=(2.83 4.33 5.5)) ///
	at(polipref=(1 3 5)) predict(outcome(5) fixed) post
est sto marg_`x'
}

esttab ///
	marg_CC_concern marg_reduce_energy marg_increase_FFtax ///
	using "raw tables/margins_all.tex", ///
	b(2) nostar not ///
	title(Marginal Effects of Value Dimensions and Political Orientation) ///
	mtitle("Climate Change Concern" "Reduce Energy" "Increase Fossil Fuel Taxes") ///
	replace	label booktabs alignment(D{.}{.}{-1}) ///
	coef( ///
	1._at "Low" ///
	2._at "Moderate" ///
	3._at "High" ///
	4._at "Low" ///
	5._at "Moderate" ///
	6._at "High" ///
	7._at "Low" ///
	8._at "Moderate" ///
	9._at "High" ///
	10._at "Low" ///
	11._at "Moderate" ///
	12._at "High" ///
	13._at "Right" ///
	14._at "Moderate" ///
	15._at "Left")

*Graph for presentation
coefplot marg_CC_concern marg_reduce_energy marg_increase_FFtax, ///
	vert graphregion(color(white) lcolor(white)) ///
	ylabel(, gmin gmax ///
	labsize(small) labcolor(black) glcolor(gs14)) ///
	coeflabels(1._at="Low" /// 
				2._at="Moderate" ///
				3._at="High" ///
				4._at="Low" /// 
				5._at="Moderate" ///
				6._at="High" ///
				7._at="Low" /// 
				8._at="Moderate" ///
				9._at="High" ///
				10._at="Low" /// 
				11._at="Moderate" ///
				12._at="High" ///
				13._at="Right" /// 
				14._at="Moderate" ///
				15._at="Left" ///
				, angle(90) labs(small)) ///
	group(1._at 2._at 3._at = `""{bf:Self}" "{bf:Transcendence}""' ///
	4._at 5._at 6._at = `""{bf:Self}" "{bf:Enhancement}""' /// 
	7._at 8._at 9._at = "{bf:Openness}" /// 	
	10._at 11._at 12._at = "{bf:Conservation}" /// 
	13._at 14._at 15._at = `""{bf:Political}" "{bf:Orientation}""') ///
	legend(region(lcolor(white)) ///
	order(1 "Climate Concern" 3 "Reduce Energy" 5 "Increase FF Taxes") row(1))
gr save "Graphs/Margins_Coefplot.gph", replace
gr export "Graphs/Margins_Coefplot.eps", as(eps) preview(off) replace
gr export "Graphs/Margins_Coefplot.png", as(png) replace
	
**********Margins plots for interactions 

///note values of Schwartz dimentions are a 10%, 50% and 90%
run "Interaction Graphs.do"


**********KHB
xtset country

/* Confirm that xtologit is same as meologit
xtologit CC_concern polipref SchwartzOpenness SchwartzSelfEnhance  SchwartzConservation  SchwartzSelfTrans ///
	socialtrust politrustraw belong_religion attend female age education income ///
	gni country_socialtrust country_politrustraw ///
	Indiv_Reduce_Energy Group_Reduce_Energy ///
	if transition==0
est sto concern_regression_xtologit
*/
*rename Schwartz value to fit KHB space naming limits
gen m1=SchwartzSelfTrans	
gen m2=SchwartzSelfEnhance 
gen m3=SchwartzOpenness 
gen m4=SchwartzConservation 
la var m1 "Self-Transcendence"
la var m2 "Self-Enhancement"
la var m3 "Openness"
la var m4 "Conservation"

*Values decomposed by political orientation

khb xtologit CC_concern m1 m2 m3 m4 ||  polipref ///
	if transition==0, s d ///
	c(socialtrust politrustraw Indiv_Reduce_Energy Group_Reduce_Energy ///
	female age education income belong_religion attend ///
	gni freexp2016 coal)
	mat disentangle = e(disentangle)
	estadd scalar selftrans_reduce = disentangle[1,4]
	estadd scalar selfenhance_reduce = disentangle[2,4]
	estadd scalar openness_reduce = disentangle[3,4]
	estadd scalar conservation_reduce = disentangle[4,4]
est sto khb_CCconcern

khb xtologit reduce_energy m1 m2 m3 m4 ||  polipref ///
	if transition==0, s d ///
	c(socialtrust politrustraw Indiv_Reduce_Energy Group_Reduce_Energy ///
	female age education income belong_religion attend ///
	gni freexp2016 coal)
	mat disentangle = e(disentangle)
	estadd scalar selftrans_reduce = disentangle[1,4]
	estadd scalar selfenhance_reduce = disentangle[2,4]
	estadd scalar openness_reduce = disentangle[3,4]
	estadd scalar conservation_reduce = disentangle[4,4]
est sto khb_reduce

khb xtologit increase_FFtax m1 m2 m3 m4 ||  polipref ///
	if transition==0, s d ///
	c(socialtrust politrustraw Indiv_Reduce_Energy Group_Reduce_Energy ///
	female age education income belong_religion attend ///
	gni freexp2016 coal)
	mat disentangle = e(disentangle)
	estadd scalar selftrans_reduce = disentangle[1,4]
	estadd scalar selfenhance_reduce = disentangle[2,4]
	estadd scalar openness_reduce = disentangle[3,4]
	estadd scalar conservation_reduce = disentangle[4,4]
est sto khb_FFtax


dropbox
cd "Dissertation/Paper 2"
esttab khb_CCconcern khb_reduce khb_FFtax using "raw tables/khb_all.tex", ///
	label stats(pct_m1 pct_m2 pct_m3 pct_m4, ///
	label("Self-Transcendence" "Self-Enhancement" "Openness" "Conservation") ///
	fmt(1 1)) se(2) b(2) star(* 0.05 ** 0.01) ///
	title(Decomposition of Value Dimensions by Political Orientation) ///
	mtitle("Climate Change Concern" "Reduce Energy" "Increase Fossil Fuel Taxes") ///
	replace	

/*
*Political preference decomposed by values
khb xtologit CC_concern polipref || m1 m2 m3 m4  ///
	if transition==0, s d ///
	c(socialtrust politrustraw Indiv_Reduce_Energy Group_Reduce_Energy ///
	female age education income belong_religion attend ///
	gni country_socialtrust country_politrustraw ///
	gini freexp2016 renewables coal)
	mat disentangle = e(disentangle)
	estadd scalar selftrans_reduce = disentangle[1,4]
	estadd scalar selfenhance_reduce = disentangle[2,4]
	estadd scalar openness_reduce = disentangle[3,4]
	estadd scalar conservation_reduce = disentangle[4,4]
est sto khb_CCconcern_poli

khb xtologit reduce_energy polipref || m1 m2 m3 m4  ///
	if transition==0, s d ///
	c(socialtrust politrustraw Indiv_Reduce_Energy Group_Reduce_Energy ///
	female age education income belong_religion attend ///
	gni country_socialtrust country_politrustraw ///
	gini freexp2016 renewables coal)
	mat disentangle = e(disentangle)
	estadd scalar selftrans_reduce = disentangle[1,4]
	estadd scalar selfenhance_reduce = disentangle[2,4]
	estadd scalar openness_reduce = disentangle[3,4]
	estadd scalar conservation_reduce = disentangle[4,4]
est sto khb_reduce_poli

khb xtologit increase_FFtax polipref || m1 m2 m3 m4  ///
	if transition==0, s d ///
	c(socialtrust politrustraw Indiv_Reduce_Energy Group_Reduce_Energy ///
	female age education income belong_religion attend ///
	gni country_socialtrust country_politrustraw ///
	gini freexp2016 renewables coal)
	mat disentangle = e(disentangle)
	estadd scalar selftrans_reduce = disentangle[1,4]
	estadd scalar selfenhance_reduce = disentangle[2,4]
	estadd scalar openness_reduce = disentangle[3,4]
	estadd scalar conservation_reduce = disentangle[4,4]
est sto khb_FFtax_poli

esttab khb_CCconcern_poli khb_reduce_poli khb_FFtax_poli using "raw tables/khb_all_poli.tex", ///
	stats(pct_polipref selftrans_reduce ///
	selfenhance_reduce openness_reduce conservation_reduce, ///
	label("Confounding \%" "\% reduced via Self-Transcendence" "\% reduced via Self-Enhancement" "\% reduced via Openness" "\% reduced via Conservation") ///
	fmt(1 1)) se(2) b(2) star(* 0.05 ** 0.01) ///
	title(Decomposition of Political Ideology by Value Dimensions) ///
	mtitle("Climate Change Concern" "Reduce Energy" "Increase Fossil Fuel Taxes") ///
	replace	

*/

****Sandbox
/*
dropbox
cd "Dissertation/Paper 2"
run "Dissertation Paper 2 Data Coding.do"	

*Model 1, values and political frames
sem ///
	(polipref SchwartzOpenness SchwartzSelfEnhance SchwartzSelfTrans SchwartzConservation-> ///
	increase_FFtax reduce_energy CC_concern, ) ///
	if transition==0, standardized nocapslatent ///
	cov( e.increase_FFtax*e.reduce_energy e.increase_FFtax*e.CC_concern e.reduce_energy*e.CC_concern)
	
*Model 2, with demos
sem ///
	(polipref SchwartzOpenness SchwartzSelfEnhance SchwartzSelfTrans SchwartzConservation ///
	socialtrust politrustraw belong_religion attend female age education income -> ///
	increase_FFtax reduce_energy CC_concern, ) ///
	if transition==0, standardized nocapslatent ///
	cov( e.increase_FFtax*e.reduce_energy e.increase_FFtax*e.CC_concern e.reduce_energy*e.CC_concern)

*Model 3, w/ contextual
sem ///
	(polipref SchwartzOpenness SchwartzSelfEnhance SchwartzSelfTrans SchwartzConservation ///
	socialtrust politrustraw belong_religion attend female age education income ///
	gni country_socialtrust country_politrustraw -> ///
	increase_FFtax reduce_energy CC_concern, ) ///
	if transition==0, standardized nocapslatent ///
	cov( e.increase_FFtax*e.reduce_energy e.increase_FFtax*e.CC_concern e.reduce_energy*e.CC_concern)

*Model 4, w/ concerns and contextual

sem ///
	(polipref SchwartzOpenness SchwartzSelfEnhance SchwartzSelfTrans SchwartzConservation ///
	socialtrust politrustraw belong_religion attend female age education income ///
	gni country_socialtrust country_politrustraw ///
	Indiv_Reduce_Energy Group_Reduce_Energy-> ///
	increase_FFtax reduce_energy CC_concern, ) ///
	if transition==0, standardized nocapslatent ///
	cov( e.increase_FFtax*e.reduce_energy e.increase_FFtax*e.CC_concern e.reduce_energy*e.CC_concern)

*Model 5, w/interactions, concerns and contextual
sem ///
	(polipref SchwartzOpenness SchwartzSelfEnhance SchwartzSelfTrans SchwartzConservation ///
	socialtrust politrustraw belong_religion attend female age education income ///
	gni country_socialtrust country_politrustraw ///
	Indiv_Reduce_Energy Group_Reduce_Energy-> ///
	increase_FFtax reduce_energy CC_concern, ) ///
	(SchwartzOpenness SchwartzSelfEnhance SchwartzSelfTrans SchwartzConservation -> polipref, ) ///
	if transition==0, standardized nocapslatent ///
	cov(e.increase_FFtax*e.reduce_energy e.increase_FFtax*e.CC_concern e.reduce_energy*e.CC_concern)

*Calculate the direct and indirect effects
sem ///
	(polipref SchwartzOpenness SchwartzSelfEnhance  SchwartzConservation  SchwartzSelfTrans ///
	socialtrust politrustraw belong_religion attend female age education income ///
	gni country_socialtrust country_politrustraw ///
	Indiv_Reduce_Energy Group_Reduce_Energy-> ///
	CC_concern, ) ///
	(SchwartzOpenness SchwartzSelfEnhance  SchwartzConservation  SchwartzSelfTrans-> polipref, ) ///
	if transition==0, standardized nocapslatent

***


egen missing=rowmiss(CC_concern polipref SchwartzOpenness SchwartzSelfEnhance  SchwartzConservation  SchwartzSelfTrans)

egen y1_std=std(CC_concern) if missing==0
egen x1_std=std(polipref) if missing==0
egen m1_std=std(SchwartzOpenness) if missing==0
egen m2_std=std(SchwartzSelfEnhance)  if missing==0
egen m3_std=std(SchwartzConservation) if missing==0 
egen m_std=std(SchwartzSelfTrans) if missing==0	

regress CC_concern x1_std m1_std m2_std m3_std m_std
regress CC_concern polipref SchwartzOpenness SchwartzSelfEnhance  SchwartzConservation  SchwartzSelfTrans, beta

gen m1=SchwartzOpenness 
gen m2=SchwartzSelfEnhance 
gen m3=SchwartzConservation 
gen m4=SchwartzSelfTrans	

khb regress CC_concern polipref ///
	|| m1 m2 m3 m4 if transition==0, ///
	c(socialtrust politrustraw belong_religion attend female age education income ///
	gni country_socialtrust country_politrustraw ///
	Indiv_Reduce_Energy Group_Reduce_Energy) s d





***Sandbox
/*

program indireff, rclass
sem ///
	(polipref SchwartzOpenness SchwartzSelfEnhance SchwartzSelfTrans SchwartzConservation ///
	socialtrust politrustraw belong_religion attend female age education income ///
	gni country_socialtrust country_politrustraw ///
	Indiv_Reduce_Energy Group_Reduce_Energy-> ///
	increase_FFtax reduce_energy CC_concern, ) ///
	(SchwartzOpenness SchwartzSelfEnhance SchwartzSelfTrans SchwartzConservation -> polipref, ) ///
	if transition==0, standardized nocapslatent ///
	cov(e.increase_FFtax*e.reduce_energy e.increase_FFtax*e.CC_concern e.reduce_energy*e.CC_concern)
  estat teffects
  mat bi = r(indirect)
  mat bd = r(direct)
  mat bt = r(total)
  return scalar indir_FF_openness  = el(bi,1,6)
  return scalar indir_FF_selfenhance  = el(bi,1,7)
  return scalar indir_FF_selftrans  = el(bi,1,8)
   return scalar indir_FF_conservation  = el(bi,1,9)
  return scalar direct_FF_openness  = el(bi,1,6)
  return scalar direct_FF_selfenhance  = el(bi,1,7)
  return scalar direct_FF_selftrans  = el(bi,1,8)
   return scalar direct_FF_conservation  = el(bi,1,9)
  return scalar total  = el(bt,1,3)
end

