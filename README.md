NodeBase: A node base class for Javascript and Coffee (logging, options, defaults and EventEmitter)
============================================

This module is the mother of all Objects of my Projects. It adds logging and EventEmitter support that can be turned on and off. An provides with standard options. Feel free to fork this and provide your own implementation. This ships as a coffee version and a JavaScript version. 

## Why?

Cause I find it a cool idea, to have a base class, which solves all the recurring tasks a class must handle in day to day business.

## How to use

To install and run do the following

	git clone https://github.com/dotmaster/nodeBase

### Implementing it on your project

In Javascript:

     var nodeBase = require('../nodeBase'),
     util = require ('util');
     util.inherits(someClass, nodeBase);
     function someClass(){
       nodeBase.apply(this, arguments);
     }
     someClass.prototype.someMember = function(){this.log('hello there')}
 

 
     var myObj = new someClass({logging:true});
     myObj.someMember(); //should output [someClass]  -- Thu, 03 Mar 2011 22:01:29 GMT  hello there

In Coffeescript:

    nodeBase = require '..nodeBase'
    util = require 'util'

    class someClass extends nodeBase
      constructor:(opts) ->
        super(opts)
      someMember: => @log 'hello there'
  
    myObj = new someClass 
      logging: true
    myObj.someMember # should output  [someClass]  -- Thu, 03 Mar 2011 22:01:29 GMT  hello there

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
