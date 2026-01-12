# Prompt for a NEW Chat: Fix LaTeX formatting + structure (MoMa-LLM report)

You are given a LaTeX project as a ZIP. Your job is to:
1) Make the PDF compile cleanly on a fresh machine.
2) Produce a single-column, readable report (NO overlapping text, NO margin overflow, NO weird spacing).
3) Follow the structure specified by the provided format template PDF in `references/Project_Group_Seminar_Lab_WT_ST__Year__Title (2).pdf`.
4) Keep total length <= 50 pages.
5) Use **biblatex numeric** citations [1], [2], ... and ensure every technical claim is cited.
6) Every citation must include a verification hint in **yellow highlight**:
   - page + section + paragraph identifier (or “paragraph starting with …”)
   - and for direct quotes, include a short exact quote (<= 25 words) in yellow highlight.

## Inputs you must use
- Main target paper: `references/Honerkamp2024 - Language Grounded Dynamic Scene Graphs for Interactive Object Search with Mobile Manipulation.pdf`
- Additional related papers in `references/` (SayCan, VoxPoser, HIMOS, SayNav, VoroNav, OrionNav, Stretch-Compose, MORE).
- Formatting blueprint: `references/Project_Group_Seminar_Lab_WT_ST__Year__Title (2).pdf`

## Deliverables
- `main.pdf` (<= 50 pages) that matches the blueprint formatting and is readable (no overlaps).
- A cleaned ZIP with sources + references included.

## What is currently wrong (typical causes of overlap)
- Wrong paper size/margins or conflicting geometry settings.
- Two-column remnants (multicol / twocolumn / IEEEtran-like settings).
- Manual negative vspace or bad list spacing.
- Images wider than \textwidth causing overfull hboxes.
- Header/footer size not accounted for.
- Tables in fixed-width columns overflowing.

## Concrete formatting requirements (implement these)
### Document class + page layout
- Use `\documentclass[11pt,a4paper]{article}` (single column).
- Use `geometry` explicitly: `margin=25mm` (or match the blueprint).
- Use `microtype` to reduce overfull boxes.
- Set:
  - `\setlength{\parskip}{0.4em}`
  - `\setlength{\parindent}{0pt}`
- Use `\usepackage{setspace}` and `\onehalfspacing` (unless blueprint says otherwise).

### Figures & tables safety rules
- Force all included graphics to be <= \linewidth:
  - Use `\includegraphics[width=\linewidth]{...}`
- For tables:
  - Prefer `tabularx` or `longtable` and wrap text.
- Add:
  - `\emergencystretch=2em`
  - `\hfuzz=1pt` (optional)
  to avoid catastrophic line-breaking.

### Robust compilation
- Use `biblatex` + `biber`.
- Add `latexmk` or Makefile rule:
  - pdflatex → biber → pdflatex → pdflatex.
- Remove any dependency on missing custom `.cls` files.

## Citation highlighting requirement (IMPORTANT)
Create a macro like:
```
\usepackage{xcolor}
\usepackage{soul}
\sethlcolor{yellow}
\newcommand{\citev}[3]{\cite{#1}\hl{[p.#2, #3]}}
\newcommand{\quotv}[4]{\hl{“#4” [p.#2, #3]}\cite{#1}}
```
Then use:
- `\citev{key}{12}{Sec. III-A, para 2 (starts “We introduce…”)}` for normal claims.
- `\quotv{key}{12}{Sec. III-A, para 2}{exact short quote...}` for quotes.

Every time you state:
- a contribution,
- a limitation,
- a metric,
- a pipeline step,
- a comparison,
you MUST attach one of these.

## Structure to enforce (match the blueprint)
- Title page / metadata (group, lab, year, etc.)
- Abstract
- 1 Introduction (motivation + problem)
- 2 Background / Related Work (grouped, not a dump)
- 3 Paper Summary (MoMa-LLM): pipeline, representation, planning loop, experiments
- 4 Contributions (bullet list) + why needed vs prior work (with citations)
- 5 Limitations (each limitation tied to evidence/citations)
- 6 Post-work: papers after / parallel work and how they extend MoMa-LLM
- 7 Conclusion
- Appendix A: glossary / acronyms (optional)
- Appendix B: math appendix (self-contained derivations + toy examples)

## Math appendix requirements
Explain the core mechanisms mathematically as if teaching a beginner:
- Define symbols before using them.
- Provide 1–2 toy numerical examples per subsection.
- Include step-by-step derivations (not just final equations).
Typical blocks to include (adapt to MoMa-LLM):
- scene graph formalization (nodes/edges/attributes)
- belief / scoring / ranking of candidate locations
- frontier exploration objective (even if heuristic)
- evaluation metrics (success rate, SPL if applicable, AUC-E if used)
But DO NOT invent equations not supported by the paper; if you add supporting math, label it “Didactic derivation” and cite where the concept comes from.

## Acceptance tests (you must run)
- `make all` produces `main.pdf` with no LaTeX fatal errors.
- `main.pdf` has:
  - no overlapping lines,
  - no content outside margins,
  - no missing references,
  - no “??” citations,
  - <= 50 pages.

Now: open the project, fix the preamble/geometry/spacing, refactor sections to follow the blueprint PDF, ensure citations are consistent and highlighted, then produce the final PDF and updated ZIP.
