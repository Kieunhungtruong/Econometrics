If you have the STATA version of this textbook, you can also use the online datasets available at the following structure:

```use "https://raw.githubusercontent.com/Kieunhungtruong/Econometrics/main/Data/[file name]", clear```

For example, to load GDP_population.dta:
use "https://raw.githubusercontent.com/Kieunhungtruong/Econometrics/main/Data/GDP_population.dta", clear
For Excel files, you can use the following commands:

For Excel files, you can use the following commands:
copy "https://raw.githubusercontent.com/Kieunhungtruong/Econometrics/main/Data/grade.xlsx" ///
     "grade.xlsx", replace
import excel "grade.xlsx", firstrow clear
These commands allow you to use the dataset even if you do not have the data files stored locally on your computer.
