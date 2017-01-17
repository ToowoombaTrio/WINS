context("rmse")

test_that("rmse is calculated correctly", {
actual <- c(4, 6, 9, 10, 4, 6, 4, 7, 8, 7)
predicted <- c(5, 6, 8, 10, 4, 8, 4, 9, 8, 9)
expect_equal(rmse(actual, predicted), 1.183216, tolerance = 1e-3)
})