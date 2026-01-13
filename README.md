# Research Projects
# Research Projects
This repository contains research work including seminar papers, shared LaTeX build infrastructure, and templates.

## 📄 Download Latest PDFs

| Document | Description | Link |
|----------|-------------|------|
| **MoMa Seminar** | Primary Seminar Paper | [📥 Download PDF](pdfs/MoMa_Seminar.pdf) |
| **Critical Analysis** | Critical Analysis Report on MoMa-LLM | [📥 Download PDF](pdfs/MoMa_Analysis_Report.pdf) |

## Directory Structure

- **`moma_seminar/`**: The primary seminar paper.
- **`moma_analysis_report/`**: Critical Analysis Report on MoMa-LLM.
- **`latex-common/`**: Shared Docker infrastructure (`Dockerfile` with `texlive-full`).
- **`templates/`**: LaTeX templates.

## Building Projects

We use a shared Docker container to build all LaTeX projects.

### Prerequisites

*   Docker installed.

### How to Build

Navigate to the project directory and run `compile.sh`:

**For MoMa Seminar:**
```bash
cd moma_seminar
./compile.sh
```

**For Critical Analysis Report:**
```bash
cd moma_analysis_report
./compile.sh
```
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
