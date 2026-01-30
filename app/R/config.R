# Configuration constants and settings for R Code Feedback App
# This file centralizes all configuration to avoid magic numbers/strings

# =============================================================================
# Application Constants
# =============================================================================

# Image handling
MAX_IMAGE_SIZE_BYTES <- 5 * 1024 * 1024  # 5MB limit for pasted images

# API configuration
DEFAULT_MAX_TOKENS <- 1000L
DEFAULT_TEMPERATURE <- 0.7
CODE_MODEL_TEMPERATURE <- 0.5  # Lower temperature for code-focused models

# UI timing
SCROLL_TO_FEEDBACK_DELAY_MS <- 300  # Delay before scrolling to feedback

# =============================================================================
# Regex Patterns (pre-compiled for performance)
# =============================================================================

# These patterns are used in check_rules() for R code analysis
PATTERNS <- list(
  # Data Import patterns
  library_readxl = "library\\(readxl\\)",
  read_excel = "read_excel\\(",
  str_call = "str\\(",
  head_call = "head\\(",


  # Descriptive Statistics patterns
  na_rm_true = "na\\.rm\\s*=\\s*TRUE",
  mean_call = "mean\\(",
  median_call = "median\\(",
  sd_call = "sd\\(",
  var_call = "var\\(",

  # Data Manipulation patterns
  pipe_operator = "\\|>",
  filter_call = "filter\\(",
  select_call = "select\\(",
  mutate_call = "mutate\\(",
  library_dplyr = "library\\(dplyr\\)",

  # Data Visualization patterns
  main_title = "main\\s*=",
  xlab_arg = "xlab\\s*=",
  ylab_arg = "ylab\\s*=",
  hist_call = "hist\\(",
  boxplot_call = "boxplot\\(",

  # Statistical Analysis patterns
  cor_call = "cor\\(",

  # Data Cleaning patterns
  is_na_call = "is\\.na\\("
)

# =============================================================================
# LLM Provider Configuration
# =============================================================================

#' LLM Provider settings for API integration
#'
#' @description
#' Configuration for supported LLM providers:
#' - openai: Direct OpenAI API access
#' - anthropic: Direct Anthropic API access
#' - openrouter: Multi-model access through OpenRouter
#'
#' @details
#' Each provider has:
#' - name: Display name for UI
#' - model: Default model (for single-model providers)
#' - api_endpoint: API URL
#' - has_model_selection: Whether user can choose models
#' - available_models: List of models (for multi-model providers)
#' - default_model: Default selection (for multi-model providers)
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
    # Recommended models for R code analysis
    # Based on 2025 benchmarks: Qwen leads for coding, DeepSeek offers best value
    available_models = list(
      "qwen/qwen-2.5-coder-32b-instruct" = "Qwen 2.5 Coder 32B (Best for coding)",
      "deepseek/deepseek-chat" = "DeepSeek V3 (Best value)",
      "deepseek/deepseek-chat-v3-0324:free" = "DeepSeek V3 Free (Free tier)",
      "google/gemini-2.0-flash-exp:free" = "Gemini 2.0 Flash (Free tier)",
      "meta-llama/llama-3.3-70b-instruct" = "Llama 3.3 70B (Strong general)",
      "mistralai/mistral-large-2411" = "Mistral Large (Balanced)",
      "anthropic/claude-3.5-haiku" = "Claude 3.5 Haiku (Fast)",
      "openai/gpt-4o-mini" = "GPT-4o Mini (Reliable)"
    ),
    default_model = "qwen/qwen-2.5-coder-32b-instruct"
  )
)

#' Generate selectInput choices from LLM_PROVIDERS config
#'
#' @return Named vector with display names as names and model IDs as values
#' @examples
#' get_openrouter_model_choices()
get_openrouter_model_choices <- function() {
  models <- LLM_PROVIDERS$openrouter$available_models
  # Reverse: model_id -> display_name becomes display_name = model_id
  choices <- setNames(names(models), unlist(models))
  return(choices)
}

# =============================================================================
# API Key Validation Patterns
# =============================================================================

API_KEY_PATTERNS <- list(
  openai = "^sk-",
  anthropic = "^sk-ant-",
  openrouter = "^sk-or-"
)
