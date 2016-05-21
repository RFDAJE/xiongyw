"use strict";

var RULE = (function(){

    /*##############################################################
      # constant definitions
      #############################################################*/
    const MAX_GRID =  19;          /* maximum board size, inclusive */
    const MIN_GRID =  2;           /* minimum board size, inclusive */
    const PASS = - 100;            /* (PASS, PASS) is a pass move */
    const MAX_HANDICAPS = 9;
    const MIN_HANDICAPS = 2;

    /*##############################################################
      # enum
      #############################################################*/
    const PLAYER = { 
        "WHITE": "W",
        "BLACK": "B",
        "NONE":  "N"  // used to indicate KO status when there is no KO
    };

    /* 
     * vertex color (state): restrict the values to be 0,1,2,3, 
     * i.e, can be stored in two bits.
     */
    const COLOR = {
        "WHITE": "W",  /* occupied by a white stone */
        "BLACK": "B",  /* occupied by a white stone */
        "GREEN": "G",  /* not occupied and valid for the next mover */
        "RED": "R"     /* not occupied, but it's forbidden for the next mover, because of ko or suicide rules */
    };

    /* types of rules */
    const RULE = {
        "CHINESE": "CHI",
        "JAPANESE": "JAP",
        "INGS": "ING",
        "BRITISH": "BRI"
    };

    /* validity of a move */
    const MOVE = {
        "GOOD": "GOOD",   /* move is valid */
        "PILE": "PILE",   /* invalid (vertex already occupied) */
        "INKO": "INKO",   /* invalid (vertex in ko_t) */
        "SUIC": "SUIC",   /* invalid (suicide) */
        "RANG": "RANG",   /* invalid (vertex out of range) */ 
        "OVER": "OVER"    /* invalid (the game was over) */
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
    const SYMMETRY = { 
        "I": "I",   /* identity, i.e., no symmetry */
        "H": "H",
        "V": "V",
        "D": "D",   /* only for square board */
        "DD": "DD", /* only for square board */
        "R": "R",   /* only for square board */
        "R2": "R2",
        "R2H": "R2H",
        "R2D": "R2D",  /* only for square board */
        "D4": "D4"     /* only for square board */
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
            console.log("ERROR: row/col (" + row + ", " + col + ") out of range!");
            return null;
        }
        return mstate.color[row][col];
    }

    /*
     * set the state data of vertex at (row, col); 
     * return the value set
     */
    function _set_vertex(mstate, row, col, color) {
        mstate.color[row][col] = color;
        return color;
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
    function _get_string(state, row, col, vertices, dir){

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
        if (dir !== SOUTH && row > 0 && mstate_get_vertex_color(state, row - 1, col) == who) {
            _get_string(state, row - 1, col, vertices, NORTH);
        }

        /* eastern search */
        if (dir !== WEST && col < state.ncol - 1 && mstate_get_vertex_color(state, row, col + 1) == who) {
            _get_string(state, row, col + 1, vertices, EAST);
        }

        /* southern search */
        if (dir !== NORTH && row < state.nrow - 1 && mstate_get_vertex_color(state, row + 1, col) == who) {
            _get_string(state, row + 1, col, vertices, SOUTH);
        }

        /* western search */
        if (dir !== EAST && col > 0 && mstate_get_vertex_color(state, row, col - 1) == who) {
            _get_string(state, row, col - 1, vertices, WEST);
        }

        if (dir !== DIRECT){
            /* recursive called, ignored return value */ 
            return 0; 
        } else {
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
    function _check_dof(state, row, col, dof) {

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
     * remove the string from state, setting the removed 
     * vertex info to COLOR.GREEN, 
     * it's assumed that the string has zero dof, so we 
     * don't check it again here.
     *
     * RETURN VALUE: none;
     */
    function _remove_string(mstate, row, col){

        var i;

        var string = mstate_get_string(mstate, row, col).string;

        for(i = 0; i < string.len; i ++){
            _set_vertex(mstate, string.rows[i], string.cols[i], COLOR.GREEN);
        }
    }


    /*
     * finds out all the pieces of a string has vertex at (row, col), 
     * and return the string and its dof in a JSON object:
     * { "string": {"len": x, "rows": [...], "cols": []}, 
     *   "dof":    {"len": x, "rows": [...], "cols": []}
     * }
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

        /* init values for the return object */
        var string = {"len": 0, "rows": [], "cols": []}, 
            dof = {"len": 0, "rows": [], "cols": []};
        var size = _get_string(state, row, col, string, DIRECT);

        /* get the dof of the string */
        for (var i = 0; i < size; i ++) {

            var ro, co;
            ro = string.rows[i];
            co = string.cols[i];

            /* southern check */
            if(ro < state.nrow - 1)  
                _check_dof(state, ro + 1, co, dof);

            /* eastern check */
            if(co < state.ncol - 1)  
                _check_dof(state, ro, co + 1, dof);

            /* northern check */
            if(ro > 0)                
                _check_dof(state, ro - 1, co, dof);

            /* western check */
            if(co > 0)                
                _check_dof(state, ro, co - 1, dof);
        }

        /* return the string and its dof */
        return {"string": string, "dof": dof};
    }


    /* black always moves on odd counts */
    function mstate_get_next_player(mstate) {
        if(0 === mstate.count % 2)
            return PLAYER.BLACK;
        else
            return PLAYER.WHITE;
    }


    function mstate_get_move_validity(mstate, row, col) {

            var saved,       // saved color of the vertex 
                enemy,       // enemy color
                next;        // next player
            var dup;         // duplicated state


            /*
             * simple test cases
             */
            
            /* if the game was over */
            if(mstate.over){
                return MOVE.OVER;
            }
            
            /* a pass is always valid */
            if(row == PASS && col == PASS){
                return MOVE.GOOD;
            }

            /* position range check */
            if(row >= mstate.nrow || col >= mstate.ncol){
                return MOVE.RANG;
            }

            /* reoccupy check */
            saved = mstate_get_vertex_color(mstate, row, col);
            if(saved == COLOR.WHITE || saved == COLOR.BLACK){
                return MOVE.PILE;
            }

            /* KO check */
            next = mstate_get_next_player(mstate);
            if(mstate.ko.who === next && 
               mstate.ko.row === row && 
               mstate.ko.col === col){
                return MOVE.INKO;
            }


            // TBD: if(dup->rule == INGS)    return MOVE.GOOD; 

            /* 
             * duplicate the state to do the suicide check, by applying
             * the candidate move on the duplicated board then check its validity. 
             * this keeps the argument state untouched. 
             */
            dup = mstate_clone(mstate);
            enemy = (next === PLAYER.BLACK)? COLOR.WHITE : COLOR.BLACK;
            

            if (next === PLAYER.BLACK) {
                _set_vertex(dup, row, col, COLOR.BLACK);
            } else {
                _set_vertex(dup, row, col, COLOR.WHITE);
            }
                
            /* 
             * a suicide move means that it causes a self string (which containing 
             * the move) has 0 dof while it can not kill any neighboring enenmy string. 
             *
             * procedure:
             *
             * 1: check if it's a possible suicide, if not, return MOVE.GOOD; otherwise,
             * 2: check this move's 4 neighboring vertices, if there is any dead enemy 
             *    string, return MOVE.GOOD; If none of enemy strings dead, or just no 
             *    enemy string there(4 neighboring vertices are all occupied by self 
             *    stones), it's a suicide move, return MOVE.SUIC.
             *
             * THE FACT: if a move kills enemy string(s), the killed enemy string(s) 
             * must occupy one of the move's 4 neighboring vertices.  
             */

            /* 1: check if it's not a suicide */
            if (mstate_get_string(dup, row, col).dof.len > 0) {
                return MOVE.GOOD;
            }

            /* 2. now it's possible a suicide */

            /* northern neighboring vertex */
            if(row > 0 && 
               mstate_get_vertex_color(dup, (row - 1), col) === enemy && 
               mstate_get_string(dup, (row - 1), col).dof.len === 0){
                return MOVE.GOOD;
            }

            /* southern neighboring vertex */
            if(row < dup.nrow - 1 && 
               mstate_get_vertex_color(dup, (row + 1), col) === enemy &&
               mstate_get_string(dup, (row + 1), col).dof.len === 0){
                return MOVE.GOOD;
            }

            /* western neighboring vertex */
            if(col > 0 && 
               mstate_get_vertex_color(dup, row, (col - 1)) === enemy && 
               mstate_get_string(dup, row, (col - 1)).dof.len === 0){
                return MOVE.GOOD;
            }

            /* eastern neighboring vertex */
            if(col < dup.ncol - 1 && 
               mstate_get_vertex_color(dup, row, (col + 1))  === enemy && 
               mstate_get_string(dup, row, (col + 1)).dof.len === 0){
                return MOVE.GOOD;
            }

            /* reaching here means it's a suicide move */
            return MOVE.SUIC;
    }



    /*
     * commit the move (row, col) and update the state of the board,
     * and return dead (if any) in a list of vertices.
     * return null for errors;
     */
    function mstate_commit_a_move(mstate, row, col){

        var     mover, enemy; /* who made this move and who is the enemy */
        var     mover_color, enemy_color;
        var     i, j, validity;
        var     string, dead = { "len": 0, "rows": [], "cols": []};

        mover = mstate_get_next_player(mstate);    
        enemy = (mover === PLAYER.BLACK)? PLAYER.WHITE : PLAYER.BLACK;
        mover_color = (mover === PLAYER.BLACK)? COLOR.BLACK : COLOR.WHITE;
        enemy_color = (enemy === PLAYER.BLACK)? COLOR.BLACK : COLOR.WHITE;

        validity = mstate_get_move_validity(mstate, row, col);
        if (validity !== MOVE.GOOD) {
            console.log("ERROR: not a valid move: " + validity);
            return null;
        }

        /* if it's a pass move */   
        if(row === PASS && col === PASS){
            
            /* two consecutive PASS ends the game */
            if(mstate.count > 0 &&
               mstate.rows[mstate.count] === PASS && 
               mstate.cols[mstate.count] === PASS) {
                mstate.over = true;
            }

            return dead;
        }

        /* commit the move now */
        _set_vertex(mstate, row, col, mover_color);


        /*
         * remove and record dead enemy strings, if any 
         */
        var neig = {"len": 0, "rows": [], "cols": []}; // it holds maximumly 4 neighboring vertices

        // northen
        if (row > 0) {
            neig.len ++;
            neig.rows.push(row - 1);
            neig.cols.push(col);
        }

        // southern
        if (row < mstate.nrow - 1) {
            neig.len ++;
            neig.rows.push(row + 1);
            neig.cols.push(col);
        }

        // western
        if (col > 0) {
            neig.len ++;
            neig.rows.push(row);
            neig.cols.push(col - 1);
        }
        
        // eastern
        if (col < mstate.ncol - 1) {
            neig.len ++;
            neig.rows.push(row);
            neig.cols.push(col + 1);
        }

        for (i = 0; i < neig.len; i ++) {
            if (mstate_get_vertex_color(mstate, neig.rows[i], neig.cols[i]) === enemy_color) {
                string = mstate_get_string(mstate, neig.rows[i], neig.cols[i]);
                if (string.dof.len === 0) {
                    _remove_string(mstate, neig.rows[i], neig.cols[i]);
                    // add dead stones
                    for (j = 0; j < string.string.len; j ++) {
                        dead.rows.push(string.string.rows[j]);
                        dead.cols.push(string.string.cols[j]);
                        dead.len ++;
                    }
                }
            }
        }

        /* update the board state */
        mstate.count ++;
        mstate.rows.push(row);
        mstate.cols.push(col);

        /*
         * update KO status 
         */
         
        mstate.ko.who = PLAYER.LAST;   /* reset the ko_t state first */
        
        /* 
         * suppose an A move killes AND only killes one piece of B.
         * condition 1: only one piece was killed,
         * condition 2: A's move was surrounded by 4 B pieces, including 
         * marginal vertices 
         */ 
        if (dead.len == 1) {
            string = mstate_get_string(mstate, row, col);
            if (string.string.len === 1 && string.dof.len === 1) {
                mstate.ko.who = enemy;
                mstate.ko.row = dead.rows[0];
                mstate.ko.col = dead.cols[0];
                _set_vertex(mstate, mstate.ko.row, mstate.ko.col, COLOR.RED);
            }
        }

        /* Find out all COLOR.RED vertex */
        // if(mstate.rule != RULE_INGS) /* TBD */

        for (i = 0; i < mstate.nrow; i ++) {
            for (j = 0; j < mstate.ncol; j ++) {
                var tmp = mstate_get_vertex_color(mstate, i, j);
                if (tmp !== COLOR.BLACK && tmp !== COLOR.WHITE) {
                    if(mstate_get_move_validity(mstate, i, j) === MOVE.GOOD)
                        _set_vertex(mstate, i, j, COLOR.GREEN);
                    else
                        _set_vertex(mstate, i, j, COLOR.RED);
                }
            }
        }

        return dead;
    }



    /* 
     * noted(bruin, 2007-12-25): the "symmetry" of a board configuration can be utilized in 
     * two aspects, i.e., move generation and board evaluation:
     *  1. move generation: if the board configuration has some kind of symmetry property, 
     *     then some candidate moves are equivalent, thus we can choose just one from 
     *     the equivalent moves, then the total number of the candidate moves (i.e., 
     *     the branching factor) is reduced.
     *  2. board evaluation: if a board configuration can be obtained by applying symmetric 
     *     transformation(s) (other than the identity transformation) of another board configuration, 
     *     then these two board configuration are equivalent, and they share the same board 
     *     evaluation result. thus by detecting equivalent board configuration, we reduce the 
     *     computation on board evaluation. be noted that it's possible that a board configration 
     *     does not have any symmetry property (i.e., it only has the identity transformation as 
     *     its symmetric transformation), in this case, no other board configration can share its 
     *     evaluation result. TBD: a symmetry-independent hashing technique is used for storing/accessing
     *     the calculated board evaluation results.
     * 
     */
    function mstate_get_board_symmetry_group(mstate) {
        var i, j, middle, is_square;
        
        var is_H, is_V, is_D, is_DD;
        var is_R, is_R2;
        
        if(mstate.nrow === mstate.ncol) {
            is_square = true;
        } else {
            is_square = false;
        }

        /* IS_H: */

        /* horizontal symmetry: top vs. bottom */
        is_H = true;
        middle = mstate.nrow / 2;
        IS_H: for (i = 0; i < mstate.ncol; i ++) { /* for each column */
            for (j = 0; j < middle; j ++) {
                if(mstate_get_vertex_color(mstate, j, i) !== mstate_get_vertex_color(mstate, mstate.nrow - 1 - j, i)) {
                    is_H = false;
                    break IS_H;
                }
            }
        }

    
        /* vertical symmetry: left vs. right */
        is_V = true;
        middle = mstate.ncol / 2;
        IS_V: for (i = 0; i < mstate.nrow; i ++) { /* for each row */
            for (j = 0; j < middle; j ++) {
                if(mstate_get_vertex_color(mstate, i, j) !== mstate_get_vertex_color(mstate, i, mstate.ncol - 1 - j)) {
                    is_V = false;
                    break IS_V;
                }
            }
        }


        if(!is_square){
            /* these are not applicable to rectangle board */
            is_D = is_DD = is_R = false;
        } else {
        
            /* diagonal symmetry: slash "/" */  
            is_D = true;
            IS_D: for (i = 0; i < mstate.nrow; i ++) {   /* for each row (ommit the last row) */
                for (j = 0; j < mstate.ncol - 1 - i; j ++) {
                    var ii, jj; /* (i, j) ---> (ii, jj) */
                    ii = mstate.ncol - 1 - j;
                    jj = mstate.ncol - 1 - i;
                    if (mstate_get_vertex_color(mstate, i, j) !== mstate_get_vertex_color(mstate, ii, jj)) {
                        is_D = false;
                        break IS_D;
                    }
                }
            }

            /* diagonal symmetry: back slash "\" */ 
            is_DD = true;
            IS_DD: for (i = 0; i < mstate.nrow - 1; i ++) {   /* for each row (ommit the last row) */
                for (j = i + 1; j < mstate.ncol; j ++) { /* (i, j) ---> (j, j) */
                    if(mstate_get_vertex_color(mstate, i, j) !== mstate_get_vertex_color(mstate, j, i)){
                        is_DD = false;
                        break IS_DD;
                    }
                }
            }
            
            /* counter clockwise rotation of 90 degree */
            is_R = true;
            IS_R: for (i = 0; i < mstate.nrow; i ++) {
                for (j = 0; j < mstate.ncol; j ++) {
                    var ii, jj; /* (i, j) ---> (ii, jj) */
                    ii = mstate.ncol - 1 - j;
                    jj = i;
                    if (mstate_get_vertex_color(mstate, i, j) !== mstate_get_vertex_color(mstate, ii, jj)) {
                        is_R = false;
                        break IS_R;
                    }
                }
            }
        }

        /* counter clockwise rotation of 180 degree */
        if (is_R) {
            is_R2 = true;
        } else {
            is_R2 = true;
            IS_RR: for (i = 0; i < mstate.nrow; i ++) {
                for (j = 0; j < mstate.ncol; j ++) {
                    var ii, jj; /* (i, j) ---> (ii, jj) */
                    ii = mstate.nrow - 1 - i;
                    jj = mstate.ncol - 1 - j;
                    if (mstate_get_vertex_color(mstate, i, j) != mstate_get_vertex_color(mstate, ii, jj)) {
                        is_R2 = false;
                        break IS_RR;
                    }
                }
            }
        }

        DONE:
        //console.log("is_H=%d, is_V=%d, is_D=%d, is_DD=%d, is_R=%d, is_R2=%d\n", is_H,    is_V,    is_D,    is_DD,    is_R,    is_R2);
        
        if (is_R) {
            if (is_D) /* any flip among H, V, D, DD */
                return SYMMETRY.D4;
            else
                return SYMMETRY.R;
        }

        if (is_R2) {
            if (is_H) /* is_H=1 implies is_V=1, and vice versa */
                return SYMMETRY.R2H;
            else if (is_D) /* is_D=1 implies is_DD=1, and vice versa */
                return SYMMETRY.R2D;
            else
                return SYMMETRY.R2;
            /* note: it's not possible that (is_H && is_D) now, since it implies is_R=1 */
        }

        if(is_H)
            return SYMMETRY.H;

        if(is_V)
            return SYMMETRY.V;

        if(is_D)
            return SYMMETRY.D;

        if(is_DD)
            return SYMMETRY.DD;

        /* reaching here means the board has no symmetry */ 
        return SYMMETRY.I;
    }

    /*
     * -------------------------------------------------------------------
     */

    var _rule = {
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
        "mstate_get_next_player": mstate_get_next_player,
        "mstate_get_move_validity": mstate_get_move_validity,
        "mstate_commit_a_move": mstate_commit_a_move,
        "mstate_get_board_symmetry_group": mstate_get_board_symmetry_group,
    };

    return _rule;

}());

