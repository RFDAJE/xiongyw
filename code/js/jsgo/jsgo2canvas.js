"use strict";

var JG2C = (function(){

    var g_rows = 19;
    var g_cols = 19;
    var g_grid_size = 45; // in pixel
    var g_stone_radius = (g_grid_size - 3) / 2;
    var g_canvas_width = (g_cols + 3) * g_grid_size; 
    var g_canvas_height = (g_rows + 3) * g_grid_size; 
    var g_line_width_1 = 1;  // inner lines
    var g_line_width_2 = 2;  // outter lines

    var _canvas = null;
    var _ctx = null;
    var _mstate = null;
     
    function set_canvas(c) {
        _canvas = c;
	    _canvas.width = g_canvas_width;
    	_canvas.height = g_canvas_height;
	    _ctx = _canvas.getContext('2d');
    }

    function set_mstate(m) {
        _mstate = m;
    }
    
    function circle_at(row, col, radius, color) {
        // find out the center
        var x = g_grid_size * (col + 2);
        var y = g_grid_size * (row + 2);

        
        _ctx.beginPath();
        _ctx.arc(x, y, radius, 0, Math.PI * 2, false);
        
        _ctx.fillStyle = color;
        _ctx.lineWidth = g_line_width_1;
        _ctx.fill();
        _ctx.closePath();
        _ctx.stroke();
    }

    function text_at(row, col, text, font, textAlign, textBaseline) {
        // find out the center
        var x = g_grid_size * (col + 2);
        var y = g_grid_size * (row + 2);
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
        _ctx.lineWidth = g_line_width_2;
        _ctx.fillRect(g_grid_size, g_grid_size, g_grid_size * (mstate.ncol + 1), g_grid_size * (mstate.nrow + 1));
        _ctx.stroke();
        
        // draw board grid
        _ctx.beginPath();
        _ctx.lineWidth = g_line_width_1;
        for (i = 0; i < mstate.nrow; i ++) {
            x1 = g_grid_size * 2;
            x2 = (mstate.ncol + 1) * g_grid_size;
            y1 = (i + 2) * g_grid_size;
            _ctx.moveTo(x1, y1);
            _ctx.lineTo(x2, y1);
        }
        
        for (i = 0; i < mstate.ncol; i ++) {
            y1 = g_grid_size * 2;
            y2 = (mstate.nrow + 1) * g_grid_size;
            x1 = (i + 2) * g_grid_size;
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
        for (i = 0; i < mstate.nrow; i ++) {
            text_at(i, - 1, (i + 1).toString()+ " ", mark_font, "end", "middle");
            text_at(i, mstate.ncol, " " + (i + 1).toString()+ " ", mark_font, "start", "middle");
        }

        for (i = 0; i < mstate.ncol; i ++) {
            text_at(- 1, i, "ABCDEFGHIJLMNOPQRST"[i], mark_font, "center", "bottom");
            text_at(mstate.nrow, i, "ABCDEFGHIJLMNOPQRST"[i], mark_font, "center", "top");
        }
        
        //circle_at(0, 0, g_stone_radius, "white");
        //circle_at(0, 1, g_stone_radius, "black");

    }
    

    return {
        "set_canvas": set_canvas,
        "set_mstate": set_mstate,
        "draw_mstate": draw_mstate
    };
}());

