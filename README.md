NodeBase: A node base class for Javascript and Coffeescript (logging, options, defaults and EventEmitter)
============================================

This module is the mother of all Objects of my Projects. It adds logging facility (with log levels, colored output and fancy stacktrace extraction of the current function you are in) that can be turned on and off and EventEmitter support. It provides with standard options and also provide some utility functions (namely now, merge, uuid and node_ver). Feel free to fork this and provide your own implementation. This ships as a coffee version and a JavaScript version. 

## Why?

Cause I find it a cool idea, to have a base class, which solves all the recurring tasks a class must handle in day to day business.

## How to use

To install and run do the following

	git clone https://github.com/dotmaster/nodeBase

### Implementing it on your project

In Javascript:

     var nodeBase = require('path/to/nodeBase'),
     util = require ('util');
     
     util.inherits(someClass, nodeBase);
     function someClass(){
       this.defaults={
          put:'someDefaultsHere',
        }
       nodeBase.apply(this, arguments);
     }
     someClass.prototype.someMember = function(){
       this.error('hello there')
       this.log('hello there')
     }
 
     //then somewhere in your code
 
     var myObj = new someClass({logging:true, logLevel: 'WARN', some: opts}, {someMore: 'defaults'});
     myObj.someMember(); 
     //will output 
     //[someClass.someMember] --Fri, 04 Mar 2011 11:53:16 GMT  [ERROR] hello there <--OUTPUT OF LOGLEVEL WILL BE COLORED
     //[someClass.someMember] --Fri, 04 Mar 2011 11:53:16 GMT  [LOG] hello there
     

In Coffeescript:

    nodeBase = require 'path/to/nodeBase.coffee'
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
        someMore: 'defaults'
    myObj.someMember 
    # will output 
    #[someClass.someMember] --Fri, 04 Mar 2011 11:53:16 GMT  [ERROR] hello there <--OUTPUT OF LOGLEVEL WILL BE COLORED
    #[someClass.someMember] --Fri, 04 Mar 2011 11:53:16 GMT  [LOG] hello there    
    
## Reserved words

There are some variable and function names, that you can't use in your derived class, cause the base class is using it.
Those are: this.defaults, this.options, this.emit, this.on, this.log, this.warn, this.info, this.error, this.LOG_LEVELS

## Features

#Logging
- fancy (highly experimental) stack trace extraction
- log levels
- colored output


## Options
you can pass in the following options to your class:

- logging: true/false turns logging on and off (DEFAULT is false)
- logLevel: 'ALL' (same as 'LOG'), 'INFO', 'WARN', 'ERROR' turns logging on and off based on LOGLEVEL (DEFAULT is ALL)
- printLevel: true/false prints the logging level in the output like [WARN]  (DEFAULT is true)
- printContext: true/false prints the current context e.g. the class you are in (DEFAULT is true)

## Using the utility functions
  nodeBase.UUID.uuid()
    "B1BBA3DC-B1DE-477A-9CF8-7DB0000BA766"
  nodeBase.now()
    "Thu, 03 Mar 2011 22:28:39 GMT"
  nodeBase.node_ver
    major: 0
    minor: 4
    release: 1
    
## Running tests

There is merely nothing right now: just type
    cd test
    //for Javascript
    node test
    //for Coffeescript
    node test.coffee

## Credits

- Gregor Schwab &lt;greg@synaptic-labs.net&gt; ([dotmaster](http://github.com/dotmaster))

## License 

(The MIT License)

Copyright (c) 2011 Gregor Schwab &lt;dev@synaptic-labs.net&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
