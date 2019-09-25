//
//  IDLFaceDetectionManager.h
//  IDLFaceSDK
//
//  Created by Tong,Shasha on 2017/5/18.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@class FaceInfo;

#define TIME_THRESHOLD_FOR_ANOTHER_SESSION 2.0

typedef NS_ENUM(NSUInteger, DetectRemindCode) {
    DetectRemindCodeOK = 0, //成功
    DetectRemindCodePitchOutofDownRange = 1,    //头部偏低
    DetectRemindCodePitchOutofUpRange = 2,  //头部偏高
    DetectRemindCodeYawOutofLeftRange = 3,  //头部偏左
    DetectRemindCodeYawOutofRightRange = 4, //头部偏右
    DetectRemindCodePoorIllumination = 5,   //光照不足
    DetectRemindCodeNoFaceDetected = 6, //没有检测到人脸
    DetectRemindCodeDataHitOne,
    DetectRemindCodeDataHitLast,
    DetectRemindCodeImageBlured,    //图像模糊
    DetectRemindCodeOcclusionLeftEye,   //左眼有遮挡
    DetectRemindCodeOcclusionRightEye,  //右眼有遮挡
    DetectRemindCodeOcclusionNose, //鼻子有遮挡
    DetectRemindCodeOcclusionMouth,    //嘴巴有遮挡
    DetectRemindCodeOcclusionLeftContour,  //左脸颊有遮挡
    DetectRemindCodeOcclusionRightContour, //右脸颊有遮挡
    DetectRemindCodeOcclusionChinCoutour,  //下颚有遮挡
    DetectRemindCodeTooClose,  //太近
    DetectRemindCodeTooFar,    //太远
    DetectRemindCodeBeyondPreviewFrame,    //出框
    DetectRemindCodeVerifyInitError,          //鉴权失败
    DetectRemindCodeVerifyDecryptError,
    DetectRemindCodeVerifyInfoFormatError,
    DetectRemindCodeVerifyExpired,
    DetectRemindCodeVerifyMissRequiredInfo,
    DetectRemindCodeVerifyInfoCheckError,
    DetectRemindCodeVerifyLocalFileError,
    DetectRemindCodeVerifyRemoteDataError,
    DetectRemindCodeTimeout,   //超时
    DetectRemindCodeConditionMeet
};


typedef NS_ENUM(NSUInteger, TrackDetectRemindCode) {
    TrackDetectRemindCodeOK = 0, //成功
    TrackDetectRemindCodeImageBlured, //图像模糊
    TrackDetectRemindCodePoorIllumination, // 光照不足
    TrackDetectRemindCodeNoFaceDetected, //没有检测到人脸
    TrackDetectRemindCodeOcclusionLeftEye,   //左眼有遮挡
    TrackDetectRemindCodeOcclusionRightEye,  //右眼有遮挡
    TrackDetectRemindCodeOcclusionNose, //鼻子有遮挡
    TrackDetectRemindCodeOcclusionMouth,    //嘴巴有遮挡
    TrackDetectRemindCodeOcclusionLeftContour,  //左脸颊有遮挡
    TrackDetectRemindCodeOcclusionRightContour, //右脸颊有遮挡
    TrackDetectRemindCodeOcclusionChinCoutour,  //下颚有遮挡
    TrackDetectRemindCodeTooClose,  //太近
    TrackDetectRemindCodeTooFar,    //太远
    TrackDetectRemindCodeBeyondPreviewFrame   //出框
    
};

typedef void (^DetectStrategyCompletion) (FaceInfo * faceinfo,NSDictionary * images, DetectRemindCode remindCode);

typedef void (^TrackDetectStrategyCompletion) (FaceInfo * faceinfo, TrackDetectRemindCode remindCode);

@interface IDLFaceDetectionManager : NSObject

@property (nonatomic, assign) BOOL enableSound;

+ (instancetype)sharedInstance;

/*带黑边的方法*/
- (void)detectStratrgyWithQualityControlImage:(UIImage *)image previewRect:(CGRect)previewRect detectRect:(CGRect)detectRect completionHandler:(DetectStrategyCompletion)completion;

/*不带黑边*/
- (void)detectStratrgyWithNormalImage:(UIImage *)image previewRect:(CGRect)previewRect detectRect:(CGRect)detectRect completionHandler:(DetectStrategyCompletion)completion;

- (void)detectMultiFacesImage:(UIImage *)image withMaxFaceCount:(NSInteger)maxFaceCount handler:(TrackDetectStrategyCompletion)completion;

- (void)reset;

-(void)startInitial;

@end
