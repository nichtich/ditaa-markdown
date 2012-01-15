% ditaa in pandoc's markdown

*ditaa* is a java program created by Stathis Sideris to convert diagrams in
ASCII art to PNG images. It is available at <http://ditaa.sourceforge.net/>.
Mikael Brännström created an extension to convert diagrams to EPS, available at
<http://ditaa-addons.sourceforge.net/>. *Pandoc* is a Haskell program created
by John MacFarlane to convert between numerous document markup formats,
available at <http://johnmacfarlane.net/pandoc/>. It comes with several extensions
of markdown markup syntax. All these programs are licensed under GPL.

*ditaa-markdown* is a simple Perl script to preprocess and convert ditaa
diagrams embedded in pandoc's markdown syntax.

~~~~~ {.ditaa}
                                              +--------------------+
                                          /-->| processed markdown |
+-----------------+   +----------------+  |   +--------------------+
| markdown source |-->| ditaa markdown |--*
+-----------------+   +-------o--------+  |   +--------------------+
                              |           \-->| image files        |
                            ditaa             +--------------------+
~~~~~

Figure: ditaa-markdown conversion process

You can pass any of ditaa's options to ditaa-markdown after the input/output
file, for instance README.pdf from this file was created via

    ./ditaa-markdown.pl -pdf README.md -S -s '0,4' | \
	markdown2pdf -o README.pdf.

To convert all ditaa diagrams to EPS and PDF vector images and create a PDF,
run:

    ./ditaa-markdown.pl -pdf example.md | markdown2pdf -o example.pdf

To convert all diagrams to PNG bitmap images and create an HTML, run:

    ./ditaa-markdown.pl example.md | pandoc -f markdown -t html > example.html

This code repository contains a copy of ditaa and ditaa eps as compiled jar
files. Feel free to copy, fork, reuse, and modify from
<http://github.com/nichtich/ditaa-markdown>!

