# Copyright 2005 The Android Open Source Project

LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
	builtins.c \
	init.c \
	devices.c \
	property_service.c \
	util.c \
	parser.c \
	logo.c \
	keychords.c \
	signal_handler.c \
	init_parser.c \
	ueventd.c \
	ueventd_parser.c

ifeq ($(strip $(INIT_BOOTCHART)),true)
LOCAL_SRC_FILES += bootchart.c
LOCAL_CFLAGS    += -DBOOTCHART=1
endif

ifeq ($(TARGET_HAS_ANCIENT_MSMCAMERA), true)
    LOCAL_CFLAGS += -DNO_MSM_CAMDIR
endif

ifeq ($(BOARD_PROVIDES_BOOTMODE), true)
    LOCAL_CFLAGS += -DBOARD_PROVIDES_BOOTMODE
endif

ifneq ($(TARGET_RECOVERY_PRE_COMMAND),)
	LOCAL_CFLAGS += -DRECOVERY_PRE_COMMAND='$(TARGET_RECOVERY_PRE_COMMAND)'
endif

ifeq ($(BOARD_HAS_EXTRA_SYS_PROPS), true)
    LOCAL_CFLAGS += -DBOARD_HAS_EXTRA_SYS_PROPS
endif

LOCAL_MODULE:= init

LOCAL_FORCE_STATIC_EXECUTABLE := true
LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT)
LOCAL_UNSTRIPPED_PATH := $(TARGET_ROOT_OUT_UNSTRIPPED)

LOCAL_STATIC_LIBRARIES := libcutils libc

include $(BUILD_EXECUTABLE)

# Make a symlink from /sbin/ueventd to /init
SYMLINKS := $(TARGET_ROOT_OUT)/sbin/ueventd
$(SYMLINKS): INIT_BINARY := $(LOCAL_MODULE)
$(SYMLINKS): $(LOCAL_INSTALLED_MODULE) $(LOCAL_PATH)/Android.mk
	@echo "Symlink: $@ -> ../$(INIT_BINARY)"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf ../$(INIT_BINARY) $@

ALL_DEFAULT_INSTALLED_MODULES += $(SYMLINKS)

# We need this so that the installed files could be picked up based on the
# local module name
ALL_MODULES.$(LOCAL_MODULE).INSTALLED := \
    $(ALL_MODULES.$(LOCAL_MODULE).INSTALLED) $(SYMLINKS)
