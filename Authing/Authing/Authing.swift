//
//  Authing.swift
//  Authing
//
//  Created by JnMars on 2022/9/22.
//

typealias ConfigCompletion = (Config?) -> Void

public class Authing: NSObject {
    
    @objc public static var sConfig: Config? = nil
    private static var sAppId = ""
    private static var isOnPremises = false
    private static var sSchema = "https"
    private static var sHost = "authing.cn"
    private static var sPublicKey = DEFAULT_PUBLIC_KEY
    private static var sCurrentUser: UserInfo?
    
    @objc public static func start(_ appid: String) {
                
        sAppId = appid
        sConfig = Config(appId: appid)
    }
    
    @objc public static func getAppId() -> String {
        return sAppId
    }

    
    @objc public static func getCurrentUser() -> UserInfo? {
        return sCurrentUser
    }
    
    @objc public static func getPublicKey() -> String {
        return sPublicKey
    }
    
    @objc public static func setHost(host: String) {
        sHost = host
    }
    
    @objc public static func getHost() -> String {
        return sHost
    }
    
    @objc public static func setSchema(schema: String) {
        sSchema = schema
    }
    
    @objc public static func getSchema() -> String {
        return sSchema
    }
    
    @objc public static func setOnPremiseInfo(host: String, publicKey: String) {
        isOnPremises = true
        sHost = host
        sPublicKey = publicKey
    }
    
    @objc public static func getIsOnPremises() -> Bool {
        return isOnPremises
    }
    
}
