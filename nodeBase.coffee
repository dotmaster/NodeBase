events = require('events');
util=require('util');

###
 @desc this is the mother of all Objects; a node Base Class with (logging and options, defaults)
  NodeBase is an EventEmitter 
###
class NodeBase extends events.EventEmitter


  #static Functions
  @now: now
  @options: options
  @merge: merge
  @mixin: merge  
  @extend: merge  
  @node_ver: node_ver  
  
  constructor:(opts) ->
    super();
    self=this;
    options(
      #yourDefaultsGoHere: true
      logging: false
      cacheSize: 5
    ,opts, self)

  #ADD THE CLASSNAME AND A TIMESTAMP TO THE LOGGING OUTPUT
  _addContext: =>
    ["[#{@constructor.name}]  -- #{now()} ", arguments...]
     
  log: => if (this.options.logging) then console.log (@_addContext arguments...)...
  warn: => if (this.options.logging) then console.log (@_addContext arguments...)...
  info: => if (this.options.logging) then console.log (@_addContext arguments...)...
  error: => if (this.options.logging) then console.log (@_addContext arguments...)...                


module.exports = NodeBase
module.exports.now = now = ->
	new Date().toUTCString();



module.exports.options = options = (opts, mergeOpts, self) ->
  if self
    # if we are called from this
    self.options = merge opts or= {}, mergeOpts or= {}
  else
    merge opts or= {}, mergeOpts or= {}

# a mixin function similar to _.extend
module.exports.merge = merge = (source, merge) ->
	for i of merge 
	  source[i] = merge[i];
	return source

#the node version
node_ver = null;
do ->
  return node_ver if node_ver?
  ver = process.version
  rex = /^v(\d+)\.(\d+)\.(\d+)/i

  matches = ver.match(rex)
  throw "Unable to determine node version" unless matches?


  node_ver = 
    major: ~~matches[1]
    minor: ~~matches[2]
    release: ~~matches[3]


module.exports.node_ver = node_ver;

#Convert arguments to array
arrize = (ary, from = 0 ) -> 
    return Array.prototype.slice.call(ary, from)

#a bind function similar to _.bind
#Bind  proxy objects to function
glue = (f, obj, oargs...) ->
	(iargs...) ->
		f.apply? obj, oargs.concat iargs

NodeBase.glue = module.exports.glue = glue;

###
 * Code taken from Robert Kieffer UUID

Math.uuid.js (v1.4)
http://www.broofa.com
mailto:robert@broofa.com

Copyright (c) 2010 Robert Kieffer
Dual licensed under the MIT and GPL licenses.


//A UUID GENERATROR FUNCTION
 // Private array of chars to use
 ###
CHARS = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('')

UUID = {}

UUID.uuid = (len, radix=CHARS.length) -> 
	chars = CHARS
	uuid = []

	if len?
		# Compact form
		for i in [0..len] 
		  uuid[i] = chars[0 | Math.random()*radix]
	else
		# rfc4122, version 4 form
		r

		# rfc4122 requires these characters
		uuid[8] = uuid[13] = uuid[18] = uuid[23] = '-'
		uuid[14] = '4'

		# Fill in random data.  At i==19 set the high bits of clock sequence as
		# per rfc4122, sec. 4.1.5
		for i in [0..36]
			if not uuid[i] 
				r = 0 | Math.random()*16
				uuid[i] = chars[(i == 19) ? (r & 0x3) | 0x8 : r]
	uuid.join('')

NodeBase.uuid = UUID



