var jp = (function(){

    // connection type
    var FREE_CONN = "..";
    var LINE_CONN = "--";
    var OPEN_CONN = null;


    // input: o, could be any json object
    //    if o is not JSON compabitle, the non-compatible 
    //    part will be lost in the cloned object
    function jsonClone(o) {
        return JSON.parse(JSON.stringify(o));
    }

    // return an empty path
    function newPath() {
        return {"nodes":[]};
    }

    // return an undefined node
    function newNode() {
        return {"x":null,
                "y":null,
                "conn":null
               };
    }

    //
    // export a JSON path into Asymptote
    // input: a path object
    // output: a string representing a path/guide in asy
    function toAsy(P) {
        var p = jsonClone(P);
        var i, e, N = p.nodes.length;
        var asy = "";

        function _node2Asy(n) {
            return "(" + n.x.toFixed(3) + "," + n.y.toFixed(3) + ")";
        }

        function _dir(from, to) {
            var dx = to.x - from.x;
            var dy = to.y - from.y;
            return "{" + dx + "," + dy +"}";
        }

        // 
        // _k: previous node
        //  k: current node
        //
        // --+----+-----
        //   | _k |  k
        // --+----+-----
        // a | -- |  --
        // b | -- |  ..      z{dir}..
        // c | .. |  ..
        // d | .. |  --      ..{dir}z
        // --+----+-----
        function _for_interior_node(_k, k, k_) {
            var asy = _node2Asy(k);
            if (_k.conn === LINE_CONN && k.conn === FREE_CONN) { // b
                asy += _dir(_k, k);
            } else if (_k.conn === FREE_CONN && k.conn === LINE_CONN) { // d
                asy = _dir(k, k_) + asy;
            }
            k.asy = asy;
        }

        // the 1st node
        asy = _node2Asy(p.nodes[0]);
        if (p.nodes[0].conn === FREE_CONN && p.nodes[N-1].conn === LINE_CONN) { // din
            asy += _dir(p.nodes[N-1], p.nodes[0]);
        }
        p.nodes[0].asy = asy;

        for(i = 1; i < N-1; i ++) {
            _for_interior_node(p.nodes[i-1], p.nodes[i], p.nodes[i+1]);
        }

        //
        // the last node
        //
        _e = p.nodes[N-2];
        e = p.nodes[N-1];
        e_ = p.nodes[0];
        if (e.conn === FREE_CONN) {
            _for_interior_node(_e, e, e_);
        } else if (e.conn === LINE_CONN) {
            e.asy = _node2Asy(e);
        } 

        asy = p.nodes.map(function(x){return x.asy+(x.conn?x.conn:"");}).join("");

        // handle the cyclic case
        if (e.conn === FREE_CONN) {
            asy += "cycle"; // to add {dir} before cycle
        } else if (e.conn === LINE_CONN) {
            asy += "cycle";
        } 

        return asy;
    }

    function toSvg(p) {
        console.log("not implemented yet!");
        return null;
    }

    //
    // divide a path into a subpaths, each subpath is either a continuous free curve segments,
    // or a continuous straightline segments; subpath type (curve or straight line) can be
    // determined by any segment of the subpath.

    // the json format of a subpath is the same as for a path.
    //
    // input: P, read-only
    // return: an array of subpath, that:
    //     1. within each subpath, the conn type of all segments are the same;
    //     2. if several free curve segments can be contained in a single subpath, 
    //        it should not be divided into multiple subpaths.
    //        note that it's possible that divided subpath is the same as the 
    //        original path, if it's not dividable.
    //     3. the closeness of subpath is indicated by the last node of the subpath:
    //        if it's null, it's open; otherwise it's closed. this also implies that,
    //        if a path is divided into more than 1 subpaths, all subpath must be open;
    //     4. din/dout property will be added into subpath, when applicable.
    function divideOnePath(P) {

        var i, n = P.nodes.length;
        var p; 
        var subs = [];  // array of subpath
        var N; // subs.length;
        var sub = newPath();  // the current subpath
        var pre_conn, cur_conn, last_conn, first_conn;

        if (n < 2) {
            //console.log("divideOnePath(): too few nodes in the path!");
            return [];
        }

        p = jsonClone(P);

        //
        // making sure that each node has a proper connetor; 
        //
        for (i = 0; i < n-1; i ++) {
            if (p.nodes[i].conn !== FREE_CONN && 
                p.nodes[i].conn !== LINE_CONN) {
                console.log("divideOnePath(): invalid path!");
                return;
            }
        }
        // only the last node can have "null" connector    
        if (p.nodes[n-1].conn !== FREE_CONN && 
            p.nodes[n-1].conn !== LINE_CONN && 
            p.nodes[n-1].conn !== OPEN_CONN) {
            console.log("divideOnePath(): invalid path (last node)!");
            return;
        }

        // 
        // split straight line and curve into different subpaths, i.e., into subs[].
        // to prevent circular reference, always clone nodes here!
        //
        subs=[];
        sub=newPath();
        sub.nodes.push(jsonClone(p.nodes[0]));
        // determine "din"
        if (p.nodes[n-1] === LINE_CONN && p.nodes[0] === FREE_CONN) {
            sub.din = {"x":(p.nodes[n-1].x - p.nodes[0].x), "y":(p.nodes[n-1].y - p.nodes[0].y)};
        } else {
            sub.din = p.din; // inherite "din" if any
        }
        pre_conn = p.nodes[0].conn;
        for (i = 1; i < n; i ++) {
            cur_conn = p.nodes[i].conn;
            if (pre_conn === cur_conn) {
                sub.nodes.push(jsonClone(p.nodes[i]));
            } else {
                // previous subpath ends
                sub.nodes.push(jsonClone(p.nodes[i]));
                if (cur_conn === LINE_CONN) {
                    // calculate dout: z_-z
                    if (i < n-1) {
                        sub.dout = {"x":(p.nodes[i+1].x - p.nodes[i].x), "y":(p.nodes[i+1].y - p.nodes[i].y)}; 
                    } else {
                        sub.dout = {"x":(p.nodes[0].x - p.nodes[i].x), "y":(p.nodes[0].y - p.nodes[i].y)};
                    }
                }
                subs.push(sub);
                // start a new subpath with the current node
                sub = newPath();
                sub.nodes.push(jsonClone(p.nodes[i]));
                if (cur_conn === FREE_CONN) {
                    // calcuate din: _z-z
                    sub.din = {"x":(p.nodes[i].x - p.nodes[i-1].x), "y":(p.nodes[i].y - p.nodes[i-1].y)};
                }
                pre_conn = cur_conn;
            }
        }
        if (sub.nodes.length > 0) {  // a path may have only one node
            if (p.dout) {
                 sub.dout = p.dout; // inherit "dout" if any
            } else { // calc dout when applicable
                if (cur_conn === FREE_CONN && p.nodes[0].conn === LINE_CONN) {
                    sub.dout = {"x":(p.nodes[1].x - p.nodes[0].x), "y":(p.nodes[1].y - p.nodes[0].y)};
                }
            }
            subs.push(sub);
        }

        N = subs.length;

        //
        // check the conn of the last node, which is stored in cur_conn now.
        //
        // if the path is open, we have already done;
        // if the path is closed, we need to connect the 1st-sub and the last-sub somehow:
        //
        //   .-->[1st-sub] ... [last-sub]-->-.
        //   |                               |
        //    ------<-------------------<----
        // 
        // there are several cases:
        // 
        // 1. 1st-sub is the same as the last-sub, i.e., there is only one subpath 
        //    (which is the original path), we are done;
        // 2. otherwise, we have 8 possiblities, in terms of the conn type of (last-sub,last-node,1st-sub):
        //    +----------+-----------+----------+-------------------------------+ 
        //    | last-sub | last-node | 1st-sub  |     result                    |
        //    +----------+-----------+----------+-------------------------------+ 
        //  a |   --     |   --      |   --     |  prepend last-sub to 1st-sub  |
        //  h |   ..     |   ..      |   ..     |  ditto                        |
        //    +----------+-----------+----------+-------------------------------+ 
        //  c |   --     |   ..      |   --     |  a new sub with one segment   |
        //  f |   ..     |   --      |   ..     |  ditto                        |
        //    +----------+-----------+----------+-------------------------------+ 
        //  d |   --     |   ..      |   ..     |  prepend last-node to 1st-sub |
        //  e |   ..     |   --      |   --     |  ditto                        |
        //    +----------+-----------+----------+-------------------------------+ 
        //  b |   --     |   --      |   ..     |  append z0 to last-sub        |
        //  g |   ..     |   ..      |   --     |  ditto                        |
        //    +----------+-----------+----------+-------------------------------+ 
        //
        if (cur_conn !== LINE_CONN && cur_conn !== FREE_CONN) {
            // it's a open path...we have already done!
        } else { // it's a closed path
            if (N === 1) {
                // the subpath === the original path. we are also done!
            } else {
                // cur_conn: last-node
                first_conn = subs[0].nodes[0].conn;  // first-sub
                last_conn = subs[N-1].nodes[0].conn; // last-sub
                
                if (last_conn === first_conn && last_conn === cur_conn) { // a,h
                    // prepend last-sub to 1st-sub
                    subs[0].nodes = subs[N-1].nodes.concat(subs[0].nodes);
                    subs.pop();  // remove the last-sub
                } else if (first_conn === last_conn && first_conn !== cur_conn) { // c, f
                    // add a one segment sub
                    sub = newPath();
                    sub.nodes.push(jsonClone(p.nodes[n-1])); // last node
                    sub.nodes.push(jsonClone(p.nodes[0])); // 1st node
                    subs.push(sub);
                } else if (cur_conn === first_conn && cur_conn !== last_conn) { // d, e
                    // prepend last node to 1st sub
                    subs[0].nodes.unshift(jsonClone(p.nodes[n-1]));
                } else if (cur_conn === last_conn && cur_conn !== first_conn) { // b, g
                    // append z0 to last-sub
                    subs[N-1].nodes.push(jsonClone(p.nodes[0]));  
                } else {
                    console.log("it should be impossible...something wrong!");
                }
            }
        }

        // handle the closeness of each subpath
        if (subs.length > 1) { // if (subs.length<=0), we are done already.
            // making sure that each subpath is open
            subs.map(function(sub){
                var n = sub.nodes.length;
                sub.nodes[n-1].conn = null;
            });
        }

        console.log(arguments.callee.name, JSON.stringify(subs));

        return subs;
    }

    // test cases
    function test_divideOnePath() {

        var n, subs;

        // test case: z0..z1--z2..z3--z3..z4--z5
        var p={"nodes":[ {"x":0,"y":0, "conn":".."},
                         {"x":1,"y":1, "conn":"--"},
                         {"x":2,"y":2, "conn":".."},
                         {"x":3,"y":3, "conn":"--"},
                         {"x":3,"y":3, "conn":".."},
                         {"x":4,"y":4, "conn":"--"},
                         {"x":5,"y":5, "conn":null}
                       ]
              };

        n = p.nodes.length;

        // it should returns:
        // - z0..z1, dout=[1,1]
        // - z1--z2
        // - z2..z3, din=[1,1], dout=[0,0]
        // - z3--z3
        // - z3..z4, din=[0,0], dout=[1,1]
        // - z4--z5

        subs = divideOnePath(p);
        console.log(arguments.callee.name, ":", JSON.stringify(subs));


        //
        // when the path is closed:
        //
        // if(z5.conn==="--"): "z4--z5" becomes "z4--z5--z0"
        p.nodes[n-1].conn = "--";
        subs = divideOnePath(p);
        console.log(arguments.callee.name, ":", JSON.stringify(subs));
        // if(z5.conn===".."): "z0..z1" becomes "z5..z0..z1"
        p.nodes[n-1].conn = "..";
        subs = divideOnePath(p);
        console.log(arguments.callee.name, ":", JSON.stringify(subs));


        //
        // test case: z0..z1..z2..
        //
        var p={"nodes":[ {"x":0,"y":0, "conn":".."},
                         {"x":1,"y":1, "conn":".."},
                         {"x":2,"y":2, "conn":".."}
                       ]
              };

        n = p.nodes.length;
        subs = divideOnePath(p);
        console.log(arguments.callee.name, ":", JSON.stringify(subs));

        //
        // test case: z0..z1..z2..z3..z0--
        //
        var p={"nodes":[ {"x":0,"y":0, "conn":".."},
                         {"x":1,"y":1, "conn":".."},
                         {"x":2,"y":2, "conn":".."},
                         {"x":3,"y":3, "conn":".."},
                         {"x":0,"y":0, "conn":"--"}
                       ]
              };

        n = p.nodes.length;
        subs = divideOnePath(p);
        console.log(arguments.callee.name, ":", JSON.stringify(subs));
        
        //
        // test case: z3..z0--z0..z1..z2..
        //
        var p={"nodes":[ {"x":3,"y":3, "conn":".."},
                         {"x":0,"y":0, "conn":"--"},
                         {"x":0,"y":0, "conn":".."},
                         {"x":1,"y":1, "conn":".."},
                         {"x":2,"y":2, "conn":".."}
                       ]
              };

        n = p.nodes.length;
        subs = divideOnePath(p);
        console.log(arguments.callee.name, ":", JSON.stringify(subs));

        //
        // test case: z0--z1--z2--
        //
        var p={"nodes":[ {"x":0,"y":0, "conn":"--"},
                         {"x":1,"y":1, "conn":"--"},
                         {"x":2,"y":2, "conn":"--"}
                       ]
              };

        n = p.nodes.length;
        subs = divideOnePath(p);
        console.log(arguments.callee.name, ":", JSON.stringify(subs));

        //
        // test case: z0..z1..z2--z3--
        //
        var p={"nodes":[ {"x":0,"y":0, "conn":".."},
                         {"x":1,"y":1, "conn":".."},
                         {"x":2,"y":2, "conn":"--"},
                         {"x":3,"y":3, "conn":"--"},
                       ]
              };

        n = p.nodes.length;
        subs = divideOnePath(p);
        console.log(arguments.callee.name, ":", JSON.stringify(subs));
    }

    function solvePath(P) {
        var SUBS = divideOnePath(P);
        //console.log(JSON.stringify(SUBS));
        var i, N = SUBS.length;
        for (i = 0; i < N; i ++) {
            if (SUBS[i].nodes[0].conn === FREE_CONN) {
                jh.solveFreePath(SUBS[i]);
            }
        }
        return SUBS;
    }


    function test_solvePath() {
        var P={"nodes":[ {"x":0,"y":0, "conn":".."},
                         {"x":100,"y":0, "conn":".."},
                         {"x":100,"y":100, "conn":".."},
                         {"x":50,"y":50, "conn":"--"},
                       ]
              };

        console.log(JSON.stringify(solvePath(P)));
    }

    function test() {
        //test_divideOnePath();
        test_solvePath();
    }

    return {
        // methods
        "jsonClone": jsonClone,  // clone an object by "JSON.parse(JSON.stringify(o))"
        "newPath": newPath, // return an empty path
        "newNode": newNode, // return an new node with default properties;
        "toAsy": toAsy, // 
        "toSvg": toSvg,
        "solvePath": solvePath, // assign u,v values for all nodes of free curve segments
        // test method
        "test": test,
        //constants
        "FREE_CONN": FREE_CONN,
        "LINE_CONN": LINE_CONN,
        "OPEN_CONN": OPEN_CONN
    };
}());
