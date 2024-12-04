DOCTYPE = LDM
DOCNUMBER = 692
DOCNAME = $(DOCTYPE)-$(DOCNUMBER)
JOBNAME = $(DOCNAME)
TEX = $(filter-out $(wildcard *acronyms.tex aglos*tex) , $(wildcard *.tex))
 
export TEXMFHOME ?= lsst-texmf/texmf

# Version information extracted from git.
GITVERSION := $(shell git log -1 --date=short --pretty=%h)
GITDATE := $(shell git log -1 --date=short --pretty=%ad)
GITSTATUS := $(shell git status --porcelain)
ifneq "$(GITSTATUS)" ""
	GITDIRTY = -dirty
endif
#Traditional acronyms are better in this document
#$(DOCNAME).pdf: $(DOCNAME).tex meta.tex aglossary.tex
$(DOCNAME).pdf: $(DOCNAME).tex meta.tex acronyms.tex
	latexmk -bibtex -xelatex -f $(DOCNAME).tex
	#makeglossaries $(DOCNAME)
	#xelatex $(DOCNAME).tex
.FORCE:

meta.tex: Makefile .FORCE
	rm -f $@
	touch $@
	echo '% GENERATED FILE -- edit this in the Makefile' >>$@
	/bin/echo '\newcommand{\lsstDocType}{$(DOCTYPE)}' >>$@
	/bin/echo '\newcommand{\lsstDocNum}{$(DOCNUMBER)}' >>$@
	/bin/echo '\newcommand{\vcsrevision}{$(GITVERSION)$(GITDIRTY)}' >>$@
	/bin/echo '\newcommand{\vcsdate}{$(GITDATE)}' >>$@

#Traditional acronyms are better in this document
acronyms.tex : ${TEX} myacronyms.txt skipacronyms.txt
	echo ${TEXMFHOME}
	python3 ${TEXMFHOME}/../bin/generateAcronyms.py -t "DM"    $(TEX)

#aglossary.tex : ${TEX} myacronyms.txt skipacronyms.txt
#	echo ${TEXMFHOME}
#	python3 ${TEXMFHOME}/../bin/generateAcronyms.py -t "DM" -g   $(TEX)

myacronyms.txt :
	touch myacronyms.txt

skipacronyms.txt :
	touch skipacronyms.txt

clean :
	latexmk -c
	rm *.pdf
	rm -rf $(VENVDIR)
	rm -f coverage.json tcresults.json vcd.json


# need docteady installed pip install docsteady and 
# JIRA_USER, JIRA_PASSWORD and ZEPHYR_TOKEN set in env or type in on prompt
docugen :
	docsteady generate-vcd --dump=True jira_docugen.tex
