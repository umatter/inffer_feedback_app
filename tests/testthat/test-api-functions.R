# Tests for API-related functions

# API Key Validation Tests
test_that("validate_api_key rejects empty key", {
  result <- validate_api_key("", "openai")
  expect_false(result$valid)
  expect_match(result$message, "required")
})

test_that("validate_api_key rejects whitespace-only key", {
  result <- validate_api_key("   ", "openai")
  expect_false(result$valid)
})

test_that("validate_api_key validates OpenAI key prefix", {
  result <- validate_api_key("sk-abc123", "openai")
  expect_true(result$valid)
})

test_that("validate_api_key rejects invalid OpenAI key prefix", {
  result <- validate_api_key("invalid-key", "openai")
  expect_false(result$valid)
  expect_match(result$message, "sk-")
})

test_that("validate_api_key validates Anthropic key prefix", {
  result <- validate_api_key("sk-ant-abc123", "anthropic")
  expect_true(result$valid)
})

test_that("validate_api_key rejects invalid Anthropic key prefix", {
  result <- validate_api_key("sk-abc123", "anthropic")
  expect_false(result$valid)
  expect_match(result$message, "sk-ant-")
})

test_that("validate_api_key validates OpenRouter key prefix", {
  result <- validate_api_key("sk-or-abc123", "openrouter")
  expect_true(result$valid)
})

test_that("validate_api_key rejects invalid OpenRouter key prefix", {
  result <- validate_api_key("sk-abc123", "openrouter")
  expect_false(result$valid)
  expect_match(result$message, "sk-or-")
})

# API Response Parsing Tests
test_that("parse_api_response parses OpenAI response correctly", {
  data <- list(
    choices = list(
      list(message = list(content = "Great job with your code!"))
    )
  )
  result <- parse_api_response(data, "openai")

  expect_true(result$available)
  expect_equal(result$message, "Great job with your code!")
  expect_match(result$provider, "OpenAI")
})

test_that("parse_api_response parses Anthropic response correctly", {
  data <- list(
    content = list(
      list(text = "Your code looks excellent!")
    )
  )
  result <- parse_api_response(data, "anthropic")

  expect_true(result$available)
  expect_equal(result$message, "Your code looks excellent!")
  expect_match(result$provider, "Anthropic")
})

test_that("parse_api_response parses OpenRouter response correctly", {
  data <- list(
    choices = list(
      list(message = list(content = "Nice work on the data analysis!"))
    )
  )
  result <- parse_api_response(data, "openrouter", "deepseek/deepseek-chat")

  expect_true(result$available)
  expect_match(result$message, "Nice work")
  expect_match(result$provider, "OpenRouter")
})

test_that("parse_api_response strips thinking content from OpenRouter", {
  data <- list(
    choices = list(
      list(message = list(content = "<think>Analyzing...</think>Great feedback!"))
    )
  )
  result <- parse_api_response(data, "openrouter", "deepseek/deepseek-chat")

  expect_true(result$available)
  expect_false(grepl("<think>", result$message))
  expect_match(result$message, "Great feedback")
})

test_that("parse_api_response handles empty choices", {
  data <- list(choices = list())
  result <- parse_api_response(data, "openai")

  expect_false(result$available)
  expect_match(result$message, "Unexpected response")
})

test_that("parse_api_response handles missing content field", {
  data <- list(
    choices = list(
      list(message = list())  # No content field
    )
  )
  result <- parse_api_response(data, "openai")

  expect_false(result$available)
})

test_that("parse_api_response handles NULL data gracefully", {
  result <- parse_api_response(NULL, "openai")

  expect_false(result$available)
  expect_match(result$message, "Error")
})

test_that("parse_api_response handles unknown provider", {
  data <- list(some = "data")
  result <- parse_api_response(data, "unknown_provider")

  expect_false(result$available)
})

# LLM Providers Configuration Tests
test_that("LLM_PROVIDERS contains expected providers", {
  expect_true("openai" %in% names(LLM_PROVIDERS))
  expect_true("anthropic" %in% names(LLM_PROVIDERS))
  expect_true("openrouter" %in% names(LLM_PROVIDERS))
})

test_that("OpenRouter has available_models defined", {
  expect_true(!is.null(LLM_PROVIDERS$openrouter$available_models))
  expect_true(length(LLM_PROVIDERS$openrouter$available_models) > 0)
})

test_that("OpenRouter has default_model defined", {
  expect_true(!is.null(LLM_PROVIDERS$openrouter$default_model))
  expect_true(LLM_PROVIDERS$openrouter$default_model %in% names(LLM_PROVIDERS$openrouter$available_models))
})
