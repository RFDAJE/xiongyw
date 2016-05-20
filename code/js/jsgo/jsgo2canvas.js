"use strict";

var JG2C = (function(){

    const GRID_SIZE = 45; // in pixel
    const STONE_RADIUS = (GRID_SIZE - 3) / 2;
    const LINE_WIDTH_1 = 1;  // inner lines
    const LINE_WIDTH_2 = 2;  // outter lines

    var _canvas = null;
    var _ctx = null;
    var _mstate = null;
     
    function set_canvas(c) {
        _canvas = c;
	    _ctx = _canvas.getContext('2d');
    }

    function set_mstate(m) {
        _mstate = m;
	    _canvas.width = (_mstate.ncol + 3) * GRID_SIZE;
    	_canvas.height = (_mstate.nrow + 3) * GRID_SIZE;;
    }

    function get_mstate() {
        return _mstate;
    }

    function get_canvas_size() {
        if (_mstate === null)
            return null;
        
        return {"width": _canvas.width, "height": _canvas.height };
    }
    
    function circle_at(row, col, radius, color) {
        // find out the center
        var x = GRID_SIZE * (col + 2);
        var y = GRID_SIZE * (row + 2);

        
        _ctx.beginPath();
        _ctx.arc(x, y, radius, 0, Math.PI * 2, false);
        
        _ctx.fillStyle = color;
        _ctx.lineWidth = LINE_WIDTH_1;
        _ctx.fill();
        _ctx.closePath();
        _ctx.stroke();
    }

    function text_at(row, col, text, font, textAlign, textBaseline) {
        // find out the center
        var x = GRID_SIZE * (col + 2);
        var y = GRID_SIZE * (row + 2);
        _ctx.font = font;
        _ctx.textAlign = textAlign;
        _ctx.textBaseline = textBaseline;
        _ctx.fillText(text, x, y);
    }

    function draw_mstate(mstate = _mstate) {
        var i, x1, y1, x2, y2;

        // draw board outline
        _ctx.strokeStyle = "black";
        _ctx.fillStyle="#EEB422";
        _ctx.beginPath();
        _ctx.lineWidth = LINE_WIDTH_2;
        _ctx.fillRect(GRID_SIZE, GRID_SIZE, GRID_SIZE * (mstate.ncol + 1), GRID_SIZE * (mstate.nrow + 1));
        _ctx.stroke();
        
        // draw board grid
        _ctx.beginPath();
        _ctx.lineWidth = LINE_WIDTH_1;
        for (i = 0; i < mstate.nrow; i ++) {
            x1 = GRID_SIZE * 2;
            x2 = (mstate.ncol + 1) * GRID_SIZE;
            y1 = (i + 2) * GRID_SIZE;
            _ctx.moveTo(x1, y1);
            _ctx.lineTo(x2, y1);
        }
        
        for (i = 0; i < mstate.ncol; i ++) {
            y1 = GRID_SIZE * 2;
            y2 = (mstate.nrow + 1) * GRID_SIZE;
            x1 = (i + 2) * GRID_SIZE;
            _ctx.moveTo(x1, y1);
            _ctx.lineTo(x1, y2);
        }
        _ctx.stroke();

        // draw stars
        if (mstate.nrow === 19 && mstate.ncol === 19) {
            circle_at( 3,  3, 4, "black");
            circle_at( 3,  9, 4, "black");
            circle_at( 3, 15, 4, "black");
            circle_at( 9,  3, 4, "black");
            circle_at( 9,  9, 4, "black");
            circle_at( 9, 15, 4, "black");
            circle_at(15,  3, 4, "black");
            circle_at(15,  9, 4, "black");
            circle_at(15, 15, 4, "black");
        }
        
        // draw grid marks: AB... & 1234
        var mark_font = "16pt sans-serif";
        _ctx.fillStyle = "black";
        for (i = mstate.nrow; i > 0; i --) { // 1 starts from the bottom of the board
            text_at(mstate.nrow - i, - 1, i.toString()+ " ", mark_font, "end", "middle");
            text_at(mstate.nrow - i, mstate.ncol, " " + i.toString()+ " ", mark_font, "start", "middle");
        }

        for (i = 0; i < mstate.ncol; i ++) {  // not using 'I'
            text_at(- 1, i, "ABCDEFGHJKLMNOPQRST"[i], mark_font, "center", "bottom");
            text_at(mstate.nrow, i, "ABCDEFGHJKLMNOPQRST"[i], mark_font, "center", "top");
        }
        
        //circle_at(0, 0, STONE_RADIUS, "white");
        //circle_at(0, 1, STONE_RADIUS, "black");

    }


    /*
     *----------------------------------
     * event handlers
     *----------------------------------
     */
    function onClick(e) {
        console.log("onClick: x=" + e.clientX + ", y=" + e.clientY + ", detail=" + e.detail);
    }

    function onDoubleClick(e) {
        console.log("onDoubleClick: x=" + e.clientX + ", y=" + e.clientY + ", detail=" + e.detail);
    }

    function onRightClick(e) {
        console.log("onRightClick: x=" + e.clientX + ", y=" + e.clientY + ", detail=" + e.detail);
    }
    
    //
    // the fact: canvas fires onmousemove events even the mouse position is not moved.
    // the impact: when click event happens, the current position is added into the path, but
    //   a mouse move event with the same position will be emitted. if we want to draw the
    //   current path, the last two points are identical...then the Bezier curve will not be draw,
    //   probably because the linear equations are not properly formed...
    // the remedy: omit mouse move event when the position is not changed. use closure the keep the 
    //   previous positions;
    var onMouseMove = (function() {
        // previous e.clientX and e.clientY
        var pre_x = -1;
        var pre_y = -1;
        return function(e){
            if(pre_x === e.clientX && pre_y === e.clientY) {
                // console.log("move without position change!");
                return;
            }
            pre_x = e.clientX;
            pre_y = e.clientY;
            console.log("onMouseMove: x=" + e.clientX + ", y=" + e.clientY + ", detail=" + e.detail);
            }
    }());

    function onMouseWheel(e) {
        console.log("onMouseWheel: dx=" + e.deltaX + ", dy=" + e.deltaY);
    }

    function onMouseLeave(e) {
        console.log("onMouseLeave: e=" + e);
    }

    function onMouseEnter(e) {
        console.log("onMouseEnter: e=" + e);
    }

    function handleFocus(e) {
        if(e.type == 'mouseover'){
            _canvas.focus();
            return false;
        }else if(e.type == 'mouseout'){
            _canvas.blur();
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
        "draw_mstate": draw_mstate,

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

