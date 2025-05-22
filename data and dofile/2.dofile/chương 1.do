clear
global link "~" 
/* Điều địa chỉ dẫn đến thư mục làm việc vào ~. 
Ví dụ thư phục làm việc là "C:\Downloads\data and dofile\1.data\chapter1" thì cú pháp là:
global link "C:\Downloads\data and dofile\1.data\chapter1" 
*/
capture log close
set more off
/******************************************************************/  
/*      Chapter 1                                                 */
/*      File Name:  chương 1.do                                   */  
/*      Date:       October 31, 2024                              */  
/*      Authors:    Nhung                                         */  
/*      Purpose:    An Introduction to Econometrics               */  
/*      Input File:     migration_remittances_16_full             */
/*                      GDP_population.dta                        */
/*                      wage2020.dta                              */
/*                      grade.dta                                 */
/*                      remittances_adolescents1.dta              */
/*      Output File:    chuong1.log                               */  
/******************************************************************/ 
log using chuong1.log, text replace

use "$link\migration_remittances_16_full.dta",clear

list per_expenditure remittances in 1/20

sum per_expenditure, detail

histogram per_expenditure,bin (27)

graph export Chapter1.1.png, as(png) name("Graph") replace

mean per_expenditure

sort per_expenditure

centile per_expenditure, centile(50)

tabstat per_expenditure , statistics(sd variance) 

centile per_expenditure , centile(25)

centile per_expenditure , centile(75)

use "$link\GDP_population.dta",clear

graph hbox PCI

graph export Chapter1.3.png, as(png) name("Graph") replace

use "$link\wage2020.dta",clear

histogram wage, frequency 

graph export Chapter1.4a.png, as(png) name("Graph") replace

use "$link\grade.dta",clear

graph bar Sốlượng, over(Điểm)

graph export Chapter1.4b.png, as(png) name("Graph") replace

use "$link\remittances_adolescents1.dta",clear

histogram num_edu_adolescents , discrete frequency 

graph export Chapter1.4c.png, as(png) name("Graph") replace

sum num_edu_adolescents,detail

use "$link\migration_remittances_16_full.dta",clear

summarize per_expenditure, detail

local q1 = r(p25)

display `q1' 

local q3 = r(p75)

display `q3' 

local iqr = `q3' - `q1'

display `iqr'

graph hbox per_expenditure

graph export Chapter1.5.png, as(png) name("Graph") replace

gen outlier_per_expenditure = 0

replace outlier_per_expenditure = 1 if per_expenditure >= 58673 

scatter per_expenditure remittances

graph export Chapter1.6.png, as(png) name("Graph") replace

correlate per_expenditure remittances, covariance 

matrix list r(C), format(%14.2f)

correlate per_expenditure remittances 

log close
