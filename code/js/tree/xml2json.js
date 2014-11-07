/*########################################################################## 
  # xml2obj and xml2json converter
  #
  # http://www.xml.com/pub/a/2006/05/31/converting-between-xml-and-json.html
  #
  # rewrite(bruin, 2013-11-26)
  # last updated(bruin, 2013-11-28)
  #########################################################################*/


/*
 * This "module" provide the following functions:
 *
 * - xml2dom()
 * - dom2json()
 *
 * - xml2json(): xml2dom() + dom2json()
 * - xml2txt(): xml2json() + JSON.stringify()
 *
 * Notes about the intrinsic limitations:
 * a) xml tag name has some restriction, e.g., no space, can not be quoted...etc, while
 *    javascript property name can be any string and can be always quoted.
 *    This is not a big problem, as we can add attributes into a tag, by using the attributes
 *    to convey the desired names;
 * b) a javascript object can not have two properties of the same name, while in xml a
 *    parent tag can have multiple kids of the same tag. The solution is to convert the kid tags
 *    into a js array, which is the value of a property whose name is the common tag name;
 */

/* 
 * some constants
 */
var NON_SPACE = /[^ \f\n\r\t\v]/;
var SHARP_TEXT = "#text";
var SHARP_CDATA = "#cdata";

/* 
 * convert a xml text string into a normalized, white-removed & comments-removed dom object 
 */
function xml2dom(xml) {
    var MIME = "text/xml";
    var dom = null;

    if (!xml) {
        return null;
    }

    if (window.DOMParser) {
        dom = (new DOMParser()).parseFromString(xml, MIME);
    } else if (window.ActiveXObject) {
        dom = new ActiveXObject('Microsoft.XMLDOM');
        dom.async = false;
        if (!dom.loadXML(xml)) {
            window.alert(dom.parseError.reason + dom.parseError.srcText);
            dom = null;
        }
    } else {
        window.alert("Error: your browser does not support parsing XML to DOM!");
    }

    if (dom.normalize) {
        dom.normalize();
    }

    
    _removeComments(dom);
    _removeWhites(dom);

    return dom;



    /*
     * private functions (to be hoisted) go below:
     */
    // recursively remove all pure white TEXT_NODE from the element, in place
    function _removeWhites(e) {
        var node, next;
        if (!e)
            return;

        for (node = e.firstChild; node;) {
            if (node.nodeType == Node.TEXT_NODE) {
                if (!node.nodeValue.match(NON_SPACE)) {
                    next = node.nextSibling;
                    e.removeChild(node);
                    node = next;
                } else {
                    node = node.nextSibling;
                }
            } else if (node.nodeType == Node.ELEMENT_NODE) {
                _removeWhites(node);
                node = node.nextSibling;
            } else {
                node = node.nextSibling;
            }
        }

        return e;
    }

    // recursively remove comments, in place
    function _removeComments(e) {
        var node, next;

        if (!e)
            return;

        for (node = e.firstChild; node; ) {
            if (node.nodeType == Node.COMMENT_NODE) {
                next = node.nextSibling;
                e.removeChild(node);
                node = next;
            } else if (node.nodeType == Node.ELEMENT_NODE) {
                _removeComments(node);
                node = node.nextSibling;
            } else {
                node = node.nextSibling;
            }
        }

        return e;
    }
}


/*
 * convert the dom into a JSON object (i.e. using only array/object/string/number/true/false/null)
 */
function dom2json(dom) {
    var o = {};
    var i, n;

    var _as_xml = function (n) {
        var i, c;
        var s = "";
        if (n.nodeType == Node.ELEMENT_NODE) {
            s += "<" + n.nodeName;
            for (i = 0; i < n.attributes.length; i++) {
                s += " " + n.attributes[i].nodeName + "=\"" + (n.attributes[i].nodeValue || "").toString() + "\"";
            }
            if (n.firstChild) {
                s += ">";
                for (c = n.firstChild; c; c = c.nextSibling) {
                    s += _as_xml(c);
                }
                s += "</" + n.nodeName + ">";
            } else {
                s += "/>";
            }
        } else if (n.nodeType == Node.TEXT_NODE) {
            s += n.nodeValue;
        } else if (n.nodeType == Node.CDATA_SECTION_NODE) {
            s += "<![CDATA[" + n.nodeValue + "]]>";
        }
        return s;
    };

    var _inner_xml = function (node) {
        if ("innerHTML" in node)
            return node.innerHTML;
        var s = "";
        for (var c = node.firstChild; c; c = c.nextSibling) {
            s += _as_xml(c);
        }
        return s;
    };

    // get a json-escaped string
    var _escapeJson = function (txt) {
        return (txt.replace(/[\\]/g, "\\\\")
                .replace(/[\"]/g, '\\"')
                .replace(/[\n]/g, '\\n')
                .replace(/[\r]/g, '\\r'));
    };


    if (!dom)
        return null;

    if (dom.nodeType == Node.DOCUMENT_NODE) {
        var O = {};
        O[dom.documentElement.nodeName] = dom2json(dom.documentElement);
        return O;
    }

    if (dom.nodeType == Node.ELEMENT_NODE) {

        if (!dom.attributes.length && !dom.firstChild) {
            return null;
        }

        // converts attributes[] into properties
        if (dom.attributes.length) {
            for (i = 0; i < dom.attributes.length; i++) {
                o["@" + dom.attributes[i].nodeName] = 
                    (dom.attributes[i].nodeValue || "").toString();
            }
        }

        if (dom.firstChild) { // element has child nodes ..
            var textChild = 0;
            var cdataChild = 0;
            var hasElementChild = false;

            for (n = dom.firstChild; n; n = n.nextSibling) {
                if (n.nodeType == Node.ELEMENT_NODE) {
                    hasElementChild = true;
                } else if (n.nodeType == Node.TEXT_NODE && n.nodeValue.match(NON_SPACE)) {
                    textChild++; // non-whitespace text
                } else if (n.nodeType == Node.CDATA_SECTION_NODE) {
                    cdataChild++; // cdata section node
                }
            }

            if (hasElementChild) {
                if (textChild < 2 && cdataChild < 2) { 
                    // structured element with a single text or/and cdata node
                    for (n = dom.firstChild; n; n = n.nextSibling) {
                        if (n.nodeType == Node.TEXT_NODE) {
                            o[SHARP_TEXT] = _escapeJson(n.nodeValue);
                        } else if (n.nodeType == Node.CDATA_SECTION_NODE) {
                            o[SHARP_CDATA] = _escapeJson(n.nodeValue);
                        } else if (o[n.nodeName]) { // multiple occurence of element ..
                            if (o[n.nodeName] instanceof Array) {
                                o[n.nodeName][o[n.nodeName].length] = dom2json(n);
                            } else {
                                o[n.nodeName] = [o[n.nodeName], dom2json(n)];
                            }
                        } else { // first occurence of element..
                            o[n.nodeName] = dom2json(n);
                        }
                    }
                } else { // mixed content
                    if (!dom.attributes.length) {
                        o = _escapeJson(_inner_xml(dom));
                    } else {
                        o[SHARP_TEXT] = _escapeJson(_inner_xml(dom));
                    }
                }
            } else if(textChild) { 
                // pure text
                if (!dom.attributes.length) {
                    o = _escapeJson(_inner_xml(dom));
                } else {
                    o[SHARP_TEXT] = _escapeJson(_inner_xml(dom));
                }
            } else if (cdataChild) { 
                // cdata
                if (cdataChild > 1) {
                    o = _escapeJson(_inner_xml(dom));
                } else {
                    for (n = dom.firstChild; n; n = n.nextSibling) {
                        o[SHARP_CDATA] = _escapeJson(n.nodeValue);
                    }
                }
            }
        }
    } else if (dom.nodeType == Node.COMMENT_NODE){
        o = dom.nodeValue; // should not happen: is _removeComments() called?
    } else {
        console.log("unhandled node type: " + dom.nodeType);
    }

    return o;
}


// xml to json
function xml2json(xml) {
    var dom = xml2dom(xml);
    var obj = dom2json(dom);
    return obj;
}

// xml to json text 
function xml2txt(xml) {
    var obj = xml2json(xml);
    return JSON.stringify(obj, null, 4);
}

/*
 * sanity tests for xml2json()
 */
(function () {
    var xmls = [undefined,
                null,
                "<e/>",
                "<e>text</e>",
                "<e attr1='value1' attr2='value2'/>",
                "<e name='value'>text</e>",
                "<e><a>text</a><b>text2</b></e>",
                "<e><a>text</a><a>text2</a></e>",
                "<e>text<a>text2</a>text3</e>",
                "<?xml version='1.0'?><e><!--comments-->text</e>"
               ];
    xmls.map(function (xml) {
        console.log(xml);
        console.log(xml2txt(xml));
        console.log('--------------');
    }).join("");
}());

