var j2c = (function(){
    var _ctx = null;

    // canvas context constants
    var POLYGON_LINE_WIDTH = 1;
    var POLYGON_STROKE_STYLE = "red";
    var BEZIER_LINE_WIDTH = 3;
    var BEZIER_STROKE_STYLE = "blue";
    var DOT_RADIUS = 4;
    var DOT_FILL_STYLE = "black";
    var CURSUR_LINE_WIDTH = 1; // cursor in the center or the dot
    var CURSUR_SIZE = 4;
    var CURSUR_STROKE_STYLE = "white";
     
    function setContext(ctx) {
        _ctx = ctx;
    }

    //
    // draw a free path: all segments are connected bezier curves
    // 
    function drawFreePath(p, is_line_path) {

        var u, v;
        var N = p.nodes.length;

        if (N < 2) {
            return;
        }

        _ctx.lineWidth = BEZIER_LINE_WIDTH;
        _ctx.strokeStyle = BEZIER_STROKE_STYLE;
        _ctx.beginPath();
        _ctx.moveTo(p.nodes[0].x, -p.nodes[0].y);
        u = p.nodes[0].u;
        for(j = 1; j < N; j ++) {
            v = p.nodes[j].v;
            _ctx.bezierCurveTo(u.x, -u.y, v.x, -v.y, p.nodes[j].x, -p.nodes[j].y);
            u = p.nodes[j].u;
        }
        if (p.nodes[N-1].conn === jp.FREE_CONN) { // cyclic
            v = p.nodes[0].v;
            _ctx.bezierCurveTo(u.x, -u.y, v.x, -v.y, p.nodes[0].x, -p.nodes[0].y);
            _ctx.closePath();
        }
        _ctx.stroke();

        //
        // draw straight lines
        //
        if (is_line_path) {
            _ctx.lineWidth = POLYGON_LINE_WIDTH;
            _ctx.strokeStyle = POLYGON_STROKE_STYLE;
            _ctx.beginPath();
            _ctx.moveTo(p.nodes[0].x, -p.nodes[0].y);
            for(j = 1; j < N; j ++) {
                _ctx.lineTo(p.nodes[j].x, -p.nodes[j].y);
            }
            if (p.nodes[N-1].conn === jp.FREE_CONN) { // cyclic
                _ctx.closePath();
            }
            _ctx.stroke();
        }
    }

    //
    // draw a straight path: all segments are straight lines
    // 
    function drawStraightPath(p) {

        var j, n = p.nodes.length;
        if (n < 2) {
            return;
        }

        _ctx.lineWidth = BEZIER_LINE_WIDTH;
        _ctx.strokeStyle = BEZIER_STROKE_STYLE;
        _ctx.beginPath();
        _ctx.moveTo(p.nodes[0].x, -p.nodes[0].y);
        for(j = 1; j < n; j ++) {
            _ctx.lineTo(p.nodes[j].x, -p.nodes[j].y);
        }

        // closeness of path/subpath is conveyed in its last node
        if (p.nodes[n-1].conn === jp.LINE_CONN) {
            _ctx.closePath();
        }
        _ctx.stroke();
    }

    // is_line_path: optional, indicate whether or not draw lines connecting nodes
    function drawOnePath(P, is_line_path) {

        var subs = jp.solvePath(P);

        subs.map(function(s){
            if (s.nodes[0].conn === jp.LINE_CONN) {
                drawStraightPath(s);
            } else {
                drawFreePath(s, is_line_path);
            }
        });
    }

    function test_drawOnePath() {
        var z0 = {x:100, y:-100, conn:".."};
        var z1 = {x:200, y:-100, conn:".."};
        var z2 = {x:200, y:-200, conn:".."};
        var z3 = {x:150, y:-130, conn:".."};
        var z00 = {x:100, y:-100, conn:"--"};

        var p = {"nodes":[ z0, z1, z2, z3, z00] };
        drawOnePath(p);


        var z22 = jp.jsonClone(z2);
        z2.conn = "--";
        var p2={"nodes":[ z0, z1, z2, z22, z3, z00] };
        p2.nodes.map(function(n){ n.x += 200; }); // shift right
        drawOnePath(p2);
    }

    function dotOnePath(p) {
        function _dot(x, y) {
            // dot
            _ctx.beginPath(); 
            _ctx.arc(x, y, DOT_RADIUS, 0, Math.PI*2, true); 
            _ctx.fillStyle = DOT_FILL_STYLE; 
            _ctx.fill();

            // cursor
            _ctx.beginPath();
            _ctx.lineWidth = CURSUR_LINE_WIDTH;
            _ctx.strokeStyle = CURSUR_STROKE_STYLE;
            _ctx.moveTo(x-CURSUR_SIZE, y);
            _ctx.lineTo(x+CURSUR_SIZE, y);
            _ctx.moveTo(x, y-CURSUR_SIZE);
            _ctx.lineTo(x, y+CURSUR_SIZE);
            _ctx.stroke();
        }

        p.nodes.map(function(k){return _dot(k.x, -k.y);});
    }
    
    function test() {
        if (!_ctx) {
            setContext(ctx);  // assumption: the global ctx already exists
        }

        test_drawOnePath();
    }

    return {
        "setContext": setContext,
        "drawOnePath": drawOnePath,
        "dotOnePath": dotOnePath,
        "test": test
    };
}());
