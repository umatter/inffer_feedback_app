# Tests for Code Execution functionality

# Load required files
source("../../app/R/config.R")
source("../../app/R/feedback_functions.R")

test_that("execute_code_safely runs valid code", {
  result <- execute_code_safely("x <- 1 + 1\nprint(x)")

  expect_true(result$success)
  expect_true(grepl("2", result$output))
  expect_null(result$error)
})

test_that("execute_code_safely captures output", {
  result <- execute_code_safely("cat('hello world')")

  expect_true(result$success)
  expect_true(grepl("hello world", result$output))
})

test_that("execute_code_safely handles syntax errors", {
  result <- execute_code_safely("x <- ")

  expect_false(result$success)
  expect_true(!is.null(result$error))
  expect_true(grepl("error|Error", result$error, ignore.case = TRUE))
})

test_that("execute_code_safely handles runtime errors", {
  result <- execute_code_safely("stop('intentional error')")

  expect_false(result$success)
  expect_true(!is.null(result$error))
  expect_true(grepl("intentional error", result$error))
})

test_that("execute_code_safely captures warnings", {
  result <- execute_code_safely("warning('test warning')")

  expect_true(result$success)
  expect_true(length(result$warnings) > 0)
  expect_true(any(grepl("test warning", result$warnings)))
})

test_that("execute_code_safely handles empty code", {
  result <- execute_code_safely("")

  # Empty code is syntactically valid
  expect_true(result$success)
})

test_that("execute_code_safely handles multiline code", {
  code <- "
    x <- 1
    y <- 2
    z <- x + y
    print(z)
  "

  result <- execute_code_safely(code)

  expect_true(result$success)
  expect_true(grepl("3", result$output))
})

test_that("execute_code_safely handles vector operations", {
  result <- execute_code_safely("x <- 1:5\nmean(x)")

  expect_true(result$success)
})

test_that("execute_code_safely handles data frame operations", {
  code <- "
    df <- data.frame(a = 1:3, b = c('x', 'y', 'z'))
    print(df)
  "

  result <- execute_code_safely(code)

  expect_true(result$success)
  expect_true(grepl("a", result$output))
})

test_that("execute_code_safely isolates environment", {
  # First execution creates a variable
  execute_code_safely("test_var <- 123")

  # Second execution should not see it (isolated environment)
  result <- execute_code_safely("exists('test_var')")

  expect_true(result$success)
  # The variable should not exist in the global environment
  expect_false(exists("test_var", envir = globalenv()))
})

test_that("CODE_EXECUTION_TIMEOUT_SECONDS is defined", {
  expect_true(exists("CODE_EXECUTION_TIMEOUT_SECONDS"))
  expect_true(is.numeric(CODE_EXECUTION_TIMEOUT_SECONDS))
  expect_true(CODE_EXECUTION_TIMEOUT_SECONDS > 0)
})

test_that("execute_code_with_plot captures histogram", {
  result <- execute_code_with_plot("hist(1:10)")

  expect_true(result$success)
  expect_true(result$has_plot)
  expect_true(!is.null(result$plot_base64))
  expect_true(grepl("^data:image/png;base64,", result$plot_base64))
})

test_that("execute_code_with_plot captures ggplot if available", {
  skip_if_not_installed("ggplot2")

  result <- execute_code_with_plot("
    library(ggplot2)
    ggplot(data.frame(x = 1:10, y = 1:10), aes(x, y)) + geom_point()
  ")

  expect_true(result$success)
  expect_true(result$has_plot)
})

test_that("generate_reference_plot returns plot for valid code", {
  result <- generate_reference_plot("hist(rnorm(50))")

  expect_true(!is.null(result))
  expect_true(grepl("^data:image/png;base64,", result))
})

test_that("generate_reference_plot returns NULL for non-plot code", {
  result <- generate_reference_plot("x <- 1 + 1")

  expect_null(result)
})

test_that("generate_reference_plot returns NULL for empty code", {
  expect_null(generate_reference_plot(""))
  expect_null(generate_reference_plot(NULL))
})
