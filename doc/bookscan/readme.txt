- website: http://www.diybookscanner.org/

- process overview
      mobile       ScanTailor       tiff2pdf      pdfsandwich           texlive     pdftk
book -------> jpgs ---------> tiffs -------> pdfs ----------> ocred pdfs------->pdf------->pdf w/ toc

- book2jpgs: using mobile to take photos, odd pages first then even pages, empty pages included (for easy matching odd/even pages). the picture file name is of the format IMG_YYYYMMDD_HHMMSS.jpg, so take the photos in order. 
note that as the page 2 mobile distance changes during the process, need to make sure the mobile camera always focuses on the pages.

- jpgs2tiffs: using Scan Tailor

- renaming files in page order: use the script "order.sh", customize the "pages" variable first.

- remove blank pages, if applicable

- tif2pdf: use the script "tiff2pdf.sh"

- OCR: pdfsandwich with parallel:
  parallel -j 2 pdfsandwich -lang eng+chi_sim -resolution 600 -o {.}.pdf {} ::: *.pdf
