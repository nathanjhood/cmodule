#include "../include/cmodule/cmodule.h"

int main(int argc, char* argv[])
{
  return 0;
}



cmodule::cmodule(): number(3.1459)
{

};
cmodule::~cmodule()
{

};

void cmodule::setNumber(double val)
{
	number = val;
};

/* Returns the number stored in the var */
double cmodule::getNumber()
{
  return number;
};

double cmodule::pow2(double val)
{
  return (val * val);
};
double cmodule::numMulX(double val)
{
  return (number * val);
};
