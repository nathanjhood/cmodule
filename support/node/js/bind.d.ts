declare class NapiModule {
    constructor(name: string);
    greet(strName: string): string;
    private _addonInstance;
}
export = NapiModule;
