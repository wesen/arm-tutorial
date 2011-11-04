#include <stdlib.h>

/* no dynamic allocation */
void *operator new(size_t size) throw() { return NULL; }
void operator delete(void *p) throw() { }

extern "C" int __aeabi_atexit(void *object,
                              void (*destructor)(void *),
                              void *dso_handle) {
  return 0;
}
