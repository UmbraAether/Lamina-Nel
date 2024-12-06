GPPPARAMS = -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore
ASPARAMS = --32
LDPARAMS = -melf_i386

objects = loader.o kernel.o

%.o: %.cpp
		g++ $(GPPPARAMS) -o $@ -c $<
%.o: %.s
		as $(ASPARAMS) -o $@ $<

NoxKernel.bin: linker.ld $(objects)
		ld $(LDPARAMS) -T $< -o $@ $(objects)

install: NoxKernel.bin
		sudo cp $< /boot/NoxKernel.bin

clean:
	@echo "Running clean..."
	@for file in $(objects) NoxKernel.bin; do \
		if [ -e "$$file" ]; then \
			echo "Removing $$file"; \
			rm "$$file"; \
		else \
			echo "$$file not found, nothing to clean."; \
		fi; \
	done

run: NoxKernel.bin
	qemu-system-i386 -kernel ~/NoxSystemsProjects/Lamina/NoxKernel.bin
