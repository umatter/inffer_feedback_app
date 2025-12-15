# INFFER Project: Presentation Slides

Beamer presentation for introducing the AI-Powered R Code Feedback App to faculty.

## Compilation

Requires the **Metropolis** Beamer theme. Compile with XeLaTeX:

```bash
xelatex presentation.tex
```

## Installing Metropolis Theme

**Ubuntu/Debian:**
```bash
sudo apt install texlive-fonts-extra
```

**macOS (MacTeX):**
```bash
sudo tlmgr install mtheme
```

**Manual installation:**
```bash
git clone https://github.com/matze/mtheme.git
cd mtheme && make install
```

## Slide Overview (10 slides)

1. **Title** - INFFER Project, author, acknowledgments & AI disclaimer
2. **The Challenge** - Motivation for AI-assisted R coding feedback
3. **Conceptual Background** - Why LLMs for education
4. **Architecture Diagram** - Serverless, privacy-first design (large visual)
5. **Architecture Principles** - Key design decisions (BYOK, OpenRouter)
6. **Three-Layer Feedback** - Syntax → Rules → AI
7. **Features & Use Cases** - What it does, when to use
8. **Enjoy the Show** - App screenshot demo
9. **Summary** - What we built, technology stack
10. **Try it out** - QR code, links, and questions

## Required Files

- `app-screenshot.png` - Screenshot of the app for slide 8
- `qr-app.png` - QR code linking to deployed app

## Customization

- BFH colors are defined at the top (`bfhblue`, `bfhorange`)
- Update URLs in the final slide as needed
- Aspect ratio is 16:9 (`aspectratio=169`)
