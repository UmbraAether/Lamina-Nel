GPPPARAMS = -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore
ASPARAMS = --32
LDPARAMS = -melf_i386

objects = loader.o kernel.o

%.o: %.cpp
	@echo "Compiling $<..."
	@g++ $(GPPPARAMS) -o $@ -c $< 2>> >(while read line; do echo "$(shell date): $$line" >> general.log; done) || \
	{ echo "$(shell date): Compilation failed for $<! Check general.log for details."; exit 1; }

%.o: %.s
	@echo "Assembling $<..."
	@as $(ASPARAMS) -o $@ $< 2>> >(while read line; do echo "$(shell date): $$line" >> general.log; done) || \
	{ echo "$(shell date): Assembly failed for $<! Check general.log for details."; exit 1; }

NoxKernel.bin: linker.ld $(objects)
	@echo "Linking [$(objects)] using $< script."
	@ld $(LDPARAMS) -T $< -o $@ $(objects) 2>> >(while read line; do echo "$(shell date): $$line" >> general.log; done) || \
	{ echo "$(shell date): Linking failed! Check general.log for details."; exit 1; }


install: NoxKernel.bin
		@mkdir -p iso/boot/grub/
		@cp NoxKernel.bin iso/boot/
		@cp grub.cfg iso/boot/grub/
		@grub-mkrescue -o NoxKernel.iso iso

clean:
	@echo "Cleaning project..."
	@for file in $(objects) NoxKernel.bin iso/boot/NoxKernel.bin NoxKernel.iso iso/boot/grub/grub.cfg general.log; do \
		if [ -e "$$file" ]; then \
			echo "Removing $$file"; \
			rm "$$file"; \
		fi; \
	done
	@echo "Cleaning complete."

run: NoxKernel.iso
	@if [ -e NoxKernel.iso ]; then \
		echo "$(shell date): Starting QEMU with NoxKernel.iso..." >> general.log; \
		qemu-system-i386 -cdrom NoxKernel.iso -no-reboot -net none || { \
			echo "$(shell date): QEMU failed to start! Did u run 'make install'." >> general.log; \
			exit 1; \
		}; \
	else \
		echo "$(shell date): Error: NoxKernel.iso not found. Cannot run QEMU." >> general.log; \
		echo "Error: NoxKernel.iso not found. Cannot run QEMU."; \
		exit 1; \
	fi

install-deps:
	@echo "Detecting package manager..."
	@echo ""
	@if command -v pacman >/dev/null; then \
		echo "Pacman detected! Installing dependencies..."; \
		echo ""; \
		sudo -v && sudo pacman -S --needed gcc binutils grub mtools xorriso qemu --noconfirm; \
	elif command -v apt >/dev/null; then \
		echo "APT detected! Installing dependencies..."; \
		echo ""; \
		sudo -v && sudo apt update && sudo apt install -y gcc binutils grub-pc-bin mtools xorriso qemu-system-i386; \
	else \
		echo "Unsupported package manager. Please install dependencies manually."; \
		echo "Needed dependencies: [ gcc, binutils, grub, mtools, xorriso, qemu-system-i386 ]"; \
		exit 1; \
	fi
