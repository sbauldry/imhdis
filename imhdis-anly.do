*** Purpose: to fit SEMs for main analysis
*** Author: S Bauldry
*** Date: July 7, 2017

use imhdis-data, replace
svyset psu, weight(wgt)

qui tab ori, gen(o)
qui tab wrk, gen(w)
qui tab reg, gen(r)
qui tab com, gen(c)

*** model for 1st generation immigrants
eststo clear

local exg sal sas sai o2 o3 o4 o5 age fem r2 r3 r4 c2 c3 w2 w3 edu inc
svy: sem (`exg' -> se2) (`exg' se2 -> pdh pdg) (`exg' se2 pdh pdg -> ssp) ///
	     (`exg' se2 pdh pdg ssp -> phl mhl) if nat == 3,                  ///
		 cov(e.pdh*e.pdg e.phl*e.mhl)
estat eqgof
estat teffects
eststo m1

*** model for refugees
local exg sal sas sai o2 o3 o4 o5 age fem r2 r3 r4 c2 c3 w2 w3 edu inc
svy: sem (`exg' -> se2) (`exg' se2 -> pdh pdg) (`exg' se2 pdh pdg -> ssp) ///
	     (`exg' se2 pdh pdg ssp -> phl mhl) if ref == 1,                  ///
		 cov(e.pdh*e.pdg e.phl*e.mhl)
estat eqgof
estat teffects
eststo m2

esttab m1 m2 using temp1.csv, b(%5.2f) se(%5.2f) star wide
