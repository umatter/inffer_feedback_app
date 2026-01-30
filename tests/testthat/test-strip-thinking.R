# Tests for strip_thinking_content() function

test_that("strip_thinking_content removes <think> blocks", {
  text <- "<think>Let me analyze this code...</think>Great job with your R code!"
  result <- strip_thinking_content(text)

  expect_false(grepl("<think>", result))
  expect_match(result, "Great job")
})

test_that("strip_thinking_content removes <thinking> blocks", {
  text <- "<thinking>I should check for syntax errors first.</thinking>Your code looks good!"
  result <- strip_thinking_content(text)

  expect_false(grepl("<thinking>", result))
  expect_match(result, "Your code looks good")
})

test_that("strip_thinking_content removes multiline thinking blocks", {
  text <- "<think>
First, let me look at the structure.
Then I'll check for errors.
Finally, I'll provide feedback.
</think>

## Code Review

Your implementation is correct!"
  result <- strip_thinking_content(text)

  expect_false(grepl("<think>", result))
  expect_match(result, "Code Review")
})

test_that("strip_thinking_content removes 'Okay, let me' preambles", {
  text <- "Okay, let me analyze this code for you.\n\nGreat work on your solution!"
  result <- strip_thinking_content(text)

  expect_match(result, "Great work")
  expect_false(grepl("Okay, let me", result))
})

test_that("strip_thinking_content removes 'Let me analyze' preambles", {
  text <- "Let me analyze your code.\n\n## Feedback\n\nYour code is correct."
  result <- strip_thinking_content(text)

  # Should remove the preamble - result should not start with "Let me"
  expect_false(grepl("^Let me", result))
  # Should contain the actual feedback content
  expect_match(result, "code is correct|Feedback")
})

test_that("strip_thinking_content removes 'Looking at' preambles", {
  text <- "Looking at this code...\n\nHi! Your solution looks great!"
  result <- strip_thinking_content(text)

  expect_match(result, "Hi!")
})

test_that("strip_thinking_content preserves clean feedback", {
  text <- "Great job! Your R code demonstrates excellent understanding of data manipulation."
  result <- strip_thinking_content(text)

  expect_equal(result, text)
})

test_that("strip_thinking_content finds feedback after markdown headers", {
  text <- "I need to review this carefully.\n\n## Code Analysis\n\nYour code is well-structured."
  result <- strip_thinking_content(text)

  # Should remove thinking preamble and keep actual content
  expect_false(grepl("^I need to review", result))
  expect_match(result, "Code Analysis|well-structured")
})

test_that("strip_thinking_content handles empty string", {
  result <- strip_thinking_content("")
  expect_equal(result, "")
})

test_that("strip_thinking_content handles whitespace-only input", {
  result <- strip_thinking_content("   \n\n  ")
  expect_equal(result, "")
})

test_that("strip_thinking_content handles multiple thinking blocks", {
  text <- "<think>First thought</think>Some text<think>Second thought</think>Final answer"
  result <- strip_thinking_content(text)

  expect_false(grepl("<think>", result))
  expect_match(result, "Final answer")
})

test_that("strip_thinking_content preserves actual feedback content", {
  text <- "Great job!\n\n```r\nx <- 1:10\nmean(x)\n```\n\nYour code is correct."
  result <- strip_thinking_content(text)

  # Should preserve feedback - either starts with Great or contains correct
  expect_true(grepl("Great job|code is correct", result))
})
