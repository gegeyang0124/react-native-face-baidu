//
//  FaceRecognize.h
//  FaceSDK
//
//  Created by Tong,Shasha on 2017/11/13.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger ,FaceLicenseStatus) {
    FaceLicenseStatusSuccess = 0,
    FaceLicenseStatusInitError,
    FaceLicenseStatusDecryptError,
    FaceLicenseStatusInfoFormatError,
    FaceLicenseStatusExpired,
    FaceLicenseStatusRequiredInfo,
    FaceLicenseStatusCheckError,
    FaceLicenseStatusLocalFileError,
    FaceLicenseStatusRemoteDataError
};

typedef NS_ENUM(NSUInteger ,FaceRecognizeType) {
    FaceRecognizeTypeIDPhoto = 0,
    FaceRecognizeTypeLive,
    FaceRecognizeTypeNIR
};

@interface FaceRecognize : NSObject

/**
 *  初始化方法
 *
 *  @return 实例化
 */
+ (FaceRecognize *_Nonnull)sharedInstance;


/**
 *  初始化离线识别模型并使用相对识别模式
 *
 *  @param type 离线识别模型类型
 */
- (void)initModelWithRecognizeType:(FaceRecognizeType)type;

/**
 *  SDK鉴权方法
 *  SDK鉴权方法 必须在使用其他方法之前设置，否则会导致SDK不可用
 *
 *  @param licenseId 鉴权api key
 *  @param localLicencePath 本地鉴权文件路径
 */
- (void)setLicenseID:(NSString *_Nonnull)licenseId
     andLocalLicenceFile:(NSString *_Nonnull)localLicencePath;

/**
 *  SDK是否可用
 *  如果可用返回结果为0
 *
 *  @return SDK可用结果
 */
- (FaceLicenseStatus)canWork;

/**
 *  开启网络鉴权
 *  默认开启
 *
 *  @param remoteAuthorize 是否开启网络鉴权
 */
- (void)setRemoteAuthorize:(BOOL)remoteAuthorize;

/**
 *  人脸特征提取
 *
 *  @param image             图像
 *  @param minSize           最小检测人脸大小 推荐值100
 *  @return                  人脸特征数据
 */
- (NSData *_Nullable)extractFeatureWithImage:(UIImage *_Nonnull)image
                             minFaceSize:(int)minSize;

/**
 *  人脸特征提取
 *  需要传入获取的图像特征点坐标数据
 *
 *  @param image             图像
 *  @param landmarks         图像特征点坐标数组
 *  @return                  人脸特征数据
 */
- (NSData *_Nullable)extractFeatureWithImage:(UIImage *_Nonnull)image
                                   landmarks:(NSArray *_Nullable*_Nullable)landmarks;

/**
 *  图像特征比对
 *  如果成功返回人脸相似度，结果范围为(-1.0 ~ +1.0)之间
 *
 *  @param firstFeature      第一张图像特征值数据
 *  @param secondFeature     第二张图像特征值数据
 *  @return                  比对结果
 */
- (CGFloat)getFaceFeatureDistance:(NSData *_Nonnull)firstFeature
                secondFaceFeature:(NSData *_Nonnull)secondFeature;

/**
 *  相似度分数映射
 *  如果成功返回人脸相似度分数，结果范围为0 ~ 100
 *
 *  @param firstFeature      第一张图像特征值数据
 *  @param secondFeature     第二张图像特征值数据
 *  @return                  相似度分数
 */
- (int)getFaceSimilarity:(NSData *_Nonnull)firstFeature
       secondFaceFeature:(NSData *_Nonnull)secondFeature;

/**
 *  开启日志打印
 *  默认关闭
 *
 *  @param visible 是否开启日志打印
 */
- (void)setLogVisible:(BOOL)visible;
@end
