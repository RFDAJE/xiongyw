/*
 * created(bruin, 2014-08-25)
 * last updated(bruin, 2014-11-14)
 *
 */

settings.tex = "xelatex";

texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{arialuni.ttf}");
/* 
 * treat the following also as CJK
 *
 * http://www.unicode.org/charts/PDF/U2460.pdf: Enclosed Alphanumerics
 * http://www.unicode.org/charts/PDF/U2600.pdf: Miscellaneous Symbols
 * http://www.unicode.org/charts/PDF/U2700.pdf: Dingbats
 */
texpreamble("\xeCJKsetcharclass{\"2460}{\"27BF}{1}");


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


/*
 * 据《周髀算經》，八尺表杆正午晷长:
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

// return the length of the shadow of GUI, as an arithmetic progression.
// radian range: (0, pi), where,
// - 0 represents winter soltice, with fixed value 1.0,
// - pi represents summer soltice, with fixed value 0; 
// and this function provides other values in between.
// notes: why pi not 2 pi? because the rest half circle is just a mirror;
real gui_arithmetic(real radian)
{
    if(radian < 0 || radian > pi){
	return 0;
    }
    
    return (1. - radian / pi);
}

// return the length of the shadow of GUI, employing cos() function.
real gui_sine(real radian)
{
    if(radian < 0 || radian > pi){
	return 0;
    }
    
    return cos(radian / 2.);
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
 * return the bounding box of a path[]:
 * - [0]: low-left point
 * - [1]: up-right point
 */
pair[] bound_box(path[] pp){
    pair[] bb;
    real xmin = infinity, ymin = infinity;  
    real xmax = -infinity, ymax = -infinity;

    for (path p: pp) {
        pair sw = min(p), ne = max(p);
        if(sw.x < xmin) xmin = sw.x;
        if(sw.y < ymin) ymin = sw.y;
        if(ne.x > xmax) xmax = ne.x;
        if(ne.y > ymax) ymax = ne.y;
    }

    bb.push((xmin, ymin));
    bb.push((xmax, ymax));

    return bb;
}

/*
 * circularly bend a path[]: typically a return from texpath()
 *
 * The idea: a cubic-bezier path is completely determined by the coordinations of its nodes 
 * and the associated control points (pre/post)...so translating a path is the same as to 
 * translate all its points (nodes and control points).
 *
 * A path[] can be treated as a rectangle (i.e., its bounding box), which represents the 
 * "source" area before the translation; The "destination" of the translation in a circular
 * bend is an area has 4 boundaries: two arcs (inner, and outer), and two straight lines 
 * (which are part of the radius having length r2-r1). 
 * 
 * If we can map each horizontal line from the source bb into an arc inside the destination, 
 * then we can map each point from the source into the destination, as each source point 
 * must be on a source line (the same apply for vertical lines in the source bb).
 *
 * So, bending a path is just "translating" the position of each node and its control points
 * in the path, and using the translated coordinates to "clone" a new path (it seems there is
 * no way to change the coordinates of the points of a path by assigning operation).
 * 
 * Note that the concavity/convexity of the guides may change due to the bend, or even change
 * from concave to convex, or vice vesa. Adjust the parameters for best results desired.
 *
 * The following is an example of using this function:
 * 
 * path[] C = texpath("中文E");
 * path[] bend = bend_path(C, 10, 12, 30, 10);
 * 
 * draw(C);
 * draw(bend);
 */
path[] bend_path(path[] pp, // array of paths
                 real r1, // inner radius
                 real r2, // outer radius
                 real start, // start angle in degree
                 real angle_span){ // angle span in degree

    path[] _normalize(path[]) = new path[] (path[] pp){
        pair[] bb = bound_box(pp);
        path[] pp2;

        // shift + scale
        for (path p: pp) {
            p = shift (-bb[0].x, -bb[0].y) * p;
            p = scale(1 / (bb[1].x - bb[0].x), 1 / (bb[1].y - bb[0].y)) * p;
            pp2.push(p);
        }

        return pp2;
    };

    /*
     * translate the normalized (x, y) 
     */
    pair _trans(pair, real, real, real) = new pair (pair xy, real r1, real r2, real angle_span) {
        // first translate into polar coordinate (radius, theta)
        real radius = r1 + (r2 - r1) * xy.y;
        real theta = angle_span * (1.0 - xy.x);

        // then return in (x, y)
        return (radius * Cos(theta), radius * Sin(theta));
    };

    /*
     * clone a normalized path with translation of positions of the nodes and the control points
     */
    path _clone_path(path) = new path (path p) {
        path clone;
        for (int i = 0; i < size(p); ++ i) {
            if(i == 0) {
                clone = clone.._trans(point(p, i), r1, r2, angle_span);
            } else {
                clone = clone..controls _trans(postcontrol(p, i-1), r1, r2, angle_span) and _trans(precontrol(p, i), r1, r2, angle_span) .. _trans(point(p, i), r1, r2, angle_span);
            }
        }

        if (cyclic(p)) {
            //write("cyclic");
            clone = clone..controls _trans(postcontrol(p, size(p) - 1), r1, r2, angle_span) and _trans(precontrol(p, 0), r1, r2, angle_span) .. _trans(point(p, 0), r1, r2, angle_span) .. cycle;
        }

        return clone;
    };

    


    // 1. normalize
    path[] pp_norm = _normalize(pp);

    // 2. clone with translation & rotate
    path[] pp_clone;
    for (path p: pp_norm) {
        pp_clone.push(rotate(start) * _clone_path(p));
    }

    return pp_clone;
}



/*
 * evenly distributed annotation around the circumference of a circle
 */
void circular_annotate(real r1, // radius for inner circle
                       real r2, // radius for outter circle
                       string[] texts, // array of the annoation text. the length of the array determines how to divide circumference into ranges;
                       bool text_inside = true, // way of annotation: inside ranges, or across ranges?
                       bool bend_text = false,  // only long text needs to bend
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
        //write(middle[0]);
        end[0] = relpoint(p, 1.0);

        // the tang/norm direction of the arc at each point
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
        /*
        if(text_inside) {
            label(scale(text_scale) * rotate(degrees(middle[1])) * Label(texts[i], middle[0]), dp);
        }
        else {
            label(scale(text_scale) * rotate(degrees(start[1])) * Label(texts[i], start[0]), dp);
        }
        */

        // the path[] for the text
        path[] text = texpath(Label(texts[i]));
        pair[] bb = bound_box(text);
        real text_width = bb[1].x - bb[0].x;
        real text_height = bb[1].y - bb[0].y;
        // calculate the target height/width, by scaling the text height to the 3/5 * (r2-r1)
        real r_gap = (r2 - r1) * 2 / 5;  /* 1/5 on top, 1/5 at bottom */
        real text_height2 = (r2 - r1) * 3 / 5;
        real text_width2 = text_width / text_height * text_height2;
        real rad = text_width2 / ((r1 + r2) / 2); // text区域对应的夹角(弧度)
        real deg = Degrees(rad);
        //write(deg);
        if (bend_text) {
            text = bend_path(text, r1 + r_gap / 2, r2 - r_gap / 2, degrees(middle[0]) - deg / 2, deg);
        } else {
            text = scale(text_width2 / text_width, text_height2 / text_height) * text;
            text = rotate(degrees(middle[1])) * text;
            text = shift(middle[0]) * text;
        }
        //draw(text, dp);
        fill(text, dp);
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

void draw_color_background(real r1, real r2) {

     path pie = rotate(-45) * buildcycle(arc((0, 0), r1, 0, 90), (0, r1)--(0, r2), arc((0, 0), r2, 90, 0), (r2, 0)--(r1, 0));

     fill(pie, lightgreen);
     fill(rotate(90) * pie, gray);
     //fill(rotate(180) * pie, gray);   // blanc pour automne
     fill(rotate(270) * pie, lightred);

     fill(scale(r1) * unitcircle, lightyellow);
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



/*************************************************************************
 * draw stuff now 
 *************************************************************************/
/*
 * draw the invisible line to extend the margin of the picture
 */
draw(shift(-7,-7)*scale(7*2)*unitsquare, white);


/*
 * 青赤黄白黑 背景
 */

draw_color_background(2.0, 6.4);

/*
 * 阴阳鱼和八卦
 */
draw_yinyang();


// 八卦：http://zh.wikipedia.org/wiki/%E5%85%AB%E5%8D%A6
circular_annotate(1.0, 1.4, new string[]{"坎", "艮", "震", "巽", "离", "坤", "兌", "乾"}, draw_r1=false, draw_r2=false, draw_delim=false);

circular_annotate(1.4, 2.0, new string[]{"☵", "☶", "☳", "☴", "☲", "☷", "☱", "☰"}, draw_r1=false, draw_r2=false, draw_delim=false);

/*
 * 十二生肖
 */
circular_annotate(2.0, 2.4, new string[]{"鼠", "牛", "虎", "兔", "龍", "蛇", "馬", "羊", "猴", "雞", "狗", "豬"}, draw_r2=false);
circular_annotate(2.4, 3.0, new string[]{"子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"}, draw_r1=false);

/*
 * 子午流注
 */
//circular_annotate(3.0, 3.3, new string[]{"足少陽膽經", "1", "足厥陰肝經", "3", "手太陰肺經", "5", "手陽明大腸經", "7", "足陽明胃經", "9", "足太陰脾經", "11", "手少陰心經", "13", "手太陽小腸經", "15", "足太陽膀胱經", "17", "足少陰腎經", "19", "手厥陰心包經", "21", "手少陽三焦經", "23"}, bend_text=true, draw_r1=false, draw_r2=false, draw_delim=false);

//circular_annotate(3.0, 3.3, new string[]{"足少陽膽經", "①", "足厥陰肝經", "③", "手太陰肺經", "⑤", "手陽明大腸經", "⑦", "足陽明胃經", "⑨", "足太陰脾經", "⑪", "手少陰心經", "①", "手太陽小腸經", "③", "足太陽膀胱經", "⑤", "足少陰腎經", "⑦", "手厥陰心包經", "⑨", "手少陽三焦經", "⑪"}, bend_text=true, draw_r1=false, draw_r2=false, draw_delim=false);

circular_annotate(3.0, 3.4, new string[]{"夜半", "①", "雞鳴", "③", "平旦", "⑤", "日出", "⑦", "食時", "⑨", "隅中", "⑪", "日中", "①", "日昳", "③", "晡時", "⑤", "日入", "⑦", "黃昏", "⑨", "人定", "⑪"}, bend_text=true, draw_r1=false, draw_r2=false, draw_delim=false);

//circular_annotate(3.25, 3.6, new string[]{"足少陽", "足厥陰", "手太陰", "手陽明", "足陽明", "足太陰", "手少陰", "手太陽", "足太陽", "足少陰", "手厥陰", "手少陽"}, bend_text=true, draw_r1=false, draw_r2=false, draw_delim=false);

circular_annotate(3.4, 3.9, new string[]{"\texttt{\bfseries GB}", "\texttt{\bfseries LR}", "\texttt{\bfseries LU}",  "\texttt{\bfseries LI}", "\texttt{\bfseries ST}", "\texttt{\bfseries SP}", "\texttt{\bfseries HT}", "\texttt{\bfseries SI}", "\texttt{\bfseries BL}", "\texttt{\bfseries KI}", "\texttt{\bfseries PC}", "\texttt{\bfseries TE}"}, bend_text=true, draw_r1=false, draw_r2=false);

circular_annotate(3.9, 4.3, new string[]{"足少陽膽經", "足厥陰肝經", "手太陰肺經", "手陽明大腸經", "足陽明胃經", "足太陰脾經", "手少陰心經", "手太陽小腸經", "足太陽膀胱經", "足少陰腎經", "手厥陰心包經", "手少陽三焦經"}, bend_text=true, draw_r1=false, draw_delim=true);


/* 
 * 二十四节气
 */
circular_annotate(4.3, 4.7, new string[]{"冬月", "臘月", "正月",  "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月"}, bend_text=true, draw_r2=false);

circular_annotate(4.7, 4.9, new string[]{"\texttt{12.23}", "\texttt{1.6}", "\texttt{1.21}", "\texttt{2.6}", "\texttt{2.21}", "\texttt{3.6}", "\texttt{3.21}", "\texttt{4.6}", "\texttt{4.21}", "\texttt{5.6}", "\texttt{5.21}", "\texttt{6.6}", "\texttt{6.21}", "\texttt{7.8}", "\texttt{7.23}", "\texttt{8.8}", "\texttt{8.23}", "\texttt{9.8}", "\texttt{9.23}", "\texttt{10.8}", "\texttt{10.23}", "\texttt{11.8}", "\texttt{11.23}", "\texttt{12.8}"}, bend_text=true, draw_r1=false, draw_r2=false, draw_delim=false);

circular_annotate(4.9, 5.4, new string[]{"冬至", "小寒", "大寒", "立春", "雨水", "驚蟄", "春分", "清明", "穀雨", "立夏", "小滿", "芒種", "夏至", "小暑", "大暑", "立秋", "處暑", "白露", "秋分", "寒露", "霜降", "立冬", "小雪", "大雪"}, bend_text=true, draw_r1=false, draw_delim=false);


/*
 * 四灵二十八宿
 */
circular_annotate(5.4, 5.8, new string[]{"虛","女","牛","斗","箕","尾","心",
                                         "房","氐","亢","角","軫","翼","張",
                                         "星","柳","鬼","井","參","觜","畢",
                                         "昴","胃","婁","奎","壁","室","危"}, draw_r1=false);

circular_annotate(5.8, 6.4, new string[]{"玄\ \ \ 武","青\ \ \ 龍","朱\ \ \ 雀","白\ \ \ 虎"}, bend_text=true);

draw(scale(6.5)*unitcircle,  defaultpen + linewidth(line_width_in_bp * 3));

// 四方
circular_annotate(6.6, 7.0, new string[]{"北","東","南","西"}, draw_r1=false, draw_r2=false, draw_delim=false);



// this is to make 4 seasons/directions more distinguishable

/*
draw_4_delims(new real[]{2.0, 3.0,   
                         3.4, 4.7,   
                         5.4, 6.4}, 
              defaultpen + linewidth(line_width_in_bp * 6) + linecap(0), 
              defaultpen + linewidth(line_width_in_bp * 4) + linecap(2) + white);
*/









// 六气
/*
circular_annotate(4.7, 5.3, new string[]{"太陽寒水", "厥陰風木", "少陰君火", 
                                         "少陽相火", "太陰濕土", "陽明燥金"}, text_scale=0.3);

circular_annotate2(4.7, 5.3, new real[]{0,45, 45,135, 135,180, 180,225, 225,315, 315, 360}, 
                   new string[]{"厥陰風木", "少陰君火", "少陽相火", "太陰濕土", "陽明燥金", "太陽寒水"}, text_scale=0.3);
*/


//draw(unitsquare);
//draw(scale(2)*unitcircle);

//draw(unitcircle);
//draw(W--E, grey+linewidth(0.2));
//draw(N--S, grey+linewidth(0.2));
