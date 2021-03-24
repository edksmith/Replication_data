dropbox
cd "Keith Dissertation/Values and Politics Paper/Climatic Change Submission/Stata_stuff"

*****Margins plots for interactions 
///note values of Schwartz dimentions are a 10%, 50% and 90%

///First need to perform analysis to get saved results
/// run "Dissertation Paper 2 Analysis.do"
// this .do is embedded within the larger analysis file

************Concern
est res reg_int_CC_concern 
margins, at(polipref=(1(1)5) SchwartzSelfTrans=(3.8 5 6)) predict(out(4) fixed) post
est sto margin_concern_selftrans
marginsplot, title(Self Transcendence, c(black) size(medium)) ///
	ytitle("Predicted Probabilities", c(black) size(small)) ///
	xtitle(Political Preference, c(black) size(medsmall)) ///
	graphregion(color(white) lcolor(white)) ///
	ylabel(0.10(0.05)0.6, gmin gmax ///
	labsize(small) labcolor(black) glcolor(gs14)) ///
	legend(rows(1) region(style(none)) size(small)) ///
	xlabel(1 "Right" 3 "Moderate" 5"Left",labsize(small) labcolor(black)) ///
	plot(,label("Low" "Moderate" "High")) ///
	plot1opt(lc(edkblue) mc(edkblue) lp(solid) ms(circle)) ///
	plot2opt(lc(edkblue) mc(edkblue) lp(dot) ms(square)) ///
	plot3opt(lc(edkblue) mc(edkblue) lp(shortdash) ms(diamond)) ///	
	ciopts(color(edkblue))
gr save "Graphs/raw graphs/concern_selftrans.gph", replace

est res reg_int_CC_concern 
margins, at(polipref=(1(1)5) SchwartzSelfEnhance=(2.33 3.67 5)) predict(out(4) fixed) post
est sto margin_concern_selfenhance
marginsplot, title(Self Enhancement, c(black) size(medium)) ///
	ytitle("") xtitle(Political Preference, c(black) size(medsmall)) ///
	graphregion(color(white) lcolor(white)) ///
	ylabel(0.10(0.05)0.6, gmin gmax ///
	labsize(small) labcolor(black) glcolor(gs14)) ///
	legend(rows(1) region(style(none)) size(small)) ///
	xlabel(1 "Right" 3 "Moderate" 5"Left",labsize(small) labcolor(black)) ///
	plot(,label("Low" "Moderate" "High")) ///
	plot1opt(lc(edkblue) mc(edkblue) lp(solid) ms(circle)) ///
	plot2opt(lc(edkblue) mc(edkblue) lp(dot) ms(square)) ///
	plot3opt(lc(edkblue) mc(edkblue) lp(shortdash) ms(diamond)) ///	
	ciopts(color(edkblue))
gr save "Graphs/raw graphs/concern_selfenhance.gph", replace

est res reg_int_CC_concern 
margins, at(polipref=(1(1)5) SchwartzOpenness=(2.75 4.25 5.5)) predict(out(4) fixed) post
est sto margin_concern_openness
marginsplot, title(Openness, c(black) size(medium)) ///
	ytitle("") ///
	xtitle(Political Preference, c(black) size(medsmall)) ///
	graphregion(color(white) lcolor(white)) ///
	ylabel(0.10(0.05)0.6, gmin gmax ///
	labsize(small) labcolor(black) glcolor(gs14)) ///
	legend(rows(1) region(style(none)) size(small)) ///
	xlabel(1 "Right" 3 "Moderate" 5"Left",labsize(small) labcolor(black)) ///
	plot(,label("Low" "Moderate" "High")) ///
	plot1opt(lc(edkblue) mc(edkblue) lp(solid) ms(circle)) ///
	plot2opt(lc(edkblue) mc(edkblue) lp(dot) ms(square)) ///
	plot3opt(lc(edkblue) mc(edkblue) lp(shortdash) ms(diamond)) ///	
	ciopts(color(edkblue))
gr save "Graphs/raw graphs/concern_openness.gph", replace

est res reg_int_CC_concern 
margins, at(polipref=(1(1)5) SchwartzConservation=(2.83 4.33 5.5)) predict(out(4) fixed) post
est sto margin_concern_conservation
est res margin_concern_conservation
marginsplot, title(Conservation, c(black) size(medium)) ///
	ytitle("") xtitle(Political Preference, c(black) size(medsmall)) ///
	graphregion(color(white) lcolor(white)) ///
	ylabel(0.10(0.05)0.6, gmin gmax ///
	labsize(small) labcolor(black) glcolor(gs14)) ///
	legend(rows(1) region(style(none)) size(small)) ///
	xlabel(1 "Right" 3 "Moderate" 5"Left",labsize(small) labcolor(black)) ///
	plot(,label("Low" "Moderate" "High")) ///
	plot1opt(lc(edkblue) mc(edkblue) lp(solid) ms(circle)) ///
	plot2opt(lc(edkblue) mc(edkblue) lp(dot) ms(square)) ///
	plot3opt(lc(edkblue) mc(edkblue) lp(shortdash) ms(diamond)) ///	
	ciopts(color(edkblue))
gr save "Graphs/raw graphs/concern_conservation.gph", replace

grc1leg ///
	"Graphs/raw graphs/concern_selftrans.gph" ///
	"Graphs/raw graphs/concern_selfenhance.gph" ///
	"Graphs/raw graphs/concern_openness.gph" ///
	"Graphs/raw graphs/concern_conservation.gph", ///
	row(1) title("Climate Change Concern", size(medsmall) c(black)) ///
	graphregion(color(white) lcolor(white)) ycomm
gr save "Graphs/raw graphs/Climate Concern Interaction.gph", replace
gr export "Graphs/raw graphs/Climate Concern Interaction.eps", as(eps) preview(off) replace
gr export "Graphs/raw graphs/Climate Concern Interaction.png", as(png) replace
gr export "Graphs/raw graphs/Climate Concern Interaction.tif", as(tif) replace


****************Reduce Energy
*Self Trans
est res reg_int_reduce_energy 
margins, at(polipref=(1(1)5) SchwartzSelfTrans=(3.8 5 6)) predict(out(5) fixed) post
est sto margin_energy_selftrans
marginsplot, title(Self Transcendence, c(black) size(medium)) ///
	ytitle("Predicted Probabilities", c(black) size(small)) ///
	xtitle(Political Preference, c(black) size(medsmall)) ///
	graphregion(color(white) lcolor(white)) ///
	ylabel(0 "0" 0.05 "0.05" 0.1 "0.10" 0.15 "0.15" 0.20 "0.20" 0.25 "0.25", ///
	labsize(small) labcolor(black) glcolor(gs14)) ///
	legend(rows(1) region(style(none)) size(small)) ///
	xlabel(1 "Right" 3 "Moderate" 5"Left",labsize(small) labcolor(black)) ///
	plot(,label("Low" "Moderate" "High")) ///
	plot1opt(lc(forest_green) mc(forest_green) lp(solid) ms(circle)) ///
	plot2opt(lc(forest_green) mc(forest_green) lp(dot) ms(square)) ///
	plot3opt(lc(forest_green) mc(forest_green) lp(shortdash) ms(diamond)) ///	
	ciopts(color(forest_green))
gr save "Graphs/raw graphs/energy_selftrans.gph", replace

*Self Enhance
est res reg_int_reduce_energy 
margins, at(polipref=(1(1)5) SchwartzSelfEnhance=(2.33 3.67 5)) predict(out(5) fixed) post
est sto margin_energy_selfenhance
marginsplot, title(Self Enhancement, c(black) size(medium)) ///
	ytitle("") xtitle(Political Preference, c(black) size(medsmall)) ///
	graphregion(color(white) lcolor(white)) ///
	ylabel(0 "0" 0.05 "0.05" 0.1 "0.10" 0.15 "0.15" 0.20 "0.20" 0.25 "0.25", ///
	labsize(small) labcolor(black) glcolor(gs14)) ///
	legend(rows(1) region(style(none)) size(small)) ///
	xlabel(1 "Right" 3 "Moderate" 5"Left",labsize(small) labcolor(black)) ///
	plot(,label("Low" "Moderate" "High")) ///
	plot1opt(lc(forest_green) mc(forest_green) lp(solid) ms(circle)) ///
	plot2opt(lc(forest_green) mc(forest_green) lp(dot) ms(square)) ///
	plot3opt(lc(forest_green) mc(forest_green) lp(shortdash) ms(diamond)) ///	
	ciopts(color(forest_green))
gr save "Graphs/raw graphs/energy_selfenhance.gph", replace

*Openness
est res reg_int_reduce_energy 
margins, at(polipref=(1(1)5) SchwartzOpenness=(2.75 4.25 5.5)) predict(out(5) fixed) post
est sto margin_energy_openness
marginsplot, title(Openness, c(black) size(medium)) ///
	ytitle("") ///
	xtitle(Political Preference, c(black) size(medsmall)) ///
	graphregion(color(white) lcolor(white)) ///
	ylabel(0 "0" 0.05 "0.05" 0.1 "0.10" 0.15 "0.15" 0.20 "0.20" 0.25 "0.25", ///
	labsize(small) labcolor(black) glcolor(gs14)) ///
	legend(rows(1) region(style(none)) size(small)) ///
	xlabel(1 "Right" 3 "Moderate" 5"Left",labsize(small) labcolor(black)) ///
	plot(,label("Low" "Moderate" "High")) ///
	plot1opt(lc(forest_green) mc(forest_green) lp(solid) ms(circle)) ///
	plot2opt(lc(forest_green) mc(forest_green) lp(dot) ms(square)) ///
	plot3opt(lc(forest_green) mc(forest_green) lp(shortdash) ms(diamond)) ///	
	ciopts(color(forest_green))
gr save "Graphs/raw graphs/energy_openness.gph", replace

*Conservation
est res reg_int_reduce_energy 	
margins, at(polipref=(1(1)5) SchwartzConservation=(2.83 4.33 5.5)) predict(out(5) fixed) post
est sto margin_energy_conservation
est res margin_energy_conservation
marginsplot, title(Conservation, c(black) size(medium)) ///
	ytitle("") xtitle(Political Preference, c(black) size(medsmall)) ///
	graphregion(color(white) lcolor(white)) ///
	ylabel(0 "0" 0.05 "0.05" 0.1 "0.10" 0.15 "0.15" 0.20 "0.20" 0.25 "0.25", ///
	labsize(small) labcolor(black) glcolor(gs14)) ///
	legend(rows(1) region(style(none)) size(small)) ///
	xlabel(1 "Right" 3 "Moderate" 5"Left",labsize(small) labcolor(black)) ///
	plot(,label("Low" "Moderate" "High")) ///
	plot1opt(lc(forest_green) mc(forest_green) lp(solid) ms(circle)) ///
	plot2opt(lc(forest_green) mc(forest_green) lp(dot) ms(square)) ///
	plot3opt(lc(forest_green) mc(forest_green) lp(shortdash) ms(diamond)) ///	
	ciopts(color(forest_green))
gr save "Graphs/raw graphs/energy_conservation.gph", replace

grc1leg ///
	"Graphs/raw graphs/energy_selftrans.gph" ///
	"Graphs/raw graphs/energy_selfenhance.gph" ///
	"Graphs/raw graphs/energy_openness.gph" ///
	"Graphs/raw graphs/energy_conservation.gph", ///
	row(1) title("Reduce Energy", size(medsmall) c(black)) ///
	graphregion(color(white) lcolor(white))  ycomm
gr save "Graphs/raw graphs/Energy Reduction Interaction.gph", replace
gr export "Graphs/raw graphs/Energy Reduction Interaction.eps", as(eps) preview(off) replace
gr export "Graphs/raw graphs/Energy Reduction Interaction.png", as(png) replace
gr export "Graphs/raw graphs/Energy Reduction Interaction.tif", as(tif) replace

************Increase FF Tax
*Self Trans
est res reg_int_increase_FFtax
margins, at(polipref=(1(1)5) SchwartzSelfTrans=(3.8 5 6)) predict(out(4) fixed) post
est sto margin_fftax_selftrans
marginsplot, title(Self Transcendence, c(black) size(medium)) ///
	ytitle("Predicted Probabilities", c(black) size(small)) ///
	xtitle(Political Preference, c(black) size(medsmall)) ///
	graphregion(color(white) lcolor(white)) ///
	ylabel(0.2(0.05)0.6, gmin gmax ///
	labsize(small) labcolor(black) glcolor(gs14)) ///
	legend(rows(1) region(style(none)) size(small)) ///
	xlabel(1 "Right" 3 "Moderate" 5"Left",labsize(small) labcolor(black)) ///
	plot(,label("Low" "Moderate" "High")) ///
	plot1opt(lc(black) mc(black) lp(solid) ms(circle)) ///
	plot2opt(lc(black) mc(black) lp(dot) ms(square)) ///
	plot3opt(lc(black) mc(black) lp(shortdash) ms(diamond)) ///	
	ciopts(color(black))
gr save "Graphs/raw graphs/fftax_selftrans.gph", replace

est res reg_int_increase_FFtax
margins, at(polipref=(1(1)5) SchwartzSelfEnhance=(2.33 3.67 5)) predict(out(4) fixed) post
est sto margin_fftax_selfenhance
marginsplot, title(Self Enhancement, c(black) size(medium)) ///
	ytitle("") xtitle(Political Preference, c(black) size(medsmall)) ///
	graphregion(color(white) lcolor(white)) ///
	ylabel(0.2(0.05)0.6, gmin gmax ///
	labsize(small) labcolor(black) glcolor(gs14)) ///
	legend(rows(1) region(style(none)) size(small)) ///
	xlabel(1 "Right" 3 "Moderate" 5"Left",labsize(small) labcolor(black)) ///
	plot(,label("Low" "Moderate" "High")) ///
	plot1opt(lc(black) mc(black) lp(solid) ms(circle)) ///
	plot2opt(lc(black) mc(black) lp(dot) ms(square)) ///
	plot3opt(lc(black) mc(black) lp(shortdash) ms(diamond)) ///	
	ciopts(color(black))
gr save "Graphs/raw graphs/fftax_selfenhance.gph", replace

est res reg_int_increase_FFtax
margins, at(polipref=(1(1)5) SchwartzOpenness=(2.75 4.25 5.5)) predict(out(4) fixed) post
est sto margin_fftax_openness
marginsplot, title(Openness, c(black) size(medium)) ///
	ytitle("") ///
	xtitle(Political Preference, c(black) size(medsmall)) ///
	graphregion(color(white) lcolor(white)) ///
	ylabel(0.2(0.05)0.6, gmin gmax ///
	labsize(small) labcolor(black) glcolor(gs14)) ///
	legend(rows(1) region(style(none)) size(small)) ///
	xlabel(1 "Right" 3 "Moderate" 5"Left",labsize(small) labcolor(black)) ///
	plot(,label("Low" "Moderate" "High")) ///
	plot1opt(lc(black) mc(black) lp(solid) ms(circle)) ///
	plot2opt(lc(black) mc(black) lp(dot) ms(square)) ///
	plot3opt(lc(black) mc(black) lp(shortdash) ms(diamond)) ///	
	ciopts(color(black))
gr save "Graphs/raw graphs/fftax_openness.gph", replace

est res reg_int_increase_FFtax	
margins, at(polipref=(1(1)5) SchwartzConservation=(2.83 4.33 5.5)) predict(out(4) fixed) post
est sto margin_fftax_conservation
est res margin_fftax_conservation
marginsplot, title(Conservation, c(black) size(medium)) ///
	ytitle("") xtitle(Political Preference, c(black) size(medsmall)) ///
	graphregion(color(white) lcolor(white)) ///
	ylabel(0.2(0.05)0.6, gmin gmax ///
	labsize(small) labcolor(black) glcolor(gs14)) ///
	legend(rows(1) region(style(none)) size(small)) ///
	xlabel(1 "Right" 3 "Moderate" 5"Left",labsize(small) labcolor(black)) ///
	plot(,label("Low" "Moderate" "High")) ///
	plot1opt(lc(black) mc(black) lp(solid) ms(circle)) ///
	plot2opt(lc(black) mc(black) lp(dot) ms(square)) ///
	plot3opt(lc(black) mc(black) lp(shortdash) ms(diamond)) ///	
	ciopts(color(black))
gr save "Graphs/raw graphs/fftax_conservation.gph", replace

grc1leg ///
	"Graphs/raw graphs/fftax_selftrans.gph" ///
	"Graphs/raw graphs/fftax_selfenhance.gph" ///
	"Graphs/raw graphs/fftax_openness.gph" ///
	"Graphs/raw graphs/fftax_conservation.gph", ///
	row(1) title("Increase Fossil Fuel Taxes", size(medsmall) c(black)) ///
	graphregion(color(white) lcolor(white)) ycomm
gr save "Graphs/raw graphs/Increase FF Taxes Interaction.gph", replace
gr export "Graphs/raw graphs/Increase FF Taxes Interaction.eps", as(eps) preview(off) replace
gr export "Graphs/raw graphs/Increase FF Taxes Interaction.png", as(png) replace
gr export "Graphs/raw graphs/Increase FF Taxes Interaction.tif", as(tif) replace
