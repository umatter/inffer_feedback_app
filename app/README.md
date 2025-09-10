# R Code Feedback App

## Overview

The R Code Feedback App is an AI-powered Shiny application that provides automated feedback on R code submissions for the BFH WDDA (Working with Data and Data Analysis) course. Built using the BFH template system, it maintains consistent branding while delivering educational feedback to help students learn R programming effectively.

## Learning Objectives

After using this app, students should be able to:

1. **Write syntactically correct R code**: Understand and avoid common syntax errors
2. **Apply best practices in R programming**: Use proper variable naming, commenting, and code organization
3. **Handle missing data appropriately**: Use functions like na.rm = TRUE in calculations
4. **Use modern R syntax**: Apply pipe operators |> for readable code workflows
5. **Create effective data visualizations**: Build properly labeled plots with appropriate chart types
6. **Understand data manipulation**: Filter, select, and transform data using dplyr functions

## Features

### Exercise Library
- **Data Import & Exploration**: Excel import with readxl, data structure exploration
- **Descriptive Statistics**: Central tendency, variability measures, quartiles
- **Data Visualization**: Histograms, boxplots, bar charts with proper labeling
- **Data Manipulation**: Filtering, summarizing, creating new variables with pipes
- **Advanced Topics**: Correlation analysis, missing data handling

### Multi-Layer Feedback System
- **Syntax Validation**: Real-time R syntax checking using webR
- **Rule-Based Analysis**: Pattern matching for common mistakes and best practices
- **AI-Powered Feedback**: Optional integration with OpenAI/Anthropic for contextual guidance
- **Pedagogical Approach**: Four-level feedback framework (Task/Process/Self-Regulation/Self)

### Interactive Controls
- **Exercise Selection**: Choose from 12+ exercises covering WDDA course topics
- **Code Editor**: Text area for R code input with syntax highlighting placeholder
- **LLM Provider Selection**: Optional AI provider (OpenAI, Anthropic) with secure API key input
- **Language Support**: Multi-language interface (English, German, French)

## How to Use

### Basic Code Analysis
1. **Select Exercise**: Choose an exercise from the categorized dropdown menu
2. **Read Instructions**: Review the exercise description and task requirements
3. **Write Code**: Enter your R code in the text area
4. **Get Feedback**: Click "Analyze Code" to receive immediate feedback
5. **Review Results**: Study the syntax validation, rule-based suggestions, and best practices

### Advanced AI Feedback (Optional)
1. **Choose Provider**: Select OpenAI or Anthropic from the dropdown
2. **Enter API Key**: Input your API key (stored in session memory only)
3. **Enhanced Analysis**: Receive contextual AI feedback in addition to rule-based analysis
4. **Learning Guidance**: Get pedagogically-informed suggestions based on exercise context

## Key Concepts Demonstrated

### 1. Syntax Validation
- Real-time R code parsing to catch syntax errors
- Clear error messages with specific line information
- Immediate feedback to prevent frustration

### 2. Rule-Based Pattern Recognition
- Category-specific analysis based on exercise type
- Recognition of best practices (proper function usage, commenting)
- Identification of common mistakes (missing libraries, improper comparisons)

### 3. Educational Feedback Design
- **Positive Reinforcement**: Highlights what students do correctly
- **Constructive Suggestions**: Actionable recommendations for improvement
- **Scaffolded Learning**: Hints before showing solutions

### 4. Modern R Practices
- Emphasis on pipe operators |> for readable code
- Proper handling of missing values with na.rm = TRUE
- Data visualization best practices with proper labeling

## Technical Implementation

### Shinylive Compatibility
- Uses only webR-compatible packages: shiny, bslib, DT, jsonlite, httr2
- No server dependencies - runs entirely in the browser
- Optimized for performance with client-side processing

### BFH Design Integration
- Full compliance with BFH corporate design standards
- Responsive layout using bslib framework
- Consistent color palette, typography, and component styling
- Multi-language support with standardized translations

### Privacy-First Architecture
- **No Data Persistence**: No databases, user accounts, or session tracking
- **Session-Only Storage**: API keys stored in browser memory only
- **Client-Side Processing**: All analysis happens in the browser
- **Optional AI**: Users choose whether to use external AI services

## Exercise Categories

### Data Import & Exploration
- **Import Excel Data**: Using readxl package for Excel file import
- **Data Structure Exploration**: str(), names(), dim(), summary() functions

### Descriptive Statistics  
- **Basic Statistics**: mean(), median(), mode calculations with missing value handling
- **Measures of Variability**: range(), var(), sd(), quantile() functions

### Data Visualization
- **Histogram**: Distribution visualization with proper labeling
- **Boxplot Comparison**: Group comparisons with categorical variables
- **Bar Chart**: Categorical data representation

### Data Manipulation
- **Filtering with Pipes**: Using |> operator with dplyr filter() and select()
- **Summarizing Data**: group_by() and summarise() workflows
- **Creating Variables**: mutate() and case_when() for new variable creation

### Advanced Topics
- **Correlation Analysis**: cor() function with scatter plot visualization
- **Missing Data**: is.na() identification and handling strategies

## Pedagogical Features

### Research-Based Feedback
- **Hattie & Timperley Framework**: Four-level feedback (Task/Process/Self-Regulation/Self)
- **Formative Focus**: Learning-oriented rather than evaluative feedback
- **Scaffolded Progression**: Hints → guidance → worked examples → direct instruction

### Learning Support
- **Immediate Response**: Real-time feedback to maintain learning momentum
- **Positive Language**: Growth mindset approach emphasizing improvement potential
- **Contextual Guidance**: Exercise-specific feedback tied to learning objectives

## Development Notes

### Implementation Status
- ✅ Core BFH template integration with corporate design
- ✅ Comprehensive exercise library (12 exercises across 5 categories)
- ✅ Multi-layer feedback system (syntax + rule-based + AI placeholder)
- ✅ Multi-language support (EN/DE/FR)
- ✅ LLM provider selection interface
- ✅ Session-based API key management
- ⏳ Full LLM API integration (placeholder implemented)
- ⏳ Shinylive deployment configuration

### Next Steps
1. **Complete LLM Integration**: Implement actual API calls to OpenAI/Anthropic
2. **Advanced Prompt Engineering**: Create research-based prompts for educational effectiveness
3. **Shinylive Deployment**: Configure for GitHub Pages hosting
4. **User Testing**: Validate educational effectiveness with WDDA students
5. **Exercise Expansion**: Add more advanced statistical analysis exercises

### Customization Guidelines
The app follows the BFH template system and can be extended by:
- Adding new exercises to the BUILTIN_EXERCISES list
- Enhancing rule-based patterns in check_rules() function
- Implementing additional LLM providers in LLM_PROVIDERS
- Extending translations for new terms
- Adding category-specific feedback logic

## Educational Impact

This application addresses the core challenge identified in the BFH E-Learning grant proposal: eliminating long wait times for individual feedback while maintaining educational quality. By providing immediate, contextual feedback, students can:

- Learn iteratively through immediate error correction
- Understand R best practices through positive reinforcement
- Build confidence through scaffolded learning progression
- Access help outside of class hours for self-paced learning

The app supports instructors by automating routine code review tasks, allowing them to focus on higher-level conceptual discussions and case studies during class time.