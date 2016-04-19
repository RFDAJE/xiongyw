/* created(bruin, 2007-03-01): draw family lineage diagram.
   - build the family tree in memory firstly
   - draw the diagram for the tree

   - updated(bruin, 2015-06-22): xelatex and utf-8
   - updated(bruin, 2016-02-11): multiple spouses support; also add "notes" field
   - updated(bruin, 2016-03-28): fix horizontal alignment bug
   - updated(bruin, 2016-03-31): add notes support
   - updated(bruin, 2016-04-02): add split (into more than 2 parts) support
   - updated(bruin, 2016-04-19): add has() method as a combination of marry() & give_birth(), for simplification.

   Todo: 
     + in certain cases, the dash lines are not aligned (2016-03-28)
     + add notes into the diagram (2016-03-31)
     - restrict (specify) the width of the diagram
     - use elipse to indicate multiple kids as "etc"
     - indicate mother when there are step mothers

   use it by importing this script: 

   import "lineage.asy" as lineage;
 */

/* Unicode Enclosed Alphanumerics: https://en.wikipedia.org/wiki/Enclosed_Alphanumerics
 *  ①②③④⑤⑥⑦⑧⑨⑩...
 */
   
settings.tex = "xelatex";


texpreamble("\usepackage{xeCJK}");

// Unicode Enclosed Alphanumerics: https://en.wikipedia.org/wiki/Enclosed_Alphanumerics
// texpreamble("\usepackage{pifont}"); 


/*
texpreamble("\setCJKmainfont{arialuni.ttf}");
texpreamble("\setCJKfamilyfont{song}{arialuni.ttf}");
texpreamble("\setCJKfamilyfont{fs}{simfang.ttf}");
texpreamble("\setCJKfamilyfont{hei}{simhei.ttf}");
texpreamble("\setCJKfamilyfont{kai}{simkai.ttf}");
*/

//texpreamble("\setCJKmainfont[Path=./fonts/]{arialuni.ttf}");
//texpreamble("\setCJKfamilyfont{song}[Path=./fonts/]{arialuni.ttf}");
texpreamble("\setCJKmainfont[Path=../../doc/surangama/fonts/]{stsong-lyj.ttf}");
texpreamble("\setCJKfamilyfont{song}[Path=../../doc/surangama/fonts/]{stsong-lyj.ttf}");
texpreamble("\setCJKfamilyfont{fs}[Path=./fonts/]{simfang.ttf}");
texpreamble("\setCJKfamilyfont{hei}[Path=./fonts/]{simhei.ttf}");
texpreamble("\setCJKfamilyfont{kai}[Path=./fonts/]{simkai.ttf}");


texpreamble("\newcommand{\song}{\CJKfamily{song}}");
texpreamble("\newcommand{\fs}{\CJKfamily{fs}}");
texpreamble("\newcommand{\hei}{\CJKfamily{hei}}");
texpreamble("\newcommand{\kai}{\CJKfamily{kai}}");

texpreamble("\xeCJKsetcharclass{\"25A1}{\"25A1}{1}"); // white square "□"


import fontsize;

/* 
 * we use PostScript unit (bp, big point) in both picture and frame: 
 *  1 bp = 1/72 inch
 */
size(0, 0);
unitsize(0, 0);

bool g_debug = false;

real g_glyph_width = 12;                      /* 一个汉字的宽度, in bp */
real g_name_height = g_glyph_width;           /* 人名高度 */
real g_conn_v_off = g_name_height / 2;        /* 人名后引出横线在 y 方向的偏移 */
real g_name_width = g_glyph_width * 3;        /* 人名最多三个字 */
real g_x_skip = 2;                            /* 水平连接线和 self/kid 的间距 */
real g_y_skip = 6;                            /* kids 子树之间的垂直间距 */
real g_spouse_v_gap = 3;                      /* 配偶上下间距 */
real g_kid_h_gap = g_name_width;              /* 上下两辈之间的水平距离 */  
pair g_default_offset = (0, 0);

defaultpen(fontsize(g_glyph_width));

pair   se=0.0001SE;         /* used for alignment for picture attach() */

pen line_pen = linewidth(0.4) + black + linecap(0); /* square cap */
pen name_pen = linewidth(0.1) + black + fontsize(g_glyph_width);
pen name_pen_female = linewidth(0.1) + deepblue + fontsize(g_glyph_width);

pen fill_male = paleblue;
pen fill_female = pink;


/*
 * 第一部分: 构造家族数据结构
 */

/* surname/name for person whose name is unknown yet */
string unknown  = "□";      
string unknown2 = "□□";

/* for born/dead date */
string question = "?";     // happened but not known
string blank = "";         // not happen yet

/* person: a node in family tree */
struct person{

    /* 
     * 个人基本信息
     */
    bool     sex;   /* true for male */
    string   surname;
    string   given_name;
    string   born_at;
    string   dead_at;
    string   notes;  /* 备注, "" 表示没有备注 */

    string   order;       /* 在位的顺序。帝王才有! */
    string   throne;      /* 在位的年头 */
    string   hao;         /* 庙号，或谥号、年号、官位等 */

    /*
     * 直系亲属: 父母、兄弟姐妹、配偶、儿女
     */
    person   dad;    /* null if unknown */
    person   mom;    /* null if unknown */
    person   lsib;   /* left sibling; null if first kid */
    person   rsib;   /* right sibling; null if last kid */
    person[] sps;    /* one may have multiple spouses */
    person   kid;    /* first child; null if no kid */

    /* 
     * 画图时使用的辅助信息。为方便记，也放在这里 
     */
    int      level;       /* 树的层，root 为 0 层 */
    int      notes_order; /* 本备注在树上所有备注中的排序，>=0 */
    real     name_width;  /* 名字的实际长度 */
    /*
     *  root 下面的一块 hash 的区域, 是可以被 root 的 sibling tree 利用的.
     *
     *  1. 一般情况:
     *  +------------------------+
     *  | root                   |
     *  +--------+               |
     *  |////////|               |
     *  |////////|    tree       |
     *  |/space//|               |
     *  |////////|               |
     *  |////////|               |
     *  +--------+---------------+
     * 
     * 2. 如果root是叶子节点，或root的子树高度小于root本身，则 root高 == tree高, 没有可利用的面积；
     * 3. 如果考虑root的孩子，则阴影部分可以是多个长方形的拼接:
     *  +------------------------+
     *  | root                   |
     *  +--------+               |
     *  |////////|  tree 0       |
     *  |////////|               |
     *  |--------+----+          |
     *  |/////////////|  tree 1  |
     *  |/////////////|          |
     *  +--------+----+----------+
     *
     */
    pair     root_size;   /* size of the root node of the tree，包括自己和配偶 */
    pair     tree_size;   /* size of the tree where the root is self */
    /* 从上到下，每一个长方形 space 的大小. 
     * 每个长方形的宽高由(x,y)代表, x 为宽,y 为高。
     * 最后一个长方形下边和root下边界齐平，故其它长方形相对于root的纵向位置都可以推出。
     */
    pair[]   space_size;  
    
    pair     offset;      /* 相对于其父(母)的 offset, 向右、向上为正值. (0,0) means root */
    
    void info() {
        write("------------------");
        write("姓名: " + this.surname + " " + this.given_name);
        write("性别: " + (this.sex? "男" : "女"));
        write("生卒: " + this.born_at + "-" + this.dead_at);
        write("父亲: " + ((this.dad != null)? this.dad.surname + " " + this.dad.given_name : ""));
        write("母亲: " + ((this.mom != null)? this.mom.surname + " " + this.mom.given_name : ""));

        for (int i = 0; i < this.sps.length; ++ i) {
            if (this.sex) {
                write("妻子: " + this.sps[i].surname + " " + this.sps[i].given_name);
            } else {
                write("丈夫: " + this.sps[i].surname + " " + this.sps[i].given_name);
            }
        }

        write("长子: " + ((this.kid != null)? this.kid.surname + " " + this.kid.given_name : ""));
    }


    /* default constructor for person */
    static person person(bool   sex,
                         string surname,
                         string given_name,
                         string born_at,
                         string dead_at,
                         string notes = blank,
                         string order = blank,
                         string throne = blank,
                         string hao = blank){
        person p = new person;
        p.sex = sex;
        p.surname = surname;
        p.given_name = given_name;
        p.born_at = born_at;
        p.dead_at = dead_at;

        /* not draw person without surname, so its notes */
        if (surname == unknown) {
            p.notes = blank;
        } else {
            p.notes = notes;
        }

        p.order = order;
        p.throne = throne;
        p.hao = hao;
        
        p.dad = null;
        p.mom = null;
        p.sps = new person[]{};
        p.kid = null;
        p.lsib = null;
        p.rsib = null;

        p.notes_order = - 1;
        p.name_width = 0;
        p.tree_size = (-1, -1);
        p.root_size = (-1, -1);
        p.space_size = new pair[]{};
        p.offset = g_default_offset;
        
        return p;
    }


    /* A.marry(B)  is not necessarily meaning B.marry(A) because the order may differ... but if "uni" == true, then
     * it means A and B are both married once (with each other), i.e., A.marry(B) implies B.marry(A). so a single call
     * is enough; otherwise, multiple calls may needed.
     *
     * usage: if A marries both B and C in such an order, call it as:
     *   A.marry(B, C);
     */
    bool marry(bool uni = true...person[] p){
        if (uni == true) {
            this.sps[0] = p[0];
            p[0].sps[0] = this;
        } else {
            this.sps = p;
        }

        return true;
    }

    /* mom gives birth to a kid.
     * note: N kids need N calls -- probably to optimize here?
     */
    bool give_birth(person kid,            /* the kid to be born */
                    person lsib = null,    /* the left sibling (old brother or sister) of this kid; null if the 1st kid */
                    person dad = null){    /* the kid's father, null means the first (or the only) husband */
        if(this.sex != false)
            return false;

        kid.mom = this;
        //this.info();
        //kid.info();
        if (dad == null) {
               kid.dad = this.sps[0];
        }
        else {
           kid.dad = dad;
        }
        
        kid.lsib = lsib;

        if(kid.lsib != null){
            lsib.rsib = kid;
        }
        else{
            this.kid = kid;
            /* we suppose it's also the first kid of the dad */
            if(kid.dad != null)
                kid.dad.kid = kid;
        }

        return true;
    }

    /*
     * added(bruin, 2016.04.19): marry() 和 give_birth() 的简化版:
     * - 不需要提供配偶信息
     * - 孩子们由不定长参数传入，第一个为长子(女)，依次列出
     *
     * 限制: 不考虑多配偶的情况
     */
    bool has(...person[] kids) {
        person male_unknown   = person(true,  unknown, unknown2, question, blank);
        person female_unknown = person(false, unknown, unknown2, question, blank);
        person mom;

        if (this.sex == true) {
            this.marry(female_unknown);
            mom = female_unknown;
        } else {
            this.marry(male_unknown);
            mom = this;
        }
        
        for (int i = 0; i < kids.length; ++ i) {
            if (i == 0) {
                mom.give_birth(kids[i]);
            } else {
                mom.give_birth(kids[i], kids[i - 1]);
            }
        }

        return true;
    }

} from person unravel person; 

person clone(person p) {
    return person(p.sex, p.surname, p.given_name, p.born_at, p.dead_at, p.notes);
}        


/*
 * seems there is no scan() routine in asymptote...
 */
int scan_int(string s) {
    int ret = 0;
    int asc; 
    int zero = 48; // ascii value of "0" is 48

    // todo: check validity of input string
    string s2 = reverse(s);
    for (int i = 0; i < length(s2); ++ i) {
        asc = ascii(substr(s2, i, 1)) - zero;
        ret += asc * (10 ^ i);
    }

    return ret;
}


/*
 * 第二部分:绘图
 */

/*
 * return the bounding box of a path[]:
 * - [0]: low-left point
 * - [1]: up-right point
 */
pair[] bound_box(path[] pp){
     pair[] bb;
     real xmin = infinity, ymin = infinity;
     real xmax = -infinity, ymax = -infinity;

     for (path p: pp) {
         pair sw = min(p), ne = max(p);
         if(sw.x < xmin) xmin = sw.x;
         if(sw.y < ymin) ymin = sw.y;
         if(ne.x > xmax) xmax = ne.x;
         if(ne.y > ymax) ymax = ne.y;
     }

     bb.push((xmin, ymin));
     bb.push((xmax, ymax));

     return bb;
}

/* 
 * put a circle around a text and scale the whole that
 * the diameter equals to the height specified
 */
picture circle_text(string s, real height, bool black=true) {
    pair bbox[], center;
    path c;
    real width, ht, r, sk;
    picture p1;

    path[] txt = texpath(s);
    bbox = bound_box(txt);
    width = bbox[1].x - bbox[0].x;
    ht = bbox[1].y - bbox[0].y;
    center = (bbox[0].x + width / 2, bbox[0].y + ht / 2);
    if (width > ht) {
        r = width / 2;
    } else {
        r = ht / 2;
    }
    r *= 1.4;  // 避免文字和圆周太近

    sk = height / (r * 2); // scale
    
    c = circle(center, r);

    if (black) {
        draw(p1, scale(sk) * c, line_pen);
        fill(p1, scale(sk) * txt, line_pen);
    } else {
        fill(p1, scale(sk) * c, line_pen);
        fill(p1, scale(sk) * txt, white);
    }
    
    return p1;
}



/* get the picture size */
pair pic_size(picture pic){
    pair min, max;
    //min = min(bbox(pic));
    //max = max(bbox(pic));
    min = min(pic);
    max = max(pic);
    //write(min);
    //write(max);
    pair size=(max.x - min.x, max.y - min.y);
    return size;
}

/* get the frame size */
pair frame_size(frame f){
    pair max=max(f);
    pair min=min(f);
    pair size=(max.x - min.x, max.y - min.y);
    return size;
}

/* add time stamp in the lower left corner of the picture */
void add_time_stamp(picture pic=currentpicture){
    label(pic, minipage("\fs\footnotesize 本表修订于 " + time("%Y-%m-%d"), 100), (0,-pic_size(pic).y-30), se);
}

/*
 * add x/y margins to a picture
 */
picture add_margin(picture pic=currentpicture,
                   real xmargin=0.05, // in percentage
                   real ymargin=xmargin,
                   pen dp=invisible) {
    pair size = size(pic, user=true);
    pair min = min(pic, user=true);
    pair max = max(pic, user=true);
    real delta_x = size.x * xmargin;
    real delta_y = size.y * ymargin;
    draw(pic, (min.x-delta_x, min.y-delta_y)--(max.x+delta_x, max.y+delta_y), dp);
    return pic;
}

/* if p is in q[] */
bool is_in(person[] q, person p) {
    if (p == null)
        return false;
        
    for (int i = 0; i < q.length; ++ i) {
        if (q[i] == p) return true;
    }
    return false;
}

/*
 * 下面的序号(1)，脚注号[1]，谥号，生卒日期都是可选的:
 * +------------+
 * |(1) 姓名 [1]|
 * |谥号        |
 * |生卒日期    |
 * +------------+
 */
picture draw_person(person p){
    picture pic, ord, name, hao, date;
    string  s1;  // 姓名
    string  s2;  // 生卒年

    // 第一行之序号
    /*
    int order;
    order = scan_int(p.order);
    if (order > 0) {
        //s1 = "\ding{" + format("%d", order + 171) + "}";
        return circle_text("囧");
    }
    */
    if (p.order != blank) {
        ord = circle_text(p.order, g_name_height - 3);  // 使高度略小些
    }
    
    // 第一行，姓名 + 脚注上标(可选)
    s1 = (p.sex != true)? "\kai ":"\song ";  // 男用宋体，女用楷体
    s1 += p.surname + p.given_name; 
    // 脚注上标
    if (p.notes_order >= 0) {
        s1 += "\textsuperscript{[" + format("%d", p.notes_order + 1) + "]}"; 
    }
    
    label(name, s1, (0, 0), p.sex? name_pen: name_pen_female, filltype = NoFill);  //Fill(ymargin=1, ((p.sex==true)?fill_male:fill_female)));

    p.name_width = pic_size(ord).x + pic_size(name).x;  // 保存第一行的长度

    // 第二行，号
    if (p.hao != blank) {
        s1 = (p.sex != true)? "\kai ":"\song " + "\footnotesize " + p.hao; 
        label(hao, s1, (0, 0), name_pen, filltype = NoFill); 
    }

    // 第三行，生卒日期。如果都不清楚的就不画
    if ((p.born_at == question || p.born_at == blank) && (p.dead_at == question || p.dead_at == blank)) {
    } else {
        s2 = "\tiny " + p.born_at + "-" + p.dead_at;
        label(date, s2, (0, 0), name_pen, filltype = NoFill); 
        // 生卒日期可能很长，当它比名字长并且长度大于常数 g_name_width 时，需要自动换行，所以采用minipage(s2, g_name_width). 
        if ((pic_size(date).x > p.name_width) && (pic_size(date).x > g_name_width)) {
            erase(date);
            label(date, minipage(s2, g_name_width), (0, 0), name_pen, filltype = NoFill);  // filltype = Draw(p=dotted));  // with bounding box
        }
    }

    /* attach ord, name, hao & date to pic */
    if (p.order == blank) {
        attach(pic, name.fit(), (0, 0), se);
    } else {
        attach(pic, ord.fit(), (0, 0), se);
        attach(pic, name.fit(), (pic_size(ord).x, 0), se);
    }
    if (p.hao != blank) {
        attach(pic, hao.fit(), (0, - pic_size(pic).y), se);
    }
    attach(pic, date.fit(), (0, - pic_size(pic).y - 2), se);

    if (g_debug) {
        draw(pic, scale(pic_size(pic).x, - pic_size(pic).y)*unitsquare, dotted+red);
    }

    return pic;
}

picture __obsolete_2__draw_person(person p){
    picture pic, name, date;
    string  s1;  // 姓名
    string  s2;  // 生卒年
    
    // 第一行，姓名 + 脚注上标(可选)
    s1 = (p.sex != true)? "\kai ":"\song ";  // 男用宋体，女用楷体
    s1 += p.surname + p.given_name; 
    // 脚注上标
    if (p.notes_order >= 0) {
        s1 += "\textsuperscript{[" + format("%d", p.notes_order + 1) + "]}"; 
    }
    
    label(name, s1, (0, 0), name_pen, filltype = NoFill);  //Fill(ymargin=1, ((p.sex==true)?fill_male:fill_female)));

    p.name_width = pic_size(name).x;  // 保存第一行的长度


    // 第二行，生卒日期。如果都不清楚的就不画
    if ((p.born_at == question || p.born_at == blank) && (p.dead_at == question || p.dead_at == blank)) {
        return name;
    }
    
    s2 = "\tiny " + p.born_at + "-" + p.dead_at;
    label(date, s2, (0, 0), name_pen, filltype = NoFill); 
    // 生卒日期可能很长，当它比名字长并且长度大于常数 g_name_width 时，需要自动换行，所以采用minipage(s2, g_name_width). 
    if ((pic_size(date).x > pic_size(name).x) && (pic_size(date).x > g_name_width)) {
        erase(date);
        label(date, minipage(s2, g_name_width), (0, 0), name_pen, filltype = NoFill); 
    }

    /* attach name & date to pic */
    attach(pic, name.fit(), (0, 0), se);
    attach(pic, date.fit(), (0, - pic_size(name).y - 2), se);

    return pic;
}

picture __obsolete_1_draw_person(person p){
    picture pic;
    real txt_width = g_name_width;
    string  s1;  // minipage(s1, txt_width)
    string  s2;  // s2 = minipage() output
    
    if (p.notes_order >= 0) {
        txt_width += g_glyph_width / 2.;
    }

    // 第一行，姓名 + 脚注上标(可选)
    s1 = (p.sex != true)? "\kai ":"\hei ";  // 男子用黑体，女子用楷体
    s1 += "\makebox[\textwidth][s]{"+p.surname + p.given_name; // [s] means evenly distribute the text
//    s1 += p.surname + p.given_name; // [s] means evenly distribute the text
    // 脚注上标
    if (p.notes_order >= 0) {
        s1 += "\textsuperscript{[" + format(p.notes_order + 1) + "]}}"; 
//        s1 += "\textsuperscript{[" + format(p.notes_order + 1) + "]}"; 
    }
    else {
        s1 += "}"; 
    }
    // 第二行，生卒日期。如果都不清楚的就不画
    if ((p.born_at == question || p.born_at == blank) && (p.dead_at == question || p.dead_at == blank)) {
    }
    else {
        s1 += "\\[2pt]\tiny " + p.born_at + "-" + p.dead_at;
    }

    s2 = minipage(s1, txt_width);
    label(pic, s2, (0, 0), name_pen, filltype = NoFill);  //Fill(ymargin=1, ((p.sex==true)?fill_male:fill_female)));
    //label(pic, s2, (0, 0), name_pen, filltype = Draw(p=dotted));  // with bounding box

    return pic;
}





/* 按广度优先 traverse the tree, return the nodes array (including the spouses if spouse==true) */
person[] traverse_tree_breath_1st(person root, bool spouse = false) {
    int i, j;
    person kid, q[];

    /* 
     * push only not yet in the queue. a kid may be added multiple times
     * because his dad/mom (node and its spouse) will be both processed, 
     * so we need to make sure the pushed element is unique
     */
    void _push_unique(person[] q, person p) {
    
        if (spouse == false) {
            q.push(p);
            return;
        }
        
        for (int i = 0; i < q.length; ++ i) {
            if (q[i] == p)
                return;
        }
        q.push(p);
    }
    
    if (root == null)
        return null;

    /*
     * 遍历，建立队列
     */
    _push_unique(q, root);
    i = 0;

    while (i < q.length) {

        /* self's espouses */
        if (spouse == true) {
            for (j = 0; j < q[i].sps.length; ++ j) {
                _push_unique(q, q[i].sps[j]);            
            }
        }
        
        /* kid & their espouses */
        if (q[i].kid != null) {
            person kid = q[i].kid;
            
            _push_unique(q, kid);
            
            if (spouse == true) {
                for (j = 0; j < kid.sps.length; ++ j) {
                    _push_unique(q, kid.sps[j]);            
                }
            }            
            while (kid.rsib != null) {
                _push_unique(q, kid.rsib);
                if (spouse == true) {
                    for (j = 0; j < kid.rsib.sps.length; ++ j) {
                        _push_unique(q, kid.rsib.sps[j]);            
                    }
                }
                kid = kid.rsib;
            }
        }

        ++ i;
    }

    return q;
}

/*
 * 找到在 root 这棵树下，kid 的上一级节点。由于 kid 在数据结构有 dad/mom 两个上级节点，
 * 所以需要通过当前的 root 往下遍历才能确定哪个在当前树上。
 */
person get_parent_node(person root, person kid) {
    person dad = kid.dad;
    person mom = kid.mom;
    person q[] = traverse_tree_breath_1st(root, spouse = false); 
    if (is_in(q, dad)) {
        return dad;
    } else if (is_in(q, mom)) {
        return mom;
    } else {
        return null;
    }
}

/*
 * 按广度优先设置树中所有备注的顺序，并按顺序画出所有备注
 */
picture set_n_draw_notes(person root, string title_notes = blank, real notes_width=15cm) {
    picture pic;
    person[] q; // the queue for breath-first traverse
    string s1;  // minipage() input
    string s2;  // minipage() output
    int i, j;

    if (root == null)
        return null;

    q = traverse_tree_breath_1st(root, true);

    /*
     * 设置备注顺序(供draw_tree()时使用), 并画备注
     */
    if (title_notes != blank) {
        j = 1;  // 标题最多只有一个备注
    } else {
        j = 0;
    }
    s1 = "\fs\footnotesize 备注: \\[3pt]";

    if (title_notes != blank) {
        s1 += "\textsuperscript{[$1$]}" + title_notes + "\\[2pt]";
    }
    
    for (i = 0; i < q.length; ++ i) {
        if (q[i].notes != blank) {
            q[i].notes_order = j;
            ++ j;

            //s1 += "\makebox[1cm][l]{\textsuperscript{[" + format(j) + "]}" + q[i].notes + "}\\[2pt]";
            s1 += "\textsuperscript{[" + format(j) + "]}" + q[i].notes + "\\[2pt]";

        }
    }

    //write(s1);

    if (j == 0)  // 没有备注
        return null; 
        
    s2 = minipage(s1, notes_width);
    label(pic, s2, (0, 0), name_pen, NoFill); 
    
    return pic;
}



/*
 * draw connection lines recursively
 *
 * 使用了下面几个全局变量:
 * - g_kid_h_gap: 两代之间的水平间隔
 * - g_x_skip: 连线和人名之间的水平空隙
 * - g_name_height: 人名高度
 */
void _draw_conn_lines_r(picture pic, // the picture
                        person root, // the root
                        pair A) {    // the position of root (top-left) in pic

    /*
     * A +-------+   C0  +---------+
     *   |     B +---+---+ E0      |
     *   +-------+   |   +---------+
     *               :
     *               :
     *               |   +--------+
     *               +---+ En     |
     *               Cn  +--------+
     *               
     *  1. 先画 B--C0
     *  2. 再依次画 Cn--En
     *  3. 最后画 C0--Cn
     */
       
    if (root.kid == null) {  // 叶子节点
        return;
    }

    person kid;    
    pair B, C0, Cn, E0, En;
    int i;
    real h = g_kid_h_gap / 2 - g_x_skip; // 短横 BC 的长度, BC=CE 
     
    B = A + (root.name_width + g_x_skip, - g_name_height / 2);
    C0 = B + (h, 0);

    // B--C0
    draw(pic, B--C0, g_debug? green: line_pen);

    // Cn-En
    for (kid = root.kid; kid != null; kid = kid.rsib) {
        En = A + kid.offset - (g_x_skip, g_name_height / 2);
        Cn = En - (h, 0);
        draw(pic, Cn--En, g_debug? blue: line_pen);
    }

    // C0--Cn
    draw(pic, C0--Cn, g_debug? red: line_pen);


    /*
     * 递归
     */
    for (kid = root.kid; kid != null; kid = kid.rsib) {
        _draw_conn_lines_r(pic, kid, A + kid.offset);
    }
}


/* 
 * recursively draw a tree, which is not split it into multi-parts.
 * the following size info are also updated:
 *   - person.root_size
 *   - person.offset
 */
picture _draw_simple_tree_r(person root, 
                            int level = 0){ // 嵌套层次

    picture pic, self, spouse;
    person kid;
    real v_offset; // spourse vertical offset
    /* (xoff, yoff) 是在 pic 中 attach 下一棵子树的坐标 */
    real xoff, yoff;
    pair A, B, C1, C2, D; // 连接线的控制点

    if (root == null)
        return null;

    /* 
     * 先画自己, attach 到 pic 上 
     */
    self = draw_person(root);
    attach(pic, self.fit(), (0, 0), se);

    /* 
     * 再依次将所有的配偶，一一 attach 到 pic 上 self 的下方 
     */
    v_offset = pic_size(self).y + g_spouse_v_gap;

    for (int i = 0; i < root.sps.length; ++ i) {
        // don't draw spouse with unknown surname
        if (root.sps[i].surname == unknown) continue;

        spouse = draw_person(root.sps[i]);
        attach(pic, spouse.fit(), (0, - v_offset), se);
        v_offset += pic_size(spouse).y + g_spouse_v_gap;
    }

    /* 更新 root.root_size, 为 self + spouses[] */
    root.root_size = pic_size(pic);

    if (g_debug) {
        /* 画 root 的框框 */
        draw(pic, scale(pic_size(pic).x, - pic_size(pic).y)*unitsquare, dashed+blue);
    }

    /* 
     * now recursively draw & attach kids 
     */
    if (root.kid == null)
        return pic;

    //xoff = pic_size(self).x + g_kid_h_gap;
    xoff = root.name_width + g_kid_h_gap;
    yoff = 0;
    
    /* 画连接线。每个子树到父树的连接线都分为三段，AB(统一画), C1C2, CD:
     *
     *        A   B   D
     * [self] +---+---+ [kid0]
     *            |
     *         C1 +---+ [kid1]
     *            |
     *            |
     *         C2 +---+ [kid2]
     *                
     */
    /* 先画公共部分 AB */
    //A = (pic_size(self).x + g_x_skip, - g_conn_v_off);
    A = (root.name_width + g_x_skip, - g_conn_v_off);
    B = A + (g_kid_h_gap / 2 - g_x_skip, 0);
    //draw(pic, A--B, line_pen); 

    /* 开始循环 */
    C1 = C2 = B;
    for(kid = root.kid; kid != null; kid = kid.rsib){

        /* 记录 kid.offset */
        kid.offset = (xoff, yoff);
        
        /* 画子树并 attach 到 pic 上 */
        picture k = _draw_simple_tree_r(kid, level + 1);
        attach(pic, k.fit(), (xoff, yoff), se);

        /* 画连接线 C1--C2, C--D */
        D = C2 + (g_kid_h_gap / 2 -g_x_skip, 0);
        //draw(pic, C1--C2--D, line_pen);

        /* 更新 yoff 以及 C1, C2 */
        yoff -= pic_size(k).y + g_y_skip;
        C1 = C2;
        C2 -= (0, pic_size(k).y + g_y_skip);
    }

    /* 更新 root.tree_size, root.space_size */
    root.tree_size = pic_size(pic);

    /* 最后画连接线 */
    if (level == 0) {
        _draw_conn_lines_r(pic, root, (0, 0));
    }

    return pic;
}

/*
 *               A
 *  +----+   H   +------------------------+
 *  |dad |---+---| zz                     |
 *  |    |   |  B+--------+               |
 *  |    |   :   |////////|               |
 *  +----+       |////////|               |
 *               |////////+----+          |
 *               |/ spaces ////|          |
 *               |/////////////|          |
 *               |/////////////|          |
 *             C +--------+----+----------+ 
 *
 *
 *               A
 *  +----+       +------------------------+
 *  |dad |---+---| zz                     |
 *  |    |   |   +--------+               |
 *  |    |   |   |        |               |
 *  +----+   |   +----+   |               |
 *         H +---|    |   |               |
 *           |  B+----+   +----+          |
 *           :   |/////////////|          |
 *               |/////////////|          |
 *             C +--------+----+----------+ 
 *
 */
/* return the next attach point for no packing case */
pair _attach_kid_pack(picture pd, picture pk, // picture dad & kid
                person dad, person kid,       // person dad & kid
                pair A,                       // attach point as if there is no packing requirement
                bool pack=false) {


    int i;
    pair ks = pic_size(pk);  // kid size
    bool hit, zz = (dad.kid == kid);  // 第一个孩子(长子)
    
    attach(pd, pk.fit(), A, se);
    kid.offset = A;


    // TODO:  marge rects, and then pack!!!!

    
    /* 
     * 更新 root.space_size: 需要把root 下面的空间和 root 孩子可能带来的空间合并 
     */
    //root.space_size.push((root.root_size.x, root.tree_size.y - root.root_size.y));


    return A + (0, - pic_size(pk).y - g_y_skip);
}

/* 
 * recursively draw a simple tree, connection lines are left undrawn.
 */
picture _draw_simple_tree_pack_r(person root, 
                                 bool pack=false, 
                                 int level=0){  // 嵌套层次

    picture pic, self, spouse;
    int i;
    person kid;
    real v_offset; // spourse vertical offset
    /* (xoff, yoff) 是在 pic 中 attach 下一棵子树的坐标 */
    real xoff, yoff;
    pair A, B, C1, C2, D; // 连接线的控制点

    if (root == null)
        return null;

    /* 
     * 先画自己, attach 到 pic 上 
     */
    self = draw_person(root);
    attach(pic, self.fit(), (0, 0), se);

    /* 
     * 再依次将所有的配偶，一一 attach 到 pic 上 self 的下方 
     */
    v_offset = pic_size(self).y + g_spouse_v_gap;

    for (int i = 0; i < root.sps.length; ++ i) {
        // don't draw spouse with unknown surname
        if (root.sps[i].surname == unknown) continue;

        spouse = draw_person(root.sps[i]);
        attach(pic, spouse.fit(), (0, - v_offset), se);
        v_offset += pic_size(spouse).y + g_spouse_v_gap;
    }

    /* 更新 root.root_size, 为 self + spouses[] */
    root.root_size = pic_size(pic);

    if (g_debug) {
        /* 画 root 的框框 */
        draw(pic, scale(pic_size(pic).x, - pic_size(pic).y)*unitsquare, dashed+blue);
    }

    /* 
     * now recursively draw & attach kids 
     */
    if (root.kid == null) {
        // root.space_size = new pair[]{}; // 初始化时叶子节点就没有 space
        return pic;
    }

    xoff = root.name_width + g_kid_h_gap;
    yoff = 0;
    
    A = (root.name_width + g_kid_h_gap, 0);
    for(kid = root.kid; kid != null; kid = kid.rsib){
        picture pk = _draw_simple_tree_pack_r(kid, pack, level + 1);
        A = _attach_kid_pack(pic, pk, root, kid, A, pack);
    }

    /* 更新 root.tree_size */
    root.tree_size = pic_size(pic);

    if (g_debug) {
        /* 画 root 整个树下空白的框框 
         *   +------------------------+
         *   | root                   |
         * A +--------+ B             |
         *   |////////|               |
         *   |////////|    tree       |
         *   |/space//|               |
         *   |////////|               |
         *   |////////|               |
         *   +--------+---------------+
         *  D         C
         */
        pair A, B, C, D;
        A = (0, - root.root_size.y);
        B = A + (root.root_size.x, 0);
        C = B - (0, root.tree_size.y - root.root_size.y);
        D = A - (0, root.tree_size.y - root.root_size.y);
        draw(pic, scale(pic_size(pic).x, - pic_size(pic).y)*unitsquare, yellow);
        draw(pic, A--B--C--D--cycle, green);
        
    }

    /* 最后画连接线 */
    if (level == 0) {
        _draw_conn_lines_r(pic, root, (0, 0));
    }

    return pic;
}


/*
 * "simple" just means "not split"
 */
picture draw_simple_tree(person root, 
                         bool pack = false) { // 是否压缩(利用)纵向空间
    if (pack) {
        return _draw_simple_tree_pack_r(root, pack);
    }
    else {
        return _draw_simple_tree_r(root);
    }
}



/*
 * put pic2[] (representing kids) below pic1 (representing parent),
 * and add connection lines betw them.

  pic1 and pic2[] are to be connected as below:

   (0,0)     
     +====================+
     |[root]      pic1    |
     |                    |
     |         A0      A  |
     |          [split]+--|--+ B
     +====================+  |
   D +-----------------------+ C
     |     A1
     |  F  +===================+
   E +--+--+ G                 |
        |  |       pic2[0]     |
        |  +===================+
        |
        |  +===================+
   H/H2 +--+ G                 |
        :  |      pic2[1]      |
        :  +===================+
        :
        
    其中:
    - pic1 为从 root 到 split (inclusive) 的一段树。root 节点的 offset 为(0,0), 
      split 节点的 offset 为 A0 的坐标。
    - pic2[] 为 split 下面的子树们。它们在合并后的 offset 为 A1[] 的坐标。
    - A1 的坐标通过确定 A0 以及 ABCEDFGH 各点得到。
    - 连接线 ABCDEF 为公共部分，先一次性画出。各个子树的连接线分两段，垂直的
      H--H2 加水平的 H--G, 分别画。
 */
picture combine_simple_trees(picture pic1, 
                      picture[] pic2, 
                      person root, 
                      person split) { // split is included in pic1

    picture pic; // the pic to return
    pair A0, A1, A, B, C, D, E, F, G, H, H2;
    person kids[]; // split 的后代, 和 pic2[] 下标对应, 为方便更新 kid 子树根节点的 offset A1[]

    // 临时变量
    person kid, parent, q[];
    real xoff, yoff, r; 
    path p;
    int i;
    
    /* 
     * making sure that "split" is a descentant from "root"
     */
    q = traverse_tree_breath_1st(root, spouse = false);
    if(is_in(q, split) == false) {
        write("error: split is not a descendant from root!");
        return pic1;
    }

    /*
     * 记录下 kids[]
     */
    kid = split.kid;
    while (kid != null) {
        kids.push(kid);  
        kid = kid.rsib;
    }

    /* 
     * attach pic1
     */
    attach(pic, pic1.fit(), (0, 0), se);

    /* 
     * 计算 A0
     */
    parent = split;
    xoff = 0;
    yoff = 0;
    do {
        xoff += parent.offset.x;
        yoff += parent.offset.y;
        parent = get_parent_node(root, parent);
    } while (parent != null);

    A0 = (xoff, yoff); 

    /*
     * 计算 ABCDEF 各点并画连接线的公共部分
     */
    xoff += split.root_size.x + g_x_skip;
    yoff -= g_conn_v_off;

    //A = A0 + (split.rect_size.x + g_x_skip, - g_conn_v_off);
    A = A0 + (split.name_width + g_x_skip, - g_conn_v_off);
    B = (pic_size(pic1).x + g_kid_h_gap / 2, A.y);
    C = (B.x, - pic_size(pic1).y - g_name_height * 2);
    D = (0, C.y);
    E = D - (0, g_name_height * 2);
    F = E + (g_kid_h_gap / 2, 0);

    //dot(pic, A0, red); dot(pic, A, red); dot(pic, B, red); dot(pic, C, red); dot(pic, D, red); dot(pic, E, red); dot(pic, F, red); 

    r = g_name_height / 4; // radius of the rounded cornor for connection lines
    p = A--(B-(r,0)){right}..{down}(B-(0,r))--
           (C+(0, r)){down}..{left}(C-(r,0))--
           (D+(r,0)){left}..{down}(D-(0,r))--
           (E+(0,r)){down}..{right}(E+(r,0))--F;

    draw(pic, p, line_pen);

    /* 
     * 循环 attach pic2[]
     */    
    yoff = 0;
    H = H2 = F;
    for (i = 0; i < pic2.length; ++ i) {
        /*
         * connection lines: 
         * 
         *    H +
         *      |
         *   H2 +--- G
         */
        G = H2 + (g_kid_h_gap / 2, 0);
        draw(pic, H--H2--G, line_pen);
        A1 = G + (0, g_conn_v_off);
        attach(pic, pic2[i].fit(), A1, se);

        /* 更新 "子树根节点" 的 offset:
         *  - 其父节点在 pic 中的绝对坐标为 A0,
         *  - 其自身在 pic 中的绝对坐标为 A1
         *  - 所以其相对于父节点的 offset 为 A1-A0;
         */
        kids[i].offset = A1 - A0; 

        /* 更新其它临时坐标 */
        yoff += pic_size(pic2[i]).y + g_y_skip;
        H = H2;
        H2 -= (0, pic_size(pic2[i]).y + g_y_skip);
    }

    return pic;
}




/*
 * 代替 __obsolete__draw_split_tree_recursive()
 */
picture draw_split_tree_in_loop(person root, person[] splits = new person[]{}, bool pack=false) {

    person q[], splits2[], kid, kid2;
    int i;

    /* 
     * sanity check on splits[]
     */
    if (splits.length <= 0) {
        return draw_simple_tree(root, pack);
    }
    
    // 检查 splits[] 的合法性, 产生 splits2[]
    q = traverse_tree_breath_1st(root, spouse = false);
    for (i = 0; i < splits.length; ++ i) {
        if(is_in(q, splits[i]) == true) {
            splits2.push(splits[i]);
        }
    }

    if (splits2.length <= 0) {
        return draw_simple_tree(root, pack);
    }

    /*
     * from now on, we use splits2[], not splits[].
     */

    picture pic1;      // root pic
    picture[][] pic2s; // 每个 split 后面对应一个 picture 数组

    /* 
     * draw root 1st 
     */
    kid = splits2[0].kid;  // save in temp
    splits2[0].kid = null; // split the tree
    pic1 = draw_simple_tree(root, pack);
    splits2[0].kid = kid;  // restore

    /*
     * 循环生成 pic2s[]
     * 每次循环，生成一个 split 后接的pic2[]数组。有几个 split 点就有几个数组。
     * 为方便loop编写，在splits[]最后加一个 fake person
     */
    person fake = new person;
    splits2.push(fake);
    for (i = 0; i < splits2.length - 1; ++ i) {
        picture[] pic2;             // temps
        kid2 = splits2[i + 1].kid;  // save in temp
        splits2[i + 1].kid = null;  // split the tree at the next split point

        /* 
         * get pic2[] in loop
         */
        kid = splits2[i].kid;  // notices the index is i, not (i + 1)
        while (kid != null) {
            pic2.push(draw_simple_tree(kid, pack));
            kid = kid.rsib;
        }
        
        splits2[i +1].kid = kid2; // restore

        pic2s.push(pic2);
    }

    splits2.pop(); // remove fake node

    /*
     * connect all pictures in a loop
     */
    for (i = 0; i < splits2.length; ++ i) {
        pic1 = combine_simple_trees(pic1, pic2s[i], root, splits2[i]);
    }
    
    return pic1;
}




/* 
 * draw a tree which is split into more than two parts 
 * splits[] are nodes *after* which the tree is to be split
 *
 * 有个缺陷: 后接上的图片会依次缩进，不好解决。
 * 使用 draw_split_tree_in_loop() 作为替代。
 */
picture __obsolete__draw_split_tree_recursive(person root, person[] splits = new person[]{}) {

    person q[], splits2[];
    int i;

    if (splits.length <= 0) {
        return draw_simple_tree(root);
    }
    
    /* 
     * check relationship between root and splits[], remove those in 
     * splits[] which are not decents of the root 
     */
    q = traverse_tree_breath_1st(root, spouse = false);
    for (i = 0; i < splits.length; ++ i) {
        if(is_in(q, splits[i]) == true) {
            splits2.push(splits[i]);
        }
    }

    if (splits2.length <= 0) {
        return draw_simple_tree(root);
    }

    
    picture pic; // the pic to return
    picture pic1, pic2[];
    person kid, parent, kids[];
    pair A0, A1; // A0 is the offset of split_after node from root
    pair A, B, C, D, E, F, G, H, H2;
    real xoff, yoff; 

    /* 
     pic1 and pic2[] are to be connected as below: ABCDEF 为公共部分，先画
     
     +===================+
     |  pic1             |
     |         A0     A  |
     |         [split]+--|--+ B
     +===================+  |
   D +----------------------+ C
     |     A1
     |  F  +===================+
   E +--+--+ G                 |
        |  |       pic2[0]     |
        |  +===================+
        |
        |  +===================+
      H +--+ G                 |
        :  |      pic2[1]      |
        :  +===================+
    */
    

    /* 
     * save the kid info and split the tree
     */
    kid = splits2[0].kid;
    splits2[0].kid = null; 

    /* 
     * draw pic1 and pic2[] 
     */
    pic1 = draw_simple_tree(root);
    
    while (kid != null) {
        kids.push(kid);  // 方便后面更新 kid 子树根节点的 offset 
        //pic2.push(draw_single_tree_recursive(kid));
        pic2.push(__obsolete__draw_split_tree_recursive(kid, splits2));
        kid = kid.rsib;
    }

    /* 
     * attach pic1
     */
    attach(pic, pic1.fit(), (0, 0), se);

    /*
     * draw common part of the "carriage return" connection lines: ABCEDF
     */
    /* get point A's offset (from root to split_after) */
    parent = splits2[0];
    xoff = 0;
    yoff = 0;
    do {
        xoff += parent.offset.x;
        yoff += parent.offset.y;
        parent = get_parent_node(root, parent);
    } while (parent != null);

    A0 = (xoff, yoff); // 记录该值，后面用来更新子树根节点的 offset

    //xoff += splits2[0].rect_size.x + g_x_skip;
    xoff += splits2[0].name_width + g_x_skip;
    yoff -= g_conn_v_off;

    A = (xoff, yoff);
    B = (pic_size(pic1).x + g_kid_h_gap / 2, A.y);
    C = (B.x, - pic_size(pic1).y - g_name_height * 2);
    D = (0, C.y);
    E = D - (0, g_name_height * 2);
    F = E + (g_kid_h_gap / 2, 0);

    //dot(pic, A, red); dot(pic, B, red); dot(pic, C, red); dot(pic, D, red); dot(pic, E, red); dot(pic, F, red); 
    
    real r = g_name_height / 4; // radius of the rounded cornor for connection lines
    path p = A--(B-(r,0)){right}..{down}(B-(0,r))--
                (C+(0, r)){down}..{left}(C-(r,0))--
                (D+(r,0)){left}..{down}(D-(0,r))--
                (E+(0,r)){down}..{right}(E+(r,0))--F;

    draw(pic, p, line_pen);

    /* 
     * 循环 attach pic2[]
     */    
    yoff = 0;
    H = H2 = F;
    for (int i = 0; i < pic2.length; ++ i) {
        /*
         * connection lines: 
         * 
         *    H +
         *      |
         *   H2 +--- G
         */
        G = H2 + (g_kid_h_gap / 2, 0);
        draw(pic, H--H2--G, line_pen);
        A1 = G + (0, g_conn_v_off);
        attach(pic, pic2[i].fit(), A1, se);

        /* 更新 "子树根节点" 的 offset:
         *  - 其父节点在 pic 中的绝对坐标为 A0,
         *  - 其自身在 pic 中的绝对坐标为 A1
         *  - 所以其相对于父节点的 offset 为 A1-A0;
         */
        kids[i].offset = A1 - A0; 

        /* 更新其它临时坐标 */
        yoff += pic_size(pic2[i]).y + g_y_skip;
        H = H2;
        H2 -= (0, pic_size(pic2[i]).y + g_y_skip);
    }

    /*
     * resotre relationship
     */
    splits2[0].kid = kid;  

    return pic;
}















void shipout_lineage(person root, person[] splits=new person[]{}, string file_name, string title, string title_notes = blank, real notes_width=15cm, bool pack = false) {

    string s;  // minipage() input for title line
    
    picture ttl; // title
    picture tree;
    picture notes; 

    real v_off = 0;

    s = "\hei\LARGE\underline{" + title + "}";
    if (title_notes != blank) {
        s += "\textsuperscript{[$1$]}";
    }
    
    label(ttl, minipage(s, notes_width), (0, 0), name_pen, NoFill); 
    notes = set_n_draw_notes(root, title_notes, notes_width);
    tree = draw_split_tree_in_loop(root, splits, pack);

    erase(currentpicture);
    attach(ttl.fit(), (0, 0), se);
    v_off -= pic_size(ttl).y + 30;
    attach(tree.fit(), (0, v_off), se);
    v_off -= pic_size(tree).y + 30;
    if (notes != null) {
        attach(notes.fit(),(0, v_off), se);
    }
    add_margin();
    shipout(file_name);
    erase(currentpicture);
}

