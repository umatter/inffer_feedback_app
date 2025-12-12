.PHONY: all clean

MAIN = presentation

all: $(MAIN).pdf

$(MAIN).pdf: $(MAIN).tex
	xelatex $(MAIN).tex
	xelatex $(MAIN).tex

clean:
	rm -f *.aux *.log *.nav *.out *.snm *.toc *.vrb *.fls *.fdb_latexmk *.synctex.gz

distclean: clean
	rm -f $(MAIN).pdf
