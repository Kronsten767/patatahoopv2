#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// --- 1. VECTORES DE RETORNO ESTÁTICO ---
BOOL return_NO(id self, SEL _cmd) { return NO; }
id return_nil(id self, SEL _cmd) { return nil; }
long long return_1(id self, SEL _cmd) { return 1; }

// --- 2. MOTOR DE INYECCIÓN (Constructor Estático) ---[cite: 2]
__attribute__((constructor)) static void apply_tribbu_total_bypass() {
    
    // --- MÓDULO 0: BYPASS DE FOTO / LIVENESS (SWIFT BRIDGE) ---
    // En Hoop, el TripManager gestiona si se requiere validación.
    // Intentamos localizar la clase Swift mediante el Runtime.
    Class hoopTripManager = NSClassFromString(@"Hoop.TripManager");
    if (hoopTripManager) {
        // Hookeamos el método que pregunta: "¿Requiere este viaje validación facial?"
        SEL livenessSel = NSSelectorFromString(@"nextTripRequiresLivenessChallenge");
        Method m0 = class_getInstanceMethod(hoopTripManager, livenessSel);
        if (m0) {
            method_setImplementation(m0, (IMP)return_NO);
        }
    }

    // --- MÓDULO 1: ENMASCARAMIENTO GPS ---[cite: 2]
    Class targetLocation = NSClassFromString(@"CLLocationSourceInformation");
    if (targetLocation) {
        Method m1 = class_getInstanceMethod(targetLocation, NSSelectorFromString(@"isSimulatedBySoftware"));
        if (m1) method_setImplementation(m1, (IMP)return_NO);

        Method m2 = class_getInstanceMethod(targetLocation, NSSelectorFromString(@"isProducedByAccessory"));
        if (m2) method_setImplementation(m2, (IMP)return_NO);
    }

    // --- MÓDULO 2: ENMASCARAMIENTO DE RED (REACHABILITY) ---[cite: 2]
    Class targetReachability = NSClassFromString(@"Reachability");
    if (targetReachability) {
        Method m4 = class_getInstanceMethod(targetReachability, NSSelectorFromString(@"isReachableViaWiFi"));
        if (m4) method_setImplementation(m4, (IMP)return_NO);

        Method m5 = class_getInstanceMethod(targetReachability, NSSelectorFromString(@"currentReachabilityStatus"));
        if (m5) method_setImplementation(m5, (IMP)return_1);
    }

    // --- MÓDULO 3: ANTI-SCREENSHOT / RECORDING ---
    // Evita que la app sepa si estás grabando pantalla o haciendo capturas
    Class screenClass = [UIScreen class];
    if (screenClass) {
        Method mCapture = class_getInstanceMethod(screenClass, NSSelectorFromString(@"isCaptured"));
        if (mCapture) method_setImplementation(mCapture, (IMP)return_NO);
    }
}
