#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// --- VECTORES DE RETORNO NATIVOS ---
BOOL return_NO(id self, SEL _cmd) { return NO; }
BOOL return_YES(id self, SEL _cmd) { return YES; }
long long return_1(id self, SEL _cmd) { return 1; }
id fake_id(id self, SEL _cmd) { return [[NSUUID alloc] initWithUUIDString:@"A1B2C3D4-E5F6-4789-90AB-CDEF12345678"]; }

// --- MOTOR DE FUERZA BRUTA (ESCÁNER LÓGICO) ---
// Escanea una clase y hackea cualquier método relacionado con validación facial
void bypassLivenessLogicInClass(NSString *className) {
    Class cls = NSClassFromString(className);
    if (!cls) return;
    
    unsigned int count = 0;
    Method *methods = class_copyMethodList(cls, &count);
    for (unsigned int i = 0; i < count; i++) {
        Method m = methods[i];
        NSString *name = NSStringFromSelector(method_getName(m));
        NSString *lowerName = name.lowercaseString;
        
        // Buscar palabras clave de validación en el código interno
        if ([lowerName containsString:@"liveness"] || [lowerName containsString:@"face"] || [lowerName containsString:@"photo"]) {
            char retType[256];
            method_getReturnType(m, retType, 256);
            
            // Si el método devuelve un Booleano ('c' o 'B' en Objective-C runtime)
            if (retType[0] == 'c' || retType[0] == 'B') {
                if ([lowerName containsString:@"require"] || [lowerName containsString:@"need"] || [lowerName containsString:@"challenge"]) {
                    method_setImplementation(m, (IMP)return_NO); // Anula la necesidad
                } else if ([lowerName containsString:@"pass"] || [lowerName containsString:@"success"] || [lowerName containsString:@"valid"]) {
                    method_setImplementation(m, (IMP)return_YES); // Fuerza el éxito
                }
            }
        }
    }
    free(methods);
}

__attribute__((constructor)) static void load_tribbu_master_bypass() {
    
    // 1. EJECUCIÓN DEL ESCÁNER DE LÓGICA SOBRE CLASES CLAVE
    bypassLivenessLogicInClass(@"Hoop.TripManager");
    bypassLivenessLogicInClass(@"Hoop.SessionManager");
    bypassLivenessLogicInClass(@"Hoop.LivenessViewController");
    
    // 2. ATAQUE DIRECTO AL SELECTOR CONOCIDO (Por si el escáner lo omite)
    Class tripManager = NSClassFromString(@"Hoop.TripManager");
    if (tripManager) {
        SEL livenessSel = NSSelectorFromString(@"nextTripRequiresLivenessChallenge");
        if (class_getInstanceMethod(tripManager, livenessSel)) {
            method_setImplementation(class_getInstanceMethod(tripManager, livenessSel), (IMP)return_NO);
        }
    }

    // 3. BYPASS DE INTERFAZ (AUTODESTRUCCIÓN DE CÁMARA)
    // Si la lógica falla y la ventana intenta abrirse, la cerramos limpiamente
    Class livenessVC = NSClassFromString(@"Hoop.LivenessViewController");
    if (livenessVC) {
        method_setImplementation(class_getInstanceMethod(livenessVC, @selector(viewWillAppear:)), 
        imp_implementationWithBlock(^(id _self, BOOL animated) {
            UIViewController *vc = (UIViewController *)_self;
            // Detectar si está en un menú de navegación o es un popup flotante
            if (vc.navigationController) {
                [vc.navigationController popViewControllerAnimated:NO];
            } else {
                [vc dismissViewControllerAnimated:NO completion:nil];
            }
        }));
    }

    // 4. BYPASS DE GPS Y MASCARADA DE RED
    Class locInfo = NSClassFromString(@"CLLocationSourceInformation");
    if (locInfo) {
        method_setImplementation(class_getInstanceMethod(locInfo, NSSelectorFromString(@"isSimulatedBySoftware")), (IMP)return_NO);
        method_setImplementation(class_getInstanceMethod(locInfo, NSSelectorFromString(@"isProducedByAccessory")), (IMP)return_NO);
    }
    
    Class reach = NSClassFromString(@"Reachability");
    if (reach) {
        method_setImplementation(class_getInstanceMethod(reach, NSSelectorFromString(@"currentReachabilityStatus")), (IMP)return_1);
        method_setImplementation(class_getInstanceMethod(reach, NSSelectorFromString(@"isReachableViaWiFi")), (IMP)return_NO);
    }

    // 5. PROTECCIÓN DE HARDWARE E IDENTIDAD
    method_setImplementation(class_getInstanceMethod([UIDevice class], @selector(identifierForVendor)), (IMP)fake_id);
    method_setImplementation(class_getInstanceMethod([UIScreen class], @selector(isCaptured)), (IMP)return_NO);
}
