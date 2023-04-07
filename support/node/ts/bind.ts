const addon = require('../build/Release/napi-module-native');

interface INapiModuleNative
{
    greet(strName: string): string;
};

class NapiModule {
    constructor(name: string) {
        this._addonInstance = new addon.NapiModule(name)
    }

    greet (strName: string) {
        return this._addonInstance.greet(strName);
    }

    // private members
    private _addonInstance: INapiModuleNative;
}

export = NapiModule;
