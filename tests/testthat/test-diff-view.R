# Tests for Diff View functionality

# Load required files
source("../../app/R/config.R")
source("../../app/R/feedback_functions.R")

test_that("extract_code_blocks extracts R code blocks", {
  text <- "Here is some code:

```r
x <- 1
print(x)
```

And more text."

  result <- extract_code_blocks(text)

  expect_equal(length(result), 1)
  expect_true(grepl("x <- 1", result[1]))
  expect_true(grepl("print\\(x\\)", result[1]))
})

test_that("extract_code_blocks handles multiple code blocks", {
  text <- "First block:

```r
x <- 1
```

Second block:

```r
y <- 2
```"

  result <- extract_code_blocks(text)

  expect_equal(length(result), 2)
  expect_true(grepl("x <- 1", result[1]))
  expect_true(grepl("y <- 2", result[2]))
})

test_that("extract_code_blocks handles plain code blocks", {
  text <- "Code:

```
plain_code <- TRUE
```"

  result <- extract_code_blocks(text)

  expect_equal(length(result), 1)
  expect_true(grepl("plain_code", result[1]))
})

test_that("extract_code_blocks returns empty for no blocks", {
  text <- "No code blocks here, just text."

  result <- extract_code_blocks(text)

  expect_equal(length(result), 0)
})

test_that("extract_code_blocks handles empty input", {
  expect_equal(length(extract_code_blocks("")), 0)
  expect_equal(length(extract_code_blocks(NULL)), 0)
})

test_that("compare_code detects identical code", {
  code <- "x <- 1\nprint(x)"

  result <- compare_code(code, code)

  expect_false(result$has_changes)
})

test_that("compare_code detects added lines", {
  original <- "x <- 1"
  suggested <- "x <- 1\nprint(x)"

  result <- compare_code(original, suggested)

  expect_true(result$has_changes)
  expect_equal(length(result$suggested_lines), 2)
  expect_equal(result$suggested_lines[[2]]$status, "added")
})

test_that("compare_code detects removed lines", {
  original <- "x <- 1\nprint(x)"
  suggested <- "x <- 1"

  result <- compare_code(original, suggested)

  expect_true(result$has_changes)
  expect_true(any(sapply(result$original_lines, function(l) l$status == "removed")))
})

test_that("compare_code detects modified lines", {
  original <- "x <- 1"
  suggested <- "x <- 2"

  result <- compare_code(original, suggested)

  expect_true(result$has_changes)
  expect_equal(result$original_lines[[1]]$status, "removed")
  expect_equal(result$suggested_lines[[1]]$status, "added")
})

test_that("compare_code handles empty inputs", {
  result <- compare_code(NULL, NULL)
  expect_false(result$has_changes)

  result <- compare_code("", "")
  expect_false(result$has_changes)
})

test_that("find_suggested_correction finds similar code", {
  original <- "x <- mean(data)\nprint(x)"
  ai_feedback <- "Here's a better version:

```r
x <- mean(data, na.rm = TRUE)
print(x)
```

This handles missing values."

  result <- find_suggested_correction(ai_feedback, original)

  expect_true(!is.null(result))
  expect_true(grepl("na.rm = TRUE", result))
})

test_that("find_suggested_correction ignores identical code", {
  original <- "x <- 1\nprint(x)"
  ai_feedback <- "Your code:

```r
x <- 1
print(x)
```

is correct."

  result <- find_suggested_correction(ai_feedback, original)

  # Should return NULL since code is identical
  expect_null(result)
})

test_that("find_suggested_correction ignores unrelated code", {
  original <- "x <- 1"
  ai_feedback <- "Here's an unrelated example:

```r
df <- data.frame(a = 1:10, b = rnorm(10))
model <- lm(b ~ a, data = df)
summary(model)
```"

  result <- find_suggested_correction(ai_feedback, original)

  # Should return NULL since code is too different (< 30% overlap)
  expect_null(result)
})

test_that("find_suggested_correction handles empty inputs", {
  expect_null(find_suggested_correction("", "code"))
  expect_null(find_suggested_correction(NULL, "code"))
  expect_null(find_suggested_correction("text", ""))
  expect_null(find_suggested_correction("text", NULL))
})

test_that("find_suggested_correction finds valid correction", {
  original <- "x <- mean(data)"
  ai_feedback <- "Short fix:

```r
x <- mean(data, na.rm = TRUE)
```

Better version:

```r
# Calculate mean with proper error handling
x <- mean(data, na.rm = TRUE)
print(paste('Mean:', x))
```"

  result <- find_suggested_correction(ai_feedback, original)

  # Should find a correction that adds na.rm = TRUE
  expect_true(!is.null(result))
  expect_true(grepl("na.rm = TRUE", result))
})
