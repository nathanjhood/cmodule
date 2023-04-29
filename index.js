#!/usr/bin/env node

const cmodule = require("./support/node/js/bindings")("cmodule");
module.exports = cmodule;
