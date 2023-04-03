#pragma once

#ifndef INCLUDE_CMODULE_H_
#define INCLUDE_CMODULE_H_

// #include <v8.h>

int main(int argc, char* argv[]);

class cmodule
{
public:

	cmodule();
	~cmodule();

	void setNumber(double val);

	double getNumber();

	double pow2(double val);

	double numMulX(double val);

private:
	double number = {7.456};
};


#endif // INCLUDE_CMODULE_H_
