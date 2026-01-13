# Research Projects

This repository contains research work including seminar papers, shared LaTeX build infrastructure, and templates.

## Structure

research/
├── latex-common/           # Shared Docker build infrastructure
│   ├── Dockerfile
│   ├── .latexmkrc
│   └── syssec-*.cls       # LaTeX class files
│
├── moma_seminar_1/        # [NEW] Active MoMa Seminar Project
│   ├── main.tex
│   ├── chapters/
│   ├── components/
│   ├── bibliography/
│   └── compile.sh         # Build script
│
├── momaLLM_minorchars_fixed_project/ # [NEW] MoMa LLM Project
│   ├── main.tex
│   ├── compile.sh         # Build script
│   └── ...
│
└── templates/             # LaTeX templates
    └── syssec-thesis-template/


## Projects

### MoMa Seminar
**Topic**: Language-Grounded Scene Understanding for Mobile Manipulation

A systematic review on integrating large language models (LLMs) and vision-language models (VLMs) with scene understanding techniques for robotic systems.

See [moma_seminar/README.md](moma_seminar/README.md) for details.

## Shared Infrastructure

The `latex-common/` directory contains shared Docker build infrastructure used by all LaTeX projects:
- **Dockerfile**: Full TeXLive environment
- **Class files**: syssec-common, syssec-report, syssec-thesis
- **Configuration**: latexmkrc for consistent builds

This allows multiple projects to share the same build environment without duplication.

## Quick Start

For any LaTeX project in this repository:

```bash
cd moma_seminar  # or any other project
./compile.sh     # Builds Docker image and compiles PDF
```

The compiled PDF will be in the `dist/` directory of each project.

## Repository

GitHub: https://github.com/pratik-adhikari/seminar_MoMa
