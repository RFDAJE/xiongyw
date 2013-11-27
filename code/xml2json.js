/* xml2json converter:
 * 
 * rewrite(bruin, 2013-11-26)
 * based on http://www.xml.com/pub/a/2006/05/31/converting-between-xml-and-json.html 
 *
 * two steps: text/xml -> xml dom -> json
 */


/**
 * convert a xml text string into a dom object
 *
 * @param {String} xml: the xml text
 * @return {Object} a XML dom document object
 *
 * ref: http://www.w3schools.com/dom/dom_parser.asp
 *      http://www.w3schools.com/dom/dom_document.asp
 */
function xml2dom(xml){
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


/**
 * convert a dom object into json
 *
 * @param {Object} dom: the xml dom document
 * @param {String} tab: tab char replacement
 * @return {Object} the json object
 *
 */
var dom2json = (function(){

    /**
     * fixme
     * @parm {} txt: 
     */
    function _escape(txt) {
        return txt.replace(/[\\]/g, "\\\\")
            .replace(/[\"]/g, '\\"')
            .replace(/[\n]/g, '\\n')
            .replace(/[\r]/g, '\\r');
    }

    /* DOM nodeType: http://www.w3schools.com/dom/dom_nodetype.asp 

       Node.ELEMENT_NODE                = 1;
       Node.ATTRIBUTE_NODE              = 2;
       Node.TEXT_NODE                   = 3;
       Node.CDATA_SECTION_NODE          = 4;
       Node.ENTITY_REFERENCE_NODE       = 5;
       Node.ENTITY_NODE                 = 6;
       Node.PROCESSING_INSTRUCTION_NODE = 7;
       Node.COMMENT_NODE                = 8;
       Node.DOCUMENT_NODE               = 9;
       Node.DOCUMENT_TYPE_NODE          = 10;
       Node.DOCUMENT_FRAGMENT_NODE      = 11;
       Node.NOTATION_NODE               = 12;

    */

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
                remove_white(node);
                node = node.nextSibling;
            }
            else{
                node = node.nextSibling;
            }
        }
        return e;
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
                                o["#text"] = _escape(n.nodeValue);
                            }
                            else if (n.nodeType == Node.CDATA_SECTION_NODE) {
                                o["#cdata"] = _escape(n.nodeValue);
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
                            o = X._escape(X.innerXml(dom));
                        else
                            o["#text"] = X._escape(X.innerXml(dom));
                    }
                }
                else if (textChild) { // pure text
                    if (!dom.attributes.length)
                        o = X._escape(X.innerXml(dom));
                    else
                        o["#text"] = X._escape(X.innerXml(dom));
                }
                else if (cdataChild) { // cdata
                    if (cdataChild > 1)
                        o = X._escape(X.innerXml(dom));
                    else
                        for (n=dom.firstChild; n; n=n.nextSibling)
                            o["#cdata"] = X._escape(n.nodeValue);
                }
            }


        }
        else{
            alert("unhandled node type: " + dom.nodeType);
        }

        return o;
    }




    toJson: function(o, name, ind) {
        var json = name ? ("\""+name+"\"") : "";
        if (o instanceof Array) {
            for (var i=0,n=o.length; i<n; i++)
                o[i] = X.toJson(o[i], "", ind+"\t");
            json += (name?":[":"[") + (o.length > 1 ? ("\n"+ind+"\t"+o.join(",\n"+ind+"\t")+"\n"+ind) : o.join("")) + "]";
        }
        else if (o == null)
            json += (name&&":") + "null";
        else if (typeof(o) == "object") {
            var arr = [];
            for (var m in o)
                arr[arr.length] = X.toJson(o[m], m, ind+"\t");
            json += (name?":{":"{") + (arr.length > 1 ? ("\n"+ind+"\t"+arr.join(",\n"+ind+"\t")+"\n"+ind) : arr.join("")) + "}";
        }
        else if (typeof(o) == "string")
            json += (name&&":") + "\"" + o.toString() + "\"";
        else
            json += (name&&":") + o.toString();
        return json;
    },
    innerXml: function(node) {
        var s = ""
        if ("innerHTML" in node)
            s = node.innerHTML;
        else {
            var asXml = function(n) {
                var s = "";
                if (n.nodeType == 1) {
                    s += "<" + n.nodeName;
                    for (var i=0; i<n.attributes.length;i++)
                        s += " " + n.attributes[i].nodeName + "=\"" + (n.attributes[i].nodeValue||"").toString() + "\"";
                    if (n.firstChild) {
                        s += ">";
                        for (var c=n.firstChild; c; c=c.nextSibling)
                            s += asXml(c);
                        s += "</"+n.nodeName+">";
                    }
                    else
                        s += "/>";
                }
                else if (n.nodeType == 3)
                    s += n.nodeValue;
                else if (n.nodeType == 4)
                    s += "<![CDATA[" + n.nodeValue + "]]>";
                return s;
            };
            for (var c=node.firstChild; c; c=c.nextSibling)
                s += asXml(c);
        }
        return s;
    },
};
                if (dom.nodeType == 9) // document node
                    dom = dom.documentElement;
                var json = X.toJson(X.toObj(X.remove_white(dom)), dom.nodeName, "\t");
                return "{\n" + tab + (tab ? json.replace(/\t/g, tab) : json.replace(/\t|\n/g, "")) + "\n}";
               }
