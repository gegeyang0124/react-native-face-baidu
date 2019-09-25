#import <math.h>
#import "BaiduFaceManager.h"
#import <UIKit/UIKit.h>
#import "LivenessViewController.h"
#import "DetectionViewController.h"
#import "LivingConfigModel.h"
#import "IDLFaceSDK/IDLFaceSDK.h"
#import "FaceParameterConfig.h"
#import <React/RCTUtils.h>

@implementation BaiduFaceManager

- (void)passData:(NSDictionary *)data {
    [self sendEventWithName:@"complete" body:data];
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"complete", @"success"];
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_MODULE(BaiduFace)

- (NSDictionary *)constantsToExport {
    return @{
             @"LivenessType":@{ @"Eye":@(FaceLivenessActionTypeLiveEye),
                                @"Mouth":@(FaceLivenessActionTypeLiveMouth),
                                @"HeadLeft":@(FaceLivenessActionTypeLiveYawLeft),
                                @"HeadRight":@(FaceLivenessActionTypeLiveYawRight),
                                @"HeadLeftOrRight":@(FaceLivenessActionTypeLiveYaw),
                                @"HeadUp":@(FaceLivenessActionTypeLivePitchUp),
                                @"HeadDown":@(FaceLivenessActionTypeLivePitchDown) }
            };
}

// 人脸跟踪检测
RCT_EXPORT_METHOD(detect)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        DetectionViewController* dvc = [[DetectionViewController alloc] init];
        dvc.delegate = self;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:dvc];
        navi.navigationBarHidden = true;
        UIWindow *window = RCTSharedApplication().delegate.window;
        [[window rootViewController] presentViewController:navi animated:true completion:nil];
    });
}

// 活体检测
RCT_EXPORT_METHOD(liveness)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        LivenessViewController* lvc = [[LivenessViewController alloc] init];
        lvc.delegate = self;
        LivingConfigModel* model = [LivingConfigModel sharedInstance];
        [lvc livenesswithList:model.liveActionArray order:model.isByOrder numberOfLiveness:model.numOfLiveness];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:lvc];
        navi.navigationBarHidden = true;
        UIWindow *window = RCTSharedApplication().delegate.window;
        [[window rootViewController] presentViewController:navi animated:true completion:nil];
    });
}

RCT_REMAP_METHOD(config, config:(nullable NSDictionary *) config)
{
    if(config == nil) {
        [self sendEventWithName:@"success" body:@YES];
        return;
    }

    id livenessRandom = [config valueForKey:@"livenessRandom"];
    if (livenessRandom != nil) {
        LivingConfigModel.sharedInstance.isByOrder = ![livenessRandom boolValue];
    }

    NSMutableArray *livenessTypeList = [config mutableArrayValueForKey:@"livenessTypeList"];
    if (livenessTypeList != nil && livenessTypeList.count > 0) {
        [LivingConfigModel.sharedInstance.liveActionArray removeAllObjects];
        for (NSObject *livenessType in livenessTypeList) {
            [LivingConfigModel.sharedInstance.liveActionArray addObject:livenessType];
        }
    }

    id livenessRandomCount = [config valueForKey:@"livenessRandomCount"];
    if (livenessRandom != nil) {
        long total = [LivingConfigModel.sharedInstance.liveActionArray count];
        long count = [livenessRandomCount longValue];
        LivingConfigModel.sharedInstance.numOfLiveness = fmaxl(fminl(count, total), 1);
    }

    [self sendEventWithName:@"success" body:@YES];
}

@end
