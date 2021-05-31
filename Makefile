# Build docker envirorment: docker build buildenv -t my-os
# Run docker envirorment:
# --- Mac OS: docker run --rm -it -v /Users/toto/Documents/Programming/OS/MyOS:/root/env my-os
# --- Windows: docker run --rm -it -v "%cd%":/root/env my-os

x86_64_kernel_linker_file := src/kernel/linker.ld

NASM := nasm
CC := gcc
LD := ld

SFLAGS := -f elf64
CFLAGS := -mcmodel=large -c -Isrc/kernel/include/ --freestanding
CDEFINES := -D OS_DEBUG
LDFLAGS := -n -nostdlib -T $(x86_64_kernel_linker_file)

x86_64_asm_kernel_source_files := $(shell find src/kernel -name *.asm)
x86_64_asm_kernel_object_files := $(patsubst src/kernel/%.asm, build/kernel/%.o, $(x86_64_asm_kernel_source_files))

x86_64_c_kernel_source_files := $(shell find src/kernel -name *.c)
x86_64_c_kernel_object_files := $(patsubst src/kernel/%.c, build/kernel/%.o, $(x86_64_c_kernel_source_files))

x86_64_kernel_object_files := $(x86_64_asm_kernel_object_files) $(x86_64_c_kernel_object_files)

$(x86_64_asm_kernel_object_files) : build/kernel/%.o : $(x86_64_asm_kernel_object_files)
	mkdir -p $(dir $@) && \
	$(NASM) $(SFLAGS) $(patsubst build/kernel/%.o, src/kernel/%.asm, $@) -o $@

$(x86_64_c_kernel_object_files) : build/kernel/%.o : $(x86_64_c_kernel_source_files)
	mkdir -p $(dir $@) && \
	$(CC) $(CFLAGS) $(CDEFINES) $(patsubst build/kernel/%.o, src/kernel/%.c, $@) -o $@

dist/kernel.bin: $(x86_64_kernel_object_files)
	mkdir -p dist && \
	$(LD) $(LDFLAGS) -o $@ $^

dist/image.iso: dist/kernel.bin
	mkdir -p dist && \
	cp $^ sysroot/boot/ && \
	grub-mkrescue /usr/lib/grub/i386-pc -o $@ sysroot

clean:
	rm -r build
	rm -r dist
