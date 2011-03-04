var nodeBase = require('../nodeBase'),
 util = require ('util');
 util.inherits(someClass, nodeBase);
 function someClass(){
   this.defaults={
     put:'someDefaultsHere',
     defaults:'canBeOverridden'
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
 

 
 var myObj = new someClass({logging:true, logLevel:'INFO', hello:'opts'}, {evenMore:'defaults', defaults:'willOverride'});
 myObj.someMember(); //should output