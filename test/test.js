debugger;
var nodeBase = require('../nodeBase'),
 util = require ('util');
 util.inherits(someClass, nodeBase);
 function someClass(){
   nodeBase.apply(this, arguments);
 }
 someClass.prototype.someMember = function(){this.log('hello there')}
 

 
 var myObj = new someClass({logging:true});
 myObj.someMember(); //should output