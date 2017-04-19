context("mae")

test_that("mae is calculated correctly", {
actual <- c(4, 6, 9, 10, 4, 6, 4, 7, 8, 7)
predicted <- c(5, 6, 8, 10, 4, 8, 4, 9, 8, 9)

expect_equal(mae(actual, predicted), 0.8)
})