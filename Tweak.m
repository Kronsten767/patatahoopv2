#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// --- DECLARACIONES DE MOTOR DE INYECCIÓN ---[cite: 7]
#ifdef __cplusplus
extern "C" {
#endif
    void MSHookFunction(void *symbol, void *replace, void **result);
    void *MSFindSymbol(void *image, const char *name);
#ifdef __cplusplus
}
#endif

// --- VECTORES DE RETORNO ---[cite: 2]
BOOL return_NO(id self, SEL _cmd) { return NO; }
long long return_1(id self, SEL _cmd) { return 1; }
id fake_UUID(id self, SEL _cmd) { return [[NSUUID alloc] initWithUUIDString:@"A1B2C3D4-E5F6-4789-90AB-CDEF12345678"]; }

// --- HOOK SWIFT (FOTO) ---
bool (*orig_liveness)(void* self);
bool hook_liveness(void* self) {
    return false; // El motor Swift recibe: "No hace falta foto"
}

// --- CONSTRUCTOR MAESTRO ---[cite: 2, 7, 9]
__attribute__((constructor)) static void apply_hoop_v3_bypass() {

    // 1. CAPA LÓGICA (Swift): Anula la necesidad de validación facial[cite: 6]
    void* symbol = MSFindSymbol(NULL, "_$s4Hoop11TripManagerC31nextTripRequiresLivenessChallengeSbvg");
    if (symbol) {
        MSHookFunction(symbol, (void*)hook_liveness, (void**)&orig_liveness);
    }

    // 2. CAPA UI (Objective-C): Cierre forzado si la cámara intenta abrirse
    Class livenessVC = NSClassFromString(@"Hoop.LivenessViewController");
    if (livenessVC) {
        Method mDidAppear = class_getInstanceMethod(livenessVC, @selector(viewDidAppear:));
        if (mDidAppear) {
            method_setImplementation(mDidAppear, imp_implementationWithBlock(^(id _self, BOOL animated) {
                [(UIViewController *)_self dismissViewControllerAnimated:YES completion:nil];
            }));
        }
    }

    // 3. MÓDULO PRIVACIDAD Y HARDWARE (Spoofing)[cite: 2, 9]
    // Cambia el ID del iPhone para evitar baneos de hardware
    method_setImplementation(class_getInstanceMethod([UIDevice class], @selector(identifierForVendor)), (IMP)fake_UUID);
    // Oculta si la pantalla está siendo grabada
    method_setImplementation(class_getInstanceMethod([UIScreen class], @selector(isCaptured)), (IMP)return_NO);

    // 4. MÓDULO GPS (Enmascaramiento de simulación)[cite: 2]
    Class locSource = NSClassFromString(@"CLLocationSourceInformation");
    if (locSource) {
        method_setImplementation(class_getInstanceMethod(locSource, NSSelectorFromString(@"isSimulatedBySoftware")), (IMP)return_NO);
        method_setImplementation(class_getInstanceMethod(locSource, NSSelectorFromString(@"isProducedByAccessory")), (IMP)return_NO);
    }

    // 5. MÓDULO RED Y ANTI-DETECCIÓN[cite: 2, 9]
    // Engaña a 'Reachability' para reportar WiFi siempre activo
    Class reach = NSClassFromString(@"Reachability");
    if (reach) {
        method_setImplementation(class_getInstanceMethod(reach, NSSelectorFromString(@"currentReachabilityStatus")), (IMP)return_1);
    }
    // Oculta archivos de Feather/Jailbreak ante NSFileManager
    method_setImplementation(class_getInstanceMethod([NSFileManager class], @selector(fileExistsAtPath:)), (IMP)return_NO);
}
