/* 
 * note that the source file must be utf8-encoded.
 * emacs: 
 *   c-x RET f utf-8
 *   c-x c-s
 * vim: 
 *   :setlocal nobomb
 *   :set encoding=utf-8
 *   :set fileencoding=utf-8
 *   :w
 */

settings.tex = "xelatex";
 
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{arialuni.ttf}");
//texpreamble("\setCJKmainfont{SimHei}");
 
 
draw((0,0)--(1cm,1cm));
label("中☰文", (1cm,1cm));
label("☰中文", (1.5cm,1.5cm));
label("1中2☰3文4", (2cm,2cm));
