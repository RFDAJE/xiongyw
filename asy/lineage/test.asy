import "lineage.asy" as lineage;




/* ######################################################################## */
//
//  家族数据
//
/* ######################################################################## */

person male_unknown   = person.person(true,  unknown, unknown2, question, blank);
person female_unknown = person.person(false, unknown, unknown2, question, blank);



person zhao_jiasong  = person.person(true,  "赵", "松家",       "前200", "前100", notes="这是赵家松的备注这是赵家松的备注这是赵家松的备注这是赵家松的备注这是赵家松的备注这是赵家松的备注");
person zhao_jiasong_wife  = person.person(false, unknown, unknown2, question, question, notes="xxx");
person zhao_cheng_x  = person.person(false, "赵", "承",       question, question, notes="这是赵成的备注");
person zhao_chengbin = person.person(true,  "赵", "承筹",     question, question);
person wen_bishou     = person.person(true,  "文", "寿必",       question, question, notes="文寿必");
person wen_changxiang = person.person(true,  "文", "祥昌",       question, question);
person wen_changxiang_wife  = person.person(false, unknown, unknown2, question, question, notes="yyy");
person wen_x          = person.person(false, "文", unknown2,       question, blank);
person wen_weixing    = person.person(true,  "文", "星卫",       question, blank);
person wen_x1         = person.person(true,  unknown, unknown2,       question, blank); 
person wen_x2         = person.person(true,  unknown, unknown2,       question, blank); 
person wen_x3         = person.person(true,  unknown, unknown2,       question, blank); 
person yan_xiangxiao  = person.person(false, "严", "孝",       question, blank);
person zhao_zuxin    = person.person(true,  "赵", "鑫",       question, blank, notes="赵鑫");
person wang_fuying    = person.person(false, "王", "英",       question, blank);
person zhao_yuwen    = person.person(true,  "赵", "贤文",      question, blank);
person zhao_yuwu     = person.person(true,  "赵", "贤武",      question, blank);
person tian_aigu      = person.person(false, "周", "爱凤",     question, blank);
person zhao_qiushi   = person.person(false, "赵", "秋若",      question, blank);
person chen_juan      = person.person(false, "张", "娟丽",     question, blank);
person zhao_kaiyuan  = person.person(false, "赵", "元元",      question, blank);


/* 关系 */

zhao_jiasong.marry(zhao_jiasong_wife);
zhao_jiasong_wife.give_birth(zhao_cheng_x);
zhao_jiasong_wife.give_birth(zhao_chengbin, zhao_cheng_x);

wen_bishou.marry(zhao_cheng_x);
zhao_cheng_x.give_birth(wen_changxiang);
zhao_cheng_x.give_birth(wen_x, wen_changxiang);

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



//set_n_draw_notes(zhao_jiasong);
shipout_lineage(zhao_jiasong, "test", "赵姓世系表", "标题注", 12cm);


