#pragma once

#ifndef MAIN_H_INCLUDED
#define MAIN_H_INCLUDED

#include <napi.h>

#include <iostream>

#ifdef USE_WCHAR
int wmain(int argc, wchar_t* argv[]);

#else
int main(int argc, char* argv[]);

#endif // USE_WCHAR


#endif // MAIN_H_INCLUDED
