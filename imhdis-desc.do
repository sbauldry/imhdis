*** Purpose: prepare descriptive statistics
*** Author: S Bauldry
*** Date: July 7, 2017

use imhdis-data, replace

qui tab ori, gen(o)
qui tab wrk, gen(w)
qui tab reg, gen(r)
qui tab com, gen(c)

tab nat
tab ref

foreach x of varlist mod anx srh spd sal sas sai yus nsi ssp se2 o2 o3 o4 ///
  o1 o5 age fem edu w1 w2 w3 inc r1 r2 r3 r4 c1 c2 c3 {
  
  qui sum `x' if nat == 3
  local m1 = r(mean)
  local s1 = r(sd)
  
  qui sum `x' if nat == 2
  local m2 = r(mean)
  local s2 = r(sd)
  
  qui sum `x' if ref == 1
  local m3 = r(mean)
  local s3 = r(sd)
  
  dis "`x': " as res %5.2f `m1' " " as res %5.2f `s1' " " ///
              as res %5.2f `m2' " " as res %5.2f `s2' " " ///
			  as res %5.2f `m3' " " as res %5.2f `s3'
}
