# Helper file to load app functions for testing
# Sources the modular R files from the app directory

library(jsonlite)

# Get the project root directory (two levels up from tests/testthat)
# testthat::test_path() returns the testthat directory
project_root <- normalizePath(file.path(testthat::test_path(), "..", ".."), mustWork = FALSE)
app_dir <- file.path(project_root, "app")

# Verify the app directory exists
if (!dir.exists(app_dir)) {
  # Fallback: try relative to current working directory
  app_dir <- normalizePath("app", mustWork = FALSE)
  if (!dir.exists(app_dir)) {
    app_dir <- normalizePath("../../app", mustWork = FALSE)
  }
}

# Define %||% operator if not available
if (!exists("%||%", mode = "function")) {
  `%||%` <- function(x, y) if (is.null(x)) y else x
}

# Source configuration and functions in the correct order
config_file <- file.path(app_dir, "R", "config.R")
api_file <- file.path(app_dir, "R", "api_functions.R")
feedback_file <- file.path(app_dir, "R", "feedback_functions.R")

if (file.exists(config_file)) {
  source(config_file, local = FALSE)
} else {
  # Define minimal config for tests if files don't exist
  MAX_IMAGE_SIZE_BYTES <- 5 * 1024 * 1024
  DEFAULT_MAX_TOKENS <- 1000L
  DEFAULT_TEMPERATURE <- 0.7
  CODE_MODEL_TEMPERATURE <- 0.5
  SCROLL_TO_FEEDBACK_DELAY_MS <- 300

  PATTERNS <- list(
    library_readxl = "library\\(readxl\\)",
    read_excel = "read_excel\\(",
    str_call = "str\\(",
    head_call = "head\\(",
    na_rm_true = "na\\.rm\\s*=\\s*TRUE",
    mean_call = "mean\\(",
    median_call = "median\\(",
    sd_call = "sd\\(",
    var_call = "var\\(",
    pipe_operator = "\\|>",
    filter_call = "filter\\(",
    select_call = "select\\(",
    mutate_call = "mutate\\(",
    library_dplyr = "library\\(dplyr\\)",
    main_title = "main\\s*=",
    xlab_arg = "xlab\\s*=",
    ylab_arg = "ylab\\s*=",
    hist_call = "hist\\(",
    boxplot_call = "boxplot\\(",
    cor_call = "cor\\(",
    is_na_call = "is\\.na\\("
  )

  LLM_PROVIDERS <- list(
    "openai" = list(
      name = "OpenAI (Direct)",
      model = "gpt-4o-mini",
      api_endpoint = "https://api.openai.com/v1/chat/completions",
      has_model_selection = FALSE
    ),
    "anthropic" = list(
      name = "Anthropic (Direct)",
      model = "claude-3-haiku-20240307",
      api_endpoint = "https://api.anthropic.com/v1/messages",
      has_model_selection = FALSE
    ),
    "openrouter" = list(
      name = "OpenRouter",
      api_endpoint = "https://openrouter.ai/api/v1/chat/completions",
      has_model_selection = TRUE,
      available_models = list(
        "qwen/qwen-2.5-coder-32b-instruct" = "Qwen 2.5 Coder 32B (Best for coding)",
        "deepseek/deepseek-chat" = "DeepSeek V3 (Best value)"
      ),
      default_model = "qwen/qwen-2.5-coder-32b-instruct"
    )
  )

  API_KEY_PATTERNS <- list(
    openai = "^sk-",
    anthropic = "^sk-ant-",
    openrouter = "^sk-or-"
  )

  get_openrouter_model_choices <- function() {
    models <- LLM_PROVIDERS$openrouter$available_models
    choices <- setNames(names(models), unlist(models))
    return(choices)
  }
}

if (file.exists(api_file)) {
  source(api_file, local = FALSE)
} else {
  # Define minimal API functions for tests
  generate_request_id <- function() {
    timestamp <- format(Sys.time(), "%Y%m%d%H%M%S")
    random_hex <- paste(sprintf("%02x", sample(0:255, 8, replace = TRUE)), collapse = "")
    paste0("req_", timestamp, "_", random_hex)
  }

  validate_api_key <- function(key, provider) {
    key <- trimws(key)
    if (nchar(key) == 0) {
      return(list(valid = FALSE, message = "API key is required"))
    }
    pattern <- API_KEY_PATTERNS[[provider]]
    if (!is.null(pattern) && !grepl(pattern, key)) {
      return(list(valid = FALSE, message = paste0("Invalid key format for ", provider)))
    }
    return(list(valid = TRUE, message = ""))
  }

  strip_thinking_content <- function(text) {
    text <- gsub("(?s)<think>.*?</think>", "", text, perl = TRUE)
    text <- gsub("(?s)<thinking>.*?</thinking>", "", text, perl = TRUE)
    thinking_preambles <- c(
      "^\\s*Okay,?\\s+(let me|I'll|I need|I should|so)[^\\n]*\\n+",
      "^\\s*Let me (analyze|look|check|review)[^\\n]*\\n+"
    )
    for (pattern in thinking_preambles) {
      text <- sub(pattern, "", text, perl = TRUE, ignore.case = TRUE)
    }
    return(trimws(text))
  }

  build_ai_prompt <- function(student_code, exercise, lang = "en") {
    paste0("Review this R code:\n```r\n", student_code, "\n```")
  }

  prepare_api_request <- function(student_code, exercise, provider, api_key, model = NULL, lang = "en") {
    prompt <- build_ai_prompt(student_code, exercise, lang)
    request_id <- generate_request_id()

    if (provider == "openai") {
      return(list(
        url = LLM_PROVIDERS$openai$api_endpoint,
        headers = list(
          "Authorization" = paste("Bearer", api_key),
          "Content-Type" = "application/json"
        ),
        body = list(
          model = LLM_PROVIDERS$openai$model,
          messages = list(list(role = "user", content = prompt)),
          max_tokens = DEFAULT_MAX_TOKENS,
          temperature = DEFAULT_TEMPERATURE
        ),
        requestId = request_id
      ))
    } else if (provider == "anthropic") {
      return(list(
        url = LLM_PROVIDERS$anthropic$api_endpoint,
        headers = list(
          "x-api-key" = api_key,
          "Content-Type" = "application/json",
          "anthropic-version" = "2023-06-01"
        ),
        body = list(
          model = LLM_PROVIDERS$anthropic$model,
          max_tokens = DEFAULT_MAX_TOKENS,
          messages = list(list(role = "user", content = prompt))
        ),
        requestId = request_id
      ))
    } else if (provider == "openrouter") {
      if (is.null(model) || model == "") {
        model <- LLM_PROVIDERS$openrouter$default_model
      }
      return(list(
        url = LLM_PROVIDERS$openrouter$api_endpoint,
        headers = list(
          "Authorization" = paste("Bearer", api_key),
          "Content-Type" = "application/json"
        ),
        body = list(
          model = model,
          messages = list(list(role = "user", content = prompt)),
          max_tokens = DEFAULT_MAX_TOKENS,
          temperature = DEFAULT_TEMPERATURE
        ),
        requestId = request_id
      ))
    }
    return(NULL)
  }

  parse_api_response <- function(data, provider, model = NULL) {
    tryCatch({
      if (provider == "openai") {
        if (!is.null(data$choices) && length(data$choices) > 0 &&
            !is.null(data$choices[[1]]$message$content)) {
          return(list(
            available = TRUE,
            message = data$choices[[1]]$message$content,
            provider = paste("OpenAI", LLM_PROVIDERS$openai$model)
          ))
        }
      } else if (provider == "anthropic") {
        if (!is.null(data$content) && length(data$content) > 0 &&
            !is.null(data$content[[1]]$text)) {
          return(list(
            available = TRUE,
            message = data$content[[1]]$text,
            provider = "Anthropic Claude-3-Haiku"
          ))
        }
      } else if (provider == "openrouter") {
        if (!is.null(data$choices) && length(data$choices) > 0 &&
            !is.null(data$choices[[1]]$message$content)) {
          feedback_text <- strip_thinking_content(data$choices[[1]]$message$content)
          return(list(
            available = TRUE,
            message = feedback_text,
            provider = paste("OpenRouter:", model %||% "Unknown")
          ))
        }
      }
      return(list(available = FALSE, message = "API Error: Unexpected response format"))
    }, error = function(e) {
      return(list(available = FALSE, message = paste("API Error:", e$message)))
    })
  }

  get_friendly_error_message <- function(error_msg, status_code = NULL) {
    if (!is.null(status_code)) {
      if (status_code == 401) return("Invalid API key. Please check your key in Settings.")
      if (status_code == 429) return("Rate limit exceeded. Please wait a moment and try again.")
      if (status_code %in% c(500, 502, 503)) return("API service temporarily unavailable.")
    }
    if (grepl("rate.?limit", error_msg, ignore.case = TRUE)) {
      return("Rate limit exceeded. Please wait a moment and try again.")
    }
    if (grepl("invalid.*key|unauthorized", error_msg, ignore.case = TRUE)) {
      return("Invalid API key. Please check your key in Settings.")
    }
    if (grepl("timeout", error_msg, ignore.case = TRUE)) {
      return("Request timed out. Please try again.")
    }
    return(paste("API Error:", error_msg))
  }
}

if (file.exists(feedback_file)) {
  source(feedback_file, local = FALSE)
} else {
  # Define minimal feedback functions for tests
  check_syntax <- function(code) {
    tryCatch({
      parse(text = code)
      list(valid = TRUE, message = "Valid R syntax (parseable)")
    }, error = function(e) {
      list(valid = FALSE, message = paste("Syntax error:", conditionMessage(e)))
    })
  }

  check_rules <- function(code, exercise) {
    issues <- c()
    suggestions <- c()
    good_practices <- c()

    has_pattern <- function(pattern_name) {
      grepl(PATTERNS[[pattern_name]], code)
    }

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
    }

    if (exercise$category == "Data Manipulation") {
      if (has_pattern("pipe_operator")) {
        good_practices <- c(good_practices, "Excellent use of pipe operator for readable code!")
      } else if (has_pattern("filter_call") || has_pattern("select_call")) {
        suggestions <- c(suggestions, "Consider using pipe operator |> for cleaner code flow")
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
}

# Load translations for testing if available
translations_file <- file.path(app_dir, "translations.json")
if (file.exists(translations_file)) {
  translations_data <- fromJSON(translations_file)
}

# Mock shiny functions if not available (for unit tests)
if (!exists("tags", mode = "list")) {
  tags <- list(
    strong = function(...) paste0("<strong>", paste(..., collapse = ""), "</strong>"),
    ul = function(...) paste0("<ul>", paste(..., collapse = ""), "</ul>"),
    li = function(x) paste0("<li>", x, "</li>"),
    em = function(...) paste0("<em>", paste(..., collapse = ""), "</em>"),
    div = function(..., class = NULL, style = NULL) {
      paste0("<div>", paste(..., collapse = ""), "</div>")
    }
  )
}

if (!exists("div", mode = "function")) {
  div <- function(..., class = NULL, style = NULL, id = NULL) {
    paste0("<div>", paste(unlist(list(...)), collapse = ""), "</div>")
  }
}

if (!exists("tagList", mode = "function")) {
  tagList <- function(...) list(...)
}

if (!exists("HTML", mode = "function")) {
  HTML <- function(x) x
}

if (!exists("translate_text", mode = "function")) {
  translate_text <- function(key, lang = "en") {
    if (exists("translations_data") && !is.null(translations_data)) {
      return(translations_data$translation[[key]][[lang]] %||% key)
    }
    return(key)
  }
}

if (!exists("render_markdown_feedback", mode = "function")) {
  render_markdown_feedback <- function(text) {
    paste0("<div class='markdown'>", text, "</div>")
  }
}
