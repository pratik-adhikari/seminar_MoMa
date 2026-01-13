# MoMa Seminar - Language-Grounded Scene Understanding

## Structure

This seminar paper follows a modular LaTeX structure:

```
moma_seminar/
├── main.tex                 # Main LaTeX document
├── compile.sh              # Compilation script (uses ../latex-common)
├── chapters/               # Chapter files
│   ├── chapter01.tex       # Introduction
│   ├── chapter02.tex       # Related Work
│   ├── chapter03.tex       # Paper Summary
│   ├── chapter04.tex       # Discussion
│   └── chapter05.tex       # Conclusion
├── components/             # Document components
│   ├── abstract.tex        # Abstract
│   └── appendix.tex        # Appendix
├── acronyms/              # Acronym definitions
│   └── acronyms.tex
├── bibliography/          # Bibliography files
│   └── bibliography.bib
└── figures/               # Figures and images
```

## Compilation

### Using Docker (Recommended)

This project uses shared Docker infrastructure from `../latex-common/`:

```bash
./compile.sh
```

This will:
1. Build the Docker image from shared infrastructure (if not already built)
2. Compile the LaTeX document using latexmk
3. Clean up auxiliary files
4. Open the resulting PDF

The compiled PDF will be in `dist/main.pdf`.

### Manual Compilation

If you prefer to compile manually with a local LaTeX distribution:

```bash
latexmk
```

## Dependencies

- Docker (for containerized compilation)
- OR a local LaTeX distribution with:
  - pdflatex
  - biber
  - latexmk
  - Required packages (see main.tex for full list)

## Repository

GitHub: https://github.com/pratik-adhikari/seminar_MoMa

## Build

### Local (recommended)

```bash
make all
```

This runs: `pdflatex -> biber -> pdflatex -> pdflatex`.

If `biber` is missing, install it (TeX Live):

```bash
sudo apt-get install biber
```

### Manual

```bash
pdflatex main.tex
biber main
pdflatex main.tex
pdflatex main.tex
```
