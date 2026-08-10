// -----------------------------------------------------------------------------
// Paper:       Trading Off Business and Family Investments:
//              Evidence from U.S. Entrepreneurial Households
// Paper author: Olivia S. Kim
// Replication package by: Olivia S. Kim and Andrew Ye
// Purpose:     Reproduce all four panels of Figure 1 using public data.
// Tested with: Stata/MP 19.5; no user-written packages are required.
//
// How to run:
//   1. Make the repository root (the directory containing README.md) the
//      current working directory in Stata.
//   2. Run: do code/analysis_fig1.do
//
// Inputs:
//   data/IPEDS_COA.xlsx
//   data/CPI.xls
//   data/bds_f_agesz_st_release.csv
//   data/HERI.xlsx
//   data/age_compulsory.dta
//
// Final outputs:
//   output/public.pdf        - Figure 1(a), cost of attendance
//   output/bizdyn_bds.pdf    - Figure 1(b), share of new firms
//   output/age_heri.pdf      - Figure 1(c), age of first-year students
//   output/compulsory.pdf    - Figure 1(d), compulsory-schooling ages
//
// The program also overwrites seven intermediate .dta files in output/.
// -----------------------------------------------------------------------------

version 19.5

// Use paths relative to the repository root. Fail early with a useful message
// if Stata was launched from another directory or an input is missing.
local projectdir "`c(pwd)'"
local datadir "`projectdir'/data"
local outdir "`projectdir'/output"

local required_inputs IPEDS_COA.xlsx CPI.xls bds_f_agesz_st_release.csv ///
	HERI.xlsx age_compulsory.dta

foreach input of local required_inputs {
	capture confirm file "`datadir'/`input'"
	if _rc {
		di as error "Required input data/`input' was not found."
		di as error "Change Stata's working directory to the repository root and rerun:"
		di as error "    do code/analysis_fig1.do"
		exit 601
	}
}

capture mkdir "`outdir'"

// Set a switch to 0 to skip the corresponding Figure 1 panel.
local switch_fig1a = 1
local switch_fig1b = 1
local switch_fig1c = 1
local switch_fig1d = 1

// Common graph colors.
local color_bg white
local color_1 cranberry
local color_2 dknavy


// -----------------------------------------------------------------------------
// Figure 1(a): Average cost of attendance at public two- and four-year schools
// -----------------------------------------------------------------------------
// IPEDS provides separate summary sheets by institution level, control, and
// student residency. The common cleaning loop creates one Stata file per sheet.
// All four sheets are retained as replication intermediates, although the final
// panel plots public institutions only. Annual CPI is then normalized to 2002
// so that the plotted averages are expressed in constant 2002 dollars.

if `switch_fig1a' == 1 {

	#delimit ;
	local sheets
		COA4pub
		COA4priv
		COA2pub
		COA2priv
	;
	#delimit cr

	foreach s of local sheets {

		// Import and standardize the IPEDS summary-statistic column names.
		di in red "`s'"
		import excel using "`datadir'/IPEDS_COA.xlsx", sheet("`s'") first clear
		rename (N Sum Minimum Maximum Mean thPercentile Median I StandardDeviation) ///
			(N sum min max mean p25 p50 p75 sd)

		// Each sheet alternates in-state and out-of-state observations. Older
		// row labels use a slightly longer suffix, so the year substring changes
		// after observation 26.
		gen d_in = strpos(Variable, "in-state") > 0
		gen d_out = strpos(Variable, "in-state") == 0
		gen lbl = "`s'"
		gen year = substr(Variable, -14, 4) if _n <= 26
		replace year = substr(Variable, -16, 4) if _n > 26
		destring year, replace
		order lbl
		drop Variable

		save "`outdir'/`s'.dta", replace
	}

	// Append all four institution groups and create group indicators.
	use "`outdir'/COA4pub.dta", clear
	append using "`outdir'/COA2pub.dta"
	append using "`outdir'/COA4priv.dta"
	append using "`outdir'/COA2priv.dta"

	gen d_4pub = strpos(lbl, "4pub") > 0
	gen d_4priv = strpos(lbl, "4priv") > 0
	gen d_2pub = strpos(lbl, "2pub") > 0
	gen d_2priv = strpos(lbl, "2priv") > 0
	drop lbl
	save "`outdir'/COA_all.dta", replace

	// Import annual U.S. CPI from FRED. The first 11 rows contain workbook
	// metadata rather than observations. Normalize CPI to its 2002 value.
	import excel using "`datadir'/CPI.xls", clear
	drop if _n < 12
	rename (A B) (year cpi)
	destring cpi, replace
	replace year = substr(year, -4, 4)
	destring year, replace

	summ cpi if year == 2002
	local cpi_02 = `r(min)'
	gen cpi_sc = cpi / `cpi_02'
	keep year cpi cpi_sc
	save "`outdir'/cpi.dta", replace

	// Deflate nominal IPEDS means and plot the public-institution series.
	use "`outdir'/COA_all.dta", clear
	merge m:1 year using "`outdir'/cpi.dta", nogen
	gen mean_sc = mean / cpi_sc

	#delimit ;
	graph twoway
		(line mean_sc year if d_4pub & d_out, color(`color_1'))
		(line mean_sc year if d_4pub & d_in, color(`color_1') lpattern(dash))
		(line mean_sc year if d_2pub & d_out, color(`color_2'))
		(line mean_sc year if d_2pub & d_in, color(`color_2') lpattern(dash))
		, graphregion(fcolor(`color_bg') lcolor(`color_bg'))
		xlabel(2001(2)2018)
		ytitle("Average Cost of Attendance ($)")
		legend(order(1 "4-year out-of-state" 2 "4-year in-state"
			3 "2-year out-of-state" 4 "2-year in-state")
			region(lcolor(`color_bg')) rows(2) symysize(1) symxsize(11) position(6))
	;
	graph export "`outdir'/public.pdf", replace;
	#delimit cr
}


// -----------------------------------------------------------------------------
// Figure 1(b): New firms as a share of all firms
// -----------------------------------------------------------------------------
// The Census BDS file contains state-by-firm-size-by-firm-age cells. Some early
// years do not contain every firm-age category. Keep years containing the
// oldest (26+) category as the completeness check, aggregate across state and
// size cells, and calculate each age group's share of national totals. The
// plotted series is the share for age-zero (new) firms.

if `switch_fig1b' == 1 {
	insheet using "`datadir'/bds_f_agesz_st_release.csv", names clear

	gen keepyear = (fage4 == "k) 26+")
	bysort year2: egen d_keep = max(keepyear)
	keep if d_keep

	collapse (sum) estabs_entry firms estabs emp, by(year2 fage4)

	foreach v in estabs_entry firms estabs emp {
		bysort year2: egen tot_`v' = total(`v')
		bysort year2: gen sh_`v' = `v' / tot_`v'
	}
	save "`outdir'/BDS.dta", replace

	use "`outdir'/BDS.dta", clear
	keep if fage4 == "a) 0"

	#delimit ;
	graph twoway
		(scatter sh_firms year2, color(`color_2'))
		(lfit sh_firms year2, color(gs8) lpattern(dash))
		, graphregion(fcolor(`color_bg') lcolor(`color_bg'))
		xlabel(2002(2)2015)
		xtitle("Year", height(5))
		ytitle("Share", height(5))
		legend(order(1 "New firms, as a Percentage of All Firms")
			region(lcolor(`color_bg')) rows(1) position(6))
	;
	graph export "`outdir'/bizdyn_bds.pdf", replace;
	#delimit cr
}


// -----------------------------------------------------------------------------
// Figure 1(c): Age distribution of first-year college students in 2015
// -----------------------------------------------------------------------------
// HERI reports separate categories for students age 16 or younger and age 17.
// Combine those values into the plotted "younger than 17" group, reshape the
// five age groups to long form, and retain the 2015 distribution.

if `switch_fig1c' == 1 {
	import excel using "`datadir'/HERI.xlsx", sheet("age") clear first
	replace age17 = age_le16 + age17
	rename age_ge21 age21
	drop age_le16
	reshape long age, i(year) j(t)
	keep if year == 2015

	// Create the value labels printed above the bars. Preserve the published
	// one-decimal label for the oldest category.
	tostring age, gen(age_lbl)
	replace age_lbl = "0.6" if t == 21
	sort t
	gen idx = _n

	#delimit ;
	graph twoway
		(bar age idx, barw(.5) color(navy))
		(scatter age idx, msym(none) mlab(age_lbl) mlabpos(12) mlabcolor(black))
		, xlabel(1 "younger than 17" 2 "18" 3 "19" 4 "20" 5 "21 or older")
		legend(off)
		ylabel(0(10)70, gmax)
		graphregion(fcolor(`color_bg') lcolor(`color_bg'))
		xtitle("Age of First-Year Students", height(5))
		ytitle("Percent", height(5))
	;
	graph export "`outdir'/age_heri.pdf", replace;
	#delimit cr
}


// -----------------------------------------------------------------------------
// Figure 1(d): Maximum compulsory-schooling age across states
// -----------------------------------------------------------------------------
// The source contains one observation for each state plus the District of
// Columbia. Collapse those 51 jurisdictions into counts at each maximum
// compulsory-attendance age and plot the resulting distribution.

if `switch_fig1d' == 1 {
	use "`datadir'/age_compulsory.dta", clear
	gen ind = 1
	collapse (sum) ind, by(age_compul)

	#delimit ;
	graph twoway
		(bar ind age_compul, ylabel(, grid) barw(.5) color(`color_2'))
		(scatter ind age_compul, msym(none) mlab(ind) mlabpos(12) mlabcolor(black))
		, graphregion(fcolor(`color_bg') lcolor(`color_bg'))
		legend(off)
		xlabel(16(1)19)
		xtitle("Compulsory Schooling Age", height(5))
		ytitle("Number of States", height(5))
	;
	graph export "`outdir'/compulsory.pdf", replace;
	#delimit cr
}

di as result "Figure 1 public-data replication complete."
