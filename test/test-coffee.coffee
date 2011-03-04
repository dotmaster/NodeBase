nodeBase = require '../nodeBase-coffee'
util = require 'util'

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
myObj.someMember() # should output  [someClass]  -- Thu, 03 Mar 2011 22:01:29 GMT  hello there