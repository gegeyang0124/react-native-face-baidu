//
//  BaiduFace.m
//  BaiduFace
//
//  Created by xieyang on 2018/8/3.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "BaiduFace.h"

#import "IDLFaceSDK/IDLFaceSDK.h"
#import "FaceParameterConfig.h"

@implementation BaiduFace

+ (void)initSDK {
//    NSBundle *assetBundle = [NSBundle bundleForClass:[self class]];
//    NSString *bundlePath = [assetBundle pathForResource:@"BaiduFace" ofType:@"bundle"];
//    if (bundlePath) {
//        assetBundle = [NSBundle bundleWithPath:bundlePath];
//    }
//
//    NSString* licensePath = [assetBundle pathForResource:FACE_LICENSE_NAME ofType:FACE_LICENSE_SUFFIX];
//    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:licensePath], @"license文件路径不对，请仔细查看文档");
//    NSString *faceLicenseId = [assetBundle objectForInfoDictionaryKey:FACE_LICENSE_ID];
//    [[FaceSDKManager sharedInstance] setLicenseID:faceLicenseId andLocalLicenceFile:licensePath];
    
//    NSString* licensePath = [[NSBundle mainBundle] pathForResource:FACE_LICENSE_NAME ofType:FACE_LICENSE_SUFFIX];
    NSString* licensePath = [ [NSBundle bundleForClass:[self class]] pathForResource:FACE_LICENSE_NAME ofType:FACE_LICENSE_SUFFIX];
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:licensePath], @"license文件路径不对，请仔细查看文档");
//    NSString *faceLicenseId = [[NSBundle mainBundle] objectForInfoDictionaryKey:FACE_LICENSE_ID];
    [[FaceSDKManager sharedInstance] setLicenseID:FACE_LICENSE_ID andLocalLicenceFile:licensePath];
    NSLog(@"canWork = %d",[[FaceSDKManager sharedInstance] canWork]);
    NSLog(@"version = %@",[[FaceVerifier sharedInstance] getVersion]);
}

@end



