/*########################################################################## 
  # json2tree
  #
  # created(bruin, 2003-02-01): first creation, support MSIE only
  # updated(bruin, 2004-07-08): support mozilla, cleanup code, add comments
  # updated(bruin, 2013-11-30): use CSS sprites 
  # updated(bruin, 2013-12-06): cosmetic changes 
  # updated(bruin, 2014-11-06): adjust data structure to explicitly add "icon" property
  #########################################################################*/

/***************************************************************************
 * General notes:
 *
 * This "module" converts a json object into a tree data structure which can be
 * rendered into HTML elements in a browser.
 *
 * 1. data format
 *
 * The following is an example to demostrate the supported JSON format:
 *
 * "root": {
 *   "@icon": "folder", 
 *   "@name": "real root name",
 *   "@desc": "desc1", 
 *   "@href": "http://www.baidu.com", 
 *   "leaf1": {
 *     "@icon": "file", 
 *     "@desc": "desc2", 
 *     "@href": "http://www.sogou.com",
 *     "@other": "a not reserved property"
 *    },
 *   "leaf2": "",
 *   "leaf3": {},
 *   "branch1": ["123", 123, true]
 *  }
 * 
 * In short, it support any JSON data format, with the exception that the following property names
 * are treated specially (they are all optional):
 *  - "@icon": its value indicates the class name of the icon for the node; class names are 
 *    predefined in "tree.css", if no match found, the 1st icon in the css spirits will be used;
 *  - "@name": the name of the node; if presents, it override the property name of the "parent".
 *  - "@desc": description of the object
 *  - "@href": hyper link of the object
 *
 * As the data is to be converted into a tree, it's necessary to distinguish leaf-nodes from 
 *  non-leaf-nodes. Basically, if a "property" is a leaf node, it means that the property value is
 * a) eiter an empty object or a primitive value, or
 * b) an object which only contains properties whose name are reserved (see below);
 * 
 * If the property value is an array, it's treated as an array of objects which share the same
 * property name. For example:
 *   {"branch": ["item1", "item2"]} is treated as {"branch": "item1"} followed by {"branch", "item2"} \
 *   as a sibling.
 *
 * 2. HTML elements ID naming convention
 *
 * Each tree node has an unique generated id, on which the HTML elments' ids depend:
 *
 * "N" + id: the node object (eg, N128 is the node object id whose id is "128"
 * "D" + id: the DIV object of the node (yes, each node has a corresponding DIV)
 * "J" + id: the node's joint icon image object in html document. 
 *
 * 3. tree icons (joint icons)
 *
 * The joint icon is to represent the status of the node in browser. there are 6 possible status for a node: 
 *
 *    |          |         |         |         |        |
 *  +---+      +---+       |       +---+     +---+      |
 *  | + |--    | - |--     +----   | + |--   | - |--    +----
 *  +---+      +---+       |       +---+     +---+
 *    |          |         |         
 * 
 *   (a)        (b)       (c)       (d)       (e)      (f)
 *
 * (a) a closed node having kid(s)  
 * (b) an opened/collapsed node having kid(s)
 * (c) a leaf node having no kids
 * (d) a last closed node having kid(s)
 * (e) a last opened/collapsed node having kid(s)
 * (f) a last leaf node having no kids
 *
 * Clicking on a non-leaf node cause it open/close, its joint icon should also 
 * change accordingly: a <=> b; d <=> e; 
 * No change of the joint icon for leaf nodes (c & f), actually no click event hooks;
 *
 * 4. typical usage
 *
 * var json =  JSON.parse(JSON.stringify(obj));  // make sure the object is JSON compatible
 * var root = json2tree(json);  // convert the object into a tree
 * document.getElementByID("elem_id").innerHTML = root.render(); //  render the tree into HTML elementssss
 * root.onclick();  // clapse the 1st level
 *
 ***************************************************************************/



/*########################################################################## 
  # some utilities 
  #########################################################################*/

// save typing 
function $(id) {
    return window.document.getElementById(id);
}

// is the object empty, i.e.: {} 
function isEmptyObj(o) {
    // return JSON.stringify(o) === "{}";
    return (o != null && 
            o != undefined && 
            typeof o === 'object' && 
            Object.getOwnPropertyNames(o).length === 0);
}

// is v a number/string/boolean primitive?
function isNsb(v) {
    return (typeof v === "number" || 
            typeof v === "string" ||
            typeof v === "boolean");
}

// is o an array? 
function isArray(o) {
    if(typeof Array.isArray === 'function'){
        return Array.isArray(o);
    }else{
        return typeof o === 'object' && Object.prototype.toString.call(o) === "[object Array]";
    }
}

// get unique id, also has a method for reset: uid(), uid.reset()
var uid = (function(init) {
    var _id = init;
    var fn = function() { return _id ++; };
    fn.reset = function() { _id = init; };
    return fn;
}(2014));


// get a xml-escaped string
var escapeXml = function (txt) {
    return (txt.replace(/>/g, "&gt;")
            .replace(/</g, "&lt;")
            .replace(/"/g, "&quot;"));
};

/*########################################################################## 
  # node/tree stuff
  #########################################################################*/


function isPropReserved(p) {

    var reserved_prop_names = ["@icon", "@name", "@desc", "@href"];
    /*
    // assume there is no match, and we set the initial value as 1
    // if there is any match, then multiply by 0, then the reduced result will be 0;
    // if there is no match, the reduced result will be 1;
    return reserved_prop_names.reduce(function(acc, x){ return (acc * ((p === x)? 0 : 1));}, 1) === 0? true : false;
    */
    return reserved_prop_names.some(function(x){ return x === p; });
}

/** 
 * Create a MyNode object.
 *
 * @constructor
 * @param {string) id An unique id of the node object to be created. 
 * @param {string} icon The name of the icon for the node
 * @param {string} name The name of the node
 * @param {string} desc The text description of the node
 * @param {string} href Hyper link of the node
 */
function MyNode(id, icon, name, desc, href) {

    /*
     * data structure for a node
     */

    // internals (i.e., stuff not to be displayed)
    this.dad = null;
    this.kids = [];
    this.id = id;    // unique id dynamically generated

    // stuff to be displayed: 
    this.icon = icon || "cube1";
    this.name = name || "";
    this.desc = desc? ": " + desc : "";
    this.href = href;

    /* 
     * properties determined by root.set_left_n_last(true, []); 
     * if there is any node update (remove/add), these properties need
     * to be updated by root.set_left_n_last(true, []) again.
     */
    this.left_code = [];   // array element: 0 means space, 1 means vertical bar
    this.lastp = false;    // is the last kid of its parent?
    
    // dynamic properties changed upon click event
    this.openp = false;  // is collapsed or not? 


    /*
     * private methods
     */

    /* get node od */ 
    function _node_id() {
        return "N" + this.id;
    }

    /* get the id of the corresponding DIV */
    function _div_id() {
        return "D" + this.id;
    }

    /* get the id of the corresponding DIV for joint icon */
    function _joint_id() {
        return "J" + this.id;
    }

    function _add_kid(kid) {
        this.kids[this.kids.length] = kid;
        kid.dad = this;
        return kid;
    }

    function _add_kids(kids) { // "kids" is an array of kids
        var that = this;
        kids.forEach(function(x){
            that.kids[that.kids.length] = x;
            x.dad = that;
        });
    }

    /**
     * Recursively set "left_code" and "lastp" properties
     * of each node in the tree. called by the root of the tree
     * after the tree structure been built
     *
     * @param {boolean} lastp Be "false" if it's not the last child of its parent; otherwise "true";
     * @param {array} left_code An array of 0/1 representing the left side icons
     * @return: nothing
     */
    function _set_left_n_last(lastp, left_code) {
        var i;
        
        this.lastp = lastp;
        this.left_code = left_code.slice(0); // copy the array
        
        if (lastp) {
            left_code.push(0);   
        } else {
            left_code.push(1);   
        }
        
        for (i = 0; i < this.kids.length; i ++) {
            if (i == this.kids.length - 1) {
                this.kids[i].set_left_n_last(true, left_code.slice(0));
            } else {
                this.kids[i].set_left_n_last(false, left_code.slice(0));
            }
        }
    }

    /**
     * Generate html elements of the node. for each node, its corresponding html elements 
     * could be divided into 2 parts: a one row TABLE, followed by a DIV:
     *
     * Node in html => TABLE + DIV
     *
     * The TABLE contains the following variable number of TDs (columns):
     * 1. left side icons: a series of blank and/or vertline icons each is a TD; none for root nodes;
     * 2. joint icon: one of 6 icons as described above. one TD for each node;
     * 3. type icon: icon representing the type of the node. one TD for each node;
     * 4. name+desc text: plain text or anchored text. one TD for each node;
     *
     * The DIV element is the container of child nodes' html elements, which in turn contains a 
     * list of TABLE+DIV bundle, one for each child node. DIVs can be controlled to show or hide. 
     * Showing a node's DIV opens/collapses the node, while hiding the node's DIV closes the node.
     */
    function _render() { 

        var docW = "<table><tr>";

        // 1. left side icons
        docW += this.get_left_icons();

        // 2. joint icon 
        docW += this.get_joint_icon();

        // 3. type icon
        docW += this.get_type_icon();

        // 4. desc text, xml-escaped 
        if (href) {
            docW += "<td>&nbsp;<code><a href='" + href + "'>" + escapeXml(this.name + this.desc) + "</a></code></td></tr></table>";            
        } else {
            docW += "<td>&nbsp;<code>" + escapeXml(this.name + this.desc) + "</code></td></tr></table>";
        }

        // 5. div object: only needed for non-leaf nodes
        if (this.kids.length > 0) {
            docW += "<div class='none' id='D" + this.id + "'></div>";
        }
        
        return docW;
    } 

    /*
     * open & close the node. for non-leaf nodes, when clicked:
     * - render kids when collapsed for the 1st time
     * - show/hide the associated div, by changing its class
     * - toggle the joint icon
     */
    function _onclick() {
        var div = $(this.div_id());

        if (!div){
            return;
        }

        if(this.kids.length === 0){
            return;
        }

        if (!div.innerHTML) {
            var kids = [];

            for (var i = 0; i < this.kids.length; i ++) {
                kids[i] = this.kids[i].render();
            }

            div.innerHTML = kids.join('');
        }

        // toggle visibility of its kids
        if (this.openp === false) {
            div.className = "block";
            this.openp = true;
        } else {
            div.className = "none";
            this.openp = false;
        }
        
        // update the joint icon in the joint DIV
        var jdiv = $(this.joint_id());
        if (jdiv) {
            jdiv.className = "icon " + this.get_joint_icon_class(); 
        }
    }

    // <td>s for left side icons, one <td> for each
    function _get_left_icons() {
        var left_code = this.left_code.slice(1);

        return (left_code.map(function(v){ 
            return [
                "<td><div class='icon ", 
                (v == 1? "vertical" : "blank"), 
                "'/></td>"
            ].join("");}).join(""));
    }

    // get joint icon class name
    function _get_joint_icon_class() {

        //console.log("joint icon:" + this.name + ", last=" + this.lastp + ", kids.length=" + this.kids.length);

        if(this.dad === null){
            return "";  // no joint icon for root node
        } else {
            if (this.lastp) {
                if (this.kids.length > 0) {
                    if (this.openp){
                        return "nodeminuslast";
                    } else {
                        return "nodepluslast";
                    }
                } else {
                    return "nodelast";
                }
            } else { 
                // not the last node 
                if (this.kids.length > 0) {
                    if (this.openp) {
                        return "nodeminus";
                    } else {
                        return "nodeplus";
                    }
                }
                else{
                    return "node";
                }
            }
        }
    }

    // get <td> for joint icom
    function _get_joint_icon() {
        
        if (this.dad === null) {
            return "";  // no joint icon for root node
        }

        return ["<td><div onclick='N", 
                this.id, 
                ".onclick()' id='",
                this.joint_id(), 
                "' class='icon ", 
                this.get_joint_icon_class(), 
                "'/></td>"
               ].join("");
    }

    // get <td> for type icon
    function _get_type_icon() {
        return ["<td><div class='icon ", this.icon, "'/></td>"].join("");
    }

    
    /*
     * public methods
     */
    this.add_kid         = _add_kid;
    this.add_kids        = _add_kids;
    this.set_left_n_last = _set_left_n_last;
    this.node_id      = _node_id;
    this.div_id          = _div_id;
    this.joint_id        = _joint_id;
    this.get_joint_icon_class = _get_joint_icon_class;

    this.get_left_icons  = _get_left_icons;  
    this.get_joint_icon   = _get_joint_icon;   
    this.get_type_icon   = _get_type_icon;   

    this.render          = _render;          
    this.onclick         = _onclick;
}


/**
 * build a tree from the object: 
 * - creating(new) all nodes in global space
 * - attaching nodes to form a tree
 * - initialize misc info in all nodes
 *
 * @parm {object or string} o: object value
 * @param {string} name: object name. optional
 * @return: the root of the tree represented by "o"
 * 
 * updated(bruin, 2013-12-20): remove the nested function. abstract with an optional parameter "name".
 * todo: make it a tail-call?
 *
 */

function json2tree(o, /* optional */ name) {
    /*
     * the real function
     */
    function _json2tree(o, /* optional */ name) {

        //console.log("_json2tree():" + name + ":" + JSON.stringify(o));

        var p, node;

        // default values for the current node
        var icon = null;
        var desc = null; 
        var href = null;

        function _isLeafNode(o) {
            if (isEmptyObj(o) || isNsb(o)) {
                return true;
            }

            if (isArray(o)) {
                return false;
            }

            // it's an object...check names of its properties, that:
            // if any of the property is not reserved, then it's not a leaf node
            for (p in o) {
                if (!isPropReserved(p)) {
                    return false;
                }
            }

            return true;
        }

        function _getAttrib(o, attr) {
            if (typeof o === "object") {
                for (p in o) {
                    if (p === '@' + attr) {
                        return o[p];
                    }
                }
            }

            return null;
        }

        if (!name) {
            /* 
             * it's assumed that this is the first call which just passing in the object.
             * all the rest recursive calls will always supply the "name" parameter.
             *
             * we assume that the top object contains a tree (not a forest) thus it has 
             * only 1 property. So take the first property as the root of the tree that
             * the property name is "name", the property value is "o".
             */
            if (o && typeof o === 'object') {
                for (p in o) {
                    return _json2tree(o[p], p);
                }
            } else {
                return null;
            }
        }

        /*
         * special treatment for array: return an array of nodes
         */
        if (isArray(o)) {
            var kids = [];
            o.forEach(function (x) {
                kids.push(_json2tree(x, name));
            });
            return kids;
        }

        if (isNsb(o)) {
            // if the object is a simple value...put the object content as the description
            node = new MyNode(uid(), null, name, o, null);
        } else {
            node = new MyNode(uid(), 
                              _getAttrib(o, "icon"), 
                              _getAttrib(o, "name") || name, // name overriding
                              _getAttrib(o, "desc"),
                              _getAttrib(o, "href"));
        }
        window[node.node_id()] = node;
        
        if (!_isLeafNode(o)) {
            for (p in o) {
                if (!isPropReserved(p)) { // only add those which are not reserved
                    var kids = _json2tree(o[p], p);
                    if (isArray(kids)){
                        node.add_kids(kids);
                    } else {
                        node.add_kid(kids);
                    }
                }
            }
        }

        return node;
    }

    /* 
     * just a wrapper of the private function
     */
    var root = _json2tree(o, name);
    root.set_left_n_last(true, []);  // need call this once the tree is built
    return root;
}
