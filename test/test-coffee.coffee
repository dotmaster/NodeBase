nodeBase = require __dirname + '/../index'

util = require(if process.binding('natives').util then 'util' else 'sys')

log = -> someClass.log arguments...

class someClass extends nodeBase
  @defaults: 
    logging:true
    logLevel: 'ALL'
    addToCollection: true
  nodeBase.static(@); #add static @options to class
  constructor:(opts) ->
    @defaults =
      put:'someDefaultsHere'
    super(arguments...)
    @on 'error', (err) -> @warn 'emitted and catched error ' + JSON.stringify(err, null, " ")
    @error 'awesome!!!'
  someMember: => 
    @log 'hello there'
    @warn 'hello there'
  
myObj = new someClass 
  logging: true
  logLevel: 'WARN'
  some:'opts',
  
myObj.someMember() 



anotherObj = new someClass 
  logging: true

if someClass.options.addToCollection then console.log 'cache ' + util.inspect someClass.Cache()
debugger
log 'Number of Objects created ' + someClass.getTotalIds()
# should output  
#[new someClass] --Fri, 04 Mar 2011 11:53:16 GMT  [INFO] awesome!!! <--OUTPUT OF LOGLEVEL WILL BE COLORED
#[someClass.someMember] --Fri, 04 Mar 2011 11:53:16 GMT  [WARN] hello there