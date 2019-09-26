#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import "PassDataDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

@interface BaiduFaceManager : RCTEventEmitter <RCTBridgeModule, PassDataDelegate>
@property (nonatomic, strong) NSString *accessToken;//访问token
@property (nonatomic, strong) NSDictionary *params;//上传文件需要的参数
@property (nonatomic, strong) RCTPromiseResolveBlock resolve;//成功回调函数
@end
