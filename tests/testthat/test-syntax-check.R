# Tests for check_syntax() function

test_that("check_syntax validates correct R code", {
  result <- check_syntax("x <- 1 + 2")
  expect_true(result$valid)
  expect_match(result$message, "Valid R syntax")
})

test_that("check_syntax validates multi-line code", {
  code <- "
  library(dplyr)
  data <- data.frame(x = 1:10)
  data |> filter(x > 5)
  "
  result <- check_syntax(code)
  expect_true(result$valid)
})

test_that("check_syntax catches missing closing parenthesis", {
  result <- check_syntax("mean(c(1, 2, 3)")
  expect_false(result$valid)
  expect_match(result$message, "Syntax error")
})

test_that("check_syntax catches incomplete assignment", {
  result <- check_syntax("x <- ")
  expect_false(result$valid)
  expect_match(result$message, "Syntax error")
})

test_that("check_syntax catches unmatched braces", {
  result <- check_syntax("if (TRUE) { print('hello')")
  expect_false(result$valid)
  expect_match(result$message, "Syntax error")
})

test_that("check_syntax handles empty string", {
  result <- check_syntax("")
  expect_true(result$valid)  # Empty string is valid R (no-op)
})

test_that("check_syntax handles comments only", {
  result <- check_syntax("# This is just a comment")
  expect_true(result$valid)
})

test_that("check_syntax validates pipe operator usage", {
  code <- "mtcars |> head() |> summary()"
  result <- check_syntax(code)
  expect_true(result$valid)
})

test_that("check_syntax catches truly invalid syntax", {
  result <- check_syntax("x @@ 5")  # Invalid operator
  expect_false(result$valid)
})

test_that("check_syntax validates function definitions", {
  code <- "
  my_func <- function(x, y) {
    return(x + y)
  }
  "
  result <- check_syntax(code)
  expect_true(result$valid)
})
