# Tests for Custom Exercise Upload functionality

# Load required files
source("../../app/R/config.R")
source("../../app/R/feedback_functions.R")

test_that("validate_exercises_json accepts valid exercises", {
  valid_json <- list(
    exercises = list(
      ex1 = list(
        title = "Test Exercise",
        description = "A test exercise",
        task = "Do the task",
        category = "Data Import",
        difficulty = "Beginner"
      )
    )
  )

  result <- validate_exercises_json(valid_json)

  expect_true(result$valid)
  expect_equal(length(result$errors), 0)
  expect_equal(length(result$exercises), 1)
})

test_that("validate_exercises_json rejects missing exercises key", {
  invalid_json <- list(
    data = list(something = "else")
  )

  result <- validate_exercises_json(invalid_json)

  expect_false(result$valid)
  expect_true(length(result$errors) > 0)
  expect_true(grepl("exercises", result$errors[1]))
})

test_that("validate_exercises_json rejects empty exercises", {
  empty_json <- list(
    exercises = list()
  )

  result <- validate_exercises_json(empty_json)

  expect_false(result$valid)
})

test_that("validate_exercises_json checks required fields", {
  missing_fields <- list(
    exercises = list(
      ex1 = list(
        title = "Test"
        # Missing: description, task, category, difficulty
      )
    )
  )

  result <- validate_exercises_json(missing_fields)

  expect_false(result$valid)
  expect_true(any(grepl("description", result$errors)))
  expect_true(any(grepl("task", result$errors)))
  expect_true(any(grepl("category", result$errors)))
  expect_true(any(grepl("difficulty", result$errors)))
})

test_that("validate_exercises_json checks valid categories", {
  invalid_category <- list(
    exercises = list(
      ex1 = list(
        title = "Test",
        description = "Desc",
        task = "Task",
        category = "Invalid Category",
        difficulty = "Beginner"
      )
    )
  )

  result <- validate_exercises_json(invalid_category)

  expect_false(result$valid)
  expect_true(any(grepl("category", result$errors)))
})

test_that("validate_exercises_json checks valid difficulties", {
  invalid_difficulty <- list(
    exercises = list(
      ex1 = list(
        title = "Test",
        description = "Desc",
        task = "Task",
        category = "Data Import",
        difficulty = "Super Hard"
      )
    )
  )

  result <- validate_exercises_json(invalid_difficulty)

  expect_false(result$valid)
  expect_true(any(grepl("difficulty", result$errors)))
})

test_that("validate_exercises_json accepts multiple valid exercises", {
  multi_json <- list(
    exercises = list(
      ex1 = list(
        title = "Test 1",
        description = "Desc 1",
        task = "Task 1",
        category = "Data Import",
        difficulty = "Beginner"
      ),
      ex2 = list(
        title = "Test 2",
        description = "Desc 2",
        task = "Task 2",
        category = "Data Visualization",
        difficulty = "Advanced"
      )
    )
  )

  result <- validate_exercises_json(multi_json)

  expect_true(result$valid)
  expect_equal(length(result$exercises), 2)
})

test_that("generate_exercise_template creates valid JSON", {
  template <- generate_exercise_template()

  # Should be valid JSON
  parsed <- jsonlite::fromJSON(template)

  expect_true(!is.null(parsed$exercises))
  expect_true(length(parsed$exercises) >= 1)
  expect_true(!is.null(parsed$categories))
  expect_true(!is.null(parsed$difficulties))
})
