- website: http://www.diybookscanner.org/

- process overview
      mobile       ScanTailor       tiff2pdf      pdfsandwich           texlive     pdftk
book -------> jpgs ---------> tiffs -------> pdfs ----------> ocred pdfs------->pdf------->pdf w/ toc

- book2jpgs: using mobile to take photos, odd pages first then even pages, empty pages included (for easy matching odd/even pages). the picture file name is of the format IMG_YYYYMMDD_HHMMSS.jpg, so take the photos in order. 
note that as the page 2 mobile distance changes during the process, need to make sure the mobile camera always focuses on the pages.

- jpgs2tiffs: using Scan Tailor

- renaming files in page order: use the script "order.sh", customize the "pages" variable first.

- remove blank pages, if applicable. sort file names by "ls *.tif|sort -k1.1n"

- change pictures into bw: tiff2bw input.tif output.tif

- tif2pdf (sudo apt-get install libtiff-tools): use the script "tiff2pdf.sh": 

for f in *.tif; do
  tiff2pdf -o ${f%tif}pdf $f
done

for bw pictures, add "-j -q 50" to reduce the size of the pdf

- OCR: pdfsandwich with parallel (excluding pages with color/grey pictures):
  parallel -j 2 pdfsandwich -lang eng+chi_sim -resolution 600 -o {.}.pdf {} ::: *.pdf

- cat PDFs into a book: using pdfpages.tex


