/////////////////////////////////////////////////////////////////////////////////////////////////////
//
// created(bruin, 2015-01-19)
// last updated(bruin, 2015-01-31)
// email: sansidee at foxmail.com
//
// This "module" implements the algorithm described in the following paper: 
// - John D. Hobby: Smooth, easy to compute interpolating splines, Discrete Computational Geometry, 1:123-140, 1986
// http://i.stanford.edu/pub/cstr/reports/cs/tr/85/1047/CS-TR-85-1047.pdf
//
// ... by also using the following references:
// - Donald E Knuth. The METAFONT book, Addison-Wesley, Reading, Massachusetts, 1986
// - Python version of the algo: http://tex.stackexchange.com/questions/54771/curve-through-a-sequence-of-points-with-metapost-and-tikz
// - Solving linear system: http://en.wikipedia.org/wiki/Gaussian_elimination
//
// The required complex number arithmetics and linear system solution are contained within this module,
// so no external dependency is required.
//
// In a nutshell, it takes in a path which contains one or more continuously connected free curve 
// segments, and return a path with solved control points stored in the nodes.
//
// The input path can be either open or closed; when the path is open, it can also specify
// the incoming direction "din" at the 1st node, or the outgoing direction "dout" at the 
// last node, or both.
//
// Note that if the user has a path composed of both free curve segments and straight line segments, 
// the user/caller has to split the original path into free curve subpath(s) and straight line 
// subpath(s), and passing the free curve subpath(s), one at a time, to this module for obtaining 
// the control points.
//
// The initial intention of this module was for vectorizing some images, which is done by:
// - draw the image in a Canvas of a html app
// - mouse click on key points on the canvas to form path(s)
// - export the path(s) to Asymptote
//
// This module is to visualize the 2nd step above, so the app user knows intuitively whether or not 
// the exported the path will be satisfactory. That's why John Hobby's algorithm is used, as 
// it is used by Asymptote (which follows METAPOST/METAFONT).
//
// This "module" may be also used in for some other "creative activities", or just for fun...
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
//  A node z[k] can contain the following properties:
//   - _l: |z[k]-z[k-1]|
//   - l_: |z[k+1]-z[k]|
//   - alpha: 
//   - beta:
//   - xi: turning angle in radian, within (-Pi, Pi]
//   - theta: departure/outgoing angle, in radian
//   - phi: arrival/incoming angle, in radian
//   - u: the 1st control point for z[k]..z[k+1]
//   - v: the 2nd control point for z[k-1]..z[k]
//
var jh = (function(){

    //
    // constants
    //
    var DEFAULT_ALPHA = 1;  // alpha & beta are tensions, should be >3/4. the bigger the straighter the curve
    var DEFAULT_BETA = 1;
    var DEFAULT_CURL_BEGIN = 1;
    var DEFAULT_CURL_END = 1;

    //
    // path connectors, as defined in p127 of "The METAFONT book"
    //
    var FREE_CURVE = "..";
    var STRAIGHT_LINE = "--";
    // the following are not supported
    var BOUNDED_CURVE = "..."; 
    var TENSE_LINE = "---";
    var SPLICE = "&";

    //
    // make Math function names shorter
    //
    var PI = Math.PI;
    var abs = Math.abs;
    var pow = Math.pow;
    var sqrt = Math.sqrt;
    var sin = Math.sin;
    var cos = Math.cos;
    var atan = Math.atan;

    //
    // vector (complex number) arithmetics
    //
    var z = (function(){
        function _sum(z0, z1) {
            return {x:z0.x+z1.x, y:z0.y+z1.y};
        }
        function _sub(z0, z1) {
            return {x:z0.x-z1.x, y:z0.y-z1.y};
        }
        function _prod(z0, z1) {
            return {x:z0.x*z1.x-z0.y*z1.y, y:z0.x*z1.y+z0.y*z1.x};
        }
        function _mod(z) {
            return sqrt(z.x*z.x + z.y*z.y);
        }
        function _arg(z) {
            if (z.x == 0) {
                if (z.y > 0) {
                    return PI/2;
                } else if (z.y < 0) {
                    return -PI/2;
                } else {
                    return 0; // ?
                }
            } else {
                var arg = atan(abs(z.y/z.x));
                if (z.x > 0) {
                    return (z.y>0)? arg: -arg;
                } else {
                    return (z.y>0)? PI - arg: - PI  + arg;
                }
            }
        }
        return {
            "sum": _sum,
            "sub": _sub,
            "prod": _prod,
            "mod": _mod,
            "arg": _arg
        };
    }());

    // limit angles within (-PI, PI]
    function limitArg(arg) {
        arg = arg % (PI*2);
        if (arg > PI) {
            arg = arg - PI*2;
        }
        if (arg <= -PI) {
            arg = arg + PI*2;
        }
        return arg;
    }

    //
    // ref: http://en.wikipedia.org/wiki/Gaussian_elimination
    //
    // A: matrix (an array of array, mxn, i.e. m rows and n columns)
    // b: vector (mx1)
    // m,n: size of the matrix
    // return: x, a vector (array of m elements)
    function solveLinearSystem(A, b, m, n) {
        var i, j, k, u, maxi, tmp, pivot, sum;
        var M = [], x = [];

        // deep copy A and b into M as combined
        for (i = 0; i < m; i ++) {
            var row = [];
            for (j = 0; j < n; j ++) {
                row.push(A[i][j]);
            }
            row.push(b[i]);
            M.push(row);
        }

        //
        // elimination 
        //
        i = 0;  // row 
        j = 0;  // col
        while (i < m && j < n) {
            // find pivot (i.e. its row index) in col j, starting from row i
            maxi = i;  // idx of the row whose column j is the max
            for (k = i+1; k < m; k ++) {
                if (abs(M[k][j]) > abs(M[maxi][j])) {
                    maxi = k;
                }
            }

            if (M[maxi][j] != 0) {
                // swap row maxi and i
                if (maxi != i) { 
                    tmp = M[maxi];
                    M[maxi] = M[i];
                    M[i] = tmp;
                }
                pivot = M[i][j];

                // divide i row by the pivot
                for (k = 0; k < n + 1; k ++) {
                    M[i][k] = M[i][k] / pivot;
                }
                // now the pivot M[i][j] = 1

                // substract M[u][j] * row i from row u 
                for (u = i+1; u < m; u ++) {
                    pivot = M[u][j];
                    for (k = 0; k < n + 1; k ++) {
                        M[u][k] = M[u][k] - M[i][k] * pivot;
                    }
                }
                i = i + 1;
            }
            j = j +1;
        }

        //
        // get the results
        //
        if (m == n) {
            x[m-1] = M[m-1][m];
            for (i = m-2; i >=0; i --) {
                sum = 0;
                for (j = i+1; j < m; j ++) {
                    sum = sum + M[i][j] * x[j];
                }
                x[i] = M[i][m] - sum;
            }
        }

        return x;
    }

    // test
    function test_solveLinearSystem() {
        var A = [[2,1,-1],[-3,-1,2],[-2,1,2]];
        var b = [8,-11,-3];
        var x = solveLinearSystem(A,b,3,3); // x should be [2, 3, -0.999]
        console.log(x);
    }

    //
    // velocity function f(theta, phi)
    //
    // theta: departure angle (in rad) at the first point z0, relative to z1-z0
    // phi: arrival angle (in rad) at the second point z1, relative to z1-z0
    //
    function _f(theta, phi) {
        var n = 2+sqrt(2)*(sin(theta)-sin(phi)/16)*(sin(phi)-sin(theta)/16)*(cos(theta)-cos(phi));
        var m = 3*(1 + 0.5*(sqrt(5)-1)*cos(theta) + 0.5*(3-sqrt(5))*cos(phi));
        return n/m;
    }

    //
    // return u and v in an array: [u, v]
    //
    function _uv(z0, z1, theta, phi, alpha, beta) {
        // the formula using complex numbers:
        // u = z0+exp(i*theta)*(z1-z0)*f(theta,phi)/alpha
        // v = z1-exp(-i*phi)*(z1-z0)*f(phi,theta)/beta

        var l = z.sub(z1, z0);  // l = z1-z0
        var t = {"x": cos(theta), "y": sin(theta)};  // exp(i*theta)
        var p = {"x": cos(-phi), "y": sin(-phi)};    // exp(-i*phi)

        var u = z.sum(z0, z.prod(t,z.prod(l,{"x":_f(theta,phi)/alpha,"y":0})));
        var v = z.sub(z1, z.prod(p,z.prod(l,{"x":_f(phi,theta)/beta,"y":0})));

        return [u,v];
    }

    // check validity of a path
    function _isValid(p) {
        // making sure each segment is a free curve segment
        var i, n = p.nodes.length;

        if (n < 2) {
            console.log(arguments.callee.name, "invalid path: too few nodes.");
            return false;
        }

        for (i = 0; i < n - 1; i ++) {
            if (p.nodes[i].conn !== FREE_CURVE) {
                console.log(arguments.callee.name, "invalid conn type.");
                return false;
            }
        }

        if (p.nodes[n-1].conn && p.nodes[n-1].conn !== FREE_CURVE) {
            console.log(arguments.callee.name, "invalid conn type of the last node.");
            return false;
        }

        return true;
    }

    // ignore din when its {0,0} 
    function _hasDin(p) {
        return (p.din && (!(p.din.x ===0 && p.din.y === 0)));
    }

    // ignore dout when its {0,0} 
    function _hasDout(p) {
        return (p.dout && (!(p.dout.x ===0 && p.dout.y === 0)));
    }

    // check if the path is closed
    function _isCyclic(p) {
        var n = p.nodes.length;
        return ((n>1) && (p.nodes[n-1].conn === FREE_CURVE));
    }

    function _checkCurlAlphaBeta(p) {

        p.curl_begin = p.curl_begin || DEFAULT_CURL_BEGIN;
        p.curl_end = p.curl_end || DEFAULT_CURL_END;

        // the properties of each node
        p.nodes.forEach(function(n) {
            n.alpha = n.alpha || DEFAULT_ALPHA;
            n.beta = n.beta || DEFAULT_BETA;
        });
    }

    //
    // g: a path
    // output: the following node properties are udpated:
    //  "xi": turning angle at z[k]
    //  "_l": |z[k]-z[k-1]|
    //  "l_": |z[k+1]-z[k]|
    //  "_arg": arg(z[k]-z[k-1])
    //  "arg_": arg(z[k+1]-z[k])
    function _updateArgXiL(g) {

        var i, N = g.nodes.length; 
        var cyclic = _isCyclic(g);
        
        if (N < 2) {
            return;
        }

        // first node
        if (!cyclic) {
            var l_ = z.sub(g.nodes[1], g.nodes[0]);
            g.nodes[0]._l = 0;
            g.nodes[0].l_ = z.mod(l_);
            g.nodes[0].arg_ = z.arg(l_);
            if (_hasDin(g)) {
                g.nodes[0]._arg = z.arg(g.din);
                g.nodes[0].xi = limitArg(g.nodes[0].arg_ - g.nodes[0]._arg);
            } else {
                g.nodes[0]._arg = 0;
                g.nodes[0].xi = 0;
            }
        } else {
            _for_interior_node(g.nodes[N-1], g.nodes[0], g.nodes[1]); 
        }

        // middle nodes
        for (i = 1; i < g.nodes.length-1; i ++) {
            _for_interior_node(g.nodes[i-1], g.nodes[i], g.nodes[i+1]);
        }

        // last node
        if (!cyclic) {
            var _l = z.sub(g.nodes[N-1], g.nodes[N-2]);
            g.nodes[N-1]._l = z.mod(_l);
            g.nodes[N-1]._arg = z.arg(_l);
            g.nodes[N-1].l_ = 0;
            if (_hasDout(g)) {
                g.nodes[N-1].arg_ = z.arg(g.dout);
                g.nodes[N-1].xi = limitArg(g.nodes[N-1].arg_ - g.nodes[N-1]._arg);
                //console.log(arguments.callee.name, JSON.stringify(g));
            } else {
                g.nodes[N-1].arg_ = 0;
                g.nodes[N-1].xi = 0;
            }
        } else {
            _for_interior_node(g.nodes[N-2], g.nodes[N-1], g.nodes[0]);
        }

        // input: _k : g[k-1] : read-only
        //         k : g[k]   : in and out. the l_/_l/xi properties of this node will be updated
        //         k_: g[k+1] : read-only
        function _for_interior_node (_k, k, k_) {

            var _l = z.sub(k, _k);
            var l_ = z.sub(k_, k);
            var _arg = z.arg(_l);
            var arg_ = z.arg(l_);

            k.l_ = z.mod(l_);
            k._l = z.mod(_l);
            k._arg = _arg;
            k.arg_ = arg_;
            k.xi = limitArg(arg_ - _arg);
        }
    }

    function test_updateArgXiL() {
        // 1. non-cyclic:
        var g = {nodes: [{x:0,y:0, conn:".."},{x:100,y:0, conn:".."},{x:100,y:100}]};
        _updateArgXiL(g);
        console.log(arguments.callee.name, JSON.stringify(g));

        // 2. cyclic:
        var g = {nodes: [{x:0,y:0, conn:".."},{x:100,y:0, conn:".."},{x:100,y:100, conn:".."}]};
        _updateArgXiL(g);
        console.log(arguments.callee.name, JSON.stringify(g));

    }

    //
    // This function creates five vectors which are coefficients of a
    // linear system which allows finding the right values of "theta" at
    // each point of the path (being "theta" the angle of departure of the
    // path at each point). 
    function _buildLinearSystem(g) {
        var i, n, N = g.nodes.length;
        var A=[], B=[], C=[], D=[], R=[];
        // 
        // Notes on the meaning of A/B/C/D/R:
        // 
        // Here the theta at each node are treated as unknown. for node k,
        // its equation can be expressed as (denote theta[k-1], theta[k], 
        // and theta[k+1] as _t, t, and t respectively):
        //
        // a*_t + (b+c)*t + d*t_ = r
        // 
        // where a/b/c/d/r for all nodes forms its own vector A/B/C/D/R 
        // respectively.
        //
        // then A/B/C/D/R is used to form the tri-diagonal matrix 
        // (http://en.wikipedia.org/wiki/Tridiagonal_matrix): 
        // 
        // | b+c d   ...a |
        // | a b+c d  ... |
        // | . a b+c d  . | * T[] = R[]
        // |    ......    |
        // | d......a b+c |
        //
        // The equations are from METAFONT book, page 131 in chapter 14.
        // There are 4 equations:
        //
        // (*): theta+phi+xi=0
        // (**): equation for interior nodes
        // (***): equation for z0 if direction is not explicitly given
        // (***'): equation for zn if direction is not explicitly given
        //
        // The last 3 equations can be expressed in the unified form:
        // (theta: t, alpha: a, beta: b, length: l, turn angle: xi)
        //
        // A*_t + (B+C)*t + D*t_ = R, thus
        //
        // (**) for interior nodes:
        //   A=X/_a
        //   B=X*(3-1/_a)
        //   C=Y*(3-1/b_)
        //   D=Y/b_
        //   R=-B*xi-D*xi_
        // where X=b^2/l, Y=a^2/l_
        // 
        // (***) for the 1st node:
        //   A=0
        //   B=0
        //   C=(1/b_-3)*X-1/a*Y
        //   D=-1/b_*X+(1/a-3)*Y
        //   R=-D*xi_
        // where X=a^2, Y=curl_start*b_^2
        // if theta_0 is known, then A=B=D=0,C=1, R=theta_0;
        // 
        // (***') for the last node:
        //   A=1/_a*X+(3-1/b)*Y
        //   B=(3-1/_a)*X+1/b*Y
        //   C=0
        //   D=0
        //   R=-B*xi
        // where X=b^2, Y=curl_end*_a^2
        // if theta_n is known, then A=B=D=0,C=1, R=theta_n;
        //
        
        // input: _k : g[k-1]
        //         k : g[k]  
        //         k_: g[k+1]
        //        idx: the idx for node "k"
        // output: A/B/C/D/R is updated accordingly
        function _for_interior_node2 (_k, k, k_, idx) {
            var X = pow(k.beta,2)/k._l;
            var Y = pow(k.alpha,2)/k.l_;
            A.push(X/_k.alpha);
            B.push(X*(3-1/_k.alpha));
            C.push(Y*(3-1/k_.beta));
            D.push(Y/k_.beta);
            R.push(-B[idx]*k.xi-D[idx]*k_.xi);
        }

        //
        // traverse the path now...
        //
        if (!_isCyclic(g)) {
            if (_hasDin(g)) { // already known: theta = -xi, because phi=0
                A.push(0);
                B.push(0);
                C.push(1);
                D.push(0);
                R.push(-g.nodes[0].xi);
            } else {
                A.push(0);
                B.push(0);
                var curl = g.curl_begin;
                var alpha_0 = g.nodes[0].alpha;
                var beta_1 = g.nodes[1].beta;
                var X=pow(alpha_0,2);
                var Y=curl*pow(beta_1,2);
                C.push(((1/beta_1)-3)*X-1/alpha_0*Y);
                D.push(-1/beta_1*X+(1/alpha_0-3)*Y);
                R.push(-D[0]*g.nodes[1].xi);
            }
        } else {
            _for_interior_node2(g.nodes[N-1], g.nodes[0], g.nodes[1], 0);
        }

        // Equations 1 to N-1 
        for (k = 1; k < N-1; k ++ ) {
            _for_interior_node2(g.nodes[k-1], g.nodes[k], g.nodes[k+1], k);
        }

        if (!_isCyclic(g)) {
            if (_hasDout(g)) { // already known: theta=0, because phi=-xi;
                A.push(0);
                B.push(0);
                C.push(1);
                D.push(0);
                R.push(0);
            } else {
                n = R.length;     // index to generate
                C.push(0);
                D.push(0);
                var curl = g.curl_end;
                var beta_n = g.nodes[n].beta;
                var alpha_n_1 = g.nodes[n-1].alpha;
                var X=pow(beta_n,2);
                var Y=curl*pow(alpha_n_1,2);
                A.push(1/alpha_n_1*X+(3-1/beta_n)*Y);
                B.push((3-1/alpha_n_1)*X+1/beta_n*Y);
                C.push(0);
                D.push(0);
                R.push(-B[n]*g.nodes[n].xi);  // g.nodes[n].xi usually be zero, so effectively R[n]=0
            }
        } else {
            _for_interior_node2(g.nodes[N-2], g.nodes[N-1], g.nodes[0], N-1);
        }

        var matrix = _buildMatrix(A, B, C, D, R);
        return [matrix, R];



        function _buildMatrix(A, B, C, D, R) {
            var k, j, prev, post, L = R.length;

            // create the empty matrix
            var a = new Array(L);
            for(k = 0; k < L; k ++) {
                a[k] = new Array(L);
                // need to init the array with zero!
                for (j = 0; j < L; j ++) {
                    a[k][j] = 0; 
                }
            }

            for(k = 0; k < L; k ++) {
                prev = (k-1+L)%L;  // "+L" is to make (prev>=0)
                post = (k+1)%L;
                a[k][prev] = A[k];
                a[k][k]    = B[k]+C[k];
                a[k][post] = D[k];
            }

            return a;
        }
    }

    function test_buildLinearSystem() {
        var g = {nodes: [
            {x:0,y:0, conn:".."},
            {x:100,y:0, conn:".."},
            {x:100,y:100, conn:".."},
            {x:50,y:50, conn:".."}]};
        _updateArgXiL(g);
        _checkCurlAlphaBeta(g);
        var r = _buildLinearSystem(g);
        console.log(arguments.callee.name, JSON.stringify(r));
    }

    // this function computes the control points for each node
    // and stores those in the path
    function solveFreePath(g) {
        var k, uv, N = g.nodes.length;
        var cyclic = _isCyclic(g);
        var Mb; // [M, b]
        var x; // theta vector

        if (!_isValid(g)) {
            console.log(arguments.callee.name, "invalid path");
            return;
        }

        _updateArgXiL(g);
        _checkCurlAlphaBeta(g);
        Mb = _buildLinearSystem(g);

        //
        // solve thetas for each node
        //
        x = solveLinearSystem(Mb[0], Mb[1], N, N);

        //
        // update theta/phi of each node
        //
        for (k = 0; k < N; k ++) {
            g.nodes[k].theta = x[k];
            g.nodes[k].phi = -g.nodes[k].theta - g.nodes[k].xi;
            //console.log(k, "theta:", g.nodes[k].theta, "phi:", g.nodes[k].phi);
        }

        // 
        // calculate u, v
        //
        // N nodes mean N-1 segments (if non-cyclic) and N segments (if cyclic).
        for (k = 0; k < N-1; k ++) {
            uv = _for_each_segment(g.nodes[k], g.nodes[k+1]);
            g.nodes[k].u = uv[0]; 
            g.nodes[k+1].v = uv[1];
        }

        if (_isCyclic(g)) {
            uv = _for_each_segment(g.nodes[N-1], g.nodes[0]);
            g.nodes[N-1].u = uv[0];
            g.nodes[0].v = uv[1];
        }

        // return control points [u,v] for one segment betw z0..z1
        function _for_each_segment(z0, z1) {
            var theta = z0.theta;
            var phi = z1.phi;
            var alpha = z0.alpha;
            var beta = z1.beta;

            //console.log(arguments.callee.name, "theta:", theta, "phi:", phi);
            return _uv(z0, z1, theta, phi, alpha, beta);
        }
    }

    function test_solveFreePath() {
        var g = {nodes: [
            {x:0,y:0, conn:".."},
            {x:100,y:0, conn:".."},
            {x:100,y:100, conn:".."},
            {x:50,y:50, conn:".."}]};

        solveFreePath(g);
        console.log(arguments.callee.name, JSON.stringify(g));
    }

    function test () {
        //test_solveLinearSystem();
        //test_updateArgXiL();
        //test_buildLinearSystem();
        test_solveFreePath();
    }

    return {
        "solveFreePath": solveFreePath,
        "test": test,
    };
}());


