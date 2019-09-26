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

/**
 拼接字典数据
 
 @param parameters 参数
 @return 拼接后的字符串
 */
-(NSString *)paramsConvert:(NSDictionary *)parameters
{
  //创建可变字符串来承载拼接后的参数
  NSMutableString *parameterString = [NSMutableString new];
  //获取parameters中所有的key
  NSArray *parameterArray = parameters.allKeys;
  for (int i = 0;i < parameterArray.count;i++) {
    //根据key取出所有的value
    id value = parameters[parameterArray[i]];
    //把parameters的key 和 value进行拼接
    NSString *keyValue = [NSString stringWithFormat:@"%@=%@",parameterArray[i],value];
    if (i == parameterArray.count || i == 0) {
      //如果当前参数是最后或者第一个参数就直接拼接到字符串后面，因为第一个参数和最后一个参数不需要加 “&”符号来标识拼接的参数
      [parameterString appendString:keyValue];
    }else
    {
      //拼接参数， &表示与前面的参数拼接
      [parameterString appendString:[NSString stringWithFormat:@"&%@",keyValue]];
    }
  }
  return parameterString;
}

-(void)request:(NSString *)urlAddress parameters:(NSDictionary *)parameters completion:(void (^)(NSMutableDictionary *))success{
  //请求地址
  NSURL *url = [NSURL URLWithString:urlAddress];
  
  //设置请求地址
  NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url];
  
  //设置请求方式
  postRequest.HTTPMethod = @"POST";
  
  NSError* error = nil;
  if ([urlAddress hasSuffix:@"oauth/2.0/token"]) {
    postRequest = [[[AFHTTPRequestSerializer serializer] requestBySerializingRequest:postRequest withParameters:parameters error:&error] mutableCopy];
  } else {
        postRequest = [[[AFJSONRequestSerializer serializer] requestBySerializingRequest:postRequest withParameters:parameters error:&error] mutableCopy];
  }
  
  if (error != nil) {
    NSLog(@"error = %@",error);
  }
  
  NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
  sessionConfig.timeoutIntervalForRequest = 20;
  sessionConfig.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4*1024*1024 diskCapacity:32*1024*1024 diskPath:@"com.baidu.FaceSharp"];
  
  NSURLSessionDataTask* task = [[[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfig] dataTaskWithRequest:postRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseData, NSError * _Nullable error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (error) {
        //        if (failure) {
        //          failure(error);
        //        }
      }
      else
      {
        if (success) {
          success(responseData);
        }
      }
    });
  }];
  [task resume];
  
//  //设置请求参数
//  postRequest.HTTPBody = [[self paramsConvert:parameters] dataUsingEncoding:NSUTF8StringEncoding];
//  //关于parameters是NSDictionary拼接后的NSString.关于拼接看后面拼接方法说明
//
//  //设置请求session
//  NSURLSession *session = [NSURLSession sharedSession];
//
//  //设置网络请求的返回接收器
//  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:postRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//    dispatch_async(dispatch_get_main_queue(), ^{
//      if (error) {
//        //        if (failure) {
//        //          failure(error);
//        //        }
//      }
//      else
//      {
//        NSError *error;
//        NSMutableDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
//        if (error) {
//          //          if (failure) {
//          //            failure(error);
//          //          }
//        }
//        else
//        {
//          if (success) {
//            success(responseObject);
//          }
//        }
//      }
//    });
//  }];
//
//  //开始请求
//  [dataTask resume];
}

- (NSString*) getTmpDirectory {
  NSString *TMP_DIRECTORY = @"react-native-face-baidu/";
  NSString *tmpFullPath = [NSTemporaryDirectory() stringByAppendingString:TMP_DIRECTORY];
  
  BOOL isDir;
  BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:tmpFullPath isDirectory:&isDir];
  if (!exists) {
    [[NSFileManager defaultManager] createDirectoryAtPath: tmpFullPath
                              withIntermediateDirectories:YES attributes:nil error:nil];
  }
  
  return tmpFullPath;
}

// at the moment it is not possible to upload image by reading PHAsset
// we are saving image and saving it to the tmp location where we are allowed to access image later
- (NSString*) persistFile:(NSData*)data {
  // create temp file
  NSString *tmpDirFullPath = [self getTmpDirectory];
  NSString *filePath = [tmpDirFullPath stringByAppendingString:[[NSUUID UUID] UUIDString]];
  filePath = [filePath stringByAppendingString:@".jpg"];
  
  // save cropped file
  BOOL status = [data writeToFile:filePath atomically:YES];
  if (!status) {
    return nil;
  }
  
  return filePath;
}

/*向百度注册人像，
@param imageStr 图片数据
 */
- (void)registerFaceWithImageBaseString:(NSString *)imageStr {
  NSDictionary* parm = @{@"user_id":self.params[@"userId"],
                         @"user_info":self.params[@"userName"],
                         @"group_id":self.params[@"groupId"],
                         @"image_type":@"BASE64",
                         @"liveness_control":@"NORMAL",
                         @"quality_control":@"NORMAL",
                         @"image":imageStr};
  [self request:[NSString stringWithFormat:@"https://aip.baidubce.com/rest/2.0/face/v3/faceset/user/add?access_token=%@",self.accessToken] parameters:parm completion:^(NSMutableDictionary *responseObject) {
    if(self.resolve){
      self.resolve(@{
                     @"path":[self persistFile:[[NSData alloc] initWithBase64EncodedString:imageStr options:NSDataBase64DecodingIgnoreUnknownCharacters]]
                     });
      
      self.resolve = nil;
    }
  }];
}

//初始化获取token
//client_id： 必须参数，应用的API Key；
//client_secret： 必须参数，应用的Secret Key；
RCT_EXPORT_METHOD(init:(NSString *)client_id
                  client_secret:(NSString *)client_secret)
{
  [self request:@"https://aip.baidubce.com/oauth/2.0/token"
     parameters:@{
                  @"client_id":client_id,
                  @"client_secret":client_secret,
                  @"grant_type":@"client_credentials"
                  }
     completion:^(NSMutableDictionary *responseObject) {
       self.accessToken = responseObject[@"access_token"];
     }];
}

// 人脸跟踪检测 图像采集
RCT_EXPORT_METHOD(detect:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  self.params = params;
  self.resolve = resolve;
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
