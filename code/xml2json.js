/* xml2json converter:
 * 
 * rewrite(bruin, 2013-11-26)
 * based on http://www.xml.com/pub/a/2006/05/31/converting-between-xml-and-json.html 
 *
 */

var xml2json = (function(){

    /* 
     * property name for texts which has sibling attributes or tags:
     *
     * 1. <e blah="value">whatever</e>   => "e": {"@blah": "value", "#text": "whatever"}
     * 2. <e>foo<a>bar</a></e>           => "e": {"#text": "foo", "a": "bar"}
     */
    var SHARP_TEXT = "#text"; 


    /*
     * property name for CDATA
     */
    var SHARP_CDATA = "#cdata";


    /**
     * escape \, ", \n, \r
     * 
     * @parm {} txt: 
     */
    function _escape(txt) {
        return txt.replace(/[\\]/g, "\\\\")
            .replace(/[\"]/g, '\\"')
            .replace(/[\n]/g, '\\n')
            .replace(/[\r]/g, '\\r');
    }



    /**
     * recursively remove all pure white TEXT_NODE from the element, in place;
     * 
     * @param {Node} e: a xml dom node
     * @return {Node} the white-removed (if any) node
     */
    function _remove_white(e) {
        var node, next;

        e.normalize();

        for (node = e.firstChild; node; ) {
            if (node.nodeType == Node.TEXT_NODE) {
                if (!node.nodeValue.match(/[^ \f\n\r\t\v]/)) {
                    next = node.nextSibling;
                    e.removeChild(node);
                    node = next;
                }
                else
                    node = node.nextSibling;
            }
            else if (node.nodeType == Node.ELEMENT_NODE) {
                _remove_white(node);
                node = node.nextSibling;
            }
            else{
                node = node.nextSibling;
            }
        }
        return e;
    }

    /**
     * convert a xml text string into a dom object
     *
     * @param {String} xml: the xml text
     * @return {Object} a XML dom document object
     *
     * ref: http://www.w3schools.com/dom/dom_parser.asp
     *      http://www.w3schools.com/dom/dom_document.asp
     */
    function _xml2dom(xml){
        var MIME = "text/xml";
        var dom = undefined;

        if(!xml){
            return undefined;
        }

        if(window.DOMParser){
            dom = (new DOMParser()).parseFromString(xml, MIME); 
        }
        else if(window.ActiveXObject){
            dom = new ActiveXObject('Microsoft.XMLDOM');
            dom.async = false;
            if (!dom.loadXML(xml)){
                window.alert(dom.parseError.reason + dom.parseError.srcText);
                dom = undefined;
            }
        }
        else{
            window.alert("Error: your browser does not support parsing XML to DOM!");
        }

        return dom;
    }


    function _as_xml(n) {
        var i, c;
        var s = "";
        if (n.nodeType == Node.ELEMENT_NODE) {
            s += "<" + n.nodeName;
            for (i=0; i<n.attributes.length;i++){
                s += " " + n.attributes[i].nodeName + "=\"" + (n.attributes[i].nodeValue||"").toString() + "\"";
            }
            if (n.firstChild) {
                s += ">";
                for (c = n.firstChild; c; c = c.nextSibling){
                    s += _as_xml(c);
                }
                s += "</" + n.nodeName + ">";
            }
            else{
                s += "/>";
            }
        }
        else if (n.nodeType == Node.TEXT_NODE){
            s += n.nodeValue;
        }
        else if (n.nodeType == Node.CDATA_SECTION_NODE){
            s += "<![CDATA[" + n.nodeValue + "]]>";
        }
        return s;
    }

    /**
     * fixme
     *
     */
    function _inner_xml(node) {

        if ("innerHTML" in node)
            return node.innerHTML;

        var s = "";
        for (var c = node.firstChild; c; c = c.nextSibling){
            s += _as_xml(c);
        }
        return s;
    }

    /**
     * fixme
     *
     * @param {Object} dom: the xml dom object, whites-removed
     * @return {fixme}: fixme
     */
    function _dom2obj(dom) {
        var o = {};
        var i, n;

        if(dom.nodeType == Node.DOCUMENT_NODE) {
            o = _dom2obj(dom.documentElement); // dom.documentElement is the root element
        }

        else if(dom.nodeType == Node.ELEMENT_NODE) {

            if(!dom.attributes.length && !dom.firstChild){
                return undefined;
            }

            // converts attributes[] into properties
            if(dom.attributes.length){  
                for (i=0; i<dom.attributes.length; i++){
                    o["@"+dom.attributes[i].nodeName] = (dom.attributes[i].nodeValue||"").toString();
                }
            }

            if(dom.firstChild) { // element has child nodes ..

                var textChild = 0;
                var cdataChild = 0;
                var hasElementChild = false;

                for (n=dom.firstChild; n; n=n.nextSibling) {
                    if (n.nodeType == Node.ELEMENT_NODE){ 
                        hasElementChild = true;
                    }
                    else if (n.nodeType == Node.TEXT_NODE && n.nodeValue.match(/[^ \f\n\r\t\v]/)){
                        textChild++; // non-whitespace text
                    }
                    else if (n.nodeType== Node.CDATA_SECTION_NODE){
                        cdataChild++; // cdata section node
                    }
                }

                if (hasElementChild) {
                    if (textChild < 2 && cdataChild < 2) { // structured element with a single text or/and cdata node
                        _remove_white(dom); // fixme: why remove white again?

                        for(n = dom.firstChild; n; n = n.nextSibling) {
                            if (n.nodeType == Node.TEXT_NODE){ 
                                o[SHARP_TEXT] = _escape(n.nodeValue);
                            }
                            else if (n.nodeType == Node.CDATA_SECTION_NODE) {
                                o[SHARP_CDATA] = _escape(n.nodeValue);
                            }
                            else if (o[n.nodeName]) {  // multiple occurence of element ..
                                if (o[n.nodeName] instanceof Array){
                                    o[n.nodeName][o[n.nodeName].length] = _dom2obj(n);
                                }
                                else{
                                    o[n.nodeName] = [o[n.nodeName], _dom2obj(n)];
                                }
                            }
                            else{  // first occurence of element..
                                o[n.nodeName] = _dom2obj(n);
                            }
                        }
                    }
                    else { // mixed content
                        if (!dom.attributes.length)
                            o = _escape(_inner_xml(dom));
                        else
                            o[SHARP_TEXT] = _escape(_inner_xml(dom));
                    }
                } /* hasElementChild */
                else if (textChild) { // pure text
                    if (!dom.attributes.length)
                        o = _escape(_inner_xml(dom));
                    else
                        o[SHARP_TEXT] = _escape(_inner_xml(dom));
                }
                else if (cdataChild) { // cdata
                    if (cdataChild > 1)
                        o = _escape(_inner_xml(dom));
                    else{
                        for(n = dom.firstChild; n; n = n.nextSibling)
                            o[SHARP_CDATA] = _escape(n.nodeValue);
                    }
                }
            }
        }
        else{
            alert("unhandled node type: " + dom.nodeType);
        }
        return o;
    }


    /**
     *
     */
    function _obj2json(o, name, ind) {
        var json = name ? ("\""+name+"\"") : "";
        if (o instanceof Array) {
            for (var i=0,n=o.length; i<n; i++)
                o[i] = _obj2json(o[i], "", ind+"\t");
            json += (name?":[":"[") + (o.length > 1 ? ("\n"+ind+"\t"+o.join(",\n"+ind+"\t")+"\n"+ind) : o.join("")) + "]";
        }
        else if (o == null){
            json += (name&&":") + "null";
        }
        else if (typeof(o) == "object") {
            var arr = [];
            for (var m in o)
                arr[arr.length] = _obj2json(o[m], m, ind+"\t");
            json += (name?":{":"{") + (arr.length > 1 ? ("\n"+ind+"\t"+arr.join(",\n"+ind+"\t")+"\n"+ind) : arr.join("")) + "}";
        }
        else if (typeof(o) == "string"){
            json += (name&&":") + "\"" + o.toString() + "\"";
        }
        else{
            json += (name&&":") + o.toString();
        }

        return json;
    }


    /** 
     * convert xml to json, in the following steps:
     * . xml -> dom
     * . dom -> obj
     * . obj -> json
     *
     * @parm {string} xml: the xml text
     * @parm {string} tab, optional: the text for tabbing the jason items
     * @return: the json object
     */
    return function(xml, tab){

        if(!xml)
            return undefined;

        if(!tab)
            tab = "\t";

        /* xml -> dom */
        var dom = _xml2dom(xml);
        if (dom.nodeType == Node.DOCUMENT_NODE)
            dom = dom.documentElement;
        _remove_white(dom);

        
        /* dom -> obj */
        var obj = _dom2obj(dom);

        var obj2 ={};
        obj2[dom.nodeName] = obj;

        /* obj -> json */

        //var json = _obj2json(obj, dom.nodeName, tab);
        var json = JSON.stringify(obj);
        //        return "{\n" + tab + (tab ? json.replace(/\t/g, tab) : json.replace(/\t|\n/g, "")) + "\n}";
        return "{\n" + tab + json + "\n}";
    }

}());


/* tests */
console.log(xml2json("<e>text<a>anchor</a>text2</e>"));

