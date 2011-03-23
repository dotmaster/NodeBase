#a capped hash collection   
#a capped hash collection   
class CappedObject extends require('events').EventEmitter
  constructor: (max, baseClass)->
    if not (baseClass or typeof baseClass is 'function') then throw Error "[CappedObject] #{baseClass} is not a function. Must be a constructor function!"    
    @max = max 
    @name = baseClass.name
    @base = baseClass
    @dropped = false
    @Collection = {};
    @_byFIFO=[];   
    @_getLast = -> @_byFIFO.pop()
    @removeCount = 0
  remove: (obj) ->  
      if @Collection[obj._id] #don't remove Objects that aren't in the collection if we call remove more than one time don't augment the counter
        ++@removeCount
        delete @Collection[obj._id] #delete from collection , but not from fifo (track over removeCount) to avoid sliceing
        @base.emit 'remove', obj
  addId: (obj) ->
   if @Collection[obj._id] then return @base.warn "[CappedObject.addId] Object already in collection returning" #if the object is already in the collection return but warn
   @_byFIFO.unshift(obj)
   @Collection[obj._id] = obj #insert the Object at id into the hash

   @base.emit 'add', obj
   #if we exceeded the maximum size remove the last element
   if @max and @_byFIFO.length - @removeCount > @max  
     #lookup the lastobject in the collection
     while true #loop popping objects till we find an object we haven't already removed
       pop = @_getLast()
       if @Collection[pop._id] then break else --@removeCount
     delete @Collection[pop._id]
     @base.emit 'remove', pop
     @base.emit 'drop', pop
     @base.warn "[CappedObject] CAP LIMIT REACHED! Dropping object #{pop._id} of collection #{@name}" #global[name] is the static log function to call
     @base.dropped = true #set to true cause we started drppng elements
  getId: (id) ->
    if not @Collection[id] and @dropped then global[name].error "[CappedObject] the object #{id} was not found in the collection, this might be due to dropped elements!"
    return @Collection[id] 
  
  getNumberOfObjects: ->
    @_byFIFO.length - @removeCount

  getObjectIds: ->
    key for obj of @Collection
    
module.exports = CappedObject