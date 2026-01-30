# Tests for check_rules() function

# Helper to create exercise context
make_exercise <- function(category) {
  list(
    title = "Test Exercise",
    description = "Test description",
    task = "Test task",
    reference_solution = "",
    category = category,
    difficulty = "Beginner"
  )
}

# Data Import category tests
test_that("check_rules detects missing readxl library for Data Import", {
  code <- "data <- read_excel('file.xlsx')"
  exercise <- make_exercise("Data Import")
  result <- check_rules(code, exercise)

  expect_true("Missing library(readxl) - needed for Excel import" %in% result$issues)
})

test_that("check_rules detects missing read_excel call for Data Import", {
  code <- "library(readxl)\ndata <- read.csv('file.csv')"
  exercise <- make_exercise("Data Import")
  result <- check_rules(code, exercise)

  expect_true("Use read_excel() function to import Excel files" %in% result$issues)
})

test_that("check_rules recognizes str() as good practice", {
  code <- "library(readxl)\ndata <- read_excel('file.xlsx')\nstr(data)"
  exercise <- make_exercise("Data Import")
  result <- check_rules(code, exercise)

  expect_true(any(grepl("str\\(\\)", result$good_practices)))
})

test_that("check_rules recognizes head() as good practice", {
  code <- "library(readxl)\ndata <- read_excel('file.xlsx')\nhead(data)"
  exercise <- make_exercise("Data Import")
  result <- check_rules(code, exercise)

  expect_true(any(grepl("head\\(\\)", result$good_practices)))
})

# Descriptive Statistics category tests
test_that("check_rules recognizes na.rm = TRUE as good practice", {
  code <- "mean(data$x, na.rm = TRUE)"
  exercise <- make_exercise("Descriptive Statistics")
  result <- check_rules(code, exercise)

  expect_true(any(grepl("na.rm", result$good_practices)))
})

test_that("check_rules suggests na.rm when using mean without it", {
  code <- "mean(data$x)"
  exercise <- make_exercise("Descriptive Statistics")
  result <- check_rules(code, exercise)

  expect_true(any(grepl("na.rm", result$suggestions)))
})

test_that("check_rules recognizes multiple stat functions", {
  code <- "mean(x, na.rm=TRUE)\nmedian(x, na.rm=TRUE)"
  exercise <- make_exercise("Descriptive Statistics")
  result <- check_rules(code, exercise)

  expect_true(any(grepl("mean", result$good_practices)))
  expect_true(any(grepl("median", result$good_practices)))
})

# Data Manipulation category tests
test_that("check_rules recognizes pipe operator as excellent practice", {
  code <- "data |> filter(x > 5) |> select(y)"
  exercise <- make_exercise("Data Manipulation")
  result <- check_rules(code, exercise)

  expect_true(any(grepl("pipe operator", result$good_practices)))
})

test_that("check_rules suggests pipe when using dplyr without it", {
  code <- "filter(data, x > 5)"
  exercise <- make_exercise("Data Manipulation")
  result <- check_rules(code, exercise)

  expect_true(any(grepl("pipe", result$suggestions)))
})

# Data Visualization category tests
test_that("check_rules recognizes main title as good practice", {
  code <- "hist(data$x, main = 'Distribution')"
  exercise <- make_exercise("Data Visualization")
  result <- check_rules(code, exercise)

  expect_true(any(grepl("main title", result$good_practices)))
})

test_that("check_rules suggests main title when missing", {
  code <- "hist(data$x)"
  exercise <- make_exercise("Data Visualization")
  result <- check_rules(code, exercise)

  expect_true(any(grepl("main title", result$suggestions)))
})

test_that("check_rules recognizes axis labels as excellent practice", {
  code <- "plot(x, y, xlab = 'X axis', ylab = 'Y axis')"
  exercise <- make_exercise("Data Visualization")
  result <- check_rules(code, exercise)

  expect_true(any(grepl("axis label", result$good_practices)))
})

# Custom category tests
test_that("check_rules handles unknown category gracefully", {
  code <- "print('hello world')"
  exercise <- make_exercise("Unknown Category")
  result <- check_rules(code, exercise)

  # Should return empty results, not error

expect_equal(length(result$issues), 0)
  expect_equal(length(result$good_practices), 0)
  expect_equal(length(result$suggestions), 0)
})
