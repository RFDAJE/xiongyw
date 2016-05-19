var JSGO = (function(){

    /*##############################################################
      # constant definitions
      #############################################################*/
    const MAX_GRID =  19;          /* maximum board size, inclusive */
    const MIN_GRID =  2;           /* minimum board size, inclusive */
    const PASS = (MAX_GRID + 1);   /* (PASS, PASS) is a pass move */
    const MAX_HANDICAPS = 9;
    const MIN_HANDICAPS = 2;

    /*##############################################################
      # enum
      #############################################################*/
    const PLAYER = { 
        WHITE: "W",
        BLACK: "B",
        NONE:  "N"  // used to indicate KO status when there is no KO
    };

    /* 
     * vertex color (state): restrict the values to be 0,1,2,3, 
     * i.e, can be stored in two bits.
     */
    const COLOR = {
    	WHITE: "W",  /* occupied by a white stone */
    	BLACK: "B",  /* occupied by a white stone */
    	GREEN: "G",  /* not occupied and valid for the next mover */
    	RED: "R",  /* not occupied, but it's forbidden for the next mover, because of ko or suicide rules */
    };

    /* types of rules */
    const RULE = {
    	CHINESE: "CHI",
    	JAPANESE: "JAP",
    	INGS: "ING",
    	BRITISH: "BRI"
    };

    /* validity of a move */
    const MOVE = {
    	GOOD: 0,   /* move is valid */
    	PILE: 1,   /* invalid (vertex already occupied) */
    	INKO: 2,   /* invalid (vertex in ko_t) */
    	SUIC: 3,   /* invalid (suicide) */
    	RANG: 4,   /* invalid (vertex out of range) */ 
    	OVER: 5    /* invalid (the game was over) */
    };


    /* symmetry groups of a board configuration, defined by their generators:
     *
     * - I: identity
     * - H: horizontal flip
     * - V: vertical flip
     * - D: diagonal '/' flip
     * - DD: diagonal '\' flip
     * - R: counterclockwise 90 degree rotation
     * - R2: R*R
     *
     * the symmetry group of a square is denoted as D4, any symmetry groups of of a 
     * board configuration (of either a square or a rectangle board)  is a subgroup 
     * of D4. D4 has the following 10 subgroups:
     * - <I>
     * - <H>, <V>, <D>, <DD>, <R2>
     * - <R>, <R2,H>, <R2,D>
     * - D4
     */
    var SYMMETRY = { 
    	I: 0, /* identity, i.e., no symmetry */
    	H: 1,
    	V: 2,
    	D: 3,     /* only for square board */
    	DD: 4,    /* only for square board */
    	R: 5,     /* only for square board */
    	R2: 6,
    	R2H: 7,
    	R2D: 8,   /* only for square board */
    	D4: 9     /* only for square board */
    };

    /*##############################################################
      # data structures conventions (they are all JSON objects!)
      #############################################################*/
    
    /* a cross-point on board is called a vertex:
     *  var vertex =  {"row": 1, "col": 4};
     */

    /* an array of vertices 
     *  var vertices = {
     *      "len": 10,
     *      "rows": [1,2,3,4,5,6,7,8,9,10],
     *      "cols": [1,2,3,4,5,6,7,8,9,10]};
     */

    /* KO (jie2) status info 
     *  var KO = {
     *      // "who" indicate if ko_t exist and who is in KO:
	 *      // PLAYER.WHITE/PLAYER.BLACK: KO exist;
	 *      // PLAYER.NONE: no KO exits;
     *      "who": PLAYER.NONE, 
     *      "row": 0,
     *      "col": 0
     *      };
     */

    /* match state
     *  var mstate = {
     *      "nrow": 19,
     *      "ncol": 19,  // the board is not necessarilly square
     *      "rule": RULE.CHINESE,
     *
	 *
	 * data storing move history. 
	 *
	 * count is the # for the last move, moves[count] is the vertex of the move.
	 * we define 0 is the init count, and moves[0]={PASS, PASS} belongs to WHITE_PLAYER.
	 * so the first real move belongs to BLACK_PLAYER which has count=1. 
	 * handicaps are treated as consective moves where the WHITE_PLAYER makes 
	 * several PASS moves.
	 *
	 * the next mover can be derived from the count, i.e., count%2=0 means the next 
	 * mover is BLACK_PLAYER, which means black always moves on odd counts. 
	 *
	 * usually the total number of moves is smaller than the total number of vertices.
	 * though it's possible not so, but the possibility is quite small.
	 *	
	 *     "count": 10,
	 *     "rows":  [1,2,3,4,5,6,7,8,9,10],
	 *     "cols":  [1,2,3,4,5,6,7,8,9,10],
	 *
	 *     "ko": { "who": PLAYER.NONE, "row": 0, "col": 0},
	 *     "over": false,  // if the game is over. 
	 *
	 *     // vetices colors of the whole board, a two dimensional array
     *     //   we use the following board coordinate system:
     *     //
     *     //         Column # ------>
     *     //
     *     //         0 1 2 3 4 5 6 ... (ncol-1)
     *     //
     *     //   R  0  +-+-+-+-+-+-+-+-+-
     *     //   o  1  +-+-+-X-+-+-+-+-+-
     *     //   w  2  +-+-O-+-+-X-+-+-X-
     *     //      3  +-+-+-O-+-+-+-+-+-
     *     //   #  4  +-+-+-+-+-+-+-+-+-
     *     //      5  +-+-+-O-+-+-+-+-+-
     *     //   |  6  +-+-+-+-+-+-+-+-+-
     *     //   |  :  +-+-+-+-+-+-+-+-+-
     *     //   V  :  +-+-+-+-+-+-+-+-+-    
     *     //   (nrow-1)                        
     *
	 *     "color": [
	 *                [COLOR.GREEN,...],  // the first row
	 *                [...],
	 *                ...,
	 *              ],
	 */


    function mstate_create(nrow = 19, ncol = 19, rule = RULE.CHINESE) {

    	/* sanity check */
    	if(nrow > MAX_GRID || ncol > MAX_GRID || nrow < MIN_GRID || ncol < MIN_GRID) {
            console.log("ERROR: illegal board size!");
    		return null;
        }

        if (rule != RULE.CHINESE && rule != RULE.JAPANESE && rule != INGS && rule != RULE.BRITISH) {
            console.log("ERROR: illegal rule!");
            return null;
        }

        // board color: 2d array
        var color = new Array(nrow);
        for (var i = 0; i < nrow; i ++) {
            // color[i] = new Array(ncol);
            color[i] = Array.apply(null, Array(ncol)); // apply() treate holes as undefined elements
            color[i].forEach(function(v, i, a) { a[i] = COLOR.GREEN; });
        }
        
        return {
            "nrow": nrow,
            "ncol": ncol,
            "rule": rule,
        	"count": 0, // the 1st move is always start from 0 for white with a PASS move
        	"rows": [PASS], 
        	"cols": [PASS], 
        	"ko": { "who": PLAYER.NONE, "row": -1, "col": -1 },
        	"over": false,
        	"color": color
        };
    }

    function mstate_clone(mstate) {
        return JSON.parse(JSON.stringify(mstate));
    }

    function mstate_get_vertex_color(mstate, row, col){
        // check range
        if (row >= mstate.nrow || col >= mstate.ncol || row < 0 || col < 0) {
            console.log("ERROR: row/col out of range!");
            return null;
        }
        return mstate.color[row][col];
    }

    const DIRECT = 0;          /* direct called */
    const NORTH  = 1;          /* northern search */
    const EAST   = 2;          /* eastern search */
    const SOUTH  = 4;          /* southern search */
    const WEST   = 8;          /* western search */

    /*
     * It recursively finds out all the pieces of a string has vertex 
     * (row, col), returns the nr of pieces in the string.
     *
     * "dir" tells the recursive search direction of the caller, take
     * one of DIRECT/NORTH/EAST/SOUTH/WEST, where DIRECT means it's a
     * direct call from outside, not recursively called by itself.
     */
    function s_get_string(state, row, col, vertices, dir){

    	var who;  /* occupant of (row, col), either BLACK or WHITE */ 
    	var i;

    	if(dir == DIRECT){  /* called from outside, not recursive call */
    		vertices.len = 0;
        }

    	/* check if (row, col) already in vertices */
    	for(i = 0; i < vertices.len; i ++){
    		if(vertices.rows[i] == row && vertices.cols[i] == col) {
    			return 0;    /* return value ignored */
              }
    	}

    	/* add the current piece in the string list first */
    	vertices.rows.push(row);
    	vertices.cols.push(col);
    	vertices.len ++;

    	who = mstate_get_vertex_color(state, row, col);

    	/*
    	 * recursively search in N/E/S/W directions 
    	 */
    	 
    	/* northern search */
    	if(!(dir & SOUTH) && row > 0 && mstate_get_vertex_color(state, row - 1, col) == who)
    		s_get_string(state, row - 1, col, vertices, NORTH);

    	/* eastern search */
    	if(!(dir & WEST) && col < state.ncol - 1 && mstate_get_vertex_color(state, row, col + 1) == who)
    		s_get_string(state, row, col + 1, vertices, EAST);

    	/* southern search */
    	if(!(dir & NORTH) && row < state.nrow - 1 && mstate_get_vertex_color(state, row + 1, col) == who)
    		s_get_string(state, row + 1, col, vertices, SOUTH);

    	/* western search */
    	if(!(dir & EAST) && col > 0 && mstate_get_vertex_color(state, row, col - 1) == who)
    		s_get_string(state, row, col - 1, vertices, WEST);

    	if(dir != DIRECT){
    		/* recursive called, ignored return value */ 
    		return 0; 
    	}
    	else{
    		/* called from outside, return string size */
    		return vertices.len;
    	}
    }

    /*
     * It checks whether the vertex (row, col) is a Degree Of Freedom.
     * If it is and not in "vdof" yet, add (row, col) to "vdof".
     *
     * RETURN VALUE
     * 0:  normal terminate
     * - 1:  (row, col) not empty, simply return
     */
    function s_check_dof(state, row, col, dof) {

    	var i, found;

    	/* dof means it should be unoccupied */
    	if(mstate_get_vertex_color(state, row, col) == COLOR.BLACK ||
    	   mstate_get_vertex_color(state, row, col) == COLOR.WHITE) {
    		return   - 1;
        }

    	/* check if (row, col) already in "dof" */
    	found = false; /* assume not in "dof" first */
    	for(i = 0; i < dof.len; i ++){
    		if(dof.cols[i] == col && dof.rows[i] == row){
    			found = true;
    			break;
    		}
    	}

    	if(!found){  /* add (row, col) to "dof" */
    		dof.rows.push(row);
    		dof.cols.push(col);
    		dof.len ++;
    	}

    	return 0;
    }


    /*
     * finds out all the pieces of a string has vertex at (row, col), 
     * and store the pieces' locatioins supplied "vlist". It's 
     * guaranteed that "vlist" has been allocated enought space by 
     * the caller.
     *
     * RETURN: the string and its dof
     */
    function mstate_get_string(state, row, col){

    	/* range check */
    	if(row >= state.nrow || col >= state.ncol || row < 0 || col < 0) {
            console.log("ERROR: out of range!");
    		return null;
        }

    	/* sanity check: it should not be empty */
    	if(mstate_get_vertex_color(state, row, col) != COLOR.BLACK &&
    	   mstate_get_vertex_color(state, row, col) != COLOR.WHITE) {
            console.log("ERROR: the vertices is not occupied by any player yet!");
    		return null;
        }

        var string = {"len": 0, "rows": [], "cols": []};
        var dof = {"len": 0, "rows": [], "cols": []};

        /* get the string first */
    	var size = s_get_string(state, row, col, vertices, DIRECT);

        /* get the dof of the string */
    	for (var i = 0; i < size; i ++) {

    		var ro, co;
    		ro = string.rows[i];
    		co = string.cols[i];

    		/* southern check */
    		if(ro < state.nrow - 1)  
    			s_check_dof(state, ro + 1, co, dof);

    		/* eastern check */
    		if(co < state.ncol - 1)  
    			s_check_dof(state, ro, co + 1, dof);

    		/* northern check */
    		if(ro > 0)                
    			s_check_dof(state, ro - 1, co, dof);

    		/* western check */
    		if(co > 0)                
    			s_check_dof(state, ro, co - 1, dof);
    	}

        /* return the string and its dof */
        return {"vertices": vertices, "dof": dof};
    }


    /*
     * -------------------------------------------------------------------
     */


	return {
	    // constants
        "MAX_GRID": MAX_GRID,
        "MIN_GRID": MIN_GRID,
        "PASS"    : PASS,
        "MAX_HANDICAPS": MAX_HANDICAPS,
        "MIN_HANDICAPS": MIN_HANDICAPS,
        // enums
        "PLAYER": PLAYER,
        "COLOR": COLOR,
        "RULE": RULE,
        "MOVE": MOVE,
        "SYMMETRY": SYMMETRY,
        // methods:
        "mstate_create": mstate_create,
        "mstate_clone": mstate_clone,
        "mstate_get_vertex_color": mstate_get_vertex_color,
        "mstate_get_string": mstate_get_string,
    };

}());

