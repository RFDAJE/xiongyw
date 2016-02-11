/* created(bruin, 2007-03-01): draw family lineage diagram.
   - build the family tree in memory firstly
   - draw the diagram for the tree

   - updated(bruin, 2015-06-22): xelatex and utf-8
   - updated(bruin, 2016-02-11): multiple spouses support; also add nick_name field

   usage: "asy -f pdf family-utf8.asy" under windows/linux
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
string unknown  = "~";      /* surname/name for person not to draw */
string question = "?";      /* for born/dead date */

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

	/* mom gives birth to the kid */
	bool give_birth(person kid,            /* the kid to be born */
	                person lsib = null,    /* the left sibling of this kid; null if the 1st kid */
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

	label(pic,
	    //minipage(((p.sex!=true)?"\kai":"\hei")+"\makebox["+format("%d", (int)width)+"bp][s]{"+p.surname + p.given_name + "}\\[2pt]\tiny" + p.born_at + "-" + p.dead_at, width),
	     minipage(((p.sex!=true)?"\kai":"\hei")+"\makebox[\textwidth][s]{"+p.surname + p.given_name + "}\\[2pt]\tiny" + p.born_at + "-" + p.dead_at, width),
	      (0, 0),
	      name_pen,
	      NoFill);
	      //Fill(ymargin=1, ((p.sex==true)?fill_male:fill_female)));

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




/* ######################################################################## */
//
//  家族数据
//
/* ######################################################################## */

person male_unknown   = person.person(true,  unknown, unknown, unknown, unknown );
person female_unknown = person.person(false, unknown, unknown, unknown, unknown );

/* ################ 熊氏 ################ */

/* 人员 */

person xiong_jiasong  = person.person(true,  "熊", "家松",       question, question);
person xiong_jiasong_wife  = person.person(false, unknown, unknown, unknown, unknown );
person xiong_cheng_x  = person.person(false, "熊", "承□",       question, question);
person xiong_chengbin = person.person(true,  "熊", "承斌",       "1911.07.12",   "1999");
person wen_bishou     = person.person(true,  "文", "必寿",       question, question);
person wen_changxiang = person.person(true,  "文", "昌祥",       question, "");
person wen_changxiang_wife  = person.person(false, unknown, unknown, unknown, unknown );
person wen_x          = person.person(false, "文", "□□",       question, "");
person wen_weixing    = person.person(true,  "文", "卫星",       question, "");
person wen_x1         = person.person(true,  "□", "□□",       question, "");  /* 性别亦不清楚 */
person wen_x2         = person.person(true,  "□", "□□",       question, "");  /* 性别亦不清楚 */
person wen_x3         = person.person(true,  "□", "□□",       question, "");  /* 性别亦不清楚 */
person yan_xiangxiao  = person.person(false, "严", "相孝",       "1911.07.20",   "1995");
person xiong_zuxin    = person.person(true,  "熊", "祖鑫",       "1944.01.25",   "");
person wang_fuying    = person.person(false, "王", "福英",       "1946.03.19",   "");
person xiong_yuwen    = person.person(true,  "熊", "育文",       "1970.07.16",   "", nick_name="大红");
person xiong_yuwu     = person.person(true,  "熊", "育武",       "1971.09.23",   "", nick_name="小红");
person tian_aigu      = person.person(false, "田", "爱姑",       "1971.12.14",   "");
person xiong_qiushi   = person.person(false, "熊", "秋实",       "1996.08.07",   "", nick_name="秋秋");
person chen_juan      = person.person(false, "陈", "娟",         "1972.11.11",   "");
person xiong_kaiyuan  = person.person(false, "熊", "开元",       "2000.12.19",   "", nick_name="元元");

/* 关系 */

xiong_jiasong.marry(xiong_jiasong_wife);
xiong_jiasong_wife.give_birth(xiong_cheng_x);
xiong_jiasong_wife.give_birth(xiong_chengbin, xiong_cheng_x);

wen_bishou.marry(xiong_cheng_x);
xiong_cheng_x.give_birth(wen_changxiang);
xiong_cheng_x.give_birth(wen_x, wen_changxiang);

wen_changxiang.marry(wen_changxiang_wife);
wen_changxiang_wife.give_birth(wen_weixing);
wen_changxiang_wife.give_birth(wen_x1, wen_weixing);
wen_changxiang_wife.give_birth(wen_x2, wen_x1);
wen_changxiang_wife.give_birth(wen_x3, wen_x2);

xiong_chengbin.marry(yan_xiangxiao);
yan_xiangxiao.give_birth(xiong_zuxin); /* not really, but adopted */

xiong_zuxin.marry(wang_fuying);
wang_fuying.give_birth(xiong_yuwen);
wang_fuying.give_birth(xiong_yuwu, xiong_yuwen);

xiong_yuwen.marry(tian_aigu);
tian_aigu.give_birth(xiong_qiushi);

xiong_yuwu.marry(chen_juan);
chen_juan.give_birth(xiong_kaiyuan);


/* ################ 王氏 ################ */

/* 人员 */

person wang_rixi      = person.person(true,  "王", "日熙",       question, question);
person wang_rixi_wife = person.person(false,  unknown, unknown,       question, question);
person wang_yuenan    = person.person(true,  "王", "月南",       question, question);
person wang_yuenan_wife = person.person(false,  unknown, unknown,       question, question);
person wang_yueying   = person.person(false, "王", "月英",       question, question);
person wang_yuehai    = person.person(true,  "王", "月海",       question, question);
person wang_yueping   = person.person(true,  "王", "月平",       question, "1948");
person wang_reyang    = person.person(true,  "王", "□□",       question, question); // 王月英的丈夫，也姓王，二羊村
person han_xinxiu     = person.person(false, "韩", "新秀",       "1915.09.27", "1991.08.18");
person shi_shixiang   = person.person(true,  "石", "世祥",       question, "1974");   // 韩新秀的第二个丈夫，和韩无后
person wang_liansheng = person.person(true,  "王", "连生",       question, question);
person wang_liansheng_wife = person.person(false,  unknown, unknown,       question, question);
person wang_chuanxi   = person.person(true,  "王", "传熙",       "1936",   "");
person zhou_yinlan    = person.person(false, "周", "引兰",       question, "");
person wang_fuen      = person.person(true,  "王", "福恩",       question, "");
person sheng_guoying  = person.person(false, "盛", "国银",       question, "");
person wang_qilin     = person.person(true,  "王", "齐林",       question, question);
person shen_yulan     = person.person(false, "沈", "玉兰",       question, unknown);
person wang_qifa      = person.person(true,  "王", "齐发",       question, "");
person wang_lachun    = person.person(true,  "王", "腊春",       question, "2005");
person wang_silin     = person.person(true,  "王", "四林",       question, "");
person wang_chunqing  = person.person(true,  "王", "春清",       "1958",   "", nick_name="春清");
person wang_yunxiang  = person.person(false, "王", "运香",       "1961",   "");
person wang_yuzhen    = person.person(false, "王", "先秀",       "1963",   "", nick_name="玉珍");
person zhou_chijun    = person.person(true,  "周", "赤军",       "1963",   "");
person wang_yunzhen   = person.person(false, "王", "云珍",       "1968",   "", nick_name="云珍");
person wang_xiankui   = person.person(true,  "王", "先奎",       "1978",   "", nick_name="想清");
person hu_aiqiong     = person.person(false, "胡", "爱琼",       question, "");
person shi_hebin      = person.person(true,  "石", "和彬",       "1965",   "", nick_name="大兵");
person deng_quanbin   = person.person(false, "邓", "全斌",       question, "");
person wang_qisong    = person.person(true,  "王", "齐松",       "1968",   "", nick_name="小兵");
person tao_weijun     = person.person(false, "陶", "卫军",       question, "");
person wang_qiyu      = person.person(true,  "王", "齐禹",       "1972.1.14",   "", nick_name="三兵");
person wang_haiyan    = person.person(true,  "王", "海燕",       question, "");
person wang_dahong    = person.person(false, "王", "□□",       question, "", nick_name="大红");
person wang_xiaohong  = person.person(false, "王", "□□",       question, "", nick_name="小红");
person wang_cuie      = person.person(false, "王", "翠娥",       "1985",   "");
person wang_cong      = person.person(false, "王", "聪",         "1987",   "");
person wang_li        = person.person(false, "王", "丽",         "1990",   "");
person wang_gongbao   = person.person(true,  "王", "功宝",       "1995",   "");
person zhou_xiang     = person.person(true,  "周", "祥",         "1991",   "", nick_name="qiangqiang");
person shi_kanming    = person.person(true,  "石", "衎明",       "1996",   "", nick_name="mingming");
person wang_yingjun   = person.person(false, "王", "滢珺",       "1996.11.01",   "", nick_name="linlin");

/* 关系 */

wang_rixi.marry(wang_rixi_wife);
wang_rixi_wife.give_birth(wang_yuenan);
wang_rixi_wife.give_birth(wang_yueying, wang_yuenan);
wang_rixi_wife.give_birth(wang_yuehai, wang_yueying);
wang_rixi_wife.give_birth(wang_yueping, wang_yuehai);

wang_yuenan.marry(wang_yuenan_wife);
wang_yuenan_wife.give_birth(wang_liansheng);

wang_liansheng.marry(wang_liansheng_wife);
wang_liansheng_wife.give_birth(wang_qilin);
wang_liansheng_wife.give_birth(wang_qifa, wang_qilin);
wang_liansheng_wife.give_birth(wang_lachun, wang_qifa);
wang_liansheng_wife.give_birth(wang_silin, wang_lachun);

wang_qilin.marry(shen_yulan);
shen_yulan.give_birth(wang_dahong);
shen_yulan.give_birth(wang_xiaohong, wang_dahong);
shen_yulan.give_birth(wang_haiyan, wang_xiaohong);

wang_yueying.marry(wang_reyang);
wang_yueying.give_birth(wang_chuanxi);

wang_chuanxi.marry(zhou_yinlan);
zhou_yinlan.give_birth(wang_chunqing);
zhou_yinlan.give_birth(wang_yuzhen, wang_chunqing);
zhou_yinlan.give_birth(wang_yunzhen, wang_yuzhen);
zhou_yinlan.give_birth(wang_xiankui, wang_yunzhen);

wang_chunqing.marry(wang_yunxiang);
wang_yunxiang.give_birth(wang_cuie);
wang_yunxiang.give_birth(wang_cong, wang_cuie);
wang_yunxiang.give_birth(wang_li, wang_cong);
wang_yunxiang.give_birth(wang_gongbao, wang_li);

wang_yuzhen.marry(zhou_chijun);
wang_yuzhen.give_birth(zhou_xiang);

wang_xiankui.marry(hu_aiqiong);

wang_yueping.marry(uni=false, han_xinxiu);
han_xinxiu.marry(uni=false, wang_yueping, shi_shixiang);
han_xinxiu.give_birth(wang_fuen);
han_xinxiu.give_birth(wang_fuying, wang_fuen);

wang_fuen.marry(sheng_guoying);
sheng_guoying.give_birth(shi_hebin);
sheng_guoying.give_birth(wang_qisong, shi_hebin);
sheng_guoying.give_birth(wang_qiyu, wang_qisong);

shi_hebin.marry(deng_quanbin);
deng_quanbin.give_birth(shi_kanming);

wang_qisong.marry(tao_weijun);
tao_weijun.give_birth(wang_yingjun);


/* ################ 赵氏 ################ */

/* 人员 */

person zhao_tonghan   = person.person(true,  "赵", "同汉",       question, question);
person chen_xx        = person.person(false, "陈", "□□",       question, question);
person zhao_fu_x      = person.person(false, "赵", "复□",       "1932",   "2004");
person zhao_fuxiang   = person.person(true,  "赵", "复祥",       "1934",   "");
person qin_qianan     = person.person(false, "秦", "前安",       question, "");
person zhao_fulong    = person.person(true,  "赵", "复龙",       "1940",   "");
person zhao_fulong_wife    = person.person(false,  unknown, unknown,       question,   "");
person zhao_fucai     = person.person(true,  "赵", "复才",       "1944",   "");
person zhao_xiangui   = person.person(false, "赵", "贤贵",       question, "");
person liu_jincheng   = person.person(true,  "柳", "金成",       question, "");
person zhao_xianchun  = person.person(true,  "赵", "贤春",       question, "");
person zhao_xianchun_wife  = person.person(false,  unknown, unknown,      question, "");
person zhao_xianbing  = person.person(true,  "赵", "贤兵",       question, "");
person zhao_xianbing_wife  = person.person(false,  unknown, unknown,      question, "");
person zhao_xianhong  = person.person(false, "赵", "贤红",       question, "");
person zhao_x0        = person.person(false, "赵", "贤□",       question, "");
person zhao_xianneng  = person.person(true,  "赵", "贤能",       question, "");
person zhao_xianneng_wife  = person.person(false,  unknown, unknown,      question, "");
person zhao_xianbing2 = person.person(true,  "赵", "贤兵",       question, "");
person zhao_xianbing2_wife  = person.person(false,  unknown, unknown,      question, "");
person liu_jun        = person.person(true,  "柳", "军",         question, "");
person zhao_liang     = person.person(true,  "赵", "亮",         question, "");
person zhao_rong      = person.person(false, "赵", "蓉",         question, "");
person zhao_na        = person.person(false, "赵", "娜",         question, "");
person zhao_heng      = person.person(true,  "赵", "恒",         question, "");
person zhao_x1        = person.person(false, "赵", "□□",       question, "");
person zhao_x2        = person.person(false, "赵", "□□",       question, "");
person zhao_x3        = person.person(false, "赵", "□□",       question, "");

/* 关系 */
zhao_tonghan.marry(chen_xx);
chen_xx.give_birth(zhao_fu_x);
chen_xx.give_birth(zhao_fuxiang, zhao_fu_x);
chen_xx.give_birth(zhao_fulong, zhao_fuxiang);
chen_xx.give_birth(zhao_fucai, zhao_fulong);

zhao_fuxiang.marry(qin_qianan);
qin_qianan.give_birth(zhao_xiangui);
qin_qianan.give_birth(zhao_xianchun, zhao_xiangui);
qin_qianan.give_birth(zhao_xianbing, zhao_xianchun);
qin_qianan.give_birth(zhao_xianhong, zhao_xianbing);

zhao_fulong.marry(zhao_fulong_wife);
zhao_fulong_wife.give_birth(zhao_x0);
zhao_fulong_wife.give_birth(zhao_xianneng, zhao_x0);
zhao_fulong_wife.give_birth(zhao_xianbing2, zhao_xianneng);

zhao_xiangui.marry(liu_jincheng);
zhao_xiangui.give_birth(liu_jun);

zhao_xianchun.marry(zhao_xianchun_wife);
zhao_xianchun_wife.give_birth(zhao_liang);
zhao_xianchun_wife.give_birth(zhao_rong, zhao_liang);

zhao_xianbing.marry(zhao_xianbing_wife);
zhao_xianbing_wife.give_birth(zhao_na);
zhao_xianbing_wife.give_birth(zhao_heng, zhao_na);

zhao_xianneng.marry(zhao_xianneng_wife);
zhao_xianneng_wife.give_birth(zhao_x1);
zhao_xianneng_wife.give_birth(zhao_x2, zhao_x1);

zhao_xianbing2.marry(zhao_xianbing2_wife);
zhao_xianbing2_wife.give_birth(zhao_x3);

zhao_fucai.marry(wang_fuying);
wang_fuying.give_birth(xiong_yuwen);

/* ################ 陈氏 ################ */

/* 人员 */

person chen_baixin    = person.person(true,  "陈", "百新",       "1911",   question);
person zhang_juying   = person.person(false, "张", "菊英",       "1911",   "1987");
person chen_lifeng    = person.person(true,  "陈", "立丰",       "1931",   "2004");
person wang_yumei     = person.person(false, "王", "玉梅",       "1937",   "");
person chen_yufeng    = person.person(false, "陈", "玉丰",       question, "");
person liu_jichang    = person.person(true,  "刘", "继昌",       question, "");
person chen_lifeng2   = person.person(true,  "陈", "利丰",       question, question);
person chen_lifeng2_  = person.person(false, "□", "□□",       question, "");  /* chen_lifeng2 的妻子 */
person chen_qingfeng  = person.person(true,  "陈", "庆丰",       "1951",   "");
person wang_xiuqin    = person.person(false, "王", "秀琴",       question, "");
person chen_lin       = person.person(true,  "陈", "林",         question, "");
person lv_x           = person.person(false, "吕", "□□",       question, "");
person chen_jie       = person.person(true,  "陈", "杰",         "1957",   "");
person qin_xiaojie    = person.person(false, "秦", "晓杰",       "1961",   "");
person chen_min       = person.person(true,  "陈", "敏",         "1959",   "");
person hu_rong        = person.person(false, "胡", "荣",         "1963",   "");
person chen_yan       = person.person(false, "陈", "艳",         "1961",   "");
person zhang_qiang    = person.person(true,  "张", "强",         question, "");
person liu_geyao      = person.person(false, "刘", "戈瑶",       question, "");
person chen_kai       = person.person(true,  "陈", "凯",         "1976",   "");
person chen_kai_wife  = person.person(false,  unknown, unknown,      question, "");
person chen_yong      = person.person(true,  "陈", "勇",         question, "");
person chen_lei       = person.person(true,  "陈", "雷",         "1986",   "2005");
person chen_jialiang  = person.person(true,  "陈", "佳亮",       "1988",   "");
person zhang_hongtao  = person.person(true,  "张", "洪涛",       "1988",   "");
person chen_xurui     = person.person(false, "陈", "旭蕊",       question, "");

/* 关系 */

chen_baixin.marry(zhang_juying);
zhang_juying.give_birth(chen_lifeng);
zhang_juying.give_birth(chen_yufeng, chen_lifeng);
zhang_juying.give_birth(chen_lifeng2, chen_yufeng);
zhang_juying.give_birth(chen_qingfeng, chen_lifeng2);
zhang_juying.give_birth(chen_lin, chen_qingfeng);

chen_lifeng.marry(wang_yumei);
wang_yumei.give_birth(chen_jie);
wang_yumei.give_birth(chen_min, chen_jie);
wang_yumei.give_birth(chen_yan, chen_min);
wang_yumei.give_birth(chen_juan, chen_yan);

chen_jie.marry(qin_xiaojie);
qin_xiaojie.give_birth(chen_lei);

chen_min.marry(hu_rong);
hu_rong.give_birth(chen_jialiang);

chen_yan.marry(zhang_qiang);
chen_yan.give_birth(zhang_hongtao);

chen_yufeng.marry(liu_jichang);
chen_yufeng.give_birth(liu_geyao);   /* not really, but adopted */

chen_lifeng2.marry(chen_lifeng2_);

chen_qingfeng.marry(wang_xiuqin);
wang_xiuqin.give_birth(chen_kai);

chen_kai.marry(chen_kai_wife);
chen_kai_wife.give_birth(chen_xurui);

chen_lin.marry(lv_x);
lv_x.give_birth(chen_yong);





/* ######################################################################## */
//
//  画图
//
/* ######################################################################## */

picture xiong=draw_tree(xiong_jiasong);
//add_time_stamp(xiong);
attach(xiong.fit(), (0,0), se);
shipout("xiong");
erase(currentpicture);


xiong_zuxin.marry(wang_fuying);      // 使 王福英 的丈夫 显示为 熊祖鑫
picture wang = draw_tree(wang_rixi);
//add_time_stamp(wang);
attach(wang.fit(), (0,0), se);
shipout("wang");
erase(currentpicture);

picture han = draw_tree(han_xinxiu);
attach(han.fit(), (0,0), se);
shipout("han");
erase(currentpicture);

picture chen = draw_tree(chen_baixin);
//add_time_stamp(chen);
attach(chen.fit(), (0, 0), se);
shipout("chen");
erase(currentpicture);

//zhao_fucai.marry(wang_fuying);
picture zhao = draw_tree(zhao_tonghan);
//add_time_stamp(zhao);
attach(zhao.fit(), (0, 0), se);
shipout("zhao");
erase(currentpicture);
