import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



/* 7 processor mode of ARM */

node modes = node("modes", "");
node privileged = node("privileged", "");
node usr = node("usr", "m");
node sys = node("sys", "m");
node exception = node("exception", "");
node svc = node("svc", "m");
node abt = node("abt", "m");
node und = node("und", "m");
node irq = node("irq", "m");
node fiq = node("fiq", "m");


modes.attach(usr, privileged);

privileged.attach(sys, exception);

exception.attach(svc, fiq, irq, abt, und);

picture my_draw_node_func(node p)
{
    picture pic;
	
    draw(pic, 
         "\texttt{"+p.text+"}", 
         box,
         (0, 0), 
         2,       /* margin between text to the bounding box */
         p.priv == "m"? black : invisible,        /* color of the bounding box */
         NoFill);      /* fill patterns. 
                             NoFill:          only draw the bounding box;
                             Fill(color):     only fill, no bounding box. use Fill(white) for no-fill & no-box;
                             FillDraw(color): both fill & box;
                       */
                       
    p.offset = pic_size(pic).y / 2;
                             
    return pic;
}



/* output the diagrams */
picture pic_modes = draw_tree(modes, my_draw_node_func, style=TREE_STYLE_CASE, gene_gap=5);

//attach(pic_modes.fit(), (0,0), SE);
							   
attach(bbox(pic_modes, 2, 2, white), (0,0), SE);
