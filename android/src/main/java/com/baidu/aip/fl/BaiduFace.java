package com.baidu.aip.fl;

import android.app.Activity;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;

import com.baidu.aip.FaceEnvironment;
import com.baidu.aip.FaceSDKManager;
import com.baidu.aip.fl.exception.FaceError;
import com.baidu.aip.fl.model.AccessToken;
import com.baidu.aip.fl.utils.LogUtil;
import com.baidu.aip.fl.utils.OnResultListener;
import com.baidu.idl.facesdk.FaceTracker;
import com.facebook.react.bridge.Promise;
import com.baidu.aip.fl.FaceCollectActivity;
import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

public class BaiduFace extends ReactContextBaseJavaModule {
    private Promise mPromise;
    private static final int FACE_REQUEST_CODE = 123;
    private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {
        @Override
        public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
            super.onActivityResult(activity, requestCode, resultCode, data);
            if (requestCode == FACE_REQUEST_CODE) {
                String path=data.getStringExtra("path");
                mPromise.resolve(path);
            }
        }
    };

    public BaiduFace(ReactApplicationContext reactContext) {
        super(reactContext);
        reactContext.addActivityEventListener(mActivityEventListener);
    }

    @Override
    public String getName() {
        return "BaiduFace";
    }

    @ReactMethod
    public void init(String key, String secret) {
        if (!TextUtils.isEmpty(key)) {
            Config.apiKey = key;
        }
        if (!TextUtils.isEmpty(secret)) {
            Config.secretKey = secret;
        }
        initLib();
        APIService.getInstance().init(getReactApplicationContext());
//        APIService.getInstance().setGroupId(Config.groupID);
        // 用ak，sk获取token, 调用在线api，如：注册、识别等。为了ak、sk安全，建议放您的服务器，
        APIService.getInstance().initAccessTokenWithAkSk(new OnResultListener<AccessToken>() {
            @Override
            public void onResult(AccessToken result) {
                Log.i("wtf", "AccessToken->" + result.getAccessToken());
                LogUtil.e("baiduFace", "启动成功");
            }

            @Override
            public void onError(FaceError error) {
                Log.e("xx", "AccessTokenError:" + error);
                error.printStackTrace();

            }
        }, getReactApplicationContext(), Config.apiKey, Config.secretKey);
    }

    @ReactMethod
    public void detect(ReadableMap option, Promise promise) {
        mPromise = promise;
        String uid = option.hasKey("userId") ? option.getString("userId") : "";
        if (option.hasKey("groupId")) {
            Config.groupID = option.getString("groupId");
            APIService.getInstance().setGroupId(Config.groupID);
        }
        Intent intent = new Intent(getCurrentActivity(), FaceCollectActivity.class);
        intent.putExtra("uid", uid);
        getCurrentActivity().startActivityForResult(intent, FACE_REQUEST_CODE);
    }

    private void readOption(ReadableMap option) {
        if (option.hasKey("client_id")) {
            Config.apiKey = option.getString("client_id");
        }
        if (option.hasKey("client_secret")) {
            Config.secretKey = option.getString("client_secret");
        }
    }

    /**
     * 初始化SDK
     */
    private void initLib() {
        // 为了android和ios 区分授权，appId=appname_face_android ,其中appname为申请sdk时的应用名
        // 应用上下文
        // 申请License取得的APPID
        // assets目录下License文件名
        FaceSDKManager.getInstance().init(getReactApplicationContext(), Config.licenseID, Config.licenseFileName);
        setFaceConfig();
    }

    private void setFaceConfig() {
        FaceTracker tracker = FaceSDKManager.getInstance().getFaceTracker(getReactApplicationContext());  //.getFaceConfig();
        // SDK初始化已经设置完默认参数（推荐参数），您也根据实际需求进行数值调整

        // 模糊度范围 (0-1) 推荐小于0.7
        tracker.set_blur_thr(FaceEnvironment.VALUE_BLURNESS);
        // 光照范围 (0-1) 推荐大于40
        tracker.set_illum_thr(FaceEnvironment.VALUE_BRIGHTNESS);
        // 裁剪人脸大小
        tracker.set_cropFaceSize(FaceEnvironment.VALUE_CROP_FACE_SIZE);
        // 人脸yaw,pitch,row 角度，范围（-45，45），推荐-15-15
        tracker.set_eulur_angle_thr(FaceEnvironment.VALUE_HEAD_PITCH, FaceEnvironment.VALUE_HEAD_ROLL,
                FaceEnvironment.VALUE_HEAD_YAW);

        // 最小检测人脸（在图片人脸能够被检测到最小值）80-200， 越小越耗性能，推荐120-200
        tracker.set_min_face_size(FaceEnvironment.VALUE_MIN_FACE_SIZE);
        //
        tracker.set_notFace_thr(FaceEnvironment.VALUE_NOT_FACE_THRESHOLD);
        // 人脸遮挡范围 （0-1） 推荐小于0.5
        tracker.set_occlu_thr(FaceEnvironment.VALUE_OCCLUSION);
        // 是否进行质量检测
        tracker.set_isCheckQuality(true);
        // 是否进行活体校验
        tracker.set_isVerifyLive(false);
    }
}
