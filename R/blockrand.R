#' Block randomization
#'
#' Generate a randomization list for a single stratum with blocks of varying sizes.
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
#' @param n total number of randomizations (within a single stratum)
#' @param arms number of arms to randomise
#' @param blocksizes numbers of each arm to include in blocks
#' @param pascal logical, whether to use pascal's triangle to determine block sizes
#' @param n_init number of initial blocks to start the randomisation list with
#' @param init_probs probabilities to use for each \code{blocksize} for the
#' first \code{n_init} blocks
#' @param ... arguments passed on to other methods (currently unused)
#'
#' @returns a data frame with columns block, blocksize, seq_in_block, arm
#' @noRd
#'
#' @examples
#' set.seed(1)
#' blockrand(10)
#'
#' # different arm labels
#' blockrand(10, arms = c("Arm 1", "Arm 2"))
#'
#' # block sizes 2, 4, and 6, 2 arms
#' blockrand(20, blocksizes = 1:3)
#'
#' # unbalanced randomisation (2:1)
#' blockrand(12, arms = c("Arm 1", "Arm 1", "Arm 2"))
#'
#' # fixed block sizes
#' blockrand(10, blocksizes = 2)
#'
blockrand <- function(n,
                      arms = LETTERS[seq(2)],
                      blocksizes = 1:4,
                      pascal = TRUE,
                      n_init = 0,
                      init_probs = NULL,
                      ...
                      ){

  if(n < 2) stop("n too small")
  if(is.null(arms)) stop("arms must be provided")
  if(n_init > 0){
    if(is.null(init_probs))
      stop("'init_probs' must be entered when 'n_init' > 0")
    if(length(init_probs) != length(blocksizes))
      stop("'length(init_probs) != length(blocksizes)' : provide probabilities for each blocksize")

  }

  N_per_block <- blocksizes * length(arms)

  if(length(blocksizes) > 1){
    if(pascal) {
      p <- pascalprops(length(N_per_block))
    } else {
      p <- rep(1 / length(N_per_block), length(N_per_block))
    }
    # estimate number of required blocks
    min_blocks <- ceiling(n / min(N_per_block))

    # generate block sizes
    blocks <- sample(N_per_block, min_blocks, replace = TRUE, prob = p)
    if(n_init > 0){
      init_blocks <- sample(N_per_block, n_init, replace = TRUE, prob = init_probs)
      blocks <- c(init_blocks, blocks)
    }

    # select blocks to reach n
    blocks <- blocks[1:min(which(cumsum(blocks) >= n))]
  } else {
    blocks <- rep(N_per_block, ceiling(n / sum(N_per_block)))
  }

  # generate randomization
  rlist <- lapply(seq_along(blocks), function(i){
    arms_i <- rep(arms, each = blocks[i] / length(arms))

    # output dataframe
    data.frame(block_in_strata = i,
               blocksize = blocks[i],
               seq_in_block = 1:blocks[i],
               arm = sample(arms_i, blocks[i]))
  }) |> do.call(what = rbind)
  rlist$seq_in_strata <- seq_len(nrow(rlist))
  rlist <- rlist[, c("seq_in_strata", "block_in_strata", "blocksize",
                     "seq_in_block", "arm")]

  class(rlist) <- c("randolist", class(rlist))

  return(rlist)
}
