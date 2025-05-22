clear
global link "~" 
/* Điều địa chỉ dẫn đến thư mục làm việc vào ~. 
Ví dụ thư phục làm việc là "C:\Downloads\data and dofile\1.data\chapter4" thì cú pháp là:
global link "C:\Downloads\data and dofile\1.data\chapter4" 
*/
capture log close
set more off
/******************************************************************/  
/*      Chapter 4                                                 */
/*      File Name:  chapter4.do                                   */  
/*      Date:       October 31, 2024                              */  
/*      Authors:    Nhung                                         */  
/*      Purpose:    Regression specification                      */  
/*      Input File:     migration_remittances_16_full.dta         */
/*                      wage2020.dta                              */
/*                      rotations_ accidents2022.dta              */
/*                      _migration_remittances_16_full.dta        */ 
/*                      GCF_FCE.dta                               */
/*                      working_children.dta                      */  
/*      Output File:    chapter4.log                               */  
/******************************************************************/ 

log using chapter4.log, text replace

use "$link\migration_remittances_16_full.dta",clear

gen agehead2 = agehead^2

global xvarfull1 "remittances HHsize children15 elderly60 female_ratio genderhead agehead agehead2 num_eduhead"

reg per_expenditure $xvarfull1

test HHsize=children15=elderly60=female_ratio=genderhead=agehead=agehead2=num_eduhead=0

use "$link\wage2020.dta", clear

gen yearsofexperience2 = yearsofexperience^2

gen experienceXgender=yearsofexperience*gender

global xvarfull3 "urban gender yearsofedu yearsofexperience yearsofexperience2 experienceXgender RedRiverDelta Northmidlandareas CentralCoast Centralhighlands MekongRiverDelta"

reg wage $xvarfull3

test yearsofexperience2=experienceXgender=RedRiverDelta=Northmidlandareas=CentralCoast=Centralhighlands=MekongRiverDelta=0

**# Kiểm định RESET (Ramsey's Regression Specification Error)

quietly reg wage urban gender yearsofedu yearsofexperience

//Bước 1: Tạo biến yhat là giá trị dự báo của biến giải thích
predict yhat

//Bước 2: Tạo hai biến là yhat2 là bình phương của yhat và yhat3 là lập phương của yhat. Sau đó hồi quy các biến yhat, yhat2 và yhat3 với mô hình ban đầu.

gen yhat2 = yhat^2

gen yhat3 = yhat^3

reg  wage urban gender yearsofedu yearsofexperience yhat2 yhat3

test yhat2 yhat3

sum wage urban gender yearsofedu yearsofexperience

gen wage_million = wage/1000

quietly reg wage_million urban gender yearsofedu yearsofexperience

predict yhat_million

gen yhat2_million = yhat_million^2

gen yhat3_million = yhat_million^3

reg  wage_million urban gender yearsofedu yearsofexperience yhat2_million yhat3_million

test yhat2_million yhat3_million

quietly reg wage_million urban gender yearsofedu yearsofexperience

ovtest

**# Kiểm định LM (Lagrange Multiplier)

//Bước 1: Tạo biến r là phần dư e

quietly reg wage urban gender yearsofedu yearsofexperience
predict r, residual 

//Bước 2: Hồi quy phần dư với toàn bộ các biến giải thích trong mô hình gốc và các biến bị bỏ sót

quietly reg r $xvarfull3 

display e(N)*e(r2)

display invchi2tail(2, 0.001)

display chi2tail(2, e(N)*e(r2))

**# Loại bỏ biến không liên quan (ngưỡng có mức ý nghĩa 90%)

use "$link\migration_remittances_16_full.dta",clear

gen agehead2=agehead^2

gen HHsize2=HHsize^2

regress food_share ln_expenditure agehead agehead2 HHsize HHsize2 dependency_ratio urban Northmidlandareas MekongRiverDelta Centralhighlands

use "$link\wage2020.dta", clear

reg yearsofexperience age,beta

**# Mô hình sử dụng dạng hàm không phù hợp
// Hồi quy ví dụ về chi tiêu

use "$link\migration_remittances_16_full.dta",clear

gen agehead2 = agehead^2

global xvarfull1 "remittances HHsize children15 elderly60 female_ratio genderhead agehead agehead2 num_eduhead"

sum per_expenditure $xvarfull1

reg ln_per_expenditure ln_remittances HHsize children15 elderly60 female_ratio genderhead agehead agehead2 num_eduhead

//Bước 1

quietly sum ln_per_expenditure

local gmean = exp(r(mean))     

display "Geometric mean: `gmean'"

//Bước 2

gen per_expenditure_g= per_expenditure/exp(r(mean))

gen lnper_expenditure_g=ln(per_expenditure_g)

//Bước 3

quietly reg per_expenditure_g $xvarfull1

scalar RSS1=e(rss)

di RSS1

//Bước 4

quietly reg lnper_expenditure_g ln_remittances HHsize children15 elderly60 female_ratio genderhead agehead agehead2 num_eduhead

scalar RSS2 =e(rss)

scalar N =e(N)

di RSS2

//Bước 5

scalar test=(e(N)/2)*log(RSS1/RSS2)

di test 

scalar pvalue=chi2tail(1,test)

di pvalue


**# Hồi quy ví dụ về mức lương
use "$link\wage2020.dta", clear

gen yearsofexperience2 = yearsofexperience^2

gen experienceXgender=yearsofexperience*gender

global xvarfull3 "urban gender yearsofedu yearsofexperience yearsofexperience2 experienceXgender RedRiverDelta Northmidlandareas CentralCoast Centralhighlands MekongRiverDelta"

reg ln_wage $xvarfull3 

//Bước 1

quietly sum ln_wage

local gmean = exp(r(mean))      

display "Geometric mean: `gmean'"

//Bước 2

gen wage_g= wage/exp(r(mean))

gen lnwage_g=ln(wage_g)

//Bước 3

quietly reg wage_g $xvarfull3

scalar RSS1=e(rss)

di RSS1

//Bước 4

quietly reg lnwage_g $xvarfull3

scalar RSS2 =e(rss)

scalar N =e(N)

di RSS2

//Bước 5

scalar test=(e(N)/2)*log(RSS1/RSS2)

di test 

scalar pvalue=chi2tail(1,test)

di pvalue

**# Quan sát có giá trị bất thường

use "$link\rotations_accidents2022.dta" , clear

reg traffic_accidents rotations

gen idprovince = _n

predict r,residual 

gen r2=r^2

line r2 idprovince

graph export Chapter4.5.1.png , as(png) name("Graph") replace

tempfile tmpdata

save `tmpdata'

drop if idprovince==50

reg traffic_accidents rotations

use `tmpdata', clear

rreg traffic_accidents rotations

quietly reg traffic_accidents rotations

lvr2plot

graph export Chapter4.5.2.png, as(png) name("Graph") replace

use "$link\migration_remittances_16_full.dta",clear

gen agehead2 = agehead^2

drop if ln_remittances==.

// Danh sách các biến cần kiểm tra outliers

local vars ln_per_expenditure ln_remittances  

foreach var in `vars' {
    * Tính mean và SD của biến
	sum `var',detail
    local mean = r(mean)
    local sd = r(sd)
    
    * Xác định ngưỡng outliers
    local lower = `mean' - 3*`sd'
    local upper = `mean' + 3*`sd'
    
    * Tạo biến chỉ báo outliers (1 nếu là outlier, 0 nếu không)
    gen outlier_`var' = (`var' < `lower' | `var' > `upper') 
}

reg ln_per_expenditure ln_remittances HHsize children15 elderly60 female_ratio genderhead agehead agehead2 num_eduhead outlier_ln_per_expenditure outlier_ln_remittances

// Cách xử lý của  Battese (1997) trong một số trường hợp
use "$link\migration_remittances_16_full.dta",clear

gen agehead2 = agehead^2

gen remittances_1 = remittances 

replace remittances_1 = 1 if remittances_1 == 0

gen ln_remittances_1 = ln( remittances_1)

gen not_remittances=(remittances_1==1)

local vars remittances per_expenditure

foreach var of local vars {
    * Tính Q1, Q3 và IQR cho biến `var`
    quietly summarize `var', detail
    scalar Q1 = r(p25)
    scalar Q3 = r(p75)
    scalar IQR = Q3 - Q1

    * Tính giới hạn dưới và trên
    scalar lower_limit = Q1 - 1.5 * IQR
    scalar upper_limit = Q3 + 1.5 * IQR

    * Tạo biến đánh dấu outliers cho biến `var`
    gen outlier_`var' = 0
    replace outlier_`var' = 1 if `var' < lower_limit | `var' > upper_limit
}

reg ln_per_expenditure ln_remittances_1 not_remittances HHsize children15 elderly60 female_ratio genderhead agehead agehead2 num_eduhead outlier_per_expenditure outlier_remittances

save _migration_remittances_16_full.dta, replace

**# Kiểm định JB (Jarque-Bera)

use "$link\rotations_accidents2022.dta" , clear

quietly reg traffic_accidents rotations

predict r, residual

sum r, detail

// Cài đặt gói jb: ssc install jb

jb r

use "$link\rotations_accidents2022.dta" , clear

gen idprovince = _n

drop if idprovince==50

quietly reg traffic_accidents rotations

predict r, residual

sum r, detail

jb r

use _migration_remittances_16_full.dta,clear

quietly reg ln_per_expenditure ln_remittances_1 not_remittances HHsize children15 elderly60 female_ratio genderhead agehead agehead2 num_eduhead outlier_per_expenditure outlier_remittances

predict r , residual

sum r, detail

histogram r, normal

graph export Chapter4.6.png , as(png) name("Graph") replace

jb r

display invchi2tail(2, 0.05)

**# Phương pháp bình phương tối thiểu gián tiếp (ILS)

use "$link\GCF_FCE.dta",clear

gen Y=FCE+GCF

//ILS

ivreg FCE ( Y = GCF )

//OLS

reg FCE Y

**# Phương pháp bình phương nhỏ nhất hai giai đoạn (2SLS)

use "$link\working_children.dta",clear

gen yearsofexperience2 = yearsofexperience^2

gen experienceXgender=yearsofexperience*gender

sum  ln_wage urban gender yearsofedu yearsofexperience yearsofexperience2 experienceXgender RedRiverDelta Northmidlandareas CentralCoast Centralhighlands MekongRiverDelta fatheredu motheredu

//Tương quan biến công cụ và biến nội sinh

corr yearsofedu fatheredu motheredu

//Hồi quy giai đoạn 1, đồng thời tạo ra biến dự đoán yearsofedu_hat

reg yearsofedu fatheredu motheredu urban gender  yearsofexperience yearsofexperience2 experienceXgender RedRiverDelta Northmidlandareas CentralCoast Centralhighlands MekongRiverDelta

predict yearsofedu_hat

//Hồi quy giai đoạn 2

reg ln_wage yearsofedu_hat urban gender  yearsofexperience yearsofexperience2 experienceXgender RedRiverDelta Northmidlandareas CentralCoast Centralhighlands MekongRiverDelta

ivregress 2sls ln_wage ( yearsofedu= fatheredu motheredu) urban gender  yearsofexperience yearsofexperience2 experienceXgender RedRiverDelta Northmidlandareas CentralCoast Centralhighlands MekongRiverDelta

//Kiểm định tính ngoại sinh

estat overid

//Kiểm định mô hình nội sinh

estat endogenous

log close 