clear
global link "~" 
/* Điều địa chỉ dẫn đến thư mục làm việc vào ~. 
Ví dụ thư phục làm việc là "C:\Downloads\data and dofile\1.data\chương 7" thì cú pháp là:
global link "C:\Downloads\data and dofile\1.data\chương 7" 
*/
capture log close
set more off
/******************************************************************/  
/*      Chapter 8                                                 */
/*      File Name:  chương 8.do                                   */  
/*      Date:       October 31, 2024                              */  
/*      Authors:    Nhung                                         */  
/*      Purpose:    Modeling count data                           */  
/*      Input File:     remittances_adolescents.dta               */  
/*      Output File:    chuong8.log                               */  
/******************************************************************/ 

log using chuong8.log, text replace

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