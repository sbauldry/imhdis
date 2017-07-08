*** Purpose: to fit SEMs for main analysis
*** Author: S Bauldry
*** Date: July 7, 2017

use imhdis-data, replace

qui tab ori, gen(o)
qui tab wrk, gen(w)
qui tab reg, gen(r)
qui tab com, gen(c)

*** model for 1st generation immigrants
eststo clear

local exg o2 o3 o4 o5 age fem r2 r3 r4 c2 c3 w2 w3 edu inc
sem (`exg' -> sal sas sai yus) ///
    (`exg' sal sas sai yus -> se2) ///
	(`exg' sal sas sai yus se2 -> spd) ///
	(`exg' sal sas sai yus se2 spd -> ssp nsi) ///
	(`exg' sal sas sai yus se2 spd ssp nsi -> mod anx srh) if nat == 3
estat eqgof
eststo m1


*** model for 2nd generation immigrants
local exg o2 o3 o4 o5 age fem r2 r3 r4 c2 c3 w2 w3 edu inc
sem (`exg' -> sal sas sai) ///
    (`exg' sal sas sai -> se2) ///
	(`exg' sal sas sai se2 -> spd) ///
	(`exg' sal sas sai se2 spd -> ssp nsi) ///
	(`exg' sal sas sai se2 spd ssp nsi -> mod anx srh) if nat == 2
estat eqgof
eststo m2


*** model for refugees
local exg o2 o3 o4 o5 age fem r2 r3 r4 c2 c3 w2 w3 edu inc
sem (`exg' -> sal sas sai) ///
    (`exg' sal sas sai -> se2) ///
	(`exg' sal sas sai se2 -> spd) ///
	(`exg' sal sas sai se2 spd -> ssp nsi) ///
	(`exg' sal sas sai se2 spd ssp nsi -> mod anx srh) if ref == 1
estat eqgof
eststo m3

esttab m1 m2 m3 using temp1.csv, b(%5.2f) se(%5.2f) star wide
