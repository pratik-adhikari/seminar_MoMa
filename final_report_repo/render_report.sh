#!/bin/bash
OUTPUT_PDF="report.pdf"
TEX_MAIN="hrl_report"

SRC_DIR="latex"

echo "Rendering PDF from $SRC_DIR using Docker (via tar-pipe)..."
# Stream latex directory content to docker, build latex, and stream back PDF
# We use -C to change to the source directory so the paths in the tar stream are relative to it
tar -C "$SRC_DIR" -cf - . | docker run --rm -i -w /data texlive/texlive sh -c '
    tar xf - && \
    pdflatex -interaction=nonstopmode '$TEX_MAIN' >&2 && \
    bibtex '$TEX_MAIN' >&2 && \
    pdflatex -interaction=nonstopmode '$TEX_MAIN' >&2 && \
    pdflatex -interaction=nonstopmode '$TEX_MAIN' >&2 && \
    cat '$TEX_MAIN'.pdf' > "$OUTPUT_PDF"

if [ -s "$OUTPUT_PDF" ]; then
    echo "Report generated successfully: $OUTPUT_PDF"
    ls -lh "$OUTPUT_PDF"
else
    echo "Error generating report. Check stderr for logs."
    exit 1
fi
