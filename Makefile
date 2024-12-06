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
		@mkdir -p iso/boot/grub/
		@cp NoxKernel.bin iso/boot/
		@cp grub.cfg iso/boot/grub/
		@grub-mkrescue -o NoxKernel.iso iso

clean:
	@echo "Running clean..."
	@for file in $(objects) NoxKernel.bin iso/boot/NoxKernel.bin NoxKernel.iso iso/boot/grub/grub.cfg; do \
		if [ -e "$$file" ]; then \
			echo "Removing $$file"; \
			rm "$$file"; \
		else \
			echo "$$file not found, nothing to clean."; \
		fi; \
	done

run: NoxKernel.bin
	qemu-system-i386 -cdrom NoxKernel.iso -no-reboot -net none

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
