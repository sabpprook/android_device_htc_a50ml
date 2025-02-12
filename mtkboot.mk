define make_header
  perl -e 'print pack("a4 L a32 a472", "\x88\x16\x88\x58", $$ARGV[0], $$ARGV[1], "\xFF"x472)' $(1) $(2) > $(3)
endef

# this is overriding targets from build/core/Makefile
$(PRODUCT_OUT)/recovery_kernel.mtk.header: $(INSTALLED_KERNEL_TARGET)
	size=$$($(call get-file-size,$(INSTALLED_KERNEL_TARGET))); \
		$(call make_header, $$((size)), "KERNEL", $@)

$(PRODUCT_OUT)/recovery_kernel.mtk: $(PRODUCT_OUT)/recovery_kernel.mtk.header
	$(call pretty,"Adding MTK header to recovery kernel.")
	cat $(PRODUCT_OUT)/recovery_kernel.mtk.header $(recovery_kernel) > $@

$(recovery_ramdisk).mtk.header: $(recovery_ramdisk)
	size=$$($(call get-file-size,$(recovery_ramdisk))); \
		$(call make_header, $$((size)), "RECOVERY", $@)

$(recovery_ramdisk).mtk:  $(MKBOOTIMG) $(recovery_ramdisk).mtk.header
	$(call pretty,"Adding MTK header to recovery ramdisk.")
	cat $(recovery_ramdisk).mtk.header $(recovery_ramdisk) > $@

INTERNAL_MTK_RECOVERYIMAGE_ARGS := \
	--kernel $(PRODUCT_OUT)/recovery_kernel.mtk \
	--ramdisk $(recovery_ramdisk).mtk \
	--cmdline "$(BOARD_KERNEL_CMDLINE)" \
	--base $(BOARD_KERNEL_BASE) \
	--pagesize $(BOARD_KERNEL_PAGESIZE)

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) \
	$(recovery_ramdisk).mtk $(PRODUCT_OUT)/recovery_kernel.mtk
	$(MKBOOTIMG) $(INTERNAL_MTK_RECOVERYIMAGE_ARGS) \
		$(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@, \
		$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
