# Changelog

## randotools 0.2.7

- Addition of the ability to prioritize small blocksizes at the start of
  a randomization list. See `randolist`.
- bug fix: the pascal argument to randolist was ignored. it’s not used
  correctly.

## randotools 0.2.6

CRAN release: 2026-03-11

correct additional URLs

## randotools 0.2.5

update URLs

## randotools 0.2.4

CRAN release: 2025-12-03

bug fix for `check_plan`: it only handled up to 26 strata, producing
unexpected results with more strata. It now handles up to 676 strata.

## randotools 0.2.3

CRAN release: 2025-11-07

minor modifications from CRAN review

## randotools 0.2.1

Add lots of tests, minor modifications to clear notes from R CMD CHECK

## randotools 0.2.0

Addition of `check_plan` to investigate a proposed randomisation
strategy, in terms of the balance that may be observed with specified
number of strata and block sizes

## randotools 0.1.1

Minor improvements suggested by [@lbeuti](https://github.com/lbeuti)

## randotools 0.1.0

- addition of tools to assess the balance of randomised elements

## randotools 0.0.4

- Package renamed to `randotools` to allow more flexibility with what it
  includes
- `randolist_to_db` : Move the randomisation result to the first column
  when exporting to REDCap
- `summary` : Remove the use of cli for messages, as they do not appear
  in `sink`ed output
- Add a vignette to show how to use the package
