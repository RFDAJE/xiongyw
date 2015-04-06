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
pair[] height={
               (0,.5), // to be confirmed
               (4,.98),
               (11,1.335),
	       (13,1.466),
	       (13.75,1.50),
	       (14, 1.517)
	      };

pen dp=linewidth(0.02);
draw((0,0)--(20, 0), dp);
draw((0,0)--(0,1.7),dp);

int i;
path p = nullpath;
for (i = 0; i < size(height); ++ i) {
 p = p--height[i];
}
write(p);
draw(p, dp+red);
dot(height, linewidth(.1));

