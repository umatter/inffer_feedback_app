# Tests for Feedback Export functionality

# Load required files
source("../../app/R/config.R")
source("../../app/R/feedback_functions.R")

test_that("format_feedback_markdown generates valid markdown", {
  feedback <- list(
    syntax_check = list(valid = TRUE, message = "Valid R syntax"),
    rule_based = list(
      issues = c("Missing library"),
      good_practices = c("Good naming"),
      suggestions = c("Add comments")
    ),
    ai_feedback = list(
      available = TRUE,
      message = "Great work!",
      provider = "Test Provider"
    )
  )

  exercise <- list(
    title = "Test Exercise",
    description = "A test description",
    task = "Do the task"
  )

  code <- "x <- 1\nprint(x)"

  result <- format_feedback_markdown(feedback, exercise, code, "en")

  # Check basic structure
  expect_true(grepl("# R Code Feedback Report", result))
  expect_true(grepl("## Exercise", result))
  expect_true(grepl("## Submitted Code", result))
  expect_true(grepl("## Syntax Check", result))
  expect_true(grepl("```r", result))
  expect_true(grepl("x <- 1", result))
})

test_that("format_feedback_markdown includes issues", {
  feedback <- list(
    syntax_check = list(valid = TRUE, message = "Valid"),
    rule_based = list(
      issues = c("Issue 1", "Issue 2"),
      good_practices = character(0),
      suggestions = character(0)
    ),
    ai_feedback = NULL
  )

  result <- format_feedback_markdown(feedback, NULL, "code", "en")

  expect_true(grepl("## Issues Found", result))
  expect_true(grepl("Issue 1", result))
  expect_true(grepl("Issue 2", result))
})

test_that("format_feedback_markdown includes good practices", {
  feedback <- list(
    syntax_check = list(valid = TRUE, message = "Valid"),
    rule_based = list(
      issues = character(0),
      good_practices = c("Good 1", "Good 2"),
      suggestions = character(0)
    ),
    ai_feedback = NULL
  )

  result <- format_feedback_markdown(feedback, NULL, "code", "en")

  expect_true(grepl("## Good Practices", result))
  expect_true(grepl("Good 1", result))
})

test_that("format_feedback_markdown includes suggestions", {
  feedback <- list(
    syntax_check = list(valid = TRUE, message = "Valid"),
    rule_based = list(
      issues = character(0),
      good_practices = character(0),
      suggestions = c("Suggestion 1")
    ),
    ai_feedback = NULL
  )

  result <- format_feedback_markdown(feedback, NULL, "code", "en")

  expect_true(grepl("## Suggestions", result))
  expect_true(grepl("Suggestion 1", result))
})

test_that("format_feedback_markdown includes AI feedback", {
  feedback <- list(
    syntax_check = list(valid = TRUE, message = "Valid"),
    rule_based = list(
      issues = character(0),
      good_practices = character(0),
      suggestions = character(0)
    ),
    ai_feedback = list(
      available = TRUE,
      message = "AI says this is great!",
      provider = "TestAI"
    )
  )

  result <- format_feedback_markdown(feedback, NULL, "code", "en")

  expect_true(grepl("## AI Feedback", result))
  expect_true(grepl("AI says this is great!", result))
  expect_true(grepl("TestAI", result))
})

test_that("format_feedback_markdown handles syntax errors", {
  feedback <- list(
    syntax_check = list(valid = FALSE, message = "Unexpected symbol"),
    rule_based = list(
      issues = character(0),
      good_practices = character(0),
      suggestions = character(0)
    ),
    ai_feedback = NULL
  )

  result <- format_feedback_markdown(feedback, NULL, "bad code", "en")

  expect_true(grepl("\\*\\*Error:\\*\\*", result))
  expect_true(grepl("Unexpected symbol", result))
})

test_that("format_feedback_markdown includes footer", {
  feedback <- list(
    syntax_check = list(valid = TRUE, message = "Valid"),
    rule_based = list(
      issues = character(0),
      good_practices = character(0),
      suggestions = character(0)
    ),
    ai_feedback = NULL
  )

  result <- format_feedback_markdown(feedback, NULL, "code", "en")

  expect_true(grepl("BFH R Code Feedback App", result))
})
