events = require('events')
util = require(if process.binding('natives').util then 'util' else 'sys')
CappedObject = require './CappedObject'
#extend the stacktracelimit for coffeescript
Error.stackTraceLimit = 50;
stringify =  (obj) -> JSON.stringify(obj, null, " ")

#from underscore.coffee
isEmpty = (obj) ->
  return obj.length is 0 if isArray(obj) or isString(obj)
  return false for own key of obj
  true
isElement   = (obj) -> obj and obj.nodeType is 1
isArguments = (obj) -> obj and obj.callee
isFunction  = (obj) -> !!(obj and obj.constructor and obj.call and obj.apply)
isString    = (obj) -> !!(obj is '' or (obj and obj.charCodeAt and obj.substr))
isArray     = Array.isArray or (obj) -> !!(obj and obj.concat and obj.unshift and not obj.callee)
###
# 
# MERGE
# a mixin function similar to _.extend but more powerful
# it can also deal with non objects like functions
#
# @desc A cool merge function, that emits warnings
#
# @args obj, args..., last
# the first argunment is the object we merge in,, which can also be a function, or better if the first obj is not an object we just set it to the merge value,
# the last can be a boolean, in such case it is a switch for turning on and off warnings, on overwriting existing variables
# logging of warnings is turned on by default
#
###

module.exports.merge = module.exports.extend = module.exports.mixin = merge = (obj, args..., last) ->
  if not obj? then throw new Error('merge: first parameter must not be undefined')
  log = true #logging of merge conflict is turned on by default
  initialProps = {}
  initialProps[prop] = true for own prop of obj
  if typeof last isnt 'boolean' then args.push last else log = last
  for source in args
    if obj is source then return obj #if it's the same just return 
    if (typeof source isnt 'object') and source? #if source is not an object and not undefined set obj to source, but log if we overwrite an existing obj
      if (typeof obj isnt 'object' and obj?) or not isEmpty(obj) #obj can be a function or string or an object containing something, then we warn
        if log then @warn "Object #{stringify(obj) or obj.name or typeof obj} exists and will be overwritten with #{stringify(source) or obj.name or typeof obj}"
      obj = source
    else  
      for own prop of source
        if initialProps[prop]?   #if the property already exists in the iniotial properties the object had before merge
          if log  # and we log
            @warn "property #{prop} exists and value #{stringify(obj[prop]) or typeof obj[prop]} will be overwritten with #{stringify(source[prop]) or typeof obj[prop]}" #give a warning about overwriting and existing initial Property of Object
            ###at #{new Error().stack}###
        obj[prop] = source[prop]
  return obj
#Coffeescript is anoying on this, all you don't define before, will be undefined
#NodeBase.options = NodeBase.defaults = merge NodeBase.defaults, NodeBase.objdefaults

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
    merge superClass.options or= {}, superClass.defaults, false #superClass options has already nodeBases @options merged in through extend
    #superClass.Cache ?= new CappedObject(NodeBase.options.maxCap, superClass.name)     
    #emit CLASS level cache events
    #superClass.Cache.on 'add', (obj) => superClass.emit 'add', obj
    #superClass.Cache.on 'remove', (obj) => superClass.emit 'remove', obj  
    #superClass.Cache.on 'drop', (obj) => superClass.emit 'drop', obj
  @objdefaults = 
    logging: true
    logLevel: 'ERROR'
    printLevel: true
    printContext: true    
    useStack: true
    emitLog: false    
  @defaults = merge @objdefaults, #see above Coffescript is annoying on using functions that are defined later in context
      addToCollection: false         
      maxCap: 10000    
  @options = @defaults
  @merge = merge
  @mixin = merge  
  @extend = merge  
  @node_ver = node_ver 
  #Class Collection specific
  @lookupId = (id)-> if @name? then @Cache?.getId(id) else NodeBase?.getId(id)
  #the CLASS level NODEBASE cache (=Capped Hash)
  #@Cache ?= new CappedObject(NodeBase.options.maxCap, @name)     
  #emit CLASS level cache events
  #@Cache.on 'add', (obj) => @emit 'add', obj
  #@Cache.on 'remove', (obj) => @emit 'remove', obj  
  #@Cache.on 'drop', (obj) => @emit 'drop', obj
  #@Cache = ->  if @name? then Cache[@name] else Cache['NodeBase']  
  #remove Objects from the CLASS collection, see also @_remove() on Object level
  @_remove = (obj) -> _remove(obj)  
  #get the number of objects created
  @getTotalIds = -> if @name? then cids[@name] || 0 else cids['NodeBase'] || 0
  #CLASS level logging
  @log = -> if @options.logging and @_checkLogLevel 'LOG' then console.log (@_addContext arguments..., 'LOG')
  @warn = -> if @options.logging and @_checkLogLevel 'WARN' then console.log (@_addContext arguments..., 'WARN')
  @info = -> if @options.logging and @_checkLogLevel 'INFO' then console.log (@_addContext arguments..., 'INFO')
  @error = -> if @options.logging and @_checkLogLevel 'ERROR' then console.log (@_addContext arguments..., 'ERROR')
  @_addContext = -> _addStaticContext.apply @, arguments 
  @_checkLogLevel = (level)-> LL[@options.logLevel] <= LL[level]    
  #event emitting of CLASS
  @emit: -> @_emitter.emit.apply @, arguments 
  @_emitter = new events.EventEmitter();
  @_emitter.on 'error', (err) -> console.log stringify(err, null, " ")  
  #CLASS level combined log emitters
  @ermit= -> _ermit.apply @, arguments 
  @wamit= -> _wamit.apply @, arguments 
  @inmit= -> _inmit.apply @, arguments 


          
  constructor:(opts, defaults) ->
    super()    
    @init(opts, defaults)
    
  init: (opts, defaults) ->
    self=this
    #merge defaults but don't make them public -> defaults will become options
    _defaults = merge {},  
      logging: true
      logLevel: 'ERROR'
      printLevel: true
      printContext: true    
      useStack: true  
      emitLog: false
      autoId: true 
      autoUuid: true                     
      cacheSize: 5
    ,@defaults, defaults, false
    # merge constructor level Object defaults before object level defaults
    @options = merge @options or= {}, @constructor.objdefaults,  _defaults, opts, true
    #@on 'error', (err) -> @log 'emitted error ' + JSON.stringify(err)
    @LOG_LEVELS = LL #make log levels available in the object
    @_checkLogLevel = (level)->
      LL[@options.logLevel] <= LL[level]
    if @_id and @options.autoId then @warn 'overwriting _id'
    @_id = if @options.autoId then cid(this) else @_id
    @_uuid =  if @options.autoUuid then UUID.uuid() else ""
    if @options.autoId then @_getTotalIds = -> getTotalIds @ #actually this is just a counter of times the constructor was called    
    if @constructor.options.addToCollection then addId(this)
    @_remove = -> _remove(this)
    
  #ADD THE CLASSNAME AND A TIMESTAMP TO THE LOGGING OUTPUT
  _addContext: -> _addContext.apply @, arguments
  ###  
  #
  # OBJECT LOGGING
  # error is special in that the first argument is interpretated as message, second as type, third, ... as arguments
  #
  #
  ###     
  log: => if @options.logging and @_checkLogLevel 'LOG' then console.log (@_addContext arguments..., 'LOG')
  warn: => if @options.logging and @_checkLogLevel 'WARN' then console.log (@_addContext arguments..., 'WARN')
  info: => if @options.logging and @_checkLogLevel 'INFO' then console.log (@_addContext arguments..., 'INFO')
  error: => if @options.logging and @_checkLogLevel 'ERROR' then console.log (@_addContext arguments..., 'ERROR')
  ermit: => _ermit.apply @, arguments 
  wamit: => _wamit.apply @, arguments 
  inmit: => _inmit.apply @, arguments 
                  
#export the base class
#
module.exports = NodeBase
module.exports.LOG_LEVELS = LL;

module.exports.now = now = ->
	new Date().toUTCString();
    
#the node version
node_ver = null
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

module.exports.glue = glue;

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
		for i in [0...36]
			if not uuid[i] 
				r = 0 | Math.random()*16
				uuid[i] = chars[if (i == 19) then (r & 0x3) | 0x8 else r]
	uuid.join('')

module.exports.uuid = UUID.uuid
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


#add Ids to a global collection, can be looked up with the static function className.lookupId

#Cache = {}
_remove = (obj)->
  if not obj._id then module.exports.error "Obj to add has no propety _id, please turn on autoId or give the object an _id before passing it to super"
  if obj?.constructor.name? 
   #(Cache[obj.constructor.name]?=new CappedObject(NodeBase.options.maxCap, obj.constructor.name)).remove(obj)
   obj.constructor.Cache.remove(obj)
  else
    #(Cache['NodeBase']?={})[obj._id] = obj
    #(Cache['NodeBase']?=new CappedObject(NodeBase.options.maxCap, 'NodeBase')).remove(obj)  
    NodeBase.ne.remove(obj)
addId = (obj)->
  #check if autoId is turned on or the object has an id
  if not obj._id then module.exports.error "Obj to add has no propety _id, please turn on autoId or give the object an _id before passing it to super"
  if obj?.constructor.name? 
   #(Cache[obj.constructor.name]?={})[obj._id] = obj
   #(Cache[obj.constructor.name]?=new CappedObject(NodeBase.options.maxCap, obj.constructor.name)).addId(obj)
   (obj.constructor.Cache?=new CappedObject(NodeBase.options.maxCap, obj.constructor)).addId(obj)
  else
    #(Cache['NodeBase']?={})[obj._id] = obj
    #(Cache['NodeBase']?=new CappedObject(NodeBase.options.maxCap, 'NodeBase')).addId(obj)
    (NodeBase.Cache?=new CappedObject(NodeBase.options.maxCap, NodeBase)).addId(obj)

module.exports.cid = cid

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
    
colorize = (string, color) -> #can be a color or level
  color = levelStylesMapping[color]?=color
  return '\033[' + styles[color][0] + 'm' + string +
         '\033[' + styles[color][1] + 'm'
       
#Stylize color helper
stylize = (level) ->



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
  colorize = (string, color) -> 
    string

#common LOGGING functionality  ->! this comes over caller
 
_addStaticContext = ( args..., level ) ->
  args.unshift stylize(level) if level? and @options.printLevel   
  stack = @name + ' static'
  message = "[-- #{now()} #{stack}]  #{args.join ' '}"
  messageColor = " -- #{now()}  #{colorize('[ '+ stack + ']', level)} #{args.join ' '}"
  if @options.emitLog
    @_emitter.emit level.toLowerCase(), 
      'message': message
      'data': 
          'class': @name
          'args': args[1...args.length]
      'type': args[1]
  return messageColor
  
_addContext = ( args..., level ) ->
  args.unshift stylize(level) if level? and @options.printLevel   
  try
    #reg = new RegExp /at\s(.*)\s\(/g
    reg = new RegExp /at\s(.*)\s\(.*:(\d+):\d+/i
    #RegExp.multiLine = true
    stackArray = new Error().stack.split reg
    debugger
    #console.log util.inspect stackArray
    #this is a hardcore hack, but what shalls
    if @options.useStack 
      #stack = if stackArray[9].indexOf('new') is -1 and stackArray[11].indexOf('anonymous') is -1 then stackArray[11] else stackArray[9] # select everything before parenthesis for stack in stackArray
      stack = if stackArray[13].indexOf('new') is -1 and stackArray[19].indexOf('anonymous') is -1 then "#{stackArray[19]}[#{stackArray[20]}]"else "#{stackArray[13]}[#{stackArray[14]}]" # select everything before parenthesis for stack in stackArray
      if stack.indexOf('inmit') isnt -1 or 
        stack.indexOf('inmit') isnt -1 or
        stack.indexOf('ermit') isnt -1           
        #then stack = stackArray[13]
        then stack = "#{stackArray[25]}[#{stackArray[26]}]"
  catch e  
  stack ?= @constructor.name
  if @options.autoId then id = " id:#{@_id}"
  message = "-- #{now()} [#{stack + id}]  #{args.join ' '}"
  messageColor = "-- #{now()} #{colorize('[ '+ stack + id + ']', level)} #{args.join ' '}"
  if @options.emitLog
    @emit level.toLowerCase(), 
      'message': message
      'data': 
        'class': @constructor.name
        'id': @_id
        'uuid': @_uuid
        'args': args[1...args.length] 
      'type': args[1] #let's say that the first argument is the message, the second the type
  return messageColor

#combined emit logging functions -> ! this comes over caller
_ermit = (message, errObj={}) ->
  mes = if typeof message isnt 'string' and message.message? then message.message else message #ducktype for passing in an error object
  if arguments.length < 1 or typeof mes isnt 'string' then throw "Ermit needs at least one arguments: a message and an optional error Object"
  ###
    message data
    - message
    -stack (the current stack)
    -err (the underlying errorObj)
  ###
  err = 
    'stack': new Error().stack
    'message': message
    'err': errObj
  @error mes
  @emit 'error', err
_wamit = (type, dataObj={}, message="") ->
  if arguments.length <1 or 
    typeof message isnt 'string' or 
    typeof type isnt 'string' 
    then throw "wamit needs at least one arguments: a type, an optional Data Object and an optional message"
  ###
    data
    dataOb   
    - message
  ###
  mes = if message is "" then type else message    
  dataObj.message ?= "" 
  if typeof dataObj.message is "string" then dataObj.message += ' - ' + mes #don't override if dataObj has an existing message property
  @warn mes
  @emit type, dataObj   
_inmit = (type, dataObj={}, message="") ->
  if arguments.length <1 or 
    typeof message isnt 'string' or 
    typeof type isnt 'string' 
    then throw "inmit needs at least one arguments: a type, an optional Data Object and an optional message"
  mes = if message is "" then type else message
  ###
    data
    dataOb   
    - message
  ###
  if dataObj.message then dataObj.message + " - " else "" #don't override if dataObj has an existing message property
  dataObj.message += mes
  @info mes
  @emit type, dataObj