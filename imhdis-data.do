*** Purpose: prepare NESARC data for analysis
*** Author: S Bauldry
*** Date: July 6, 2017

*** extracting wave 1 variables
use IDNUM S1Q1F ETHRACE2A S1Q1E SEX MARITAL CHLD0_17 S1Q6A S1Q7A1 S1Q7A2 ///
  S1Q12B S1Q14C* REGION CCS S1Q233-S1Q2312 ///
  using "~/dropbox/research/data/nesarc/stata/NESARC Wave 1 Data", replace
  
tempfile d1
save `d1', replace


*** extracting wave 2 variables
use IDNUM DEP12ROBSI DYSROSI12 HYPO12 W2PANDX12 PANADX12 AGORADX12 SOCDX12 ///
  SPEC12 GENDX12 W2S1Q25 W2S12Q4A W2S1Q2BR W2S1Q2AR W2S1Q2C W2S2DQ1*       ///
  W2S2DQ6* W2S2DQ8* W2S2DQ2* W2S2DQ9* W2S2DQ3A* W2S2DQ10A* W2AGE W2WEIGHT  ///
  W2PSU W2STRATUM W2S1Q2D W2S1Q2E W2S2DQ27* W2S2DQ17B W2S2DQ18B W2S2DQ19B  ///
  W2S2DQ20B W2S2DQ21B W2S2DQ22B W2S2DQ23 W2S2DQ24 W2S2DQ25B W2S2DQ26C      ///
  W2S1Q37C W2MARITAL W2S1Q361-W2S1Q3614 W2S12Q5A21 W2S12Q5B21 W2NBPCS      ///
  W2NBMCS using "~/dropbox/research/data/nesarc/stata/NESARC Wave 2 Data", ///
  replace

*** merging two waves
merge 1:1 IDNUM using `d1'
keep if _merge == 3
drop _merge
  
rename _all, lower
recode s1q1f (9 = .)
recode s1q1e (98 99 = .)
recode w2s1q25 w2s1q2br w2s2dq1* w2s2dq6* w2s2dq8* w2s2dq2* w2s2dq9* ///
  w2s2dq3a* w2s2dq10a* w2s2dq27* w2s12q4a s1q233-s1q2312 w2s1q361-w2s1q3614 ///
  w2s12q5a21 (9 = .)
recode w2s1q2ar w2s1q2c w2s2dq17b w2s2dq20b w2s2dq21b w2s2dq22b w2s2dq23 ///
  w2s2dq24 w2s2dq25b w2s2dq26c w2s12q5b21 w2nbpcs w2nbmcs (99 = .)
recode w2s1q2d w2s1q2e (999 = .)
recode w2s1q37c (. = 2) (999 = .)


*** preparing variables for analysis
* mood/anxiety disorder in past year, self-rated health
gen mod = ( dep12robsi == 1 | dysrosi12 == 1 | hypo12 == 1 )
gen anx = ( w2pandx12 == 1 | panadx12 == 1 | agoradx12 == 1 | socdx12 == 1 | ///
            spec12 == 1 | gendx12 == 1 )
gen srh = 6 - w2s1q25
rename (w2nbpcs w2nbmcs) (phl mhl)
lab var mod "w2 mood disorder past year"
lab var anx "w2 anxiety disorder past year"
lab var srh "w2 self-rated health"
lab var phl "w2 physical health SF12-2"
lab var mhl "w2 mental health SF12-2"

* refugee, nativity, and origin
gen ref = (w2s12q4a == 1) if !mi(w2s12q4a)

gen mnat = (w2s1q2d == 10) if !mi(w2s1q2d)
gen fnat = (w2s1q2e == 10) if !mi(w2s1q2e)

gen     nat = 3 if s1q1f != 1 & !mi(s1q1f)
replace nat = 3 if w2s1q2br != 1 & mi(nat)
replace nat = 2 if ( mnat != 1 | fnat != 1 ) & mi(nat)
replace nat = 1 if s1q1f == 1 & mi(nat)
replace nat = 1 if w2s1q2br == 1 & mi(nat)
lab def nt 1 "born in US" 2 "2nd gen immigrant" 3 "1st gen immigrant"
lab val nat nt
lab var nat "w1 nativity status"

rename s1q1e origin
replace origin = w2s1q2ar if mi(origin)
recode origin (5 6 12/15 17/20 22 27 29 37 38 40 41 44/46 50 51 55 58 = 1) ///
              (1 2 54 = 2) (10 16 21 23 24 30 32 34 42 47 49 52 57 = 3) ///
              (9 35 36 8 11 39 43 53 = 4) (3 4 7 25 26 28 31 33 48 56 98 = 7), ///
			  gen(ori)
replace ori = 1 if ethrace2a == 1 & mi(ori)
replace ori = 2 if ethrace2a == 2 & mi(ori)
replace ori = 7 if ethrace2a == 3 & mi(ori)
replace ori = 3 if ethrace2a == 4 & mi(ori)
lab def or 1 "Eu" 2 "Af" 3 "As" 4 "Hi" 7 "Ot"
lab val ori or
lab var ori "w1 national origin"

* acculturation indicators
gen yus = w2s1q2c
lab var yus "w2 years in US"

foreach x in a b c d e f g h i j k {
	replace w2s2dq1`x' = w2s2dq6`x' if mi(w2s2dq1`x')
	replace w2s2dq1`x' = w2s2dq8`x' if mi(w2s2dq1`x')
}
rename (w2s2dq1a w2s2dq1b w2s2dq1c w2s2dq1d w2s2dq1e w2s2dq1f w2s2dq1g    ///
        w2s2dq1h w2s2dq1i w2s2dq1j w2s2dq1k) (al1 al2 al3 al4 al5 al6 al7 ///
		as1 as2 as3 as4)

foreach x in a b c d e f g h {
	replace w2s2dq2`x' = w2s2dq9`x' if mi(w2s2dq2`x')
}
rename (w2s2dq2a w2s2dq2b w2s2dq2c w2s2dq2d w2s2dq2e w2s2dq2f w2s2dq2g ///
        w2s2dq2h) (ai1 ai2 ai3 ai4 ai5 ai6 ai7 ai8)

alpha al* if nat > 1, gen(sal)
alpha as* if nat > 1, gen(sas)
alpha ai* if nat > 1, gen(sai)
lab var sal "w2 acculturation language scale (a = 0.96)"
lab var sas "w2 acculturation social preferences scale (a = 0.85)"
lab var sai "w2 acculturation identity scale (a = 0.87)"

* perceived discrimination indicators
forval i = 1/6 {
	replace w2s2dq3a`i' = w2s2dq10a`i' if mi(w2s2dq3a`i') 
}
rename (w2s2dq3a*) (pd1 pd2 pd3 pd4 pd5 pd6)

alpha pd1 pd2, gen(pdh)
alpha pd3 pd4 pd5 pd6, gen(pdg)
lab var pd1 "w2 discrimination in health care or insurance"
lab var pd2 "w2 discrimination in received care"
lab var pd3 "w2 discrimination in public"
lab var pd4 "w2 discrimination in any situation"
lab var pd5 "w2 called a racist name"
lab var pd6 "w2 made fun of"
lab var pdh "w2 perceived discrimination health care (a = 0.75)"
lab var pdg "w2 perceived discrimination general (a = 0.73)"

* social support 
recode w2s2dq27a w2s2dq27b w2s2dq27g w2s2dq27h w2s2dq27k w2s2dq27l (4 = 1) ///
       (3 = 2) (2 = 3) (1 = 4)
alpha w2s2dq27a-w2s2dq27l, gen(ssp)
lab var ssp "w2 social support scale (a = .83)"

* stressful life events
recode s1q233-s1q2312 w2s1q361-w2s1q3614 w2s12q5a21 (2 = 0)
egen se1 = rowtotal(s1q233-s1q2312)

gen tpol = ( w2s1q369 == 1 | w2s1q3614 == 1 )
gen tvic = ( w2s1q3610 == 1 | w2s1q3611 == 1 )
gen agei = w2age - w2s12q5b21
replace w2s12q5a21 = 0 if agei > 1
egen se2 = rowtotal(w2s1q361-w2s1q369 w2s1q3612 w2s12q5a21 tpol tvic)

lab var se1 "w1 stressful life events"
lab var se2 "w2 stressful life events"
	
* sociodemographics
rename w2age age
lab var age "w2 age"

gen fem = (sex == 2)
lab var fem "w1 female"

recode s1q6a (8 = 9) (9 = 8), gen(edu)
lab var edu "w1 highest grade completed"

gen wrk     = 3 if s1q7a1 == 1
replace wrk = 2 if s1q7a2 == 1 & mi(wrk)
replace wrk = 1 if mi(wrk)
lab def wk 1 "NW" 2 "PT" 3 "FT", replace
lab val wrk wk
lab var wrk "w1 work status"

recode s1q12b (1 = .25) (2 = .65) (3 = .9) (4 = 1.15) (5 = 1.4) ///
			  (6 = 1.75) (7 = 2.25) (8 = 2.75) (9 = 3.25) (10 = 3.75) ///
			  (11 = 4.5) (12 = 5.5) (13 = 6.5) (14 = 7.5) (15 = 8.5) ///
			  (16 = 9.5) (17 = 10.5) (18 = 11.5) (19 = 13.5) (20 = 17.5) ///
			  (21 = 31.6345), gen(inc)
lab var inc "w1 household income"

rename (region ccs) (reg com)
lab def rg 1 "NE" 2 "M" 3 "S" 4 "W", replace
lab val reg rg
lab var reg "w1 region"

lab def ct 1 "center" 2 "not center" 3 "not MSA", replace
lab val com ct
lab var com "w1 community type"

* complex sample variables
rename (w2weight w2psu) (wgt psu)

*** saving analysis variables and sample
order idnum nat ref phl mhl srh pdh pdg ssp sal sas sai se2 ori age fem edu ///
  wrk inc reg com wgt psu 
keep idnum-psu

* just keep immigrants and refugees
keep if nat > 1 | ref == 1

* drop 111 cases missing outcome variables (1%)
keep if !mi(phl, pdh)

* drop 64 cases missing covariates (<1%)
keep if !mi(pdg, ssp, sal, sas, sai, ori)

save imhdis-data, replace
