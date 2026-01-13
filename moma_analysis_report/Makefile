.PHONY : all latex biber view nonstop clean distclean

TARGET=main
SOURCE=$(TARGET).tex
NONSTOP=-interaction nonstopmode -halt-on-error -file-line-error

all:
	pdflatex $(SOURCE)
	biber $(TARGET)
	pdflatex $(SOURCE)
	pdflatex $(SOURCE)

latex:
	pdflatex $(SOURCE)
	pdflatex $(SOURCE)

biber:
	biber $(TARGET)

view:
	open $(TARGET).pdf &
nonstop:
	max_print_line=1048576 pdflatex $(NONSTOP) $(SOURCE)
	biber $(TARGET)
	max_print_line=1048576 pdflatex $(NONSTOP) $(SOURCE)
	max_print_line=1048576 pdflatex $(NONSTOP) $(SOURCE)

clean:
	rm -f $(TARGET).aux $(TARGET).bbl $(TARGET).blg $(TARGET).log

distclean:clean
	rm -f $(TARGET).pdf
