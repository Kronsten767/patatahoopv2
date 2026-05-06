ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = TRIBBU

# Usamos Tweak.m para mantener tu estructura de Objective-C puro
TRIBBU_FILES = Tweak.m
TRIBBU_CFLAGS = -fobjc-arc
TRIBBU_FRAMEWORKS = Foundation UIKit

# Importante: Aunque sea un .m, para que el bypass de Swift (la cara) 
# funcione mediante MSHookFunction, el linker necesita substrate.
TRIBBU_LIBRARIES = substrate

# FIX: Este flag evita el error de compilación en GitHub Actions 
# (Shared cache eligible dylib cannot link to ineligible dylib)
TRIBBU_LDFLAGS = -Wl,-not_for_dyld_shared_cache -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/library.mk
