import { NativeModules, Platform, NativeEventEmitter } from 'react-native';

const IOSSDKSupport = (method) => {
    return new Promise(resolve => {
        const subscript = EventEmitter.addListener('complete', (data) => {
            if (!data) {
                resolve({ success: false });
                return;
            }
            data.bestImage0 = Array.isArray(data.bestImage) ? data.bestImage[0] : '';
            resolve({ success: true, images: data });
            subscript.remove();
        });
        SDK[method]();
    });
};
const SDK = NativeModules.BaiduFace;
const EventEmitter = new NativeEventEmitter(SDK);
const BaiduFace = Platform.select({
    android: SDK,
    ios: {
        init:(client_id,client_secret)=>SDK.init(client_id,client_secret),
        detect: (options) => {
            return SDK.detect(options);
            // return IOSSDKSupport('detect');
        },
        liveness: () => {
            return IOSSDKSupport('liveness');
        },
        config: (opt) => {
            return new Promise(resolve => {
                const subscript = EventEmitter.addListener('success', (data) => {
                    resolve(true);
                    subscript.remove();
                });
                SDK.config(opt);
            });
        },
        LivenessType: SDK.LivenessType,
    }
});

export default {

    /**
     * 初始化获取token
     * @param {应用的API Key} client_id
     * @param {应用的Secret Key} client_secret
     */
    init:(client_id,client_secret)=>BaiduFace.init(client_id,client_secret),

    /**
     * 人脸检测后会自动拍照 注册人像
     * @param {注册参数} options
     * options={
                    userId:"用户ID",
                    userName:"用户名",
                    groupId:"用户分组"
                }
     *
     */
    detect: (options) => BaiduFace.detect(options),
    /**
     * 活体检测
     */
    liveness: () => BaiduFace.liveness(),
    /**
     * 人像配置(代码)
     *
     * @param {Object} opt 配置
     * @param {Boolean} [opt.livenessRandom] 随机活体动作
     * @param {Number} [opt.livenessRandomCount] 随机活体检测动作数
     * @param {Array.<LivenessType>} [opt.livenessTypeList] 活体动作
     */
    config: (opt) => BaiduFace.config(opt),
    /**
     * 活体类型常量
     *
     * Eye: 眨眼
     * Mouth: 张嘴
     * HeadUp: 抬头
     * HeadDown: 低头
     * HeadLeft: 向左转头
     * HeadRight: 向右转头
     * HeadLeftOrRight: 摇头
     */
    LivenessType: BaiduFace.LivenessType
};
