default:
	sgml2html -s 0 -T 2 index.sgml 2>/dev/null
	cat logo >> index.html
all:	default text
text txt:
	sgml2rawtxt index
