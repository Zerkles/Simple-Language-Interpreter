#ifndef INSTRUKCJE_H
#define INSTRUKCJE_H
#include <string>
struct instrukcja {
	std::string* nazwa;
	char typ;
	int* arg1;
	int* arg2;
};
#endif
