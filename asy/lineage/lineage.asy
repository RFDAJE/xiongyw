/* created(bruin, 2007-03-01): draw family lineage diagram.
   - build the family tree in memory firstly
   - draw the diagram for the tree

   - updated(bruin, 2015-06-22): xelatex and utf-8
   - updated(bruin, 2016-02-11): multiple spouses support; also add nick_name field

   use it by importing this script: 

   import "lineage.asy" as lineage;
 */

settings.tex = "xelatex";


texpreamble("\usepackage{xeCJK}");

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

/* we use PostScript unit in both picture and frame */
size(0, 0);
unitsize(0, 0);

defaultpen(fontsize(12));
pen line_pen = linewidth(0.8) + black + linecap(0); /* square cap */
pen name_pen = linewidth(0.1) + black + fontsize(12);

pen fill_male = paleblue;
pen fill_female = pink;

real   width = 36;          /* person's name width: minipage width */
pair   se=0.0001SE;         /* used for alignment for picture attach() */

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
  string   nick_name;
	string   born_at;
	string   dead_at;

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
	                     string nick_name = ""){
		person p = new person;
		p.sex = sex;
		p.surname = surname;
		p.given_name = given_name;
		p.nick_name = nick_name;
		p.born_at = born_at;
		p.dead_at = dead_at;

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

		//if(this.sex == p.sex)
		//	return false;

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

picture draw_person(person p){
	picture pic;
	string s;

	//minipage(((p.sex!=true)?"\kai":"\hei")+"\makebox["+format("%d", (int)width)+"bp][s]{"+p.surname + p.given_name + "}\\[2pt]\tiny" + p.born_at + "-" + p.dead_at, width),
	// minipage(((p.sex!=true)?"\kai":"\hei")+"\makebox[\textwidth][s]{"+p.surname + p.given_name + "}\\[2pt]\tiny" + p.born_at + "-" + p.dead_at, width),
	if ((p.born_at == question || p.born_at == blank) && (p.dead_at == question || p.dead_at == blank)) { // 生卒日期都不清楚的就不写
	    s = minipage(((p.sex!=true)?"\kai":"\hei")+"\makebox[\textwidth][s]{"+p.surname + p.given_name + "}", width);
	} else {
	    s = minipage(((p.sex!=true)?"\kai":"\hei")+"\makebox[\textwidth][s]{"+p.surname + p.given_name + "}\\[2pt]\tiny" + p.born_at + "-" + p.dead_at, width);
	}

	label(pic, s, (0, 0), name_pen, NoFill);  //Fill(ymargin=1, ((p.sex==true)?fill_male:fill_female)));

	return pic;
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

picture draw_tree(person root){

	picture pic, self, spouse;
	person kid;

	if(root != null){


		self = draw_person(root);
		attach(pic, self.fit(), (0, 0), se);

/*
		if(root.sps != null && root.sps.surname != unknown){  // not draw person with unknown surname
			spouse = draw_person(root.sps);
			attach(pic, spouse.fit(), (0, -pic_size(self).y - 3), se);
		}
*/

   /* draw all spouses in order, under "self" */
   real v_offset = pic_size(self).y + 3;
   //root.info();
   //write(root.sps.length);
   for (int i = 0; i < root.sps.length; ++ i) {
     // don't draw spouse with unknown surname
     if (root.sps[i].surname == unknown) continue;

     spouse = draw_person(root.sps[i]);
     attach(pic, spouse.fit(), (0, - v_offset), se);
     v_offset += pic_size(spouse).y + 3;
   }


		real xgap = width*2;
		real ygap = 0;
		for(kid = root.kid; kid != null; kid = kid.rsib){

			/* draw connection lines */
			pair self_right = (pic_size(self).x + 2, -pic_size(self).y/3);
			pair middle = self_right + (width/2, 0);
			draw(pic, self_right--middle--(middle+(0,ygap))--(self_right+(width - 4,ygap)), line_pen);

			/* draw kid pic and attach it */
			picture k = draw_tree(kid);
			attach(pic, k.fit(), (xgap, ygap), se);


			ygap -= pic_size(k).y + 6;
		}

	}

	return pic;
}

/* add time stamp in the lower left corner of the picture */
void add_time_stamp(picture pic){
	label(pic, minipage("\fs\footnotesize " + time("%Y-%m-%d")+"\:修订", 100), (0,-pic_size(pic).y), 0.001SE);
}
