#pragma once

#ifndef VALUE_H_INCLUDED
#define VALUE_H_INCLUDED

#include <napi.h>

#include "mathconstants.h"

class Val
{
public:
	Val();
	~Val();

	Napi::Number getPi();

	Napi::Number getEuler();

private:
	Napi::Number pi;
	Napi::Number euler;
};



#endif // VALUE_H_INCLUDED
