debugger;
var nodeBase = require('../nodeBase'),
 util = require ('util');
 util.inherits(someClass, nodeBase);
 function someClass(){
   this.defaults={
     some:'defaults',
     defaults:'canNotBeOverridden'
   }   
   nodeBase.apply(this, arguments);
 }
 someClass.prototype.someMember = function(){this.log('hello there')}
 

 
 var myObj = new someClass({logging:true, hello:'opts'}, {evenMore:'defaults', defaults:'canBeOverridden'});
 myObj.someMember(); //should output