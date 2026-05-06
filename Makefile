ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = TRIBBU
# Asegúrate de que el archivo en tu repo se llame Tweak.xm
TRIBBU_FILES = Tweak.xm
TRIBBU_CFLAGS = -fobjc-arc
TRIBBU_FRAMEWORKS = Foundation
TRIBBU_LIBRARIES = substrate

# FIX CRÍTICO: Resuelve el error "Shared cache eligible dylib cannot link to ineligible dylib"
TRIBBU_LDFLAGS = -Wl,-not_for_dyld_shared_cache

include $(THEOS_MAKE_PATH)/library.mk
