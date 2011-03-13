NodeBase: A node base class for Javascript and Coffeescript (logging, options, defaults and EventEmitter)
============================================

This module is the mother of all Objects of my Projects. It adds logging facility (with log levels, colored output and fancy stacktrace extraction of the current function you are in) that can be turned on and off and EventEmitter support. It provides with standard options and also provide some utility functions (namely now, merge, uuid and node_ver). Feel free to fork this and provide your own implementation. This ships as a coffee version and a JavaScript version. 

NOTE: As of version 0.5.0 development is just done in Coffeescript!


## Why?

a) Cause I find it a cool idea, to have a base class, which solves all the recurring tasks a class must handle in day to day business.

b) In nearly all node projects classes inherit often from the EventEmitter Object. However this is not enough base functionality. You can use this class everywhere you would use EventEmitter and get fancy logging, options and defaults for free!

## How to use

To install and run do the following

	git clone https://github.com/dotmaster/nodeBase
	
or

  npm install nodeBase

### Implementing it on your project

In Javascript: 

     var nodeBase = require('path/to/nodeBase'),
     util = require ('util');
     
     util.inherits(someClass, nodeBase);
     function someClass(opts){
       this.defaults={
          put:'someDefaultsHere'
        }
       nodeBase.apply(this, arguments); //pass the opts to the parrent constructor, will set this.options as a mixin of defaults and opts
     }
     someClass.prototype.someMember = function(){
       this.error('hello there')
       this.log('hello there')
     }
 
     //then somewhere in your code
 
     var myObj = new someClass({logging:true, logLevel: 'WARN', some: opts}, {someMore: 'defaults'});
     myObj.someMember(); 
     //will output 
     //[someClass.someMember id:1] --Fri, 04 Mar 2011 11:53:16 GMT  [ERROR] hello there
     //[someClass.someMember id:1] --Fri, 04 Mar 2011 11:53:16 GMT  [LOG] hello there
                ^             ^                                       ^
                |             |                                       |
            the class   the object id                   OUTPUT OF LOGLEVEL WILL BE COLORED
        and member function  
        
In Coffeescript:

There are tow ways to implement NodeBase:
a) Inheritance

    nodeBase = require 'path/to/nodeBase/'
    util = require 'util'

    class someClass extends nodeBase
      constructor:(opts) ->
        @defaults =
          put:'someDefaultsHere'
        super(opts) #pass options to super, will set @options as a mixin of defaults and opts, no need to pass defaulkts here
      someMember: => @log 'hello there'
  
    myObj = new someClass 
      logging: true
      some:'opts',
        someMore: 'defaults'
    myObj.someMember 
    # will output 
    #[someClass.someMember id:1] --Fri, 04 Mar 2011 11:53:16 GMT  [ERROR] hello there
    #[someClass.someMember id:1] --Fri, 04 Mar 2011 11:53:16 GMT  [LOG] hello there    

b) as a mixin (beginning from version 0.6.0)
    nodeBase = require 'path/to/nodeBase/'
    util = require(if process.binding('natives').util then 'util' else 'sys')
    
    #make a static logging shortcut
    log = -> filteredClient.log arguments...
    
    #class has another base class than nodeBase already
    class filteredClient extends Client
      #add some static class defaults
      @defaults: 
        logging:true
      nodeBase.static(@); #add static @options and @defaults to class
      constructor:(opts) -> #pass in some object level options and the defaults
        #add some object level defaults
        @defaults =
          put:'someDefaultsHere'
        #must call the constructor before mixing in nodeBase! (to reduce risk of potentially shallowing constructor functions of Client)
        super(arguments...)
        #nodeBase as a mixin, using merge is better then just saying @[i]=n[i]
        NodeBase.merge @[i] ||= {} = n[i] for i, val of n = new nodeBase(opts,@defaults) #remember to pass the defaults
      register: => #some member functions
      
      myObj = new filteredClient 
        logging: true
        logLevel: 'WARN'
        some:'opts'

      myObj.register()
            
      #will output
      #[new filteredClient id:1]  -- Mon, 07 Mar 2011 12:52:08 GMT  [ERROR] awesome!!!
      #[filteredClient.register id:1]  -- Mon, 07 Mar 2011 12:52:08 GMT  [WARN] hello there

    
## Reserved words

There are some variable and function names, that you can't use in your derived class, cause the base class is using it.
Those are: this.defaults, this.options, this.emit, this.on, this.log, this.warn, this.info, this.error, this.LOG_LEVELS, this._uuid, this._cid_, this._getTotalCids, this._addContext (despite this.constructor)

## Features

### Logging
- fancy (highly experimental) stack trace extraction
- log levels
- colored output
- as of version 0.5.0 introduced static logging (see test directory for usage)

### Auto Id and Uuid creation for objects
- every new object gets a uuid and a id (starting from 1) stored unde _uuid and _id

### Global cache of objects created (highly experimental)
- version 0.5.0 has a global object cache (with a custom capped collection implementation to avoid memory leaks)


## Options and Defaults
you can pass in the following defaults to your class:

- logging: true/false turns logging on and off (DEFAULT is false)
- logLevel: 'ALL' (same as 'LOG'), 'INFO', 'WARN', 'ERROR' turns logging on and off based on LOGLEVEL (DEFAULT is ALL)
- printLevel: true/false prints the logging level in the output like [WARN]  (DEFAULT is true)
- printContext: true/false prints the current context e.g. the class you are in (DEFAULT is true)
- useStack: true/false extracts function name from Stacktrace (highly experimental) for printing out the current context (DEFAULT is true)
- emitLog: true/false if to emit the log messages as an event of form ('level', {message: logMessage, data:anyObj}) (DEFAULT is true)
- autoId, autoUuid: true/false if to generate an Id, Uuid for each object (DEFAULT is true)
- addToCollection: true/false if to turn on the global caching (DEFAULT is false)

## Using the utility functions
  nodeBase.uuid()
    "B1BBA3DC-B1DE-477A-9CF8-7DB0000BA766"
  nodeBase.now()
    "Thu, 03 Mar 2011 22:28:39 GMT"
  nodeBase.node_ver
    major: 0
    minor: 4
    release: 1
    
## Running tests

NodeBase has been tested against version node >0.2.0 (only compiled Javascript version)

There is merely nothing right now: just type
    cd test
    //for Javascript
    node test
    //for Coffeescript
    node test.coffee
    
Furthermore there are some performance tests regarding the Cache implementation [www.perf.com/browse/Gregor]  (http://www.perf.com/browse/Gregor)

## Todo
- eventually export log functions also statically
- feel free to extend NodeBase in whatever way you want. E.g. a database logger, config reader and writer, etc.
- eventually add an option for a static objects lookup function (danger of memory leak though)


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
