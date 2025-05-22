# Econometrics
This is a detailed guide with the Python version. It can help you approach our econometrics book.
If you have the STATA version of this textbook, you can also use the online datasets available at the following structure:

```use "https://raw.githubusercontent.com/Kieunhungtruong/Econometrics/main/data_dofile/1.data/[chapter name]/[file name]", clear```

For example, to load GDP_population.dta in chapter 1 (chương 1):

```use "https://raw.githubusercontent.com/Kieunhungtruong/Econometrics/main/data_dofile/1.data/chapter1/GDP_population.dta", clear```

For Excel files, you can use the following commands:

```import excel "https://raw.githubusercontent.com/Kieunhungtruong/Econometrics/main/data_dofile/1.data/chapter5/sales.xlsx", sheet("car") firstrow```

These commands allow you to use the dataset even if you do not have the data files stored locally on your computer.
