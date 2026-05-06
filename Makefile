ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = TRIBBU
# Asegúrate de que el archivo se llame Tweak.xm para soportar C++ y Cydia Substrate
TRIBBU_FILES = Tweak.xm
TRIBBU_CFLAGS = -fobjc-arc
TRIBBU_FRAMEWORKS = Foundation
# Esto es vital para dispositivos sin Jailbreak (Sideloading)
TRIBBU_LIBRARIES = substrate

include $(THEOS)/makefiles/library.mk
