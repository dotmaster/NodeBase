nodeBase = require '..nodeBase-coffe'
util = require 'util'

class someClass extends nodeBase
  constructor:(opts) ->
    super(opts)
  someMember: => @log 'hello there'
  
myObj = new someClass 
  logging: true
myObj.someMember # should output  [someClass]  -- Thu, 03 Mar 2011 22:01:29 GMT  hello there