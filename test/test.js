var nodeBase = require("../index"), 
 util = require(process.binding('natives').util ? 'util' : 'sys');
 util.inherits(someClass, nodeBase);
 
 //you need to add these lines to get static logging functions working 
 someClass.defaults = { logging:true }
 nodeBase.static(someClass) //add static functions
 var log= someClass.log
 
 function someClass(){
   this.defaults={
     put:'someDefaultsHere',
     defaults:'canNotBeOverridden'
   }   
   nodeBase.apply(this, arguments);
  this.info('wow this is cool');
 }
 someClass.prototype.someMember = function(){
   this.log('hello there');
   this.info('hello there');
   this.warn('hello there');
   this.error('hello there');         
  }
 

 
 var myObj = new someClass({logging:true, logLevel:'INFO', hello:'opts'});
 myObj.on('error', function(err){log('emitted error', JSON.stringify(err))})
 myObj.someMember(); 
 
 log ('Number of Objects created ' + someClass.getTotalIds())
 //should output
 //[new someClass] --Fri, 04 Mar 2011 11:53:16 GMT  [INFO] wow this is cool <--OUTPUT OF LOGLEVEL WILL BE COLORED
 //[someClass.someMember] --Fri, 04 Mar 2011 11:53:16 GMT  [INFO] hello there
 //[someClass.someMember] --Fri, 04 Mar 2011 11:53:16 GMT  [WARN] hello there
 //[someClass.someMember] --Fri, 04 Mar 2011 11:53:16 GMT  [ERROR] hello there