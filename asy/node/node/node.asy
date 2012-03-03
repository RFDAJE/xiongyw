/* 
 * Created(bruin, 2008-07-04): generic node/tree struct and default drawing routine.
 * updated(bruin, 2008-09-19): added tree styles & orientations; draw different levels; 
 *                             added more comments to the code.
 * updated(bruin, 2008-09-26): added collapse icons (minus/plus) support for STEP style;
 *
 * updated(bruin, 2011-12-10): add two customized draw tree function: draw_dir_tree(root), and draw_call_seqeunce(root)";
 *
 * $Id$
 *
 * To use this "package", add the following in the begining of your .asy file:
 *
 * import "node.asy" as node;
 */


 
 
/* we use PostScript unit in both picture and frame */
size(0, 0);
unitsize(0, 0);


/*
 * Tree styles: FLAT, STEP, CASE
 * -----------------------------
 *
 * FLAT (the default style):
 *
 *  root --+-- kid1    
 *         |         
 *         +-- kid2  
 *
 * STEP:
 *
 *  root
 *    |
 *    +--- kid1                
 *    |
 *    +--- kid2
 *
 * CASE:
 *
 *         kid1
 *  root {
 *         kid2
 */
int TREE_STYLE_FLAT = 0;
int TREE_STYLE_STEP = 1;
int TREE_STYLE_CASE = 2;

/*
 * Four orientations: LEFT, RIGHT, UP, DOWN
 * ----------------------------------------
 * using FLAT style to show different orientations:
 *
 * LEFT: as shown above (the default orientation)
 *
 * RIGHT: 
 *   
 *    kid1 --+-- root
 *           |
 *    kid2 --+
 * 
 * UP:
 *
 *  root
 *   |
 *   +-------+
 *   |       |
 *  kid1    kid2
 *
 * DOWN:
 * 
 *  kid1    kid2
 *   |       |
 *   +-------+
 *   |
 *  root
 * 
 */
int TREE_ORIENT_LEFT  = 0;
int TREE_ORIENT_RIGHT = 1;
/* do we really need it? 
int TREE_ORIENT_UP    = 2;
int TREE_ORIENT_DOWN  = 3;
*/
/* default space between two nodes */
private real default_gene_gap = 20;
private real default_peer_gap = 6;

/* default pen for connection lines */
private pen default_line_pen = linewidth(0.4) + black + linecap(0); /* square cap */

/* 
 * this is used for alignment for picture attach()
 */
private pair se = 0.000001SE;
private pair sw = 0.000001SW;
private pair ne = 0.000001NE;
private pair nw = 0.000001NW;




/*
 * Data struct for the node (and the tree)
 * ---------------------------------------
 *
 * To use the data struct to define a tree, e.g.,
 * to build the following tree:
 *
 *  root--+-- kid1
 *        |
 *        +-- kid2 --+-- kid21
 *                   | 
 *                   +-- kid22
 *       
 * We simply do:
 * 
 *   node root = node("root");
 *   node kid1 = node("kid1");
 *   node kid2 = node("kid2");
 *
 *   root.attach(kid1, kid2);
 *   
 *   node kid21 = node("kid21");
 *   node kid22 = node("kid22");
 *
 *   kid2.attach(kid21, kid22);
 *
 */
struct node{

    string   text;
    string   priv; /* private data used for customized drawing of a node */

    /*
     * The following is a sample CASE style diagram (LEFT orientation):
     *
     *       |
     *       V
     *   --------                        +-----------+
     *    offset                       / |           |
     *                     +--------+  | +-----------+
     *   --------          |        | <
     *       ^          /  +--------+  | +----------+
     *       |          |              \ |          |
     *                  |                +----------+
     *                  |  +------------+
     *      +-------+   |  |            |
     *      | root  |  <   +------------+
     *      +-------+   |                 +-------+
     *                  |                 |       |
     *                  |              /  +-------+
     *                  |              |  
     *                  \  +-------+   |  +-------+
     *                     |       |  <   |       |
     *                     +-------+   |  +-------+
     *                                 |  
     *                                 \  +-------+
     *                                    |       |
     *                                    +-------+
     *
     *
     *  The diagram has the following characteristics:
     * 
     *   1. the "<" is at the middle point (vertically) of the brace;
     *   2. the root node is center-aligned (vertically) with the brace;
     *   3. the brace covers _node_ pictures of all the kids, but not the 
     *      _tree_ picture of the kids.
     *
     *  To draw such a tree, we need to know the following info:
     *   
     *   a: the size of root node's picture (it's trivial);
     *   b: the size of accumulated picture of all kids (also trivial);
     *   c: the vertical position to place the brace (e.g., the vertical
     *      offset as shown above), this can be achived by adding an offset
     *      number to each node (the offset will be refered only when the 
     *      node is either the first or the last kid of its parent).
     *   c: the height of the brace. with kids' offsets, this can be
     *      obtained, by the following fomula:
     *      brace_height = sum_of_kids_height - offset_of_the_1st_kid 
     *               - height_of_the_last_kid + offset_of_the_last_kid;
     *
     *  So the only extra thing is to calculate and record the "offset" of
     *  a node. For leaf nodes, the offset is firstly set as half of the 
     *  node height (when the node is been drawn). if this node has kids, then
     *  this offset needs to be updated after it has been combined with its 
     *  kids (and the brace in between).
     *  
     */
    real     offset;  /* used for draw TREE_STYLE_CASE */

    node     dad;
    node     kids[];
    

    /* default constructor */
    void operator init(string text, string priv = ""){
    
        /* the text may contains '_', which is reserved by Tex */
        this.text = replace(text, "_", "\_"); 
        this.priv = priv;
        this.dad = null;
    }

    /* adding variable number of kids */
    void attach(... node _kids[]){   
        this.kids.append(_kids);
        for(int i = 0; i < _kids.length; ++ i){
            _kids[i].dad = this;
        }
    }
};


/* 
 * get the picture size 
 */
pair pic_size(picture pic)
{
    pair min, max;
    min = min(pic);
    max = max(pic);
    pair size=(max.x - min.x, max.y - min.y);
    return size;
}

/* 
 * get the frame size 
 */
pair frame_size(frame f){
    pair max=max(f);
    pair min=min(f);
    pair size=(max.x - min.x, max.y - min.y);
    return size;
}


/* this is the default node draw function */
picture default_draw_node(node p)
{
    picture pic;
    draw(pic, 
         "\texttt{"+p.text+"}", 
         box,
         (0, 0), 
         1,            /* margin between text to the bounding box */
         black,        /* color of the bounding box */
         NoFill);      /* fill patterns. 
                             NoFill:          only draw the bounding box;
                             Fill(color):     only fill, no bounding box. use Fill(white) for no-fill & no-box;
                             FillDraw(color): both fill & box;
                       */
                       
    p.offset = pic_size(pic).y / 2;
                             
    return pic;
}


/* 
 * draw the tree. passing a node drawing function as an argument, for customized drawing.
 *
 * the simplist way is to use all default values. for example:
 *
 * picture pic_root = draw_tree(root);
 * attach(pic_root.fit(), (0,0), se);
 * shipout("root_tree.eps");
 * erase(currentpicture);
 *
 */
picture draw_tree(node root, 
                  int level = 100, /* default to draw all levels. 100 should be big enough :) */
                  int style = TREE_STYLE_FLAT,
                  int orient = TREE_ORIENT_LEFT,
                  bool show_collapse_icon = false,  /* only apply to STEP style */
                  real gene_gap = default_gene_gap, /* generation gap: gap between root and its kid */
                  real peer_gap = default_peer_gap,
                  pen line_pen = default_line_pen,
                  picture cust_draw_node(node node) = default_draw_node) 
{

    /* 
     * the picture of the tree is composed by 3 parts: 
     *
     *  1. pic of the root
     *  2. pic of the kids 
     *  3. pic of the connection betw root and kids 
     *
     * NB: part 2 & 3 is optional
     */
    picture pic; 

    if(root != null && level > 0){

        picture self; /* the picture of the root node */
        picture kids; /* the picture of all kids put together */
        picture conn; /* the picture of connections betwee root and kids */

        pair    kids_size[];  /* size of each kid's pic */ 
        real    brace_height; /* use for CASE style only */
        int     i;
        
        /* 
         * 1. draw the root node 
         */
        self = cust_draw_node(root);

        if(level == 1 || root.kids.length == 0){ /* leaf */
            return self;
        }

        /* 
         * 2. draw kids: draw each kid and put them togeher according to the orientation
         */
        for(i = 0; i < root.kids.length; ++ i){
            
            picture k = draw_tree(root.kids[i], level - 1, style, orient, show_collapse_icon, gene_gap, peer_gap, line_pen, cust_draw_node);
            kids_size.push(pic_size(k));
            
            if(orient == TREE_ORIENT_RIGHT){
                /*
                 *       +-------+
                 *       |       |
                 *       +-------+
                 *    
                 *    +----------* 
                 *    |////// SW |
                 *    +----------+
                 *            
                 *             ...
                 */
                attach(kids, k.fit(), i == 0? (0, 0) : (0, - pic_size(kids).y - peer_gap), sw);
            }
            /*
            else if(orient == TREE_ORIENT_UP){
                attach(kids, k.fit(), i == 0? (0, 0) : (pic_size(kids).x + peer_gap, 0), se);
            }
            else if(orient == TREE_ORIENT_DOWN){
                attach(kids, k.fit(), i == 0? (0, 0) : (pic_size(kids).x + peer_gap, - pic_size(kids).y), ne);
            }
            */
            else{ /* the default: TREE_ORIENT_LEFT */
                /*
                 *    +-------+
                 *    |       |
                 *    +-------+
                 *    
                 *    *----------+ 
                 *    |SE ///////|
                 *    +----------+
                 *            
                 *    ...
                 */
                attach(kids, k.fit(), i == 0? (0, 0) : (0, - pic_size(kids).y - peer_gap), se);
            }
        }

        /* 
         * 3. draw connection: totally 6 kinds of connections
         *
         * -----+---------------------------------
         *     \|     FLAT      STEP       CASE
         * ---- +--------------------------------
         *      |
         *      |   --+--       |         
         * LEFT |     |         +--        {
         *      |     +--       |        
         *      |               +--
         * -----+---------------------------------
         *      |
         * RIGHT|   --+--         |     
         *      |     |         --+        }
         *      |   --+           |
         *      |               --+
         * -----+---------------------------------
         *
         * The following notes take "LEFT" orientation and "FLAT/STEP" style as example.
         *
         * The picture of a node occupies a rectangle box as shown below. Two points 
         * L & R represent the center points on the left and right side of the box.
         *
         *   +--------------+
         *   |              |
         *   * L            * R
         *   |              |
         *   +--------------+
         *   
         * For FLAT style, a connection line connects the root's R point to the 
         * children's L points, as shown below:
         * 
         *   +--------------+           +---------+
         *   |              |           |         |
         *   |            R *-----+-----* L       |
         *   |              |     |     |         |
         *   +--------------+     |     +---------+
         *                        |
         *                        |
         *                        |     +--------------+
         *                        |     |              |
         *                        +-----* L            |
         *                              |              |
         *                              +--------------+
         *
         * So the connection line is composed by 1 vertical line (if more than 1 child) and 
         * horizontal lines for each child (the line for the 1st child is longer).
         *
         * For STEP style, a connection line connects a point A on the bottom
         * line of the root box to children's L points, as shown below:
         *
         *   +--------------+
         *   |              |
         *   |  root        |
         *   |              |
         *   +-----*--------+
         *         |
         *         |
         *         |       +--------------+
         *         |       |              |
         *         +-------* L    child   |
         *                 |              |
         *                 +--------------+
         * 
         * So the connection line is composed by 1 vertical line and horizontal lines for 
         * each child (of the same length).
         *
         */

	/* this is to prepare the collapse icons (minus, plus, or nothing), if required */	
        real icon_size = default_peer_gap;
        picture plus, minus, nothing; /* plus for uncollapsed,  and minus collapsed */
        /* fill the square_out, and draw square_in. this is to keep a small gap around the icon (with the lines) */
        path square_out = (0, 0)--(icon_size, 0)--(icon_size, icon_size)--(0, icon_size)--cycle;
        path square_in  = (icon_size * 0.1, icon_size * 0.1)--(icon_size * 0.9, icon_size * 0.1)--(icon_size * 0.9, icon_size * 0.9)--(icon_size * 0.1, icon_size * 0.9)--cycle;
	if(style == TREE_STYLE_STEP && show_collapse_icon){        
	    /* minus icon */
            filldraw(minus, square_out, white, white);
            draw(minus, square_in, line_pen);
            draw(minus, (icon_size * 0.25, icon_size / 2)--(icon_size - icon_size * 0.25, icon_size / 2), line_pen);
            /* plus icon */
            filldraw(plus, square_out, white, white);
            draw(plus, square_in, line_pen);
            draw(plus, (icon_size * 0.2, icon_size / 2)--(icon_size - icon_size * 0.2, icon_size / 2), line_pen);
            draw(plus, (icon_size / 2, icon_size * 0.2)--(icon_size / 2, icon_size * 0.8), line_pen);
            /* nothing icon: invisibule, just to keep a consistant size of the connection shape */
            draw(nothing, square_out, invisible);
        }

        if(orient == TREE_ORIENT_RIGHT){
            if(style == TREE_STYLE_STEP){
                real y, conn_y[];

                y = - pic_size(self).y / 2 - peer_gap;
                conn_y.push(y);
                for(i = 1; i < root.kids.length; ++ i){
                    y -= kids_size[i - 1].y + peer_gap;
                    conn_y.push(y);
                }

                /* draw the vertical line first */
                draw(conn, (gene_gap / 2, 0)--(gene_gap / 2, conn_y[root.kids.length - 1]), line_pen);
                
                /* draw horizontal bars */
                for(i = 0; i < root.kids.length; ++ i){
                    draw(conn, (0, conn_y[i])--(gene_gap / 2, conn_y[i]), line_pen);
                    if(show_collapse_icon && root.kids[i].kids.length > 0){
                        if(level < 3)
                            attach(conn, plus.fit(), (gene_gap / 2, conn_y[i]), (0,0));
                        else
                            attach(conn, minus.fit(), (gene_gap / 2, conn_y[i]), (0,0));
                    }
                    else{
                        attach(conn, nothing.fit(), (gene_gap / 2, conn_y[i]), (0,0));
                    }
                }
            }
            else if(style == TREE_STYLE_CASE){
                if(root.kids.length == 1){
                    /* if there is just one kid, then not use brace, use a dash line instead */
                    draw(conn, (0, 0)--(gene_gap, 0), line_pen);
                    brace_height = pic_size(conn).y;
                }
                else{
                    brace_height = pic_size(kids).y - root.kids[0].offset 
                                                    - kids_size[root.kids.length - 1].y
                                                    + root.kids[root.kids.length - 1].offset; 
                    /* draw the brace */
                    label(conn, minipage("\ensuremath{\left.\vcenter{\hsize=0pt\rule{0pt}{"+format("%f", brace_height)+"bp}}\right\}}", gene_gap), (0,0), NoFill);

                    /*
                     * note: at this point, pic_size(conn).y != brace_height, it's bigger. thus using pic_size(conn).y
                     *   to obtain brace_height will be inaccurate. so we put brace_height's outside the inner loop, 
                     *   thus we can refer it later (in step 4 for anchoring).
                     */

                    /* update the root's offset now */
                    root.offset = brace_height / 2 + root.kids[0].offset;
                }
            }
            else{ /* TREE_STYLE_LEFT, the default */
                real y, conn_y[];
                
                y = 0
                conn_y.push(y);
                for(i = 1; i < root.kids.length; ++ i){
                    y -= kids_size[i - 1].y + peer_gap;
                    conn_y.push(y);
                }
                
                /* draw the horizontal lines */
                for(i = 0; i < root.kids.length; ++ i){
                    draw(conn, (i == 0? gene_gap : gene_gap / 2, conn_y[i])--(0, conn_y[i]), line_pen);
                }
                
                /* draw the vertical line, if it exists */
                if(root.kids.length > 1){
                    draw(conn, (gene_gap / 2, conn_y[0])--(gene_gap / 2, conn_y[i - 1]), line_pen);
                }
            }
        }
        else{ /* TREE_ORIENT_LEFT, the default */
            if(style == TREE_STYLE_STEP){
                real y, conn_y[];

                y = - pic_size(self).y / 2 - peer_gap;
                conn_y.push(y);
                for(i = 1; i < root.kids.length; ++ i){
                    y -= kids_size[i - 1].y + peer_gap;
                    conn_y.push(y);
                }

                /* draw the vertical line first */
                draw(conn, (0, 0)--(0, conn_y[root.kids.length - 1]), line_pen);
                
                /* draw horizontal bars */
                for(i = 0; i < root.kids.length; ++ i){
                    draw(conn, (0, conn_y[i])--(gene_gap / 2, conn_y[i]), line_pen);
                    if(show_collapse_icon && root.kids[i].kids.length > 0){
                        if(level < 3)
                            attach(conn, plus.fit(), (0, conn_y[i]), (0,0));
                        else
                            attach(conn, minus.fit(), (0, conn_y[i]), (0,0));
                    }
                    else{
                        attach(conn, nothing.fit(), (0, conn_y[i]), (0,0));
                    }
                }
            }
            else if(style == TREE_STYLE_CASE){
                if(root.kids.length == 1){
                    /* if there is just one kid, then not use brace, use a dash line instead */
                    draw(conn, (0, 0)--(gene_gap, 0), line_pen);
                    brace_height = pic_size(conn).y;
                }
                else{
                    brace_height = pic_size(kids).y - root.kids[0].offset 
                                                    - kids_size[root.kids.length - 1].y
                                                    + root.kids[root.kids.length - 1].offset; 
                    /* draw the brace */
                    label(conn, minipage("\ensuremath{\left.\vcenter{\hsize=0pt\rule{0pt}{"+format("%f", brace_height)+"bp}}\right\{}", gene_gap), (0,0), NoFill);

                    /*
                     * note: at this point, pic_size(conn).y != brace_height, it's bigger. thus using pic_size(conn).y
                     *   to obtain brace_height will be inaccurate. so we put brace_height's outside the inner loop, 
                     *   thus we can refer it later (in step 4 for anchoring).
                     */

                    /* update the root's offset now */
                    root.offset = brace_height / 2 + root.kids[0].offset;
                }
            }
            else{ /* TREE_STYLE_LEFT, the default */
                real y, conn_y[];
                
                y = 0
                conn_y.push(y);
                for(i = 1; i < root.kids.length; ++ i){
                    y -= kids_size[i - 1].y + peer_gap;
                    conn_y.push(y);
                }
                
                /* draw the horizontal lines */
                for(i = 0; i < root.kids.length; ++ i){
                    draw(conn, (i == 0? 0 : gene_gap / 2, conn_y[i])--(gene_gap, conn_y[i]), line_pen);
                }
                
                /* draw the vertical line, if it exists */
                if(root.kids.length > 1){
                    draw(conn, (gene_gap / 2, conn_y[0])--(gene_gap / 2, conn_y[i - 1]), line_pen);
                }
            }
        }


        /* 
         * 4. put all pieces together 
         *
         * The "tree pic" of a kid (i.e., with its own children attached) is different
         * to the "node pic" of the kid node itself. We are anchoring the "tree pic" here.
         * To anchor the "tree pic" into the right place (i.e, the L point of the node pic
         * connects to the connection line), there is an *assumption* that the node pic heights
         * of the root and its 1st kid is the same. Though the chance is very small, this 
         * assumption could be wrong (in that case, the anchor point will be inaccurate). 
         */

        if(orient == TREE_ORIENT_RIGHT){
            if(style == TREE_STYLE_STEP){
                attach(pic, self.fit(), (0, 0), se);
                attach(pic, conn.fit(), (pic_size(self).x - gene_gap / 2, - pic_size(self).y), sw);
                if(show_collapse_icon){
                    attach(pic, kids.fit(), (pic_size(self).x - gene_gap - icon_size / 2, - pic_size(self).y - peer_gap), sw);
		}
		else{
                    attach(pic, kids.fit(), (pic_size(self).x - gene_gap, - pic_size(self).y - peer_gap), sw);
		}
            }
            else if(style == TREE_STYLE_CASE){
                attach(pic, self.fit(), (0, 0), E);
                attach(pic, conn.fit(), (- 2, 0), W);
                /* anchor the kids */
                real y1 = brace_height / 2 + root.kids[0].offset - pic_size(kids).y / 2;
                attach(pic, kids.fit(), (- pic_size(conn).x, y1), W);
            }
            else{  /* TREE_STYLE_FLAT, the default */
                attach(pic, self.fit(), (0, 0), se);
                attach(pic, conn.fit(), (0, - pic_size(self).y / 2), sw);
                attach(pic, kids.fit(), (- gene_gap, 0), sw);
            }
        }
        else{ /* TREE_ORIENT_LEFT, the default */
            if(style == TREE_STYLE_STEP){
                attach(pic, self.fit(), (0, 0), se);
                attach(pic, conn.fit(), (gene_gap / 2, - pic_size(self).y), se);
                if(show_collapse_icon){
                    attach(pic, kids.fit(), (gene_gap + icon_size / 2, - pic_size(self).y - peer_gap), se);
		}
		else{
                    attach(pic, kids.fit(), (gene_gap, - pic_size(self).y - peer_gap), se);
		}
            }
            else if(style == TREE_STYLE_CASE){
                attach(pic, self.fit(), (0, 0), E);
                if(root.kids.length == 1)
                    attach(pic, conn.fit(), (pic_size(pic).x + gene_gap / 2, 0), E);
                else
                    attach(pic, conn.fit(), (pic_size(pic).x, 0), E);
                /* anchor the kids */
                real y1 = brace_height / 2 + root.kids[0].offset - pic_size(kids).y / 2;
                attach(pic, kids.fit(), (pic_size(pic).x + pic_size(conn).x, y1), E);
            }
            else{ /* TREE_STYLE_FLAT, the default */
                attach(pic, self.fit(), (0, 0), se);
                attach(pic, conn.fit(), (pic_size(pic).x, - pic_size(self).y / 2), se);
                attach(pic, kids.fit(), (pic_size(pic).x, 0), se);
            }
        }

    }

    return pic;
}

 

/*================================================================================================ 
 draw folder tree. to use it, call: 
   picture root = draw_dir_tree(root);
 ================================================================================================ */ 

real   font_size = 10;      /* font size */

/* it's assumed that the private data of a node is either "d" or "f", which represent
   "directory" and "file" respectively */
string dir = "d";
string file = "f";

/* 
 * sample node draw function to draw folder 
 * icon around directory names, as shown below:
 *
 *          _______
 *         /       \
 *        +------------------+
 *        |                  |
 *        | mydirectoryname  |
 *        |                  |
 *        +------------------+
 */
picture dir_draw_func(node p)
{
	picture pic;
	real mini_h = font_size; 
	real margin = 2 ; /* h & v margins */
    pair min, max;

  label(pic, "\texttt{"+p.text+"}");
  
  
   /* get the text dimension */
   min = min(pic);
   max = max(pic);
   
   /* make sure the height is at least min_h */
   if((max.y - min.y) < mini_h){
       real delta = (mini_h - (max.y - min.y)) / 2;
       max = (max.x, max.y + delta);
       min = (min.x, min.y - delta);
   }
   
   /* take margin into account */
   min -= (margin, margin);
   max += (margin, margin);
   
   /* draw the box */
   draw(pic, min--(min.x, max.y)--max--(max.x, min.y)--cycle,  p.priv == dir? defaultpen : invisible);

   /* draw the folder part */
   draw(pic, (min.x, max.y)--(min.x+2, max.y+2)--(min.x+8, max.y+2)--(min.x+10, max.y), p.priv == dir? defaultpen : invisible);

   return pic;
}

picture draw_dir_tree(node root)
{
	return draw_tree(root, dir_draw_func, style=TREE_STYLE_FLAT, gene_gap=40);
}



/*================================================================================================ 
 draw call sequence. to use it, call: 
   picture root = draw_call_seq(root);
 ================================================================================================ */ 
picture draw_call_sequence(node root)
{
	return draw_tree(root, style=TREE_STYLE_FLAT, gene_gap=40);
}
