# randotools

Randomisation is one of the key aspects of clinical trials, ensuring
that treatment groups are balanced and that the results are not biased.
The `randotools` package provides functions to create randomisation
lists in R, with a focus on flexibility and ease of use.

``` r

library(randotools)
```

## Creating randomization lists

Randomisation lists are easily created with the `randolist` function.
Specify the number of participants to randomise (per strata, if there
are any), any strata, the arms to randomise between, and the block
sizes.

``` r

randolist(n = 20, arms = c("Trt1", "Trt2"))
#>    seq_in_strata block_in_strata blocksize seq_in_block  arm
#> 1              1               1         4            1 Trt1
#> 2              2               1         4            2 Trt1
#> 3              3               1         4            3 Trt2
#> 4              4               1         4            4 Trt2
#> 5              5               2         2            1 Trt1
#> 6              6               2         2            2 Trt2
#> 7              7               3         6            1 Trt2
#> 8              8               3         6            2 Trt1
#> 9              9               3         6            3 Trt2
#> 10            10               3         6            4 Trt1
#> 11            11               3         6            5 Trt1
#> 12            12               3         6            6 Trt2
#> 13            13               4         4            1 Trt2
#> 14            14               4         4            2 Trt1
#> 15            15               4         4            3 Trt2
#> 16            16               4         4            4 Trt1
#> 17            17               5         4            1 Trt1
#> 18            18               5         4            2 Trt1
#> 19            19               5         4            3 Trt2
#> 20            20               5         4            4 Trt2
```

In the above call,

- `n` specifies the number of participants to randomise per stratum. In
  this case, we are randomising 20 participants in a single stratum.
- `arms` specifies the names of the arms to randomise between.

Any number of arms can be specified, so `randolist` can be used for
trials with two, three, even 10 or more arms, so platform trials can be
accommodated by `randolist`, although implementing them within the
database is not trivial.

### Block randomisation

By default, `randolist` uses block randomisation - rather than using
random selection along the whole list in the hope that the arms are
balanced, it creates blocks of randomisation, whereby each block is
balanced, and block sizes are chosen at random. This not only helps with
balancing, but also makes it harder to guess the next allocation. Block
sizes are controlled via the `blocksizes` argument, where the values
should be the potential number of each arm to include in any given
block. E.g. `c(1,2)` would produce blocks with either one of each arm,
or two of each arm, for a total block size or 2 or 4.

``` r

r <- randolist(n = 10, 
               arms = c("Trt1", "Trt2"), 
               blocksizes = c(1,2))
```

Additionally, `blocksizes` are selected approximately proportional to
Pascal’s Triangle, so that medium sizes blocks are more likely to be
selected than small or large blocks. This is done to ensure that the
randomisation list is not too predictable, and helps with balance by
reducing the chance of finishing mid-way through a large block.

To disable block randomisation, set the block size to `n` divided by the
number of arms (in this case `n`/2, so 10):

``` r

randolist(n = 20, 
          arms = c("Trt1", "Trt2"),
          blocksizes = 10)
#>    seq_in_strata block_in_strata blocksize seq_in_block  arm
#> 1              1               1        20            1 Trt1
#> 2              2               1        20            2 Trt1
#> 3              3               1        20            3 Trt2
#> 4              4               1        20            4 Trt1
#> 5              5               1        20            5 Trt1
#> 6              6               1        20            6 Trt2
#> 7              7               1        20            7 Trt1
#> 8              8               1        20            8 Trt2
#> 9              9               1        20            9 Trt1
#> 10            10               1        20           10 Trt2
#> 11            11               1        20           11 Trt1
#> 12            12               1        20           12 Trt1
#> 13            13               1        20           13 Trt2
#> 14            14               1        20           14 Trt1
#> 15            15               1        20           15 Trt2
#> 16            16               1        20           16 Trt1
#> 17            17               1        20           17 Trt2
#> 18            18               1        20           18 Trt2
#> 19            19               1        20           19 Trt2
#> 20            20               1        20           20 Trt2
```

The `blockrand` function can also be used for non-stratified
randomisation lists.

### Stratified randomisation lists

It is very common to need a stratified randomisation where the
randomisation is balanced within strata. This is done by specifying the
`strata` argument, which should be a list of the stratifying variables.
The function will then create a randomisation list for each stratum, and
combine them into a single list. The list for each strata contains `n`
participants.

``` r

rs <- randolist(n = 10, 
                strata = list(sex = c("Male", "Female"),
                              age = c("Teen", "Adult")))

table(rs$sex)
#> 
#>   Male Female 
#>     20     24
table(rs$sex, rs$arm)
#>         
#>           A  B
#>   Male   10 10
#>   Female 12 12
```

By using factors to specify the strata, the labels and levels are
available for use when exporting the randomisation list, which is useful
for importing into electronic data capture systems such as REDCap, which
requires a specific format.

### Unbalanced randomisation lists

It is not uncommon to have unbalanced randomisation lists. E.g. 2
control participants per experimental participant. This is easily done
by changing the `arms` argument:

``` r

r2 <- randolist(n = 10, 
               arms = c("A", "A", "B"))

table(r2$arm)
#> 
#>  A  B 
#> 10  5
```

Adaptive trials sometimes modify the randomisation balance part way
through a trial, which can be accomplished via this method.

### More control over randomisation lists

In some cases, such as relatively short randomisation lists including
larger block sizes, it may be desirable to use smaller blocks at the
beginning of a randomisation list. The `n_init` and `init_probs`
arguments provide the means to accomplish that. They add `n_init` blocks
to the beginning of the randomisation list (per strata) with blocksizes
according to `init_probs`.

For example, the following code will add 2 blocks with blocks of size 2
and 3 with probabilities of 0.8 and 0.2, respectively, and no blocks of
size 6.

``` r

randolist(n = 50, n_init = 2, init_probs = c(.8,.2,0))
```

We can go beyond the addition of `n_init` blocks to the beginning of the
list. Using this method, we can use specific probabilities for the
various blocksizes (by default, intermediate blocksizes are more
frequent than the smallest/largest, when `pascal = TRUE`, or equal
probabilities, when `pascal = FALSE`). In order to specify the
probabilities for the full list, set `n_init` to some value large enough
that the full list can be generated with the `n_init` blocks
(e.g. `n_init` should be at least `n`/`min(blocksizes)`). For example,
to generate a list with block sizes 2, 4 and 6 with probabilities of
0.7, .2, .1, i.e. prioritizing blocks of size 2, and 50 randomisations,
we can use the following code:

``` r

r <- randolist(n = 50, 
          blocksizes = 1:3, # blocksizes*length(arms) = final blocksizes
          n_init = 25, # 50/min(blocksizes*length(arms))
          init_probs = c(.7,.2,.1))
```

This gives the following blocksize frequencies:

``` r

table(r$blocksize)/c(2,4,6)
#> 
#>  2  4  6 
#> 11  4  2
```

## Summarizing randomisation lists

It can be helpful to summarize the randomisation list to check that the
requirements, such as the balance, coding, etc, are met. The `randolist`
package includes a `summary` precisely for this purpose:

``` r

randolist(n = 20, arms = c("Trt1", "Trt2")) |> summary()
#> ---- Randomisation list report ----
#> -- Overall
#> Total number of randomisations:  20 
#> Randomisation groups:  Trt1 : Trt2 
#> Randomisation ratio: 1:1 
#> Randomisations to each arm:
#> Trt1 Trt2 
#>   10   10 
#> Block sizes:
#> 4 
#> 5
```

The summary for stratified randomisation lists also includes information
at the strata level.

## Exporting randomisation lists

Once a randomisation list is created, it needs to be transferred into a
system that will ultimately perform the randomisation. We primarily use
two systems for this: REDCap and SecuTrial, but you might use others,
which may require other modifications. The `randolist` package includes
a function to convert the randomisation list into a format that should
be, with minimal effort, be importable into these systems.

``` r

# create a very small randomisation list for demonstration purposes
rs2 <- randolist(n = 2, blocksizes = 1,
                 arms = c("Aspirin", "Placebo"),
                 strata = list(sex = c("Male", "Female"),
                               age = c("Teen", "Adult")))
```

The `randolist_to_db` function is used to convert the randomisation list
into a format that can be imported into the system. The function takes
the randomisation list as input, and converts it to a data frame with
the columns appropriate for the target database (`target_db`). In the
case of REDCap, it is necessary to provide a data frame which maps the
arms provided in `randolist` to the database variables.

``` r

randolist_to_db(rs2, target_db = "REDCap", 
                rando_enc = data.frame(arm = c("Aspirin", "Placebo"),
                                       rand_result = c(1, 2)),
                strata_enc = list(sex = data.frame(sex = c("Male", "Female"), code = 1:2),
                                  age = data.frame(age = c("Teen", "Adult"), code = 1:2)))
#>   rand_result sex age
#> 1           1   1   1
#> 2           2   1   1
#> 3           2   2   1
#> 4           1   2   1
#> 5           2   1   2
#> 6           1   1   2
#> 7           1   2   2
#> 8           2   2   2
```

SecuTrial uses a more standardised format, so `rando_encoding` is not
required.

``` r

randolist_to_db(rs2, target_db = "secuTrial",
                strata_enc = list(sex = data.frame(sex = c("Male", "Female"), code = 1:2),
                                  age = data.frame(age = c("Teen", "Adult"), code = 1:2)))
#>   Number   Group       sex       age
#> 1      1 Aspirin value = 1 value = 1
#> 2      2 Placebo value = 1 value = 1
#> 3      3 Placebo value = 2 value = 1
#> 4      4 Aspirin value = 2 value = 1
#> 5      5 Placebo value = 1 value = 2
#> 6      6 Aspirin value = 1 value = 2
#> 7      7 Aspirin value = 2 value = 2
#> 8      8 Placebo value = 2 value = 2
```

The dataframe returned can then be exported to CSV or xlsx and imported
into the relevant database.
