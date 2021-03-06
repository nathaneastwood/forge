context("certify")

test_that("certify() works with arbitrary functions", {
  expect_identical(c(certify(42, ~ .x > 41)), 42)
  expect_error(certify(42, ~ .x > 42), "Condition `~\\.x > 42` not satisfied for `x`\\.")
  expect_error(certify(42, function(x) x > 42), "Condition `function\\(x\\) x > 42` not satisfied for `x`\\.")
})

test_that("certify() works with multiple conditions", {
  expect_identical(c(certify(42, ~ .x > 41, ~ .x < 43)), 42)
  expect_error(certify(42, ~ .x > 41, ~ .x < 39), "Condition `~\\.x < 39` not satisfied for `x`\\.")
  expect_error(certify(42, ~ .x < 39, ~ .x > 43), "Condition `~\\.x < 39` not satisfied for `x`\\.")
})

test_that("certify() helper functions work for scalar values", {
  expect_identical(c(certify(42, bounded(41, 43))), 42)
  expect_error(certify(42, bounded(43, 44)), "Condition `bounded\\(43, 44\\)` not satisfied for `x`\\.")
  expect_identical(c(certify(42, bounded(42, 43, incl_lower = TRUE))), 42)
  expect_error(certify(42, bounded(41, 42, incl_upper = FALSE)), "Condition `bounded\\(41, 42, incl_upper = FALSE\\)` not satisfied for `x`\\.")
  expect_identical(c(certify(42, lt(43))), 42)
  expect_error(certify(42, lt(42)), "Condition `lt\\(42\\)` not satisfied for `x`\\.")
  expect_identical(c(certify(42, lte(42))), 42)
  expect_identical(c(certify(42, gt(41))), 42)
  expect_error(certify(42, gt(42)), "Condition `gt\\(42\\)` not satisfied for `x`\\.")
  expect_identical(c(certify(42, gte(42))), 42)
})

test_that("certify() helper functions work for vector values", {
  expect_identical(c(certify(1:2, gt(0))), 1:2)
  expect_identical(c(certify(1:2, gte(1:2))), 1:2)
  expect_error(certify(1:2, gt(1)), "Condition `gt\\(1\\)` not satisfied for `x`\\.")
  expect_identical(c(certify(1:5, bounded(1, 5))), 1:5)
  expect_error(certify(1:5, bounded(1, 5, incl_lower = FALSE)), "Condition `bounded\\(1, 5, incl_lower = FALSE\\)` not satisfied for `x`\\.")
})

test_that("certify() allow_null argument works", {
  my_null <- NULL
  expect_error(cast_nullable_double_list(my_null) %>% certify(bounded(1, 3)),
               "`x` must not be NULL\\.")
  expect_identical(certify(NULL, bounded(1, 3), allow_null = TRUE), NULL)
})

test_that("id gets carried through forge pipes", {
  library(magrittr)
  foo <- 42
  expect_error(
    cast_scalar_integer(foo, return_id = TRUE) %>%
      certify(gt(42)),
    "Condition `gt\\(42\\)` not satisfied for `foo`\\."
  )

  expect_error(
    cast_scalar_integer(foo, id = "bar", return_id = TRUE) %>%
      certify(gt(42)),
    "Condition `gt\\(42\\)` not satisfied for `bar`\\."
  )
})
