#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#include <substrate.h>

// --- VECTORES DE RETORNO ESTÁTICO (Obj-C) ---[cite: 2]
BOOL return_NO(id self, SEL _cmd) { return NO; }
id return_nil(id self, SEL _cmd) { return nil; }
long long return_1(id self, SEL _cmd) { return 1; }

// --- BYPASS SWIFT (Validación Facial) ---
bool (*orig_nextTripRequiresLivenessChallenge)(void* self);
bool hook_nextTripRequiresLivenessChallenge(void* self) {
    return false; // Forzamos retorno Falso en el registro x0 de la CPU
}

// --- MOTOR DE INYECCIÓN (Constructor) ---[cite: 2]
__attribute__((constructor)) static void apply_tribbu_bypass() {
    
    // 1. Bypass de Swift (Liveness) - Para iPhone 11-17
    MSImageRef image = MSGetImageByName(NULL);
    if (image) {
        void* symbol = MSFindSymbol(image, "_$s4Hoop11TripManagerC31nextTripRequiresLivenessChallengeSbvg");
        if (symbol) {
            MSHookFunction(symbol, (void*)hook_nextTripRequiresLivenessChallenge, (void**)&orig_nextTripRequiresLivenessChallenge);
        }
    }

    // 2. Módulo GPS (Existente)[cite: 2]
    Class targetLocation = NSClassFromString(@"CLLocationSourceInformation");
    if (targetLocation) {
        Method m1 = class_getInstanceMethod(targetLocation, NSSelectorFromString(@"isSimulatedBySoftware"));
        if (m1) method_setImplementation(m1, (IMP)return_NO);

        Method m2 = class_getInstanceMethod(targetLocation, NSSelectorFromString(@"isProducedByAccessory"));
        if (m2) method_setImplementation(m2, (IMP)return_NO);
    }

    // 3. Módulo Red (Existente)[cite: 2]
    Class targetReachability = NSClassFromString(@"Reachability");
    if (targetReachability) {
        Method m4 = class_getInstanceMethod(targetReachability, NSSelectorFromString(@"isReachableViaWiFi"));
        if (m4) method_setImplementation(m4, (IMP)return_NO);

        Method m5 = class_getInstanceMethod(targetReachability, NSSelectorFromString(@"currentReachabilityStatus"));
        if (m5) method_setImplementation(m5, (IMP)return_1);
    }
}
