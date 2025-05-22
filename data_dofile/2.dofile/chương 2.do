clear
global link "~" 
/* Điều địa chỉ dẫn đến thư mục làm việc vào ~. 
Ví dụ thư phục làm việc là "C:\Downloads\data_dofile\1.data\chapter2" thì cú pháp là:
global link "C:\Downloads\data_dofile\1.data\chapter2" 

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
/*      Chapter 2                                                 */
/*      File Name:  chapter2.do                                   */  
/*      Date:       October 31, 2024                              */  
/*      Authors:    Nhung                                         */  
/*      Purpose:    The linear regression model                   */   
/*      Input File:     migration_remittances_16_full             */ 
/*                      migration_remittances_14_full             */ 
/*                      migration_remittances_12_full             */
/*                      panel121416                               */  
/*      Output File:    chapter2.log                              */  
/******************************************************************/ 

log using chapter2.log, text replace

use "$link\migration_remittances_16_full.dta",clear

tabstat per_expenditure remittances , statistics(mean median sd var min max n)

collapse (mean) per_expenditure remittances

gen year =2016

save 2016,replace
use "$link\migration_remittances_14_full.dta",clear

collapse (mean) per_expenditure remittances

gen year =2014

save 2014,replace

use "$link\migration_remittances_12_full.dta",clear

collapse (mean) per_expenditure remittances

gen year = 2012

append using 2014 2016

use "$link\panel121416.dta",clear

use "$link\migration_remittances_16_full.dta",clear

graph twoway (lfitci per_expenditure remittances) (scatter per_expenditure remittances)

graph export Chapter2.6.png, as(png) name("Graph") replace

reg per_expenditure remittances

margins, at ( remittances==60000)

use "$link\migration_remittances_16_full.dta",clear

gen agehead2=agehead^2

gen HHsize2=HHsize^2

reg food_share ln_expenditure agehead agehead2 primary secondary high_school higher_education HHsize HHsize2 dependency_ratio domestic_remittances overseas_remittances urban RedRiverDelta Northmidlandareas MekongRiverDelta Centralhighlands CentralCoast

//or
global xvar "ln_expenditure agehead agehead2 primary secondary high_school higher_education HHsize HHsize2 dependency_ratio domestic_remittances overseas_remittances urban RedRiverDelta Northmidlandareas MekongRiverDelta Centralhighlands CentralCoast"

regress food_share $xvar 

ereturn list

log close
