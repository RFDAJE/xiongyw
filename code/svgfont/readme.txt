created(bruin, 2012-11-27)
--------------------------

1. The purpose is to extract the character set of gb2312-80 
   from unicode-encoded ttf font (which is usually available
   from Windows). The result TTF font is also unicode-encoded, 
   the gain is purely the size: the original TTF font normally 
   contains more than 20K code points, and gb2312-80 is less  
   than 8K code points. 

   Original fonts: simhei.ttf, simhei.svg
   Result fonts: gb2312simhei.svg, gb2312simhei.ttf

2. The procedure is as the following:

   - Use FontForge to convert "simhei.ttf" into "simhei.svg"
   - Check the header of "simHei.svg" to change/update the copyright claims if applicable.
   - Compile "glyph.c" and execute it with "simhei.svg" as its input file, and
     redirect the output into "gb2312simhei.svg"
   - Open "gb2312simhei.svg" in FontForge, click "File->Generate Fonts..." to generate the TTF font: gb2312simhei.ttf
   - Open "gb2312simhei.ttf" in FontForge to confirm it's ok. For example, click "Encoding->Force Encoding" it will 
     shows the font is using "ISO 10646-1 (Unicode, BMP)" encoding.

3. The sizes:

-rwxr--r--. 1 bruin bruin  9751960 Nov 28 09:21 simhei.ttf
-rw-rw-r--. 1 bruin bruin  2162820 Nov 28 09:18 gb2312simhei.ttf

-rw-rw-r--. 1 bruin bruin 22280343 Nov 28 08:51 simhei.svg
-rw-rw-r--. 1 bruin bruin  4816512 Nov 28 09:13 gb2312simhei.svg

[bruin@fc13 svgfont]$ grep "<glyph " simhei.svg|wc -l
28561
[bruin@fc13 svgfont]$ grep "<glyph " gb2312simhei.svg|wc -l
7612

