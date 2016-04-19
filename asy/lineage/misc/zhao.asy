import "lineage.asy" as lineage;




/* ######################################################################## */
//
//  赵国世系
//
/* ######################################################################## */

person male_unknown   = person(true,  unknown, blank, question, blank);
person female_unknown = person(false, unknown, blank, question, blank);
person ellipse        = person(false, "", "$\cdots$", question, question); // make it female



person zao_fu           = person(true,  "", "造父",       question, question, notes="《史记·趙世家》: “季勝生孟增。孟增幸於周成王，是為宅皋狼。皋狼生衡父，衡父生造父。造父幸於周繆王。造父取驥之乘匹，與桃林盜驪、驊騮、綠耳，獻之繆王。繆王使造父御，西巡狩，見西王母，樂之忘歸。而徐偃王反，繆王日馳千里馬，攻徐偃王，大破之。乃賜造父以趙城，由此為趙氏。”按赵城即今山西省洪洞县赵城镇。");
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
person zhao_su          = person(true,  "", "夙",       question, question, hao="耿氏");
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
person zhao_shuai       = person(true,  "", "衰",       question, "前622", hao="成季", notes="《史记·趙世家》: “趙衰卜事晉獻公及諸公子，莫吉；卜事公子重耳，吉，即事重耳。重耳以驪姬之亂亡奔翟，趙衰從。翟伐廧咎如，得二女，翟以其少女妻重耳，長女妻趙衰而生盾。初，重耳在晉時，趙衰妻亦生趙同、趙括、趙嬰齊。趙衰從重耳出亡，凡十九年，得反國。重耳為晉文公，趙衰為原大夫，居原，任國政 $\cdots$ 趙衰既反晉，晉之妻固要迎翟妻，而以其子盾為適嗣，晉妻三子皆下事之。晉襄公之六年，而趙衰卒，謚為成季。”");
person zhao_shuai_wife  = clone(female_unknown);
person zhao_dun         = person(true,  "", "盾",       question, "前601", hao="宣子");
person zhao_tong        = person(true,  "", "同",       question, "前583", hao="原氏");
person zhao_kuo         = person(true,  "", "括",       question, "前583", hao="屏氏");
person zhao_yingqi      = person(true,  "", "婴齐",       question, question, hao="楼氏");
person zhao_dun_wife    = clone(female_unknown);
person zhao_shuo        = person(true,  "", "朔",       question, "前597", hao="庄子");
person zhao_shuo_wife   = person(false, "", "庄姬",     question, question);
person zhao_WU          = person(true,  "", "武",       question, "前541", hao="文子", notes="此即赵氏孤儿。"); // 
person zhao_WU_wife     = clone(female_unknown);
person zhao_huo         = person(true,  "", "或",       question, question); 
person zhao_cheng       = person(true,  "", "成",       question, "前518", hao="景叔"); 
person zhao_cheng_wife  = clone(female_unknown);
person zhao_yang        = person(true,  "", "鞅",       question, "前476", hao="简子"); 
person zhao_yang_wife   = clone(female_unknown);
person zhao_bolu        = person(true,  "", "伯鲁",       question, question); 
person zhao_bolu_wife   = clone(female_unknown);
person zhao_wuxu        = person(true,  "", "毋卹",       question, "前425", hao="襄子"); 
person zhao_wuxu_wife   = clone(female_unknown);
person zhao_jia         = person(true,  "", "嘉",       question, "前424", hao="桓子"); 
person zhao_zhou        = person(true,  "", "周",       question, question, hao="代成君");  // 
person zhao_zhou_wife   = clone(female_unknown);
person zhao_huan        = person(true,  "", "浣",       question, "前409", order="1", throne="15", hao="献候"); 
person zhao_huan_wife   = clone(female_unknown);
person zhao_ji2         = person(true,  "", "籍",       question, "前400", order="2", throne="9", hao="烈候"); 
person zhao_x           = person(true,  "", unknown,    question, "前387", order="3", throne="13", hao="武公"); 
person zhao_ji2_wife    = clone(female_unknown);
person zhao_x_wife      = clone(female_unknown);
person zhao_chao2       = person(true,  "", "朝",       question, question, hao="公子"); 
person zhao_zhang       = person(true,  "", "章",       question, "前375", order="4", throne="12", hao="敬候"); 
person zhao_zhong       = person(true,  "", "种",       question, "前", order="5", throne="25", hao="成候"); 
person zhao_zhang_wife  = clone(female_unknown);
person zhao_zhong_wife  = clone(female_unknown);
person zhao_yu          = person(true,  "", "语",       question, "前", order="6", throne="24", hao="肃候"); 
person zhao_yu_wife     = clone(female_unknown);
person zhao_yong        = person(true,  "", "雍",       question, "前", order="7", throne="27", hao="武灵王"); 
person zhao_cheng2      = person(true,  "", "成",       question, question, hao="安平君"); 
person zhao_sheng2      = person(true,  "", "胜",       question, question, hao="平原君"); 
person zhao_yong_wife   = clone(female_unknown);
person zhao_zhang2      = person(true,  "", "章",       question, question, hao="太子"); 
person zhao_he          = person(true,  "", "何",       question, "前", order="8", throne="33", hao="惠文王"); 
person zhao_pyj         = person(true,  "", "豹",       question, question, hao="平阳君"); 
person zhao_he_wife     = clone(female_unknown);
person zhao_dan         = person(true,  "", "丹",       question, "前", order="9", throne="21", hao="孝成王"); 
person zhao_caj         = person(true,  "", unknown,       question, question, hao="长安君"); 
person zhao_llj          = person(true,  "", unknown,       question, question, hao="庐陵君"); 
person zhao_dan_wife    = clone(female_unknown);
person zhao_yan         = person(true,  "", "偃",       question, "前", order="10", throne="9", hao="悼襄王"); 
person zhao_yan_wife    = clone(female_unknown);
person zhao_jia2        = person(true,  "", "嘉",       question, "前", order="11", throne="6", hao="代王"); 
person zhao_qian        = person(true,  "", "迁",       question, "前", order="12", throne="8", hao="幽缪王"); 
person zhao_jia2_wife   = clone(female_unknown);
person zhao_fu          = person(true,  "", "辅",       question, question); 




/* 关系 */
/*
zao_fu.marry(zao_fu_wife);
zao_fu_wife.give_birth(ellipse1);
*/
zao_fu.has(ellipse1);

/*
ellipse1.marry(male_unknown);
ellipse1.give_birth(yan_fu);
*/
ellipse1.has(yan_fu);

/*
yan_fu.marry(yan_fu_wife);
yan_fu_wife.give_birth(shu_dai);
*/
yan_fu.has(shu_dai);

/*
shu_dai.marry(shu_dai_wife);
shu_dai_wife.give_birth(ellipse2);
*/
shu_dai.has(ellipse2);

/*
ellipse2.marry(male_unknown);
ellipse2.give_birth(gong_ming);
*/
ellipse2.has(gong_ming);

/*
gong_ming.marry(gong_ming_wife);
gong_ming_wife.give_birth(zhao_su);
gong_ming_wife.give_birth(zhao_shuai, zhao_su);
*/
gong_ming.has(zhao_su, zhao_shuai);

/*
zhao_su.marry(zhao_su_wife);
zhao_su_wife.give_birth(zhao_gongmeng);
*/
zhao_su.has(zhao_gongmeng);

/*
zhao_gongmeng.marry(zhao_gongmeng_wife);
zhao_gongmeng_wife.give_birth(zhao_chuan);
zhao_gongmeng_wife.give_birth(zhao_chuan2, zhao_chuan);
*/
zhao_gongmeng.has(zhao_chuan, zhao_chuan2);

/*
zhao_chuan.marry(zhao_chuan_wife);
zhao_chuan_wife.give_birth(zhao_zhan0);
zhao_chuan_wife.give_birth(zhao_zhan, zhao_zhan0);
*/
zhao_chuan.has(zhao_zhan0, zhao_zhan);

/*
zhao_zhan.marry(zhao_zhan_wife);
zhao_zhan_wife.give_birth(zhao_sheng);
*/
zhao_zhan.has(zhao_sheng);

/*
zhao_sheng.marry(zhao_sheng_wife);
zhao_sheng_wife.give_birth(zhao_wu);
zhao_sheng_wife.give_birth(zhao_wu2, zhao_wu);
*/
zhao_sheng.has(zhao_wu, zhao_wu2);

/*
zhao_wu.marry(zhao_wu_wife);
zhao_wu_wife.give_birth(zhao_ji);
*/
zhao_wu.has(zhao_ji);

/*
zhao_wu2.marry(zhao_wu2_wife);
zhao_wu2_wife.give_birth(zhao_wu2_kid);
*/
zhao_wu2.has(zhao_wu2_kid);

/*
zhao_wu2_kid.marry(zhao_wu2_kid_wife);
zhao_wu2_kid_wife.give_birth(zhao_chao);
*/
zhao_wu2_kid.has(zhao_chao);



// 赵衰以下
/*
zhao_shuai.marry(zhao_shuai_wife);
zhao_shuai_wife.give_birth(zhao_dun);
zhao_shuai_wife.give_birth(zhao_tong, zhao_dun);
zhao_shuai_wife.give_birth(zhao_kuo, zhao_tong);
zhao_shuai_wife.give_birth(zhao_yingqi, zhao_kuo);
*/
zhao_shuai.has(zhao_dun, zhao_tong, zhao_kuo, zhao_yingqi);

/*
zhao_dun.marry(zhao_dun_wife);
zhao_dun_wife.give_birth(zhao_shuo);
*/
zhao_dun.has(zhao_shuo);


zhao_shuo.marry(zhao_shuo_wife);
zhao_shuo_wife.give_birth(zhao_WU);
/*
zhao_shuo.has(zhao_WU);
*/

/*
zhao_WU.marry(zhao_WU_wife);
zhao_WU_wife.give_birth(zhao_cheng);
*/
zhao_WU.has(zhao_cheng);

/*
zhao_cheng.marry(zhao_cheng_wife);
zhao_cheng_wife.give_birth(zhao_yang);
*/
zhao_cheng.has(zhao_yang);

/*
zhao_yang.marry(zhao_yang_wife);
zhao_yang_wife.give_birth(zhao_bolu);
zhao_yang_wife.give_birth(zhao_wuxu, zhao_bolu);
*/
zhao_yang.has(zhao_bolu, zhao_wuxu);

/*
zhao_wuxu.marry(zhao_wuxu_wife);
zhao_wuxu_wife.give_birth(zhao_jia);
*/
zhao_wuxu.has(zhao_jia);

/*
zhao_bolu.marry(zhao_bolu_wife);
zhao_bolu_wife.give_birth(zhao_zhou);
*/
zhao_bolu.has(zhao_zhou);

/*
zhao_zhou.marry(zhao_zhou_wife);
zhao_zhou_wife.give_birth(zhao_huan);
*/
zhao_zhou.has(zhao_huan);


/*
zhao_huan.marry(zhao_huan_wife);
zhao_huan_wife.give_birth(zhao_ji2);
zhao_huan_wife.give_birth(zhao_x, zhao_ji2);
*/
zhao_huan.has(zhao_ji2, zhao_x);

/*
zhao_ji2.marry(zhao_ji2_wife);
zhao_ji2_wife.give_birth(zhao_zhang);
*/
zhao_ji2.has(zhao_zhang);

/*
zhao_x.marry(zhao_x_wife);
zhao_x_wife.give_birth(zhao_chao2);
*/
zhao_x.has(zhao_chao2);

/*
zhao_zhang.marry(zhao_zhang_wife);
zhao_zhang_wife.give_birth(zhao_zhong);
*/
zhao_zhang.has(zhao_zhong);

/*
zhao_zhong.marry(zhao_zhong_wife);
zhao_zhong_wife.give_birth(zhao_yu);
zhao_zhong_wife.give_birth(zhao_cheng2, zhao_yu);
*/
zhao_zhong.has(zhao_yu, zhao_cheng2);

/*
zhao_yu.marry(zhao_yu_wife);
zhao_yu_wife.give_birth(zhao_yong);
*/
zhao_yu.has(zhao_yong);

/*
zhao_yong.marry(zhao_yong_wife);
zhao_yong_wife.give_birth(zhao_zhang2);
zhao_yong_wife.give_birth(zhao_he, zhao_zhang2);
zhao_yong_wife.give_birth(zhao_pyj, zhao_he);
zhao_yong_wife.give_birth(zhao_sheng2, zhao_pyj); 
*/
zhao_yong.has(zhao_zhang2, zhao_he, zhao_pyj, zhao_sheng2);

/*
zhao_he.marry(zhao_he_wife);
zhao_he_wife.give_birth(zhao_dan);
zhao_he_wife.give_birth(zhao_caj, zhao_dan);
zhao_he_wife.give_birth(zhao_llj, zhao_caj);
*/
zhao_he.has(zhao_dan, zhao_caj, zhao_llj);

/*
zhao_dan.marry(zhao_dan_wife);
zhao_dan_wife.give_birth(zhao_yan);
*/
zhao_dan.has(zhao_yan);

/*
zhao_yan.marry(zhao_yan_wife);
zhao_yan_wife.give_birth(zhao_jia2);
zhao_yan_wife.give_birth(zhao_qian, zhao_jia2);
*/
zhao_yan.has(zhao_jia2, zhao_qian);

/*
zhao_jia2.marry(zhao_jia2_wife);
zhao_jia2_wife.give_birth(zhao_fu);
*/
zhao_jia2.has(zhao_fu);

//g_debug = true;
g_kid_h_gap *= .8;  // 缩小两辈之间间距
shipout_lineage(zao_fu, new person[]{zhao_yang},  "zhao", "赵国世系表", "参考\underline{https://zh.wikipedia.org/wiki/趙國君主世系圖}编制。", 20cm);
//shipout_lineage(zao_fu,  "zhao", "赵国世系表", "参考\underline{https://zh.wikipedia.org/wiki/趙國君主世系圖}编制。", 20cm);

