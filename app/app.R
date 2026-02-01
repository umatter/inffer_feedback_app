# R Code Feedback App - Main Application
# AI-powered Shiny application for WDDA course

# =============================================================================
# Shinylive Compatibility Workaround
# =============================================================================
# This is a workaround for a known Shinylive/webR issue where munsell package
# is required as a transitive dependency but fails to load in WASM environment.
# See: https://github.com/posit-dev/shinylive/issues/
if (FALSE) {
  library(munsell)
}

# =============================================================================
# Load Dependencies
# =============================================================================

library(shiny)
library(bslib)
library(jsonlite)
library(markdown)
library(shinyjs)

# Source modular components
source("bfh_theme_helpers.R")
source("R/config.R")
source("R/feedback_functions.R")
source("R/api_functions.R")

# =============================================================================
# Load Data Files
# =============================================================================

# Load translations
translations_data <- fromJSON("translations.json")

# Load exercises from external JSON (instructor-customizable)
exercises_data <- fromJSON("exercises.json")
BUILTIN_EXERCISES <- exercises_data$exercises

# =============================================================================
# Translation Functions
# =============================================================================

#' Translate text to specified language
#'
#' @param key Translation key or vector of keys
#' @param lang Language code ("en", "de", "fr")
#' @return Translated text or vector of translated texts
translate_text <- function(key, lang = "en") {
  # Handle vector input

  if (length(key) > 1) {
    return(sapply(key, translate_text, lang = lang, USE.NAMES = FALSE))
  }

  # Default to English if language not found
  if (!lang %in% translations_data$languages) {
    lang <- "en"
  }

  # Return translation or key if not found
  return(translations_data$translation[[key]][[lang]] %||% key)
}

# =============================================================================
# Markdown Rendering
# =============================================================================

#' Render markdown to sanitized HTML
#'
#' @param markdown_text Markdown text to render
#' @return HTML content wrapped in styled container
render_markdown_feedback <- function(markdown_text) {
  if (is.null(markdown_text) || markdown_text == "") {
    return("")
  }

  # Convert markdown to HTML
  html_content <- markdown::markdownToHTML(
    text = markdown_text,
    fragment.only = TRUE,
    options = c('use_xhtml', 'smartypants', 'base64_images', 'mathjax', 'highlight_code')
  )

  # Basic HTML sanitization - remove potentially dangerous tags
  # Note: markdownToHTML with fragment.only=TRUE is relatively safe,
  # but we add extra protection for AI-generated content
  html_content <- gsub("<script[^>]*>.*?</script>", "", html_content, ignore.case = TRUE, perl = TRUE)
  html_content <- gsub("<iframe[^>]*>.*?</iframe>", "", html_content, ignore.case = TRUE, perl = TRUE)
  html_content <- gsub("on\\w+\\s*=", "data-removed=", html_content, ignore.case = TRUE)

  # Wrap in styled container
 styled_html <- paste0('<div class="markdown-content">', html_content, '</div>')

  return(HTML(styled_html))
}

# =============================================================================
# JavaScript for Browser API Calls
# =============================================================================

# JavaScript code for making API calls via browser fetch (required for webR/Shinylive)
# Uses MAX_IMAGE_SIZE_BYTES constant for image validation
js_fetch_api <- sprintf("
// Maximum image size constant (from R config)
var MAX_IMAGE_SIZE = %d;

shinyjs.callLLMApi = function(paramsJson) {
  var input = Array.isArray(paramsJson) ? paramsJson[0] : paramsJson;

  var params;
  if (typeof input === 'string') {
    try {
      params = JSON.parse(input);
    } catch(e) {
      console.error('Failed to parse params JSON:', e);
      Shiny.setInputValue('api_response', {
        requestId: 'unknown',
        success: false,
        error: 'Failed to parse API parameters'
      }, {priority: 'event'});
      return;
    }
  } else {
    params = input;
  }

  var url = params.url;
  var headers = params.headers;
  var body = params.body;
  var requestId = params.requestId;

  // Debug logging (API key masked for security)
  console.log('=== LLM API CALL ===');
  console.log('URL:', url);
  var safeHeaders = {};
  for (var key in headers) {
    if (key.toLowerCase() === 'authorization' || key.toLowerCase() === 'x-api-key') {
      safeHeaders[key] = '***MASKED***';
    } else {
      safeHeaders[key] = headers[key];
    }
  }
  console.log('Headers:', safeHeaders);
  console.log('Model:', body.model);

  fetch(url, {
    method: 'POST',
    headers: headers,
    body: JSON.stringify(body)
  })
  .then(response => {
    var statusCode = response.status;
    console.log('Response Status:', statusCode);
    if (!response.ok) {
      return response.json().then(errData => {
        throw {message: errData.error?.message || 'API request failed', status: statusCode};
      }).catch((e) => {
        if (e.status) throw e;
        throw {message: 'API request failed with status ' + statusCode, status: statusCode};
      });
    }
    return response.json();
  })
  .then(data => {
    Shiny.setInputValue('api_response', {
      requestId: requestId,
      success: true,
      data: data
    }, {priority: 'event'});
  })
  .catch(error => {
    console.error('API Error:', error.message);
    Shiny.setInputValue('api_response', {
      requestId: requestId,
      success: false,
      error: error.message,
      status: error.status || null
    }, {priority: 'event'});
  });
}
", MAX_IMAGE_SIZE_BYTES)

# =============================================================================
# UI Definition
# =============================================================================

ui <- function(request) {
  div(
    add_bfh_theme(),
    useShinyjs(),
    extendShinyjs(text = js_fetch_api, functions = c("callLLMApi")),

    page_navbar(
      title = NULL,
      theme = bs_theme(
        primary = BFH_COLORS$dunkelblau,
        secondary = BFH_COLORS$orange,
        success = BFH_COLORS$mittelgruen,
        info = BFH_COLORS$hellblau,
        warning = BFH_COLORS$orange,
        light = BFH_COLORS$grauwert_5,
        dark = BFH_COLORS$dunkelgrau,
        bg = "#ffffff",
        fg = BFH_COLORS$text_grau,
        base_font = font_google("Inter", local = FALSE, display = "swap"),
        font_scale = 1.0
      ),

      header = div(
        id = "dynamic_header",
        create_bfh_header(
          textOutput("header_title", inline = TRUE),
          textOutput("header_subtitle", inline = TRUE)
        )
      ),

      # Main Code Analysis Panel
      nav_panel(
        title = textOutput("interactive_demo_title", inline = TRUE),

        layout_sidebar(
          sidebar = sidebar(
            open = "always",
            position = "left",
            width = 380,

            # Settings Panel
            create_bfh_panel(
              title = textOutput("settings_title", inline = TRUE),
              content = tagList(
                # LLM Provider Selection
                selectInput(
                  "llm_provider",
                  textOutput("llm_provider_label", inline = TRUE),
                  choices = c(
                    "Select Provider" = "",
                    "OpenAI (Direct)" = "openai",
                    "Anthropic (Direct)" = "anthropic",
                    "OpenRouter (Multi-Model)" = "openrouter"
                  ),
                  selected = ""
                ),

                # Model Selection (only for OpenRouter)
                conditionalPanel(
                  condition = "input.llm_provider == 'openrouter'",
                  selectInput(
                    "openrouter_model",
                    textOutput("model_selection_label", inline = TRUE),
                    choices = get_openrouter_model_choices(),
                    selected = LLM_PROVIDERS$openrouter$default_model
                  ),
                  div(class = "text-muted text-small mb-2",
                      textOutput("model_selection_help")
                  )
                ),

                # API Key Input with real-time validation
                conditionalPanel(
                  condition = "input.llm_provider != ''",
                  passwordInput(
                    "api_key",
                    textOutput("api_key_label", inline = TRUE),
                    placeholder = "Enter your API key"
                  ),
                  # Real-time validation feedback
                  uiOutput("api_key_validation_ui"),
                  br(),
                  bfh_action_button(
                    "save_api_key",
                    textOutput("save_api_key_text", inline = TRUE),
                    style = "success"
                  ),
                  conditionalPanel(
                    condition = "output.api_key_saved == true",
                    div(class = "text-success text-small mt-2",
                        tags$i(class = "fa fa-check"), " ",
                        textOutput("api_key_saved_text", inline = TRUE)
                    )
                  )
                )
              )
            ),

            # Built-in Exercise Selector
            create_bfh_panel(
              title = textOutput("builtin_exercises_title", inline = TRUE),
              content = tagList(
                p(textOutput("builtin_exercises_help"), class = "text-muted text-small"),
                selectInput(
                  "selected_exercise",
                  NULL,
                  choices = c("Custom Exercise" = "", setNames(
                    names(BUILTIN_EXERCISES),
                    sapply(BUILTIN_EXERCISES, function(x) x$title)
                  )),
                  selected = ""
                ),
                # Show exercise details when selected
                uiOutput("exercise_details_ui")
              )
            ),

            # Custom Exercise Upload Panel
            create_bfh_panel(
              title = textOutput("custom_exercises_title", inline = TRUE),
              content = tagList(
                p(textOutput("custom_exercises_help"), class = "text-muted text-small"),
                fileInput(
                  "exercise_upload",
                  NULL,
                  accept = ".json",
                  placeholder = "Select JSON file..."
                ),
                # Validation status display
                uiOutput("upload_validation_ui"),
                # Options
                checkboxInput(
                  "replace_builtin",
                  textOutput("replace_builtin_label", inline = TRUE),
                  value = FALSE
                ),
                # Action buttons
                div(class = "d-flex gap-2 flex-wrap",
                    bfh_action_button("apply_exercises", textOutput("apply_text", inline = TRUE), style = "success"),
                    bfh_action_button("clear_custom_exercises", textOutput("clear_custom_text", inline = TRUE), style = "secondary"),
                    downloadButton("download_template", textOutput("download_template_text", inline = TRUE), class = "btn btn-info")
                )
              )
            )
          ),

          # Exercise Input Panel
          create_bfh_panel(
            title = textOutput("exercise_input_title", inline = TRUE),
            content = tagList(
              div(class = "bfh-card-content",
                  p(textOutput("exercise_input_help"), class = "text-muted"),
                  textAreaInput(
                    "exercise_text",
                    textOutput("exercise_text_label", inline = TRUE),
                    placeholder = "Paste your exercise text here or use Ctrl+V to paste a screenshot...",
                    height = "150px",
                    width = "100%"
                  ),
                  # JavaScript for clipboard image handling
                  tags$script(HTML(sprintf("
                    $(document).ready(function() {
                      var MAX_IMAGE_SIZE = %d;

                      $('#exercise_text').on('paste', function(e) {
                        var items = (e.originalEvent.clipboardData || window.clipboardData).items;

                        for (var i = 0; i < items.length; i++) {
                          if (items[i].type.indexOf('image') !== -1) {
                            var blob = items[i].getAsFile();

                            if (blob.size > MAX_IMAGE_SIZE) {
                              Shiny.setInputValue('pasted_image_error', 'Image too large (max 5MB)', {priority: 'event'});
                              e.preventDefault();
                              return;
                            }

                            var reader = new FileReader();
                            reader.onload = function(event) {
                              Shiny.setInputValue('pasted_image_data', event.target.result, {priority: 'event'});
                            };
                            reader.readAsDataURL(blob);
                            e.preventDefault();
                          }
                        }
                      });
                    });
                  ", MAX_IMAGE_SIZE_BYTES))),
                  # Image display area
                  conditionalPanel(
                    condition = "output.has_exercise_image == true",
                    div(id = "exercise_image_container",
                        h6(textOutput("pasted_image_label", inline = TRUE)),
                        div(id = "exercise_image_display", class = "border p-2 mb-2"),
                        bfh_action_button(
                          "clear_exercise_image",
                          textOutput("clear_image_text", inline = TRUE),
                          style = "secondary"
                        )
                    )
                  ),
                  br(),
                  bfh_action_button(
                    "clear_exercise",
                    textOutput("clear_exercise_text", inline = TRUE),
                    style = "secondary"
                  )
              )
            )
          ),

          # Code Input Panel
          create_bfh_panel(
            title = textOutput("code_input_title", inline = TRUE),
            content = tagList(
              textAreaInput(
                "student_code",
                NULL,
                placeholder = "# Enter your R code here\n# Example: data <- read.csv('file.csv')\nhead(data)",
                height = "200px",
                width = "100%"
              ),
              br(),
              div(class = "d-flex gap-2 flex-wrap",
                  bfh_action_button(
                    "analyze_code",
                    textOutput("analyze_button_text", inline = TRUE),
                    style = "primary"
                  ),
                  bfh_action_button(
                    "run_code",
                    textOutput("run_code_text", inline = TRUE),
                    style = "success"
                  ),
                  bfh_action_button(
                    "clear_code",
                    textOutput("clear_button_text", inline = TRUE),
                    style = "secondary"
                  )
              )
            )
          ),

          # Code Output Panel (conditional)
          conditionalPanel(
            condition = "output.has_code_output == true",
            create_bfh_panel(
              title = textOutput("code_output_title", inline = TRUE),
              content = tagList(
                uiOutput("code_output_display"),
                # Plot output (conditional) - uses base64 image for webR compatibility
                conditionalPanel(
                  condition = "output.has_plot_output == true",
                  div(class = "code-output-container plot-output mt-3",
                      div(class = "output-label", textOutput("plot_output_label", inline = TRUE)),
                      uiOutput("code_plot_output")
                  )
                )
              )
            )
          ),

          # Feedback Panel
          create_bfh_card(
            tagList(
              h4(textOutput("feedback_title", inline = TRUE), class = "bfh-color-1"),
              div(id = "feedback_content",
                  div(class = "bfh-card-highlight",
                      uiOutput("feedback_display")
                  )
              ),
              # Diff View (conditional)
              conditionalPanel(
                condition = "output.has_code_diff == true",
                div(id = "diff_view_container",
                    h5(textOutput("diff_title", inline = TRUE), class = "bfh-color-2 mt-3"),
                    uiOutput("diff_display")
                )
              ),
              # Export Buttons
              conditionalPanel(
                condition = "output.has_feedback == true",
                div(class = "export-buttons",
                    downloadButton("download_markdown", textOutput("download_md_text", inline = TRUE), class = "btn btn-info"),
                    bfh_action_button("print_pdf", textOutput("print_pdf_text", inline = TRUE), style = "secondary")
                )
              )
            ),
            highlight = TRUE
          )
        )
      ),

      # Theory/Guide Panel
      nav_panel(
        title = textOutput("theory_title", inline = TRUE),
        div(
          class = "container-fluid",
          style = "max-width: 800px; margin: 0 auto;",

          create_bfh_panel(
            title = textOutput("r_fundamentals_title", inline = TRUE),
            content = tagList(
              p(textOutput("r_fundamentals_text"),
                style = "font-size: 1.1em; line-height: 1.6;")
            ),
            status = "info"
          ),

          create_bfh_card(
            tagList(
              h3(textOutput("best_practices_title", inline = TRUE), class = "bfh-color-1"),
              uiOutput("best_practices_content")
            )
          ),

          create_bfh_card(
            tagList(
              h3(textOutput("common_mistakes_title", inline = TRUE), class = "bfh-color-1"),
              uiOutput("common_mistakes_content")
            )
          ),

          create_bfh_card(
            tagList(
              h3(textOutput("learning_resources_title", inline = TRUE), class = "bfh-color-1"),
              uiOutput("learning_resources_content")
            )
          )
        )
      ),

      nav_spacer(),
      nav_item(create_language_selector("en"))
    )
  )
}

# =============================================================================
# Server Logic
# =============================================================================

server <- function(input, output, session) {

  # ---------------------------------------------------------------------------
  # Reactive Values
  # ---------------------------------------------------------------------------
  current_lang <- reactiveVal("en")
  api_key_saved <- reactiveVal(FALSE)
  saved_api_key <- reactiveVal("")
  has_exercise_image <- reactiveVal(FALSE)
  exercise_image_data <- reactiveVal("")
  pending_api_context <- reactiveVal(NULL)
  partial_feedback <- reactiveVal(NULL)
  api_key_error <- reactiveVal("")

  # Custom exercise upload
  uploaded_exercises <- reactiveVal(NULL)
  upload_validation <- reactiveVal(NULL)

  # Code execution
  code_output <- reactiveVal(NULL)
  has_code_output <- reactiveVal(FALSE)
  has_plot_output <- reactiveVal(FALSE)
  plot_base64 <- reactiveVal(NULL)


  # Feedback export & diff
  last_feedback <- reactiveVal(NULL)
  last_exercise <- reactiveVal(NULL)
  last_student_code <- reactiveVal("")
  suggested_code <- reactiveVal(NULL)
  has_feedback <- reactiveVal(FALSE)
  has_code_diff <- reactiveVal(FALSE)

  # ---------------------------------------------------------------------------
  # Auto-detect API keys from environment (local development only)
  # ---------------------------------------------------------------------------
  observe({
    # Skip in webR/Shinylive
    if (grepl("wasm|emscripten", R.version$platform, ignore.case = TRUE)) {
      return()
    }

    # Check providers in order of preference
    for (provider in c("openrouter", "openai", "anthropic")) {
      env_var <- switch(provider,
        "openrouter" = "OPENROUTER_API_KEY",
        "openai" = "OPENAI_API_KEY",
        "anthropic" = "ANTHROPIC_API_KEY"
      )
      key <- Sys.getenv(env_var, "")
      if (nzchar(key)) {
        updateSelectInput(session, "llm_provider", selected = provider)
        updateTextInput(session, "api_key", value = key)
        saved_api_key(key)
        api_key_saved(TRUE)
        return()
      }
    }
  }) |> bindEvent(TRUE, once = TRUE)

  # ---------------------------------------------------------------------------
  # Language Handling
  # ---------------------------------------------------------------------------
  observeEvent(input$selected_language, {
    current_lang(input$selected_language)
  })

  # Translation outputs
  output$header_title <- renderText({ translate_text("R Code Feedback App", current_lang()) })
  output$header_subtitle <- renderText({ translate_text("AI-Powered Learning Assistant for WDDA Course", current_lang()) })
  output$interactive_demo_title <- renderText({ translate_text("Code Analysis", current_lang()) })
  output$theory_title <- renderText({ translate_text("R Programming Guide", current_lang()) })
  output$settings_title <- renderText({ translate_text("Settings", current_lang()) })
  output$llm_provider_label <- renderText({ translate_text("AI Provider", current_lang()) })
  output$model_selection_label <- renderText({ translate_text("Model Selection", current_lang()) })
  output$model_selection_help <- renderText({ translate_text("Choose a model based on your needs - coding specialists offer better R feedback", current_lang()) })
  output$api_key_label <- renderText({ translate_text("API Key", current_lang()) })
  output$save_api_key_text <- renderText({ translate_text("Save API Key", current_lang()) })
  output$api_key_saved_text <- renderText({ translate_text("API Key saved successfully", current_lang()) })
  output$builtin_exercises_title <- renderText({ translate_text("Built-in Exercises", current_lang()) })
  output$builtin_exercises_help <- renderText({ translate_text("Or choose from our pre-built exercises for common R programming tasks.", current_lang()) })
  output$exercise_input_title <- renderText({ translate_text("Exercise Input", current_lang()) })
  output$exercise_input_help <- renderText({ translate_text("Paste your exercise description or screenshot here. This is the main way to input your assignment.", current_lang()) })
  output$exercise_text_label <- renderText({ translate_text("Exercise Description", current_lang()) })
  output$pasted_image_label <- renderText({ translate_text("Pasted Image", current_lang()) })
  output$clear_image_text <- renderText({ translate_text("Clear Image", current_lang()) })
  output$clear_exercise_text <- renderText({ translate_text("Clear Exercise", current_lang()) })
  output$code_input_title <- renderText({ translate_text("Your R Code", current_lang()) })
  output$analyze_button_text <- renderText({ translate_text("Analyze Code", current_lang()) })
  output$clear_button_text <- renderText({ translate_text("Clear", current_lang()) })
  output$feedback_title <- renderText({ translate_text("Feedback", current_lang()) })
  output$r_fundamentals_title <- renderText({ translate_text("R Programming Fundamentals", current_lang()) })
  output$best_practices_title <- renderText({ translate_text("Best Practices", current_lang()) })
  output$common_mistakes_title <- renderText({ translate_text("Common Mistakes", current_lang()) })
  output$learning_resources_title <- renderText({ translate_text("Learning Resources", current_lang()) })

  # Custom exercise upload translations
  output$custom_exercises_title <- renderText({ translate_text("Custom Exercises", current_lang()) })
  output$custom_exercises_help <- renderText({ translate_text("Upload custom exercises JSON file", current_lang()) })
  output$replace_builtin_label <- renderText({ translate_text("Replace built-in exercises", current_lang()) })
  output$apply_text <- renderText({ translate_text("Apply", current_lang()) })
  output$clear_custom_text <- renderText({ translate_text("Clear Custom", current_lang()) })
  output$download_template_text <- renderText({ translate_text("Download Template", current_lang()) })

  # Code execution translations
  output$run_code_text <- renderText({ translate_text("Run Code", current_lang()) })
  output$code_output_title <- renderText({ translate_text("Code Output", current_lang()) })
  output$plot_output_label <- renderText({ translate_text("Plot Output", current_lang()) })

  # Feedback export translations
  output$download_md_text <- renderText({ translate_text("Download Markdown", current_lang()) })
  output$print_pdf_text <- renderText({ translate_text("Print as PDF", current_lang()) })

  # Diff view translations
  output$diff_title <- renderText({ translate_text("Suggested Code Changes", current_lang()) })

  # ---------------------------------------------------------------------------
  # API Key Validation (Real-time)
  # ---------------------------------------------------------------------------
  output$api_key_validation_ui <- renderUI({
    key <- input$api_key
    provider <- input$llm_provider

    if (is.null(key) || nchar(trimws(key)) == 0 || provider == "") {
      return(div(class = "text-muted text-small",
                 textOutput("api_key_help", inline = TRUE)))
    }

    validation <- validate_api_key(key, provider)

    if (validation$valid) {
      div(class = "text-success text-small",
          tags$i(class = "bi bi-check-circle"), " Valid key format")
    } else {
      div(class = "text-warning text-small",
          tags$i(class = "bi bi-exclamation-triangle"), " ", validation$message)
    }
  })

  output$api_key_help <- renderText({
    translate_text("Enter your API key to enable AI feedback", current_lang())
  })

  # Save API key
  observeEvent(input$save_api_key, {
    validation <- validate_api_key(input$api_key, input$llm_provider)
    if (validation$valid) {
      saved_api_key(trimws(input$api_key))
      api_key_saved(TRUE)
      api_key_error("")
    } else {
      api_key_saved(FALSE)
      saved_api_key("")
      api_key_error(validation$message)
    }
  })

  # Reset on provider change
  observeEvent(input$llm_provider, {
    api_key_saved(FALSE)
    saved_api_key("")
    api_key_error("")
  })

  output$api_key_saved <- reactive({ api_key_saved() })
  outputOptions(output, "api_key_saved", suspendWhenHidden = FALSE)

  # ---------------------------------------------------------------------------
  # Exercise Selection
  # ---------------------------------------------------------------------------
  output$exercise_details_ui <- renderUI({
    ex_id <- input$selected_exercise
    if (is.null(ex_id) || ex_id == "") return(NULL)

    ex <- BUILTIN_EXERCISES[[ex_id]]
    if (is.null(ex)) return(NULL)

    tagList(
      div(class = "mt-2 p-2 bg-light rounded",
          tags$strong(ex$title),
          tags$span(class = "badge bg-secondary ms-2", ex$difficulty),
          tags$p(class = "text-muted small mb-1", ex$description),
          tags$p(class = "small mb-0", tags$strong("Task: "), ex$task)
      ),
      bfh_action_button("use_exercise", "Use This Exercise", style = "info")
    )
  })

  observeEvent(input$use_exercise, {
    ex_id <- input$selected_exercise
    if (!is.null(ex_id) && ex_id != "") {
      ex <- BUILTIN_EXERCISES[[ex_id]]
      if (!is.null(ex)) {
        updateTextAreaInput(session, "exercise_text", value = paste0(ex$task, "\n\n", ex$description))
      }
    }
  })

  # ---------------------------------------------------------------------------
  # Exercise Input Handling
  # ---------------------------------------------------------------------------
  observeEvent(input$clear_exercise, {
    updateTextAreaInput(session, "exercise_text", value = "")
    has_exercise_image(FALSE)
    exercise_image_data("")
    updateSelectInput(session, "selected_exercise", selected = "")
  })

  observeEvent(input$clear_exercise_image, {
    has_exercise_image(FALSE)
    exercise_image_data("")
  })

  observeEvent(input$pasted_image_data, {
    if (!is.null(input$pasted_image_data)) {
      has_exercise_image(TRUE)
      exercise_image_data(input$pasted_image_data)
      output$exercise_image_display <- renderUI({
        tags$img(src = input$pasted_image_data,
                style = "max-width: 100%; height: auto; border-radius: 4px;")
      })
    }
  })

  observeEvent(input$pasted_image_error, {
    if (!is.null(input$pasted_image_error)) {
      showNotification(input$pasted_image_error, type = "error", duration = 5)
    }
  })

  output$has_exercise_image <- reactive({ has_exercise_image() })
  outputOptions(output, "has_exercise_image", suspendWhenHidden = FALSE)

  # ---------------------------------------------------------------------------
  # Code Analysis
  # ---------------------------------------------------------------------------
  observeEvent(input$clear_code, {
    updateTextAreaInput(session, "student_code", value = "")
  })

  observeEvent(input$analyze_code, {
    if (nchar(trimws(input$student_code)) == 0) {
      output$feedback_display <- renderUI({
        div(class = "alert alert-warning",
            p(translate_text("Please enter some R code to analyze", current_lang()))
        )
      })
      return()
    }

    # Reset diff view
    has_code_diff(FALSE)
    suggested_code(NULL)

    # Build exercise context
    ex_id <- input$selected_exercise
    exercises <- current_exercises()

    if (!is.null(ex_id) && ex_id != "" && !is.null(exercises[[ex_id]])) {
      ex <- exercises[[ex_id]]
      exercise_context <- list(
        title = ex$title,
        description = ex$description,
        task = ex$task,
        reference_solution = ex$reference_solution %||% "",
        category = ex$category,
        difficulty = ex$difficulty,
        has_image = has_exercise_image(),
        image_data = if(has_exercise_image()) exercise_image_data() else ""
      )
    } else {
      exercise_context <- list(
        title = "Custom Exercise",
        description = input$exercise_text,
        task = input$exercise_text,
        reference_solution = "",
        category = "Custom",
        difficulty = "Unknown",
        has_image = has_exercise_image(),
        image_data = if(has_exercise_image()) exercise_image_data() else ""
      )
    }

    # Store for export
    last_exercise(exercise_context)
    last_student_code(input$student_code)

    # Run synchronous checks
    sync_feedback <- list(
      syntax_check = check_syntax(input$student_code),
      rule_based = check_rules(input$student_code, exercise_context),
      ai_feedback = NULL
    )

    # Get API configuration
    api_key_to_use <- if (nzchar(saved_api_key())) saved_api_key() else trimws(input$api_key)
    provider <- input$llm_provider
    model <- if (provider == "openrouter") input$openrouter_model else NULL
    has_api_config <- provider != "" && nzchar(api_key_to_use)

    if (has_api_config) {
      partial_feedback(sync_feedback)
      pending_api_context(list(
        provider = provider,
        model = model,
        lang = current_lang()
      ))

      # Show partial results with professional loading indicator
      loading_msg <- translate_text("Getting AI feedback...", current_lang())
      output$feedback_display <- renderUI({
        tagList(
          create_feedback_ui(sync_feedback, current_lang()),
          div(class = "alert alert-info",
              div(class = "d-flex align-items-center",
                  div(class = "spinner-border spinner-border-sm me-2", role = "status",
                      style = "width: 1.2rem; height: 1.2rem;",
                      span(class = "visually-hidden", "Loading...")
                  ),
                  span(loading_msg)
              )
          )
        )
      })

      # Run student code to capture any generated plot for AI feedback
      student_plot_result <- execute_code_with_plot(input$student_code)
      student_plot_base64 <- if (student_plot_result$has_plot) student_plot_result$plot_base64 else NULL

      # Also update the code output display if plot was generated
      if (student_plot_result$has_plot) {
        code_output(student_plot_result)
        plot_base64(student_plot_result$plot_base64)
        has_code_output(TRUE)
        has_plot_output(TRUE)
      }

      # Generate reference plot if exercise has a reference solution
      reference_plot_base64 <- NULL
      if (!is.null(exercise_context$reference_solution) &&
          nchar(trimws(exercise_context$reference_solution)) > 0) {
        reference_plot_base64 <- generate_reference_plot(exercise_context$reference_solution)
      }

      # Trigger API call with plot images
      api_params <- prepare_api_request(
        student_code = input$student_code,
        exercise = exercise_context,
        provider = provider,
        api_key = api_key_to_use,
        model = model,
        lang = current_lang(),
        student_plot_base64 = student_plot_base64,
        reference_plot_base64 = reference_plot_base64
      )

      if (!is.null(api_params)) {
        api_params_json <- toJSON(api_params, auto_unbox = TRUE)
        js$callLLMApi(api_params_json)
      } else {
        sync_feedback$ai_feedback <- list(
          available = FALSE,
          message = "Could not prepare API request"
        )
        output$feedback_display <- renderUI({
          create_feedback_ui(sync_feedback, current_lang())
        })
        pending_api_context(NULL)
        partial_feedback(NULL)
      }
    } else {
      # No API configured
      msg <- if (provider == "") {
        translate_text("Please configure AI provider and API key in Settings", current_lang())
      } else {
        translate_text("Please enter and save your API key in Settings", current_lang())
      }
      sync_feedback$ai_feedback <- list(available = FALSE, message = msg)

      # Store feedback for export (even without AI)
      last_feedback(sync_feedback)
      has_feedback(TRUE)

      output$feedback_display <- renderUI({
        create_feedback_ui(sync_feedback, current_lang())
      })
    }

    # Scroll to feedback (using constant delay)
    shinyjs::delay(SCROLL_TO_FEEDBACK_DELAY_MS, {
      shinyjs::runjs("
        var feedbackEl = document.getElementById('feedback_display');
        if (feedbackEl) {
          feedbackEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
      ")
    })
  })

  # Handle API response
  observeEvent(input$api_response, {
    response <- input$api_response
    context <- pending_api_context()
    feedback <- partial_feedback()

    pending_api_context(NULL)
    partial_feedback(NULL)

    if (is.null(feedback)) return()

    if (response$success) {
      ai_result <- parse_api_response(response$data, context$provider, context$model)
      feedback$ai_feedback <- ai_result

      # Extract suggested code for diff view
      if (ai_result$available && !is.null(ai_result$message)) {
        sugg <- find_suggested_correction(ai_result$message, last_student_code())
        if (!is.null(sugg)) {
          suggested_code(sugg)
          has_code_diff(TRUE)
        }
      }
    } else {
      # Use friendly error message
      friendly_msg <- get_friendly_error_message(response$error, response$status)
      feedback$ai_feedback <- list(available = FALSE, message = friendly_msg)
    }

    # Store feedback for export
    last_feedback(feedback)
    has_feedback(TRUE)

    output$feedback_display <- renderUI({
      create_feedback_ui(feedback, context$lang)
    })
  })

  # ---------------------------------------------------------------------------
  # Custom Exercise Upload Handling
  # ---------------------------------------------------------------------------

  # Handle file upload
  observeEvent(input$exercise_upload, {
    req(input$exercise_upload)

    tryCatch({
      # Read and parse JSON
      json_content <- jsonlite::fromJSON(input$exercise_upload$datapath)

      # Validate structure
      validation <- validate_exercises_json(json_content)
      upload_validation(validation)

      if (validation$valid) {
        uploaded_exercises(validation$exercises)
      } else {
        uploaded_exercises(NULL)
      }
    }, error = function(e) {
      upload_validation(list(
        valid = FALSE,
        exercises = NULL,
        errors = paste("Invalid JSON:", e$message)
      ))
      uploaded_exercises(NULL)
    })
  })

  # Display validation status
  output$upload_validation_ui <- renderUI({
    val <- upload_validation()
    if (is.null(val)) return(NULL)

    if (val$valid) {
      n_exercises <- length(uploaded_exercises())
      div(class = "upload-validation-status upload-validation-success",
          tags$i(class = "bi bi-check-circle"), " ",
          n_exercises, " ", translate_text("exercises loaded successfully", current_lang())
      )
    } else {
      div(class = "upload-validation-status upload-validation-error",
          tags$i(class = "bi bi-exclamation-triangle"), " ",
          translate_text("Validation errors", current_lang()), ":",
          tags$ul(lapply(val$errors, function(e) tags$li(e)))
      )
    }
  })

  # Apply custom exercises
  observeEvent(input$apply_exercises, {
    custom <- uploaded_exercises()
    if (is.null(custom) || length(custom) == 0) {
      showNotification(translate_text("No custom exercises to apply", current_lang()), type = "warning")
      return()
    }

    # Build combined exercise list
    if (input$replace_builtin) {
      combined <- custom
    } else {
      combined <- modifyList(BUILTIN_EXERCISES, custom)
    }

    # Update the exercise selector
    choices <- c("Custom Exercise" = "", setNames(
      names(combined),
      sapply(combined, function(x) x$title)
    ))

    updateSelectInput(session, "selected_exercise", choices = choices)
    showNotification(paste(length(custom), translate_text("exercises loaded successfully", current_lang())), type = "message")
  })

  # Clear custom exercises
  observeEvent(input$clear_custom_exercises, {
    uploaded_exercises(NULL)
    upload_validation(NULL)

    # Reset to built-in exercises
    choices <- c("Custom Exercise" = "", setNames(
      names(BUILTIN_EXERCISES),
      sapply(BUILTIN_EXERCISES, function(x) x$title)
    ))

    updateSelectInput(session, "selected_exercise", choices = choices)
    showNotification(translate_text("Custom exercises cleared", current_lang()), type = "message")
  })

  # Download template
  output$download_template <- downloadHandler(
    filename = function() {
      "exercise_template.json"
    },
    content = function(file) {
      template <- generate_exercise_template()
      writeLines(template, file)
    },
    contentType = "application/json"
  )

  # Get current exercises (built-in + custom)
  current_exercises <- reactive({
    custom <- uploaded_exercises()
    if (!is.null(custom) && length(custom) > 0) {
      if (isTRUE(input$replace_builtin)) {
        return(custom)
      } else {
        return(modifyList(BUILTIN_EXERCISES, custom))
      }
    }
    return(BUILTIN_EXERCISES)
  })

  # ---------------------------------------------------------------------------
  # Code Execution Handling
  # ---------------------------------------------------------------------------

  observeEvent(input$run_code, {
    code <- input$student_code
    if (is.null(code) || nchar(trimws(code)) == 0) {
      showNotification(translate_text("Please enter some R code to analyze", current_lang()), type = "warning")
      return()
    }

    # Show loading indicator
    has_code_output(TRUE)
    has_plot_output(FALSE)
    plot_base64(NULL)
    code_output(list(running = TRUE))

    # Execute code with plot capture
    result <- execute_code_with_plot(code)
    code_output(result)

    # Handle plot if generated
    if (isTRUE(result$has_plot) && !is.null(result$plot_base64)) {
      plot_base64(result$plot_base64)
      has_plot_output(TRUE)
    }
  })

  # Display code output
  output$code_output_display <- renderUI({
    result <- code_output()
    if (is.null(result)) return(NULL)

    if (isTRUE(result$running)) {
      return(div(class = "code-output-container",
          div(class = "d-flex align-items-center",
              div(class = "spinner-border spinner-border-sm me-2", role = "status"),
              span(translate_text("Running code...", current_lang()))
          )
      ))
    }

    elements <- list()

    # Status indicator
    status_class <- if (result$success) "code-output-success" else "code-output-error"

    # Console output
    if (result$success) {
      if (nchar(result$output) > 0) {
        elements <- append(elements, list(
          div(class = paste("code-output-container", status_class),
              div(class = "output-label", translate_text("Console Output", current_lang())),
              tags$pre(result$output)
          )
        ))
      } else {
        elements <- append(elements, list(
          div(class = paste("code-output-container", status_class),
              div(class = "output-label", translate_text("Console Output", current_lang())),
              tags$pre(class = "text-muted", translate_text("No output", current_lang()))
          )
        ))
      }
    } else {
      elements <- append(elements, list(
        div(class = paste("code-output-container", status_class),
            div(class = "output-label", translate_text("Execution error", current_lang())),
            tags$pre(class = "text-danger", result$error)
        )
      ))
    }

    # Warnings
    if (length(result$warnings) > 0) {
      elements <- append(elements, list(
        div(class = "code-output-warning",
            tags$strong(translate_text("Warnings", current_lang()), ":"),
            tags$ul(lapply(result$warnings, function(w) tags$li(w)))
        )
      ))
    }

    do.call(tagList, elements)
  })

  output$has_code_output <- reactive({ has_code_output() })
  outputOptions(output, "has_code_output", suspendWhenHidden = FALSE)

  output$has_plot_output <- reactive({ has_plot_output() })
  outputOptions(output, "has_plot_output", suspendWhenHidden = FALSE)

  # Render captured plot as base64 image (webR compatible)
  output$code_plot_output <- renderUI({
    img_data <- plot_base64()
    if (!is.null(img_data)) {
      tags$img(
        src = img_data,
        style = "max-width: 100%; height: auto; border-radius: 4px;",
        alt = "Generated plot"
      )
    }
  })

  # ---------------------------------------------------------------------------
  # Feedback Export Handling
  # ---------------------------------------------------------------------------

  output$has_feedback <- reactive({ has_feedback() })
  outputOptions(output, "has_feedback", suspendWhenHidden = FALSE)

  # Download Markdown
  output$download_markdown <- downloadHandler(
    filename = function() {
      paste0("r_feedback_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".md")
    },
    content = function(file) {
      feedback <- last_feedback()
      exercise <- last_exercise()
      code <- last_student_code()

      if (is.null(feedback)) {
        writeLines("No feedback available.", file)
        return()
      }

      md_content <- format_feedback_markdown(feedback, exercise, code, current_lang())
      writeLines(md_content, file)
    },
    contentType = "text/markdown"
  )

  # Print as PDF (via browser)
  observeEvent(input$print_pdf, {
    feedback <- last_feedback()
    if (is.null(feedback)) {
      showNotification(translate_text("No feedback to export", current_lang()), type = "warning")
      return()
    }

    # Generate HTML for printing
    exercise <- last_exercise()
    code <- last_student_code()
    md_content <- format_feedback_markdown(feedback, exercise, code, current_lang())

    # Convert to HTML
    html_content <- markdown::markdownToHTML(
      text = md_content,
      fragment.only = FALSE,
      options = c('use_xhtml', 'smartypants', 'highlight_code')
    )

    # Add print styles
    html_content <- gsub("</head>", "
      <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        pre { background: #f5f5f5; padding: 10px; overflow-x: auto; }
        code { background: #f5f5f5; padding: 2px 4px; }
        @media print { body { max-width: none; } }
      </style>
    </head>", html_content)

    # Encode for JavaScript
    html_encoded <- jsonlite::toJSON(html_content, auto_unbox = TRUE)

    # Open in new window and print
    shinyjs::runjs(sprintf("
      var printWindow = window.open('', '_blank');
      printWindow.document.write(%s);
      printWindow.document.close();
      printWindow.onload = function() {
        printWindow.print();
      };
    ", html_encoded))
  })

  # ---------------------------------------------------------------------------
  # Diff View Handling
  # ---------------------------------------------------------------------------

  output$has_code_diff <- reactive({ has_code_diff() })
  outputOptions(output, "has_code_diff", suspendWhenHidden = FALSE)

  output$diff_display <- renderUI({
    sugg <- suggested_code()
    orig <- last_student_code()

    if (is.null(sugg) || sugg == "" || is.null(orig) || orig == "") {
      return(NULL)
    }

    # Compare code
    diff_result <- compare_code(orig, sugg)

    if (!diff_result$has_changes) {
      return(NULL)
    }

    # Build diff display
    build_diff_lines <- function(lines, label) {
      line_elements <- lapply(seq_along(lines), function(i) {
        line <- lines[[i]]
        status_class <- paste0("diff-line diff-line-", line$status)
        div(class = status_class,
            span(class = "diff-line-number", i),
            span(line$text)
        )
      })

      div(class = "diff-panel",
          div(class = "diff-panel-header", label),
          div(class = "diff-panel-content",
              tags$pre(do.call(tagList, line_elements))
          )
      )
    }

    div(class = "diff-container",
        build_diff_lines(diff_result$original_lines, translate_text("Your Code", current_lang())),
        build_diff_lines(diff_result$suggested_lines, translate_text("Suggested", current_lang()))
    )
  })

  # ---------------------------------------------------------------------------
  # Theory Content
  # ---------------------------------------------------------------------------
  output$r_fundamentals_text <- renderText({
    translate_text("R is a powerful language for data analysis and statistics. Understanding key concepts like data types, functions, and syntax will help you write effective code.", current_lang())
  })

  output$best_practices_content <- renderUI({
    tagList(
      tags$ul(
        tags$li(translate_text("Use descriptive variable names", current_lang())),
        tags$li(translate_text("Comment your code for clarity", current_lang())),
        tags$li(translate_text("Use pipe operators for readable workflows", current_lang())),
        tags$li(translate_text("Check for missing values with na.rm = TRUE", current_lang()))
      )
    )
  })

  output$common_mistakes_content <- renderUI({
    tagList(
      tags$ul(
        tags$li(translate_text("Forgetting to load required packages", current_lang())),
        tags$li(translate_text("Using = instead of == for comparisons", current_lang())),
        tags$li(translate_text("Not handling missing values properly", current_lang())),
        tags$li(translate_text("Inconsistent object naming conventions", current_lang()))
      )
    )
  })

  output$learning_resources_content <- renderUI({
    tagList(
      tags$ul(
        tags$li(tags$a("R for Data Science", href = "https://r4ds.had.co.nz/", target = "_blank")),
        tags$li(tags$a("RStudio Education", href = "https://education.rstudio.com/", target = "_blank")),
        tags$li(tags$a("CRAN R Manual", href = "https://cran.r-project.org/manuals.html", target = "_blank"))
      )
    )
  })
}

# =============================================================================
# Run Application
# =============================================================================

shinyApp(ui = ui, server = server, enableBookmarking = "url")
