# Feedback analysis functions for R Code Feedback App
# Contains syntax checking, rule-based analysis, and feedback UI generation

# =============================================================================
# Syntax Checking
# =============================================================================

#' Check R code syntax validity
#'
#' @param code Character string containing R code to validate
#' @return List with 'valid' (logical) and 'message' (character)
#' @examples
#' check_syntax("x <- 1 + 2")
#' check_syntax("x <- ")  # Invalid
check_syntax <- function(code) {
  tryCatch({
    parse(text = code)
    list(valid = TRUE, message = "Valid R syntax (parseable)")
  }, error = function(e) {
    error_msg <- conditionMessage(e)
    list(valid = FALSE, message = paste("Syntax error:", error_msg))
  })
}

# =============================================================================
# Rule-Based Pattern Checking
# =============================================================================

#' Analyze R code against category-specific rules
#'
#' @param code Character string containing R code to analyze
#' @param exercise List containing exercise metadata including 'category'
#' @return List with 'issues', 'suggestions', and 'good_practices' vectors
#'
#' @details
#' Supported categories:
#' - Data Import: Checks for readxl, read_excel, str, head
#' - Descriptive Statistics: Checks for na.rm, mean, median, sd
#' - Data Manipulation: Checks for pipes, dplyr functions
#' - Data Visualization: Checks for titles, labels, plot types
#' - Statistical Analysis: Checks for correlation
#' - Data Cleaning: Checks for is.na
#'
#' @examples
#' exercise <- list(category = "Data Import")
#' check_rules("library(readxl)\ndata <- read_excel('file.xlsx')", exercise)
check_rules <- function(code, exercise) {
  issues <- c()
  suggestions <- c()
  good_practices <- c()

  # Helper function to check pattern
  has_pattern <- function(pattern_name) {
    grepl(PATTERNS[[pattern_name]], code)
  }

  # Category-specific checks
  if (exercise$category == "Data Import") {
    if (!has_pattern("library_readxl")) {
      issues <- c(issues, "Missing library(readxl) - needed for Excel import")
    }
    if (!has_pattern("read_excel")) {
      issues <- c(issues, "Use read_excel() function to import Excel files")
    }
    if (has_pattern("str_call")) {
      good_practices <- c(good_practices, "Great! Using str() to explore data structure")
    }
    if (has_pattern("head_call")) {
      good_practices <- c(good_practices, "Good practice using head() to preview data")
    }
  }

  if (exercise$category == "Descriptive Statistics") {
    if (has_pattern("na_rm_true")) {
      good_practices <- c(good_practices, "Excellent! Properly handling missing values with na.rm = TRUE")
    } else if (has_pattern("mean_call") || has_pattern("median_call") || has_pattern("sd_call")) {
      suggestions <- c(suggestions, "Consider adding na.rm = TRUE to handle missing values")
    }

    if (has_pattern("mean_call")) {
      good_practices <- c(good_practices, "Using mean() for central tendency")
    }
    if (has_pattern("median_call")) {
      good_practices <- c(good_practices, "Using median() - robust measure of center")
    }
    if (has_pattern("sd_call") || has_pattern("var_call")) {
      good_practices <- c(good_practices, "Good use of variability measures")
    }
  }

  if (exercise$category == "Data Manipulation") {
    if (has_pattern("pipe_operator")) {
      good_practices <- c(good_practices, "Excellent use of pipe operator for readable code!")
    } else if (has_pattern("filter_call") || has_pattern("select_call") || has_pattern("mutate_call")) {
      suggestions <- c(suggestions, "Consider using pipe operator |> for cleaner code flow")
    }

    if (has_pattern("library_dplyr")) {
      good_practices <- c(good_practices, "Good practice loading dplyr library")
    }
    if (has_pattern("filter_call")) {
      good_practices <- c(good_practices, "Using filter() for data subsetting")
    }
    if (has_pattern("select_call")) {
      good_practices <- c(good_practices, "Using select() to choose specific columns")
    }
  }

  if (exercise$category == "Data Visualization") {
    if (has_pattern("main_title")) {
      good_practices <- c(good_practices, "Good practice adding a main title")
    } else {
      suggestions <- c(suggestions, "Consider adding a main title with main = 'Your Title'")
    }

    if (has_pattern("xlab_arg") || has_pattern("ylab_arg")) {
      good_practices <- c(good_practices, "Excellent axis labeling!")
    } else {
      suggestions <- c(suggestions, "Add axis labels with xlab and ylab for clarity")
    }

    if (has_pattern("hist_call")) {
      good_practices <- c(good_practices, "Using histogram for continuous data distribution")
    }
    if (has_pattern("boxplot_call")) {
      good_practices <- c(good_practices, "Boxplot is great for comparing groups")
    }
  }

  if (exercise$category == "Statistical Analysis") {
    if (has_pattern("cor_call")) {
      good_practices <- c(good_practices, "Using correlation to examine relationships")
    }
  }

  if (exercise$category == "Data Cleaning") {
    if (has_pattern("is_na_call")) {
      good_practices <- c(good_practices, "Good use of is.na() to check missing values")
    }
  }

  list(issues = issues, suggestions = suggestions, good_practices = good_practices)
}

# =============================================================================
# Feedback UI Generation
# =============================================================================

#' Create feedback UI elements from analysis results
#'
#' @param feedback List containing syntax_check, rule_based, and ai_feedback results
#' @param lang Language code for translations ("en", "de", "fr")
#' @return Shiny tagList with formatted feedback display
create_feedback_ui <- function(feedback, lang) {
  ui_elements <- list()

  # Syntax feedback
  if (feedback$syntax_check$valid) {
    ui_elements <- append(ui_elements, list(
      div(class = "alert alert-success",
          tags$strong("\u2713 Syntax: "), feedback$syntax_check$message)
    ))
  } else {
    ui_elements <- append(ui_elements, list(
      div(class = "alert alert-danger",
          tags$strong("\u2717 Syntax: "), feedback$syntax_check$message)
    ))
  }

  # Rule-based feedback
  if (length(feedback$rule_based$issues) > 0) {
    ui_elements <- append(ui_elements, list(
      div(class = "alert alert-warning",
          tags$strong("\u26a0\ufe0f Issues found:"),
          tags$ul(lapply(feedback$rule_based$issues, function(x) tags$li(x)))
      )
    ))
  }

  if (length(feedback$rule_based$good_practices) > 0) {
    ui_elements <- append(ui_elements, list(
      div(class = "alert alert-success",
          tags$strong("\u2705 Good practices:"),
          tags$ul(lapply(feedback$rule_based$good_practices, function(x) tags$li(x)))
      )
    ))
  }

  if (length(feedback$rule_based$suggestions) > 0) {
    ui_elements <- append(ui_elements, list(
      div(class = "alert alert-info",
          tags$strong("\U0001f4a1 Suggestions:"),
          tags$ul(lapply(feedback$rule_based$suggestions, function(x) tags$li(x)))
      )
    ))
  }

  # AI feedback
  if (!is.null(feedback$ai_feedback)) {
    if (feedback$ai_feedback$available) {
      ui_elements <- append(ui_elements, list(
        div(class = "alert alert-info",
            tags$strong("AI Feedback", if(!is.null(feedback$ai_feedback$provider)) paste0(" (", feedback$ai_feedback$provider, ")") else "", ":"),
            tags$div(
              style = "margin-top: 10px;",
              render_markdown_feedback(feedback$ai_feedback$message)
            )
        )
      ))
    } else {
      ui_elements <- append(ui_elements, list(
        div(class = "alert alert-secondary",
            tags$em(feedback$ai_feedback$message)
        )
      ))
    }
  }

  if (length(ui_elements) == 0) {
    ui_elements <- list(
      div(class = "alert alert-light",
          translate_text("Click 'Analyze Code' to get feedback on your R code.", lang)
      )
    )
  }

  return(do.call(tagList, ui_elements))
}

# =============================================================================
# Feedback Analysis Wrapper
# =============================================================================

#' Run synchronous feedback analysis (syntax + rules)
#'
#' @param student_code Character string containing code to analyze
#' @param exercise Exercise context list
#' @return List with syntax_check, rule_based, and ai_feedback (NULL) results
analyze_code <- function(student_code, exercise) {
  feedback <- list(
    syntax_check = check_syntax(student_code),
    rule_based = check_rules(student_code, exercise),
    ai_feedback = NULL
  )
  return(feedback)
}

# =============================================================================
# Custom Exercise Upload Validation
# =============================================================================

#' Validate uploaded exercises JSON structure
#'
#' @param json_data Parsed JSON data (list)
#' @return List with 'valid' (logical), 'exercises' (list or NULL), 'errors' (character vector)
#'
#' @details
#' Validates that:
#' - JSON has 'exercises' key
#' - Each exercise has required fields
#' - Category and difficulty are valid values
#'
#' @examples
#' json_data <- list(exercises = list(ex1 = list(title = "Test", ...)))
#' validate_exercises_json(json_data)
validate_exercises_json <- function(json_data) {
  errors <- character(0)

  # Check for exercises key
  if (is.null(json_data$exercises)) {
    return(list(
      valid = FALSE,
      exercises = NULL,
      errors = "JSON must contain an 'exercises' object"
    ))
  }

  exercises <- json_data$exercises

  # Check if exercises is a named list
  if (!is.list(exercises) || length(exercises) == 0) {
    return(list(
      valid = FALSE,
      exercises = NULL,
      errors = "The 'exercises' object must contain at least one exercise"
    ))
  }

  # Validate each exercise
  for (ex_id in names(exercises)) {
    ex <- exercises[[ex_id]]

    # Check required fields
    for (field in EXERCISE_REQUIRED_FIELDS) {
      if (is.null(ex[[field]]) || ex[[field]] == "") {
        errors <- c(errors, paste0("Exercise '", ex_id, "': missing required field '", field, "'"))
      }
    }

    # Validate category
    if (!is.null(ex$category) && !ex$category %in% VALID_CATEGORIES) {
      errors <- c(errors, paste0(
        "Exercise '", ex_id, "': invalid category '", ex$category,
        "'. Valid: ", paste(VALID_CATEGORIES, collapse = ", ")
      ))
    }

    # Validate difficulty
    if (!is.null(ex$difficulty) && !ex$difficulty %in% VALID_DIFFICULTIES) {
      errors <- c(errors, paste0(
        "Exercise '", ex_id, "': invalid difficulty '", ex$difficulty,
        "'. Valid: ", paste(VALID_DIFFICULTIES, collapse = ", ")
      ))
    }
  }

  if (length(errors) > 0) {
    return(list(
      valid = FALSE,
      exercises = NULL,
      errors = errors
    ))
  }

  return(list(
    valid = TRUE,
    exercises = exercises,
    errors = character(0)
  ))
}

#' Generate exercise template JSON for download
#'
#' @return Character string containing JSON template
generate_exercise_template <- function() {
  template <- list(
    exercises = list(
      my_exercise_1 = list(
        title = "My Custom Exercise",
        description = "Description of what students will learn",
        task = "What students should do: e.g., Load the data file and calculate summary statistics",
        reference_solution = "# Optional reference solution\ndata <- read.csv('file.csv')\nsummary(data)",
        category = "Data Import",
        difficulty = "Beginner"
      ),
      my_exercise_2 = list(
        title = "Another Exercise",
        description = "Another exercise description",
        task = "Create a histogram of the 'value' column",
        reference_solution = "hist(data$value, main = 'Distribution')",
        category = "Data Visualization",
        difficulty = "Intermediate"
      )
    ),
    categories = VALID_CATEGORIES,
    difficulties = VALID_DIFFICULTIES
  )

  jsonlite::toJSON(template, auto_unbox = TRUE, pretty = TRUE)
}

# =============================================================================
# Feedback Export Functions
# =============================================================================

#' Format feedback as Markdown for export
#'
#' @param feedback List containing syntax_check, rule_based, ai_feedback
#' @param exercise Exercise context list
#' @param student_code Character string of submitted code
#' @param lang Language code
#' @return Character string containing formatted Markdown
format_feedback_markdown <- function(feedback, exercise, student_code, lang = "en") {
  # Build header
  md <- paste0(
    "# R Code Feedback Report\n\n",
    "**Generated:** ", format(Sys.time(), "%Y-%m-%d %H:%M"), "\n\n",
    "---\n\n"
  )

  # Exercise section
  if (!is.null(exercise) && !is.null(exercise$title) && exercise$title != "Custom Exercise") {
    md <- paste0(md,
      "## Exercise\n\n",
      "**", exercise$title, "**\n\n",
      if (!is.null(exercise$description)) paste0(exercise$description, "\n\n") else "",
      if (!is.null(exercise$task)) paste0("**Task:** ", exercise$task, "\n\n") else ""
    )
  } else if (!is.null(exercise$description) && exercise$description != "") {
    md <- paste0(md,
      "## Exercise\n\n",
      exercise$description, "\n\n"
    )
  }

  # Submitted code section
  md <- paste0(md,
    "## Submitted Code\n\n",
    "```r\n",
    student_code,
    "\n```\n\n"
  )

  # Syntax check section
  md <- paste0(md,
    "## Syntax Check\n\n",
    if (feedback$syntax_check$valid)
      paste0("**Valid:** ", feedback$syntax_check$message, "\n\n")
    else
      paste0("**Error:** ", feedback$syntax_check$message, "\n\n")
  )

  # Rule-based feedback
  if (length(feedback$rule_based$issues) > 0) {
    md <- paste0(md,
      "## Issues Found\n\n",
      paste0("- ", feedback$rule_based$issues, collapse = "\n"), "\n\n"
    )
  }

  if (length(feedback$rule_based$good_practices) > 0) {
    md <- paste0(md,
      "## Good Practices\n\n",
      paste0("- ", feedback$rule_based$good_practices, collapse = "\n"), "\n\n"
    )
  }

  if (length(feedback$rule_based$suggestions) > 0) {
    md <- paste0(md,
      "## Suggestions\n\n",
      paste0("- ", feedback$rule_based$suggestions, collapse = "\n"), "\n\n"
    )
  }

  # AI feedback section
  if (!is.null(feedback$ai_feedback) && feedback$ai_feedback$available) {
    md <- paste0(md,
      "## AI Feedback",
      if (!is.null(feedback$ai_feedback$provider))
        paste0(" (", feedback$ai_feedback$provider, ")")
      else "",
      "\n\n",
      feedback$ai_feedback$message, "\n\n"
    )
  }

  # Footer
  md <- paste0(md,
    "---\n\n",
    "*Generated by [BFH R Code Feedback App](https://umatter.github.io/inffer_feedback_app)*\n"
  )

  return(md)
}

# =============================================================================
# Code Execution Functions
# =============================================================================

#' Execute R code safely in isolated environment
#'
#' @param code Character string containing R code to execute
#' @param timeout_seconds Maximum execution time in seconds
#' @return List with 'success', 'output', 'error', 'warnings', 'has_plot'
#'
#' @details
#' Executes code in an isolated environment with:
#' - Output capture via capture.output()
#' - Warning capture via withCallingHandlers()
#' - Error handling via tryCatch()
#' - Plot detection
execute_code_safely <- function(code, timeout_seconds = CODE_EXECUTION_TIMEOUT_SECONDS) {
  # First check syntax
  syntax <- check_syntax(code)
  if (!syntax$valid) {
    return(list(
      success = FALSE,
      output = "",
      error = syntax$message,
      warnings = character(0),
      has_plot = FALSE
    ))
  }

  # Create execution environment with access to base R packages
  # Using globalenv() as parent allows access to loaded packages while
  # still isolating user-created variables
  exec_env <- new.env(parent = globalenv())

  # Add common packages to environment if loaded
  # This allows access to base R functions
  for (pkg in c("base", "stats", "graphics", "grDevices", "utils", "datasets", "methods")) {
    if (pkg %in% loadedNamespaces()) {
      try(attach(asNamespace(pkg), name = paste0("pkg:", pkg), warn.conflicts = FALSE), silent = TRUE)
    }
  }

  # Capture warnings
  warnings_list <- character(0)

  # Capture output and execute
  output <- ""
  error_msg <- NULL
  has_plot <- FALSE

  result <- tryCatch({
    # Set timeout (partial support in webR)
    # Note: setTimeLimit may not work fully in webR/WASM
    old_time_limit <- getOption("warn")
    on.exit(options(warn = old_time_limit), add = TRUE)

    # Capture output
    output <- capture.output({
      withCallingHandlers(
        {
          # Check if code produces a plot
          # We detect plot by checking if graphics device is used
          old_dev <- dev.cur()

          # Execute the code
          eval(parse(text = code), envir = exec_env)

          # Check if new device was opened or current device was modified
          new_dev <- dev.cur()
          if (new_dev != old_dev || new_dev > 1) {
            has_plot <<- TRUE
          }
        },
        warning = function(w) {
          warnings_list <<- c(warnings_list, conditionMessage(w))
          invokeRestart("muffleWarning")
        }
      )
    }, type = "output")

    list(success = TRUE)
  }, error = function(e) {
    list(success = FALSE, error = conditionMessage(e))
  })

  if (result$success) {
    return(list(
      success = TRUE,
      output = paste(output, collapse = "\n"),
      error = NULL,
      warnings = warnings_list,
      has_plot = has_plot
    ))
  } else {
    return(list(
      success = FALSE,
      output = paste(output, collapse = "\n"),
      error = result$error,
      warnings = warnings_list,
      has_plot = FALSE
    ))
  }
}

#' Execute R code safely with plot capture (webR compatible)
#'
#' @param code Character string containing R code to execute
#' @param timeout_seconds Maximum execution time in seconds
#' @return List with 'success', 'output', 'error', 'warnings', 'has_plot', 'plot_base64'
#'
#' @details
#' Captures plots by rendering to a temporary PNG file and converting to base64.
#' This approach is compatible with webR/Shinylive WASM environment.
execute_code_with_plot <- function(code, timeout_seconds = CODE_EXECUTION_TIMEOUT_SECONDS) {
  # First check syntax
  syntax <- check_syntax(code)
  if (!syntax$valid) {
    return(list(
      success = FALSE,
      output = "",
      error = syntax$message,
      warnings = character(0),
      has_plot = FALSE,
      plot_base64 = NULL
    ))
  }

  # Create execution environment with access to base R packages
  # Using globalenv() as parent allows access to loaded packages while
  # still isolating user-created variables
  exec_env <- new.env(parent = globalenv())

  # Capture warnings
  warnings_list <- character(0)

  # Create temp file for plot capture
  plot_file <- tempfile(fileext = ".png")
  on.exit(unlink(plot_file), add = TRUE)

  # Capture output and execute
  output <- ""
  has_plot <- FALSE
  plot_base64 <- NULL

  result <- tryCatch({
    # Close any existing graphics devices
    while (dev.cur() > 1) {
      dev.off()
    }

    # Open PNG device to capture any plots
    png(plot_file, width = 800, height = 600, res = 96)

    # Capture output
    output <- capture.output({
      withCallingHandlers(
        {
          eval(parse(text = code), envir = exec_env)
        },
        warning = function(w) {
          warnings_list <<- c(warnings_list, conditionMessage(w))
          invokeRestart("muffleWarning")
        }
      )
    }, type = "output")

    # Close the device
    dev.off()

    # Check if plot was created (file exists and has content)
    if (file.exists(plot_file) && file.info(plot_file)$size > 0) {
      # Read and convert to base64
      plot_bytes <- readBin(plot_file, "raw", file.info(plot_file)$size)
      plot_base64 <- paste0("data:image/png;base64,", jsonlite::base64_enc(plot_bytes))
      has_plot <- TRUE
    }

    list(success = TRUE)
  }, error = function(e) {
    # Make sure to close the device on error
    if (dev.cur() > 1) try(dev.off(), silent = TRUE)
    list(success = FALSE, error = conditionMessage(e))
  })

  if (result$success) {
    return(list(
      success = TRUE,
      output = paste(output, collapse = "\n"),
      error = NULL,
      warnings = warnings_list,
      has_plot = has_plot,
      plot_base64 = plot_base64
    ))
  } else {
    return(list(
      success = FALSE,
      output = paste(output, collapse = "\n"),
      error = result$error,
      warnings = warnings_list,
      has_plot = FALSE,
      plot_base64 = NULL
    ))
  }
}

# =============================================================================
# Reference Plot Generation
# =============================================================================

#' Generate a plot from reference solution code
#'
#' @param reference_code Character string containing R code that generates a plot
#' @return Base64 encoded PNG image, or NULL if no plot generated
#'
#' @details
#' Executes the reference solution in an isolated environment and captures
#' any generated plot as a base64 PNG image.
generate_reference_plot <- function(reference_code) {
  if (is.null(reference_code) || trimws(reference_code) == "") {
    return(NULL)
  }

  # Check if code likely generates a plot
  plot_indicators <- c("plot(", "hist(", "barplot(", "boxplot(", "pie(",
                       "ggplot(", "geom_", "lines(", "points(", "abline(",
                       "curve(", "image(", "contour(", "pairs(", "mosaicplot(")
  has_plot_code <- any(sapply(plot_indicators, function(p) grepl(p, reference_code, fixed = TRUE)))

  if (!has_plot_code) {
    return(NULL)
  }

  # Use execute_code_with_plot to generate the reference plot
  result <- execute_code_with_plot(reference_code)

  if (result$success && result$has_plot && !is.null(result$plot_base64)) {
    return(result$plot_base64)
  }

  return(NULL)
}

# =============================================================================
# Diff View Functions
# =============================================================================

#' Extract R code blocks from markdown text
#'
#' @param text Character string containing markdown
#' @return Character vector of extracted code blocks
#'
#' @details
#' Extracts fenced code blocks with ```r or ``` markers
extract_code_blocks <- function(text) {
  if (is.null(text) || text == "") return(character(0))

  # Pattern for fenced code blocks: ```r or ``` followed by code and closing ```
  # Handles both ```r and ```R and plain ```
  # Use (?s) for DOTALL mode to match across newlines
  pattern <- "(?s)```[rR]?\\s*\\n(.*?)\\n```"

  matches <- gregexpr(pattern, text, perl = TRUE)
  if (matches[[1]][1] == -1) return(character(0))

  # Extract matched content
  code_blocks <- regmatches(text, matches)[[1]]

  # Remove the ``` markers - need to handle multiline
  code_blocks <- gsub("^```[rR]?\\s*\\n", "", code_blocks, perl = TRUE)
  code_blocks <- gsub("\\n```$", "", code_blocks, perl = TRUE)

  return(code_blocks)
}

#' Compare two code strings line by line
#'
#' @param original Original code string
#' @param suggested Suggested/modified code string
#' @return List with diff information for display
#'
#' @details
#' Returns a list with:
#' - original_lines: vector of original lines with diff status
#' - suggested_lines: vector of suggested lines with diff status
#' - has_changes: logical indicating if there are differences
compare_code <- function(original, suggested) {
  if (is.null(original) || is.null(suggested)) {
    return(list(
      original_lines = list(),
      suggested_lines = list(),
      has_changes = FALSE
    ))
  }

  # Split into lines
  orig_lines <- strsplit(trimws(original), "\n")[[1]]
  sugg_lines <- strsplit(trimws(suggested), "\n")[[1]]

  # Normalize whitespace for comparison
  orig_normalized <- trimws(orig_lines)
  sugg_normalized <- trimws(sugg_lines)

  # Build line-by-line comparison
  max_lines <- max(length(orig_lines), length(sugg_lines))

  original_result <- list()
  suggested_result <- list()
  has_changes <- FALSE

  for (i in seq_len(max_lines)) {
    orig_line <- if (i <= length(orig_lines)) orig_lines[i] else ""
    sugg_line <- if (i <= length(sugg_lines)) sugg_lines[i] else ""
    orig_norm <- if (i <= length(orig_normalized)) orig_normalized[i] else ""
    sugg_norm <- if (i <= length(sugg_normalized)) sugg_normalized[i] else ""

    if (orig_norm == sugg_norm) {
      # Lines are the same
      original_result[[i]] <- list(text = orig_line, status = "unchanged")
      suggested_result[[i]] <- list(text = sugg_line, status = "unchanged")
    } else if (orig_norm == "" && sugg_norm != "") {
      # Line added in suggestion
      original_result[[i]] <- list(text = "", status = "empty")
      suggested_result[[i]] <- list(text = sugg_line, status = "added")
      has_changes <- TRUE
    } else if (orig_norm != "" && sugg_norm == "") {
      # Line removed in suggestion
      original_result[[i]] <- list(text = orig_line, status = "removed")
      suggested_result[[i]] <- list(text = "", status = "empty")
      has_changes <- TRUE
    } else {
      # Line modified
      original_result[[i]] <- list(text = orig_line, status = "removed")
      suggested_result[[i]] <- list(text = sugg_line, status = "added")
      has_changes <- TRUE
    }
  }

  return(list(
    original_lines = original_result,
    suggested_lines = suggested_result,
    has_changes = has_changes
  ))
}

#' Find the most likely code suggestion from AI feedback
#'
#' @param ai_feedback Character string containing AI feedback text
#' @param original_code Original student code
#' @return Character string with suggested code, or NULL if none found
#'
#' @details
#' Extracts code blocks from AI feedback and finds the one most likely
#' to be a correction (30%+ token overlap with original, but different)
find_suggested_correction <- function(ai_feedback, original_code) {
  if (is.null(ai_feedback) || ai_feedback == "") return(NULL)
  if (is.null(original_code) || original_code == "") return(NULL)

  # Extract all code blocks
  code_blocks <- extract_code_blocks(ai_feedback)
  if (length(code_blocks) == 0) return(NULL)

  # Tokenize original code (simple word-based)
  orig_tokens <- unique(unlist(strsplit(original_code, "[^a-zA-Z0-9_.]+")))
  orig_tokens <- orig_tokens[nchar(orig_tokens) > 0]

  best_match <- NULL
  best_score <- 0

  for (block in code_blocks) {
    # Skip if identical to original
    if (trimws(block) == trimws(original_code)) next

    # Tokenize suggestion
    sugg_tokens <- unique(unlist(strsplit(block, "[^a-zA-Z0-9_.]+")))
    sugg_tokens <- sugg_tokens[nchar(sugg_tokens) > 0]

    # Calculate overlap
    overlap <- length(intersect(orig_tokens, sugg_tokens))
    total <- length(union(orig_tokens, sugg_tokens))

    if (total > 0) {
      similarity <- overlap / total

      # Look for code that's similar but different (30-95% overlap)
      # This suggests it's a correction, not example code
      if (similarity >= 0.3 && similarity < 0.95) {
        # Prefer longer code blocks that are more likely to be complete solutions
        score <- similarity * nchar(block)
        if (score > best_score) {
          best_score <- score
          best_match <- block
        }
      }
    }
  }

  return(best_match)
}
