import "lineage.asy" as lineage;




/* ######################################################################## */
//
//  赵国世系
//
/* ######################################################################## */

person male_unknown   = person(true,  unknown, blank, question, blank);
person female_unknown = person(false, unknown, blank, question, blank);
person ellipse        = person(false, "", "$\cdots$", question, question); // make it female



person zao_fu           = person(true,  "", "造父",       question, question);
person zao_fu_wife      = person(false, unknown, unknown2, question, question);
person ellipse1         = clone(ellipse);
//ellipse1.given_name += "(隔六世)";
person yan_fu           = person(true,  "", "奄父",       question, question); // 造父六世孙
person yan_fu_wife      = clone(female_unknown);
person shu_dai          = person(true,  "", "叔代",       question, question);
person shu_dai_wife     = clone(female_unknown);
person ellipse2         = clone(ellipse);
//ellipse2.given_name += "(隔五世)";
person gong_ming        = person(true,  "", "公明",       question, question);
person gong_ming_wife   = clone(female_unknown);
person zhao_su          = person(true,  "", "夙",       question, question);
person zhao_su_wife     = clone(female_unknown);
person zhao_gongmeng    = person(true,  "", "共孟",       question, question);
person zhao_gongmeng_wife = clone(female_unknown);
person zhao_shu_wife    = clone(female_unknown);
person zhao_chuan       = person(true,  "", "穿",       question, question); 
person zhao_chuan2      = clone(male_unknown); // 穿弟
person zhao_chuan_wife  = clone(female_unknown);
person zhao_zhan0       = clone(male_unknown); // 旃兄
person zhao_zhan        = person(true,  "", "旃",       question, question); 
person zhao_zhan_wife   = clone(female_unknown);
person zhao_sheng       = person(true,  "", "胜",       question, question); 
person zhao_sheng_wife  = clone(female_unknown);
person zhao_wu          = person(true,  "", "午",       question, "前497"); 
person zhao_wu2         = clone(male_unknown); // 午弟
person zhao_wu_wife     = clone(female_unknown);
person zhao_wu2_wife    = clone(female_unknown);
person zhao_ji          = person(true,  "", "稷",       question, question); 
person zhao_wu2_kid     = clone(male_unknown);
person zhao_wu2_kid_wife = clone(female_unknown);
person zhao_chao        = person(true,  "", "朝",       question, question); 



/* 赵衰以下 */
person zhao_shuai       = person(true,  "", "衰",       question, "前622"); // he has more than one wife, actually
person zhao_shuai_wife  = clone(female_unknown);
person zhao_dun         = person(true,  "", "盾",       question, "前601");
person zhao_tong        = person(true,  "", "同",       question, "前583");
person zhao_kuo         = person(true,  "", "括",       question, "前583");
person zhao_yingqi      = person(true,  "", "婴齐",       question, question);
person zhao_dun_wife    = clone(female_unknown);
person zhao_shuo        = person(true,  "", "朔",       question, "前597");
person zhao_shuo_wife   = clone(female_unknown);
person zhao_WU          = person(true,  "", "武",       question, "前541"); // 赵氏孤儿
person zhao_WU_wife     = clone(female_unknown);
person zhao_huo         = person(true,  "", "或",       question, question); 
person zhao_cheng       = person(true,  "", "成",       question, "前518"); 
person zhao_cheng_wife  = clone(female_unknown);
person zhao_yang        = person(true,  "", "鞅",       question, "前476"); 
person zhao_yang_wife   = clone(female_unknown);


/* 关系 */
zao_fu.marry(zao_fu_wife);
zao_fu_wife.give_birth(ellipse1);
ellipse1.marry(male_unknown);
ellipse1.give_birth(yan_fu);
yan_fu.marry(yan_fu_wife);
yan_fu_wife.give_birth(shu_dai);
shu_dai.marry(shu_dai_wife);
shu_dai_wife.give_birth(ellipse2);
ellipse2.marry(male_unknown);
ellipse2.give_birth(gong_ming);
gong_ming.marry(gong_ming_wife);
gong_ming_wife.give_birth(zhao_su);
gong_ming_wife.give_birth(zhao_shuai, zhao_su);
zhao_su.marry(zhao_su_wife);
zhao_su_wife.give_birth(zhao_gongmeng);
zhao_gongmeng.marry(zhao_gongmeng_wife);
zhao_gongmeng_wife.give_birth(zhao_chuan);
zhao_gongmeng_wife.give_birth(zhao_chuan2, zhao_chuan);
zhao_chuan.marry(zhao_chuan_wife);
zhao_chuan_wife.give_birth(zhao_zhan0);
zhao_chuan_wife.give_birth(zhao_zhan, zhao_zhan0);
zhao_zhan.marry(zhao_zhan_wife);
zhao_zhan_wife.give_birth(zhao_sheng);
zhao_sheng.marry(zhao_sheng_wife);
zhao_sheng_wife.give_birth(zhao_wu);
zhao_sheng_wife.give_birth(zhao_wu2, zhao_wu);
zhao_wu.marry(zhao_wu_wife);
zhao_wu2.marry(zhao_wu2_wife);
zhao_wu_wife.give_birth(zhao_ji);
zhao_wu2_wife.give_birth(zhao_wu2_kid);
zhao_wu2_kid.marry(zhao_wu2_kid_wife);
zhao_wu2_kid_wife.give_birth(zhao_chao);

// 赵衰以下
zhao_shuai.marry(zhao_shuai_wife);
zhao_shuai_wife.give_birth(zhao_dun);
zhao_shuai_wife.give_birth(zhao_tong, zhao_dun);
zhao_shuai_wife.give_birth(zhao_kuo, zhao_tong);
zhao_shuai_wife.give_birth(zhao_yingqi, zhao_kuo);
zhao_dun.marry(zhao_dun_wife);
zhao_dun_wife.give_birth(zhao_shuo);
zhao_shuo.marry(zhao_shuo_wife);
zhao_shuo_wife.give_birth(zhao_WU);
zhao_WU.marry(zhao_WU_wife);
zhao_WU_wife.give_birth(zhao_cheng);
zhao_cheng.marry(zhao_cheng_wife);
zhao_cheng_wife.give_birth(zhao_yang);


g_kid_h_gap *= .6;  // 缩小两辈之间间距
shipout_lineage(zao_fu, /* new person[]{gong_ming}, */ "zhao", "赵国世系表", "参考\underline{https://zh.wikipedia.org/wiki/趙國君主世系圖}编制。", 10cm);


