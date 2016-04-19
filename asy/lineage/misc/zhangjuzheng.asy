import "lineage.asy" as lineage;




/* ######################################################################## */
//
//  家族数据
//
/* ######################################################################## */

person male_unknown   = person(true,  unknown, unknown2, question, blank);
person female_unknown = person(false, unknown, unknown2, question, blank);



person zhang_zhen           = person(true,  "张", "镇",       question, question);
person zhang_zhen_wife      = person(false, "李", "氏",       question, question);
person zhang_wenming        = person(true,  "张", "文明",     "1504",   "1577");
person zhang_wenming_wife   = person(false, "赵", "氏",       "1506",   question);

person zhang_juzheng        = person(true,  "张", "居正",     "1525",   "1582");
person zhang_juzheng_wife   = person(false, "顾", "氏",       question, question);
person zhang_jujing         = person(true,  "张", "居敬",     question, question);
person zhang_jujing_wife    = person(false,  unknown, unknown2,question, question);
person zhang_juyi           = person(true,  "张", "居易",     question, question);
person zhang_juqian         = person(true,  "张", "居谦",     question, "1580");
person zhang_jux            = person(false, "张", "居□",     question, question);
person zhang_jux_husb       = person(true,  "刘", "允桂",     question, question);

person zhang_jingxiu        = person(true,  "张", "敬修",     question, "1584");
person zhang_jingxiu_wife   = person(false, "高", "氏",       question, question);
person zhang_sixiu          = person(true,  "张", "嗣修",     question, question);
person zhang_sixiu_wife     = person(false, "贺", "氏",       question, question);
person zhang_maoxiu         = person(true,  "张", "懋修",     "1555",   "1634");
person zhang_maoxiu_wife    = person(false, "高", "氏",       question, question);
person zhang_jianxiu        = person(true,  "张", "简修",     question, question);
person zhang_jianxiu_wife   = person(false, "王", "氏",       question, question);
person zhang_yunxiu         = person(true,  "张", "允修",     "1565",   "1644");
person zhang_yunxiu_wife    = person(false, "李", "氏",       question, question);
person zhang_jingxiu2       = person(true,  "张", "静修",     question, question);
person zhang_xxiu           = person(false, "张", "□修",     question, question);
person zhang_xxiu_husb      = person(true,  "刘", "戡之",     question, question);
person zhang_simin          = person(true,  "张", "嗣敏",     question, question);

person zhang_chonghui       = person(true,  "张", "重辉",     "1579",   question);
person zhang_chongx1        = person(false, "张", "重□",     question, question);
person zhang_chongx2        = person(false, "张", "重□",     question, question);
person zhang_chongx3        = person(false, "张", "重□",     question, question);
person zhang_chongguang     = person(true,  "张", "重光",     question, question);
person zhang_chongdeng      = person(true,  "张", "重登",     question, question);
person zhang_chongyuan      = person(true,  "张", "重元",     question, question);
person zhang_chongx4        = person(false, "张", "重□",     question, question);
person zhang_chongx5        = person(false, "张", "重□",     question, question);
person zhang_chongrun       = person(true,  "张", "重润",     question, question);
person zhang_chongyun       = person(true,  "张", "重允",     question, question);


/* 关系 */
zhang_zhen.marry(zhang_zhen_wife);
zhang_zhen_wife.give_birth(zhang_wenming);
zhang_wenming.marry(zhang_wenming_wife);
zhang_wenming_wife.give_birth(zhang_juzheng);
zhang_wenming_wife.give_birth(zhang_jujing, zhang_juzheng);
zhang_wenming_wife.give_birth(zhang_juyi, zhang_jujing);
zhang_wenming_wife.give_birth(zhang_juqian, zhang_juyi);
zhang_wenming_wife.give_birth(zhang_jux, zhang_juqian);

zhang_juzheng.marry(zhang_juzheng_wife);
zhang_jujing.marry(zhang_jujing_wife);
zhang_jux.marry(zhang_jux_husb);

zhang_juzheng_wife.give_birth(zhang_jingxiu);
zhang_juzheng_wife.give_birth(zhang_sixiu, zhang_jingxiu);
zhang_juzheng_wife.give_birth(zhang_maoxiu, zhang_sixiu);
zhang_juzheng_wife.give_birth(zhang_jianxiu, zhang_maoxiu);
zhang_juzheng_wife.give_birth(zhang_yunxiu, zhang_jianxiu);
zhang_juzheng_wife.give_birth(zhang_jingxiu2, zhang_yunxiu);
zhang_juzheng_wife.give_birth(zhang_xxiu, zhang_jingxiu2);

zhang_jujing_wife.give_birth(zhang_simin);

zhang_jingxiu.marry(zhang_jingxiu_wife);
zhang_jingxiu_wife.give_birth(zhang_chonghui);
zhang_jingxiu_wife.give_birth(zhang_chongx1, zhang_chonghui);
zhang_jingxiu_wife.give_birth(zhang_chongx2, zhang_chongx1); 
zhang_jingxiu_wife.give_birth(zhang_chongx3, zhang_chongx2); 

zhang_sixiu.marry(zhang_sixiu_wife);
zhang_sixiu_wife.give_birth(zhang_chongguang);

zhang_maoxiu.marry(zhang_maoxiu_wife);
zhang_maoxiu_wife.give_birth(zhang_chongdeng);
zhang_maoxiu_wife.give_birth(zhang_chongyuan, zhang_chongdeng);
zhang_maoxiu_wife.give_birth(zhang_chongx4, zhang_chongyuan);
zhang_maoxiu_wife.give_birth(zhang_chongx5, zhang_chongx4); 

zhang_jianxiu.marry(zhang_jianxiu_wife);
zhang_jianxiu_wife.give_birth(zhang_chongrun);
zhang_jianxiu_wife.give_birth(zhang_chongyun, zhang_chongrun);





g_debug = true;


shipout_lineage(zhang_zhen, "zhangjuzheng", "张居正世系表", "根据《张居正大传》编制于 2016.03.31。", 10cm);


