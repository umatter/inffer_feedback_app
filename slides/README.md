# Presentation Slides

Beamer presentation for introducing the R Code Feedback App to faculty.

## Compilation

Requires the **Metropolis** Beamer theme. Compile with XeLaTeX:

```bash
# Single compilation
xelatex presentation.tex

# Or use latexmk for full compilation
latexmk -xelatex presentation.tex
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

## Slide Overview

1. **The Challenge** - Motivation for AI-assisted feedback
2. **Conceptual Background** - Why LLMs for education
3. **Architecture Diagram** - Serverless, privacy-first design (large visual)
4. **Architecture Principles** - Key design decisions
5. **Three-Layer Feedback** - Syntax → Rules → AI
6. **Features & Use Cases** - What it does, when to use
7. **Enjoy the Show** - App screenshot demo
8. **Summary** - What we built, technology stack
9. **Try it out** - Links and questions

## Customization

- BFH colors are defined at the top (`bfhblue`, `bfhorange`)
- Update URLs in the final slide as needed
- Aspect ratio is 16:9 (`aspectratio=169`)
