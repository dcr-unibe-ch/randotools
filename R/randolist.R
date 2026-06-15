#' Generate randomisation lists
#'
#' Randomisation lists are central to randomised trials. This function allows
#' to generate randomisation lists simply, via (optionally) stratified block randomisation
#'
#' @param n total number of randomizations (per stratum)
#' @param arms arms to randomise
#' @param strata named list of stratification variables (see examples)
#' @param blocksizes numbers of each arm to include in blocks (see details)
#' @param pascal logical, whether to use pascal's triangle to determine block sizes
#' @param n_init number of blocks with different blocksize probabilities to
#' initialize the list with
#' @param init_probs probabilities to use for each \code{blocksize} for the
#' \code{n_init} blocks
#' @param ... arguments passed on to other methods
#'
#' @details \code{blocksizes} defines the number of allocations to each arm in a block.
#' For example, if there are two arms, and \code{blocksizes} = 1, each block will
#' contain 2 randomisations. If \code{blocksizes} = \code{1:2}, each block will
#' contain either one of each arm, or two of each arm. Total block sizes are
#' therefore  \code{blocksizes * length(arms)}.
#'
#' By default, frequency of the different block sizes is determined using Pascal's
#' triangle.
#' This has the advantage that small and large block sizes are less common than
#' intermediate sized blocks, which helps with making it more difficult to guess
#' future allocations, and reduces the risk of finishing in the middle of a large
#' block.
#'
#' Unbalanced randomization is possible by specifying the same arm label multiple times.
#'
#' To disable block randomisation, set \code{blocksizes} to the same value as \code{n}.
#'
#' It can be helpful to use smaller blocks at the start of a randomisation list.
#' \code{n_init} allows you to define how many blocks to add at the beginning of
#' the list with a different set of blocksize probabilities (entered via
#' \code{init_probs}). Note that this modifies the final frequencies of the
#' blocksizes - they are no longer according to normal settings (pascals triangle, if
#' \code{pascal = TRUE}, or approximately equal, if \code{pascal = FALSE}).
#' Depending on the settings, it may even be that some blocksizes are not observed at
#' all (e.g. if \code{n_init} exceeds the total number of blocks required and
#' \code{init_probs = c(.8, .1, 0)}, there will be none of the larger blocks in
#' the randomisation list.
#'
#' \code{n_init} and \code{init_probs} allow more control over the blocksize
#' probabilities than is otherwise possible (i.e. with the \code{pascal} argument).
#' Suppose you want primarily blocks of size 2, with some blocks of size 4, you might
#' set \code{n_init} to \code{n/2} (as if all blocks were of size 2, just to ensure
#' that there are enough blocks for all randomisations) and set \code{init_probs = c(0.8, .2)}.
#'
#' @export
#'
#' @returns object of class `randolist` which is a dataframe with additional
#' attributes ratio (randomisation ratio, e.g. 1:1, 2:1), arms (arm labels),
#' stratified (logical whether the list is stratified), and stratavars (the
#' stratification variables)
#'
#' @examples
#' # example code
#' randolist(10)
#' # one stratifying variable
#' randolist(10, strata = list(sex = c("M", "F")))
#' # two stratifying variables
#' randolist(10, strata = list(sex = c("M", "F"),
#'                             age = c("child", "adult")))
#' # different arm labels
#' randolist(10, arms = c("arm 1", "arm 2"))
#'
#' # unbalanced (2:1) randomization
#' randolist(10, arms = c("arm 1", "arm 1", "arm 2"))
#'
#'
randolist <- function(n,
                      arms = LETTERS[1:2],
                      strata = NA,
                      blocksizes = 1:3,
                      pascal = TRUE,
                      n_init = 0,
                      init_probs = NULL,
                      ...){

  strata_y <- is.list(strata)

  if(!strata_y) {

    rlist <- blockrand(n = n, arms = arms, blocksizes = blocksizes,
                       n_init = n_init, init_probs = init_probs, ...)

  } else {

    grid <- expand.grid(strata)
    grid$strata_txt <- apply(grid, 1, function(x) paste(x, collapse = "; "))
    grid$stratum <- nth <- 1:nrow(grid)

    rlist <- lapply(seq_along(nth), function(x){
      # get the current stratum
      stratum <- nth[x]

      # generate randomization for this stratum
      rlist <- blockrand(n = n, arms = arms, blocksizes = blocksizes,
                         n_init = n_init, init_probs = init_probs, ...)

      # add stratum information to the randomization
      rlist$stratum <- stratum

      return(rlist)
    }) |> do.call(what = "rbind") |>
      merge(grid, by = "stratum")

    class(rlist) <- c("randolist", class(rlist))
  }

  attr(rlist, "ratio") <- table(arms) |> paste(collapse = ":")
  attr(rlist, "arms") <- unique(arms)
  attr(rlist, "stratified") <- strata_y
  attr(rlist, "stratavars") <- names(strata)

  return(rlist)
}




