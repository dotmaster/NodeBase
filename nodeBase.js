var events = require('events');
var util=require('util');
//NodeBase is an EventEmitter
util.inherits(NodeBase, events.EventEmitter);
/**
 * @desc this is the mother of all Objects; a node Base Class with (logging and options, defaults)
 */

module.exports=NodeBase;

function NodeBase(opts){
  events.EventEmitter.call(this);
	//process.EventEmitter.call(this);
	var self=this;
	options({
	  //yourDefaultsGoHere: true,
	  logging: false,
		cacheSize: 5
	}, opts, self);
}
//ADD THE CLASSNAME AND A TIMESTAMP TO THE LOGGING OUTPUT
NodeBase.prototype._addContext = function(a){
  var args = Array.prototype.slice.call(a);
  args.unshift('['+this.constructor.name+'] ' + '--' + now()+ ' '); 
  return args;   
}
NodeBase.prototype.log = function(a){ if (this.options.logging) console.log.apply(this, this._addContext(arguments));}
NodeBase.prototype.warn = function(a){ if (this.options.logging) console.warn.apply(this, this._addContext(arguments));}
NodeBase.prototype.info = function(a){ if (this.options.logging) console.info.apply(this, this._addContext(arguments));}  
NodeBase.prototype.error = function(a){ if (this.options.logging) console.error.apply(this, this._addContext(arguments));}
  // we try connecting every n milli seconds. On errors n is always doubled.

function now(){
	return new Date().toUTCString();
}
NodeBase.now = module.exports.now = now;

function options(opts, mergeOpts, self){
  if(self)
	  self.options = merge(opts || {}, mergeOpts || {});
	  else{
	    return merge(opts || {}, mergeOpts || {});
	  }
}
NodeBase.options = module.exports.options = options;

// a mixin function similar to _.extend
function merge(source, merge){
	for (var i in merge) source[i] = merge[i];
	return source;
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



