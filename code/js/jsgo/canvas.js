/* TODO:
 * - page zoom, and onmouseWheel event handling.
 */

"use strict";

var KANVAS = (function(){

    const GRID_SIZE = 39; // in pixel
    const STONE_RADIUS = (GRID_SIZE - 3) / 2;
    const LINE_WIDTH_1 = 1;  // inner lines
    const LINE_WIDTH_2 = 2;  // outter lines
    const LINE_WIDTH_3 = 3;  // outter lines

    var _canvas = null;
    var _ctx = [];
    var _mstate = null;

    var _show_number = false;
    
    const BOARD = 0;
    const STONE = 1;
    const MARK = 2;

    /* input: an array of canvas: [board, stone, mark] */
    function set_canvas(c) {
        _canvas = c;
        for (var i = 0; i < c.length; i ++) {
    	    _ctx.push(_canvas[i].getContext('2d'));
        }
    }

    function set_mstate(m) {
        _mstate = m;
        for (var i = 0; i < _canvas.length; i ++ ) {
    	    _canvas[i].width = (_mstate.ncol + 3) * GRID_SIZE;
        	_canvas[i].height = (_mstate.nrow + 3) * GRID_SIZE;;
        }
    }

    function get_mstate() {
        return _mstate;
    }

    function get_canvas_size() {
        if (_mstate === null)
            return null;
        
        return {"width": _canvas[BOARD].width, "height": _canvas[BOARD].height };
    }

    /* indication */
    const NOTHING = 0;
    const SQUARE = 1;
    const TRIANGLE = 2;
    const FORBIDDEN = 3;

    /* "idx" is the canvas index, starting from 0 (bottom one) */
    function circle_at(idx, row, col, radius, color, indicate = NOTHING) {
        // find out the center
        var x = GRID_SIZE * (col + 2);
        var y = GRID_SIZE * (row + 2);

        
        _ctx[idx].beginPath();
        _ctx[idx].strokeStyle = "black";
        _ctx[idx].arc(x, y, radius, 0, Math.PI * 2, false);
        
        _ctx[idx].fillStyle = color;
        _ctx[idx].lineWidth = LINE_WIDTH_1;
        _ctx[idx].fill();
        _ctx[idx].closePath();
        _ctx[idx].stroke();

        // indicate the next move
        if (indicate === SQUARE) {
            _ctx[idx].beginPath();
            _ctx[idx].lineWidth = LINE_WIDTH_2;
            _ctx[idx].strokeStyle = "green";
            _ctx[idx].rect(x - GRID_SIZE / 6, y - GRID_SIZE / 6, GRID_SIZE / 3, GRID_SIZE / 3);
            _ctx[idx].closePath();
            _ctx[idx].stroke();
        } else if (indicate === TRIANGLE) {
        } else if (indicate === FORBIDDEN) {
            _ctx[idx].beginPath();
            _ctx[idx].lineWidth = LINE_WIDTH_3;
            _ctx[idx].strokeStyle = "red";
            _ctx[idx].arc(x, y, radius, 0, Math.PI * 2, false);
            _ctx[idx].moveTo(x - radius * .7, y + radius * .7);
            _ctx[idx].lineTo(x + radius * .7, y - radius * .7);
            _ctx[idx].closePath();
            _ctx[idx].stroke();
        }
    }

    function text_at(idx, row, col, text, font, textAlign, textBaseline, color="black") {
        // find out the center
        var x = GRID_SIZE * (col + 2);
        var y = GRID_SIZE * (row + 2);
        
        _ctx[idx].font = font;
        _ctx[idx].textAlign = textAlign;
        _ctx[idx].textBaseline = textBaseline;
        _ctx[idx].fillStyle = color;
        _ctx[idx].fillText(text, x, y);
    }

    function draw_board(mstate = _mstate) {
        var i, j, x1, y1, x2, y2;
        
        _ctx[BOARD].clearRect(0, 0, _canvas[BOARD].width, _canvas[BOARD].height);

        // draw board outline
        _ctx[BOARD].strokeStyle = "black";
        _ctx[BOARD].fillStyle="#EEB422";
        _ctx[BOARD].beginPath();
        _ctx[BOARD].lineWidth = LINE_WIDTH_2;
        _ctx[BOARD].fillRect(GRID_SIZE, GRID_SIZE, GRID_SIZE * (mstate.ncol + 1), GRID_SIZE * (mstate.nrow + 1));
        _ctx[BOARD].stroke();
        
        // draw board grid
        _ctx[BOARD].beginPath();
        _ctx[BOARD].lineWidth = LINE_WIDTH_1;
        for (i = 0; i < mstate.nrow; i ++) {
            x1 = GRID_SIZE * 2;
            x2 = (mstate.ncol + 1) * GRID_SIZE;
            y1 = (i + 2) * GRID_SIZE;
            _ctx[BOARD].moveTo(x1, y1);
            _ctx[BOARD].lineTo(x2, y1);
        }
        
        for (i = 0; i < mstate.ncol; i ++) {
            y1 = GRID_SIZE * 2;
            y2 = (mstate.nrow + 1) * GRID_SIZE;
            x1 = (i + 2) * GRID_SIZE;
            _ctx[BOARD].moveTo(x1, y1);
            _ctx[BOARD].lineTo(x1, y2);
        }
        _ctx[BOARD].stroke();

        // draw stars
        if (mstate.nrow === 19 && mstate.ncol === 19) {
            circle_at(BOARD,  3,  3, 4, "black");
            circle_at(BOARD,  3,  9, 4, "black");
            circle_at(BOARD,  3, 15, 4, "black");
            circle_at(BOARD,  9,  3, 4, "black");
            circle_at(BOARD,  9,  9, 4, "black");
            circle_at(BOARD,  9, 15, 4, "black");
            circle_at(BOARD, 15,  3, 4, "black");
            circle_at(BOARD, 15,  9, 4, "black");
            circle_at(BOARD, 15, 15, 4, "black");
        }
        
        // draw grid marks: AB... & 1234
        var mark_font = Math.round(GRID_SIZE / 3) + "pt sans-serif";
        _ctx[BOARD].fillStyle = "black";
        for (i = mstate.nrow; i > 0; i --) { // 1 starts from the bottom of the board
            text_at(BOARD, mstate.nrow - i, - 1, i.toString()+ " ", mark_font, "end", "middle");
            text_at(BOARD, mstate.nrow - i, mstate.ncol, " " + i.toString()+ " ", mark_font, "start", "middle");
        }

        for (i = 0; i < mstate.ncol; i ++) {  // not using 'I'
            text_at(BOARD, - 1, i, "ABCDEFGHJKLMNOPQRST"[i], mark_font, "center", "bottom");
            text_at(BOARD, mstate.nrow, i, "ABCDEFGHJKLMNOPQRST"[i], mark_font, "center", "top");
        }

    }

    /* stones are drawn on the STONE layer */
    function draw_stones(mstate = _mstate) {
        var i, j, color;

        _ctx[STONE].clearRect(0, 0, _canvas[STONE].width, _canvas[STONE].height);
        
        // draw stones 
        for (i = 0; i < mstate.nrow; i ++ ) {
            for (j = 0; j < mstate.ncol; j ++) {
                color = RULE.mstate_get_vertex(mstate, i, j).color;
                if (color === RULE.COLOR.WHITE) {
                    circle_at(STONE, i, j, STONE_RADIUS, "white");
                } else if (color === RULE.COLOR.BLACK) {
                    circle_at(STONE, i, j, STONE_RADIUS, "black");
                }
            }
        }

        if (_show_number === true) {
            _draw_numbers();
        }
    }

    /* can also hide numbers */
    function draw_numbers(yes = true) {
        _show_number = yes;
        _draw_numbers();
    }
    
    /* numbers are on the MARK layer */
    function _draw_numbers(mstate = _mstate) {
        var i, j, vert;
        var font1 = Math.round(GRID_SIZE / 2) + "pt sans-serif";   // for numbers < 100
        var font2 = Math.round(GRID_SIZE / 2.5) + "pt sans-serif";  // for numbers >=100

        _ctx[MARK].clearRect(0, 0, _canvas[MARK].width, _canvas[MARK].height);

        if (_show_number === false) {
            return;
        }
        
        // draw numbers
        if (false) { // this way the reoccupied position will be drawn by mutliple numbers
            for (i = 0; i < mstate.count; i ++ ) {
                var row, col, color;
                row = mstate.rows[i];
                col = mstate.cols[i];
                if (row === RULE.PASS && col === RULE.PASS) {
                    continue;
                }
                color = RULE.mstate_get_vertex(mstate, row, col).color;
                if (color === RULE.COLOR.WHITE) {
                    text_at(MARK, row, col, i.toString(), i < 100? font1: font2, "center", "middle", "black");
                } else if (color === RULE.COLOR.BLACK) {
                    text_at(MARK, row, col, i.toString(), i < 100? font1: font2, "center", "middle", "white");
                }
            }
        } else {
            for (i = 0; i < mstate.nrow; i ++) {
                for (j = 0; j < mstate.ncol; j ++) {
                    vert = RULE.mstate_get_vertex(mstate, i, j);
                    if (vert.color === RULE.COLOR.WHITE) {
                        text_at(MARK, i, j, vert.count.toString(), vert.count < 100? font1: font2, "center", "middle", "black");
                    } else if (vert.color === RULE.COLOR.BLACK) {
                        text_at(MARK, i, j, vert.count.toString(), vert.count < 100? font1: font2, "center", "middle", "white");
                    }
                }
            }
        }
    }

    /* convert (x, y) in canvas coordinate into board's (row, col)
     * return { "row": a, "col", b}
     */
    function _pixel_to_board(x, y) {
        var row = Math.round(y / GRID_SIZE) - 2;
        var col = Math.round(x / GRID_SIZE) - 2;
        //console.log(row + "," + col);
        if (row > _mstate.nrow - 1 || row < 0 || col > _mstate.ncol - 1 || col < 0) {
            return null;
        } else {
            return {"row": row, "col": col};
        }
    }
    
    /*
     *----------------------------------
     * event handlers
     *----------------------------------
     */
    function onClick(e) {
        //console.log("onClick: x=" + e.clientX + ", y=" + e.clientY + ", detail=" + e.detail);
        var position = _pixel_to_board(e.clientX, e.clientY);
        if (position !== null) {
            RULE.mstate_commit_a_move(_mstate, position.row, position.col);
            draw_stones();
        }
    }

    function onDoubleClick(e) {
        console.log("onDoubleClick: x=" + e.clientX + ", y=" + e.clientY + ", detail=" + e.detail);
    }

    function onRightClick(e) {
        console.log("onRightClick: x=" + e.clientX + ", y=" + e.clientY + ", detail=" + e.detail);
    }
    
    function onMouseMove(e) {
        //console.log("onMouseMove: x=" + e.clientX + ", y=" + e.clientY + ", detail=" + e.detail);
        var position = _pixel_to_board(e.clientX, e.clientY);
        draw_stones();
        if (position !== null) {
            var move = RULE.mstate_get_move_validity(_mstate, position.row, position.col);
            var player = RULE.mstate_get_next_player(_mstate);
            if (move === RULE.MOVE.GOOD) {
                circle_at(STONE, position.row, position.col, STONE_RADIUS, player === RULE.PLAYER.WHITE? "white" : "black", SQUARE);
            } else if (move === RULE.MOVE.INKO || move === RULE.MOVE.SUIC){
                circle_at(STONE, position.row, position.col, STONE_RADIUS, player === RULE.PLAYER.WHITE? "white" : "black", FORBIDDEN);
            }
        }
    }

    function onMouseWheel(e) {
        console.log("onMouseWheel: clientX="+ e.clientX +", clientY=" + e.clientY +", dx=" + e.deltaX + ", dy=" + e.deltaY + ", wheelDelta=" + e.wheelDelta);
    }

    function onMouseLeave(e) {
        console.log("onMouseLeave: e=" + e);
        draw_stones();
    }

    function onMouseEnter(e) {
        console.log("onMouseEnter: e=" + e);
    }

    function handleFocus(e) {
        if(e.type == 'mouseover'){
            _canvas[0].focus();
            return false;
        }else if(e.type == 'mouseout'){
            _canvas[0].blur();
            return false;
        }
        return true;
    };

    function handleKeyDown(e) {
        const N_KEY = 78;
        console.log("key down:" + e.keyCode);

        var key_id = e.keyCode || e.which;

        if (key_id === N_KEY) {  // toggle for show/hide numbers
            if (_show_number === true)
                _show_number = false;
            else
                _show_number = true;

            _draw_numbers();
        }
        
        return false;
    };



    return {
        "set_canvas": set_canvas,
        "set_mstate": set_mstate,
        "get_mstate": get_mstate,
        "get_canvas_size": get_canvas_size,
        "draw_board": draw_board,
        "draw_stones": draw_stones,
        "draw_numbers": draw_numbers,

        // event handlers
        "onMouseMove": onMouseMove,
        "onClick": onClick,
        "onDoubleClick": onDoubleClick,
        "onRightClick": onRightClick,
        "onMouseWheel": onMouseWheel,
        "onMouseEnter": onMouseEnter,
        "onMouseLeave": onMouseLeave,
        "handleFocus": handleFocus,
        "handleKeyDown": handleKeyDown
    };
}());

