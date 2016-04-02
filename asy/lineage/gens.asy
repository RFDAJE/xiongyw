/* created(bruin, 2007-03-01): draw family lineage diagram.
   - build the family tree in memory firstly
   - draw the diagram for the tree

   - updated(bruin, 2015-06-22): xelatex and utf-8
   - updated(bruin, 2016-02-11): multiple spouses support; also add nick_name field
   - updated(bruin, 2016-02-22): split into two files: lineages.asy (library), and gens.asy (data)

   usage: "asy -f pdf gens.asy" under windows/linux
 */

import "lineage.asy" as lineage;





/* ######################################################################## */
//
//  家族数据
//
/* ######################################################################## */

person male_unknown   = person(true,  unknown, unknown2, question, blank);
person female_unknown = person(false, unknown, unknown2, question, blank);

/* ################ 熊姓 ################ */

/* 人员 */

person xiong_jiasong  = person(true,  "熊", "家松",       question, question);
person xiong_jiasong_wife  = person(false, unknown, unknown2, question, question );
person xiong_cheng_x  = person(false, "熊", "承"+unknown,       question, question);
person xiong_chengbin = person(true,  "熊", "承斌",       "1911.07.12",   "1999");
person wen_bishou     = person(true,  "文", "必寿",       question, question);
person wen_changxiang = person(true,  "文", "昌祥",       question, "");
person wen_changxiang_wife  = person(false, unknown, unknown2, question, question );
person wen_x          = person(false, "文", unknown2,       question, blank);
person wen_weixing    = person(true,  "文", "卫星",       question, blank);
person wen_x1         = person(true,  unknown, unknown2,       question, blank);  /* 性别亦不清楚 */
person wen_x2         = person(true,  unknown, unknown2,       question, blank);  /* 性别亦不清楚 */
person wen_x3         = person(true,  unknown, unknown2,       question, blank);  /* 性别亦不清楚 */
person yan_xiangxiao  = person(false, "严", "相孝",       "1911.07.20",   "1995");
person xiong_zuxin    = person(true,  "熊", "祖鑫",       "1944.01.25",   blank, notes="本名赵复才，两岁时由于生母病逝且家境窘迫，被熊家领养，遂改用此名。");
person wang_fuying    = person(false, "王", "福英",       "1946.03.19",   blank);
person xiong_yuwen    = person(true,  "熊", "育文",       "1970.07.16",   blank); // notes="小名大红");
person xiong_yuwu     = person(true,  "熊", "育武",       "1971.09.23",   blank); // notes="小名小红");
person tian_aigu      = person(false, "田", "爱姑",       "1971.12.14",   blank);
person xiong_qiushi   = person(false, "熊", "秋实",       "1996.08.07",   blank); // notes="小名秋秋");
person chen_juan      = person(false, "陈", "娟",         "1972.11.11",   blank);
person xiong_kaiyuan  = person(false, "熊", "开元",       "2000.12.19",   blank); // notes="小名元元");

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


/* ################ 王姓 ################ */

/* 人员 */

person wang_rixi      = person(true,  "王", "日熙",       question, question, notes = "共有兄弟姊妹七人，在其中排行第六 。");
person wang_rixi_wife = person(false,  unknown, unknown,       question, question);
person wang_yuenan    = person(true,  "王", "月南",       question, question);
person wang_yuenan_wife = person(false,  "肖", unknown2,       question, question);
person wang_yueying   = person(false, "王", "月英",       question, question, notes="国民党营级军官，带兵路过五峰时和韩新秀结合，后病逝于驻地恩施 。");
person wang_yuehai    = person(true,  "王", "月海",       question, question);
person wang_yueping   = person(true,  "王", "月平",       question, "1948");
person wang_reyang    = person(true,  "王", unknown2,       question, question); // 王月英的丈夫，也姓王，二羊村
person han_xinxiu     = person(false, "韩", "新秀",       "1915.09.27", "1991.08.18", notes="又名黄桂香、韩香大。四岁丧母，十岁丧父。"); 
person shi_shixiang   = person(true,  "石", "世祥",       question, "1974", notes="和韩新秀无后。");   // 韩新秀的第二个丈夫，和韩无后
person wang_liansheng = person(true,  "王", "连生",       question, question);
person wang_liansheng_wife = person(false,  "彭", unknown2,       question, question);
person wang_chuanxi   = person(true,  "王", "传熙",       "1936",   question);
person zhou_yinlan    = person(false, "周", "引兰",       question, blank);
person wang_fuen      = person(true,  "王", "福恩",       question, blank);
person sheng_guoying  = person(false, "盛", "国银",       question, blank);
person wang_qilin     = person(true,  "王", "齐林",       question, question);
person shen_yulan     = person(false, "沈", "玉兰",       question, blank);
person wang_qifa      = person(true,  "王", "齐发",       question, blank);
person wang_qifa_wife = person(false, "彭", unknown2,       question, blank);
person wang_lachun    = person(true,  "王", "齐三",       question, "2005");  // 腊春
person wang_lachun_wife= person(false,"刘", "宝姑",       question, blank);
person wang_silin     = person(true,  "王", "四林",       question, blank);
person wang_silin_wife = person(false,  "乔", unknown2,       question, blank);
person wang_chunqing  = person(true,  "王", "先林",       "1958",   blank); // notes="小名春清"
person wang_yunxiang  = person(false, "王", "运香",       "1961",   blank);
person wang_yuzhen    = person(false, "王", "先秀",       "1963",   blank); // notes="小名玉珍");
person zhou_chijun    = person(true,  "周", "赤军",       "1963",   blank);
person wang_yunzhen   = person(false, "王", "云珍",       "1968",   blank); // notes="小名云珍");
person wang_xiankui   = person(true,  "王", "先奎",       "1978",   blank); // notes="小名想清");
person hu_aiqiong     = person(false, "胡", "爱琼",       question, blank);
person wang_yuran     = person(true,  "王", "禹然",       "2010",   blank); // notes="小名贝贝");
person shi_hebin      = person(true,  "石", "和彬",       "1965",   blank); // notes="小名大兵");
person deng_quanbin   = person(false, "邓", "全斌",       question, blank);
person wang_qisong    = person(true,  "王", "齐松",       "1968",   blank); // notes="小名小兵");
person tao_weijun     = person(false, "陶", "卫军",       question, blank);
person wang_qiyu      = person(true,  "王", "齐禹",       "1972.1.14",   blank); // notes="小名三兵");
person wang_haiyan    = person(true,  "王", "海燕",       question, blank);
person wang_dahong    = person(false, "王", unknown2,       question, blank); // notes="小名大红");
person wang_xiaohong  = person(false, "王", unknown2,       question, blank); // notes="小名小红");
person wang_cuie      = person(false, "王", "翠娥",       "1985",   blank);
person wang_cong      = person(false, "王", "聪",         "1987",   blank);
person wang_li        = person(false, "王", "丽",         "1990",   blank);
person wang_gongbao   = person(true,  "王", "功宝",       "1995",   blank);
person zhou_xiang     = person(true,  "周", "祥",         "1991",   blank); // notes="小名祥祥");
person shi_kanming    = person(true,  "石", "衎明",       "1996",   blank); // notes="小名明明");
person wang_yingjun   = person(false, "王", "滢珺",       "1996.11.01",   blank); // notes="小名淋淋");

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

wang_qifa.marry(wang_qifa_wife);
wang_lachun.marry(wang_lachun_wife);
wang_silin.marry(wang_silin_wife);

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
hu_aiqiong.give_birth(wang_yuran);

//wang_yueping.marry(uni=false, han_xinxiu);
//han_xinxiu.marry(uni=false, wang_yueping, shi_shixiang);
wang_yueping.marry(han_xinxiu);
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


/* ################ 黄姓 ################ */


/* 人员 */
person huang_dacai = person(true, "黄", "大才", question, question);
person huang_dacai_wife = person(false, "田", "氏", question, question);
person huang_peihu = person(true, "黄", "佩虎", question, question);
person huang_peihu_wife = person(false, "钟", "氏", question, question);
person huang_zudian = person(true, "黄", "祖典", question, question);
person huang_zudian_wife = person(false, "苏", "氏", question, question);
person huang_zongde = person(true, "黄", "宗德", question, question);
person huang_zongde_wife = person(false, "韩", "氏", question, question);
person huang_zhiyao = person(true, "黄", "志尧", question, question);
person huang_zhiyao_wife = person(false, "胡", "氏", question, question);
person huang_zhiyu = person(true, "黄", "志禹", question, question);
person huang_zhiyu_wife = person(false, unknown, unknown2, question, question);
person huang_shiguang = person(true, "黄", "士光", question, question);
person huang_shiguang_wife = person(false, "胡", "氏", question, question);
person huang_shideng = person(true, "黄", "士登", "1887.04.25", "1942.08.01", notes="为五峰当地一代名医。又名韩宝山，其外曾祖父名为韩天德，韩姓盖由此而来。");
person huang_shideng_wife = person(false, "田", "氏", question, question);
person huang_zizhang = person(true, "黄", "子章", question, question);
person huang_zizhang_wife = person(false, "周", "氏",  question, question);
person huang_haida = person(true, "黄", "海大", "1917.12.27", "1982.08.29", notes="又名黄河清。两岁丧母，八岁丧父，后由黄士登(韩宝山)抚养并从其学习医术。");  
person huang_haida_wife0 = person(false, "唐", "氏", question, question, notes="和黄海大无后。"); 
person huang_haida_wife1 = person(false, "张", "卜秀", "1919.12.05", "1989.05.22", notes="和黄海大离异后再婚，也嫁给一黄姓(但无后)。"); 
person huang_haida_wife2 = person(false, "吴", "厚英", "1924.11.02", "2014.08.04", notes="和黄海大无后。");
person huang_daoming = person(true, "黄", "道明", "1944.08.25", blank);
person zou_xiangchun = person(false, "邹", "祥春", "1947.04.04", blank, notes="又名杨仲芳。"); 
person huang_shenghong = person(true, "黄", "声鸿", "1968.12.09", blank);
person huang_shenghong_wife = person(false, "郑", "龙萍", "1970.02.15", blank);
person zhang_fangnian = person(true, "张", "方年", "1970.02.25", blank);
person zhang_fangnian_wife = person(false, "彭", "令", "1971.05.15", blank);
person huang_shengqiang = person(true, "黄", "胜强", "1971.08.24", blank);
person huang_shengqiang_wife = person(false, "李", "俊霞", "1972.10.21", blank);
person huang_zhengyang = person(false, "黄", "正阳", "1995.05.22", blank);
person zhang_pengxu = person(true, "张", "彭栩", "1996.08.15", blank);
person huang_minchen = person(true, "黄", "民宸", "1998.03.17", blank);


/* 关系 */
huang_dacai.marry(huang_dacai_wife);
huang_dacai_wife.give_birth(huang_peihu);
huang_peihu.marry(huang_peihu_wife);
huang_peihu_wife.give_birth(huang_zudian);
huang_zudian.marry(huang_zudian_wife);
huang_zudian_wife.give_birth(huang_zongde);
huang_zongde.marry(huang_zongde_wife);
huang_zongde_wife.give_birth(huang_zhiyao);
huang_zongde_wife.give_birth(huang_zhiyu, huang_zhiyao);
huang_zhiyao.marry(huang_zhiyao_wife);
huang_zhiyao_wife.give_birth(huang_shiguang);
huang_zhiyu.marry(huang_zhiyu_wife);
huang_zhiyu_wife.give_birth(huang_shideng);
huang_shiguang.marry(huang_shiguang_wife);
huang_shideng.marry(huang_shideng_wife);
huang_shiguang_wife.give_birth(huang_zizhang);
huang_zizhang.marry(huang_zizhang_wife);
huang_zizhang_wife.give_birth(han_xinxiu);
huang_zizhang_wife.give_birth(huang_haida, han_xinxiu);
huang_haida.marry(uni=false, huang_haida_wife0, huang_haida_wife1, huang_haida_wife2);
huang_haida_wife0.marry(uni=false, huang_haida);
huang_haida_wife1.marry(uni=false, huang_haida);
huang_haida_wife2.marry(uni=false, huang_haida);
huang_haida_wife1.give_birth(huang_daoming);
huang_daoming.marry(zou_xiangchun);
zou_xiangchun.give_birth(huang_shenghong);
zou_xiangchun.give_birth(zhang_fangnian, huang_shenghong);
zou_xiangchun.give_birth(huang_shengqiang, zhang_fangnian);
huang_shenghong.marry(huang_shenghong_wife);
zhang_fangnian.marry(zhang_fangnian_wife);
huang_shengqiang.marry(huang_shengqiang_wife);
huang_shenghong_wife.give_birth(huang_zhengyang);
zhang_fangnian_wife.give_birth(zhang_pengxu);
huang_shengqiang_wife.give_birth(huang_minchen);


/* ################ 赵姓 ################ */

/* 人员 */

person zhao_tonghan   = person(true,  "赵", "同汉",       question, question);
person chen_xx        = person(false, "陈", unknown2,       question, question);
person zhao_fu_x      = person(false, "赵", "复□",       "1932",   "2004");
person zhao_fuxiang   = person(true,  "赵", "复祥",       "1934",   blank);
person qin_qianan     = person(false, "秦", "前安",       question, blank);
person zhao_fulong    = person(true,  "赵", "复龙",       "1940",   blank);
person zhao_fulong_wife    = person(false,  unknown, unknown2,       question,   blank);
person zhao_fucai     = person(true,  "赵", "复才",       "1944.01.25",   blank);  // 即 熊祖鑫
person zhao_xiangui   = person(false, "赵", "贤贵",       question, blank);
person liu_jincheng   = person(true,  "柳", "金成",       question, blank);
person zhao_xianchun  = person(true,  "赵", "贤春",       question, blank);
person zhao_xianchun_wife  = person(false,  unknown, unknown,      question, blank);
person zhao_xianbing  = person(true,  "赵", "贤兵",       question, blank);
person zhao_xianbing_wife  = person(false,  unknown, unknown,      question, blank);
person zhao_xianhong  = person(false, "赵", "贤红",       question, blank);
person zhao_x0        = person(false, "赵", "贤□",       question, blank);
person zhao_xianneng  = person(true,  "赵", "贤能",       question, blank);
person zhao_xianneng_wife  = person(false,  unknown, unknown,      question, blank);
person zhao_xianbing2 = person(true,  "赵", "贤兵",       question, blank);
person zhao_xianbing2_wife  = person(false,  unknown, unknown,      question, blank);
person liu_jun        = person(true,  "柳", "军",         question, blank);
person zhao_liang     = person(true,  "赵", "亮",         question, blank);
person zhao_rong      = person(false, "赵", "蓉",         question, blank);
person zhao_na        = person(false, "赵", "娜",         question, blank);
person zhao_heng      = person(true,  "赵", "恒",         question, blank);
person zhao_x1        = person(false, "赵", unknown2,       question, blank);
person zhao_x2        = person(false, "赵", unknown2,       question, blank);
person zhao_x3        = person(false, "赵", unknown2,       question, blank);

/* 关系 */
zhao_tonghan.marry(chen_xx);
chen_xx.give_birth(zhao_fu_x);
chen_xx.give_birth(zhao_fuxiang, zhao_fu_x);
chen_xx.give_birth(zhao_fulong, zhao_fuxiang);
//chen_xx.give_birth(zhao_fucai, zhao_fulong);
chen_xx.give_birth(xiong_zuxin, zhao_fulong);

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

//zhao_fucai.marry(wang_fuying);
xiong_zuxin.marry(wang_fuying);
//wang_fuying.give_birth(xiong_yuwen);

/* ################ 陈姓 ################ */

/* 人员 */

person chen_baixin    = person(true,  "陈", "百新",       "1911",   question);
person zhang_juying   = person(false, "张", "菊英",       "1911",   "1987");
person chen_lifeng    = person(true,  "陈", "立丰",       "1931",   "2004", notes="籍贯浙江鄞县。");
person wang_yumei     = person(false, "王", "玉梅",       "1937",   blank,  notes="籍贯山东招远。");
person chen_yufeng    = person(false, "陈", "玉丰",       question, blank);
person liu_jichang    = person(true,  "刘", "继昌",       question, blank);
person chen_lifeng2   = person(true,  "陈", "利丰",       question, question);
person chen_lifeng2_  = person(false, unknown, unknown2,       question, blank);  /* chen_lifeng2 的妻子 */
person chen_qingfeng  = person(true,  "陈", "庆丰",       "1951",   blank);
person wang_xiuqin    = person(false, "王", "秀琴",       question, blank);
person chen_lin       = person(true,  "陈", "林",         question, blank);
person lv_x           = person(false, "吕", unknown2,       question, blank);
person chen_jie       = person(true,  "陈", "杰",         "1957",   blank);
person qin_xiaojie    = person(false, "秦", "晓杰",       "1961",   blank);
person chen_min       = person(true,  "陈", "敏",         "1959",   blank);
person hu_rong        = person(false, "胡", "荣",         "1963",   blank);
person chen_yan       = person(false, "陈", "艳",         "1961",   blank);
person zhang_qiang    = person(true,  "张", "强",         question, blank);
person liu_geyao      = person(false, "刘", "戈瑶",       question, blank);
person chen_kai       = person(true,  "陈", "凯",         "1976",   blank);
person chen_kai_wife  = person(false,  unknown, unknown2,      question, blank);
person chen_yong      = person(true,  "陈", "勇",         question, blank);
person chen_lei       = person(true,  "陈", "雷",         "1986",   "2005");
person chen_jialiang  = person(true,  "陈", "佳亮",       "1988",   blank);
person zhang_hongtao  = person(true,  "张", "洪涛",       "1988",   blank);
person chen_xurui     = person(false, "陈", "旭蕊",       question, blank);

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


shipout_lineage(xiong_jiasong, "xiong", "熊姓世系表", "族谱: 【震起鄱阳泰云开，万家承祖育英才。】本表修订于 2016.03.31。", 12cm);
shipout_lineage(wang_rixi,     "wang",  "王姓世系表", "族谱: 【寿同日月，福齐海天。】本表修订于 2016.03.31。", 12cm);
shipout_lineage(chen_baixin,   "chen",  "陈姓世系表", "本表修订于 2016.03.31。", 9cm); 
shipout_lineage(zhao_tonghan,  "zhao",  "赵姓世系表", "本表修订于 2016.03.31。", 9cm);
shipout_lineage(huang_dacai,   "huang", "黄姓世系表", "族谱: 【必甲凤文国，大佩祖宗志；士子\underline{广登朝，荣华传万世}；大道生民广，渊源少浩长。】由于当时家族人丁不兴旺，其中打下划线的辈分被跳过，后两句为再续谱。宗祠对联: 【家藏东观文章古，世守西江孝友风。】本表修订于 2016.03.31。", 27cm);

