# Integration tests for R Code Feedback App
# These tests verify the complete analysis workflow

# Note: Full shinytest2 integration tests require a running Shiny server
# and are not compatible with Shinylive deployment. These tests focus on
# the integration between modules without requiring the UI.

test_that("complete analysis workflow works for valid R code", {
  # Create exercise context
  exercise <- list(
    title = "Test Exercise",
    description = "Test description",
    task = "Calculate the mean",
    reference_solution = "mean(x)",
    category = "Descriptive Statistics",
    difficulty = "Beginner"
  )

  # Sample R code
  code <- "x <- c(1, 2, 3, 4, 5)\nmean(x, na.rm = TRUE)"

  # Run syntax check
  syntax_result <- check_syntax(code)
  expect_true(syntax_result$valid)

  # Run rule-based analysis
  rules_result <- check_rules(code, exercise)
  expect_true(any(grepl("na.rm", rules_result$good_practices)))
  expect_true(any(grepl("mean", rules_result$good_practices)))
})

test_that("complete analysis workflow detects syntax errors", {
  exercise <- list(category = "Custom")
  code <- "x <- c(1, 2, 3"  # Missing closing parenthesis

  syntax_result <- check_syntax(code)
  expect_false(syntax_result$valid)
  expect_match(syntax_result$message, "error", ignore.case = TRUE)
})

test_that("API request preparation works for all providers", {
  exercise <- list(
    description = "Test exercise",
    task = "Do something"
  )
  code <- "print('hello')"

  # Test OpenAI
  openai_req <- prepare_api_request(code, exercise, "openai", "sk-test123")
  expect_equal(openai_req$url, LLM_PROVIDERS$openai$api_endpoint)
  expect_true(!is.null(openai_req$requestId))
  expect_match(openai_req$headers$Authorization, "Bearer")

  # Test Anthropic
  anthropic_req <- prepare_api_request(code, exercise, "anthropic", "sk-ant-test123")
  expect_equal(anthropic_req$url, LLM_PROVIDERS$anthropic$api_endpoint)
  expect_true(!is.null(anthropic_req$headers$`x-api-key`))

  # Test OpenRouter
  openrouter_req <- prepare_api_request(code, exercise, "openrouter", "sk-or-test123", "deepseek/deepseek-chat")
  expect_equal(openrouter_req$url, LLM_PROVIDERS$openrouter$api_endpoint)
  expect_equal(openrouter_req$body$model, "deepseek/deepseek-chat")
})

test_that("API response parsing handles all provider formats", {
  # OpenAI format
  openai_response <- list(
    choices = list(
      list(message = list(content = "Great R code!"))
    )
  )
  openai_result <- parse_api_response(openai_response, "openai")
  expect_true(openai_result$available)
  expect_equal(openai_result$message, "Great R code!")

  # Anthropic format
  anthropic_response <- list(
    content = list(
      list(text = "Excellent work!")
    )
  )
  anthropic_result <- parse_api_response(anthropic_response, "anthropic")
  expect_true(anthropic_result$available)
  expect_equal(anthropic_result$message, "Excellent work!")

  # OpenRouter format (with thinking content to strip)
  openrouter_response <- list(
    choices = list(
      list(message = list(content = "<think>Let me analyze...</think>Good job!"))
    )
  )
  openrouter_result <- parse_api_response(openrouter_response, "openrouter", "deepseek/deepseek-chat")
  expect_true(openrouter_result$available)
  expect_false(grepl("<think>", openrouter_result$message))
})

test_that("exercise categories trigger appropriate rule checks", {
  categories <- c(
    "Data Import",
    "Descriptive Statistics",
    "Data Manipulation",
    "Data Visualization",
    "Statistical Analysis",
    "Data Cleaning"
  )

  for (cat in categories) {
    exercise <- list(category = cat)

    # Run with generic code
    result <- check_rules("x <- 1", exercise)

    # Should return valid structure
    expect_true(is.list(result))
    expect_true("issues" %in% names(result))
    expect_true("suggestions" %in% names(result))
    expect_true("good_practices" %in% names(result))
  }
})

test_that("request ID generation produces unique IDs", {
  ids <- replicate(100, generate_request_id())

  # All IDs should be unique
  expect_equal(length(unique(ids)), 100)

  # All IDs should match expected format
  expect_true(all(grepl("^req_\\d{14}_[0-9a-f]{16}$", ids)))
})

test_that("friendly error messages are generated correctly", {
  # Test HTTP status codes
  expect_match(get_friendly_error_message("", 401), "Invalid API key", ignore.case = TRUE)
  expect_match(get_friendly_error_message("", 429), "Rate limit", ignore.case = TRUE)
  expect_match(get_friendly_error_message("", 500), "unavailable", ignore.case = TRUE)

  # Test error message patterns
  expect_match(get_friendly_error_message("rate limit exceeded", NULL), "Rate limit", ignore.case = TRUE)
  expect_match(get_friendly_error_message("unauthorized", NULL), "Invalid API key", ignore.case = TRUE)
  expect_match(get_friendly_error_message("timeout", NULL), "timed out", ignore.case = TRUE)
})

test_that("configuration constants are properly defined", {
  # Check that all required constants exist
  expect_true(exists("MAX_IMAGE_SIZE_BYTES"))
  expect_true(exists("DEFAULT_MAX_TOKENS"))
  expect_true(exists("DEFAULT_TEMPERATURE"))
  expect_true(exists("SCROLL_TO_FEEDBACK_DELAY_MS"))
  expect_true(exists("PATTERNS"))
  expect_true(exists("LLM_PROVIDERS"))
  expect_true(exists("API_KEY_PATTERNS"))

  # Check reasonable values
  expect_true(MAX_IMAGE_SIZE_BYTES > 0)
  expect_true(DEFAULT_MAX_TOKENS > 0)
  expect_true(DEFAULT_TEMPERATURE >= 0 && DEFAULT_TEMPERATURE <= 1)
  expect_true(SCROLL_TO_FEEDBACK_DELAY_MS > 0)
})

test_that("PATTERNS contains all required regex patterns", {
  required_patterns <- c(
    "library_readxl", "read_excel", "str_call", "head_call",
    "na_rm_true", "mean_call", "median_call", "sd_call",
    "pipe_operator", "filter_call", "select_call",
    "main_title", "xlab_arg", "ylab_arg",
    "cor_call", "is_na_call"
  )

  for (pattern_name in required_patterns) {
    expect_true(pattern_name %in% names(PATTERNS),
                info = paste("Missing pattern:", pattern_name))
  }
})
