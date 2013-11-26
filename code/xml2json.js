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
 * @param {String} txt: the xml text
 * @return {Object} a XML dom document object
 *
 * ref: http://www.w3schools.com/dom/dom_parser.asp
 *      http://www.w3schools.com/dom/dom_document.asp
 */
function xml2dom(txt){
    var MIME = "text/xml";
    var dom = undefined;

    if(!txt){
        return undefined;
    }

    if(window.DOMParser){
        dom = (new DOMParser()).parseFromString(txt, MIME); 
    }
    else if(window.ActiveXObject){
        dom = new ActiveXObject('Microsoft.XMLDOM');
        dom.async = false;
        if (!dom.loadXML(txt)){
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


function dom2json(dom, tab) {

    /* nodeType: http://www.w3schools.com/dom/dom_nodetype.asp */

    var ELEMENT_NODE                = 1;
    var ATTRIBUTE_NODE              = 2;
    var TEXT_NODE                   = 3;
    var CDATA_SECTION_NODE          = 4;
    var ENTITY_REFERENCE_NODE       = 5;
    var ENTITY_NODE                 = 6;
    var PROCESSING_INSTRUCTION_NODE = 7;
    var COMMENT_NODE                = 8;
    var DOCUMENT_NODE               = 9;
    var DOCUMENT_TYPE_NODE          = 10;
    var DOCUMENT_FRAGMENT_NODE      = 11;
    var NOTATION_NODE               = 12;

    var X = {
        /**
         * recursively remove all pure white TEXT_NODE from the element, in place;
         * and return the original element
         */
        remove_white: function(e) {
            var node, next;

            e.normalize();

            for (node = e.firstChild; node; ) {
                if (node.nodeType == TEXT_NODE) {
                    if (!node.nodeValue.match(/[^ \f\n\r\t\v]/)) {
                        next = node.nextSibling;
                        e.removeChild(node);
                        node = next;
                    }
                    else
                        node = node.nextSibling;
                }
                else if (node.nodeType == ELEMENT_NODE) {
                    remove_white(node);
                    node = node.nextSibling;
                }
                else{
                    node = node.nextSibling;
                }
            }
            return e;
        },

        toObj: function(dom) {
            var o = {};
            if (dom.nodeType==1) {   // element node ..
                if (dom.attributes.length)   // element with attributes  ..
                    for (var i=0; i<dom.attributes.length; i++)
                        o["@"+dom.attributes[i].nodeName] = (dom.attributes[i].nodeValue||"").toString();
                if (dom.firstChild) { // element has child nodes ..
                    var textChild=0, cdataChild=0, hasElementChild=false;
                    for (var n=dom.firstChild; n; n=n.nextSibling) {
                        if (n.nodeType==1) hasElementChild = true;
                        else if (n.nodeType==3 && n.nodeValue.match(/[^ \f\n\r\t\v]/)) textChild++; // non-whitespace text
                        else if (n.nodeType==4) cdataChild++; // cdata section node
                    }
                    if (hasElementChild) {
                        if (textChild < 2 && cdataChild < 2) { // structured element with evtl. a single text or/and cdata node ..
                            X.remove_white(dom);
                            for (var n=dom.firstChild; n; n=n.nextSibling) {
                                if (n.nodeType == 3)  // text node
                                    o["#text"] = X.escape(n.nodeValue);
                                else if (n.nodeType == 4)  // cdata node
                                    o["#cdata"] = X.escape(n.nodeValue);
                                else if (o[n.nodeName]) {  // multiple occurence of element ..
                                    if (o[n.nodeName] instanceof Array)
                                        o[n.nodeName][o[n.nodeName].length] = X.toObj(n);
                                    else
                                        o[n.nodeName] = [o[n.nodeName], X.toObj(n)];
                                }
                                else  // first occurence of element..
                                    o[n.nodeName] = X.toObj(n);
                            }
                        }
                        else { // mixed content
                            if (!dom.attributes.length)
                                o = X.escape(X.innerXml(dom));
                            else
                                o["#text"] = X.escape(X.innerXml(dom));
                        }
                    }
                    else if (textChild) { // pure text
                        if (!dom.attributes.length)
                            o = X.escape(X.innerXml(dom));
                        else
                            o["#text"] = X.escape(X.innerXml(dom));
                    }
                    else if (cdataChild) { // cdata
                        if (cdataChild > 1)
                            o = X.escape(X.innerXml(dom));
                        else
                            for (var n=dom.firstChild; n; n=n.nextSibling)
                                o["#cdata"] = X.escape(n.nodeValue);
                    }
                }
                if (!dom.attributes.length && !dom.firstChild) o = null;
            }
            else if (dom.nodeType==9) { // document.node
                o = X.toObj(dom.documentElement);
            }
            else
                alert("unhandled node type: " + dom.nodeType);
            return o;
        },
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
        escape: function(txt) {
            return txt.replace(/[\\]/g, "\\\\")
                .replace(/[\"]/g, '\\"')
                .replace(/[\n]/g, '\\n')
                .replace(/[\r]/g, '\\r');
        }
    };
    if (dom.nodeType == 9) // document node
        dom = dom.documentElement;
    var json = X.toJson(X.toObj(X.remove_white(dom)), dom.nodeName, "\t");
    return "{\n" + tab + (tab ? json.replace(/\t/g, tab) : json.replace(/\t|\n/g, "")) + "\n}";
}
