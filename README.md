# react-native-face-baidu
封装百度人脸识别sdk

### 安装步骤
- `yarn add react-native-face-baidu`
- `react-native link react-native-face-baidu`
- <details>
    <summary>Android 步骤</summary>

    - 修改包名(AndroidManifest.xml 的 package 和 android/app/build.gradle > android > defaultConfig > applicationId 填入创建授权时输入的 android 包名)
    - 在 android/gradle.properties 文件中配置
    ```profile
    ...
    BAIDU_FACE_SDK_LICENSE_ID="*license*"
    BAIDU_FACE_SDK_LICENSE_FILE_NAME="idl-license.face-android" # 可不配, 默认为 idl-license.face-android
    ...
    ```
    - 在 MainApplication.java 中添加
    ```java
    import com.baidu.idl.face.BaiduFace; /* 在顶部添加 */
    ...
    @Override
    public void onCreate() {
        super.onCreate();
        SoLoader.init(this, /* native exopackage */ false);
        BaiduFace.init(this); /* 在 onCreate 中添加 */
    }
    ```
    - 把 license 文件放入 android/app/src/main/assets 目录
  </details>
- <details>
    <summary>ios集成</summary>

    - xcode打开项目, 然后在 ${项目根目录}/node_modules/react-native-face-baidu/ios/这个目录下，找到BaiduFace文件夹，将其拖入你的项目
    - 确认 General/Identity/Bundle Identifier 与创建授权时填入的要一致
    - General/Linked Frameworks and Libraries 下点击 + 号, 选择 libc++.tbd, 点击 add 按钮
    - 把 你在百度下载的证书文件：idl-license.face-ios, 拖入你的项目
    - 在 info.plist 中添加 NSCameraUsageDescription
    - 在 info.plist 中添加 BAIDU_FACE_LICENSE_ID, 值为**创建授权**是填入的**授权标识**
    - 在 info.plist 中添加 相机和相册权限
    - 在 AppDelegate.m 中
    ```objective-c
    #import "BaiduFace.h" // 引入头文件

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        [BaiduFace initSDK]; // 初始化人像SDK
    }

    ```
  </details>


### 使用
```javascript
import BaiduFace from "react-native-face-baidu";

//必须先初始化一次人脸识别，qpp运行期间，只需要启动一次
 /**
     * 初始化获取token
     * @param {应用的API Key} client_id
     * @param {应用的Secret Key} client_secret
     */
BaiduFace.init(client_id,client_secret);

// 人脸图像采集
BaiduFace.detect({ 
      userId:"用户ID",
      userName:"用户名",
      groupId:"用户分组"
    });

// 活体检测
BaiduFace.liveness()
```

### 欢迎交流
欢迎提问交流；若有bug，请添加bug截图或代码片段，以便更快更好的解决问题。<br>
欢迎大家一起交流

### [我的博客](http://blog.sina.com.cn/s/articlelist_6078695441_0_1.html)