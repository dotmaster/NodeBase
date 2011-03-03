var nodeBase = require('../nodeBase'),
 util = require ('util');
 util.inherits(someClass, nodeBase);
 function someClass(){
   this.defaults={
     put:'someDefaultsHere',
     defaults:'canBeOverridden'
   }   
   nodeBase.apply(this, arguments);
 }
 someClass.prototype.someMember = function(){this.log('hello there')}
 

 
 var myObj = new someClass({logging:true, hello:'opts'}, {evenMore:'defaults', defaults:'willOverride'});
 myObj.someMember(); //should output