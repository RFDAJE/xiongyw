1. Take a look of "sample.asy" and "sample_old.asy" to get a feeling how to use the "node.asy" module;
   
   Briefly, to draw dir tree: prepare the nodes, and call draw_dir_tree(root);
            to draw call seq: prepare the nodes, and call draw_call_sequence(root);

2. To prepare dir tree data automatically, take a look of "./dirtree/readme.txt";

3. It's assumed that asymptote and TexLive 2011 is installed on your system. if not yet, do the following:

Install:
 
-          Suppose TexLive 2010 or 2011 is already installed.
-          Download Asymptote Windows binary ¡°asymptote-2.13-setup.exe¡± from http://asymptote.sf.net, and install it;
-          Download ghostscript windows bnary ¡°gs902w32.exe¡± from http://ghostscript.com, and install it
 
 
Config:
 
-          Add ¡°config.asy¡± under asymptote root ¡°c:\program files\asymptote\config.asy¡±, with the following content:
 
import settings;
 
gs="c:\Program Files\gs\gs9.02\bin\gswin32.exe";
psviewer="c:\texlive\2011\bin\win32\psv.exe";
pdfviewer="c:\Program Files\FoxitReader\FoxitReader.exe";
 
 
-          Command line for generating the pdf:
 
D:\>asy -noV -f pdf asytest
cygwin warning:
  MS-DOS style path detected: C:/Documents and Settings/ywxiong\.asy
  Preferred POSIX equivalent is: /cygdrive/c/Documents and Settings/ywxiong/.asy
 
  CYGWIN environment variable option "nodosfilewarning" turns off this warning.
  Consult the user's guide for more details about POSIX paths:
    http://cygwin.com/cygwin-ug-net/using.html#using-pathnames
 
D:\>


