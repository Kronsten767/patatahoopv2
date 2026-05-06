#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// Vectores de retorno nativos para el Runtime[cite: 2]
BOOL return_NO(id self, SEL _cmd) { return NO; }
long long return_1(id self, SEL _cmd) { return 1; }
id fake_id(id self, SEL _cmd) { return [[NSUUID alloc] initWithUUIDString:@"E621E1F8-C36C-495A-93FC-0C247A3E6E5F"]; }

__attribute__((constructor)) static void load_tribbu_bypass() {
    
    // 1. BYPASS CARA: Dismiss automático de la UI[cite: 1]
    Class liveness = NSClassFromString(@"Hoop.LivenessViewController");
    if (liveness) {
        method_setImplementation(class_getInstanceMethod(liveness, @selector(viewDidAppear:)), 
        imp_implementationWithBlock(^(id _self, BOOL animated) {
            [(UIViewController *)_self dismissViewControllerAnimated:YES completion:nil];
        }));
    }

    // 2. BYPASS GPS: Ocultar simulación de software[cite: 2]
    Class locInfo = NSClassFromString(@"CLLocationSourceInformation");
    if (locInfo) {
        method_setImplementation(class_getInstanceMethod(locInfo, NSSelectorFromString(@"isSimulatedBySoftware")), (IMP)return_NO);
        method_setImplementation(class_getInstanceMethod(locInfo, NSSelectorFromString(@"isProducedByAccessory")), (IMP)return_NO);
    }

    // 3. BYPASS RED: Reachability forzado[cite: 2]
    Class reach = NSClassFromString(@"Reachability");
    if (reach) {
        method_setImplementation(class_getInstanceMethod(reach, NSSelectorFromString(@"currentReachabilityStatus")), (IMP)return_1);
        method_setImplementation(class_getInstanceMethod(reach, NSSelectorFromString(@"isReachableViaWiFi")), (IMP)return_NO);
    }

    // 4. SPOOF HARDWARE ID: Identificador único falso
    method_setImplementation(class_getInstanceMethod([UIDevice class], @selector(identifierForVendor)), (IMP)fake_id);

    // 5. PRIVACIDAD: Bloqueo de detección de grabación
    method_setImplementation(class_getInstanceMethod([UIScreen class], @selector(isCaptured)), (IMP)return_NO);
}
