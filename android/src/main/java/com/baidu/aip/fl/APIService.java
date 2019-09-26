/*
 * Copyright (C) 2017 Baidu, Inc. All Rights Reserved.
 */
package com.baidu.aip.fl;

import java.io.File;

import com.baidu.aip.fl.model.AccessToken;
import com.baidu.aip.fl.model.RegParams;
import com.baidu.aip.fl.utils.DeviceUuidFactory;
import com.baidu.aip.fl.utils.HttpUtil;
import com.baidu.aip.fl.utils.OnResultListener;
import com.baidu.aip.fl.parser.RegResultParser;

import android.content.Context;
import android.util.Base64;
import android.util.Log;

import static com.baidu.aip.fl.utils.Base64RequestBody.readFile;

public class APIService {

    private static final String BASE_URL = "https://aip.baidubce.com";

    private static final String ACCESS_TOEKN_URL = BASE_URL + "/oauth/2.0/token?";

    private static final String REG_URL = BASE_URL + "/rest/2.0/face/v3/faceset/user/add";


    private static final String IDENTIFY_URL = BASE_URL + "/rest/2.0/face/v3/search";
    private static final String VERIFY_URL = BASE_URL + "/rest/2.0/face/v3/verify";

    private String accessToken;

    private String groupId;

    private APIService() {

    }

    private static volatile APIService instance;

    public static APIService getInstance() {
        if (instance == null) {
            synchronized (APIService.class) {
                if (instance == null) {
                    instance = new APIService();


                }
            }
        }
        return instance;
    }

    public void init(Context context) {
        // 采用deviceId分组
        HttpUtil.getInstance().init();
        DeviceUuidFactory.init(context);
    }

    public void setGroupId(String groupId) {
        this.groupId = groupId;
    }

    /**
     * 设置accessToken 如何获取 accessToken 详情见:
     *
     * @param accessToken accessToken
     */
    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getAccessToken() {
        return accessToken;
    }

    /**
     * 明文aksk获取token
     *
     * @param listener
     * @param context
     * @param ak
     * @param sk
     */
    public void initAccessTokenWithAkSk(final OnResultListener<AccessToken> listener, Context context, String ak,
                                        String sk) {

        StringBuilder sb = new StringBuilder();
        sb.append("client_id=").append(ak);
        sb.append("&client_secret=").append(sk);
        sb.append("&grant_type=client_credentials");
        HttpUtil.getInstance().getAccessToken(listener, ACCESS_TOEKN_URL, sb.toString());

    }

    /**
     * 注册
     *
     * @param listener
     * @param file
     * @param uid
     * @param username
     */
    public void reg(OnResultListener listener, File file, String uid, String username) {
        RegParams params = new RegParams();
        String base64Img = "";
        try {
            byte[] buf = readFile(file);

            base64Img = new String(Base64.encode(buf, Base64.NO_WRAP));

        } catch (Exception e) {
            e.printStackTrace();
        }
        params.setImgType("BASE64");
        params.setBase64Img(base64Img);
        Log.e("FACE====",base64Img);
        params.setGroupId(groupId);

        params.setUserId(uid);
        params.setUserInfo(username);
        // 参数可以根据实际业务情况灵活调节
        params.setQualityControl("NONE");
        params.setLivenessControl("NORMAL");

        RegResultParser parser = new RegResultParser();
        String url = urlAppendCommonParams(REG_URL);
        HttpUtil.getInstance().post(url, params, parser, listener);
    }

    /**
     * @param listener
     * @param file
     */

    public void identify(OnResultListener listener, File file) {
        RegParams params = new RegParams();
        String base64Img = "";
        try {
            byte[] buf = readFile(file);
            base64Img = new String(Base64.encode(buf, Base64.NO_WRAP));

        } catch (Exception e) {
            e.printStackTrace();
        }
        params.setImgType("BASE64");
        params.setBase64Img(base64Img);
        //params.setBase64Img("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");
        Log.e("=-=====",base64Img);
        Log.e("=-=====","11111");
        params.setGroupIdList(groupId);
        // 可以根据实际业务情况灵活调节
        params.setQualityControl("NORMAL");
        params.setLivenessControl("NORMAL");

        RegResultParser parser = new RegResultParser();
        String url = urlAppendCommonParams(IDENTIFY_URL);
        HttpUtil.getInstance().post(url, params, parser, listener);
    }

    public void verify(OnResultListener listener, File file, String uid) {
        RegParams params = new RegParams();
        String base64Img = "";
        try {

            byte[] buf = readFile(file);
            base64Img = Base64.encodeToString(buf, Base64.DEFAULT);
            // base64Img = new String(Base64.encode(buf, Base64.NO_WRAP));

        } catch (Exception e) {
            Log.d("baseImg", "file size > -1");
            e.printStackTrace();
        }
        params.setImgType("BASE64");
        params.setBase64Img(base64Img);
        params.setUserId(uid);
        params.setGroupIdList(groupId);
        // 可以根据实际业务情况灵活调节
        params.setQualityControl("NONE");
        params.setLivenessControl("NORMAL");

        RegResultParser parser = new RegResultParser();
        String url = urlAppendCommonParams(IDENTIFY_URL);
        HttpUtil.getInstance().post(url, params, parser, listener);
    }


    /**
     * URL append access token，sdkversion，aipdevid
     *
     * @param url
     * @return
     */
    private String urlAppendCommonParams(String url) {
        StringBuilder sb = new StringBuilder(url);
        sb.append("?access_token=").append(accessToken);

        return sb.toString();
    }

}
