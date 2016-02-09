制作步骤（2015-12-13）：

        手机            ScanTailor           TIFF2PDF             texlive
book -----------> jpgs ------------> tiffs ------------> pdfs ----------------> pdf


1. 用手机拍照。为方便计，先拍奇数面，再拍偶数面。手机拍照用声控模式。得到 240张 原始照片，文件名格式为 IMG_YYMMDD_HHMMSS.jpg 。
2. 用 ScanTailor 分两批（奇数面一批，偶数面一批）处理所有照片。一批是ScanTailor的一个Project。得到 240张 TIFF 格式图片输出：*.tif
3. 给文件重新按页码顺序命名。笨办法：先用 dir 把文件名按时间顺序排序输出到一个文件，把它成一个 javascript 的数组，再用循环 console.log() 打印调用 ren 的批处理文件即可。得到 1.tif 到 240.tif 共 240 个 tiff 文件。
4. 将 TIFF 转换成PDF。在 debian 下安装 libtiff-tools 包，再用 javascript 生成 shell 脚本调用 tiff2pdf *.tif -o *.pdf 共 240 遍得到 240个 pdf 文件。
5. 将 240 个 PDF 文件合成为一个 PDF。用 texlive 下面的 pdflatex 引擎以及 pdfpages 包：

\documentclass[a4paper]{book}
\usepackage[paper=a4paper]{geometry}
\usepackage[final]{pdfpages}
\usepackage{verbatim}
\begin{document}
% trim=left bottom right top, in bp
\includepdf[nup=1x1,pages=-,offset=0mm 0mm, trim=0 0 0 0, scale=1.,angle=0,turn=false,frame=false]{pdf/1.pdf}
。。。。。。
\includepdf[nup=1x1,pages=-,offset=0mm 0mm, trim=0 0 0 0, scale=1.,angle=0,turn=false,frame=false]{pdf/240.pdf}
\end{document} 

