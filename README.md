# R Code Feedback App - WDDA Course

An AI-powered Shiny application that provides automated feedback on R code submissions for the BFH Working with Data and Data Analysis (WDDA) course.

**Live Demo:** https://umatter.github.io/inffer_feedback_app

## Features

- **AI-Powered Feedback**: LLM-based code analysis via OpenRouter, OpenAI, or Anthropic APIs
- **Multi-Model Support**: Choose from various models (Qwen Coder, DeepSeek, GPT-4o, Claude, etc.)
- **Syntax Validation**: Immediate R syntax checking before AI analysis
- **Code Execution**: Run R code directly in the browser with console and plot output
- **Plot Feedback**: AI compares student plots to reference solutions (vision-capable models)
- **Feedback Export**: Download feedback as Markdown or print as PDF
- **Diff View**: Side-by-side comparison of student code vs AI suggestions
- **Custom Exercises**: Upload JSON exercises with reference solutions
- **Multi-Language UI**: German, French, and English interface
- **Screenshot Paste**: Paste images directly for context (Ctrl+V)
- **Privacy-First**: No user accounts, session-only data, runs entirely in browser
- **BFH Design**: Corporate design compliance with accessibility features

Note: The app includes demo exercises for testing. For course use, instructors can upload custom exercises via JSON.

## Live Deployment

The app runs entirely client-side via webR/Shinylive - no backend server required. Deployment is automatic via GitHub Actions on push to `main`.

**Deployed at:** `https://[username].github.io/[repository-name]/`

### GitHub Pages Setup

1. Go to repository Settings → Pages → Source: "GitHub Actions"
2. Push to `main` branch - the workflow handles the rest

## Local Development

```bash
# Install required R packages
Rscript -e "install.packages(c('shiny', 'bslib', 'shinyjs', 'jsonlite', 'markdown'))"

# Run the app
Rscript -e "shiny::runApp('app', port=3838)"
```

### Test Shinylive Export Locally

```r
# Install shinylive
install.packages("shinylive")

# Export and serve
shinylive::export("app", "_site")
httpuv::runStaticServer("_site")
```

## Usage

1. **Setup**: Select LLM provider and enter API key in Settings
2. **Select Exercise**: Choose a demo exercise or upload a custom one
3. **Enter Code**: Write or paste your R code solution
4. **Get Feedback**: Receive syntax validation and AI-powered feedback

## API Keys

- **OpenRouter** (recommended): Get from [openrouter.ai/keys](https://openrouter.ai/keys) - access to multiple models
- **OpenAI**: Get from [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
- **Anthropic**: Get from [console.anthropic.com](https://console.anthropic.com)

API keys are stored in session memory only and never persisted.

## Privacy

- No user registration or login required
- All code runs in browser via WebAssembly
- Code only sent to LLM APIs when requesting AI feedback
- No server-side storage of student submissions
- GDPR compliant by design

## License

This project uses dual licensing to support its role as an Open Educational Resource (OER):

- **Code** (R scripts, configuration files): [MIT License](LICENSE)
- **Educational Content** (documentation, courseware): [CC BY-SA 4.0](LICENSE-CONTENT)

## Acknowledgments

This project is part of the **INFFER Project** (Interactive Inference), supported by the BFH E-Learning funding program ([virtuelle-akademie.ch](https://virtuelle-akademie.ch)).

**AI tools used:** Claude Code (Sonnet 4.5, Opus 4.5) for app framework, testing, deployment, bug fixing, CSS styling, Beamer setup.
