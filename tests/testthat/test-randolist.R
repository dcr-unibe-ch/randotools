

test_that("randolist returns a data.frame with expected columns", {
  set.seed(123)
  r <- randolist(n = 10)

  expect_s3_class(r, "data.frame")
  expect_true(all(c("arm", "block_in_strata", "blocksize", "seq_in_block",
                    "seq_in_strata") %in% names(r)))
  expect_equal(nrow(r), 10)
})

test_that("randolist returns correct number of arms", {
  set.seed(123)
  r <- randolist(n = 12, arms = c("A", "B"))
  expect_true(all(r$arm %in% c("A", "B")))
  expect_equal(length(unique(r$arm)), 2)
})

test_that("randolist handles unbalanced randomisation", {
  set.seed(123)
  r <- randolist(n = 12, arms = c("A", "A", "B"))
  expect_true("ratio" %in% names(attributes(r)))
  expect_match(attr(r, "ratio"), "2:1")
})

test_that("randolist with single stratification variable adds stratum info", {
  set.seed(123)
  r <- randolist(10, strata = list(sex = c("M", "F")))

  expect_true("stratum" %in% names(r))
  expect_true("sex" %in% names(r))
  expect_true(attr(r, "stratified"))
  expect_equal(as.character(sort(unique(r$sex))), c("M", "F"))
})

test_that("randolist with two stratification variables expands all combinations", {
  set.seed(123)
  strata <- list(sex = c("M", "F"), age = c("child", "adult"))
  r <- randolist(10, strata = strata)

  expect_equal(length(unique(r$stratum)), 4)  # 2x2 combinations
  expect_true(all(c("sex", "age") %in% names(r)))
  expect_true(all(r$age %in% c("child", "adult")))
  expect_true(all(r$sex %in% c("M", "F")))
})

test_that("randolist attributes are correctly set", {
  r <- randolist(10, arms = c("arm1", "arm2"))
  expect_equal(attr(r, "arms"), c("arm1", "arm2"))
  expect_false(attr(r, "stratified"))
})

test_that("randolist can generate non-block randomisation if blocksizes = n", {
  r <- randolist(10, blocksizes = 5)
  expect_equal(nrow(r), 10)
  expect_true(all(r$arm %in% c("A", "B")))
})

test_that("randolist errors or warns on invalid input", {
  expect_error(randolist(n = -1))
  expect_error(randolist(n = 5, arms = NULL))
})

test_that("error if incorrect number of init_probs supplied", {
  expect_error(randolist(10, n_init = 3, init_probs = c(.9, .8, .1, 0)))
  expect_error(randolist(10, n_init = 3, init_probs = 1))
  expect_error(randolist(10, n_init = 3))
})
