#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import "PassDataDelegate.h"

@interface BaiduFaceManager : RCTEventEmitter <RCTBridgeModule, PassDataDelegate>

@end
