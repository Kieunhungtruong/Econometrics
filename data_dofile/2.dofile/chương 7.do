clear
global link "~" 
/* Điều địa chỉ dẫn đến thư mục làm việc vào ~. 
Ví dụ thư phục làm việc là "C:\Downloads\data_dofile\1.data\chương 7" thì cú pháp là:
global link "C:\Downloads\data_dofile\1.data\chương 7" 

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
/*      Chapter 7                                                 */
/*      File Name:  chapter7.do                                   */  
/*      Date:       October 31, 2024                              */  
/*      Authors:    Nhung                                         */  
/*      Purpose:    Panel data                                    */  
/*      Input File:     panel121416                               */  
/*      Output File:    chapter7.log                              */  
/******************************************************************/ 

log using chapter7.log, text replace

use "$link\panel121416.dta",clear

global xvarpanel "HHsize agehead children_ratio elderly_ratio genderhead female_ratio agehead2 num_eduhead migration"

**# Mô hình Pooled OLS

reg ln_per_expenditure $xvarpanel

**# Mô hình Pooled OLS với biến giả năm

gen _2012 =(year==2012)

gen _2014 =(year==2014)

reg ln_per_expenditure $xvarpanel _2012 _2014

**# Mô hình FEM

xtset hhid year

xtreg ln_per_expenditure $xvarpanel, fe

xtreg ln_per_expenditure $xvarpanel, fe robust

**# Mô hình REM

xtreg ln_per_expenditure $xvarpanel

xtreg ln_per_expenditure $xvarpanel, robust

**# Sự phù hợp của mô hình FEM và REM

quietly xtreg ln_per_expenditure $xvarpanel

xttest0

quietly xtreg ln_per_expenditure $xvarpanel ,fe

est store FEM

quietly xtreg ln_per_expenditure $xvarpanel

est store REM

hausman FEM REM

log close