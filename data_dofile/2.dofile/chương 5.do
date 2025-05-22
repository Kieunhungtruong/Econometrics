clear
global link "C:\Stata\data and dofile\1.data\chương 5" 
/* Điều địa chỉ dẫn đến thư mục làm việc vào ~. 
Ví dụ thư phục làm việc là "C:\Downloads\data_dofile\1.data\chương 5" thì cú pháp là:
global link "C:\Downloads\data_dofile\1.data\chương 5" 

Trong trường hợp không thể tải file về bạn có thể dùng online với cú pháp:
use "https://raw.githubusercontent.com/Kieunhungtruong/Econometrics/main/data_dofile/1.data/[chapter name]/[file name]",clear

   Ví dụ cần file GDP_population.dta.dta trong chương 1:
   use "https://raw.githubusercontent.com/Kieunhungtruong/Econometrics/main/data_dofile/1.data/chapter1/GDP_population.dta", clear

   Đối với các tệp excel, bạn có thể sử dụng các lệnh sau: 
   import excel "https://raw.githubusercontent.com/Kieunhungtruong/Econometrics/main/data_dofile/1.data/chapter5/sales.xlsx", sheet("car") firstrow
*/
capture log close
set more off
/******************************************************************/  
/*      Chapter 5                                                 */
/*      File Name:  chapter5.do                                   */  
/*      Date:       October 31, 2024                              */  
/*      Authors:    Nhung                                         */  
/*      Purpose:    Qualitative variables                         */  
/*      Input File:     GDP_population.dta                        */
/*                      wage2020.dta                              */  
/*                      disaster.dta                              */
/*                      GCF_GS.dta                                */
/*                      GDP_unemploymentrate                      */
/*                      sales.xlsx                                */
/*                      migration_remittances_16_full.dta         */   
/*      Output File:    chapter5.log                              */  
/******************************************************************/ 

log using chapter5.log, text replace

use "$link\wage2020.dta", clear

reg wage yearsofexperience gender

use "$link\GDP_population.dta",clear

xtile quartile = PCI , nq(4)

gen topPCI =(quartile==4)

//gen topPCI = 1 if quartile==4
//replace  topPCI = 0 if topPCI==.

reg GDP topPCI population

use "$link\wage2020.dta", clear

gen sector1 = (sector==1)

gen sector2 = (sector==2)

gen sector3 = (sector==3)

gen sector4 = (sector==4)

gen sector5 = (sector==5)

gen sector0 = (sector==0)

reg wage yearsofexperience sector1 sector2 sector3 sector4 sector5 

save wage2020.dta, replace

use "$link\GDP_population.dta",clear

xtile quartile = PCI , nq(4)

gen topPCI =(quartile==4)

gen RedRiverDelta= (region == 1)

gen Northmidlandareas= (region == 2)

gen CentralCoast= (region == 3)

gen Centralhighlands= (region == 4)

gen MekongRiverDelta= (region == 5)

reg GDP topPCI population RedRiverDelta Northmidlandareas CentralCoast Centralhighlands MekongRiverDelta

save GDP_population.dta, replace

use wage2020, clear

reg wage yearsofexperience sector

//Bỏ hệ số chặn

reg wage yearsofexperience sector0 sector1 sector2 sector3 sector4 sector5, noconst

**# Biến tương tác

reg wage yearsofexperience gender i.gender#c.yearsofexperience  sector1 sector2 sector3 sector4 sector5 i.sector1#c.yearsofexperience i.sector2#c.yearsofexperience i.sector3#c.yearsofexperience i.sector4#c.yearsofexperience i.sector5#c.yearsofexperience 

reg wage gender

reg ln_wage gender

use GDP_population.dta,clear

gen ln_GDP=ln(GDP)

reg ln_GDP topPCI population RedRiverDelta Northmidlandareas CentralCoast Centralhighlands MekongRiverDelta

use "$link\disaster.dta" ,clear

sum healthcare_child HHsize agechild genderchild agehead genderhead num_eduhead jobhead land storm flood 

reg healthcare_child HHsize agechild genderchild agehead genderhead num_eduhead jobhead land storm flood

reg ln_healthcare_child HHsize agechild genderchild agehead genderhead num_eduhead jobhead land storm flood

use "$link\GCF_GS.dta",clear

reg GCF GS

gen COVID19=(year>2019)

reg GCF GS COVID19

gen GSXCOVID19= GS*COVID19

reg GCF GS COVID19 GSXCOVID19

use "$link\GDP_unemploymentrate.dta",clear

reg GDP unemploymentrate 

reg GDP unemploymentrate COVID19

clear

import excel "$link\sales.xlsx", sheet("car") firstrow

gen D2=(quarter==2) 

gen D3=(quarter==3) 

gen D4=(quarter==4)
 
reg sales D2 D3 D4

predict sales_predict

predict r,r 

sum sales_predict, detail

gen sales_adj = r(mean) + r

gen qdate = yq(year, quarter) 

format qdate %tq

line sales_adj sales qdate 

graph export Chapter5.9.png, as(png) name("Graph") replace

**# Hồi quy tuyến tính Piecewise

use "$link\migration_remittances_16_full.dta",clear

twoway (scatter ln_per_expenditure agehead) (lfit ln_per_expenditure agehead) (qfit ln_per_expenditure agehead)

graph export Chapter5.9.1.png, as(png) name("Graph") replace

mkspline age0 2 = agehead , displayknots

reg ln_per_expenditure agehead if agehead <59

reg ln_per_expenditure agehead if agehead >=59

//Hồi quy tính đến hệ số chặn

gen age1 = (agehead - 59)

replace age1 = 0 if agehead >= 59

gen age2 = ( agehead - 59) 

replace  age2 = 0 if agehead < 59

gen int1 = 1

replace  int1 = 0 if agehead >= 59

gen int2 = 1

replace  int2 = 0 if agehead < 59

reg ln_per_expenditure age1 if agehead <59

di "y = " _b[_cons] " + " _b[age1] " * age1"

reg ln_per_expenditure age2 if agehead >=59

di "y = " _b[_cons] " + " _b[age2] " * age2"

regress ln_per_expenditure int1 int2 age1 age2 ,hascons

predict yhat

twoway (scatter ln_per_expenditure agehead )(line yhat agehead if agehead <59) (line yhat agehead if agehead >=59)

graph export Chapter5.9.2.png, as(png) name("Graph") replace

use "$link\disaster.dta",clear

mkspline land0 2 = land , displayknots

gen land1 = (land - 205)

replace land1 = 0 if land >= 205

gen land2 = ( land - 205) 

replace  land2 = 0 if land < 205

gen int1 = 1

replace  int1 = 0 if land >= 205

gen int2 = 1

replace  int2 = 0 if land < 205

reg ln_healthcare_child land1 if land <205

di "y = " _b[_cons] " + " _b[land1] " * land1"

reg ln_healthcare_child land2 if land >=205

di "y = " _b[_cons] " + " _b[land2] " * land2"

regress ln_healthcare_child int1 int2 land1 land2 ,hascons

predict yhat

twoway (scatter ln_healthcare_child land)(line yhat land if land <205) (line yhat land if land >=205)

graph export Chapter5.9.3.png, as(png) name("Graph") replace

log close 
