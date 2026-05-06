ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = TRIBBU
# Volvemos a .m para usar Objective-C puro sin Cydia
TRIBBU_FILES = Tweak.m
TRIBBU_CFLAGS = -fobjc-arc
TRIBBU_FRAMEWORKS = Foundation UIKit

include $(THEOS)/makefiles/library.mk
