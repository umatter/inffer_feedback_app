# Workaround for Shinylive munsell dependency issue
if (FALSE) {
  library(munsell)
}

library(shiny)
library(bslib)
library(jsonlite)
library(httr2)
library(markdown)
library(shinyjs)

# Source BFH theme helpers (local copy for Shinylive compatibility)
source("bfh_theme_helpers.R")

# Load translations from JSON file
translations_data <- fromJSON("translations.json")

# Create translation function
translate_text <- function(key, lang = "en") {
  # Default to English if language not found
  if (!lang %in% translations_data$languages) {
    lang <- "en"
  }
  
  # Return translation or key if not found
  return(translations_data$translation[[key]][[lang]] %||% key)
}

# Render markdown to HTML with proper styling
# Note: CSS styles are now in www/bfh-theme.css under .markdown-content
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

  # Wrap in styled container (CSS defined in bfh-theme.css)
  styled_html <- paste0('<div class="markdown-content">', html_content, '</div>')

  return(HTML(styled_html))
}

# Built-in exercise library - comprehensive WDDA course coverage
BUILTIN_EXERCISES <- list(
  "data_import_excel" = list(
    title = "Import Excel Data",
    description = "Import data from an Excel file and explore its structure using readxl package",
    task = "Load the Excel file 'students_data.xlsx' using readxl, then display the structure and first few rows",
    reference_solution = "library(readxl)\nstudents <- read_excel('students_data.xlsx')\nstr(students)\nhead(students)",
    category = "Data Import",
    difficulty = "Beginner"
  ),
  "data_exploration" = list(
    title = "Data Structure Exploration",
    description = "Explore the structure and properties of a dataset",
    task = "Use str(), names(), dim(), and summary() to explore the dataset structure",
    reference_solution = "str(students)\nnames(students)\ndim(students)\nsummary(students)",
    category = "Data Import",
    difficulty = "Beginner"
  ),
  "descriptive_stats_basic" = list(
    title = "Basic Descriptive Statistics",
    description = "Calculate central tendency measures for numeric variables",
    task = "Calculate the mean, median, and mode for the 'score' variable, handling missing values",
    reference_solution = "mean(students$score, na.rm = TRUE)\nmedian(students$score, na.rm = TRUE)\n# Mode calculation\ntable(students$score) |> which.max() |> names()",
    category = "Descriptive Statistics",
    difficulty = "Beginner"
  ),
  "descriptive_stats_spread" = list(
    title = "Measures of Variability",
    description = "Calculate dispersion measures to understand data spread",
    task = "Calculate range, variance, standard deviation, and quartiles for the 'score' variable",
    reference_solution = "range(students$score, na.rm = TRUE)\nvar(students$score, na.rm = TRUE)\nsd(students$score, na.rm = TRUE)\nquantile(students$score, na.rm = TRUE)",
    category = "Descriptive Statistics",
    difficulty = "Intermediate"
  ),
  "histogram_basic" = list(
    title = "Create a Histogram",
    description = "Visualize the distribution of a continuous variable using histogram",
    task = "Create a histogram of student scores with proper titles and labels",
    reference_solution = "hist(students$score,\n     main = 'Distribution of Student Scores',\n     xlab = 'Score',\n     ylab = 'Frequency',\n     col = 'skyblue',\n     breaks = 10)",
    category = "Data Visualization",
    difficulty = "Beginner"
  ),
  "boxplot_comparison" = list(
    title = "Boxplot for Group Comparison",
    description = "Compare distributions across groups using boxplots",
    task = "Create a boxplot comparing scores by student major",
    reference_solution = "boxplot(score ~ major, \n        data = students,\n        main = 'Scores by Major',\n        xlab = 'Major',\n        ylab = 'Score',\n        col = c('lightblue', 'lightgreen', 'lightcoral'))",
    category = "Data Visualization",
    difficulty = "Intermediate"
  ),
  "pipe_filtering" = list(
    title = "Data Filtering with Pipes",
    description = "Use pipe operators for readable data filtering operations",
    task = "Filter students with scores > 80 and select name, major, and score columns using pipes",
    reference_solution = "library(dplyr)\nstudents |>\n  filter(score > 80) |>\n  select(name, major, score)",
    category = "Data Manipulation",
    difficulty = "Intermediate"
  ),
  "pipe_summarizing" = list(
    title = "Data Summarization with Pipes",
    description = "Create summary statistics by groups using pipe operations",
    task = "Group by major and calculate mean and median scores for each group",
    reference_solution = "students |>\n  group_by(major) |>\n  summarise(\n    mean_score = mean(score, na.rm = TRUE),\n    median_score = median(score, na.rm = TRUE),\n    n = n()\n  )",
    category = "Data Manipulation",
    difficulty = "Advanced"
  ),
  "data_mutate" = list(
    title = "Creating New Variables",
    description = "Add new calculated variables to your dataset",
    task = "Create a new variable 'grade' based on score (A: 90+, B: 80-89, C: 70-79, D: <70)",
    reference_solution = "students <- students |>\n  mutate(\n    grade = case_when(\n      score >= 90 ~ 'A',\n      score >= 80 ~ 'B',\n      score >= 70 ~ 'C',\n      TRUE ~ 'D'\n    )\n  )",
    category = "Data Manipulation",
    difficulty = "Advanced"
  ),
  "barplot_categorical" = list(
    title = "Bar Chart for Categories",
    description = "Visualize categorical data using bar charts",
    task = "Create a bar chart showing the count of students by major",
    reference_solution = "major_counts <- table(students$major)\nbarplot(major_counts,\n        main = 'Number of Students by Major',\n        xlab = 'Major',\n        ylab = 'Count',\n        col = rainbow(length(major_counts)))",
    category = "Data Visualization",
    difficulty = "Beginner"
  ),
  "correlation_analysis" = list(
    title = "Correlation Analysis",
    description = "Examine relationships between numeric variables",
    task = "Calculate correlation between study_hours and score variables",
    reference_solution = "cor(students$study_hours, students$score, use = 'complete.obs')\n# Create scatter plot\nplot(students$study_hours, students$score,\n     main = 'Study Hours vs Score',\n     xlab = 'Study Hours',\n     ylab = 'Score',\n     pch = 16,\n     col = 'blue')",
    category = "Statistical Analysis",
    difficulty = "Advanced"
  ),
  "missing_data" = list(
    title = "Handling Missing Data",
    description = "Identify and handle missing values in your dataset",
    task = "Check for missing values and calculate statistics excluding them",
    reference_solution = "# Check for missing values\nsum(is.na(students$score))\n# Remove missing values\nstudents_clean <- students |>\n  filter(!is.na(score))\n# Or use na.rm in calculations\nmean(students$score, na.rm = TRUE)",
    category = "Data Cleaning",
    difficulty = "Intermediate"
  )
)

# LLM Provider configuration
# OpenRouter allows access to many models through a unified API
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
    # Recommended models for R code analysis (can be customized)
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

ui <- function(request) {
  # Add BFH theme CSS and language selector to page
  div(
    # Add BFH theme CSS
    add_bfh_theme(),
    
    # Enable shinyjs
    useShinyjs(),
    
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
      
      # Add BFH header as header content
      header = div(
        id = "dynamic_header",
        create_bfh_header(
          textOutput("header_title", inline = TRUE),
          textOutput("header_subtitle", inline = TRUE)
        )
      ),
  
      nav_panel(
        title = textOutput("interactive_demo_title", inline = TRUE),
        
        layout_sidebar(
          sidebar = sidebar(
            open = "always",
            position = "left",
            width = 380,
            
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
                    choices = c(
                      "Qwen 2.5 Coder 32B (Best for coding)" = "qwen/qwen-2.5-coder-32b-instruct",
                      "DeepSeek V3 (Best value)" = "deepseek/deepseek-chat",
                      "DeepSeek V3 Free (Free tier)" = "deepseek/deepseek-chat-v3-0324:free",
                      "Gemini 2.0 Flash (Free tier)" = "google/gemini-2.0-flash-exp:free",
                      "Llama 3.3 70B (Strong general)" = "meta-llama/llama-3.3-70b-instruct",
                      "Mistral Large (Balanced)" = "mistralai/mistral-large-2411",
                      "Claude 3.5 Haiku (Fast)" = "anthropic/claude-3.5-haiku",
                      "GPT-4o Mini (Reliable)" = "openai/gpt-4o-mini"
                    ),
                    selected = "qwen/qwen-2.5-coder-32b-instruct"
                  ),
                  div(class = "text-muted text-small mb-2",
                      textOutput("model_selection_help")
                  )
                ),
                
                # API Key Input
                conditionalPanel(
                  condition = "input.llm_provider != ''",
                  passwordInput(
                    "api_key",
                    textOutput("api_key_label", inline = TRUE),
                    placeholder = "Enter your API key"
                  ),
                  div(class = "text-muted text-small",
                      textOutput("api_key_help")
                  ),
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
                  ),
                  div(class = "text-danger text-small mt-2",
                      textOutput("api_key_error", inline = TRUE)
                  )
                )
              )
            )
          ),
          
          # Exercise Input Panel (Main Feature)
          create_bfh_panel(
            title = textOutput("exercise_input_title", inline = TRUE),
            content = tagList(
              div(class = "bfh-card-content",
                  p(textOutput("exercise_input_help"), class = "text-muted"),
                  # Text area for exercise description
                  textAreaInput(
                    "exercise_text",
                    textOutput("exercise_text_label", inline = TRUE),
                    placeholder = "Paste your exercise text here or use Ctrl+V to paste a screenshot...",
                    height = "150px",
                    width = "100%"
                  ),
                  # Add JavaScript for clipboard image handling
                  tags$script(HTML("
                    $(document).ready(function() {
                      var MAX_IMAGE_SIZE = 5 * 1024 * 1024; // 5MB limit

                      // Handle paste events on the exercise text area
                      $('#exercise_text').on('paste', function(e) {
                        var items = (e.originalEvent.clipboardData || window.clipboardData).items;

                        for (var i = 0; i < items.length; i++) {
                          if (items[i].type.indexOf('image') !== -1) {
                            var blob = items[i].getAsFile();

                            // Check file size before processing
                            if (blob.size > MAX_IMAGE_SIZE) {
                              Shiny.setInputValue('pasted_image_error', 'Image too large (max 5MB)', {priority: 'event'});
                              e.preventDefault();
                              return;
                            }

                            var reader = new FileReader();

                            reader.onload = function(event) {
                              // Send the image data to Shiny
                              Shiny.setInputValue('pasted_image_data', event.target.result, {priority: 'event'});
                            };

                            reader.readAsDataURL(blob);
                            e.preventDefault(); // Prevent the default paste action for images
                          }
                        }
                      });
                    });
                  ")),
                  # Image display area for pasted screenshots
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
                  div(class = "d-flex gap-2",
                      bfh_action_button(
                        "clear_exercise",
                        textOutput("clear_exercise_text", inline = TRUE),
                        style = "secondary"
                      )
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
              div(class = "d-flex gap-2",
                  bfh_action_button(
                    "analyze_code",
                    textOutput("analyze_button_text", inline = TRUE),
                    style = "primary"
                  ),
                  bfh_action_button(
                    "clear_code",
                    textOutput("clear_button_text", inline = TRUE),
                    style = "secondary"
                  )
              )
            )
          ),
          
          # Feedback panel (full width)
          create_bfh_card(
            tagList(
              h4(textOutput("feedback_title", inline = TRUE), class = "bfh-color-1"),
              div(id = "feedback_content",
                  div(class = "bfh-card-highlight",
                      uiOutput("feedback_display")
                  )
              )
            ),
            highlight = TRUE
          ),
          
        )
      ),
      
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
      ), # close nav_panel (Theory)
      
      # Add language selector as right-aligned nav item
      nav_spacer(),
      nav_item(create_language_selector("en"))
    ) # close page_navbar
  ) # close outer div
}

server <- function(input, output, session) {

  # Reactive value for language (session-scoped)
  current_lang <- reactiveVal("en")

  # Reactive values for API key management
  api_key_saved <- reactiveVal(FALSE)
  saved_api_key <- reactiveVal("")

  # Reactive values for exercise input
  has_exercise_image <- reactiveVal(FALSE)
  exercise_image_data <- reactiveVal("")

  # Auto-detect API keys from environment variables (local development only)
  # This does NOT run in webR/Shinylive deployment (sandboxed, no env var access)
  observe({
    # Skip if running in webR/Shinylive (WASM/Emscripten platform)
    if (grepl("wasm|emscripten", R.version$platform, ignore.case = TRUE)) {
      return()
    }

    # Check for OpenRouter API key first (preferred)
    openrouter_key <- Sys.getenv("OPENROUTER_API_KEY", "")
    if (nzchar(openrouter_key)) {
      updateSelectInput(session, "llm_provider", selected = "openrouter")
      updateTextInput(session, "api_key", value = openrouter_key)
      saved_api_key(openrouter_key)
      api_key_saved(TRUE)
      return()
    }

    # Check for OpenAI API key
    openai_key <- Sys.getenv("OPENAI_API_KEY", "")
    if (nzchar(openai_key)) {
      updateSelectInput(session, "llm_provider", selected = "openai")
      updateTextInput(session, "api_key", value = openai_key)
      saved_api_key(openai_key)
      api_key_saved(TRUE)
      return()
    }

    # Check for Anthropic API key
    anthropic_key <- Sys.getenv("ANTHROPIC_API_KEY", "")
    if (nzchar(anthropic_key)) {
      updateSelectInput(session, "llm_provider", selected = "anthropic")
      updateTextInput(session, "api_key", value = anthropic_key)
      saved_api_key(anthropic_key)
      api_key_saved(TRUE)
      return()
    }
  }) |> bindEvent(TRUE, once = TRUE)  # Run only once on session start

  # Update language when user changes selection
  observeEvent(input$selected_language, {
    current_lang(input$selected_language)
  })
  
  # Reactive text outputs for translations
  output$header_title <- renderText({ translate_text("R Code Feedback App", current_lang()) })
  output$header_subtitle <- renderText({ translate_text("AI-Powered Learning Assistant for WDDA Course", current_lang()) })
  output$interactive_demo_title <- renderText({ translate_text("Code Analysis", current_lang()) })
  output$theory_title <- renderText({ translate_text("R Programming Guide", current_lang()) })
  output$settings_title <- renderText({ translate_text("Settings", current_lang()) })
  output$llm_provider_label <- renderText({ translate_text("AI Provider", current_lang()) })
  output$model_selection_label <- renderText({ translate_text("Model Selection", current_lang()) })
  output$model_selection_help <- renderText({ translate_text("Choose a model based on your needs - coding specialists offer better R feedback", current_lang()) })
  output$api_key_label <- renderText({ translate_text("API Key", current_lang()) })
  output$api_key_help <- renderText({ translate_text("Enter your API key to enable AI feedback", current_lang()) })
  output$save_api_key_text <- renderText({ translate_text("Save API Key", current_lang()) })
  output$api_key_saved_text <- renderText({ translate_text("API Key saved successfully", current_lang()) })
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
  
  
  # Clear code button
  observeEvent(input$clear_code, {
    updateTextAreaInput(session, "student_code", value = "")
  })
  
  # API key format validation helper
  validate_api_key <- function(key, provider) {
    key <- trimws(key)
    if (nchar(key) == 0) {
      return(list(valid = FALSE, message = "API key is required"))
    }
    if (provider == "openai" && !grepl("^sk-", key)) {
      return(list(valid = FALSE, message = "OpenAI API keys should start with 'sk-'"))
    }
    if (provider == "anthropic" && !grepl("^sk-ant-", key)) {
      return(list(valid = FALSE, message = "Anthropic API keys should start with 'sk-ant-'"))
    }
    if (provider == "openrouter" && !grepl("^sk-or-", key)) {
      return(list(valid = FALSE, message = "OpenRouter API keys should start with 'sk-or-'"))
    }
    return(list(valid = TRUE, message = ""))
  }

  # Reactive value for API key validation error
  api_key_error <- reactiveVal("")

  # Save API key button
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
  
  # Reset API key status when provider changes
  observeEvent(input$llm_provider, {
    api_key_saved(FALSE)
    saved_api_key("")
    api_key_error("")
  })

  # Output for API key saved status
  output$api_key_saved <- reactive({
    api_key_saved()
  })
  outputOptions(output, "api_key_saved", suspendWhenHidden = FALSE)

  # Output for API key error message
  output$api_key_error <- renderText({
    api_key_error()
  })
  
  # Clear exercise button
  observeEvent(input$clear_exercise, {
    updateTextAreaInput(session, "exercise_text", value = "")
    has_exercise_image(FALSE)
    exercise_image_data("")
  })
  
  # Clear exercise image button
  observeEvent(input$clear_exercise_image, {
    has_exercise_image(FALSE)
    exercise_image_data("")
  })
  
  # Handle pasted image data
  observeEvent(input$pasted_image_data, {
    if (!is.null(input$pasted_image_data)) {
      has_exercise_image(TRUE)
      exercise_image_data(input$pasted_image_data)

      # Update the image display
      output$exercise_image_display <- renderUI({
        tags$img(src = input$pasted_image_data,
                style = "max-width: 100%; height: auto; border-radius: 4px;")
      })
    }
  })

  # Handle pasted image error (e.g., file too large)
  observeEvent(input$pasted_image_error, {
    if (!is.null(input$pasted_image_error)) {
      showNotification(
        input$pasted_image_error,
        type = "error",
        duration = 5
      )
    }
  })
  
  # Output for exercise image status
  output$has_exercise_image <- reactive({
    has_exercise_image()
  })
  outputOptions(output, "has_exercise_image", suspendWhenHidden = FALSE)
  
  # Feedback analysis
  observeEvent(input$analyze_code, {
    if (nchar(trimws(input$student_code)) == 0) {
      output$feedback_display <- renderUI({
        div(class = "alert alert-warning",
            p(translate_text("Please enter some R code to analyze", current_lang()))
        )
      })
      return()
    }
    
    # Show spinner immediately with JavaScript (using translated text)
    loading_msg <- translate_text("Analyzing your code... Please wait, this may take a few moments.", current_lang())
    shinyjs::runjs(sprintf("
      $('#feedback_display').html(`
        <div class='alert alert-info'>
          <div class='d-flex align-items-center'>
            <div class='spinner-border spinner-border-sm me-2' role='status' style='width: 1.2rem; height: 1.2rem;'>
              <span class='visually-hidden'>Loading...</span>
            </div>
            <span>🤖 %s</span>
          </div>
        </div>
      `);
    ", loading_msg))
    
    # Use custom exercise input
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

    # Get API key - use saved key if available, otherwise use input directly
    api_key_to_use <- if (nzchar(saved_api_key())) saved_api_key() else trimws(input$api_key)

    # Perform analysis
    feedback_result <- analyze_code(
      student_code = input$student_code,
      exercise = exercise_context,
      provider = input$llm_provider,
      api_key = api_key_to_use,
      model = if (input$llm_provider == "openrouter") input$openrouter_model else NULL,
      lang = current_lang()
    )

    # Update with results 
    output$feedback_display <- renderUI({
      result_ui <- create_feedback_ui(feedback_result, current_lang())
      result_ui
    })
    
    # Scroll to feedback after UI is updated
    shinyjs::delay(500, {
      shinyjs::runjs("
        var feedbackEl = document.getElementById('feedback_display');
        if (feedbackEl) {
          feedbackEl.scrollIntoView({ 
            behavior: 'smooth', 
            block: 'start' 
          });
        }
      ")
    })
  })
  
  # Theory content
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

# Feedback analysis function
analyze_code <- function(student_code, exercise, provider = "", api_key = "", model = NULL, lang = "en") {
  feedback <- list(
    syntax_check = check_syntax(student_code),
    rule_based = check_rules(student_code, exercise),
    ai_feedback = NULL
  )

  # Add AI feedback if provider and key are available
  if (provider != "" && api_key != "") {
    feedback$ai_feedback <- get_ai_feedback(student_code, exercise, provider, api_key, model, lang)
  }

  return(feedback)
}

# Basic syntax checking - just validates R parsing
check_syntax <- function(code) {
  tryCatch({
    parse(text = code)
    list(valid = TRUE, message = "Code can be parsed")
  }, error = function(e) {
    list(valid = FALSE, message = paste("Syntax error:", e$message))
  })
}

# Rule-based pattern checking
check_rules <- function(code, exercise) {
  issues <- c()
  suggestions <- c()
  good_practices <- c()
  
  # Category-specific checks
  if (exercise$category == "Data Import") {
    # Check for required packages
    if (!grepl("library\\(readxl\\)", code)) {
      issues <- c(issues, "Missing library(readxl) - needed for Excel import")
    }
    if (!grepl("read_excel\\(", code)) {
      issues <- c(issues, "Use read_excel() function to import Excel files")
    }
    # Check for data exploration
    if (grepl("str\\(", code)) {
      good_practices <- c(good_practices, "Great! Using str() to explore data structure")
    }
    if (grepl("head\\(", code)) {
      good_practices <- c(good_practices, "Good practice using head() to preview data")
    }
  }
  
  if (exercise$category == "Descriptive Statistics") {
    # Check for missing value handling
    if (grepl("na\\.rm\\s*=\\s*TRUE", code)) {
      good_practices <- c(good_practices, "Excellent! Properly handling missing values with na.rm = TRUE")
    } else if (grepl("mean\\(|median\\(|sd\\(", code)) {
      suggestions <- c(suggestions, "Consider adding na.rm = TRUE to handle missing values")
    }
    
    # Check for appropriate functions
    if (grepl("mean\\(", code)) {
      good_practices <- c(good_practices, "Using mean() for central tendency")
    }
    if (grepl("median\\(", code)) {
      good_practices <- c(good_practices, "Using median() - robust measure of center")
    }
    if (grepl("sd\\(|var\\(", code)) {
      good_practices <- c(good_practices, "Good use of variability measures")
    }
  }
  
  if (exercise$category == "Data Manipulation") {
    # Check for pipe usage
    if (grepl("\\|>", code)) {
      good_practices <- c(good_practices, "Excellent use of pipe operator for readable code!")
    } else if (grepl("filter\\(|select\\(|mutate\\(", code)) {
      suggestions <- c(suggestions, "Consider using pipe operator |> for cleaner code flow")
    }
    
    # Check for dplyr functions
    if (grepl("library\\(dplyr\\)", code)) {
      good_practices <- c(good_practices, "Good practice loading dplyr library")
    }
    if (grepl("filter\\(", code)) {
      good_practices <- c(good_practices, "Using filter() for data subsetting")
    }
    if (grepl("select\\(", code)) {
      good_practices <- c(good_practices, "Using select() to choose specific columns")
    }
  }
  
  if (exercise$category == "Data Visualization") {
    # Check for proper labeling
    if (grepl("main\\s*=", code)) {
      good_practices <- c(good_practices, "Good practice adding a main title")
    } else {
      suggestions <- c(suggestions, "Consider adding a main title with main = 'Your Title'")
    }
    
    if (grepl("xlab\\s*=|ylab\\s*=", code)) {
      good_practices <- c(good_practices, "Excellent axis labeling!")
    } else {
      suggestions <- c(suggestions, "Add axis labels with xlab and ylab for clarity")
    }
    
    # Check for appropriate plot types
    if (grepl("hist\\(", code)) {
      good_practices <- c(good_practices, "Using histogram for continuous data distribution")
    }
    if (grepl("boxplot\\(", code)) {
      good_practices <- c(good_practices, "Boxplot is great for comparing groups")
    }
  }
  
  if (exercise$category == "Statistical Analysis") {
    if (grepl("cor\\(", code)) {
      good_practices <- c(good_practices, "Using correlation to examine relationships")
    }
  }
  
  if (exercise$category == "Data Cleaning") {
    if (grepl("is\\.na\\(", code)) {
      good_practices <- c(good_practices, "Good use of is.na() to check missing values")
    }
  }
  
  # Minimal general checks - let the LLM do the heavy lifting
  list(issues = issues, suggestions = suggestions, good_practices = good_practices)
}

# AI feedback with actual API implementation
get_ai_feedback <- function(student_code, exercise, provider, api_key, model = NULL, lang = "en") {
  if (is.null(provider) || provider == "" || is.null(api_key) || api_key == "") {
    return(list(
      available = FALSE,
      message = "Please configure AI provider and API key in Settings"
    ))
  }

  # Create the prompt for the AI
  exercise_context <- ""
  if (!is.null(exercise) && !is.null(exercise$description) && exercise$description != "") {
    exercise_context <- paste("Exercise context:", exercise$description, "\n\n")
  }

 # Language-specific instructions
  lang_instruction <- switch(lang,
    "de" = "WICHTIG: Antworte komplett auf Deutsch. Alle Erklärungen, Feedback und Kommentare müssen auf Deutsch sein.",
    "fr" = "IMPORTANT: Réponds entièrement en français. Toutes les explications, commentaires et retours doivent être en français.",
    "IMPORTANT: Respond entirely in English."
  )

  prompt <- paste0(
    "You are an R programming tutor providing constructive feedback to students learning R programming.\n\n",
    lang_instruction, "\n\n",
    exercise_context,
    "Student's R code:\n```r\n", student_code, "\n```\n\n",
    "Provide helpful, encouraging feedback that covers:\n",
    "1. **Code Analysis**: Review correctness, identify any errors, and suggest fixes\n",
    "2. **Best Practices**: Highlight good coding habits and suggest style improvements\n",
    "3. **Learning Opportunities**: Point out clever solutions or suggest alternative approaches\n",
    "4. **Next Steps**: Recommend what the student could explore next to improve their R skills\n\n",
    "IMPORTANT FORMATTING RULES:\n",
    "- Output ONLY the feedback itself - do NOT include any thinking, reasoning, or planning\n",
    "- Start directly with a friendly greeting and the feedback content\n",
    "- Do NOT write phrases like 'Let me analyze...' or 'I need to...' or 'Okay, let me...'\n",
    "- Use markdown formatting (headers, bullet points, code blocks)\n",
    "- Start with positive observations\n",
    "- Keep the tone supportive and educational"
  )

  tryCatch({
    if (provider == "openai") {
      return(call_openai_api(prompt, api_key))
    } else if (provider == "anthropic") {
      return(call_anthropic_api(prompt, api_key))
    } else if (provider == "openrouter") {
      return(call_openrouter_api(prompt, api_key, model))
    } else {
      return(list(
        available = FALSE,
        message = "Unsupported AI provider"
      ))
    }
  }, error = function(e) {
    return(list(
      available = FALSE,
      message = paste("AI API Error:", e$message)
    ))
  })
}

# OpenAI API call
call_openai_api <- function(prompt, api_key) {
  tryCatch({
    response <- request("https://api.openai.com/v1/chat/completions") |>
      req_headers(
        "Authorization" = paste("Bearer", api_key),
        "Content-Type" = "application/json"
      ) |>
      req_body_json(list(
        model = "gpt-4o-mini",
        messages = list(
          list(role = "user", content = prompt)
        ),
        max_tokens = 1000,
        temperature = 0.7
      )) |>
      req_timeout(30) |>
      req_perform()
    
    if (resp_status(response) == 200) {
      result <- resp_body_json(response)

      # Validate response structure
      if (!is.null(result$choices) &&
          length(result$choices) > 0 &&
          !is.null(result$choices[[1]]$message$content)) {
        feedback_text <- result$choices[[1]]$message$content
        return(list(
          available = TRUE,
          message = feedback_text,
          provider = "OpenAI GPT-4o-mini"
        ))
      } else {
        return(list(
          available = FALSE,
          message = "OpenAI API Error: Unexpected response format"
        ))
      }
    } else {
      error_info <- tryCatch(resp_body_json(response), error = function(e) list())
      return(list(
        available = FALSE,
        message = paste("OpenAI API Error:", error_info$error$message %||% "Unknown error")
      ))
    }
  }, error = function(e) {
    return(list(
      available = FALSE,
      message = paste("OpenAI API Error:", e$message)
    ))
  })
}

# Anthropic API call  
call_anthropic_api <- function(prompt, api_key) {
  tryCatch({
    response <- request("https://api.anthropic.com/v1/messages") |>
      req_headers(
        "x-api-key" = api_key,
        "Content-Type" = "application/json",
        "anthropic-version" = "2023-06-01"
      ) |>
      req_body_json(list(
        model = "claude-3-haiku-20240307",
        max_tokens = 1000,
        messages = list(
          list(role = "user", content = prompt)
        )
      )) |>
      req_timeout(30) |>
      req_perform()
    
    if (resp_status(response) == 200) {
      result <- resp_body_json(response)

      # Validate response structure
      if (!is.null(result$content) &&
          length(result$content) > 0 &&
          !is.null(result$content[[1]]$text)) {
        feedback_text <- result$content[[1]]$text
        return(list(
          available = TRUE,
          message = feedback_text,
          provider = "Anthropic Claude-3-Haiku"
        ))
      } else {
        return(list(
          available = FALSE,
          message = "Anthropic API Error: Unexpected response format"
        ))
      }
    } else {
      error_info <- tryCatch(resp_body_json(response), error = function(e) list())
      return(list(
        available = FALSE,
        message = paste("Anthropic API Error:", error_info$error$message %||% "Unknown error")
      ))
    }
  }, error = function(e) {
    return(list(
      available = FALSE,
      message = paste("Anthropic API Error:", e$message)
    ))
  })
}

# Helper function to strip thinking/reasoning content from LLM responses
strip_thinking_content <- function(text) {
  # Step 1: Remove <think>...</think> blocks (used by DeepSeek and others)
  # Use (?s) for DOTALL mode to match across newlines
  text <- gsub("(?s)<think>.*?</think>", "", text, perl = TRUE)

  # Step 2: Remove <thinking>...</thinking> blocks
  text <- gsub("(?s)<thinking>.*?</thinking>", "", text, perl = TRUE)

  # Step 3: Remove common thinking preamble patterns at the start of response
  # These catch models that output "Okay, let me analyze..." before actual feedback
  thinking_preambles <- c(
    "^\\s*Okay,?\\s+(let me|I'll|I need|I should|so)[^\\n]*\\n+",
    "^\\s*Alright,?\\s+(let me|I'll|I need|I should|so)[^\\n]*\\n+",
    "^\\s*Let me (analyze|look|check|review|examine|think|consider|see|figure)[^\\n]*\\n+",
    "^\\s*I('ll| will| need to| should)\\s+(analyze|look|check|review|examine|think|consider|see|figure)[^\\n]*\\n+",
    "^\\s*Looking at (this|the|your)[^\\n]*\\n+",
    "^\\s*First,? (let me|I'll|I need|I should)[^\\n]*\\n+",
    "^\\s*So,?\\s+(the|this|looking|let me|I)[^\\n]*\\n+",
    "^\\s*Hmm,?[^\\n]*\\n+",
    "^\\s*Now,? (let me|I'll|I need)[^\\n]*\\n+"
  )

  # Apply each pattern repeatedly until no more matches
  for (pattern in thinking_preambles) {
    prev_text <- ""
    iterations <- 0
    while (prev_text != text && iterations < 10) {
      prev_text <- text
      text <- sub(pattern, "", text, perl = TRUE, ignore.case = TRUE)
      iterations <- iterations + 1
    }
  }

  # Step 4: If text still has thinking content, find where actual feedback starts
  # Look for common feedback starters and strip everything before them
  feedback_starters <- c(
    "(?m)^Hi[!,]",                    # "Hi!" or "Hi,"
    "(?m)^Hello[!,]",                 # "Hello!" or "Hello,"
    "(?m)^Hey[!,]",                   # "Hey!" or "Hey,"
    "(?m)^Great (job|work|effort|start)",
    "(?m)^Good (job|work|effort|start)",
    "(?m)^Nice (job|work|effort|try)",
    "(?m)^Well done",
    "(?m)^Thank you",
    "(?m)^Thanks for",
    "(?m)^I (see|notice|can see)",
    "(?m)^## ",                       # Markdown H2
    "(?m)^# ",                        # Markdown H1
    "(?m)^\\*\\*",                    # Bold markdown
    "(?m)^Your (code|solution|approach)",
    "(?m)^The (code|solution)",
    "(?m)^This (code|looks|is)"
  )

  for (pattern in feedback_starters) {
    match <- regexpr(pattern, text, perl = TRUE)
    if (match[1] > 1 && match[1] < 500) {
      # Found actual feedback within first 500 chars - strip preamble
      text <- substr(text, match[1], nchar(text))
      break
    }
  }

  return(trimws(text))
}

# OpenRouter API call (supports multiple models)
call_openrouter_api <- function(prompt, api_key, model = "deepseek/deepseek-chat") {
  if (is.null(model) || model == "") {
    model <- "deepseek/deepseek-chat"
  }

  # Extract human-readable model name for display
  model_display_name <- switch(model,
    "qwen/qwen-2.5-coder-32b-instruct" = "Qwen 2.5 Coder 32B",
    "deepseek/deepseek-chat" = "DeepSeek V3",
    "deepseek/deepseek-chat-v3-0324:free" = "DeepSeek V3 (Free)",
    "google/gemini-2.0-flash-exp:free" = "Gemini 2.0 Flash (Free)",
    "meta-llama/llama-3.3-70b-instruct" = "Llama 3.3 70B",
    "mistralai/mistral-large-2411" = "Mistral Large",
    "anthropic/claude-3.5-haiku" = "Claude 3.5 Haiku",
    "openai/gpt-4o-mini" = "GPT-4o Mini",
    model  # fallback to model ID
  )

  tryCatch({
    response <- request("https://openrouter.ai/api/v1/chat/completions") |>
      req_headers(
        "Authorization" = paste("Bearer", api_key),
        "Content-Type" = "application/json",
        "HTTP-Referer" = "https://github.com/umatter/inffer_feedback_app",
        "X-Title" = "WDDA R Code Feedback App"
      ) |>
      req_body_json(list(
        model = model,
        messages = list(
          list(role = "user", content = prompt)
        ),
        max_tokens = 1000,
        temperature = 0.7,
        # Disable extended thinking/reasoning for models that support it
        # This prevents reasoning tokens from appearing in the response
        reasoning = list(exclude = TRUE)
      )) |>
      req_timeout(60) |>  # longer timeout for OpenRouter routing
      req_perform()

    if (resp_status(response) == 200) {
      result <- resp_body_json(response)

      # OpenRouter uses OpenAI-compatible response format
      if (!is.null(result$choices) &&
          length(result$choices) > 0 &&
          !is.null(result$choices[[1]]$message$content)) {
        feedback_text <- result$choices[[1]]$message$content
        # Strip any thinking/reasoning content that some models output
        feedback_text <- strip_thinking_content(feedback_text)
        return(list(
          available = TRUE,
          message = feedback_text,
          provider = paste("OpenRouter:", model_display_name)
        ))
      } else {
        return(list(
          available = FALSE,
          message = "OpenRouter API Error: Unexpected response format"
        ))
      }
    } else {
      error_info <- tryCatch(resp_body_json(response), error = function(e) list())
      error_msg <- error_info$error$message %||%
                   error_info$error$code %||%
                   "Unknown error"
      return(list(
        available = FALSE,
        message = paste("OpenRouter API Error:", error_msg)
      ))
    }
  }, error = function(e) {
    return(list(
      available = FALSE,
      message = paste("OpenRouter API Error:", e$message)
    ))
  })
}

# Create feedback UI
create_feedback_ui <- function(feedback, lang) {
  ui_elements <- list()
  
  # Syntax feedback
  if (feedback$syntax_check$valid) {
    ui_elements <- append(ui_elements, list(
      div(class = "alert alert-success",
          tags$strong("✓ Syntax: "), feedback$syntax_check$message)
    ))
  } else {
    ui_elements <- append(ui_elements, list(
      div(class = "alert alert-danger",
          tags$strong("✗ Syntax: "), feedback$syntax_check$message)
    ))
  }
  
  # Rule-based feedback
  if (length(feedback$rule_based$issues) > 0) {
    ui_elements <- append(ui_elements, list(
      div(class = "alert alert-warning",
          tags$strong("⚠️ Issues found:"),
          tags$ul(lapply(feedback$rule_based$issues, function(x) tags$li(x)))
      )
    ))
  }
  
  if (length(feedback$rule_based$good_practices) > 0) {
    ui_elements <- append(ui_elements, list(
      div(class = "alert alert-success",
          tags$strong("✅ Good practices:"),
          tags$ul(lapply(feedback$rule_based$good_practices, function(x) tags$li(x)))
      )
    ))
  }
  
  if (length(feedback$rule_based$suggestions) > 0) {
    ui_elements <- append(ui_elements, list(
      div(class = "alert alert-info",
          tags$strong("💡 Suggestions:"),
          tags$ul(lapply(feedback$rule_based$suggestions, function(x) tags$li(x)))
      )
    ))
  }
  
  # AI feedback
  if (!is.null(feedback$ai_feedback)) {
    if (feedback$ai_feedback$available) {
      ui_elements <- append(ui_elements, list(
        div(class = "alert alert-info",
            tags$strong("🤖 AI Feedback", if(!is.null(feedback$ai_feedback$provider)) paste0(" (", feedback$ai_feedback$provider, ")") else "", ":"),
            tags$div(
              style = "margin-top: 10px;",
              render_markdown_feedback(feedback$ai_feedback$message)
            )
        )
      ))
    } else {
      ui_elements <- append(ui_elements, list(
        div(class = "alert alert-secondary",
            tags$em("🤖 ", feedback$ai_feedback$message)
        )
      ))
    }
  }
  
  if (length(ui_elements) == 0) {
    ui_elements <- list(
      div(class = "alert alert-light",
          translate_text("Click 'Analyze Code' to get feedback on your R code.", lang())
      )
    )
  }
  
  return(do.call(tagList, ui_elements))
}

shinyApp(ui = ui, server = server, enableBookmarking = "url")