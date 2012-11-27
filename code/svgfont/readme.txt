created(bruin, 2012-11-27)
--------------------------

1. The purpose is to extrace the character set of gb2312-80 
   from unicode-encoded ttf font (which is usually available
   from Windows). The result TTF font is also unicode-encoded, 
   the gain is purely the size: the original TTF font normally 
   contains more than 20K code points, and gb2312-80 is less  
   than 8K code points. 

   Original TTF font: SimHei.ttf
   Result TTF font: GB2312SimHei.ttf

2. The procedure is as the following:

   - Use FontForge to convert "SimHei.ttf" into "SimHei.svg"
   - Check the header of "SimHei.svg" to change/update the copyright claims if applicable.
   - Compile "glyph.c" and execute it with "SimHei.svg" as its input file, and
     redirect the output into "GB2312SimHei.svg"
   - Open "GB2312SimHei.svg" in FontForge and generate the TTF font: GB2312SimHei.ttf
