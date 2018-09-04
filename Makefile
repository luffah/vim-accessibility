# all: docs tags

tags:
	vim -u NONE -c "helptags doc/ | qa!"

docs:
	vimdoc.sh

