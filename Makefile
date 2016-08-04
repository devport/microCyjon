# it's alive

ASM=nasm -f bin
BOOTLOADER=bootloader
BUILD=build

all:
#	$(ASM) kernel.asm			-o build/kernel.bin

	$(ASM) $(BOOTLOADER)/stage2.asm	-o build/stage2.bin
	$(ASM) $(BOOTLOADER)/stage1.asm	-o $(BUILD)/image.omega

	rm -f	$(BUILD)/stage2.bin
