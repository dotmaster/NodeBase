nodeBase = require __dirname + '/../nodeBase-coffee'
util = require(if process.binding('natives').util then 'util' else 'sys')

class someClass extends nodeBase
  constructor:(opts, defaults) ->
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
    a: 'default'
myObj.someMember() 
# should output  
#[new someClass] --Fri, 04 Mar 2011 11:53:16 GMT  [INFO] awesome!!! <--OUTPUT OF LOGLEVEL WILL BE COLORED
#[someClass.someMember] --Fri, 04 Mar 2011 11:53:16 GMT  [WARN] hello there