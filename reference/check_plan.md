# Check randomisation plan

Before committing to a randomisation plan (in terms of the number of
strata, block sizes etc) it can be useful to estimate the imbalance that
might be expected. This function simulates trials of a given sample size
and returns the imbalance that might be expected.

## Usage

``` r
check_plan(
  n_rando,
  n_strata,
  arms = c("A", "B"),
  blocksizes = c(1, 2),
  n_sim = 1000
)

# S3 method for class 'checkplan'
print(x, ...)
```

## Arguments

- n_rando:

  number of participants to randomise

- n_strata:

  number of strata

- arms:

  arms that will be randomised

- blocksizes:

  number of each randomisation group per block (e.g. 1 = one of each arm
  per block, 2 = per of each arm per block)

- n_sim:

  number of simulations

- x:

  check_plan object

- ...:

  options passed to print.data.frame

## Value

list of class checkplan with slots the same slots as input to the
function plus mean (mean imbalance), counts (counts of the imbalances)
and worst_case (randomisation results with the worst observed imbalance)

## Functions

- `print(checkplan)`: Print method for check_plan output

## See also

https://www.sealedenvelope.com/randomisation/simulation/

## Examples

``` r

check_plan(50, 3, n_sim = 50)
#> 
#> Number of simulated trials: 50 
#>  Number of participants per trial: 50 
#>  Number of strata: 3 
#>  Blocksizes: 2, 4 
#>  Mean imbalance: 0.96 
#>  Distribution of imbalance:
#>  imbalance  n  % cum%
#>          0 27 54   54
#>          2 22 44   98
#>          4  1  2  100
#> 
#> Worst case imbalance from simulations:
#>   arm  n
#> 1   A 23
#> 2   B 27
```
