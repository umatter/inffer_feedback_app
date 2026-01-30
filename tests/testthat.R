# Test runner for R Code Feedback App
# Run with: Rscript tests/testthat.R

library(testthat)

# Set working directory to app folder for sourcing
original_wd <- getwd()
app_dir <- file.path(dirname(dirname(sys.frame(1)$ofile %||% ".")), "app")
if (dir.exists(app_dir)) {
  setwd(app_dir)
}

# Source helper to load functions without starting app
source("test-helper.R", local = TRUE)

# Reset working directory
setwd(original_wd)

# Run tests
test_dir("testthat", reporter = "summary")
