# Generate randomisation lists

Randomisation lists are central to randomised trials. This function
allows to generate randomisation lists simply, via (optionally)
stratified block randomisation

## Usage

``` r
randolist(
  n,
  arms = LETTERS[1:2],
  strata = NA,
  blocksizes = 1:3,
  pascal = TRUE,
  n_init = 0,
  init_probs = NULL,
  ...
)
```

## Arguments

- n:

  total number of randomizations (per stratum)

- arms:

  arms to randomise

- strata:

  named list of stratification variables (see examples)

- blocksizes:

  numbers of each arm to include in blocks (see details)

- pascal:

  logical, whether to use pascal's triangle to determine block sizes

- n_init:

  number of blocks with different blocksize probabilities to initialize
  the list with

- init_probs:

  probabilities to use for each `blocksize` for the `n_init` blocks

- ...:

  arguments passed on to other methods

## Value

object of class `randolist` which is a dataframe with additional
attributes ratio (randomisation ratio, e.g. 1:1, 2:1), arms (arm
labels), stratified (logical whether the list is stratified), and
stratavars (the stratification variables)

## Details

`blocksizes` defines the number of allocations to each arm in a block.
For example, if there are two arms, and `blocksizes` = 1, each block
will contain 2 randomisations. If `blocksizes` = `1:2`, each block will
contain either one of each arm, or two of each arm. Total block sizes
are therefore `blocksizes * length(arms)`.

By default, frequency of the different block sizes is determined using
Pascal's triangle. This has the advantage that small and large block
sizes are less common than intermediate sized blocks, which helps with
making it more difficult to guess future allocations, and reduces the
risk of finishing in the middle of a large block. If`pascal = FALSE`,
all `blocksize`s have the same frequency.

Unbalanced randomization is possible by specifying the same arm label
multiple times.

To disable block randomisation, set `blocksizes` to the same value as
`n`.

It can be helpful to use smaller blocks at the start of a randomisation
list. `n_init` allows you to define how many blocks to add at the
beginning of the list with a different set of blocksize probabilities
(entered via `init_probs`). Note that this modifies the final
frequencies of the blocksizes - they are no longer according to normal
settings (pascals triangle, if `pascal = TRUE`, or approximately equal,
if `pascal = FALSE`). Depending on the settings, it may even be that
some blocksizes are not observed at all (e.g. if `n_init` exceeds the
total number of blocks required and `init_probs = c(.8, .1, 0)`, there
will be none of the larger blocks in the randomisation list.

`n_init` and `init_probs` allow more control over the blocksize
probabilities than is otherwise possible (i.e. with the `pascal`
argument). Suppose you want primarily blocks of size 2, with some blocks
of size 4, you might set `n_init` to `n/2` (as if all blocks were of
size 2, just to ensure that there are enough blocks for all
randomisations) and set `init_probs = c(0.8, .2)`.

## Examples

``` r
# example code
randolist(10)
#>    seq_in_strata block_in_strata blocksize seq_in_block arm
#> 1              1               1         6            1   B
#> 2              2               1         6            2   B
#> 3              3               1         6            3   A
#> 4              4               1         6            4   A
#> 5              5               1         6            5   A
#> 6              6               1         6            6   B
#> 7              7               2         6            1   B
#> 8              8               2         6            2   A
#> 9              9               2         6            3   A
#> 10            10               2         6            4   B
#> 11            11               2         6            5   B
#> 12            12               2         6            6   A
# one stratifying variable
randolist(10, strata = list(sex = c("M", "F")))
#>    stratum seq_in_strata block_in_strata blocksize seq_in_block arm sex
#> 1        1             1               1         2            1   B   M
#> 2        1             2               1         2            2   A   M
#> 3        1             3               2         4            1   A   M
#> 4        1             4               2         4            2   B   M
#> 5        1             5               2         4            3   B   M
#> 6        1             6               2         4            4   A   M
#> 7        1             7               3         4            1   A   M
#> 8        1             8               3         4            2   B   M
#> 9        1             9               3         4            3   B   M
#> 10       1            10               3         4            4   A   M
#> 11       2             1               1         6            1   B   F
#> 12       2             2               1         6            2   A   F
#> 13       2             3               1         6            3   B   F
#> 14       2             4               1         6            4   B   F
#> 15       2             5               1         6            5   A   F
#> 16       2             6               1         6            6   A   F
#> 17       2             7               2         4            1   B   F
#> 18       2             8               2         4            2   A   F
#> 19       2             9               2         4            3   B   F
#> 20       2            10               2         4            4   A   F
#>    strata_txt
#> 1           M
#> 2           M
#> 3           M
#> 4           M
#> 5           M
#> 6           M
#> 7           M
#> 8           M
#> 9           M
#> 10          M
#> 11          F
#> 12          F
#> 13          F
#> 14          F
#> 15          F
#> 16          F
#> 17          F
#> 18          F
#> 19          F
#> 20          F
# two stratifying variables
randolist(10, strata = list(sex = c("M", "F"),
                            age = c("child", "adult")))
#>    stratum seq_in_strata block_in_strata blocksize seq_in_block arm sex   age
#> 1        1             1               1         6            1   A   M child
#> 2        1             2               1         6            2   B   M child
#> 3        1             3               1         6            3   A   M child
#> 4        1             4               1         6            4   B   M child
#> 5        1             5               1         6            5   A   M child
#> 6        1             6               1         6            6   B   M child
#> 7        1             7               2         6            1   B   M child
#> 8        1             8               2         6            2   A   M child
#> 9        1             9               2         6            3   A   M child
#> 10       1            10               2         6            4   B   M child
#> 11       1            11               2         6            5   A   M child
#> 12       1            12               2         6            6   B   M child
#> 13       2             1               1         4            1   A   F child
#> 14       2             2               1         4            2   B   F child
#> 15       2             3               1         4            3   A   F child
#> 16       2             4               1         4            4   B   F child
#> 17       2             5               2         6            1   A   F child
#> 18       2             6               2         6            2   A   F child
#> 19       2             7               2         6            3   B   F child
#> 20       2             8               2         6            4   A   F child
#> 21       2             9               2         6            5   B   F child
#> 22       2            10               2         6            6   B   F child
#> 23       3             1               1         4            1   A   M adult
#> 24       3             2               1         4            2   A   M adult
#> 25       3             3               1         4            3   B   M adult
#> 26       3             4               1         4            4   B   M adult
#> 27       3             5               2         6            1   A   M adult
#> 28       3             6               2         6            2   B   M adult
#> 29       3             7               2         6            3   A   M adult
#> 30       3             8               2         6            4   B   M adult
#> 31       3             9               2         6            5   B   M adult
#> 32       3            10               2         6            6   A   M adult
#> 33       4             1               1         4            1   B   F adult
#> 34       4             2               1         4            2   A   F adult
#> 35       4             3               1         4            3   B   F adult
#> 36       4             4               1         4            4   A   F adult
#> 37       4             5               2         4            1   B   F adult
#> 38       4             6               2         4            2   A   F adult
#> 39       4             7               2         4            3   A   F adult
#> 40       4             8               2         4            4   B   F adult
#> 41       4             9               3         2            1   B   F adult
#> 42       4            10               3         2            2   A   F adult
#>    strata_txt
#> 1    M; child
#> 2    M; child
#> 3    M; child
#> 4    M; child
#> 5    M; child
#> 6    M; child
#> 7    M; child
#> 8    M; child
#> 9    M; child
#> 10   M; child
#> 11   M; child
#> 12   M; child
#> 13   F; child
#> 14   F; child
#> 15   F; child
#> 16   F; child
#> 17   F; child
#> 18   F; child
#> 19   F; child
#> 20   F; child
#> 21   F; child
#> 22   F; child
#> 23   M; adult
#> 24   M; adult
#> 25   M; adult
#> 26   M; adult
#> 27   M; adult
#> 28   M; adult
#> 29   M; adult
#> 30   M; adult
#> 31   M; adult
#> 32   M; adult
#> 33   F; adult
#> 34   F; adult
#> 35   F; adult
#> 36   F; adult
#> 37   F; adult
#> 38   F; adult
#> 39   F; adult
#> 40   F; adult
#> 41   F; adult
#> 42   F; adult
# different arm labels
randolist(10, arms = c("arm 1", "arm 2"))
#>    seq_in_strata block_in_strata blocksize seq_in_block   arm
#> 1              1               1         2            1 arm 2
#> 2              2               1         2            2 arm 1
#> 3              3               2         6            1 arm 2
#> 4              4               2         6            2 arm 1
#> 5              5               2         6            3 arm 1
#> 6              6               2         6            4 arm 2
#> 7              7               2         6            5 arm 2
#> 8              8               2         6            6 arm 1
#> 9              9               3         4            1 arm 1
#> 10            10               3         4            2 arm 2
#> 11            11               3         4            3 arm 1
#> 12            12               3         4            4 arm 2

# unbalanced (2:1) randomization
randolist(10, arms = c("arm 1", "arm 1", "arm 2"))
#>    seq_in_strata block_in_strata blocksize seq_in_block   arm
#> 1              1               1         3            1 arm 1
#> 2              2               1         3            2 arm 2
#> 3              3               1         3            3 arm 1
#> 4              4               2         9            1 arm 1
#> 5              5               2         9            2 arm 1
#> 6              6               2         9            3 arm 2
#> 7              7               2         9            4 arm 1
#> 8              8               2         9            5 arm 1
#> 9              9               2         9            6 arm 1
#> 10            10               2         9            7 arm 1
#> 11            11               2         9            8 arm 2
#> 12            12               2         9            9 arm 2

```
