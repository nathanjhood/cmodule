#include "add.h"

Napi::Value Add(const Napi::CallbackInfo& info) {

  Napi::Env env = info.Env();

	if (info.Length() < 2 || !info[0].IsNumber() || !info[1].IsNumber()) {

    Napi::TypeError::New(env, "Number expected").ThrowAsJavaScriptException();

    return env.Null();
  }

	double a = info[0].As<Napi::Number>().DoubleValue();
  double b = info[1].As<Napi::Number>().DoubleValue();
  double sum = a + b;

	return Napi::Number::New(env, sum);
}

// Napi::Object Init(Napi::Env env, Napi::Object exports) {

// 	exports.Set("add", Napi::Function::New(env, Add));

// 	return exports;
// }
