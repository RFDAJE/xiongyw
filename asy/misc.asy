/*
 * created(bruin, 2014-01-06): my own packge for misc routines
 *
 * To use this "package", add the following in the begining of your .asy file:
 *
 * import "misc.asy" as misc;
 */

import math;

 
/* use PostScript unit in both picture and frame */
size(0, 0);
unitsize(0, 0);

private pair O=0, S=(0,-1), N=(0,1), W=(-1,0), E=(1,0);


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
 * We can normalize the "source" path[] into an unit square, and the map the unit square
 * into the anglar area which starts from east and grows CCW, as shown below:
 *
 *       x ^                             X ^
 *         |                               |
 *         |-------+(1,1)                  |    `
 *         |///////|                       | o /  \
 *         |///////|          ==>          |  \    \
 *         |///////|                       |   \    \
 *      ---+------------> y            ----+----\----+------> Y
 *        o|                              O|       (1,1)
 *
 * Bending a path is just "translating" the position of each node and its control points
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
     * translate the normalized (x, y): 避免上宽下窄的情况
     */
    pair _trans2(pair, real, real, real) = new pair (pair xy, real r1, real r2, real angle_span) {

        // 要避免上宽下窄，就是要让每条圆弧的长度都一样长。这里采用半径 (r1+r2)/2 所对应的圆弧（下称中间弧）的长度为统一的弧长。
        // 先计算出点 xy 对应的半径 radius，目的点必然在以radius为半径的圆弧上。这里不用角度而用弧长来确定目的点：
        // 先假设这个点落在中间弧上，并以中间弧的中点为原点，取顺时针为负，逆时针为正，算出这个点在中间弧上的弧长坐标；再把这个
        // 弧长坐标移到目的弧上，而得到目的点。

        // use the length of arc at the center as the "standard" arc length
        path mid_arc = arc((0,0), (r1+r2)/2, 0, angle_span);
        real arc_len = arclength(mid_arc);

        // xy 点所对应的弧长坐标
        real len = (0.5 - xy.x) * arc_len;

        // xy 点所对应的弧的半径
        real radius = r1 + (r2 - r1) * xy.y;
        // 以 radius 为半径，以 angle_span/2 为起点，按顺时针和逆时针分别作弧
        path arc_ccw = arc((0,0), radius, angle_span/2, angle_span, CCW);
        path arc_cw =  arc((0,0), radius, angle_span/2, angle_span, CW);

        if (len >= 0) {
            return arcpoint(arc_ccw, len);
        } else {
            return arcpoint(arc_cw, -len);
        }
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
void circular_annotate(picture pic, 
                       real r1, // radius for inner circle
                       real r2, // radius for outter circle
                       string[] texts, // 文字數組, CW排列。數組的長度即表示把圓周等分為幾份；
                                       // 數組的第一個元素被顯示在正上方(即X軸正向所指的方向)。
                       bool text_inside = true, // way of annotation: inside ranges, or across ranges?
                       real angular_shift = 0,  // 整體的 CW 旋轉度數
                       bool bend_text = false,  // only long text needs to bend
                       bool draw_r1=true,       // draw the inner circle?
                       bool draw_r2=true,       // draw the outer circule?
                       bool draw_delim=true,    // draw the delim between two adjacent ranges
                       pen[] text_colors = new pen[],
                       pen[] fill_colors = new pen[],
                       pen dp=defaultpen)
{
    int i, n = texts.length;

    if(text_colors.length < n) {
        text_colors = array(n, dp);
    }

    if(fill_colors.length < n) {
        fill_colors = array(n, invisible);
    }

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
	roots[i] = rotate(angular_shift) * unityroot(n, i);
    }
    roots = reflect(S, N) * (rotate(90) * roots);
    delimits = rotate(360. / n / 2) * roots;
    delimits.cyclic = true;

    /*
     * 2. label_path[i] (for each region) is an arc of radius (r1+r2)/2, inside the region, CW direction
     */
    path[] label_path;
    for(i = 0; i < n; ++ i){
	label_path[i] = scale((r1 + r2) / 2.) * arc(O, delimits[i], delimits[i + 1], CW);
    }

    /*
     * 3.1. fill each region
     */
    path[] regions;
    for (i = 0; i < n; ++ i) {
        path arc1 = scale(r1) * arc(O, delimits[i], delimits[i + 1], CW);
        path arc2 = scale(r2) * arc(O, delimits[i+1], delimits[i], CCW);
        path line1 = arcpoint(arc1, arclength(arc1))--arcpoint(arc2, 0);
        path line2 = arcpoint(arc2, arclength(arc2))--arcpoint(arc1, 0);
        regions[i] = buildcycle(arc1, line1, arc2, line2);

        // debug code
        /* 
        if(i == 0){
            write(arc1);
            write(line1);
            write(arc2);
            write(line2);
            write(regions[i]);
            write("--");
            draw(arc1, red, arrow=Arrow);
            draw(arc2, green, arrow=Arrow);
            draw(line1, blue, arrow=Arrow);
            draw(line2, black, arrow=Arrow);
        }
        */

        fill(pic, regions[i], fill_colors[i]);
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

        fill(pic, text, dp + text_colors[i]);
    }

    /*
     * 3. circles
     */
    if(draw_r1) {	
        draw(pic, scale(r1)*unitcircle, dp);
    }

    if(draw_r2) {
        draw(pic, scale(r2)*unitcircle, dp);
    }

    /*
     * 4. delimites
     */
    if (draw_delim == true) {
        for(i = 0; i < n; ++ i){
            draw(pic, scale(r1)*delimits[i]--scale(r2)*delimits[i], dp);
        }
    }
}

/*
 * add x/y margins to a picture
 */
picture add_margin(picture pic=currentpicture,
           real xmargin=0.05, // in percentage
           real ymargin=xmargin,
           pen dp=invisible) {

    pair size = size(pic, user=true);
    pair min = min(pic, user=true);
    pair max = max(pic, user=true);

    real delta_x = size.x * xmargin;
    real delta_y = size.y * ymargin;

    draw(pic, (min.x-delta_x, min.y-delta_y)--(max.x+delta_x, max.y+delta_y), dp);

    return pic;
}
