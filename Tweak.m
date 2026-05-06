#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// --- 1. DECLARACIONES PARA INYECCIÓN SWIFT ---[cite: 7]
#ifdef __cplusplus
extern "C" {
#endif
    void MSHookFunction(void *symbol, void *replace, void **result);
    void *MSFindSymbol(void *image, const char *name);
#ifdef __cplusplus
}
#endif

// --- 2. VECTORES DE RETORNO ---[cite: 2]
BOOL return_NO(id self, SEL _cmd) { return NO; }
long long return_1(id self, SEL _cmd) { return 1; }

// ID de hardware falso para evitar rastreo/baneos
id fake_device_id(id self, SEL _cmd) {
    return [[NSUUID alloc] initWithUUIDString:@"A1B2C3D4-E5F6-4789-90AB-CDEF12345678"];
}

// --- 3. LOGICA DE BYPASS SWIFT ---
bool (*orig_liveness)(void* self);
bool hook_liveness(void* self) {
    return false; // El servidor pide foto -> El Dylib dice NO.
}

// --- 4. MOTOR MAESTRO DE INYECCIÓN ---
__attribute__((constructor)) static void apply_hoop_complete_bypass() {

    // A. BYPASS FACIAL (MÉTODO DUAL)
    // Nivel 1: Variable lógica de Swift[cite: 6]
    void* livenessSym = MSFindSymbol(NULL, "_$s4Hoop11TripManagerC31nextTripRequiresLivenessChallengeSbvg");
    if (livenessSym) {
        MSHookFunction(livenessSym, (void*)hook_liveness, (void**)&orig_liveness);
    }
    // Nivel 2: Interfaz de usuario (Auto-dismiss)[cite: 1]
    Class livenessVC = NSClassFromString(@"Hoop.LivenessViewController");
    if (livenessVC) {
        method_setImplementation(class_getInstanceMethod(livenessVC, @selector(viewDidAppear:)), 
        imp_implementationWithBlock(^(id _self, BOOL animated) {
            [(UIViewController *)_self dismissViewControllerAnimated:YES completion:nil];
        }));
    }

    // B. SPOOFING DE HARDWARE (IDENTIFIER FOR VENDOR)
    method_setImplementation(class_getInstanceMethod([UIDevice class], @selector(identifierForVendor)), (IMP)fake_device_id);

    // C. ENMASCARAMIENTO GPS[cite: 2]
    Class locInfo = NSClassFromString(@"CLLocationSourceInformation");
    if (locInfo) {
        method_setImplementation(class_getInstanceMethod(locInfo, NSSelectorFromString(@"isSimulatedBySoftware")), (IMP)return_NO);
        method_setImplementation(class_getInstanceMethod(locInfo, NSSelectorFromString(@"isProducedByAccessory")), (IMP)return_NO);
    }

    // D. ENMASCARAMIENTO DE RED[cite: 2]
    Class reach = NSClassFromString(@"Reachability");
    if (reach) {
        method_setImplementation(class_getInstanceMethod(reach, NSSelectorFromString(@"isReachableViaWiFi")), (IMP)return_NO);
        method_setImplementation(class_getInstanceMethod(reach, NSSelectorFromString(@"currentReachabilityStatus")), (IMP)return_1);
    }

    // E. BYPASS DE DETECCIÓN DE GRABACIÓN / SCREENSHOT
    method_setImplementation(class_getInstanceMethod([UIScreen class], @selector(isCaptured)), (IMP)return_NO);

    // F. ANTI-TAMPER (OCULTAR RUTA DE SIDELOAD)
    method_setImplementation(class_getInstanceMethod([NSFileManager class], @selector(fileExistsAtPath:)), (IMP)return_NO);
}
