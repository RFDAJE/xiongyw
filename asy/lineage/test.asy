import "lineage.asy" as lineage;




/* ######################################################################## */
//
//  家族数据
//
/* ######################################################################## */

person male_unknown   = person(true,  unknown, unknown2, question, blank);
person female_unknown = person(false, unknown, unknown2, question, blank);

person ellipse        = person(true, "", "$\cdots$", question, question);


person zhao_jiasong  = person(true,  "赵", "松家",       "前200", "前190", notes="这是赵家松的备注这是赵家松的备注这是赵家松的备注这是赵家松的备注这是赵家松的备注这是赵家松的备注");
person zhao_jiasong_wife  = person(false, unknown, unknown2, question, question, notes="xxx");
person zhao_cheng_x  = person(false, "赵", "承",       "2000.10.10", "2100.12.12", notes="这是赵成的备注");
person zhao_chengbin = person(true,  "赵", "承筹",     question, question);
person wen_bishou     = person(true,  "文", "寿必",       question, question, notes="文寿必");
person wen_changxiang = person(true,  "文", "祥昌",       question, question);
person wen_changxiang2 = person(true,  "文", "祥盛",       question, question);
person wen_changxiang_wife  = person(false, unknown, unknown2, question, question, notes="yyy");
person wen_x          = person(false, "文", unknown2,       question, blank);
person wen_weixing    = person(true,  "文", "星卫",       question, blank);
person wen_x1         = person(true,  unknown, unknown2,       question, blank); 
person wen_x2         = person(true,  unknown, unknown2,       question, blank); 
person wen_x3         = person(true,  unknown, unknown2,       question, blank); 
person yan_xiangxiao  = person(false, "严", "孝",       question, blank);
person zhao_zuxin    = person(true,  "赵", "鑫",       question, blank, notes="赵鑫");
person wang_fuying    = person(false, "王", "英",       question, blank);
person zhao_yuwen    = person(true,  "赵", "贤文",      question, blank);
person zhao_yuwu     = person(true,  "赵", "贤武",      question, blank);
person tian_aigu      = person(false, "周", "爱凤",     question, blank);
person zhao_qiushi   = person(false, "赵", "秋若",      question, blank);
person chen_juan      = person(false, "张", "娟丽",     question, blank);
person zhao_kaiyuan  = person(false, "赵", "丽丽",      question, blank);
person zhao_fang  = person(false, "赵", "芳",      question, blank);
person zhao_yan  = person(false, "赵", "艳",      "1981.10.10", "2029.12.12");
person zhao_lan  = person(false, "赵", "兰",      "1981.10.10", "2029.12.12");
person zhao_chu  = person(false, "赵", "楚",      question, blank);
person zhao_qian  = person(false, "赵", "茜",      question, blank);


/* 关系 */

zhao_jiasong.marry(zhao_jiasong_wife);
zhao_jiasong_wife.give_birth(ellipse);

ellipse.marry(female_unknown);
female_unknown.give_birth(zhao_cheng_x);
female_unknown.give_birth(zhao_chengbin, zhao_cheng_x);

wen_bishou.marry(zhao_cheng_x);
zhao_cheng_x.give_birth(wen_changxiang);
zhao_cheng_x.give_birth(wen_x, wen_changxiang);
zhao_cheng_x.give_birth(wen_changxiang2, wen_x);

wen_changxiang.marry(wen_changxiang_wife);
wen_changxiang_wife.give_birth(wen_weixing);
wen_changxiang_wife.give_birth(wen_x1, wen_weixing);
wen_changxiang_wife.give_birth(wen_x2, wen_x1);
wen_changxiang_wife.give_birth(wen_x3, wen_x2);

zhao_chengbin.marry(yan_xiangxiao);
yan_xiangxiao.give_birth(zhao_zuxin); /* not really, but adopted */

zhao_zuxin.marry(wang_fuying);
wang_fuying.give_birth(zhao_yuwen);
wang_fuying.give_birth(zhao_yuwu, zhao_yuwen);

zhao_yuwen.marry(tian_aigu);
tian_aigu.give_birth(zhao_qiushi);

zhao_yuwu.marry(chen_juan);
chen_juan.give_birth(zhao_kaiyuan);

zhao_kaiyuan.marry(male_unknown);
zhao_fang.marry(male_unknown);
zhao_yan.marry(male_unknown);
zhao_lan.marry(male_unknown);
zhao_chu.marry(male_unknown);

zhao_kaiyuan.give_birth(zhao_fang);
zhao_fang.give_birth(zhao_yan);
zhao_yan.give_birth(zhao_lan);
zhao_lan.give_birth(zhao_chu);
zhao_chu.give_birth(zhao_qian);


g_debug = true;
//shipout_lineage(zhao_jiasong, splits = new person[] {zhao_zuxin, zhao_fang, zhao_lan}, "test", "赵姓世系表", "标题注", 12cm);
//zhao_zuxin.kid = null;
shipout_lineage(zhao_jiasong,  "test", "赵姓世系表", "标题注", 12cm);


