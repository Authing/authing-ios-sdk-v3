//
//  AuthOptions.swift
//  Authing
//
//  Created by JnMars on 2022/9/26.
//

import Foundation

enum EncryptType: String {
    case NONE = "none"
    case SM2 = "sm2"
    case RSA = "rsa"
}


public class AuthOptions: NSObject {
    public var scope: String = "openid profile username email phone offline_access roles external_id extended_fields tenant_id"
    public var tenantId: String?
    public var customData: NSDictionary?
    public var autoRegister: Bool?
    public var captchaCode: Bool?
    public var passwordEncryptType: String? = EncryptType.NONE.rawValue
    
    public override init() { }
}
