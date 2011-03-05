var events = require('events');
var util = require(process.binding('natives').util ? 'util' : 'sys');
//NodeBase is an EventEmitter
util.inherits(NodeBase, events.EventEmitter);
/**
 * @desc this is the mother of all Objects; a node Base Class with (logging and options, defaults)
 */

module.exports=NodeBase;

//LOG LEVELS
var L = 0
var LL =
 { ALL: L++
 , LOG : L++
 , INFO : L++
 , WARN : L++
 , ERROR : L++
 };
for (L in LL) LL[LL[L]] = L; 
module.exports.LOG_LEVELS = LL;
   
function NodeBase(opts, defaults){
  defaults = defaults || {};
  events.EventEmitter.call(this);
	//process.EventEmitter.call(this);
	var self=this;
	//self.defaults=merge(self.defaults, defaults); //leave defaults like they are
	options({
	  //yourDefaultsGoHere: true,
	  logging: false,
	  logLevel: 'ALL',
	  printLevel: true,
	  printContext: true,
	  useStack: true,
	  emitLog: true,
		cacheSize: 5 //a fun property whatever this means
	}, self.defaults, defaults, opts, self);
	//loglevel
 

  this.LOG_LEVELS = LL; //make loglevel available in the object
  this._checkLogLevel = function(level){
    return (LL[this.options.logLevel] <= LL[level]);
  }
}

//ADD THE CLASSNAME AND A TIMESTAMP TO THE LOGGING OUTPUT
NodeBase.prototype._addContext = function _addC(a, level){
  var args = Array.prototype.slice.call(a);
  var copy = args.slice(1, args.length);
  if(level && this.options.printLevel)  args.unshift(stylize(level)); 
  var stack;  
  try{
    if (this.options.useStack) stack = new Error().stack.split('at ')[3].match(/(.*)\s\(/)[1]; // selct everything before parenthesis
  }catch(e){  } 
  var stack = stack || this.constructor.name

  if (this.options.printContext) args.unshift('['+stack+'] ' + '--' + now()+ ' '); 

  //emit a log event
  if(this.options.emitLog) this.emit(level, {'message': args.join(' ') ,'data': copy })
  
  return args;   
}
NodeBase.prototype.log = function(a){ if (this.options.logging && this._checkLogLevel('LOG')) console.log.apply(this, this._addContext(arguments, 'LOG'));}
NodeBase.prototype.warn = function(a){ if (this.options.logging && this._checkLogLevel('WARN')) console.warn.apply(this, this._addContext(arguments, 'WARN'));}
NodeBase.prototype.info = function(a){ if (this.options.logging && this._checkLogLevel('INFO')) console.info.apply(this, this._addContext(arguments, 'INFO'));}  
NodeBase.prototype.error = function(a){ if (this.options.logging && this._checkLogLevel('ERROR')) console.error.apply(this, this._addContext(arguments, 'ERROR'));}
  // we try connecting every n milli seconds. On errors n is always doubled.

function now(){
	return new Date().toUTCString();
}
NodeBase.now = module.exports.now = now;

function options(defaults){
  var args = Array.prototype.slice.call(arguments);
  var self = args[args.length-1]
  if(self instanceof NodeBase)
    args.pop(),
	  self.options = merge.apply(null, args);
  else{
    return merge.appy(null, arguments);
  }
}
NodeBase.options = module.exports.options = options;

// a mixin function similar to _.extend
function merge(obj){
  Array.prototype.slice.call(arguments, 1).forEach (function(source) {
     for (var prop in source) obj[prop] = source[prop];
   });
   return obj;
};
NodeBase.merge = module.exports.merge = merge;

//the node version
var node_ver = null;
(function(){
	if( node_ver ) return node_ver;
	var ver = process.version,
		rex = /^v(\d+)\.(\d+)\.(\d+)/i;

	var matches = ver.match(rex);
	if( !matches ){
		throw "Unable to determine node version";
	}

	node_ver = { major: (~~matches[1]), minor: (~~matches[2]), release: (~~matches[3]) };
	return node_ver;
})();
NodeBase.node_ver = module.exports.node_ver = node_ver;

//Convert arguments to array
var arrize = function(ary, from){
    return Array.prototype.slice.call(ary, from || 0);
};

//a bind function similar to _.bind
//Bind  proxy objects to function
function glue(f, obj){
	var oargs = arrize(arguments, 2);
	return function(){
		var iargs = arrize(arguments);
		return f.apply && f.apply(obj, oargs.concat(iargs));
	}
}
NodeBase.glue = module.exports.glue = glue;

/**
 * Code taken from Robert Kieffer UUID
 */

/*!
Math.uuid.js (v1.4)
http://www.broofa.com
mailto:robert@broofa.com

Copyright (c) 2010 Robert Kieffer
Dual licensed under the MIT and GPL licenses.
*/

//A UUID GENERATROR FUNCTION
 // Private array of chars to use
var CHARS = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split(''); 

var UUID = {};

UUID.uuid = function (len, radix) {
	var chars = CHARS, uuid = [];
	radix = radix || chars.length;

	if (len) {
		// Compact form
		for (var i = 0; i < len; i++) uuid[i] = chars[0 | Math.random()*radix];
	} else {
		// rfc4122, version 4 form
		var r;

		// rfc4122 requires these characters
		uuid[8] = uuid[13] = uuid[18] = uuid[23] = '-';
		uuid[14] = '4';

		// Fill in random data.  At i==19 set the high bits of clock sequence as
		// per rfc4122, sec. 4.1.5
		for (var i = 0; i < 36; i++) {
			if (!uuid[i]) {
				r = 0 | Math.random()*16;
				uuid[i] = chars[(i == 19) ? (r & 0x3) | 0x8 : r];
			}
		}
	}

	return uuid.join('');
};

NodeBase.uuid = module.exports.UUID = UUID;

//Stylize color helper
var stylize = function(level) {
  // http://en.wikipedia.org/wiki/ANSI_escape_code#graphics
  var styles =
      { 'bold' : [1, 22],
        'italic' : [3, 23],
        'underline' : [4, 24],
        'inverse' : [7, 27],
        'white' : [37, 39],
        'grey' : [90, 39],
        'black' : [30, 39],
        'blue' : [34, 39],
        'cyan' : [36, 39],
        'green' : [32, 39],
        'magenta' : [35, 39],
        'red' : [31, 39],
        'yellow' : [33, 39] };

  var style =
      { 'WARN': 'magenta',         
        'ERROR': 'red',              
        'INFO': 'cyan',        
        'LOG': 'green',
      }[level];

  if (style) {
    return '\033[' + styles[style][0] + 'm' + '[' + level + ']' +
           '\033[' + styles[style][1] + 'm';
  } else {
    return str;
  }
};
if (typeof global !== 'undefined' ) var colors=true;
if (! colors) {
  stylize = function(level) { return '['+ level+ '] '; };
}



