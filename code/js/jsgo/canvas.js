/* TODO:
 * - page zoom, and onmouseWheel event handling.
 */

"use strict";

var JG2C = (function(){

    const GRID_SIZE = 45; // in pixel
    const STONE_RADIUS = (GRID_SIZE - 3) / 2;
    const LINE_WIDTH_1 = 1;  // inner lines
    const LINE_WIDTH_2 = 2;  // outter lines

    var _canvas = [null, null];
    var _ctx = [null, null];
    var _mstate = null;

    /* input: an array of 2 canvas: [board, stone] */
    function set_canvas(c) {
        _canvas = c;
	    _ctx[0] = _canvas[0].getContext('2d');
	    _ctx[1] = _canvas[1].getContext('2d');
    }

    function set_mstate(m) {
        _mstate = m;
	    _canvas[0].width = (_mstate.ncol + 3) * GRID_SIZE;
    	_canvas[0].height = (_mstate.nrow + 3) * GRID_SIZE;;
	    _canvas[1].width = (_mstate.ncol + 3) * GRID_SIZE;
    	_canvas[1].height = (_mstate.nrow + 3) * GRID_SIZE;;
    }

    function get_mstate() {
        return _mstate;
    }

    function get_canvas_size() {
        if (_mstate === null)
            return null;
        
        return {"width": _canvas[0].width, "height": _canvas[0].height };
    }
    
    function circle_at(idx, row, col, radius, color, indicate = false) {
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
        if (indicate) {
            _ctx[idx].beginPath();
            _ctx[idx].strokeStyle = "red";
            _ctx[idx].rect(x - GRID_SIZE / 6, y - GRID_SIZE / 6, GRID_SIZE / 3, GRID_SIZE / 3);
            _ctx[idx].closePath();
            _ctx[idx].stroke();
        }

    }

    function text_at(row, col, text, font, textAlign, textBaseline) {
        // find out the center
        var x = GRID_SIZE * (col + 2);
        var y = GRID_SIZE * (row + 2);
        _ctx[0].font = font;
        _ctx[0].textAlign = textAlign;
        _ctx[0].textBaseline = textBaseline;
        _ctx[0].fillText(text, x, y);
    }

    function draw_board(mstate = _mstate) {
        var i, j, x1, y1, x2, y2;
        
        _ctx[0].clearRect(0, 0, _canvas[0].width, _canvas[0].height);

        // draw board outline
        _ctx[0].strokeStyle = "black";
        _ctx[0].fillStyle="#EEB422";
        _ctx[0].beginPath();
        _ctx[0].lineWidth = LINE_WIDTH_2;
        _ctx[0].fillRect(GRID_SIZE, GRID_SIZE, GRID_SIZE * (mstate.ncol + 1), GRID_SIZE * (mstate.nrow + 1));
        _ctx[0].stroke();
        
        // draw board grid
        _ctx[0].beginPath();
        _ctx[0].lineWidth = LINE_WIDTH_1;
        for (i = 0; i < mstate.nrow; i ++) {
            x1 = GRID_SIZE * 2;
            x2 = (mstate.ncol + 1) * GRID_SIZE;
            y1 = (i + 2) * GRID_SIZE;
            _ctx[0].moveTo(x1, y1);
            _ctx[0].lineTo(x2, y1);
        }
        
        for (i = 0; i < mstate.ncol; i ++) {
            y1 = GRID_SIZE * 2;
            y2 = (mstate.nrow + 1) * GRID_SIZE;
            x1 = (i + 2) * GRID_SIZE;
            _ctx[0].moveTo(x1, y1);
            _ctx[0].lineTo(x1, y2);
        }
        _ctx[0].stroke();

        // draw stars
        if (mstate.nrow === 19 && mstate.ncol === 19) {
            circle_at(0,  3,  3, 4, "black");
            circle_at(0,  3,  9, 4, "black");
            circle_at(0,  3, 15, 4, "black");
            circle_at(0,  9,  3, 4, "black");
            circle_at(0,  9,  9, 4, "black");
            circle_at(0,  9, 15, 4, "black");
            circle_at(0, 15,  3, 4, "black");
            circle_at(0, 15,  9, 4, "black");
            circle_at(0, 15, 15, 4, "black");
        }
        
        // draw grid marks: AB... & 1234
        var mark_font = "16pt sans-serif";
        _ctx[0].fillStyle = "black";
        for (i = mstate.nrow; i > 0; i --) { // 1 starts from the bottom of the board
            text_at(mstate.nrow - i, - 1, i.toString()+ " ", mark_font, "end", "middle");
            text_at(mstate.nrow - i, mstate.ncol, " " + i.toString()+ " ", mark_font, "start", "middle");
        }

        for (i = 0; i < mstate.ncol; i ++) {  // not using 'I'
            text_at(- 1, i, "ABCDEFGHJKLMNOPQRST"[i], mark_font, "center", "bottom");
            text_at(mstate.nrow, i, "ABCDEFGHJKLMNOPQRST"[i], mark_font, "center", "top");
        }

    }

    /* stones are drawn on the 2nd layer */
    function draw_stones(mstate = _mstate) {
        var i, j, color;

        _ctx[1].clearRect(0, 0, _canvas[1].width, _canvas[1].height);
        
        // draw stones 
        for (i = 0; i < mstate.nrow; i ++ ) {
            for (j = 0; j < mstate.ncol; j ++) {
                color = RULE.mstate_get_vertex_color(_mstate, i, j);
                if (color === RULE.COLOR.WHITE) {
                    circle_at(1, i, j, STONE_RADIUS, "white");
                } else if (color === RULE.COLOR.BLACK) {
                    circle_at(1, i, j, STONE_RADIUS, "black");
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
            if (move !== RULE.MOVE.GOOD) {
                return;
            }
            var player = RULE.mstate_get_next_player(_mstate);
            circle_at(1, position.row, position.col, STONE_RADIUS, player === RULE.PLAYER.WHITE? "white" : "black", true);
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
        console.log("key down:" + e.keyCode);
        return false;
    };



    return {
        "set_canvas": set_canvas,
        "set_mstate": set_mstate,
        "get_mstate": get_mstate,
        "get_canvas_size": get_canvas_size,
        "draw_board": draw_board,
        "draw_stones": draw_stones,

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

