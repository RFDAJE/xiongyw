var JSGO = (function(){

    /*##############################################################
      # constant definitions
      #############################################################*/
    var MAX_GRID =  19;          /* maximum board size, inclusive */
    var MIN_GRID =  2;           /* minimum board size, inclusive */
    var PASS = (MAX_GRID + 1)    /* (PASS, PASS) is a pass move */
    var MAX_HANDICAPS = 9
    var MIN_HANDICAPS = 2

    /*##############################################################
      # enum
      #############################################################*/
    var PLAYER = { 
        WHITE: "W",
        BLACK: "B",
        NONE:  "N"  // used to indicate KO status when there is no KO
    };

    /* 
     * vertex color (state): restrict the values to be 0,1,2,3, 
     * i.e, can be stored in two bits.
     */
    var COLOR = {
    	WHITE: "W",  /* occupied by a white stone */
    	BLACK: "B",  /* occupied by a white stone */
    	GREEN: "G",  /* not occupied and valid for the next mover */
    	RED: "R",  /* not occupied, but it's forbidden for the next mover, because of ko or suicide rules */
    };

    /* types of rules */
    var RULE = {
    	CHINESE: "CHI",
    	JAPANESE: "JAP",
    	INGS: "ING",
    	BRITISH: "BRI"
    };

    /* validity of a move */
    var MOVE = {
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
     *  var vetices = {
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
            console.log("illegal board size!");
    		return null;
        }

        if (rule != RULE.CHINESE && rule != RULE.JAPANESE && rule != INGS && rule != RULE.BRITISH) {
            console.log("illegal rule!");
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
    };

}());

