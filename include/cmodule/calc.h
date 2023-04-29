#pragma once

#ifndef CALC_H_INCLUDED
#define CALC_H_INCLUDED

#include <napi.h>

void checker(const Napi::CallbackInfo& info);

Napi::Value Calc(const Napi::CallbackInfo& info);

// Napi::Object Init(Napi::Env env, Napi::Object exports);

// NODE_API_MODULE(calc, Init)

#endif // CALC_H_INCLUDED
