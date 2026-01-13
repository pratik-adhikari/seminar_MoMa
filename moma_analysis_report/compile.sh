#!/bin/bash
set -ex

# Shared build infrastructure
LATEX_COMMON="../latex-common"
IMAGENAME="research/tex-builder"
TAG="latest"

if [[ "$(docker images -q $IMAGENAME:$TAG 2> /dev/null)" == "" ]];
then
    echo "Building the docker image from shared infrastructure..."
    docker build -t $IMAGENAME:$TAG -f $LATEX_COMMON/Dockerfile $LATEX_COMMON
fi

echo "Compiling the latex document..."
docker run --rm \
    -v $(pwd):/document/:z \
    -v $(realpath $LATEX_COMMON):/latex-common/:z \
    $IMAGENAME:$TAG \
    /bin/sh -c 'cp /latex-common/*.cls /document/ && latexmk -pdf -interaction=nonstopmode && latexmk -c && rm -f /document/*.cls'

echo ""
# Attempt to open the generated PDF.
xdg-open dist/main.pdf 2>/dev/null || echo "Please open dist/main.pdf manually to view the document"
