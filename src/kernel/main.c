#include <stdint.h>

#define KERNEL_OFFSET 0xFFFFFF8000000000

void kernel_main()
{
    *(uint64_t*)(0xB8000 + KERNEL_OFFSET) = 0x2f592f412f4b2f4f;

    while (1);
}