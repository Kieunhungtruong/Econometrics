clear
global link "~" 
/* Điều địa chỉ dẫn đến thư mục làm việc vào ~. 
Ví dụ thư phục làm việc là "C:\Downloads\data_dofile\1.data\chương 6" thì cú pháp là:
global link "C:\Downloads\data_dofile\1.data\chương 6" 

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
/*      Chapter 6                                                 */
/*      File Name:  chapter6.do                                   */  
/*      Date:       October 31, 2024                              */  
/*      Authors:    Nhung                                         */  
/*      Purpose:    Multinominal regression models                */  
/*      Input File:     migration.dta                             */ 
/*                      TableF18-2.csv                            */  
/*      Output File:    chapter6.log                              */  
/******************************************************************/

log using chapter6.log, text replace

**# mô hình MLM 
use "$link\migration.dta",clear

mlogit migration_place gender age HHsize genderhead agehead agehead2 children_ratio elderly_ratio urban ethnicity agrland house_structure,base(0)

mlogit, rrr

margins, at (gender==1 age==22 HHsize==4 genderhead==0 agehead==52 children_ratio==0 elderly_ratio==0.5 urban==1 ethnicity==1 agrland==0 house_structure==1)
margins, at ( gender=1 age=18 HHsize=3 genderhead=0 agehead=60 urban=0 ethnicity=1 agrland=1 house_structure=0)

margins, atmeans

//Tác động biên

quietly mlogit migration_place gender age HHsize genderhead agehead agehead2 children_ratio elderly_ratio urban ethnicity agrland house_structure,base(0)

mfx, predict(p outcome(1)) 

mfx, predict(p outcome(2)) 

mfx, predict(p outcome(3)) 

**# mô hình MPM

mprobit migration_place gender age HHsize genderhead agehead agehead2 children_ratio elderly_ratio urban ethnicity agrland house_structure,base(0)

//Tác động biên

mfx, predict(p outcome(1))

mfx, predict(p outcome(2))

mfx, predict(p outcome(3))

**# Mô hình CLM

clear

import delimited "$link\TableF18-2.csv", delimiter("", collapse) 

gen id = ceil(_n / 4)

gen order = mod(_n-1, 4) + 1

gen air =(order==1)

gen train =(order==2)

gen bus =(order==3)

//CLM 

clogit mode ttme invc invt gc air train bus , group(id)

//CLM với tỷ số odds

clogit mode ttme invc invt gc air train bus , group(id) or

//Dự đoán cho cá nhân

predict predict

list id mode predict in 1/4

//Tác động biên 

asclogit mode ttme invc invt gc, case(id) alternatives(order) basealternative(4) nolog

**# Mô hình MXL

gen airXhinc = air* hinc

gen trainXhinc = train *hinc

gen busXhinc = bus * hinc

gen airXpsize= air* psize

gen trainXpsize= train * psize

gen busXpsize= bus * psize

//MXL

clogit mode ttme invc invt gc air train bus airXhinc trainXhinc busXhinc airXpsize trainXpsize busXpsize , group(id) nolog

///hay

asclogit mode ttme invc invt gc, case(id) alternatives(order) basealternative(4) casevars(hinc psize)  nolog

//MXL với tỷ số odds

clogit mode ttme invc invt gc air train bus airXhinc trainXhinc busXhinc airXpsize trainXpsize busXpsize , group(id) or nolog

///hay

asclogit mode ttme invc invt gc, case(id) alternatives(order) basealternative(4) casevars(hinc psize)  nolog or

log close 
