# Credit Default Risk — Expected Value Decision Model

Predicting default on consumer loan applications, then turning those probabilities
into an approve/reject decision based on expected profit rather than a fixed 0.5
cut-off.

**Status (25 Sep 2026):** database and cleaning complete, modelling in progress.
The expected-value layer and dashboard are not built yet.

## Data

[Home Credit Default Risk](https://www.kaggle.com/competitions/home-credit-default-risk)
— seven related tables, 58.4M rows total, loaded into a local PostgreSQL database.
The main application table holds 307,511 applications; 8.07% defaulted.

| table | rows |
|---|---|
| application_train | 307,511 |
| bureau | 1,716,428 |
| bureau_balance | 27,299,925 |
| previous_application | 1,670,214 |
| installments_payments | 13,605,401 |
| credit_card_balance | 3,840,312 |
| pos_cash_balance | 10,001,358 |

## Results so far

Application table only. PR-AUC on a held-out validation set; the no-skill baseline
is 0.0807.

| model | PR-AUC |
|---|---|
| Logistic regression | 0.217 |
| XGBoost (untuned) | 0.234 |

Five-fold cross-validation puts fold-to-fold variation at 0.215–0.232, so
differences under about 0.017 aren't distinguishable from noise. That ruled out one
experiment: binning `amt_goods_price` into deciles lifted validation PR-AUC by
0.002, well inside the noise, so it was dropped rather than reported as a gain.

## What's in here

notebooks/
00_data_dictionary.ipynb column definitions
01_column_checks.ipynb inspection of all 122 application columns
02_cleaning.ipynb cleaning decisions and the reasoning for each
03_model.ipynb split, pipelines, baseline models
sql/
01_create_tables.sql schema for all seven tables
02_indexes.sql indexes on the join keys


## Cleaning approach

Extreme values were judged by whether the rest of the record supported them, rather
than by a threshold rule. That turned up four different problems:

- An income of 117,000,000 on an applicant who borrowed 562,491 and defaulted —
  a credit-to-income ratio of 0.005 against a population median near 3. Most likely
  117,000 recorded at 1000×.
- `days_employed` holding 365,243 — about 1000 years — on 55,374 records, 99.96% of
  them pensioners. A placeholder for "no current employment", not a measurement.
- `own_car_age` piling up at exactly 64 and 65 where neighbouring values hold a
  handful of records each, suggesting the upper range was bucketed.
- 261 credit enquiries in one two-month window for an applicant with almost none in
  any other window.

Redundancy was removed on evidence: the 14 housing measurements each appear three
times (`_avg`, `_mode`, `_medi`) and correlate 0.97–0.998 between versions, so 28
columns were dropped. Ten near-constant flags went under a single 99.9% rule.

## Reproducing it

1. Download the competition data and unzip into `data/`:
   `kaggle competitions download -c home-credit-default-risk`
2. Create a `home_credit` database, then run `sql/01_create_tables.sql`
3. Load each CSV with `\copy`, then run `sql/02_indexes.sql`
4. Copy `.env.example` to `.env` and fill in your database credentials
5. Run the notebooks in order

## Next

- SQL aggregation of the six history tables to one row per applicant, and a measure
  of how much they add over the application table alone
- An expected-value decision rule: P(good) × margin − P(bad) × LGD × exposure, with
  the optimal approval rate reported across a range of loss-given-default
- A Power BI dashboard with the cut-off and LGD as adjustable parameters

## On AI assistance

I used Claude throughout this project, mainly for scaffolding — sklearn syntax,
pipeline structure, catching bugs. The analytical decisions are mine: which
anomalies to investigate, whether a value was an error or a genuine extreme, what to
drop and why, and which improvements cleared the noise floor. The modelling notebook
was then rebuilt from scratch without assistance, using the first version as a
reference.