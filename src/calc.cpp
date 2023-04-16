#include "calc.h"

void checker(const Napi::CallbackInfo& info) {

	Napi::Env env = info.Env();

	std::string msg = "Number expected";

	if (info.Length() < 2 || !info[0].IsNumber() || !info[1].IsNumber()) {

    Napi::TypeError::New(env, msg).ThrowAsJavaScriptException();
  }

}

Napi::Value Calc(const Napi::CallbackInfo& info) {

	Napi::Env env = info.Env();

	checker(info);

	double a = info[0].As<Napi::Number>().DoubleValue();
  double b = info[1].As<Napi::Number>().DoubleValue();

	double result = a + b;

	return Napi::Number::New(env, result);

}

// Napi::Object Init(Napi::Env env, Napi::Object exports) {

// 	exports.Set("calc", Napi::Function::New(env, Calc));

// 	return exports;
// }
