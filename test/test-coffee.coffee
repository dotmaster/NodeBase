nodeBase = require __dirname + '/../nodeBase-coffee'

util = require(if process.binding('natives').util then 'util' else 'sys')

log = -> someClass.log(arguments...)
class someClass extends nodeBase
  @defaults: 
    logging:true
    addToCollection: false
  @static(@); #add static @options to class
  constructor:(opts) ->
    @defaults =
      put:'someDefaultsHere'
    super(arguments...)
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
log 'Number of Objects created ' + someClass.getTotalIds()
# should output  
#[new someClass] --Fri, 04 Mar 2011 11:53:16 GMT  [INFO] awesome!!! <--OUTPUT OF LOGLEVEL WILL BE COLORED
#[someClass.someMember] --Fri, 04 Mar 2011 11:53:16 GMT  [WARN] hello there