// created(bruin, 2012-12-22): 1st day after the end-of-the-world...
// testing encoding conversion...
//
// install node.js and then "npm install iconv-lite".
//
//

var iconv = require('iconv-lite');

//var s_heb = '\xe6\xe6';  // raw string in ISO 8859-8, aka hebrew
//var b_heb = new Buffer(s_heb, 'binary');  // new binary buffer from string
var b_heb = new Buffer([0xe6, 0xe6]);
var s_ucs2 = iconv.decode(b_heb,'hebrew'); // decode heb buf to ucs2 string
var b_utf8 = iconv.encode(s_ucs2, 'utf8'); // encode ucs2 string to utf8 buf
var b_ucs2 = new Buffer(s_ucs2, 'ucs2');   // new ucs2 (utf16le) buffer from string

console.log("hebrew:");
console.log(b_heb);
console.log("utf8:");
console.log(b_utf8);
console.log("utf16le:");
console.log(b_ucs2);
