Usage:

- 'make' to get an executable 'dirtree'
- run 'dirtree' to get a output, or redirect to a file, say 'my.asy'

Then use asy to produce the pdf:

asy -noV -f pdf my.asy

Note: 

- the asy generated depends on "node.asy", make sure it exists at the proper path;
- it's assumed that asymptote and texlive are installed correctly.


