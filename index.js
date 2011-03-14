require('coffee-script')
module.exports = require('./nodeBase-coffee')
merge = module.exports.merge 
merge(module.exports, require('./sha1'))