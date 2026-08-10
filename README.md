# Kim, "Trading Off Business and Family Investments: Evidence from U.S. Entrepreneurial Households"

By **Olivia S. Kim**

Please send questions about the paper or replication materials to
[Olivia S. Kim](mailto:okim@hbs.edu).

**Publication status:** Accepted at *Management Science*, March 2026

**Latest public manuscript:** [SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3527860)
(revised April 1, 2026)

---

# `code`

## Empirical analysis of public-use data

`analysis_fig1.do` is the only public-data analysis program. It reproduces all
four panels of Figure 1 from the five public source files in `data/`. The data,
analysis files, and code used for results based on restricted JPMorgan Chase
Institute (JPMCI) records are not included in this repository; those materials
are described separately under [JPMCI data](#jpmci-data).

### Requirements and execution

The package was tested with **Stata/MP 19.5**

1. Clone or download this repository.
2. Open Stata and make the repository root—the directory containing this
   README—the working directory.
3. Run:

   ```stata
   do code/analysis_fig1.do
   ```

The program reads source files from `data/` and overwrites the corresponding
intermediate datasets and figures in `output/`.

### Figure 1 replication map

| Panel | What it shows | Public source data | Main processing | Intermediate files | Final output |
| --- | --- | --- | --- | --- | --- |
| Figure 1(a) | Average cost of attendance at public two- and four-year institutions | `data/IPEDS_COA.xlsx`; `data/CPI.xls` | Reshapes the four IPEDS summary sheets, merges annual CPI, and expresses costs in 2002 dollars | `output/COA2priv.dta`; `output/COA2pub.dta`; `output/COA4priv.dta`; `output/COA4pub.dta`; `output/COA_all.dta`; `output/cpi.dta` | `output/public.pdf` |
| Figure 1(b) | New firms as a share of all firms | `data/bds_f_agesz_st_release.csv` | Keeps years containing all firm-age categories, aggregates across state and firm-size cells, and calculates firm shares | `output/BDS.dta` | `output/bizdyn_bds.pdf` |
| Figure 1(c) | Age distribution of first-year college students in 2015 | `data/HERI.xlsx` | Combines the age-16-or-younger and age-17 groups, reshapes the age distribution, and keeps 2015 | None | `output/age_heri.pdf` |
| Figure 1(d) | Distribution of state compulsory-schooling ages | `data/age_compulsory.dta` | Counts states and the District of Columbia by maximum compulsory-attendance age | None | `output/compulsory.pdf` |

The private-institution IPEDS datasets are created by the common cleaning loop
for completeness, but Figure 1(a) plots only public institutions.

# `data`

## Public data sources

- `CPI.xls` contains annual U.S. CPI observations for 2002–2017 from FRED
  series [CPALTT01USA661S](https://fred.stlouisfed.org/series/CPALTT01USA661S).
- `HERI.xlsx` contains published trends from UCLA's Cooperative Institutional
  Research Program Freshman Survey, including the 2015 age distribution used
  in Figure 1(c). See [*The American Freshman: Fifty-Year Trends,
  1966–2015*](https://www.heri.ucla.edu/monographs/50YearTrendsMonograph2016.pdf).
- `IPEDS_COA.xlsx` contains cost-of-attendance summary statistics by
  institution level, control, and residency for academic years 2002–03 through
  2017–18. The source is the U.S. Department of Education's
  [Integrated Postsecondary Education Data System](https://nces.ed.gov/ipeds/use-the-data).
- `age_compulsory.dta` contains the 2017 maximum compulsory-attendance age for
  the 50 states and the District of Columbia. The values correspond to
  [NCES Table 5.1](https://nces.ed.gov/programs/statereform/tab5_1.asp), whose
  underlying source is the Education Commission of the States.
- `bds_f_agesz_st_release.csv` is the U.S. Census Bureau Business Dynamics
  Statistics firm-age-by-size-by-state release. The archived source file is in
  the Census Bureau's
  [BDS time-series directory](https://www2.census.gov/programs-surveys/research/ces/tables/time-series/bds/firm/age-size-state/).

# JPMCI data

The data used for this paper were prepared in JPMorgan Chase Institute's (JPMCI) secure computing facilities. Due to JPMCI's rules on access and confidentiality, the programming code and analysis files cannot be made available publicly. The analysis files and programming code created by the author will be available within JPMCI's secure computing facilities until 2029 or the expiry of the data-use agreement (whichever comes first), and can be requested by researchers with approved projects (email institute@jpmchase.com). We grant any researchers with appropriate approval to conduct research on JPMCI's secure computing facilities access to these files.

The following tables and key variables are needed to replicate the
restricted-data analysis.

## Tables

- `ok_final_typ`
- `ok_outcomes_biz_typ`
- `ok_outcomes_hh_typ`

## Key variables

- `id_biz`
- `id_hh`
- `date_qt`
- `age_youngest`
- `ct_kids`
- `age`
- `cust_state`
- `naics1_lbl`
- `desc_subtype`
- `biz_inc_tot`
- `biz_exp_tot`
- `hh_consumption`



# Directory structure

```text
.
|-- .gitignore
|-- README.md
|-- code/
|   `-- analysis_fig1.do
|-- data/
|   |-- CPI.xls
|   |-- HERI.xlsx
|   |-- IPEDS_COA.xlsx
|   |-- age_compulsory.dta
|   `-- bds_f_agesz_st_release.csv
`-- output/
    |-- BDS.dta
    |-- COA2priv.dta
    |-- COA2pub.dta
    |-- COA4priv.dta
    |-- COA4pub.dta
    |-- COA_all.dta
    |-- age_heri.pdf
    |-- bizdyn_bds.pdf
    |-- compulsory.pdf
    |-- cpi.dta
    `-- public.pdf
```

## Files in `output/`

- `COA2priv.dta`, `COA2pub.dta`, `COA4priv.dta`, and `COA4pub.dta` are cleaned
  versions of the corresponding IPEDS workbook sheets.
- `COA_all.dta` appends the four cleaned IPEDS datasets before the CPI merge.
- `cpi.dta` stores annual CPI and the index normalized to 2002.
- `BDS.dta` stores the aggregated firm-age series and calculated shares.
- `public.pdf`, `bizdyn_bds.pdf`, `age_heri.pdf`, and `compulsory.pdf` are the
  four Figure 1 panel outputs described above.

The generated datasets and figures are committed as reproducibility baselines.
Running `code/analysis_fig1.do` recreates and overwrites them.
