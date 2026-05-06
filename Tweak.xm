#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#include <substrate.h>

// ---------------------------------------------------------
// 1. VECTORES DE RETORNO (Obj-C y Swift)
// ---------------------------------------------------------
BOOL return_NO(id self, SEL _cmd) { return NO; }
id return_nil(id self, SEL _cmd) { return nil; }
long long return_1(id self, SEL _cmd) { return 1; }

// Puntero para la función original de Swift
bool (*orig_nextTripRequiresLivenessChallenge)(void* self);

// Función de reemplazo para el bypass facial
bool hook_nextTripRequiresLivenessChallenge(void* self) {
    return false; // Forzamos FALSE a nivel de registro de CPU
}

// ---------------------------------------------------------
// 2. MOTOR DE INYECCIÓN UNIVERSAL
// ---------------------------------------------------------
__attribute__((constructor)) static void apply_tribbu_bypass() {
    
    // --- MÓDULO SWIFT: BYPASS FACIAL ---
    // Buscamos en el ejecutable principal (NULL indica la imagen actual)
    MSImageRef image = MSGetImageByName(NULL);
    if (image) {
        void* symbol = MSFindSymbol(image, "_$s4Hoop11TripManagerC31nextTripRequiresLivenessChallengeSbvg");
        if (symbol) {
            MSHookFunction(symbol, (void*)hook_nextTripRequiresLivenessChallenge, (void**)&orig_nextTripRequiresLivenessChallenge);
        }
    }

    // --- MÓDULO GPS: ENMASCARAMIENTO ---[cite: 2]
    Class targetLocation = NSClassFromString(@"CLLocationSourceInformation");
    if (targetLocation) {
        Method m1 = class_getInstanceMethod(targetLocation, NSSelectorFromString(@"isSimulatedBySoftware"));
        if (m1) method_setImplementation(m1, (IMP)return_NO);

        Method m2 = class_getInstanceMethod(targetLocation, NSSelectorFromString(@"isProducedByAccessory"));
        if (m2) method_setImplementation(m2, (IMP)return_NO);
    }

    // --- MÓDULO RED: REACHABILITY ---[cite: 2]
    Class targetReachability = NSClassFromString(@"Reachability");
    if (targetReachability) {
        Method m3 = class_getClassMethod(targetReachability, NSSelectorFromString(@"reachabilityForLocalWiFi"));
        if (m3) method_setImplementation(m3, (IMP)return_nil);

        Method m4 = class_getInstanceMethod(targetReachability, NSSelectorFromString(@"isReachableViaWiFi"));
        if (m4) method_setImplementation(m4, (IMP)return_NO);

        Method m5 = class_getInstanceMethod(targetReachability, NSSelectorFromString(@"currentReachabilityStatus"));
        if (m5) method_setImplementation(m5, (IMP)return_1);
    }
}
