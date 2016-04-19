import "lineage.asy" as lineage;




/* ######################################################################## */
//
//  陶渊明
//
/* ######################################################################## */

person male_unknown   = person(true,  unknown, blank, question, blank);
person female_unknown = person(false, unknown, blank, question, blank);
person ellipse        = person(true, "", "$\cdots$", question, question); 



person kan              = person(true,  "", "侃",       "259", "334", hao="长沙公", order="1"); 

person xia              = person(true,  "", "夏",       question, question, order="2"); 
person bin             = person(true,  "", "斌",       question, question); 
person zhan             = person(true,  "", "瞻",       question, question); 
person ell1             = clone(ellipse);
person mao              = person(true,  "", "茂",       question, question); 
person mou0             = person(false,  "", unknown,       question, question); 
person meng_jia         = person(true,  "孟", "嘉",       question, question); 
person ell2             = clone(ellipse);

person hong              = person(true,  "", "弘",       question, question, order="3"); 
person qian_fu           = person(true,  "", "潜父",       question, question); 
person qian_shu           = person(true,  "", "夔",       question, question); 
person ell3             = clone(ellipse);
person ell4             = clone(ellipse);
person qian_mu           = person(false,  "", "潜母",       question, question); 

person zhuo              = person(true,  "", "绰",       question, question, order="4"); 
person qian              = person(true,  "", "潜",       "365", "427", hao="五柳先生"); 

person yanshou              = person(true,  "", "延寿",       question, question, order="5"); 


/* 
 * 关系 
 */
kan.has(xia, bin, zhan, ell1, mao, mou0, ell2);
zhan.has(hong);
hong.has(zhuo);
zhuo.has(yanshou);

mao.has(qian_fu, qian_shu);
mou0.marry(meng_jia);
mou0.give_birth(ell3);
mou0.give_birth(qian_mu, ell3);
mou0.give_birth(ell4, qian_mu);

qian_fu.has(qian);

g_debug = false;
g_kid_h_gap *= 1.;  // 调整两辈之间间距
name_pen_female = linewidth(0.1) + deepred + fontsize(g_glyph_width);
shipout_lineage(kan, "taoyuanming", "陶渊明家族关系", "制于2016年4月19日。", 15cm, pack=true);

