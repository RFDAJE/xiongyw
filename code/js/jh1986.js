// created(bruin, 2015-01-19)
// last updated(bruin, 2015-01-22)
// email: sansidee at foxmail.com
//
// This "module" implements the algorithm described in the following paper, without external dependency: 
// - John D. Hobby:　Smooth,　easy　to　compute　interpolating　splines. Discrete　Comput.　Geom.,　1:123－140,1986
// ...by using the following references:
// - Donald E Knuth. The METAFONT book, Addison-Wesley, Reading, Massachusetts, 1986
// - Python version of the algo: http://tex.stackexchange.com/questions/54771/curve-through-a-sequence-of-points-with-metapost-and-tikz
// - Solving linear system: http://en.wikipedia.org/wiki/Gaussian_elimination
//
// This "module" may be used in a browser app...using Canvas or SVG for drawing, 
// together with mouse/kbd events, just for fun, or for some "creative activities"...
// and it's straight forward to "export" the created path(s) to other systems (e.g. Asymptote).
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
// Sample usage (also a test case):
//
// 1. A non-cyclic case:
//   var g=[[0,0],[100,0],[100,100]];
//   jh.solve_angles(g);  // now departure/arrival angles are available in g;
//   jh.find_control_points(g); // now control points (u, v) are available in g;
// Then: 
//   g[0].u=[27.614237491539676, -27.61423749153966], g[0].v=undefined
//   g[1].u=[127.61423749153968, 27.61423749153967], g[1].v=[72.38576250846032, -27.61423749153966]
//   g[2].u=undefined, g[2].v=[127.61423749153968, 72.38576250846033]
//
// 2. A cyclic case
//   var g=[[0,0],[100,0],[100,100]];
//   g.cyclic = true;
//   jh.solve_angles(g);  
//   jh.find_control_points(g);
// Then:
//   g[0].u=[24.141650832591306, -30.77287601266758], g[0].v=[-51.96389295116529, 66.23732759662731]
//   g[1].u=[129.05587460326385, 29.055874603263845], g[1].v=[70.94412539673614, -29.055874603263845]
//   g[2].u=[33.76267240337269, 151.9638929511653], g[2].v=[130.77287601266758, 75.85834916740869]
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
// Note: 
//
//  A node/knot of a guide/path is represented by a point on the plane (z), which is 
//  represented here by an array of two numbers: [x,y]; 
//  A node, i.e., this array (also an object), can also contain "metapost properties":
//   - d_post: |z[k+1]-z[k]|
//   - d_ant: |z[k]-z[k-1]|
//   - alpha: 
//   - beta:
//   - xi: turning angle (at the node on the polygon of the guide)
//   - theta: departure angle
//   - phi: arraival angle
//   - u: the 1st control point betw this node and its NEXT node
//   - v: the 2nd control point betw this node and its PREV node
//
// A path/guide is represented by an array of points. The path/guide can contain 
// the following "metapost" properties:
//   - cyclic: bool
//   - curl_begin:
//   - curl_end:
//

var jh = (function(){
    // return the complex sum
    function c_sum(z0, z1) {
        return [z0[0]+z1[0], z0[1]+z1[1]];
    }

    // return the complex sub
    function c_sub(z0, z1) {
        return [z0[0]-z1[0], z0[1]-z1[1]];
    }

    // return the complex production
    function c_prod(z0, z1) {
        return [z0[0]*z1[0]-z0[1]*z1[1], z0[0]*z1[1]+z0[1]*z1[0]];
    }

    // return the length of the vector
    function c_mod(z) {
        return Math.sqrt(z[0]*z[0] + z[1]*z[1]);
    }

    // return the angle (in rad) of a vector
    function c_arg(z) {
        if (z[0] == 0) {
            if (z[1] > 0) {
                return Math.PI/2;
            } else if (z[1] < 0) {
                return -Math.PI/2;
            } else {
                return 0; // ?
            }
        } else {
            var arg = Math.atan(Math.abs(z[1]/z[0]));
            if (z[0] > 0) {
                return (z[1]>0)? arg: -arg;
            } else {
                return (z[1]>0)? Math.PI - arg: - Math.PI  + arg;
            }
        }
    }


    //
    // http://en.wikipedia.org/wiki/Gaussian_elimination
    //
    // A: matrix (an array of array, mxn, i.e. m rows and n columns)
    // b: vector (mx1)
    // m,n: size of the matrix
    // return: x, a vector (array of m elements)
    //
    // sample usage:
    //
    // var A=[[2,1,-1],[-3,-1,2],[-2,1,2]];
    // var b=[8,-11,-3];
    // var x=solve_matrix(A,b,3,3);
    //
    // then: x=[2, 3, -0.9999999999999999];
    //
    function solve_matrix(A, b, m, n) {
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

        /*
         * elimination 
         */
        i = 0;  // row 
        j = 0;  // col
        while (i < m && j < n) {
            // find pivot (i.e. its row index) in col j, starting from row i
            maxi = i;  // idx of the row whose column j is the max
            for (k = i+1; k < m; k ++) {
                if (Math.abs(M[k][j]) > Math.abs(M[maxi][j])) {
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

        /* 
         * get the results
         */
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

    /*
     * the following routines are "cloned" from the original python code:
     * http://tex.stackexchange.com/questions/54771/curve-through-a-sequence-of-points-with-metapost-and-tikz
     */

    var MP_DEFAULT_ALPHA = 1;
    var MP_DEFAULT_BETA = 1;
    var MP_DEFAULT_CURL_BEGIN = 1;
    var MP_DEFAULT_CURL_END = 1;

    /*
     * velocity function f(theta, phi)
     *
     * theta: departure angle (in rad) at the first point z0, relative to z1-z0
     * phi: arrival angle (in rad) at the second point z1, relative to z1-z0
     */
    function f(theta, phi) {
        var n = 2+Math.sqrt(2)*(Math.sin(theta)-Math.sin(phi)/16)*(Math.sin(phi)-Math.sin(theta)/16)*(Math.cos(theta)-Math.cos(phi));
        var m = 3*(1 + 0.5*(Math.sqrt(5)-1)*Math.cos(theta) + 0.5*(3-Math.sqrt(5))*Math.cos(phi));
        return n/m;
    }

    /*
     * return u and v in an array: [[ux,uy], [vx,vy]]
     */
    function calc_uv(z0, z1, theta, phi, alpha, beta) {
        // the formula using complex numbers:
        // u = z0+exp(i*theta)*(z1-z0)*f(theta,phi)/alpha
        // v = z1-exp(-i*phi)*(z1-z0)*f(phi,theta)/beta

        var l = [z1[0]-z0[0], z1[1]-z0[1]];  // l = z1-z0
        var t = [Math.cos(theta), Math.sin(theta)];  // exp(i*theta)
        var p = [Math.cos(-phi), Math.sin(-phi)];    // exp(-i*phi)

        var u = c_sum(z0, c_prod(t,c_prod(l,[f(theta,phi)/alpha,0])));
        var v = c_sub(z1, c_prod(p,c_prod(l,[f(phi,theta)/beta,0])));

        return [u,v];
    }

    /* 
     * traverses the guide and computes the distance between adjacent points, and the 
     * turning angles of the polyline which joins them
     *
     * g: an array of points (which forms an asymptote guide)
     * output: none. but following properties of each point g[k] (treated as a complex number here) is added or updated:
     *  "d_ant": |g[k]-g[k-1]|
     *  "d_post": |g[k+1]-g[k]|
     *  "xi": turning angle at g[k], in rad: arg((g[k+1]-g[k])/(g[k]-g[k-1]))
     *
     * sample test cases:
     * 1. non-cyclic:
     *   var g=[[0,0],[100,0],[100,100]];
     *   _compute_distances_and_angles(g);
     * then:
     *   g[0]: [0, 0, d_ant: 0, d_post: 100, xi: 0]
     *   g[1]: [100, 0, d_post: 100, d_ant: 100, xi: 1.5707963267948966]
     *   g[2]: [100, 100, d_ant: 100, d_post: 0, xi: 0]
     *
     * 2. cyclic:
     *   var g=[[0,0],[100,0],[100,100]];
     *   g.cyclic = true;
     *   _compute_distances_and_angles(g);
     * then:
     *   g[0]: [0, 0, d_post: 100, d_ant: 141.4213562373095, xi: -0.7853981633974483]
     *   g[1]: [100, 0, d_post: 100, d_ant: 100, xi: 1.5707963267948966]
     *   g[2]: [100, 100, d_post: 141.4213562373095, d_ant: 100, xi: -0.7853981633974483]
     */
    function _compute_distances_and_angles(g) {

        var i, N = g.length; 
        
        if (N < 2) {
            return;
        }

        /*
         * input: _k : g[k-1] : read-only
         *         k : g[k]   : in and out. the d_post/d_ant/xi properties of this node will be updated
         *         k_: g[k+1] : read-only
         */
        function _for_each_node (_k, k, k_) {

            var l_ant = c_sub(k, _k);
            var l_post = c_sub(k_, k);
            var arg_ant = c_arg(l_ant);
            var arg_post = c_arg(l_post);

            k.d_post = c_mod(l_post);
            k.d_ant = c_mod(l_ant);

            // making sure that xi is between [-PI, PI]
            k.xi = arg_post - arg_ant;
            if(k.xi > Math.PI) {
                k.xi = k.xi - Math.PI*2;
            }
            if(k.xi < -Math.PI) {
                k.xi = k.xi + Math.PI*2;
            }
        }

        // first node
        if (!g.cyclic) {
            g[0].d_ant = 0;
            g[0].d_post = c_mod(c_sub(g[1], g[0]));
            g[0].xi = 0;
        } else {
            _for_each_node(g[N-1], g[0], g[1]); 
        }

        // middle nodes
        for (i = 1; i < g.length-1; i ++) {
            _for_each_node(g[i-1], g[i], g[i+1]);
        }

        // last node
        if (!g.cyclic) {
            g[N-1].d_ant = c_mod(c_sub(g[N-1], g[N-2]));
            g[N-1].d_post = 0;
            g[N-1].xi = 0;
        } else {
            _for_each_node(g[N-2], g[N-1], g[0]);
        }
    }

    /*
     * This function creates five vectors which are coefficients of a
     * linear system which allows finding the right values of "theta" at
     * each point of the path (being "theta" the angle of departure of the
     * path at each point). The theory is from METAFONT book."""
     */
    function _build_coefficients(g) {
        var i, n, N = g.length;
        var A=[], B=[], C=[], D=[], R=[];

        // 
        // check & update (when needed) properties of g and the nodes in g
        //
        function _check_guide(g) {

            // the properties of the guide
            if (!g.cyclic) {
                g.cyclic = false;
            } else {
                g.cyclic = true;
            }
            g.curl_begin = g.curl_begin || MP_DEFAULT_CURL_BEGIN;
            g.curl_end = g.curl_end || MP_DEFAULT_CURL_END;

            // the properties of each node
            g.forEach(function(x) {
                x.alpha = x.alpha || MP_DEFAULT_ALPHA;
                x.beta = x.beta || MP_DEFAULT_BETA;
            });
        }

        // input: _k : g[k-1]
        //         k : g[k]  
        //         k_: g[k+1]
        //        idx: the idx for node "k"
        // output: A/B/C/D/R is updated accordingly
        function _for_each_node (_k, k, k_, idx) {
            A.push(   _k.alpha  / (Math.pow(k.beta,2)  * k.d_ant));
            B.push((3-_k.alpha) / (Math.pow(k.beta,2)  * k.d_ant));
            C.push((3-k_.beta)  / (Math.pow(k.alpha,2) * k.d_post));
            D.push(   k_.beta   / (Math.pow(k.alpha,2) * k.d_post));
            R.push(-B[idx] * k.xi  - D[idx] * k_.xi);
        }

        //
        // prepare...
        //
        _compute_distances_and_angles(g);
        _check_guide(g);

        //
        // traverse the path now...
        //
        if (!g.cyclic) {
            // In this case, first equation doesn't follow the general rule
            A.push(0);
            B.push(0);
            var curl = g.curl_begin;
            var alpha_0 = g[0].alpha;
            var beta_1 = g[1].beta;
            var xi_0 = Math.pow(alpha_0,2) * curl / Math.pow(beta_1,2);
            var xi_1 = g[1].xi;
            C.push(xi_0*alpha_0 + 3 - beta_1);
            D.push((3 - alpha_0)*xi_0 + beta_1);
            R.push(-D[0]*xi_1);
        } else {
            _for_each_node(g[N-1], g[0], g[1], 0);
        }

        // Equations 1 to N-1 
        for (k = 1; k < N-1; k ++ ) {
            _for_each_node(g[k-1], g[k], g[k+1], k);
        }

        if (!g.cyclic) {
            // The last equation doesnt follow the general form
            n = R.length;     // index to generate
            C.push(0);
            D.push(0);
            var curl = g.curl_end;
            var beta_n = g[n].beta;
            var alpha_n_1 = g[n-1].alpha;
            var xi_n = Math.pow(beta_n,2) * curl / Math.pow(alpha_n_1,2);
            A.push((3-beta_n)*xi_n + alpha_n_1);
            B.push(beta_n*xi_n + 3 - alpha_n_1);
            R.push(0);
        } else {
            _for_each_node(g[N-2], g[N-1], g[0], N-1);
        }

        return [A, B, C, D, R];
    }

    // This function receives the five vectors created by
    // _build_coefficients() and uses them to build a linear system with N
    // unknonws (being N the number of points in the path). Solving the system
    // finds the value for theta (departure angle) at each point
    function _solve_for_thetas(A, B, C, D, R) {
        var k, prev, post, L = R.length;

        // create the empty matrix
        var a = new Array(L), b = R;
        for(k = 0; k < L; k ++) {
            a[k] = new Array(L);
        }

        for(k = 0; k < L; k ++) {
            prev = (k-1+L)%L;  // "+L" is to make (prev>=0)
            post = (k+1)%L;
            a[k][prev] = A[k];
            a[k][k]    = B[k]+C[k];
            a[k][post] = D[k];
        }

        return solve_matrix(a, b, L, L);
    }

    // This function receives a path in which each point is "open", i.e. it
    // does not specify any direction of departure or arrival at each node,
    // and finds these directions in such a way which minimizes "mock
    // curvature". The theory is from "The METAFONT book".
    // 
    // Basically it solves
    // a linear system which finds all departure angles (theta), and from
    // these and the turning angles at each point, the arrival angles (phi)
    // can be obtained, since theta + phi + xi = 0  at each node/knot
    function solve_angles(g) {
        var k, L = g.length;

        if (L < 2) {
            console.log("Error: a path has less than 2 nodes...");
            return;
        }

        var ABCDR = _build_coefficients(g);
        var x = _solve_for_thetas(ABCDR[0], ABCDR[1], ABCDR[2], ABCDR[3], ABCDR[4]);
        for (k = 0; k < L; k ++) {
            g[k].theta = x[k];
            g[k].phi = -g[k].theta - g[k].xi;
        }
    }


    // This function receives a path in which, for each point, the values
    // of theta and phi (leave and enter directions) are known, either because
    // they were previously stored in the structure, or because it was
    // computed by function solve_angles(). 
    //
    // From this path description this function computes the control points 
    // for each knot and stores it in the path.
    function find_control_points(g) {
        var k, uv, N = g.length;

        if (N < 2) { // no, I cannt do it...
            return;
        }

        // return control points [u,v] for one segment betw z0..z1
        function _for_each_segment(z0, z1) {
            var theta = z0.theta;
            var phi = z1.phi;
            var alpha = z0.alpha;
            var beta = z1.beta;

            return calc_uv(z0, z1, theta, phi, alpha, beta);
        }

        // N nodes mean N-1 segments (if non-cyclic) and N segments (if cyclic).
        for (k = 0; k < N-1; k ++) {
            uv = _for_each_segment(g[k], g[k+1]);
            g[k].u = uv[0]; // u
            g[k+1].v = uv[1]; // v
        }

        if (g.cyclic) {
            uv = _for_each_segment(g[N-1], g[0]);
            g[N-1].u = uv[0];
            g[0].v = uv[1];
        }
    }

    return { solve_angles: solve_angles, find_control_points: find_control_points};
}());
