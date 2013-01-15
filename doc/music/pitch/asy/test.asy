/* created(bruin, 2007-03-09): draw cases with braces "{".
   $Id: test.asy 2 2007-03-22 12:54:39Z Administrator $
 */

import fontsize;

texpreamble("\usepackage{amssymb,amsmath,mathrsfs}
             \usepackage{CJK}
             %\newcommand{\myfrac}[2]{\,$\mathrm{{^{#1}}\!\!\diagup\!\!{_{#2}}}$\,}
             %\newcommand{\myfrac}[2]{#1\!/\!#2}
             %\newcommand{\cwave}{～}
             \newcommand{\cdash}{－\!\!\!－\!\!\!－}  % 中文破折号
             \newcommand{\song}{\CJKfamily{song}}
             \newcommand{\fs}{\CJKfamily{fs}}
             \newcommand{\hei}{\CJKfamily{hei}}
             \newcommand{\kai}{\CJKfamily{kai}}
             \AtBeginDocument{\begin{CJK*}{GBK}{song}}
             \AtEndDocument{\clearpage\end{CJK*}}"
            );

/* ------------------------------------------------ */
/* data struct and function to build tree in memory */
/* ------------------------------------------------ */

struct node{
	string   text;
	node     kids[];

	static node node(string text){  /* default constructor */
		node _n = new node;
		_n.text = text;
		return _n;
	}

	void contains(node _kids[]){ /* adding kids */
		this.kids.append(_kids);
	}
};

/* build node tree in recursive fashion, e.g.,
		node complex=node("复数", node("有理数",  node("整数")
		                                          node("分数")),
		                          node("无理数"));
or,
		node complex=node("复数", node("有理数"),
		                          node("无理数"));
		complex.kids[0].contains(new node[]{node("aaa"), node("bbb")});  
*/
node node(string text ... node[] _kids){
	node root = node.node(text);
	root.contains(_kids);
	return root;
}

/* ------------------------------------------------ */
/* parameters & functions to draw tree in pictures  */
/* ------------------------------------------------ */

/* we use PostScript unit (bp) in both picture and frame */
size(0, 0);
unitsize(0, 0);

string default_delim_symb  ="\{";  /* delim symbol "{" */
real   default_font_size   = 12;   /* font size */
real   default_line_sep    = 5;    /* vertical space between two consective items */
real   default_delim_width = 10;    /* width occupied by the brace, e.g. "{". */
/* 0.5 means the brace starts/stops at the middle (vertically) of 
	the node name text, i.e., cover half line;
	1 means the brace covers the whole line; 
	0 means the brace does not cover the line 
*/
real   default_coverage    = 0.8;  
pair   se=0.000000001SE;       /* used for alignment */

defaultpen(fontsize(default_font_size));


struct mypicture{
	picture pic;
	
	/* ratio of the height (from top to "middle point") to the total_height of the picture;
	   the "middle point" for a tree (usually sub-tree) is the middle point (vertically)
	   of the text line (i.e., text of the root node). 
	   this point is referenced for drawing the higer level (left side) brace if we attach 
	   this tree to a parent node.	 */
	real    middle_frac; 
	
	/* default constructor */
	static mypicture mypicture(){
		mypicture _p = new mypicture;
		return _p;
	}
}

pair pic_size(picture pic){
	pair min, max;
	//min = min(bbox(pic));
	//max = max(bbox(pic));
	min = min(pic);
	max = max(pic);
	pair size=(max.x - min.x, max.y - min.y);
	return size;
}

mypicture draw_node(node p, real font_size=default_font_size){
	mypicture mypic = mypicture.mypicture();
  //write("draw_node" + p.text);
  defaultpen(fontsize(font_size));
	label(mypic.pic, p.text, (0, 0), NoFill);
	mypic.middle_frac = 0.5;	
	return mypic;
}

mypicture draw_tree(node root, 
                    real font_size=default_font_size,
                    real line_sep=default_line_sep,
                    string delim_symb=default_delim_symb,
                    real delim_width=default_delim_width,
                    real coverage=default_coverage){

	mypicture pic = mypicture.mypicture();   /* pic to return */
	
	mypicture self = mypicture.mypicture();     /* node name */
	mypicture brace = mypicture.mypicture();    /* brace */
	mypicture kids = mypicture.mypicture();     /* kids */
	mypicture k  = mypicture.mypicture();        /* kid  */

	node kid;
	
	real ygap = 0, kids_ht = 0, brace_ht = 0;
	real first_kid_ht_offset = 0; /* top-down direction for middle point */
	real last_kid_ht_offset = 0;  /* bottom-up direction for middle point */
	
	real   center_y_adjust = (coverage - 0.5) * font_size;

	if(root != null){
	
	  //write("draw_tree" + root.text);
	  
		self = draw_node(root, font_size);
		
		if(root.kids.length != 0){

			/* draw kids */	
			bool is_first_kid = true;
			kids_ht = 0;
			for(int i = 0; i < root.kids.length; ++ i){
				k = draw_tree(root.kids[i], font_size, line_sep, delim_symb, delim_width, coverage);
				if(is_first_kid == true){
					first_kid_ht_offset = pic_size(k.pic).y * k.middle_frac;
					is_first_kid = false;
				}
				attach(kids.pic, k.pic.fit(), (0, ygap), se);
				ygap -= pic_size(k.pic).y + line_sep;
				kids_ht += pic_size(k.pic).y;
			}
			last_kid_ht_offset = pic_size(k.pic).y * (1-k.middle_frac);
			kids_ht += (root.kids.length - 1) * line_sep;
			
			brace_ht = kids_ht - first_kid_ht_offset - last_kid_ht_offset;
			/* adjust the brace_ht in two directions (up/down) */
			brace_ht += center_y_adjust * 2; 
			
		  /* draw the brace */
			label(brace.pic, minipage("\ensuremath{\left.\vcenter{\hsize=0pt\rule{0pt}{"+format("%f", brace_ht)+"bp}}\right"+delim_symb+"}", delim_width), (0,0), NoFill);
			
			/* put 3 together: self + brace + kids: firstly the kids */
			attach(pic.pic, kids.pic.fit(), (pic_size(self.pic).x + pic_size(brace.pic).x, 0), E);
			
			/* center_y is the y coordinate of the center point of the brace. */
			real center_y = pic_size(kids.pic).y / 2 - first_kid_ht_offset  + center_y_adjust - brace_ht / 2;
			attach(pic.pic, brace.pic.fit(), (pic_size(self.pic).x, center_y), E);
			attach(pic.pic, self.pic.fit(), (0, center_y), E);

			/* cal the middle_frac */
			//pic.middle_frac = (pic_size(pic.pic).y / 2 - center_y) / pic_size(pic.pic).y;
			pic.middle_frac = 0.5 - center_y / pic_size(pic.pic).y;
		}
		else{
			/* only have the node name */
			attach(pic.pic, self.pic.fit(), (0, 0), E);
			pic.middle_frac = 0.5;
		}
	}
	
	return pic;
}

/* ------------------------------------------------ */
/* trees & pictures to be drawn                     */
/* ------------------------------------------------ */

/* 音列 */

node series = node("音列", node("某种音阶", node("音级的数目"), 
                                            node("音级间的距离")),
                           node("绝对音高"));

mypicture p =draw_tree(series);
attach(p.pic.fit(), (0, 0), se); 
shipout("series.eps");
erase(currentpicture);

/* 钢琴黑白键音列 */

real p_font_size = 9;
real p_delim_width = 8;
node p_series = node.node(minipage("钢琴上黑白键所组成的音列", p_font_size * 6 + 2));
p_series.contains(new node[]{node("十二平均律音阶", node("音级的数目：12"),
                                                    node("音级间的距离：100\,音分（平均律）")),
                             node("绝对音高：$a^1$的频率为\,440\,Hz")});

attach(draw_tree(p_series,font_size=p_font_size, delim_width=p_delim_width).pic.fit(), (0, 0), se); 
shipout("p_series.eps");
erase(currentpicture);

/* 中国古今律制分类: 冯文慈 p144 */

node temp = node.node(minipage("我国古今常见律制", default_font_size * 4 + 2));
temp.contains(new node[] {node("应用律制", node("守常律制", node("自然律制", node("五度相生律（横向结合律）"),
                                                                             node("纯律（纵向结合律）")),
                                                            node("人为平均（等比）律制－\!\!\!－\!\!\!－十二平均律")),
                                           node("无常律制－\!\!\!－\!\!\!－如潮剧律制"),
                                           node("双性律制－\!\!\!－\!\!\!－如陕、甘、粤某些民族民间乐种的律制")),
                          node("理论律制－\!\!\!－\!\!\!－如京房六十律、钱乐之三百六十律等")});                     

attach(draw_tree(temp).pic.fit(), (0, 0), se); 
shipout("temp.eps");
erase(currentpicture);
