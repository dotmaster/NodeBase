(function() {
  var CHARS, Cache, CappedCollection, L, LL, NodeBase, UUID, addId, arrize, cid, cids, colors, events, getTotalCids, glue, merge, node_ver, now, stylize, util;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __slice = Array.prototype.slice;
  events = require('events');
  util = require(process.binding('natives').util ? 'util' : 'sys');
  Error.stackTraceLimit = 50;
  L = 0;
  LL = {
    ALL: L++,
    LOG: L++,
    INFO: L++,
    WARN: L++,
    ERROR: L++
  };
  for (L in LL) {
    LL[LL[L]] = L;
  }
  /*
   @desc this is the mother of all Objects; a node Base Class with (logging and options, defaults)
    NodeBase is an EventEmitter
  */
  NodeBase = (function() {
    __extends(NodeBase, events.EventEmitter);
    NodeBase.now = now;
    NodeBase.static = function(superClass) {
      var i, val, _ref;
      for (i in NodeBase) {
        if (!__hasProp.call(NodeBase, i)) continue;
        val = NodeBase[i];
        (_ref = superClass[i]) != null ? _ref : superClass[i] = NodeBase[i];
      }
      return merge(superClass.options || (superClass.options = {}), superClass.defaults);
    };
    NodeBase.defaults = {
      logging: false,
      logLevel: 'ALL',
      printLevel: true,
      printContext: true,
      useStack: true
    };
    NodeBase.options = NodeBase.defaults;
    NodeBase.merge = merge;
    NodeBase.mixin = merge;
    NodeBase.extend = merge;
    NodeBase.node_ver = node_ver;
    NodeBase.lookupId = function(id) {
      var _ref, _ref2;
      if (this.name != null) {
        return (_ref = Cache[this.name]) != null ? _ref.getId(id) : void 0;
      } else {
        return (_ref2 = Cache['NodeBase']) != null ? _ref2.getId(id) : void 0;
      }
    };
    NodeBase.Cache = function() {
      var _ref, _ref2;
      if (this.name != null) {
        return (_ref = Cache[this.name]) != null ? _ref.Collection : void 0;
      } else {
        return (_ref2 = Cache['NodeBase']) != null ? _ref2.Collection : void 0;
      }
    };
    NodeBase.getTotalIds = function() {
      if (this.name != null) {
        return cids[this.name] || 0;
      } else {
        return cids['NodeBase'] || 0;
      }
    };
    NodeBase.log = function() {
      if (this.options.logging && this._checkLogLevel('LOG')) {
        return console.log(this._addContext.apply(this, __slice.call(arguments).concat(['LOG'])));
      }
    };
    NodeBase.warn = function() {
      if (this.options.logging && this._checkLogLevel('WARN')) {
        return console.log(this._addContext.apply(this, __slice.call(arguments).concat(['WARN'])));
      }
    };
    NodeBase.info = function() {
      if (this.options.logging && this._checkLogLevel('INFO')) {
        return console.log(this._addContext.apply(this, __slice.call(arguments).concat(['INFO'])));
      }
    };
    NodeBase.error = function() {
      if (this.options.logging && this._checkLogLevel('ERROR')) {
        return console.log(this._addContext.apply(this, __slice.call(arguments).concat(['ERROR'])));
      }
    };
    NodeBase._checkLogLevel = function(level) {
      return LL[this.options.logLevel] <= LL[level];
    };
    NodeBase._addContext = function() {
      var args, level, message, stack, _i;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), level = arguments[_i++];
      if ((level != null) && this.options.printLevel) {
        args.unshift(stylize(level));
      }
      stack = this.name + ' static';
      return message = "[" + stack + "]  -- " + (now()) + "  " + (args.join(' '));
    };
    function NodeBase(opts) {
      this.error = __bind(this.error, this);;
      this.info = __bind(this.info, this);;
      this.warn = __bind(this.warn, this);;
      this.log = __bind(this.log, this);;
      this._addContext = __bind(this._addContext, this);;
      this.NodeBase = __bind(this.NodeBase, this);;
      this.NodeBase = __bind(this.NodeBase, this);;
      this.NodeBase = __bind(this.NodeBase, this);;
      this.NodeBase = __bind(this.NodeBase, this);;
      this.NodeBase = __bind(this.NodeBase, this);;      var self;
      NodeBase.__super__.constructor.call(this);
      self = this;
      merge(this.defaults || (this.defaults = {}), {
        logging: false,
        logLevel: 'ALL',
        printLevel: true,
        printContext: true,
        useStack: true,
        emitLog: true,
        autoId: true,
        autoUuid: true,
        cacheSize: 5,
        addToCollection: false
      }, this.defaults);
      merge(this.options || (this.options = {}), this.defaults, this.constructor.defaults, opts);
      this.LOG_LEVELS = LL;
      this._checkLogLevel = function(level) {
        return LL[this.options.logLevel] <= LL[level];
      };
      if (this.options.autoId) {
        this._id = cid(this);
      }
      if (this.options.autoUuid) {
        this._uuid = UUID.uuid();
      }
      if (this.options.autoId) {
        this._getTotalIds = function() {
          return getTotalIds(this);
        };
      }
      if (this.options.addToCollection) {
        addId(this);
      }
    }
    NodeBase.prototype._addContext = function() {
      var args, id, level, message, reg, stack, stackArray, _i;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), level = arguments[_i++];
      if ((level != null) && this.options.printLevel) {
        args.unshift(stylize(level));
      }
      try {
        reg = new RegExp(/at\s(.*)\s\(/g);
        stackArray = new Error().stack.split(reg);
        if (this.options.useStack) {
          stack = stackArray[9].indexOf('new') === -1 && stackArray[11].indexOf('anonymous') === -1 ? stackArray[11] : stackArray[9];
        }
      } catch (e) {

      }
      stack != null ? stack : stack = this.constructor.name;
      if (this.options.autoId) {
        id = " id:" + this._id;
      }
      message = "[" + (stack + id) + "]  -- " + (now()) + "  " + (args.join(' '));
      if (this.options.emitLog) {
        this.emit(level, {
          'message': message,
          'data': args.slice(1, args.length)
        });
      }
      return message;
    };
    NodeBase.prototype.log = function() {
      if (this.options.logging && this._checkLogLevel('LOG')) {
        return console.log(this._addContext.apply(this, __slice.call(arguments).concat(['LOG'])));
      }
    };
    NodeBase.prototype.warn = function() {
      if (this.options.logging && this._checkLogLevel('WARN')) {
        return console.log(this._addContext.apply(this, __slice.call(arguments).concat(['WARN'])));
      }
    };
    NodeBase.prototype.info = function() {
      if (this.options.logging && this._checkLogLevel('INFO')) {
        return console.log(this._addContext.apply(this, __slice.call(arguments).concat(['INFO'])));
      }
    };
    NodeBase.prototype.error = function() {
      if (this.options.logging && this._checkLogLevel('ERROR')) {
        return console.log(this._addContext.apply(this, __slice.call(arguments).concat(['ERROR'])));
      }
    };
    return NodeBase;
  })();
  module.exports = NodeBase;
  module.exports.LOG_LEVELS = LL;
  module.exports.now = now = function() {
    return new Date().toUTCString();
  };
  /*
  module.exports.options = options = (opts, mergeOpts..., self) ->
    if self instanceof NodeBase
      # if we are called from this
      self.options = merge opts or= {}, mergeOpts or= {}
    else
      merge opts or= {}, mergeOpts or= {}
  */
  module.exports.merge = merge = __bind(function() {
    var args, obj, prop, source, _i, _len;
    obj = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      source = args[_i];
      for (prop in source) {
        obj[prop] = source[prop];
      }
    }
    return obj;
  }, this);
  node_ver = null;
  (function() {
    var matches, rex, ver;
    if (node_ver != null) {
      return node_ver;
    }
    ver = process.version;
    rex = /^v(\d+)\.(\d+)\.(\d+)/i;
    matches = ver.match(rex);
    if (matches == null) {
      throw "Unable to determine node version";
    }
    return node_ver = {
      major: ~~matches[1],
      minor: ~~matches[2],
      release: ~~matches[3]
    };
  })();
  module.exports.node_ver = node_ver;
  arrize = function(ary, from) {
    if (from == null) {
      from = 0;
    }
    return Array.prototype.slice.call(ary, from);
  };
  glue = function() {
    var f, oargs, obj;
    f = arguments[0], obj = arguments[1], oargs = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    return function() {
      var iargs;
      iargs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return typeof f.apply == "function" ? f.apply(obj, oargs.concat(iargs)) : void 0;
    };
  };
  NodeBase.glue = module.exports.glue = glue;
  /*
    Code taken from Robert Kieffer UUID

    Math.uuid.js (v1.4)
    http://www.broofa.com
    mailto:robert@broofa.com

    Copyright (c) 2010 Robert Kieffer
    Dual licensed under the MIT and GPL licenses.


    A UUID GENERATROR FUNCTION
    Private array of chars to use
   */
  CHARS = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
  UUID = {};
  UUID.uuid = function(len, radix) {
    var chars, i, r, uuid, _ref;
    if (radix == null) {
      radix = CHARS.length;
    }
    chars = CHARS;
    uuid = [];
    if (len != null) {
      for (i = 0; (0 <= len ? i <= len : i >= len); (0 <= len ? i += 1 : i -= 1)) {
        uuid[i] = chars[0 | Math.random() * radix];
      }
    } else {
      r;
      uuid[8] = uuid[13] = uuid[18] = uuid[23] = '-';
      uuid[14] = '4';
      for (i = 0; i <= 36; i++) {
        if (!uuid[i]) {
          r = 0 | Math.random() * 16;
          uuid[i] = chars[((_ref = i === 19) != null) ? _ref : r & 0x3 | {
            0x8: r
          }];
        }
      }
    }
    return uuid.join('');
  };
  NodeBase.uuid = UUID.uuid;
  module.exports.UUID = UUID;
  cids = {};
  cid = function(obj) {
    if ((obj != null ? obj.constructor.name : void 0) != null) {
      return ++cids[obj.constructor.name] || (cids[obj.constructor.name] = 1);
    } else {
      return ++cids['NodeBase'] || (cids['NodeBase'] = 1);
    }
  };
  getTotalCids = function(obj) {
    if ((obj != null ? obj.constructor.name : void 0) != null) {
      return cids[obj.constructor.name] || 0;
    } else {
      return cids['NodeBase'] || 0;
    }
  };
  CappedCollection = (function() {
    __extends(CappedCollection, Array);
    function CappedCollection(max, key) {
      this.max = max;
      this.key = key != null ? key : '_id';
      this.Collection = [];
      this._byFIFO = [];
      this._getLast = function() {
        return this._byFIFO.pop();
      };
      this.comparator = __bind(function(value) {
        return value._id;
      }, this);
    }
    CappedCollection.prototype.addId = function(obj) {
      var index, lastIndex;
      this._byFIFO.unshift(obj);
      index = this._sortedIndex(this.Collection, obj, this.comparator);
      this.Collection.splice(index, 0, obj);
      if (this.max && this.Collection.length > this.max) {
        lastIndex = this._sortedIndex(this.Collection, this._getLast(), this.comparator);
        return this.Collection.splice(lastIndex, 1);
      }
    };
    CappedCollection.prototype.getId = function(id) {
      var index;
      index = this._nearestObjAtIndex(this.Collection, id, this.comparator);
      if (this.Collection[index][this.key] === id) {
        return this.Collection[index];
      } else {
        return;
      }
    };
    CappedCollection.prototype._sortedIndex = function(array, obj, comparator) {
      var high, low, mid;
      comparator || (comparator = function(value) {
        return value;
      });
      low = 0;
      high = array.length;
      while (low < high) {
        mid = (low + high) >> 1;
        if (comparator(array[mid]) < comparator(obj)) {
          low = mid + 1;
        } else {
          high = mid;
        }
      }
      return low;
    };
    CappedCollection.prototype._nearestObjAtIndex = function(array, id, comparator) {
      var high, low, mid;
      comparator || (comparator = function(value) {
        return value;
      });
      low = 0;
      high = array.length;
      while (low < high) {
        mid = (low + high) >> 1;
        if (comparator(array[mid]) < id) {
          low = mid + 1;
        } else {
          high = mid;
        }
      }
      return low;
    };
    return CappedCollection;
  })();
  Cache = {};
  addId = function(obj) {
    var _name, _ref, _ref2;
    if ((obj != null ? obj.constructor.name : void 0) != null) {
      return ((_ref = Cache[_name = obj.constructor.name]) != null ? _ref : Cache[_name] = new CappedCollection()).addId(obj);
    } else {
      return ((_ref2 = Cache['NodeBase']) != null ? _ref2 : Cache['NodeBase'] = new CappedCollection()).addId(obj);
    }
  };
  NodeBase.cid = cid;
  stylize = function(level) {
    var levelStylesMapping, style, styles;
    styles = {
      'bold': [1, 22],
      'italic': [3, 23],
      'underline': [4, 24],
      'inverse': [7, 27],
      'white': [37, 39],
      'grey': [90, 39],
      'black': [30, 39],
      'blue': [34, 39],
      'cyan': [36, 39],
      'green': [32, 39],
      'magenta': [35, 39],
      'red': [31, 39],
      'yellow': [33, 39]
    };
    levelStylesMapping = {
      'WARN': 'magenta',
      'ERROR': 'red',
      'INFO': 'cyan',
      'LOG': 'green'
    };
    style = levelStylesMapping[level];
    if (style) {
      return '\033[' + styles[style][0] + 'm' + '[' + level + ']' + '\033[' + styles[style][1] + 'm';
    } else {
      return str;
    }
  };
  if (typeof global != "undefined" && global !== null) {
    colors = true;
  } else {
    stylize = function(level) {
      return '[' + level + '] ';
    };
  }
}).call(this);
