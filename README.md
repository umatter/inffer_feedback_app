# R Code Feedback App - WDDA Course

An AI-powered Shiny application that provides automated feedback on R code submissions for the BFH Working with Data and Data Analysis (WDDA) course.

## Features

- 🤖 **AI-Powered Feedback**: Integration with OpenAI and Anthropic LLM providers
- 📚 **Exercise Library**: Built-in exercises covering WDDA course topics
- 📝 **Custom Exercises**: Upload your own exercises with reference solutions
- 🎓 **Pedagogical Framework**: Research-based feedback using Hattie & Timperley model
- 🔒 **Privacy-First**: No user accounts, session-only data storage
- 🎨 **BFH Design**: Corporate design compliance with accessibility features

## Deployment

### GitHub Pages (Automatic)

1. **Enable GitHub Pages**: Go to repository Settings → Pages → Source: "GitHub Actions"

2. **Push to main branch**: The GitHub Actions workflow will automatically:
   - Install R and required packages
   - Convert the Shiny app to Shinylive format
   - Deploy to GitHub Pages

3. **Access the app**: Available at `https://[username].github.io/[repository-name]/`

### Local Development

```bash
# Install required R packages
Rscript -e "install.packages(c('shiny', 'shinydashboard', 'shinyjs', 'DT', 'jsonlite', 'httr2'))"

# Run the app
Rscript -e "shiny::runApp('app.R', port=3838)"
```

### Manual Shinylive Export

```r
# Install shinylive
install.packages("shinylive")

# Export to static files
shinylive::export(
  appdir = ".",
  destdir = "docs"
)
```

## Usage

1. **Setup**: Select LLM provider and enter API key
2. **Submit Code**: Choose exercise and enter R code
3. **Get Feedback**: Receive multi-layer analysis and suggestions
4. **Custom Exercises**: Upload your own exercises for personalized feedback

## API Keys

- **OpenAI**: Get from [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
- **Anthropic**: Get from [console.anthropic.com](https://console.anthropic.com)

API keys are stored in memory only and never saved.

## Privacy

- No user registration or login required
- Session-based progress tracking only
- Code only sent to LLM APIs for analysis
- GDPR compliant by design

## License

MIT License - see LICENSE file for details.

---

*Developed for BFH - Berner Fachhochschule*
