/*
 * created(bruin, 2014-08-25)
 * last updated(bruin, 2014-09-1)
 *
 * 据《周髀算经》，八尺表杆正午晷长:
 * - 冬至 (winter solstice): 1.35丈
 * - 夏至 (summer solstice): 0.16丈
 * - 24节气的晷长为等差数列，公差为：(1.3-0.16)/12=0.0991666666丈，亦即 9.9分1小分
 * 注：1丈=10尺=3.33333米；1尺=10寸；1寸=10分；1分=6小分
 *
 * 若“标准化”晷长，即以夏至为0，冬至为1，则公差为1/12。
 * 取上北下南左西右东，即冬至为北、夏至为南、春分为东、秋分为西，则以冬至为首以顺时针
 * 为序，各节气的标准化晷长为：
 * 冬至，小寒，大寒，立春，雨水，惊蛰，春分，清明，谷雨，立夏，小满，芒种：1 ~  1/12
 * 夏至，小暑，大暑，立秋，处暑，白露，秋分，寒露，霜降，立冬，小雪，大雪：0 ~ 11/12
 *
 * 但等差数列得出的并不是传统的阴阳图。若采用cos()函数计算晷长序列，得出的图更符合惯例。
 * 这里分别定义两种计算晷长序列。
 */

settings.tex = "xelatex";

texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{arialuni.ttf}");
texpreamble("\xeCJKsetcharclass{\"2600}{\"267F}{1}");  // this tells xetex to treat "symbol misc" as CJK


import math;
//import three;
//import labelpath3;
//import labelpath;
import fontsize;

/*
 * about sizes
 */
real pt2cm = 1 / 72.27 * 2.54; // 1 pt = 1/72.27 inch; 
real bp2cm = 1 / 72 * 2.54;    // 1 bp = 1/72 inch
real cm2pt = 1 / pt2cm;
real cm2bp = 1 / bp2cm;

real unit_size_in_cm = 0.5;   // make yinyang circle size about 1x1cm
real unit_size_in_pt = unit_size_in_cm * cm2pt;
real line_width_in_cm = 0.01;
real line_width_in_bp = line_width_in_cm * cm2bp;
real font_size_in_cm = 0.4;
real font_size_in_pt = font_size_in_cm * cm2pt; 
real font_size_in_user = font_size_in_cm / unit_size_in_cm;

unitsize(unit_size_in_pt);
defaultpen(linewidth(line_width_in_bp));
defaultpen(fontsize(font_size_in_pt));
//defaultpen(basealign(0));

//label("1", (0, 0), invisible);
//real font_height = (max(currentpicture).y - min(currentpicture).y) * bp2cm / unit_size_in_cm;



/*
 *
 */
int n5 = 5, n8 = 8, n12 = 12, n24 = 24, n64 = 64;
pair O=0, S=(0,-1), N=(0,1), W=(-1,0), E=(1,0);
int i;


// return the length of the shadow of GUI, as an arithmetic progression.
// radius range: (0, pi), where,
// - 0 represents winter soltice, with fixed value 1.0,
// - pi represents summer soltice, with fixed value 0; 
// and this function provides other values in between.
// notes: why pi not 2 pi? because the rest half circle is just a mirror;
real gui_arithmetic(real radius)
{
    if(radius < 0 || radius > pi){
	return 0;
    }
    
    return (1. -radius / pi);
}

// return the length of the shadow of GUI, employing cos() function.
real gui_sine(real radius)
{
    if(radius < 0 || radius > pi){
	return 0;
    }
    
    return cos(radius / 2.);
}

// this function returns a cyclic guide for the "black fish", which,
// - starts from winter soltice (0, 1)
// - goes inside the circle SE-ward CW
// - passes the center point
// - changes to CCW and continue
// - passes the summer soltice (0, -1)),
// - then goes back to the winter soltice CW by exactly following the circumference of the circle.
// the nodes in the guide are over-all in CW order.
// n: 1/4 of the number of points around the circle. 
guide fish(int n, real gui_interp(real)) 
{
    int i;
    
    // 1. determine the array of shadow length, starting from winter solstice, in CW order
    real[] gui;  
    for(i = 0; i < n * 4; ++ i){
	real rad = radians(90. / n * i);
	if(rad > pi){
	    rad = rad - pi;
	}
    	gui[i] = gui_interp(rad);
	//write(gui[i]);
    }

    // 2. obtain the direction for each point, respective to the shadow array.
    pair[] roots;
    for(i = 0; i < n * 4; ++ i){
	roots[i] = unityroot(n * 4, i);  // starting from (1,0), in CCW order
    }

    // make it starts from winter soltice and in CW order, by indexing an array by an array
    /*
    //int[] index24 = {6, 5, 4, 3, 2, 1, 0, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7};
    int[] index = reverse(n + 1);
    index.append(reverse(n * 4));
    index = index[:n * 4];
    roots = roots[index];  
    
    for(i = 0; i < n * 4; ++ i){
    dot(" ", roots[i], red);
    dot(roots2[i], green);
    }
    */	

    roots = reflect(S, N) * (rotate(90) * roots);  // rotate followed by vertical reflect/mirror

    // make it cyclic
    //roots.cyclic = true;

    // 3. the interior part of the "fish" curve.
    guide fish;
    // right-hand half: in CW order
    for(i = 0; i < n * 2; ++ i){
	pair p = O + gui[i] * dir(roots[i]);
	fish = fish..p;
	//dot(" ", p);
    }
    // the center of the circle
    fish = fish..(0, 0);
    // left-hand half: in CCW order, not including the summer soltice
    for(i = n * 4 - 1; i > n * 2; -- i){
	pair p = O + gui[i] * dir(roots[i]);
	fish = fish..p;
	//dot(" ", p);
    }
    // the summer soltice: need special treatment as its shadow length is zero.
    fish = fish..{E}(0, -1){W};

    // 4. add the exterior part, to make it cyclic.
    for(i = n * 2 + 1; i < n * 4; ++ i){
	fish = fish..roots[i];
    }
    fish = fish..{E}cycle;
    
    return fish;
}

void draw_yinyang(){

    // circle
    draw(unitcircle);

    // fish
    filldraw(fish(6, gui_sine));
    //draw(fish(6, gui_arithmetic), grey);
    
    // eyes
    fill(circle((-0.35, 0), 1/12.));
    unfill(circle((0.35, 0), 1/12.));
}


/*
 * evenly distributed annotation around the circumference of a circle
 */
void circular_annotate(real r1, // radius for inner circle
                       real r2, // radius for outter circle
                       string[] texts, // array of the annoation text. the length of the array determines how to divide circumference into ranges;
                       bool text_inside = true, // way of annotation: inside ranges, or across ranges?
                       real text_scale=0.5,     // scale factor for the text
                       bool draw_r1=true,       // draw the inner circle?
                       bool draw_r2=true,       // draw the outer circule?
                       bool draw_delim=true,    // draw the delim between two adjacent ranges
                       bool fill=false,         // fill in between the two circles?
                       pen dp=defaultpen)    
{
    int i, n = texts.length;

    /*
     * 1. equally divide the circumference into n regions:
     *
     * - roots[] are the center of each region, and
     * - delimits[] are the boundary betw regions.
     *
     * the order of the regions and delimites are both CW, 
     * while the regions start from the due north, and the dilimites[]
     * is cyclic, starting from the "left" boundary of the first region.
     */
    pair[] roots, delimits;
    for(i = 0; i < n; ++ i){
	roots[i] = unityroot(n, i);
    }
    roots = reflect(S, N) * (rotate(90) * roots);
    //roots = rotate(90) * reflect(S, N) * roots;
    //roots = reflect(O, roots[0]) * roots;
    delimits = rotate(360. / n / 2) * roots;
    delimits.cyclic = true;

    /*
     * 2. label_path[] for each region is an arc of radius (r1+r2)/2, inside the region, CW direction
     */
    path[] label_path;
    for(i = 0; i < n; ++ i){
	label_path[i] = scale((r1 + r2) / 2.) * arc(O, delimits[i], delimits[i + 1], CW);
    }

    /*
     * 3. draw text for each region
     */
    
    for(i = 0; i < n; ++ i){

	path p = label_path[i];

        // the start/middle/stop point of the arc:
        // - [0]: the point
        // - [1]: the tang at the point
        // - [2]: the norm at the point
        pair start[], middle[], end[];

        start[0] = relpoint(p, 0.);
        middle[0] = relpoint(p, 0.5); // midpoint(p);
        end[0] = relpoint(p, 1.0);

        // the tang/norm direction of the arc at mdpoint
	real len = arclength(p);
        start[1] = dir(p, arctime(p, 0));
        start[2] = rotate(90) * start[1];
	middle[1] = dir(p, arctime(p, len / 2));
	middle[2] = rotate(90) * middle[1];
	end[1] = dir(p, arctime(p, len));
	end[2] = rotate(90) * end[1];

	//draw(p, Arrow);
	//draw(md--(md + tang), Arrow);
	//draw(md--(md - norm), Arrow);

        /* labelpath, but not support xelatex for chinese */
	//labelpath(texts[i], shift(scale((r1-r2)/2.5) * norm) * p);

        /* labelpath3, not clear how to use it yet */
        //path3 p3 = path3(p);
	//draw(labelpath(texts[i], p3));

        /* simple label */
        if(text_inside) {
            label(scale(text_scale) * rotate(degrees(middle[1])) * Label(texts[i], middle[0]), dp);
        }
        else {
            label(scale(text_scale) * rotate(degrees(start[1])) * Label(texts[i], start[0]), dp);
        }
    }

    /*
     * 3. circles
     */
    if(draw_r1) {	
        draw(scale(r1)*unitcircle, dp);
    }

    if(draw_r2) {
        draw(scale(r2)*unitcircle, dp);
    }

    /*
     * 4. delimites
     */
    for(i = 0; i < n; ++ i){
	
	//draw(scale(r1)*roots[i]--scale(r2)*roots[i], dotted+grey);

        if(draw_delim) {
            if(text_inside) {
	        draw(scale(r1)*delimits[i]--scale(r2)*delimits[i], dp);
            }
            else{
	        draw(scale((r1+r2)/2)*roots[i]--scale(r2)*roots[i], dp);
            }
        }
    }
}

/*
 * manually distributed annotation around the circumference of a circle
 */
void circular_annotate2(real r1, // radius for inner circle
                        real r2, // radius for outter circle
                        real[] angles,  // array of the (start_angle, stop_angle). angle 0 is due north, CW.
                        string[] texts, // array of the corresponding texts.
                        bool text_inside = true, // way of annotation: inside ranges, or across ranges?
                        real text_scale=0.5,     // scale factor for the text
                        bool draw_r1=true,       // draw the inner circle?
                        bool draw_r2=true,       // draw the outer circule?
                        bool draw_delim=true,    // draw the delim between two adjacent ranges
                        bool fill=false,         // fill in between the two circles?
                        pen dp=defaultpen)    
{
    int i, n = texts.length;

    /*
     * 1. read the regions from the argument:
     *
     * - delimits_left[] are the unit direction of the left boundary of each region
     * - middles[] are the unit direction of the center of each region
     * - delimits_right[] are the unit direction of the right boundary of each region
     *
     * the order of the regions and delimites are both CW.
     */
    pair[] delimits_left, middles, delimits_right;
    for(i = 0; i < n; ++ i){
        real gauche = angles[i*2];
        real droit = angles[i*2+1];
        real moyen = (gauche + droit) / 2;
	delimits_left[i] = rotate(-gauche) * dir(O--(0,1));
	delimits_right[i] = rotate(-droit) * dir(O--(0,1));
        middles[i] = rotate(-moyen) * dir(O--(0,1));
    }

    /*
     * 2. label_path[] for each region is an arc of radius (r1+r2)/2, inside the region, CW direction
     */
    path[] label_path;
    for(i = 0; i < n; ++ i){
	label_path[i] = scale((r1 + r2) / 2.) * arc(O, delimits_left[i], delimits_right[i], CW);
    }

    /*
     * 3. draw text for each region
     */
    
    for(i = 0; i < n; ++ i){

	path p = label_path[i];

        // the start/middle/stop point of the arc:
        // - [0]: the point
        // - [1]: the tang at the point
        // - [2]: the norm at the point
        pair start[], middle[], end[];

        start[0] = relpoint(p, 0.);
        middle[0] = relpoint(p, 0.5); // midpoint(p);
        end[0] = relpoint(p, 1.0);

        // the tang/norm direction of the arc at mdpoint
	real len = arclength(p);
        start[1] = dir(p, arctime(p, 0));
        start[2] = rotate(90) * start[1];
	middle[1] = dir(p, arctime(p, len / 2));
	middle[2] = rotate(90) * middle[1];
	end[1] = dir(p, arctime(p, len));
	end[2] = rotate(90) * end[1];

	//draw(p, Arrow);
	//draw(md--(md + tang), Arrow);
	//draw(md--(md - norm), Arrow);

        /* labelpath, but not support xelatex for chinese */
	//labelpath(texts[i], shift(scale((r1-r2)/2.5) * norm) * p);

        /* labelpath3, not clear how to use it yet */
        //path3 p3 = path3(p);
	//draw(labelpath(texts[i], p3));

        /* simple label */
        if(text_inside) {
            label(scale(text_scale) * rotate(degrees(middle[1])) * Label(texts[i], middle[0]), dp);
        }
        else {
            label(scale(text_scale) * rotate(degrees(start[1])) * Label(texts[i], start[0]), dp);
        }
    }

    /*
     * 3. circles
     */
    if(draw_r1) {	
        draw(scale(r1)*unitcircle, dp);
    }

    if(draw_r2) {
        draw(scale(r2)*unitcircle, dp);
    }

    /*
     * 4. delimites
     */
    for(i = 0; i < n; ++ i){
	
	//draw(scale(r1)*roots[i]--scale(r2)*roots[i], dotted+grey);

        if(draw_delim) {
            if(text_inside) {
	        draw(scale(r1)*delimits_left[i]--scale(r2)*delimits_left[i], dp);
	        draw(scale(r1)*delimits_right[i]--scale(r2)*delimits_right[i], dp);
            }
            else{
	        draw(scale((r1+r2)/2)*middles[i]--scale(r2)*middles[i], dp);
            }
        }
    }
}


void draw_4_delims(real[] radius, pen noir, pen blanc)
{
    int i, n = radius.length;
    pair[] north_west;

    // put some negative margin
    for(i = 0; i < n / 2; ++ i){
        real delta = 0.01;
        radius[i*2] -= delta;
        radius[i*2+1] += delta;
    }

    
    for(i = 0; i < n; ++ i) {
        north_west[i] = rotate(45) * (radius[i], 0);
    }

    for(i = 0; i < n / 2; ++ i){
        draw(north_west[i*2]--north_west[i*2+1], noir);
        draw(rotate(90) * (north_west[i*2]--north_west[i*2+1]), noir);
        draw(rotate(180) * (north_west[i*2]--north_west[i*2+1]), noir);
        draw(rotate(270) * (north_west[i*2]--north_west[i*2+1]), noir);

        draw(north_west[i*2]--north_west[i*2+1], blanc);
        draw(rotate(90) * (north_west[i*2]--north_west[i*2+1]), blanc);
        draw(rotate(180) * (north_west[i*2]--north_west[i*2+1]), blanc);
        draw(rotate(270) * (north_west[i*2]--north_west[i*2+1]), blanc);
    }
}

/*
 * circularly bend a guide array (guides)
 *
 * the idea: the source, i.e. the guides can be seen as a rectangle (which is
 * the bounding box of the guides), and the destination's boundary 
 * has four segments: two arcs (inner, and outer), and two straight lines 
 * (which are part of the radius having length r2-r1). If we can map each horizontal
 * line from the source into an arc inside the destination, then we can map each point 
 * from the source into the destination, as each source point must be on a source line.
 * (the same apply for vertical lines in the source rectangle).
 *
 * so, bending a guide is just transforming the position of each node in the guide.
 * 
 * 1. transform the guides by shifting/scaling it into an unitsquare, i.e., box((0,0),(1,1)).
 *    so the x/y coordinate of each point in the guides is now a horizontal/vertial ratio.
 * 2. let the destination arc starts from positive part of x-axis and extends CCW, using (0,0) 
 *    as the origin
 * 3. rotate to the desired position
 *
 * Note that the concavity/convexity of the guides may change due to the bend, or even change
 * from concave to convex, or vice vesa. Adjust the parameters for best results desired.
 *
 * The following is an example of using this function:
 *
 * guide[] g = {
 *    (0,0)..(50, 70)..(100,100), 
 *    (100, 100)..(150,30)..(200,0),
 *    (0,0)..(50,0)..(100,0)..(150,0)..(200,0),
 *    (0,50)..(50,50)..(100,50)..(150,50)..(200,50),
 *    (0,100)..(50,100)..(100,100)..(150,100)..(200,100)
 * };
 *
 * draw(g);
 * guide[] g2 = bend_guide(g, 280, 300, 30, 30);
 * draw(g2);
 */
 
guide[] bend_guide(guide[] gg, // array of guides
                 real r1, // inner radius
                 real r2, // outer radius
                 real start, // start angle in degree
                 real angle){ // angle span in degree
    /* 
     * 1. unify the guides
     */
    // find out the bounding box
    real xmin = infinity, ymin = infinity;  
    real xmax = -infinity, ymax = -infinity;
    for (guide g: gg) {
        path p = g; // need resolve the guide to get the bounding box, i.e. min()/max()
        pair sw = min(p), ne = max(p);
        if(sw.x < xmin) xmin = sw.x;
        if(sw.y < ymin) ymin = sw.y;
        if(ne.x > xmax) xmax = ne.x;
        if(ne.y > ymax) ymax = ne.y;
    }
    //write(xmin, ymin, xmax, ymax);

    // shift + scale
    guide[] gg2;
    for (guide g: gg) {
        g = shift (-xmin, -ymin) * g;
        g = scale(1 / (xmax - xmin), 1 / (ymax - ymin)) * g;
        gg2.push(g);
    }

    /*
     * 2.
     */
    guide[] gg3;
    for (guide g2: gg2) {
        guide g3;
        path p2 = g2;
        // bend g2 into g3
        for (int i = 0; i < size(p2); ++ i) {
            real r, theta;
            path rp; // arc path
            pair p = point(p2, i);
            //write("p=", p);
            r = r1 + (r2 - r1) * p.y;
            //write("r=", r);
            theta = angle * (1 - p.x);
            //write("theta=", theta);
            rp = arc((0, 0), r,  0., theta, CCW);
            p = relpoint(rp, 1.0);  // now we have the end point of the arc
            //write("final p=", p);
            //write();
            g3 = g3..p;
        }

        // add g3 into gg3
        gg3.push(g3);
    }

    /*
     * 3. rotate
     */
    guide[] gg4;
    for( guide g: gg3) {
        g = rotate(start) * g;
        gg4.push(g);
    }

    return gg4;
}




/*
 * draw stuff now 
 */

draw_yinyang();

//circular_annotate(1, 2, new string[]{"冬", "春", "夏", "秋"});

// 八卦：http://zh.wikipedia.org/wiki/%E5%85%AB%E5%8D%A6
circular_annotate(1.0, 1.4, new string[]{"坎", "艮", "震", "巽", "离", "坤", "兑", "乾"}, 0.3, draw_r1=false, draw_r2=false, draw_delim=false);
circular_annotate(1.4, 2.0, new string[]{"☵", "☶", "☳", "☴", "☲", "☷", "☱", "☰"}, 0.5, draw_r1=false, draw_r2=false, draw_delim=false);
circular_annotate(2.0, 2.4, new string[]{"鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"}, 0.3, draw_r2=false);
circular_annotate(2.4, 3.0, new string[]{"子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"}, 0.5, draw_r1=false);
//circular_annotate(3.0, 3.4, new string[]{"23", "1", "3", "5", "7", "9", "11", "13", "15", "17", "19", "21"}, text_inside=false, 0.3, draw_r1=false, draw_delim=false);
circular_annotate(3.0, 3.5, new string[]{"胆", "1", "肝", "3", "肺", "5", "大肠", "7", "胃", "9", "脾", "11", 
                                         "心", "13", "小肠", "15", "膀胱", "17", "肾", "19", "心包", "21", "三焦", "23"}, 
                  text_inside=true, 0.3, draw_r1=false, draw_delim=false);
//circular_annotate(3.0, 3.4, new string[]{"胆", "肝", "肺", "大肠", "胃", "脾", "心", "小肠", "膀胱", "肾", "心包", "三焦"}, 0.3);

circular_annotate(3.5, 4.0, new string[]{"冬月", "腊月", "正月",  "二月", "三月", "四月", 
                                         "五月", "六月", "七月", "八月", "九月", "十月"}, 0.3);
circular_annotate(4.0, 4.3, new string[]{"12.23", "1.6", "1.21", "2.6", "2.21", "3.6", 
                                         "3.21", "4.6", "4.21", "5.6", "5.21", "6.6", 
                                         "6.21", "7.8", "7.23", "8.8", "8.23", "9.8", 
                                         "9.23", "10.8", "10.23", "11.8", "11.23", "12.8"}, 
                  text_scale=0.3, draw_r1=false, draw_r2=false, draw_delim=false);

circular_annotate(4.3, 4.7, new string[]{"冬至", "小寒", "大寒", "立春", "雨水", "惊蛰", 
                                         "春分", "清明", "谷雨", "立夏", "小满", "芒种", 
                                         "夏至", "小暑", "大暑", "立秋", "处暑", "白露", 
                                         "秋分", "寒露", "霜降", "立冬", "小雪", "大雪"}, 
                  text_scale=0.35, draw_r1=false, draw_delim=false);

// 六气

circular_annotate(4.7, 5.3, new string[]{"太阳寒水", "厥阴风木", "少阴君火", 
                                         "少阳相火", "太阴湿土", "阳明燥金"}, text_scale=0.3);

/*
circular_annotate2(4.7, 5.3, new real[]{0,45, 45,135, 135,180, 180,225, 225,315, 315, 360}, 
                   new string[]{"厥阴风木", "少阴君火", "少阳相火", "太阴湿土", "阳明燥金", "太阳寒水"}, text_scale=0.3);
*/
// 四灵二十八宿
circular_annotate(5.3, 5.8, new string[]{"虚","女","牛","斗","箕","尾","心",
                                         "房","氐","亢","角","轸","翼","张",
                                         "星","柳","鬼","井","参","觜","毕",
                                         "昴","胃","娄","奎","壁","室","危"}, text_scale=0.3, draw_r1=false);

circular_annotate(5.8, 6.3, new string[]{"玄\ 武","青\ 龙","朱\ 雀","白\ 虎"}, text_scale=0.3);

draw(scale(6.4)*unitcircle,  defaultpen + linewidth(line_width_in_bp * 3));

// 四方
circular_annotate(6.4, 6.8, new string[]{"北","东","南","西"}, text_scale=0.3, draw_r1=false, draw_r2=false, draw_delim=false);

// this is to make 4 seasons/directions more distinguishable

draw_4_delims(new real[]{2.0, 3.0,   3.5, 4.0,   5.3, 6.3}, 
              defaultpen + linewidth(line_width_in_bp * 4) + linecap(0), 
              defaultpen + linewidth(line_width_in_bp * 2) + linecap(2) + white);

//draw(unitsquare);
//draw(scale(2)*unitcircle);

//draw(unitcircle);
//draw(W--E, grey+linewidth(0.2));
//draw(N--S, grey+linewidth(0.2));
