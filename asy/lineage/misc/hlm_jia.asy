import "lineage.asy" as lineage;




/* ######################################################################## */
//
//  红楼梦贾府
//
/* ######################################################################## */

person male_unknown   = person(true,  unknown, blank, question, blank);
person female_unknown = person(false, unknown, blank, question, blank);



person mou              = clone(male_unknown);
person yan              = person(true,  "", "演",       question, question, hao="宁国公"); 
person yuan             = person(true,  "", "源",       question, question, hao="荣国公"); 
person daihua           = person(true,  "", "代化",       question, question); 
person daihua2          = person(true,  "", unknown2, question, blank);
person daihua3          = person(true,  "", unknown2, question, blank);
person daihua4          = person(true,  "", unknown2, question, blank);
person fu               = person(true,  "", "敷",       question, question); 
person jing             = person(true,  "", "敬",       question, question); 
person zhen             = person(true,  "", "珍",       question, question); 
person xichun           = person(false,  "", "惜春",       question, question); 

/* 贾珍妻子 */
person jia_zhen_wife0   = person(false,  "", unknown,       question, question);  // 原配
person jia_zhen_wife1   = person(false, "", "尤氏", question, question);
person jia_zhen_wife2   = person(false, "", "佩凤", question, question);
person jia_zhen_wife3   = person(false, "", "偕鸾", question, question);
person jia_zhen_wife4   = person(false, "", "文花", question, question);

person rong             = person(true,  "", "蓉",       question, question); //, notes="为贾珍原配所出。"); 
person rong_wife0       = person(false, "秦", "可卿", question, question);
person rong_wife1       = person(false, "", "许氏", question, question);

person mou2              = clone(male_unknown);
person mou3              = clone(male_unknown);
person qiang             = person(true,  "", "蔷",       question, question); //, notes="为贾珍养子"); 


// 荣国府
person daishan           = person(true,  "", "代善",       question, question); 
person daishan2           = person(true,  "", unknown2,       question, question, notes="为荣府近派亲戚。"); 
person jiamu             = person(false, "史", "太君",       question, question, hao="贾母"); 

person she               = person(true,  "", "赦",       question, question); 
person zheng             = person(true,  "", "政",       question, question); 
person min               = person(false, "", "敏",       question, question); 

person jia_she_wife0     = person(false,  "", unknown,       question, question);  // 原配
person jia_she_wife1     = person(false,  "邢", "夫人",       question, question);   // , notes="和贾赦无后。"
person jia_she_wife2     = person(false,  "", unknown,       question, question);  
person jia_she_wife3     = person(false,  "", unknown,       question, question);  
person jia_she_wife4     = person(false,  "", "嫣红",       question, question);  
person jia_she_wife5     = person(false,  "", "翠云",       question, question);  
person jia_she_wife6     = person(false,  "", "娇红",       question, question);  

person lian              = person(true,  "", "琏",       question, question); //, notes="为贾赦原配所出。"); 
person yingchun          = person(false,  "", "迎春",       question, question);  
person cong              = person(true,  "", "琮",       question, question); 

person jia_lian_wife0    = person(false,  "王", "熙凤",       question, question);  // 原配
person jia_lian_wife1    = person(false,  "尤", "二姐",       question, question);
person jia_lian_wife2    = person(false,  "", "秋桐",       question, question); 
person jia_lian_wife3    = person(false,  "", "平儿",       question, question); 

person jiaojie          = person(false,  "", "巧姐",       question, question); 
person zhou_xiucai       = person(true,  "周", "秀才",       question, question); 


person sun_shaozu       = person(true,  "孙", "绍祖",       question, question); 

person jia_zheng_wife0     = person(false,  "王", "夫人",       question, question);  // 原配
person jia_zheng_wife1     = person(false,  "赵", "姨娘",       question, question); //, notes="探春和贾环为其所出。");  
person jia_zheng_wife2     = person(false,  "周", "姨娘",       question, question); //, notes="和贾政无后。");  

person zhu              = person(true,  "", "珠",       question, question); 
person yuanchun         = person(false,  "", "元春",       question, question); 
person baoyu              = person(true,  "", "宝玉",       question, question); 
person tanchun         = person(false,  "", "探春",       question, question); 
person huan              = person(true,  "", "环",       question, question); 
person huangdi              = person(true,  "", "皇帝",       question, question); 

person liwan         = person(false,  "李", "纨",       question, question); 
person lan              = person(true,  "", "蘭",       question, question); 
person xue_baochai      = person(false,  "薛", "宝钗",       question, question); 
person zhou_gongzi       = person(true,  "周", "公子",       question, question); 

person lin_ruhai       = person(true,  "林", "如海",       question, question); 
person lin_daiyu       = person(false,  "林", "黛玉",       question, question); 



// 非嫡派宗族
// 贾菌
person mou4 = clone(male_unknown); // daishan2 之子
person mou5 = clone(male_unknown);
person loushi = person(false, "", "娄氏", question, question);
person jun = person(true, "", "菌", question, question);

person mou6 = person(true, "", unknown, question, question, notes="为贾府非嫡派宗族。");  // 代儒父
person dairu = person(true, "", "代儒", question, question);
person mou7 = clone(male_unknown);  // 代儒子
person rui = person(true, "", "瑞", question, question);


person mou8 = person(true, "", unknown, question, question, notes="为贾府同门旁支。");  // 贾芸祖先
person mou9 = person(true, unknown, unknown, question, question); 
person mou10 = clone(male_unknown); 
person mou11 = clone(male_unknown); 
person yun_mom = person(false, "", "五嫂子", question, question); // 贾芸母亲
person yun = person(true, "", "芸", question, question);

/* 
 * 关系 
 */

// 宁国府

mou.has(yan, yuan, mou6, mou8);
yan.has(daihua, daihua2, daihua3, daihua4);
daihua.has(fu, jing);

daihua4.has(mou2);
mou2.has(mou3);
mou3.has(qiang);

jing.has(zhen, xichun);
zhen.marry(uni=false, jia_zhen_wife0, jia_zhen_wife1, jia_zhen_wife2, jia_zhen_wife3, jia_zhen_wife4);
jia_zhen_wife0.give_birth(rong, dad=zhen);
rong.marry(uni=false, rong_wife0, rong_wife1);


// 荣国府
yuan.has(daishan, daishan2);
daishan.marry(jiamu);
jiamu.give_birth(she);
jiamu.give_birth(zheng, she);
jiamu.give_birth(min, zheng); 
she.marry(uni=false, jia_she_wife0, jia_she_wife1, jia_she_wife2, jia_she_wife3, jia_she_wife4, jia_she_wife5, jia_she_wife6);
jia_she_wife0.give_birth(lian, dad=she);
jia_she_wife0.give_birth(yingchun, lian, dad=she);
jia_she_wife3.give_birth(cong, yingchun, dad=she);

lian.marry(uni=false, jia_lian_wife0, jia_lian_wife1, jia_lian_wife2, jia_lian_wife3);
jia_lian_wife0.give_birth(jiaojie, dad=lian);

jiaojie.marry(zhou_xiucai);

yingchun.marry(sun_shaozu);


zheng.marry(uni=false, jia_zheng_wife0, jia_zheng_wife1, jia_zheng_wife2);
jia_zheng_wife0.give_birth(zhu, dad=zheng);
jia_zheng_wife0.give_birth(yuanchun, zhu, dad=zheng);
jia_zheng_wife0.give_birth(baoyu, yuanchun, dad=zheng);
jia_zheng_wife0.give_birth(tanchun, baoyu, dad=zheng);  // 实为赵姨娘所出
jia_zheng_wife0.give_birth(huan, tanchun, dad=zheng);  // 实为赵姨娘所出


zhu.marry(liwan);
liwan.give_birth(lan);
yuanchun.marry(huangdi);
baoyu.marry(xue_baochai);
tanchun.marry(zhou_gongzi);

min.marry(lin_ruhai);
min.give_birth(lin_daiyu);

// 贾菌
daishan2.has(mou4);
mou4.has(mou5);
mou5.marry(loushi);
loushi.give_birth(jun);


// 贾代儒、贾瑞
mou6.has(dairu);
dairu.has(mou7);
mou7.has(rui);

// 贾芸
mou8.has(mou9);
mou9.has(mou10);
mou10.has(mou11);
mou11.marry(yun_mom);
yun_mom.give_birth(yun);



g_debug = false;
g_kid_h_gap *= 1.6;  // 调整两辈之间间距
name_pen_female = linewidth(0.1) + deepred + fontsize(g_glyph_width);
shipout_lineage(mou, "hlm_jia", "贾府人物关系", "参考人文《红楼梦》1996年第二版等编制于2016年4月19日。", 15cm, pack=true);

