clear
global link "~" 
/* Điều địa chỉ dẫn đến thư mục làm việc vào ~. 
Ví dụ thư phục làm việc là "C:\Downloads\data and dofile\1.data\chương 3" thì cú pháp là:
global link "C:\Downloads\data and dofile\1.data\chương 3" 
*/
capture log close
set more off
/******************************************************************/  
/*      Chapter 3                                                 */
/*      File Name:  chương 3.do                                   */  
/*      Date:       October 31, 2024                              */  
/*      Authors:    Nhung                                         */  
/*      Purpose:    Heteroskedasticity                            */  
/*      Input File:     migration_remittances_16_full.dta         */
/*                      wage2020.dta                              */  
/*      Output File:    chuong3.log                               */  
/******************************************************************/ 

log using chuong3.log, text replace

use "$link\migration_remittances_16_full.dta",clear

quietly regress per_expenditure remittances

predict r, residual 

twoway (scatter r remittances)(lowess r remittances),yline(0)

graph export Chapter3.2.png, as(png) name("Graph") replace

use "$link\migration_remittances_16_full.dta",clear

**# Kiểm định Breusch–Pagan
//Bước 1:Ước lượng mô hình hồi quy.

quietly reg per_expenditure remittances 

//Bước 2:Lấy phần dư e và bình phương phần dư e^2

predict r, residual 
gen rsq = r^2

//Bước 3: Hồi quy bình phương phần dư với tất cả các biến độc lập từ mô hình OLS gốc

reg rsq remittances 

// Kiểm định Breusch–Pagan bằng lệnh stata
quietly reg per_expenditure remittances 
hettest,rhs fstat

**# Kiểm định White thông thường

quietly reg rsq remittances c.remittances#c.remittances
display "LMwhite: " e(N)*e(r2)

// Kiểm định White test bằng lệnh stata
quietly reg per_expenditure remittances
imtest,white

**# Kiểm định White có điều chỉnh
//Bước 1: Hồi quy mô hình OLS

quietly reg per_expenditure remittances

//Bước 2: Tạo biến mới đặt tên là yhat và yhat2, với yhat là biến chứa giá trị dự báo của biến phụ thuộc.

predict yhat,xb
gen yhat2=yhat^2

//Bước 3: Hồi quy phần dư của mô hình với hai biến yhat và yhat2

reg rsq yhat yhat2

**# Sử dụng bình phương nhỏ nhất có trọng số (Weighted Least Squares: WLS)

//Tìm findit wls chọn cài đặt wls0

wls0  per_expenditure remittances , wvar( remittances ) type(abse) noconst

hettest,rhs fstat

gen remittances_sqrt = sqrt(remittances)

wls0 per_expenditure remittances  , wvar(remittances_sqrt) type(abse) noconst

hettest,rhs fstat

**# Lấy log cho các biến

reg ln_per_expenditure ln_remittances

hettest,rhs fstat

**# Chọn trọng số là giá trị dự báo yhat

wls0 per_expenditure remittances  , wvar(yhat) type(abse) noconst

hettest,rhs fstat

reg per_expenditure remittances ,robust

**# Mô hình chi tiêu thực phẩm

gen agehead2=agehead^2

gen HHsize2=HHsize^2

global xvar "ln_expenditure agehead agehead2 primary secondary high_school higher_education HHsize HHsize2 dependency_ratio domestic_remittances overseas_remittances urban RedRiverDelta Northmidlandareas MekongRiverDelta Centralhighlands CentralCoast"

quietly regress food_share $xvar 

hettest,rhs fstat

imtest,white

regress food_share $xvar,robust

**# Mô hình tiền lương

use "$link\wage2020.dta", clear

quietly regress wage urban gender yearsofedu yearsofexperience

hettest,rhs fstat

imtest,white

regress wage urban gender yearsofedu yearsofexperience,robust

log close
