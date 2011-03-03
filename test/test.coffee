nodeBase = require '../nodeBase.coffee'
util = require 'util'

class someClass extends nodeBase
  constructor:(opts, defaults) ->
    @defaults =
      put:'someDefaultsHere'
    super(arguments...)
  someMember: => @log 'hello there'
  
myObj = new someClass 
  logging: true
  some:'opts',
    a: 'default'
myObj.someMember # should output  [someClass]  -- Thu, 03 Mar 2011 22:01:29 GMT  hello there