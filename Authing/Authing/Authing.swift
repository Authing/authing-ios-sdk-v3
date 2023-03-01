//
//  Authing.swift
//  Authing
//
//  Created by JnMars on 2022/9/22.
//

typealias ConfigCompletion = (Config?) -> Void

public class Authing: NSObject {
    
    @objc public static let DEFAULT_RSA_PUBLIC_KEY = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4xKeUgQ+Aoz7TLfAfs9+paePb5KIofVthEopwrXFkp8OCeocaTHt9ICjTT2QeJh6cZaDaArfZ873GPUn00eOIZ7Ae+TiA2BKHbCvloW3w5Lnqm70iSsUi5Fmu9/2+68GZRH9L7Mlh8cFksCicW2Y2W2uMGKl64GDcIq3au+aqJQIDAQAB"
    
    @objc public static let DEFAULT_SM2_PUBLIC_KEY = "042bc07187cc3bdcfe63b37902eead6dc400734d386e8e2be05d26159bce3259ae602c608052204079e5f49c12ef3296df8ceeff6314b45e2cf110dd58e96a47e4"
    
    public typealias AuthCompletion = (Int, String?, UserInfo?) -> Void
    
    @objc public static var sConfig: Config? = nil
    
    public enum NotifyName: String {
        /// wechat notification
        case notify_wechat = "wechatLoginOK"
        /// wecom register notification
        case notify_wecom_register = "WeComRegisterNotificationName"
        /// wecom receive notification
        case notify_wecom_receive = "WeComReceiveNotificationName"
        ///lark register notification
        case notify_lark_register = "LarkRegisterNotificationName"
        /// lark receive notification
        case notify_lark_receive = "LarkReceiveNotificationName"
    }
    
    private static var debugMode: Bool = false
    private static var sSchema = "https"
    private static var sHost = "authing.cn"
    private static var sWebsocketHost = "wss://events.authing.com"
    private static var sAppId = ""
    private static var isOnPremises = false
    private static var sRSAPublicKey = DEFAULT_RSA_PUBLIC_KEY
    private static var sSM2PublicKey = DEFAULT_SM2_PUBLIC_KEY

    private static var sCurrentUser: UserInfo?
    
    @objc public static func start(_ appid: String) {
                
        sAppId = appid
        sConfig = Config(appId: appid)
    }
    
    @objc public static func getAppId() -> String {
        return sAppId
    }
    
    @objc public static func setSchema(schema: String) {
        sSchema = schema
    }
    
    @objc public static func getSchema() -> String {
        return sSchema
    }
    
    @objc public static func setHost(host: String) {
        sHost = host
    }
    
    @objc public static func getHost() -> String {
        return sHost
    }
    
    @objc public static func getIsOnPremises() -> Bool {
        return isOnPremises
    }
    
    @objc public static func getRSAPublicKey() -> String {
        return sRSAPublicKey
    }
    
    @objc public static func getSM2PublicKey() -> String {
        return sSM2PublicKey
    }
    
    @objc public static func setOnPremiseInfo(host: String, RASpublicKey: String? = nil, SM2publicKey: String? = nil) {
        isOnPremises = true
        sHost = host
        if let rsa = RASpublicKey {
            sRSAPublicKey = rsa
        }
        if let sm2 = SM2publicKey {
            sSM2PublicKey = sm2
        }
    }
    
    @objc public static func setWebsocketHost(websocketHost: String) {
        sWebsocketHost = websocketHost
    }
    
    @objc public static func getWebsocketHost() -> String {
        return sWebsocketHost
    }
    
    
    @objc public static func getConfig(completion: @escaping(Config?)->Void) {
        if let c = sConfig {
            c.getConfig(completion: completion)
        } else {
            completion(nil)
        }
    }
    
    @objc public static func getConfigObject() -> Config? {
        return sConfig
    }
    
//    @objc public static func setupAlipay(_ appid: String, customScheme: String) {
//        Alipay.appid = appid
//        Alipay.customScheme = customScheme
//    }
    
    
    @objc private static func clearUser(_ code: Int, _ message: String?, _ completion: @escaping(Int, String?, UserInfo?) -> Void) {
        UserManager.removeUser()
        sCurrentUser = nil
        completion(code, message, nil)
    }
    
    @objc public static func getCurrentUser() -> UserInfo? {
        return sCurrentUser
    }
    
    @objc public static func saveUser(_ userInfo: UserInfo?) {
        sCurrentUser = userInfo
        // TODO save to user defaults then Core Data
        UserManager.saveUser(sCurrentUser)
    }
    
    @objc public static func setDebugMode(open: Bool) {
        debugMode = open
    }
    
    @objc public static func getDebugMode() -> Bool {
        return  debugMode
    }
    
}
