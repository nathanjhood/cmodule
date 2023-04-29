"use strict";
const addon = require('../build/Release/napi-module-native');

class NapiModule {
    constructor(name) {
        this._addonInstance = new addon.NapiModule(name);
    }
    greet(strName) {
        return this._addonInstance.greet(strName);
    }
}
module.exports = NapiModule;
