PANDOC = pandoc
ENGINE = lualatex

NAME = ruby-libssw

SOURCE = $(NAME).md
BIBTEX = $(NAME).bib
TARGET = $(NAME).pdf

$(TARGET): $(BIBTEX)
	$(PANDOC) -o $(TARGET) -C --pdf-engine=$(ENGINE) -V linkcolor=blue $(SOURCE)

all:
	clean $(TARGET)

clean:
	rm -f $(TARGET)