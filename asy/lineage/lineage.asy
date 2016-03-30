/* created(bruin, 2007-03-01): draw family lineage diagram.
   - build the family tree in memory firstly
   - draw the diagram for the tree

   - updated(bruin, 2015-06-22): xelatex and utf-8
   - updated(bruin, 2016-02-11): multiple spouses support; also add "notes" field
   - updated(bruin, 2016-03-28): fix horizontal alignment bug

   Todo: 
     + in certain cases, the dash lines are not aligned (2016-03-28)
     - add notes into the diagram
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

texpreamble("\setCJKmainfont[Path=./fonts/]{arialuni.ttf}");
texpreamble("\setCJKfamilyfont{song}[Path=./fonts/]{arialuni.ttf}");
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

real g_glyph_width = 12;                      /* 一个汉字的宽度, in bp */
real g_name_height = g_glyph_width;           /* 人名高度 */
real g_name_width = g_glyph_width * 3;        /* 人名最多三个字 */
real g_spouse_v_gap = 3;                      /* 配偶上下间距 */
real g_kid_h_gap = g_name_width;              /* 上下两辈之间的水平距离 */  
defaultpen(fontsize(g_glyph_width));

pair   se=0.0001SE;         /* used for alignment for picture attach() */

pen line_pen = linewidth(0.8) + black + linecap(0); /* square cap */
pen name_pen = linewidth(0.1) + black + fontsize(g_glyph_width);

pen fill_male = paleblue;
pen fill_female = pink;


/*
 * 第一部分: 构造家族数据结构
 */

/* surname/name for person whose name is unknown yet */
string unknown  = "□";      
string unknown2 = "□□";

/* for born/dead date */
string question = "?";     // reached but not known yet
string blank = "";         // not reached

/* person: a node in family tree */
struct person{
    bool     sex;   /* true for male */
    string   surname;
    string   given_name;
    string   born_at;
    string   dead_at;
    string   notes;

    person   dad;    /* null if unknown */
    person   mom;    /* null if unknown */

    /* one may have multiple spouses */
    person[] sps;

    person   kid;    /* first child; null if leaf */
    person   lsib;   /* left sibling; null if first kid */
    person   rsib;   /* right sibling; null if last kid */

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
                         string notes = blank){
        person p = new person;
        p.sex = sex;
        p.surname = surname;
        p.given_name = given_name;
        p.born_at = born_at;
        p.dead_at = dead_at;
        p.notes = notes;

        p.dad = null;
        p.mom = null;
        p.sps = new person[]{};
        p.kid = null;
        p.lsib = null;
        p.rsib = null;

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
};



/*
 * 第二部分:绘图
 */



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


/* fixme: 在画之前如何确定文字的长度?貌似中文的姓名，即使宽度超过minipage的宽度，也不会
 *        换行，而且生成的 pic 的 size 也不能反映世界的宽度。。。
 * \widthof: http://tex.stackexchange.com/questions/18576/get-width-of-a-given-text-as-length
 */
picture draw_person(person p, int num = 0){ // num: 脚注上标顺序；缺省 0 或小于 0 表示不需要画上标
    picture pic;
    real txt_width = g_name_width;
    string  s1;  // minipage(s1, txt_width)
    string  s2;  // s2 = minipage() output
    
    if (num > 0) {
        txt_width += g_glyph_width / 2;
    }

    // 第一行，姓名 + 脚注上标(可选)
    s1 = (p.sex != true)? "\kai":"\hei";  // 男子用黑体，女子用楷体
    s1 += "\makebox[\textwidth][s]{"+p.surname + p.given_name; // [s] means evenly distribute the text
    // 脚注上标
    if (num > 0) {
        s1 += "\textsuperscript{[" + format(num) + "]}}"; 
    }
    else {
        s1 += "}"; 
    }
    // 第二行，生卒日期。如果都不清楚的就不画
    if ((p.born_at == question || p.born_at == blank) && (p.dead_at == question || p.dead_at == blank)) {
    }
    else {
        s1 += "\\[2pt]\tiny" + p.born_at + "-" + p.dead_at;
    }

    s2 = minipage(s1, txt_width);
    label(pic, s2, (0, 0), name_pen, NoFill);  //Fill(ymargin=1, ((p.sex==true)?fill_male:fill_female)));

    return pic;
}


picture draw_tree(person root){

    picture pic, self, spouse;
    person kid;

    if (root == null)
        return null;

    /* 先画自己, attach 到 pic 上 */
    self = draw_person(root);
    //write(root.surname + root.given_name);
    //write(pic_size(self).x);
    attach(pic, self.fit(), (0, 0), se);

    /* 再依次所有的配偶，一一 attach 到 pic 上 self 的下方 */
    real v_offset = pic_size(self).y + g_spouse_v_gap;

    for (int i = 0; i < root.sps.length; ++ i) {
        // don't draw spouse with unknown surname
        if (root.sps[i].surname == unknown) continue;

        spouse = draw_person(root.sps[i]);
        attach(pic, spouse.fit(), (0, - v_offset), se);
        v_offset += pic_size(spouse).y + g_spouse_v_gap;
    }

    /* 最后递归画 kids */

    /* (xoff, yoff) 是在 pic 中 attach 下一棵子树的坐标 */
    real xoff = pic_size(self).x + g_kid_h_gap;
    real yoff = 0;
    
    real xskip = 2; /* 水平连接线和 self/kid 的间距 */
    real yskip = 6; /* kids 子树之间的垂直间距 */
    
    for(kid = root.kid; kid != null; kid = kid.rsib){

        /* 画连接线。每个子树到父树的连接线都分为三段，横竖横:
         *
         * [self]----+ 
         *           |
         *           +----[kid]
         */
        pair self_right = (pic_size(self).x + xskip, - g_name_height / 2);
        pair middle = self_right + (g_kid_h_gap / 2, 0);
        draw(pic, self_right--middle--(middle + (0, yoff))--(self_right + (g_kid_h_gap - xskip * 2, yoff)), line_pen);

        /* 画子树并 attach 到 pic 上 */
        picture k = draw_tree(kid);
        attach(pic, k.fit(), (xoff, yoff), se);


        yoff -= pic_size(k).y + yskip;
    }

    return pic;
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


/* add time stamp in the lower left corner of the picture */
void add_time_stamp(picture pic=currentpicture){
    label(pic, minipage("\fs\footnotesize 本表修订于 " + time("%Y-%m-%d"), 100), (0,-pic_size(pic).y-30), se);
}

void shipout_lineage(person root, string file_name) {
    picture pic=draw_tree(root);

    erase(currentpicture);
    attach(pic.fit(), (0,0), se);
    add_time_stamp();
    add_margin();
    add_time_stamp(pic);
    shipout(file_name);
    erase(currentpicture);
}
