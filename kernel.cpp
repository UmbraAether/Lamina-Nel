#include "gdt.h"
#include "types.h"
void printf(const char *str) {
  static uint16_t *VideoMemory = (uint16_t *)0xb8000;

  for (int32_t i = 0; str[i] != '\0'; i++)
    VideoMemory[i] = (VideoMemory[i] & 0xFF00) | str[i];
}

typedef void (*constructor)();
extern "C" constructor start_ctors;
extern "C" constructor end_ctors;
extern "C" void callConstructors() {
  for (constructor *i = &start_ctors; i != &end_ctors; i++)
    (*i)();
}

extern "C" void kernelMain(void *multiboot_structure, uint32_t magicNumber) {
  printf("Hello world!\n");

  GlobalDescriptorTable gdt;

  while (1)
    ;
}
