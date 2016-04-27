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
person xichun           = person(false,  "", "惜春~\underline{8}",       question, question); 

/* 贾珍妻子 */
person jia_zhen_wife0   = person(false,  "", unknown,       question, question);  // 原配
person jia_zhen_wife1   = person(false, "", "尤氏", question, question);
person jia_zhen_wife2   = person(false, "", "佩凤", question, question);
person jia_zhen_wife3   = person(false, "", "偕鸾", question, question);
person jia_zhen_wife4   = person(false, "", "文花", question, question);

person rong             = person(true,  "", "蓉",       question, question); //, notes="为贾珍原配所出。"); 
person rong_wife0       = person(false, "秦", "可卿~\underline{12}", question, question); //, order="12");
person rong_wife1       = person(false, "", "许氏", question, question);

// 贾蔷: 梨香院管优伶
person mou2              = clone(male_unknown);
person mou3              = clone(male_unknown);
person qiang             = person(true,  "", "蔷",       question, question ,notes="第九回称其“亦系宁府中之正派玄孙”。"); 


// 荣国府
person daishan           = person(true,  "", "代善",       question, question); 
person daishan2           = person(true,  "", unknown2,       question, question,  di=false);  // notes="为荣府近派亲戚。",
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
person yingchun          = person(false,  "", "迎春~\underline{7}",       question, question);  
person cong              = person(true,  "", "琮",       question, question); 

person jia_lian_wife0    = person(false,  "王", "熙凤~\underline{9}",       question, question); //, order="9");  // 原配
person jia_lian_wife1    = person(false,  "尤", "二姐",       question, question);
person jia_lian_wife2    = person(false,  "", "秋桐",       question, question); 
person jia_lian_wife3    = person(false,  "", "平儿",       question, question); 

person qiaojie          = person(false,  "", "巧姐~\underline{10}",       question, question);//, order="10"); 
person zhou_xiucai       = person(true,  "周", "秀才",       question, question); 


person sun_shaozu       = person(true,  "孙", "绍祖",       question, question); // 中山狼

person jia_zheng_wife0     = person(false,  "王", "夫人",       question, question);  // 原配
person jia_zheng_wife1     = person(false,  "赵", "姨娘",       question, question); //, notes="探春和贾环为其所出。");  
person jia_zheng_wife2     = person(false,  "周", "姨娘",       question, question); //, notes="和贾政无后。");  

person zhu              = person(true,  "", "珠",       question, question); 
person yuanchun         = person(false,  "", "元春~\underline{3}",       question, question); //, order="3"); 
person baoyu              = person(true,  "", "宝玉",       question, question); 
person tanchun         = person(false,  "", "探春~\underline{4}",       question, question); //, order="4"); 
person huan              = person(true,  "", "环",       question, question); 
person huangdi              = person(true,  "", "皇帝",       question, question); 

person liwan         = person(false,  "李", "纨~\underline{11}",       question, question); //, order="11"); 
person lan              = person(true,  "", "蘭",       question, question); 
person xue_baochai      = person(false,  "薛", "宝钗~\underline{1}",       question, question); //, order="1"); 
person zhou_gongzi       = person(true,  "周", "公子",       question, question); 

person lin_ruhai       = person(true,  "林", "如海",       question, question); 
person lin_daiyu       = person(false,  "林", "黛玉~\underline{2}",       question, question); //, order="2"); 



// 非嫡派宗族
// 贾菌: 第九回"亦系荣国府近派的重孙"
person mou4 = person(true,  "", unknown, question, blank); // daishan2 之子
person mou5 = clone(male_unknown);
person loushi = person(false, "", "娄氏", question, question);
person jun = person(true, "", "菌", question, question, notes="第九回称其“亦系荣国府近派的重孙”。");

// 贾瑞
person mou6 = person(true, "", unknown, question, question, di=false);  // 代儒父, notes="为贾府非嫡派宗族。"
person dairu = person(true, "", "代儒", question, question);
person mou7 = clone(male_unknown);  // 代儒子
person rui = person(true, "", "瑞", question, question);

// 贾芸: 大花园管种树栽花
person mou8 = person(true, "", unknown, question, question, di=false);  // 贾芸祖先
person mou9 = person(true, unknown, unknown, question, question); 
person mou10 = clone(male_unknown); 
person mou11 = clone(male_unknown); 
person yun_mom = person(false, "", "五嫂子", question, question); // 贾芸母亲
person yun = person(true, "", "芸", question, question, notes="贾府姻亲，第二十三回中称其为“西廊下五嫂子的儿子”，在第二十四回认宝玉为父。");

// 贾芹: 铁槛庙管小和尚小尼姑
person mou12 = person(true, "", unknown, question, question, di=false);  // 贾芹祖先
person mou13 = person(true, unknown, unknown, question, question); 
person mou14 = clone(male_unknown); 
person mou15 = clone(male_unknown); 
person qin_mom = person(false, "", "周氏", question, question); // 贾芹母亲:第23回"坐轿子来求凤姐"。
person qin = person(true, "", "芹", question, question, notes="第二十四回称其为“你们(贾芸)三房里的老四”。");

// 贾雨村
person mou16 = person(true, "", unknown, question, question, di=false);  
person mou17 = person(true, unknown, unknown, question, question); 
person mou18 = clone(male_unknown); 
person yuchun = person(true, "", "雨村", question, question, notes="即贾化，第二回称“若论荣国一支，却是同谱”，第三回“拿着宗侄的名帖，至荣府的门前投了”。");
person yuchun_wife = person(false,  "", unknown,       question, question);  // 原配
person jiaoxin = person(false, "", "娇杏", question, question);

/* 
 * 关系 
 */

// 宁国府

mou.has(yan, yuan, mou12, mou8, mou6, mou16);
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
jia_lian_wife0.give_birth(qiaojie, dad=lian);

//qiaojie.marry(zhou_xiucai); // 后40回
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

// tanchun.marry(zhou_gongzi); // 后40回

min.marry(lin_ruhai);
min.give_birth(lin_daiyu);

// 贾菌
daishan2.has(mou4);
mou4.has(mou5);
mou5.marry(loushi);
loushi.give_birth(jun);

// 贾芹
mou12.has(mou13);
mou13.has(mou14);
mou14.has(mou15);
mou15.marry(qin_mom);
qin_mom.give_birth(qin);


// 贾芸
mou8.has(mou9);
mou9.has(mou10);
mou10.has(mou11);
mou11.marry(yun_mom);
yun_mom.give_birth(yun);

// 贾代儒、贾瑞
mou6.has(dairu);
dairu.has(mou7);
mou7.has(rui);

// 贾雨村
mou16.has(mou17);
mou17.has(mou18);
mou18.has(yuchun);
yuchun.marry(uni=false, yuchun_wife, jiaoxin);



g_debug = false;
g_kid_h_gap *= 1.6;  // 调整两辈之间间距
name_pen_female = linewidth(0.1) + deepred + fontsize(g_glyph_width);
shipout_lineage(mou, "hlm_jia", "贾府人物关系简图", "虚线表示同宗旁支；带下划线的数字表示十二正钗的序号(不含史湘云~\underline{5}和妙玉~\underline{6})。参考人文1996年第二版编制于2016年4月27日。", 15cm, pack=true);

