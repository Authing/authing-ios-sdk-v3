//
//  AuthOptions.swift
//  Authing
//
//  Created by JnMars on 2022/9/26.
//

import Foundation

public class AuthOptions: NSObject {
    
    public var context: String?
    public var passwordEncryptType: EncryptType? = .NONE
    public var clientIp: String?
    public override init() { }
}

public class LoginOptions: AuthOptions {
    
    public var scope: String = "openid profile username email phone offline_access roles external_id extended_fields tenant_id"
    public var tenantId: String?
    public var customData: NSDictionary?
    public var autoRegister: Bool?
    public var captchaCode: Bool?
    public override init() { }
    
    public func setValues(body: NSMutableDictionary){
        let optionsDic: NSMutableDictionary = ["scope": self.scope]
        if let tenantId = self.tenantId {
            optionsDic.setValue(tenantId, forKey: "tenantId")
        }
        if let customData = self.customData {
            optionsDic.setValue(customData, forKey: "customData")
        }
        if let autoRegister = self.autoRegister {
            optionsDic.setValue(autoRegister, forKey: "autoRegister")
        }
        if let captchaCode = self.captchaCode {
            optionsDic.setValue(captchaCode, forKey: "captchaCode")
        }
        if let passwordEncryptType = self.passwordEncryptType {
            optionsDic.setValue(passwordEncryptType.rawValue, forKey: "passwordEncryptType")
        }
        if let context = self.context {
            optionsDic.setValue(context, forKey: "context")
        }
        body.setValue(optionsDic, forKey: "options")
    }
}

public class RegisterOptions: AuthOptions {
    
    public var profile: NSDictionary?
    public var phonePassCodeForInformationCompletion: String?
    public var emailPassCodeForInformationCompletion: String?
    public override init() { }
    
    public func setValues(body: NSMutableDictionary){
        let optionsDic: NSMutableDictionary = [:]
     
        if let phonePassCodeForInformationCompletion = self.phonePassCodeForInformationCompletion {
            optionsDic.setValue(phonePassCodeForInformationCompletion, forKey: "phonePassCodeForInformationCompletion")
        }
        if let emailPassCodeForInformationCompletion = self.emailPassCodeForInformationCompletion {
            optionsDic.setValue(emailPassCodeForInformationCompletion, forKey: "emailPassCodeForInformationCompletion")
        }
        if let passwordEncryptType = self.passwordEncryptType {
            optionsDic.setValue(passwordEncryptType.rawValue, forKey: "passwordEncryptType")
        }
        if let context = self.context {
            optionsDic.setValue(context, forKey: "context")
        }

        body.setValue(optionsDic, forKey: "options")
        if let profile = self.profile {
            body.setValue(profile, forKey: "profile")
        }
    }
}
