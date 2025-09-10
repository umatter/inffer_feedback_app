# BFH Theme Helper Functions for Shiny Apps
# Functions to apply consistent BFH branding across all applications

# BFH Color Palette (matching corporate design)
BFH_COLORS <- list(
  # Core palette (converted to hex for plotly compatibility)
  dunkelblau = "#506e96",
  dunkelgruen = "#556455", 
  dunkelviolett = "#645078",
  dunkelocker = "#786450",
  mittelgruen = "#699673",
  mittelblau = "#699bbe",
  mittelviolett = "#825a7d",
  mittelocker = "#96825f",
  hellgruen = "#8caf82",
  hellblau = "#87b9c8",
  
  # Online colors (WCAG-optimized)
  orange = "#fac300",
  grau = "#697d91",
  text_grau = "#4b647d",
  dunkelgrau = "#3c3c3c",
  
  # Grayscale series
  grauwert_1 = "#64788b",
  grauwert_2 = "#a2aeb9",
  grauwert_3 = "#c1c9d1",
  grauwert_4 = "#e0e4e8",
  grauwert_5 = "#eff1f3"
)

#' Get BFH Color Palette for Charts
#' 
#' Returns a vector of BFH colors suitable for use in charts and plots
#' 
#' @param type Type of palette: "primary" (blues/greens), "full" (all colors), "categorical" (distinct colors)
#' @param n Number of colors needed (will cycle if more than available)
#' @return Vector of hex color codes
#' 
#' @examples
#' get_bfh_palette("primary", 3)
#' get_bfh_palette("categorical", 5)
get_bfh_palette <- function(type = "primary", n = NULL) {
  
  palettes <- list(
    primary = c(BFH_COLORS$dunkelblau, BFH_COLORS$mittelblau, BFH_COLORS$hellblau,
                BFH_COLORS$dunkelgruen, BFH_COLORS$mittelgruen, BFH_COLORS$hellgruen),
    
    categorical = c(BFH_COLORS$dunkelblau, BFH_COLORS$mittelgruen, BFH_COLORS$dunkelviolett,
                   BFH_COLORS$dunkelocker, BFH_COLORS$hellblau, BFH_COLORS$mittelviolett),
    
    full = c(BFH_COLORS$dunkelblau, BFH_COLORS$dunkelgruen, BFH_COLORS$dunkelviolett,
             BFH_COLORS$dunkelocker, BFH_COLORS$mittelgruen, BFH_COLORS$mittelblau,
             BFH_COLORS$mittelviolett, BFH_COLORS$mittelocker, BFH_COLORS$hellgruen,
             BFH_COLORS$hellblau),
    
    grayscale = c(BFH_COLORS$dunkelgrau, BFH_COLORS$grauwert_1, BFH_COLORS$grauwert_2,
                  BFH_COLORS$grauwert_3, BFH_COLORS$grauwert_4, BFH_COLORS$text_grau)
  )
  
  palette <- palettes[[type]]
  
  if (is.null(n)) {
    return(palette)
  }
  
  if (n <= length(palette)) {
    return(palette[1:n])
  } else {
    # Cycle colors if more needed
    return(rep(palette, length.out = n))
  }
}

#' Create BFH-styled Panel
#' 
#' Creates a panel with BFH corporate design styling
#' 
#' @param title Panel title
#' @param content Panel content (HTML or tagList)
#' @param status Panel status ("primary", "info", "success", "warning")
#' @return HTML div with BFH styling
create_bfh_panel <- function(title = NULL, content, status = "primary") {
  
  status_classes <- list(
    primary = "bfh-panel",
    info = "bfh-panel bfh-card-highlight",
    success = "bfh-panel",
    warning = "bfh-panel"
  )
  
  panel_class <- status_classes[[status]] %||% "bfh-panel"
  
  if (!is.null(title)) {
    div(class = panel_class,
        div(class = "bfh-panel-header", title),
        content
    )
  } else {
    div(class = panel_class, content)
  }
}

#' Create BFH-styled Card
#' 
#' Creates a card component with BFH corporate design styling
#' 
#' @param content Card content
#' @param highlight Whether to highlight the card
#' @return HTML div with BFH card styling
create_bfh_card <- function(content, highlight = FALSE) {
  card_class <- if (highlight) "bfh-card bfh-card-highlight" else "bfh-card"
  div(class = card_class, content)
}

#' Apply BFH Theme to Plotly Chart
#' 
#' Applies BFH corporate colors and styling to a plotly chart
#' 
#' @param p A plotly plot object
#' @return Modified plotly plot with BFH styling
style_bfh_plotly <- function(p) {
  p %>%
    plotly::layout(
      font = list(family = "Lucida Sans, sans-serif", color = BFH_COLORS$text_grau),
      paper_bgcolor = "white",
      plot_bgcolor = "white",
      colorway = get_bfh_palette("categorical", 10),
      # Better margins for mobile
      margin = list(l = 60, r = 20, b = 60, t = 60, pad = 4)
    ) %>%
    plotly::config(
      displayModeBar = TRUE,
      modeBarButtonsToRemove = c("pan2d", "lasso2d", "select2d", "autoScale2d", 
                                 "hoverClosestCartesian", "hoverCompareCartesian",
                                 "toggleHover", "resetScale2d"),
      displaylogo = FALSE,
      # Mobile-friendly configuration
      responsive = TRUE,
      toImageButtonOptions = list(
        format = 'png',
        filename = 'central_limit_theorem_plot',
        height = 500,
        width = 700,
        scale = 1
      ),
      # Touch-friendly interactions
      scrollZoom = FALSE,
      doubleClick = "reset+autosize"
    )
}

#' Apply BFH Theme to ggplot2
#' 
#' Creates a ggplot2 theme following BFH corporate design
#' 
#' @return ggplot2 theme object
theme_bfh <- function() {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("ggplot2 package is required for theme_bfh()")
  }
  
  ggplot2::theme_minimal() +
    ggplot2::theme(
      text = ggplot2::element_text(family = "sans", color = BFH_COLORS$text_grau),
      plot.title = ggplot2::element_text(color = BFH_COLORS$dunkelblau, size = 16, face = "bold"),
      plot.subtitle = ggplot2::element_text(color = BFH_COLORS$grau, size = 12),
      axis.title = ggplot2::element_text(color = BFH_COLORS$text_grau, size = 11),
      axis.text = ggplot2::element_text(color = BFH_COLORS$grau, size = 10),
      legend.title = ggplot2::element_text(color = BFH_COLORS$text_grau, size = 11),
      legend.text = ggplot2::element_text(color = BFH_COLORS$grau, size = 10),
      panel.grid.major = ggplot2::element_line(color = BFH_COLORS$grauwert_4, linewidth = 0.5),
      panel.grid.minor = ggplot2::element_line(color = BFH_COLORS$grauwert_5, linewidth = 0.25),
      panel.border = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(color = BFH_COLORS$dunkelblau, face = "bold"),
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.background = ggplot2::element_rect(fill = "white", color = NA)
    )
}

#' Get BFH Color Scale for ggplot2
#' 
#' Provides BFH color scales for ggplot2 charts
#' 
#' @param type Type of scale: "fill" or "color"
#' @param palette Palette type: "primary", "categorical", "full"
#' @return ggplot2 scale function
scale_bfh <- function(type = "color", palette = "categorical") {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("ggplot2 package is required for scale_bfh()")
  }
  
  colors <- get_bfh_palette(palette)
  
  if (type == "fill") {
    ggplot2::scale_fill_manual(values = colors)
  } else {
    ggplot2::scale_color_manual(values = colors)
  }
}

#' Create BFH Action Button
#' 
#' Creates an action button with BFH styling
#' 
#' @param inputId Input ID for the button
#' @param label Button label
#' @param style Button style: "primary", "secondary", "success", "info"
#' @param icon Optional icon
#' @return Shiny action button with BFH styling
bfh_action_button <- function(inputId, label, style = "primary", icon = NULL) {
  
  style_classes <- list(
    primary = "btn btn-primary",
    secondary = "btn btn-secondary", 
    success = "btn btn-success",
    info = "btn btn-info",
    outline = "btn btn-outline-primary"
  )
  
  btn_class <- style_classes[[style]] %||% "btn btn-primary"
  
  actionButton(
    inputId = inputId,
    label = label,
    icon = icon,
    class = btn_class
  )
}

#' Add BFH Theme CSS to Shiny App
#' 
#' Adds the BFH theme CSS file to a Shiny app
#' 
#' @return HTML tags for including BFH CSS
add_bfh_theme <- function() {
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "bfh-theme.css"),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no"),
    tags$meta(name = "mobile-web-app-capable", content = "yes"),
    tags$meta(name = "apple-mobile-web-app-capable", content = "yes"),
    tags$meta(name = "apple-mobile-web-app-status-bar-style", content = "default"),
    tags$style(HTML("
      .shiny-notification {
        position: fixed;
        top: 20px;
        right: 20px;
        background: white;
        border: 1px solid #c1c9d1;
        border-left: 4px solid #fac300;
        border-radius: 4px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        z-index: 9999;
      }
      
      .shiny-notification-content {
        color: #4b647d;
        font-family: 'Lucida Sans', sans-serif;
      }
      
      /* Navbar title container styling */
      .navbar-title-container {
        display: flex;
        align-items: center;
        justify-content: space-between;
        width: 100%;
        max-width: 100%;
      }
      
      .navbar-title {
        flex: 1;
        margin: 0;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
      
      /* Language selector dropdown styling */
      .language-selector-dropdown {
        margin-left: 15px;
        flex-shrink: 0;
      }
      
      /* Language selector in navbar context */
      .nav-item .language-selector-dropdown {
        margin: 0;
        display: flex;
        align-items: center;
      }
      
      /* Responsive navbar adjustments */
      @media (max-width: 768px) {
        .navbar-title-container {
          flex-direction: row;
          gap: 10px;
        }
        
        .navbar-title {
          font-size: 0.9rem;
        }
        
        .language-selector-dropdown {
          margin-left: 0;
        }
      }
      
      .language-selector-dropdown .language-btn {
        background: transparent;
        border: 1px solid #c1c9d1;
        color: #4b647d;
        font-size: 12px;
        font-weight: 500;
        padding: 4px 12px;
        border-radius: 4px;
        min-width: 45px;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s ease;
        white-space: nowrap;
      }
      
      .language-selector-dropdown .language-btn:hover {
        background: #f8f9fa;
        border-color: #a2aeb9;
      }
      
      .language-selector-dropdown .language-btn:focus {
        box-shadow: 0 0 0 0.2rem rgba(80, 110, 150, 0.25);
        border-color: #506e96;
      }
      
      
      .language-selector-dropdown .language-menu {
        min-width: 45px;
        padding: 4px 0;
        border: 1px solid #c1c9d1;
        border-radius: 4px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      }
      
      .language-selector-dropdown .language-menu .dropdown-item {
        padding: 4px 12px;
        font-size: 12px;
        font-weight: 500;
        color: #4b647d;
        text-align: center;
      }
      
      .language-selector-dropdown .language-menu .dropdown-item:hover {
        background: #f8f9fa;
        color: #4b647d;
      }
      
      .language-selector-dropdown .language-menu .dropdown-item:active {
        background: #506e96;
        color: white;
      }

      /* Touch-friendly hover alternatives */
      @media (hover: none) and (pointer: coarse) {
        .btn:hover {
          transform: none;
          box-shadow: none;
        }
        
        .btn:active {
          transform: translateY(1px);
          box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        
        .bfh-logo:hover {
          transform: none;
        }
        
        .bfh-card:hover {
          box-shadow: 0 1px 3px rgba(0,0,0,0.12);
        }
        
        .language-selector-dropdown .language-btn:hover {
          background: transparent;
        }
        
        .language-selector-dropdown .language-menu .dropdown-item:hover {
          background: transparent;
        }
      }
    "))
  )
}

#' Create BFH Header
#' 
#' Creates a standardized header for BFH Shiny apps with logo
#' 
#' @param title App title
#' @param subtitle App subtitle (optional)
#' @param show_logo Whether to show BFH logo (default: TRUE)
#' @return HTML header with BFH styling
create_bfh_header <- function(title, subtitle = NULL, show_logo = TRUE) {
  
  if (show_logo) {
    header_content <- div(
      class = "bfh-header-with-logo d-flex align-items-center mb-3",
      div(
        class = "bfh-logo-container me-3",
        tags$img(
          src = "BFH_Logo_C_de_fr_en_100_RGB.png",
          alt = "Berner Fachhochschule Logo",
          class = "bfh-logo",
          style = "height: 60px; width: auto;"
        )
      ),
      div(
        class = "bfh-header-text flex-grow-1",
        tags$h1(title, class = "mb-1"),
        if (!is.null(subtitle)) {
          tags$p(class = "text-muted mb-0", subtitle)
        }
      )
    )
  } else {
    header_content <- tags$h1(title)
    
    if (!is.null(subtitle)) {
      header_content <- tagList(
        header_content,
        tags$p(class = "text-muted", subtitle)
      )
    }
  }
  
  div(class = "bfh-header mb-3", header_content)
}

#' Create Language Selector
#' 
#' Creates a clean single-button language selector that shows current language
#' 
#' @param selected Default selected language code
#' @return Shiny dropdown for language selection
create_language_selector <- function(selected = "en") {
  # Convert language codes to display labels
  lang_labels <- list("de" = "DE", "fr" = "FR", "en" = "EN")
  
  div(
    class = "language-selector-dropdown",
    
    # Custom dropdown button
    div(
      class = "dropdown",
      tags$button(
        class = "btn language-btn dropdown-toggle",
        type = "button",
        id = "languageDropdown",
        `data-bs-toggle` = "dropdown",
        `aria-expanded` = "false",
        span(id = "current-lang", lang_labels[[selected]])
      ),
      
      # Dropdown menu
      div(
        class = "dropdown-menu dropdown-menu-end language-menu",
        `aria-labelledby` = "languageDropdown",
        tags$a(class = "dropdown-item language-option", href = "#", `data-lang` = "de", "DE"),
        tags$a(class = "dropdown-item language-option", href = "#", `data-lang` = "fr", "FR"), 
        tags$a(class = "dropdown-item language-option", href = "#", `data-lang` = "en", "EN")
      )
    ),
    
    # JavaScript for dropdown functionality
    tags$script(HTML("
      $(document).ready(function() {
        $('.language-option').click(function(e) {
          e.preventDefault();
          var lang = $(this).data('lang');
          var langText = $(this).text();
          
          // Update button text
          $('#current-lang').text(langText);
          
          // Trigger Shiny input change
          Shiny.setInputValue('selected_language', lang);
          
          // Close dropdown
          $('.dropdown-toggle').dropdown('hide');
        });
      });
    "))
  )
}

#' Initialize BFH Translator
#' 
#' Creates and configures a shiny.i18n translator for BFH apps
#' 
#' @param translation_file Path to translations.json file
#' @param default_language Default language code
#' @return Translator object
create_bfh_translator <- function(translation_file = "translations.json", default_language = "en") {
  if (!requireNamespace("shiny.i18n", quietly = TRUE)) {
    stop("shiny.i18n package is required. Install with: install.packages('shiny.i18n')")
  }
  
  translator <- shiny.i18n::Translator$new(translation_json_path = translation_file)
  translator$set_translation_language(default_language)
  return(translator)
}

#' Null-coalescing operator
#' 
#' Returns the left-hand side if not NULL, otherwise the right-hand side
#' 
#' @param x Left-hand side
#' @param y Right-hand side
#' @return x if not NULL, otherwise y
`%||%` <- function(x, y) if (is.null(x)) y else x