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
