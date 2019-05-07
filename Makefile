# all: docs tags

tags:
	vim -u NONE -c "helptags doc/ | qa!"

docs:
	vim -c "call genhelp#GenHelp('plugin/accessibility.vim') | qa!"
