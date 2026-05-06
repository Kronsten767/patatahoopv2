ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = TRIBBU
TRIBBU_FILES = Tweak.m
TRIBBU_CFLAGS = -fobjc-arc
TRIBBU_FRAMEWORKS = Foundation UIKit
TRIBBU_LDFLAGS = -Wl,-segalign,4000 -Wl,-not_for_dyld_shared_cache

include $(THEOS_MAKE_PATH)/library.mk
