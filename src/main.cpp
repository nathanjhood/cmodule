#include "main.h"

#ifdef USE_WCHAR
int wmain(int argc, wchar_t* argv[])
{

#else
int main(int argc, char* argv[])
{

#endif // USE_WCHAR

	int e_code = {0};

  std::cout << "Program name is: " << argv[0] << std::endl;

  if (argc == 1) {
    std::cout << "No extra Command Line Argument passed other than program name" << std::endl;

    return e_code = 1;
  }
  else if (argc > 1) {
    std::cout << "Number of arguments passed: " << argc << std::endl;
    std::cout << "----Following are the commnand line arguments passed----" << std::endl;
    for (int i = 0; i < argc; i++) {
      std::cout << "argv[" << i << "]: " << argv[i] << '\n';
    }

    return e_code = 1;
  }
  else {
    std::cout << "No valid Command Line Argument found other than program name" << std::endl;

    return e_code = 0;
  }

  return e_code;
}
