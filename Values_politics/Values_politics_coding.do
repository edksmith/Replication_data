dropbox
cd "Keith Dissertation/Values and Politics Paper/Climatic Change Submission/Stata_stuff"
use "ESS Round 8 (2016).dta", replace

********Dependent Variables******
****Policy Support
**Increase Taxes on Fossil Fuels
recode inctxff ///
	(5=1 "Stongly Against") ///
	(4=2 "Some Against") ///
	(3=3 "Neither nor") ///
	(2 1=4 "Somewhat or Strongly Favor"), /// ***collapsed these two because strong favor has only 5%
	gen(increase_FFtax)
lab var increase_FFtax "Increase Fossil Fuel Taxes"
	
**Public Money to Subsidize Renewables
recode sbsrnen ///
	(5=1 "Stong Against") ///
	(4=2 "Some Against") ///
	(3=3 "Neither nor") ///
	(2=4 "Some Favor") ///
	(1=5 "Stong Favor"), ///
	gen(sub_renewables)	
lab var sub_renewables "Subsidise Renewable Energy"

**Law banning inefficient Appliances
recode banhhap ///
	(5=1 "Stong Against") ///
	(4=2 "Some Against") ///
	(3=3 "Neither nor") ///
	(2=4 "Some Favor") ///
	(1=5 "Stong Favor"), ///
	gen(ban_appliances)

lab var ban_appliances "Ban Sale of non-Efficient Appliances"

*****Individual Actions
**Reduce Energy Use
recode rdcenr ///
	(1 2 =1 "Hardley ever") /// ***Collapsed as never had only 2.5%
	(3 = 2 "Sometimes") ///
	(4=3 "Often") ///
	(5=4 "Very Often") ///
	(6=5 "Always") ///
	(else=.), ///
	gen(reduce_energy)
lab var reduce_energy "Reduce Energy"

**Buy Energy Appliances
clonevar buy_appliance=eneffap
lab var buy_appliance "Likelihood to Buy Efficient Appliance"

********Climate Change Attitudes and Beliefs******
****CC Concern**
**Global CC Concern
gen CC_global_impact=11-ccgdbd
la def CC_global_impact 1 "Extremely Good" 11 "Extremely Bad"
la val CC_global_impact CC_global_impact
lab var CC_global_impact "Climate Change Impact on World"

**General CC Concern
**General CC Concern
recode wrclmch ///
	(1=1 "Not at all worrried") ///
	(2=2 "Not very worried") ///
	(3=3 "Somewhat worried") ///
	(4 5 = 4 "Very or Extremely worried"), ///
	gen(CC_concern)
lab var CC_concern "Climate Change Concern"

*****Perceived Adaptive Capacity
**Individual Reduction Effectiveness // "How likely, limiting own energy use reduce climate change"
clonevar Indiv_Reduce_Energy=ownrdcc
lab var Indiv_Reduce_Energy "Individual Energy Reduction"

**Group Likeliness to Reduce  // "Imagine large numbers of people limit energy use, how likely reduce climate chan"
clonevar Group_Likely_Energy=lklmten
lab var Group_Likely_Energy "Likelihood Group Limits Energy"

**Group Reduction Effectiveness // "How likely, large numbers of people limit energy use"
clonevar Group_Reduce_Energy=lkredcc
lab var Group_Reduce_Energy "Group Energy Reduction"

**Government Likeliness to Act // "How likely, governments enough countries take action to reduce climate change"
clonevar Gov_Likely_Energy=gvsrdcc
lab var Gov_Likely_Energy "Likelihood Governments Take Actions"


*****Climate Change Normative Beliefs
**Responsibility // "To what extent feel personal responsibility to reduce climate change"
clonevar Indiv_Responsible = ccrdprs
lab var Indiv_Responsible "Personal Responsibility to Reduce Climate Change"

**Trend Skepticism (low to high) // "Do you think world's climate is changing"
clonevar Trend_Skepticism= clmchng
lab var Trend_Skepticism "World's climate is changing"	

**Attribute Skepticism (low to high) // "Climate change caused by natural processes, human activity, or both"
clonevar Att_Skepticism = ccnthum
recode Att_Skepticism (55=.e)
lab var Att_Skepticism "Climate change is caused by human activity"

*************************Political Frames**********
**Politial Orientation (right to left)
recode lrscale ///
	(0/2=5 "Str Left") ///
	(3 4=4 "Mod Left") ///
	(5=3 "Moderate") ///
	(6 7=2 "Mod Right") ///
	(8/10=1 "Str Right"), ///
	gen(polipref)
lab var polipref "Political Orientation"
	
*************************Human Values**********
***Schwartz Values
*recode
clonevar schwartzV1 = ipcrtiv 
clonevar schwartzV2 = imprich
clonevar schwartzV3 = ipeqopt
clonevar schwartzV4 = ipshabt
clonevar schwartzV5 = impsafe
clonevar schwartzV6 = impdiff
clonevar schwartzV7 = ipfrule
clonevar schwartzV8 = ipudrst
clonevar schwartzV9 = ipmodst
clonevar schwartzV10 = ipgdtim
clonevar schwartzV11 = impfree
clonevar schwartzV12 = iphlppl
clonevar schwartzV13 = ipsuces
clonevar schwartzV14 = ipstrgv
clonevar schwartzV15 = ipadvnt
clonevar schwartzV16 = ipbhprp
clonevar schwartzV17 = iprspot
clonevar schwartzV18 = iplylfr
clonevar schwartzV19 = impenv
clonevar schwartzV20 = imptrad
clonevar schwartzV21 = impfun

recode schwartzV1-schwartzV21 ///
	(6=1) (5=2) (4=3) (3=4) (2=5) (1=6)
lab def schwartz ///
	6 "Very much like me" ///
	5 "Like me" ///
	4 "Somewhat like me" ///
	3 "A little like me" ///
	2 "Not like me" ///
	1 "Not like me at all"
lab val schwartz* schwartz

*Missing Values
egen missSchwartzSE = ///
	rowmiss (schwartzV5 schwartzV14)
egen missSchwartzCO = ///
	rowmiss (schwartzV7 schwartzV16)
egen missSchwartzTR =  ///
	rowmiss (schwartzV9 schwartzV20)
egen missSchwartzBE =  ///
	rowmiss (schwartzV12 schwartzV18)
egen missSchwartzUN =  ///
	rowmiss (schwartzV3 schwartzV8 schwartzV19)
egen missSchwartzSD =  ///
	rowmiss (schwartzV1 schwartzV11)
egen missSchwartzST =  ///
	rowmiss (schwartzV6 schwartzV15)
egen missSchwartzHE =  ///
	rowmiss (schwartzV10 schwartzV21)
egen missSchwartzAC =  ///
	rowmiss (schwartzV4 schwartzV13)
egen missSchwartzPO =  ///
	rowmiss (schwartzV2 schwartzV17)
egen missSchwartzALL =  ///
	rowmiss (schwartzV1- schwartzV21)
egen missSchwartzOpenness = ///
	rowmiss(schwartzV1 schwartzV11 schwartzV6 schwartzV15)
egen missSchwartzSelfEnhance = /// 
	rowmiss(schwartzV10 schwartzV21 schwartzV4 schwartzV13 schwartzV2 schwartzV17)
egen missSchwartzConservation = ///
	rowmiss(schwartzV5 schwartzV14 schwartzV7 schwartzV16 schwartzV9 schwartzV20) 
egen missSchwartzSelfTrans = ///
	rowmiss(schwartzV12 schwartzV18 schwartzV3 schwartzV8 schwartzV19)

*Raw Values
egen SchwartzRawSE = rowmean(schwartzV5 schwartzV14) if missSchwartzSE==0
egen SchwartzRawCO = rowmean(schwartzV7 schwartzV16) if missSchwartzCO==0    
egen SchwartzRawTR = rowmean(schwartzV9 schwartzV20) if missSchwartzTR==0 
egen SchwartzRawBE = rowmean(schwartzV12 schwartzV18) if missSchwartzBE==0 
egen SchwartzRawUN = rowmean(schwartzV3 schwartzV8 schwartzV19) if missSchwartzUN==0 
egen SchwartzRawSD = rowmean(schwartzV1 schwartzV11) if missSchwartzSD==0 
egen SchwartzRawST = rowmean(schwartzV6 schwartzV15) if missSchwartzST==0 
egen SchwartzRawHE = rowmean(schwartzV10 schwartzV21) if missSchwartzHE==0 
egen SchwartzRawAC = rowmean(schwartzV4 schwartzV13) if missSchwartzAC==0 
egen SchwartzRawPO = rowmean(schwartzV2 schwartzV17) if missSchwartzPO==0 

*Centered Values
egen MEANcentered = rowmean(schwartzV1- schwartzV21) 
gen SchwartzCenterSE = SchwartzRawSE - MEANcentered if missSchwartzSE==0
gen SchwartzCenterCO = SchwartzRawCO - MEANcentered if missSchwartzCO==0
gen SchwartzCenterTR = SchwartzRawTR - MEANcentered if missSchwartzTR==0
gen SchwartzCenterBE = SchwartzRawBE - MEANcentered if missSchwartzBE==0
gen SchwartzCenterUN = SchwartzRawUN - MEANcentered if missSchwartzUN==0
gen SchwartzCenterSD = SchwartzRawSD - MEANcentered if missSchwartzSD==0
gen SchwartzCenterST = SchwartzRawST - MEANcentered if missSchwartzST==0
gen SchwartzCenterHE = SchwartzRawHE - MEANcentered if missSchwartzHE==0
gen SchwartzCenterAC = SchwartzRawAC - MEANcentered if missSchwartzAC==0
gen SchwartzCenterPO = SchwartzRawPO - MEANcentered if missSchwartzPO==0

*Raw Higher Order
egen SchwartzSelfTrans ///
	= rowmean(schwartzV12 schwartzV18 ///
	schwartzV3 schwartzV8 schwartzV19) ///
	if missSchwartzSelfTrans==0
lab var SchwartzSelfTrans "Self Transcendence"	

egen SchwartzSelfEnhance ///
	= rowmean(schwartzV10 schwartzV21 schwartzV4 ///
	schwartzV13 schwartzV2 schwartzV17) ///
	if missSchwartzSelfEnhance==0
lab var SchwartzSelfEnhance "Self Enhancement"

egen SchwartzOpenness ///
	= rowmean(schwartzV1 schwartzV11 ///
	schwartzV6 schwartzV15) ///
	if missSchwartzOpenness==0
lab var SchwartzOpenness "Openness"
		
egen SchwartzConservation ///
	= rowmean(schwartzV5 schwartzV14 schwartzV7 ///
	schwartzV16 schwartzV9 schwartzV20) ///
	if missSchwartzConservation==0
lab var SchwartzConservation "Conservation"
	
*drop unneeded
drop schwartzV* missSchwartz* SchwartzRaw* MEANcentered

*****************Individual Factors***********
*Social Trust
clonevar socialtrust = ppltrst
la var socialtrust "Individual Social Trust"

*Political Trust
egen misstrust=rowmiss(trstprl trstlgl trstplc trstplt trstprt)
recode misstrust(1/5=1)

factor trstprl trstlgl trstplc trstplt trstprt ///
	if misstrust==0
rotate, oblima f(1)
predict politrust

la var politrust "Political trust, factor"

egen politrustraw=rowmean(trstprl trstlgl trstplc trstplt trstprt) ///
	if misstrust==0

la var politrustraw "Individual Political Trust"
	
*Religion
recode rlgblg ///
	(1=1 "Belong to religious group") ///
	(2=0 "Does not belong"), ///
	gen(belong_religion)
la var belong_religion "Religious Belonging"

recode rlgatnd ///
	(7=1 "Never") ///
	(6=2 "Less often") ///
	(5=3 "Only on holy days") ///
	(4=4 "Monthly") ///
	(3=5 "Weekly") ///
	(2 1 = 6 ">Weekly"), ///
	gen(attend)
la var attend "Religious Service Attendance"

*****************Contextual Factors************
*Country
encode cntry,gen(country)

*Transition State
recode country ///
	(1 2 3 5 7 8 9 ///
	10 12 13 14 15 17 18 20 22= 0 "not Communist") ///
	(4 6 11 16 19 21 23 = 1 "former Communist"), ///
	gen(transition)
la var transition "Transition State"

*Social Trust
bysort country: egen country_socialtrust = mean(socialtrust)

la var country_socialtrust "Country Social Trust"

*Political Trust
bysort country: egen country_politrust = mean(politrust)
bysort country: egen country_politrustraw = mean(politrustraw)

la var country_politrust "Country Political Trust, factor"
la var country_politrustraw "Country Political Trust"

*Domestic economy
recode country ///
	(1=45.360) (2=42.050) (3=81.130) (4=17.960) ///
	(5=43.700) (6=18.670) (7=27.150) (8=44.760) ///
	(9=38.160) (10=40.600)(11=12.920) (12=53.370) ///
	(13=37.440) (14=60.500) (15=31.180) (16=12.430) ///
	(17=46.910) (18=76.160) (19=12.730) (20=19.930) ///
	(21=9.220) (22=52.270) (23=22.030), ///
	gen(gni)
la var gni "GNI per capita, in 1000s"

*Create Egalitarian and Freedom of Expression Index (2016, VDEM, Version 10)
/*note this loads a new file, so run in separate instance of stata
do "Democracy Indeces/Create Democracy variables.do"
*/

*Merge into this file
merge m:1 country ///
using "V-Dem Version 10, to merge.dta", nogenerate 

*Inequality (World bank, 2016) 
recode country ///
	(1=30.8) (2=27.6) (3=33.0) (4=25.4) ///
	(5=31.9) (6=31.2) (7=35.8) (8=27.1) ///
	(9=31.9) (10=34.8) (11=30.3) (12=32.8) ///
	(13=39.0) (14=26.8) (15=35.2) (16=38.4) ///
	(17=28.2) (18=28.5) (19=31.2) (20=35.2) ///
	(21=36.8) (22=29.6) (23=24.8), gen(gini)
la var gini "GINI Index"

*Freedom House Democracy Index (https://freedomhouse.org/sites/default/files/FH_FITW_Report_2016.pdf)
recode country ///
	(1=95) (2=96) (3=96) (4=95) ///
	(5=95) (6=94) (7=95) (8=100) ///
	(9=91) (10=95)(11=79) (12=96) ///
	(13=80) (14=100) (15=89) (16=91) ///
	(17=99) (18=100) (19=93) (20=97) ///
	(21=22) (22=100) (23=92), ///
	gen(democracy)
la var democracy "Democratic Index"

*Renewables as % of Total primary energy supply (2016, IEA) https://www.iea.org/data-and-statistics/data-tables?country=ITALY&energy=Balances&year=2016
recode country ///
	(1=0.323) (2=0.083) (3=0.246) (4=0.111) ///
	(5=0.14) (6=0.173) (7=0.148) (8=0.323) ///
	(9=0.106) (10=0.093) (11=0.126) (12=0.084) ///
	(13=0.024) (14=0.872) (15=0.18) (16=0.21) ///
	(17=0.063) (18=0.521) (19=0.096) (20=0.267) ///
	(21=0.034) (22=0.387) (23=0.172), ///
	gen(renewables)
la var renewables "Renewables as % of TPES"

*Coal as % of Total primary energy supply (2016, IEA) https://www.iea.org/data-and-statistics/data-tables?country=ITALY&energy=Balances&year=2016
recode country ///
	(1=0.091) (2=0.057) (3=0.005) (4=0.399) ///
	(5=0.249) (6=0.715) (7=0.088) (8=0.134) ///
	(9=0.037) (10=0.066) (11=0.086) (12=0.15) ///
	(13=0.24) (14=0.019) (15=0.073) (16=0.026) ///
	(17=0.138) (18=0.028) (19=0.495) (20=0.131) ///
	(21=0.159) (22=0.042) (23=0.169), ///
	gen(coal)
la var coal "coal as % of TPES"	



*****************Sociodemographics*************
*Gender
recode gndr ///
	(1=0 "male") ///
	(2=1 "female"), ///
	gen(female)
	
lab var female "Female"

*Age
_strip_labels age
clonevar age=agea

recode agea ///
	(15/34=1 "<34") ///
	(35/49 = 2 "35-49") ///
	(50/64 = 3 "50-64") ///
	(65/max = 4 "65+"), ///
	gen(agecategories)
lab var age "Age"
	
*Education
recode edulvlb ///
	(0 113 = 1 "Primary or less") ///
	(129 212 213 222 = 2 "Lower secondary") ///
	(229 311 312 313 321 322 323 = 3 "Upper secondary") ///
	(412/510 = 4 "Vocational") ///
	(520 = 5 "Adv. Vocational") ///
	(610 620 = 6 "Bachelors") ///
	(710 720 = 7 "Masters") ///
	(800 = 8 "PhD") ///
	(else = .), ///
	gen(education)

lab var education "Educational Attainment"

*Income
clonevar income=hinctnta 
lab var income "Household income, Country Deciles"







