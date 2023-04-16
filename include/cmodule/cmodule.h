#pragma once

#ifndef INCLUDE_CMODULE_H_
#define INCLUDE_CMODULE_H_

#include <napi.h>

#include "calc.h"

static Napi::String Method(const Napi::CallbackInfo& info);

static Napi::Object Init(Napi::Env env, Napi::Object exports);

NODE_API_MODULE(cmodule, Init)

#endif // INCLUDE_CMODULE_H_
