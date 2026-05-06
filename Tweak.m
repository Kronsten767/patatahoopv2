#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// 1. Declaración manual de MSHookFunction para no necesitar "lo de Cydia" (headers)
// Esto permite que el dylib use el motor de inyección de Swift aunque sea un .m
#ifdef __cplusplus
extern "C" {
#endif
    void MSHookFunction(void *symbol, void *replace, void **result);
    void *MSFindSymbol(void *image, const char *name);
#ifdef __cplusplus
}
#endif

// --- VECTORES DE RETORNO ESTÁTICO ---[cite: 2]
BOOL return_NO(id self, SEL _cmd) { return NO; }
long long return_1(id self, SEL _cmd) { return 1; }

// --- BYPASS SWIFT LIVENESS (FOTO) ---
// Usamos el símbolo exacto del binario Hoop_3[cite: 6]
bool (*orig_liveness)(void* self);
bool hook_liveness(void* self) {
    return false; // Forzamos que NO pida la foto a nivel de CPU
}

// --- MOTOR DE INYECCIÓN ---[cite: 2, 7]
__attribute__((constructor)) static void apply_hoop_master_bypass() {

    // A. SWIFT BYPASS (MÉTODO SEGURO)
    // Buscamos el símbolo que extrajimos de Hoop_3[cite: 6]
    void* symbol = MSFindSymbol(NULL, "_$s4Hoop11TripManagerC31nextTripRequiresLivenessChallengeSbvg");
    if (symbol) {
        // Aunque estemos en un .m, esto inyectará el falso en el núcleo de Swift
        MSHookFunction(symbol, (void*)hook_liveness, (void**)&orig_liveness);
    }

    // B. BYPASS DE INTERFAZ (DISMISS AUTOMÁTICO)
    // Si la pantalla de verificación logra aparecer, la obligamos a cerrarse sola
    Class livenessVC = NSClassFromString(@"Hoop.LivenessViewController");
    if (livenessVC) {
        Method mDidLoad = class_getInstanceMethod(livenessVC, @selector(viewDidAppear:));
        IMP dismissImp = imp_implementationWithBlock(^(id _self, BOOL animated) {
            [(UIViewController *)_self dismissViewControllerAnimated:YES completion:nil];
        });
        method_setImplementation(mDidLoad, dismissImp);
    }

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
}
