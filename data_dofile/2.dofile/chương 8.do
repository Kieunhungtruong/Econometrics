clear
global link "~" 
/* Điều địa chỉ dẫn đến thư mục làm việc vào ~. 
Ví dụ thư phục làm việc là "C:\Downloads\data_dofile\1.data\chương 8" thì cú pháp là:
global link "C:\Downloads\data_dofile\1.data\chương 8" 

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
/*      Chapter 8                                                 */
/*      File Name:  chapter8.do                                   */  
/*      Date:       October 31, 2024                              */  
/*      Authors:    Nhung                                         */  
/*      Purpose:    Modeling count data                           */  
/*      Input File:     remittances_adolescents.dta               */  
/*      Output File:    chapter8.log                              */  
/******************************************************************/ 

log using chapter8.log, text replace

use "$link\remittances_adolescents.dta",clear

gen overseas_adolescent_gender=overseas_remittances*adolescent_gender

gen domestic_adolescent_gender=domestic_remittances*adolescent_gender

global xvarpoisson "adolescent6_18_ratio adolescent0_15_ratio HHsize overseas_remittances domestic_remittances overseas_adolescent_gender  domestic_adolescent_gender crop_land"

regress outpatient $xvarpoisson

histogram outpatient, discrete frequency
 
graph export Chapter8.png, as(png) name("Graph") replace

sum outpatient,detail

jb outpatient

**# Mô hình hồi quy Poisson

poisson outpatient $xvarpoisson, nolog

mfx

poisson outpatient $xvarpoisson, irr nolog

**# Những hạn chế của mô hình hồi quy Poisson

quietly poisson outpatient $xvarpoisson

predict yhat

gen yhat2 = yhat^2

gen e =outpatient - yhat

gen e2 =e^2

gen diff = e2 - outpatient 

reg diff yhat2,nocons

**# Mô hình hồi quy nhị phân âm

nbreg outpatient $xvarpoisson, nolog

mfx

nbreg,irr

**# Kiểm định sự phù hợp 2 mô hình
quietly poisson outpatient $xvarpoisson, nolog

est sto poisson

quietly nbreg outpatient $xvarpoisson, nolog

est sto nbreg

lrtest nbreg poisson,force

log close