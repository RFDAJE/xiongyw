import "lineage.asy" as lineage;




/* ######################################################################## */
//
//  赵国世系
//
/* ######################################################################## */

person male_unknown   = person(true,  unknown, unknown2, question, blank);
person female_unknown = person(false, unknown, unknown2, question, blank);
person ellipse        = person(false, "", "$\cdots$", question, question); // make it female



person zao_fu           = person(true,  "", "造父",       question, question);
person zao_fu_wife      = person(false, unknown, unknown2, question, question);
person ellipse1         = clone(ellipse);
ellipse1.given_name += "(隔六世)";
person yan_fu           = person(true,  "", "奄父",       question, question); // 造父六世孙
person yan_fu_wife      = clone(female_unknown);
person shu_dai          = person(true,  "", "叔代",       question, question);
person shu_dai_wife     = clone(female_unknown);
person ellipse2         = clone(ellipse);
ellipse2.given_name += "(隔五世)";
person zhao_su          = person(true,  "", "夙",       question, question);
person zhao_su_wife     = clone(female_unknown);
person zhao_gongmeng    = person(true,  "", "共孟",       question, question);
person zhao_gongmeng_wife = clone(female_unknown);
person zhao_shu_wife    = clone(female_unknown);
person zhao_shuai       = person(true,  "", "衰",       question, question); // he has more than one wife, actually
person zhao_shuai_wife  = clone(female_unknown);

person zhao_dun         = person(true,  "", "盾",       question, question);
person zhao_tong        = person(true,  "", "同",       question, question);
person zhao_kuo         = person(true,  "", "括",       question, question);
person zhao_yingqi      = person(true,  "", "婴齐",       question, question);

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
ellipse2.give_birth(zhao_su);
zhao_su.marry(zhao_su_wife);
zhao_su_wife.give_birth(zhao_gongmeng);
zhao_gongmeng.marry(zhao_gongmeng_wife);
zhao_gongmeng_wife.give_birth(zhao_shuai);
zhao_shuai.marry(zhao_shuai_wife);
zhao_shuai_wife.give_birth(zhao_dun);
zhao_shuai_wife.give_birth(zhao_tong, zhao_dun);
zhao_shuai_wife.give_birth(zhao_kuo, zhao_tong);
zhao_shuai_wife.give_birth(zhao_yingqi, zhao_kuo);


shipout_lineage(zao_fu, new person[] {zhao_shuai}, "zhao", "赵国世系表", "", 10cm);


