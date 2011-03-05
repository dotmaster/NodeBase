events = require('events')
util = require(if process.binding('natives').util then 'util' else 'sys')

#extend the stacktracelimit for coffeescript
Error.stackTraceLimit = 50;

#LOG LEVELS
L = 0
LL =
 ALL: L++
 LOG : L++
 INFO : L++
 WARN : L++
 ERROR : L++

LL[LL[L]] = L for L of LL #yeah! 

###
 @desc this is the mother of all Objects; a node Base Class with (logging and options, defaults)
  NodeBase is an EventEmitter 
###

class NodeBase extends events.EventEmitter


  #static Functions
  @now = now
  @static = (superClass) -> 
    superClass[i]?=NodeBase[i] for own i, val of NodeBase
    merge superClass.options or= {}, superClass.defaults #superClass options has already nodeBases @options merged in through extend
  @defaults = 
    logging: false
    logLevel: 'ALL'
    printLevel: true
    printContext: true    
    useStack: true
    emitLog: true    
    maxCap: 10000
    addToCollection: false
  @options = @defaults
  @merge = merge
  @mixin = merge  
  @extend = merge  
  @node_ver = node_ver 
  @lookupId = (id)-> if @name? then Cache[@name]?.getId(id) else Cache['NodeBase']?.getId(id)
  @Cache = ->  if @name? then Cache[@name]?.Collection else Cache['NodeBase']?.Collection
  @getTotalIds = -> if @name? then cids[@name] || 0 else cids['NodeBase'] || 0
  @log = => if @options.logging and @_checkLogLevel 'LOG' then console.log (@_addContext arguments..., 'LOG')
  @warn = => if @options.logging and @_checkLogLevel 'WARN' then console.log (@_addContext arguments..., 'WARN')
  @info = => if @options.logging and @_checkLogLevel 'INFO' then console.log (@_addContext arguments..., 'INFO')
  @error = => if @options.logging and @_checkLogLevel 'ERROR' then console.log (@_addContext arguments..., 'ERROR')  
  @_checkLogLevel = (level)-> LL[@options.logLevel] <= LL[level]
  @_emitter = new events.EventEmitter();
  @_addContext = ( args..., level ) =>
    args.unshift stylize(level) if level? and @options.printLevel   
    stack = @name + ' static'
    message = "[#{stack}]  -- #{now()}  #{args.join ' '}"
    if @options.emitLog
      @_emitter.emit level, 
        'message': message
        'data': 
            'class': @name
            'args': args[1...args.length]
    return message
          
  constructor:(opts) ->
    super()
    self=this
    #merge @defaults, defaults #leave defaults like they are
    merge @defaults or= {},  
      #yourDefaultsGoHere: true
      logging: false
      logLevel: 'ALL'
      printLevel: true
      printContext: true    
      useStack: true  
      emitLog: true
      autoId: true 
      autoUuid: true                     
      cacheSize: 5
    ,@defaults
    merge @options or= {}, @defaults, @constructor.defaults, opts
    @LOG_LEVELS = LL #make log levels available in the object
    @_checkLogLevel = (level)->
      LL[@options.logLevel] <= LL[level]
    @_id = if @options.autoId then cid(this) else ""
    @_uuid =  if @options.autoUuid then UUID.uuid() else ""
    if @options.autoId then @_getTotalIds = -> getTotalIds @ #actually this is just a counter of times the constructor was called    
    if @constructor.options.addToCollection then addId(this)

  #ADD THE CLASSNAME AND A TIMESTAMP TO THE LOGGING OUTPUT
  _addContext: ( args..., level ) =>
    args.unshift stylize(level) if level? and @options.printLevel   
    try
      reg = new RegExp /at\s(.*)\s\(/g
      #RegExp.multiLine = true
      stackArray = new Error().stack.split reg
      #console.log util.inspect stackArray
      #this is a hardcore hack, but what shalls
      if @options.useStack 
        stack = if stackArray[9].indexOf('new') is -1 and stackArray[11].indexOf('anonymous') is -1 then stackArray[11] else stackArray[9] # select everything before parenthesis for stack in stackArray
    catch e  
    stack ?= @constructor.name
    if @options.autoId then id = " id:#{@_id}"
    message = "[#{stack + id}]  -- #{now()}  #{args.join ' '}"
    if @options.emitLog
      @emit level, 
        'message': message
        'data': 
          'class': @constructor.name
          'id': @_id
          'uuid': @_uuid
          'args': args[1...args.length] 
    return message   
     
  log: => if @options.logging and @_checkLogLevel 'LOG' then console.log (@_addContext arguments..., 'LOG')
  warn: => if @options.logging and @_checkLogLevel 'WARN' then console.log (@_addContext arguments..., 'WARN')
  info: => if @options.logging and @_checkLogLevel 'INFO' then console.log (@_addContext arguments..., 'INFO')
  error: => if @options.logging and @_checkLogLevel 'ERROR' then console.log (@_addContext arguments..., 'ERROR')                
  #export the base class

module.exports = NodeBase
module.exports.LOG_LEVELS = LL;

module.exports.now = now = ->
	new Date().toUTCString();


###
module.exports.options = options = (opts, mergeOpts..., self) ->
  if self instanceof NodeBase
    # if we are called from this
    self.options = merge opts or= {}, mergeOpts or= {}
  else
    merge opts or= {}, mergeOpts or= {}
###
# a mixin function similar to _.extend
module.exports.merge = merge = (obj, args...) =>
  for source in args
    for prop of source
      obj[prop] = source[prop]
  return obj

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
  Code taken from Robert Kieffer UUID

  Math.uuid.js (v1.4)
  http://www.broofa.com
  mailto:robert@broofa.com

  Copyright (c) 2010 Robert Kieffer
  Dual licensed under the MIT and GPL licenses.


  A UUID GENERATROR FUNCTION
  Private array of chars to use
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

NodeBase.uuid = UUID.uuid
module.exports.UUID = UUID

#Cid Handling
cids={}
cid = (obj)->
  if obj?.constructor.name? 
    ++cids[obj.constructor.name] || cids[obj.constructor.name]= 1
  else
    ++cids['NodeBase'] || cids['NodeBase']= 1

getTotalCids =  (obj) ->
  if obj?.constructor.name?
    cids[obj.constructor.name] || 0
  else
    cids['NodeBase'] || 0

#a capped hash collection   
class CappedCollection extends Array
  constructor: (max, key)->
    @max = max || NodeBase.options.maxCap
    @key = key ? '_id'
    @Collection = [];
    @_byFIFO=[];   
    @_getLast = -> @_byFIFO.pop() 
    @comparator = (value) => value._id
  addId: (obj) ->
   @_byFIFO.unshift(obj)
   index = @_sortedIndex(@Collection, obj, @comparator)
   @Collection.splice(index, 0, obj)
   #if we exceeded the maximum size remove the last element
   if @max and @Collection.length > @max  
     #lookup the lastobject in the collection
     lastIndex = @_sortedIndex(@Collection, @_getLast(), @comparator)
     @Collection.splice(lastIndex, 1)   
  getId: (id) ->
    index = @_nearestObjAtIndex(@Collection, id, @comparator)
    if @Collection[index][@key] is id then @Collection[index] else undefined

  _sortedIndex: (array, obj, comparator) ->
    comparator ||= (value)->value
    low =  0
    high = array.length
    while low < high
     mid = (low + high) >> 1
     if comparator(array[mid]) < comparator(obj) then low = mid + 1 else high = mid
    low

  _nearestObjAtIndex: (array, id, comparator) ->
    comparator ||= (value)->value
    low =  0
    high = array.length
    while low < high
      mid = (low + high) >> 1
      if comparator(array[mid]) < id then low = mid + 1 else high = mid
    low
  

#add Ids to a global collection, can be looked up with the static function className.lookupId
Cache = {}
addId = (obj)->
  if obj?.constructor.name? 
   #(Cache[obj.constructor.name]?={})[obj._id] = obj
   (Cache[obj.constructor.name]?=new CappedCollection()).addId(obj)
  else
    #(Cache['NodeBase']?={})[obj._id] = obj
    (Cache['NodeBase']?=new CappedCollection()).addId(obj)

NodeBase.cid = cid

#Stylize color helper
stylize = (level) ->
  # http://en.wikipedia.org/wiki/ANSI_escape_code#graphics
  styles =
      'bold' : [1, 22]
      'italic' : [3, 23]
      'underline' : [4, 24]
      'inverse' : [7, 27]
      'white' : [37, 39]
      'grey' : [90, 39]
      'black' : [30, 39]
      'blue' : [34, 39]
      'cyan' : [36, 39]
      'green' : [32, 39]
      'magenta' : [35, 39]
      'red' : [31, 39]
      'yellow' : [33, 39]

  levelStylesMapping =
      'WARN': 'magenta'       
      'ERROR': 'red'              
      'INFO': 'cyan'        
      'LOG': 'green'
  style = levelStylesMapping[level]

  if (style)
    return '\033[' + styles[style][0] + 'm' + '[' + level + ']' +
           '\033[' + styles[style][1] + 'm'
  else
    return str

if global?
  colors = true 
else
  stylize = (level) ->  
    return '['+ level + '] '



