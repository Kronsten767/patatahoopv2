ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = Hoop

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TRIBBU_JB
TRIBBU_JB_FILES = Tweak.xm
TRIBBU_JB_CFLAGS = -fobjc-arc
TRIBBU_JB_FRAMEWORKS = UIKit Foundation
TRIBBU_JB_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk
