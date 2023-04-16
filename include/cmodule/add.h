#pragma once

#ifndef ADD_H_INCLUDED
#define ADD_H_INCLUDED

#include <napi.h>

Napi::Value Add(const Napi::CallbackInfo& info);

// Napi::Object Init(Napi::Env env, Napi::Object exports);

// NODE_API_MODULE(add, Init)

#endif // ADD_H_INCLUDED
