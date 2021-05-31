#include <stdint.h>

#include <memory.h>

void kernel_main()
{
    *(uint64_t*)(0xB8000 + KERNEL_OFFSET) = 0x2f592f412f4b2f4f;

    while (1);
}