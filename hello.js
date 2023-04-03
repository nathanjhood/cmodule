var addon = require('bindings')('cmodule');

console.log(addon.hello()); // 'world'
