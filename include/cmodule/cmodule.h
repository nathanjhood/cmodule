#pragma once

#ifndef INCLUDE_CMODULE_H_
#define INCLUDE_CMODULE_H_

// #include <node.h>

// #include <napi.h>

// int main(int argc, char* argv[]);

// class cmodule
// {
// public:

// 	cmodule();
// 	~cmodule();

// 	void setNumber(double val);

// 	double getNumber();

// 	double pow2(double val);

// 	double numMulX(double val);

// private:
// 	double number = {7.456};
// };

#include <napi.h>



static Napi::String Method(const Napi::CallbackInfo& info);

static Napi::Object Init(Napi::Env env, Napi::Object exports);

NODE_API_MODULE(hello, Init)

#endif // INCLUDE_CMODULE_H_
