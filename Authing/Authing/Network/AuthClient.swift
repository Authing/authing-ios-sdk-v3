//
//  AuthClient.swift
//  Authing
//
//  Created by JnMars on 2022/9/22.
//

import Foundation

enum Connection: String {
    case password = "PASSWORD"
    case passcode = "PASSCODE"
    case ldap = "LDAP"
    case ad = "AD"
}

public enum Channel: String {
    case login = "CHANNEL_LOGIN"
    case register = "CHANNEL_REGISTER"
    case reset_password = "CHANNEL_RESET_PASSWORD"
    case bind_phone = "CHANNEL_BIND_PHONE"
    case unbind_phone = "CHANNEL_UNBIND_PHONE"
    case bind_mfa = "CHANNEL_BIND_MFA"
    case verify_mfa = "CHANNEL_VERIFY_MFA"
    case unbind_mfa = "CHANNEL_UNBIND_MFA"
    case complete_phone = "CHANNEL_COMPLETE_PHONE"
    case identity_verification = "CHANNEL_IDENTITY_VERIFICATION"
    case delete_account = "CHANNEL_DELETE_ACCOUNT"
    case bind_email = "CHANNEL_BIND_EMAIL"
    case unbind_email = "CHANNEL_UNBIND_EMAIL"
}

public enum SocialConnection: String {
    case apple = "apple"
    case wechat = "wechat"
    case wechatwork = "wechatwork"
    case wechatwork_agency = "wechatwork_agency"
    case lark_internal = "lark_internal"
    case lark_public = "lark_public"
    case google = "google"
    
    func getIdentiKey() -> String {
        switch self {
        case .apple:
            return "apple"
        case .wechat:
            return "wechat:mobile"
        case .wechatwork:
            return "wechatwork:mobile"
        case .wechatwork_agency:
            return "wechatwork:agency:mobile"
        case .lark_internal:
            return "lark-internal"
        case .lark_public:
            return "lark-public"
        case .google:
            return "google:mobile"
        }
    }
}

public enum EncryptType: String {
    case NONE = "none"
    case SM2 = "sm2"
    case RSA = "rsa"
}

public class AuthClient: Client {
    
    public var authRequest = AuthRequest()

    //MARK: ---------- Register ----------
    public func registerByEmail(email: String, password: String, _ options: RegisterOptions? = nil, completion: @escaping(Response) -> Void) {
        let encryptedPassword = Util.encryptPassword(password, type: options?.passwordEncryptType ?? .NONE)
        let body: NSMutableDictionary = ["connection": Connection.password.rawValue,
                                  "passwordPayload": ["email": email, "password": encryptedPassword]]
        options?.setValues(body: body)
        post("/api/v3/signup", body, completion: completion)
    }
    
    public func registerByEmailCode(email: String, passCode: String, _ options: RegisterOptions? = nil, completion: @escaping(Response) -> Void) {
        let body: NSMutableDictionary = ["connection": Connection.passcode.rawValue,
                                  "passCodePayload": ["email": email, "passCode": passCode]]
        options?.setValues(body: body)
        post("/api/v3/signup", body, completion: completion)
    }

    public func registerByPhoneCode(phoneCountryCode: String? = nil, phone: String, passCode: String, _ options: RegisterOptions? = nil, completion: @escaping(Response) -> Void) {
        let payload: NSMutableDictionary = ["phone": phone, "passCode": passCode]
        if let code = phoneCountryCode {
            payload.setValue(code, forKey: "phoneCountryCode")
        }
        let body: NSMutableDictionary = ["connection": Connection.passcode.rawValue,
                                  "passCodePayload": payload]
        options?.setValues(body: body)
        post("/api/v3/signup", body, completion: completion)
    }
    
    public func registerByUsername(username: String, password: String, _ options: RegisterOptions? = nil, completion: @escaping(Response) -> Void) {
        let encryptedPassword = Util.encryptPassword(password, type: options?.passwordEncryptType)
        let body: NSMutableDictionary = ["connection": Connection.password.rawValue,
                                  "passwordPayload": ["username": username, "password": encryptedPassword]]
        options?.setValues(body: body)
        post("/api/v3/signup", body, completion: completion)
    }

    //MARK: ---------- Login ----------
    
    public func loginByEmail(email: String, password: String, _ options: LoginOptions? = nil, completion: @escaping(Response) -> Void) {
        let encryptedPassword = Util.encryptPassword(password, type: options?.passwordEncryptType)
        let body: NSMutableDictionary = ["connection": Connection.password.rawValue,
                                  "passwordPayload": ["email": email, "password": encryptedPassword]]
        options?.setValues(body: body)
        post("/api/v3/signin", body) { res in
            self.createUserInfo(nil, res: res, completion: completion)
        }
    }
    
    public func loginByEmailCode(email: String, passCode: String, _ options: LoginOptions? = nil, completion: @escaping(Response) -> Void) {
        let body: NSMutableDictionary = ["connection": Connection.passcode.rawValue,
                                  "passCodePayload": ["email": email, "passCode": passCode]]
        options?.setValues(body: body)
        post("/api/v3/signin", body) { res in
            self.createUserInfo(nil, res: res, completion: completion)
        }
    }

    public func loginByPhoneCode(phoneCountryCode: String? = nil, phone: String, passCode: String, _ options: LoginOptions? = nil, completion: @escaping(Response) -> Void) {
        let payload: NSMutableDictionary = ["phone": phone, "passCode": passCode]
        if phoneCountryCode != nil {
            payload.setValue(phoneCountryCode, forKey: "phoneCountryCode")
        }
        let body: NSMutableDictionary = ["connection": Connection.passcode.rawValue,
                                  "passCodePayload": payload]
        options?.setValues(body: body)
        post("/api/v3/signin", body) { res in
            self.createUserInfo(nil, res: res, completion: completion)
        }
    }
    
    public func loginByUsername(username: String, password: String, _ options: LoginOptions? = nil, completion: @escaping(Response) -> Void) {
        let encryptedPassword = Util.encryptPassword(password, type: options?.passwordEncryptType)
        let body: NSMutableDictionary = ["connection": Connection.password.rawValue,
                                  "passwordPayload": ["username": username, "password": encryptedPassword]]
        options?.setValues(body: body)
        post("/api/v3/signin", body) { res in
            self.createUserInfo(nil, res: res, completion: completion)
        }
    }
    
    public func loginByAccount(account: String, password: String, _ options: LoginOptions? = nil, completion: @escaping(Response) -> Void) {
        let encryptedPassword = Util.encryptPassword(password, type: options?.passwordEncryptType)
        let body: NSMutableDictionary = ["connection": Connection.password.rawValue,
                                  "passwordPayload": ["account": account, "password": encryptedPassword]]
        options?.setValues(body: body)
        post("/api/v3/signin", body) { res in
            self.createUserInfo(nil, res: res, completion: completion)
        }
    }

    //MARK: ---------- Social ----------
    public func loginByThirdPart(code: String, connection: SocialConnection, _ options: LoginOptions? = nil, completion: @escaping(Response) -> Void) {
        getConfig { config in

            guard let conf = config else {
                completion(Response(ErrorCode.config.rawValue, nil, ErrorCode.config.errorMessage(), nil))
                return
            }
            
            guard let conId = conf.getConnectionId(type: connection.getIdentiKey()) else {
                completion(Response(ErrorCode.config.rawValue, nil, ErrorCode.config.errorMessage(), nil))
                return
            }
                        
            let body: NSMutableDictionary = ["connection": connection.rawValue,
                                             "extIdpConnidentifier": conId]
            options?.setValues(body: body)
            switch connection {
            case .apple:
                body.setValue(["code": code], forKey: "applePayload")
                break
            case .wechat:
                body.setValue(["code": code], forKey: "wechatPayload")
                break
            case .wechatwork:
                body.setValue(["code": code], forKey: "wechatworkPayload")
                break
            case .wechatwork_agency:
                body.setValue(["code": code], forKey: "wechatworkAgencyPayload")
                break
            case .lark_internal:
                body.setValue(["code": code], forKey: "larkInternalPayload")
                break
            case .lark_public:
                body.setValue(["code": code], forKey: "larkPublicPayload")
                break
            case .google:
                body.setValue(["code": code], forKey: "googlePayload")
                break
                
            }
            
            self.post("/api/v3/signin-by-mobile", body) { res in
                self.createUserInfo(nil, res: res, completion: completion)
            }
        }
    }
    
    public func loginByOneAuth(token: String, accessToken: String, _ options: LoginOptions? = nil, completion: @escaping(Response) -> Void) {
        getConfig { config in

            guard let conf = config else {
                completion(Response(ErrorCode.config.rawValue, nil, ErrorCode.config.errorMessage(), nil))
                return
            }
            
            guard let conId = conf.getConnectionId(type: "yidun") else {
                completion(Response(ErrorCode.config.rawValue, nil, ErrorCode.config.errorMessage(), nil))
                return
            }
                        
            let body: NSMutableDictionary = ["connection": "yidun",
                                             "extIdpConnidentifier": conId,
                                             "yidunPayload": ["token": token,
                                                              "accessToken": accessToken]]
            options?.setValues(body: body)
            self.post("/api/v3/signin-by-mobile", body) { res in
                self.createUserInfo(nil, res: res, completion: completion)
            }
        }
    }
    
    //MARK: ---------- Send SMS && Send email ----------
    public func sendSms(phone: String, phoneCountryCode: String? = nil, channel: Channel, completion: @escaping(Response) -> Void) {
        let body: NSMutableDictionary = ["phoneNumber": phone, "channel": channel.rawValue]
        if phoneCountryCode != nil {
            body.setValue(phoneCountryCode, forKey: "phoneCountryCode")
        }
        post("/api/v3/send-sms", body, completion: completion)
    }
    
    public func sendEmail(email: String, channel: Channel, completion: @escaping(Response) -> Void) {
        let body: NSDictionary = ["email": email, "channel": channel.rawValue]
        post("/api/v3/send-email", body, completion: completion)
    }
    
    //MARK: ---------- Scan QRCode ----------
    public func markQRCodeScanned(qrcodeId: String, completion: @escaping(Response) -> Void) {
        post("/api/v3/change-qrcode-status", ["qrcodeId": qrcodeId, "action": "SCAN"], completion: completion)
    }
        
    public func cancelByScannedTicket(qrcodeId: String, completion: @escaping(Response) -> Void) {
        post("/api/v3/change-qrcode-status", ["qrcodeId": qrcodeId, "action": "CANCEL"], completion: completion)
    }
    
    public func loginByScannedTicket(ticket: String, completion: @escaping(Response) -> Void) {
        post("/api/v3/exchange-tokenset-with-qrcode-ticket", ["ticket": ticket], completion: completion)
    }
    
    //MARK: ---------- User ----------

//    public func createUserInfo(_ code: Int, _ message: String?, _ data: NSDictionary?, completion: @escaping(Int, String?, UserInfo?) -> Void) {
//        createUserInfo(nil, code, message, data, completion: completion)
//    }
        
    public func createUserInfo(_ user: UserInfo?, res: Response, completion: @escaping(Response) -> Void) {
        let userInfo = user ?? UserInfo()
        if res.statusCode == 200 {
            userInfo.parse(data: res.data)
            
            // only save user for 'root', otherwise we might be in console
            if config == nil || config?.appId == Authing.getAppId() {
                Authing.saveUser(userInfo)
            } else {
                ALog.i(Self.self, "requesting app ID: \(config!.appId ?? "") root app ID: \(Authing.getAppId())")
            }
            
            completion(res)
        } else if res.apiCode == EC_MFA_REQUIRED {
            Authing.saveUser(userInfo)
            userInfo.mfaData = res.data
            completion(res)
        } else if res.apiCode == EC_FIRST_TIME_LOGIN {
            userInfo.firstTimeLoginToken = res.data?["token"] as? String
            completion(res)
        } else {
            completion(res)
        }
    }
    
    public func getProfile(customData: Bool? = false, identities: Bool? = false, departmentIds: Bool? = false, completion: @escaping(Response) -> Void) {
        get("/api/v3/get-profile?withCustomData=\(customData ?? false)&withIdentities=\(identities ?? false)&withDepartmentIds=\(departmentIds ?? false)") { res in
            self.createUserInfo(nil, res: res, completion: completion)
        }
    }
    

    public func updateProfile(object: NSDictionary, completion: @escaping(Response) -> Void) {
        post("/api/v3/update-profile", object, completion: completion)
    }
    
    public func bindPhone(phoneCountryCode: String? = nil, phoneNumber: String, passCode: String, completion: @escaping(Response) -> Void) {
        let body: NSMutableDictionary = ["phoneNumber" : phoneNumber, "passCode" : passCode]
        if phoneCountryCode != nil {
            body.setValue(phoneCountryCode, forKey: "phoneCountryCode")
        }
        post("/api/v3/bind-phone", body, completion: completion)
    }
    
    public func unbindPhone(passCode: String, completion: @escaping(Response) -> Void) {
        post("/api/v3/unbind-phone", ["passCode": passCode], completion: completion)
    }
    
    public func updatePhone(newPhoneCountryCode: String? = nil, newPhoneNumber: String, newPhonePassCode: String, oldPhoneCountryCode: String? = nil, oldPhoneNumber: String? = nil, oldPhonePassCode: String? = nil, completion: @escaping(Response) -> Void) {
        
        let body: NSMutableDictionary = ["newPhoneNumber" : newPhoneNumber, "newPhonePassCode" : newPhonePassCode]
        if newPhoneCountryCode != nil {
            body.setValue(newPhoneCountryCode, forKey: "newPhoneCountryCode")
        }

        if oldPhoneNumber != nil && oldPhonePassCode != nil {
            if oldPhoneCountryCode != nil {
                body.setValue(oldPhoneCountryCode, forKey: "oldPhoneCountryCode")
            }
            body.setValue(oldPhoneNumber, forKey: "oldPhoneNumber")
            body.setValue(oldPhonePassCode, forKey: "oldPhonePassCode")
        }
        
        let dicBody: NSMutableDictionary = ["verifyMethod": "PHONE_PASSCODE","phonePassCodePayload": body]

        post("/api/v3/verify-update-phone-request", dicBody) { res in
            if res.statusCode == 200 {
                if let updatePhoneToken = res.data?["updatePhoneToken"] as? String{
                    self.post("/api/v3/update-phone", ["updatePhoneToken": updatePhoneToken], completion: completion)
                } else {
                    completion(Response(ErrorCode.exchangeToken.rawValue, nil, ErrorCode.exchangeToken.errorMessage(), nil))
                }
            } else {
                completion(Response(res.statusCode, res.apiCode, res.message, res.data))
            }
        }
    }
    
    public func bindEmail(email: String, passCode: String, completion: @escaping(Response) -> Void) {
        let body: NSDictionary = ["email" : email, "passCode" : passCode]
        post("/api/v3/bind-email", body, completion: completion)
    }
    
    public func unbindEmail(passCode: String, completion: @escaping(Response) -> Void) {
        post("/api/v3/unbind-email", ["passCode": passCode], completion: completion)
    }
    
    public func updateEmail(newEmail: String, newEmailPassCode: String, oldEmail: String? = nil, oldEmailPassCode: String? = nil, completion: @escaping(Response) -> Void) {
        
        let body: NSMutableDictionary = ["newEmail" : newEmail, "newEmailPassCode" : newEmailPassCode]

        if oldEmail != nil && oldEmailPassCode != nil {

            body.setValue(oldEmail, forKey: "oldEmail")
            body.setValue(oldEmailPassCode, forKey: "oldEmailPassCode")
        }
        
        let dicBody: NSMutableDictionary = ["verifyMethod": "EMAIL_PASSCODE", "emailPassCodePayload": body]

        post("/api/v3/verify-update-email-request", dicBody) { res in
            if res.statusCode == 200 {
                if let updateEmailToken = res.data?["updateEmailToken"] as? String{
                    self.post("/api/v3/update-email", ["updateEmailToken": updateEmailToken], completion: completion)
                } else {
                    completion(Response(ErrorCode.exchangeToken.rawValue, nil, ErrorCode.exchangeToken.errorMessage(), nil))
                }
            } else {
                completion(Response(res.statusCode, res.apiCode, res.message, res.data))
            }
        }
    }
    
    public func updatePassword(newPassword: String, oldPassword: String? = nil, passwordEncryptType: EncryptType? = .NONE, completion: @escaping(Response) -> Void) {
        let body: NSMutableDictionary = ["newPassword" : Util.encryptPassword(newPassword, type: passwordEncryptType)]
        if (oldPassword != nil) {
            body.setValue(Util.encryptPassword(oldPassword!, type: passwordEncryptType), forKey: "oldPassword")
        }
        if let encryptType = passwordEncryptType{
            body.setValue(encryptType, forKey: "passwordEncryptType")
        }
        post("/api/v3/update-password", body, completion: completion)
    }
    
    public func resetPasswordByPhone(phoneCountryCode: String? = nil, phoneNumber: String, passCode: String, password: String, _ passwordEncryptType: EncryptType? = nil, completion: @escaping(Response) -> Void) {
        let payload: NSMutableDictionary = ["phoneNumber": phoneNumber, "passCode": passCode]
        if phoneCountryCode != nil {
            payload.setValue(phoneCountryCode, forKey: "phoneCountryCode")
        }
        let body: NSDictionary = ["verifyMethod" : "PHONE_PASSCODE",
                                  "phonePassCodePayload": payload]
        
        post("/api/v3/verify-reset-password-request", body) { res in
            if res.statusCode == 200 {
                if let passwordResetToken = res.data?["passwordResetToken"] as? String{
                    let dicBody: NSMutableDictionary  = ["passwordResetToken": passwordResetToken,
                                                         "password": Util.encryptPassword(password, type: passwordEncryptType)]
                    if passwordEncryptType != nil {
                        dicBody.setValue(passwordEncryptType?.rawValue, forKey: "passwordEncryptType")
                    }
                    self.post("/api/v3/reset-password", dicBody, completion: completion)
                } else {
                    completion(Response(ErrorCode.exchangeToken.rawValue, nil, ErrorCode.exchangeToken.errorMessage(), nil))
                }
            } else {
                completion(Response(res.statusCode, res.apiCode, res.message, res.data))
            }
        }
    }

    public func resetPasswordByEmail(email: String, passCode: String, password: String, _ passwordEncryptType: EncryptType? = nil, completion: @escaping(Response) -> Void) {
        let payload: NSMutableDictionary = ["email": email, "passCode": passCode]
        let body: NSDictionary = ["verifyMethod" : "EMAIL_PASSCODE",
                                  "emailPassCodePayload": payload]
        
        post("/api/v3/verify-reset-password-request", body) { res in
            if res.statusCode == 200 {
                if let passwordResetToken = res.data?["passwordResetToken"] as? String{
                    let dicBody: NSMutableDictionary  = ["passwordResetToken": passwordResetToken,
                                                         "password": Util.encryptPassword(password, type: passwordEncryptType)]
                    if passwordEncryptType != nil {
                        dicBody.setValue(passwordEncryptType?.rawValue, forKey: "passwordEncryptType")
                    }
                    self.post("/api/v3/reset-password", dicBody, completion: completion)
                } else {
                    completion(Response(ErrorCode.exchangeToken.rawValue, nil, ErrorCode.exchangeToken.errorMessage(), nil))
                }
            } else {
                completion(Response(res.statusCode, res.apiCode, res.message, res.data))
            }
        }
    }
    
    public func deleteAccountByPhone(phoneCountryCode: String? = nil, phoneNumber: String, passCode: String, completion: @escaping(Response) -> Void) {
        let payload: NSMutableDictionary = ["phoneNumber": phoneNumber, "passCode": passCode]
        if phoneCountryCode != nil {
            payload.setValue(phoneCountryCode, forKey: "phoneCountryCode")
        }
        let body: NSDictionary = ["verifyMethod" : "PHONE_PASSCODE",
                                  "phonePassCodePayload": payload]
        
        post("/api/v3/verify-delete-account-request", body) { res in
            if res.statusCode == 200 {
                if let deleteAccountToken = res.data?["deleteAccountToken"] as? String {
                    self.post("/api/v3/delete-account", ["deleteAccountToken": deleteAccountToken], completion: completion)
                } else {
                    completion(Response(ErrorCode.exchangeToken.rawValue, nil, ErrorCode.exchangeToken.errorMessage(), nil))
                }
            } else {
                completion(Response(res.statusCode, res.apiCode, res.message, res.data))
            }
        }
    }

    public func deleteAccountByEmail(email: String, passCode: String, completion: @escaping(Response) -> Void) {
        let payload: NSMutableDictionary = ["email": email, "passCode": passCode]
        let body: NSDictionary = ["verifyMethod" : "EMAIL_PASSCODE",
                                  "emailPassCodePayload": payload]
        
        post("/api/v3/verify-delete-account-request", body) { res in
            if res.statusCode == 200 {
                if let deleteAccountToken = res.data?["deleteAccountToken"] as? String {
                    self.post("/api/v3/delete-account", ["deleteAccountToken": deleteAccountToken], completion: completion)
                } else {
                    completion(Response(ErrorCode.exchangeToken.rawValue, nil, ErrorCode.exchangeToken.errorMessage(), nil))
                }
            } else {
                completion(Response(res.statusCode, res.apiCode, res.message, res.data))
            }
        }
    }
    
    public func deleteAccountByPassword(password: String, _ passwordEncryptType: EncryptType?, completion: @escaping(Response) -> Void) {
        let payload: NSMutableDictionary = ["password": Util.encryptPassword(password, type: passwordEncryptType)]
        if passwordEncryptType != nil {
            payload.setValue(passwordEncryptType?.rawValue, forKey: "passwordEncryptType")
        }
        let body: NSDictionary = ["verifyMethod" : "PASSWORD",
                                  "passwordPayload": payload]
        
        post("/api/v3/verify-delete-account-request", body) { res in
            if res.statusCode == 200 {
                if let deleteAccountToken = res.data?["deleteAccountToken"] as? String {
                    self.post("/api/v3/delete-account", ["deleteAccountToken": deleteAccountToken], completion: completion)
                } else {
                    completion(Response(ErrorCode.exchangeToken.rawValue, nil, ErrorCode.exchangeToken.errorMessage(), nil))
                }
            } else {
                completion(Response(res.statusCode, res.apiCode, res.message, res.data))
            }
        }
    }
    
    public func logout(completion: @escaping(Response) -> Void) {
        
        if let accessToken = Authing.getCurrentUser()?.accessToken {
            post("/oidc/token/revocation", ["client_id": Authing.getAppId(),
                                            "token": accessToken]) { res in
                Authing.saveUser(nil)
                HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
                completion(Response(res.statusCode, res.apiCode, res.message, res.data))
            }
        } else {
            completion(Response(ErrorCode.user.rawValue, nil, ErrorCode.user.errorMessage(), nil))
        }
    }
    
    //MARK: ---------- User Resources ----------
    public func getLoginHistory(page: Int = 1, limit: Int = 10, success: Bool? = nil, start: String? = nil, end: String? = nil, completion: @escaping (Response) -> Void) {
        let successStr = success == nil ? "" : "&success=" + String(success!)
        let startStr = start == nil ? "" : "&start=" + start!
        let endStr = end == nil ? "" : "&end=" + end!

        get("/api/v3/get-my-login-history?appId=\(Authing.getAppId())&page=\(String(page))&limit=\(String(limit))\(successStr)\(startStr)\(endStr)", completion: completion)
    }
    
    public func getLoggedApps(completion: @escaping(Response) -> Void) {
        get("/api/v3/get-my-logged-in-apps", completion: completion)
    }
    
    public func getAccessibleApps(completion: @escaping(Response) -> Void) {
        get("/api/v3/get-my-accessible-apps", completion: completion)
    }
    
    public func getTenantList(completion: @escaping(Response) -> Void) {
        get("/api/v3/get-my-tenant-list", completion: completion)
    }
    
    public func getRoleList(namespace: String? = nil, completion: @escaping(Response) -> Void) {
        get("/api/v3/get-my-role-list\(namespace == nil ? "" : "?namespace=" + namespace!)", completion: completion)
    }
    
    public func getGroupList(completion: @escaping(Response) -> Void) {
        get("/api/v3/get-my-group-list", completion: completion)
    }
    
    public func getDepartmentList(page: Int = 1, limit: Int = 10, withCustomData: Bool = false, sortBy: String = "JoinDepartmentAt", orderBy: String = "Desc", completion: @escaping(Response) -> Void) {
        get("/api/v3/get-my-department-list?page=\(String(page))&limit=\(String(limit))&withCustomData=\(String(withCustomData))&sortBy=\(sortBy)&orderBy=\(orderBy)", completion: completion)
    }
    
    public func getAuthorizedResources(namespace: String? = nil, resourceType: String? = nil, completion: @escaping(Response) -> Void) {
        get("/api/v3/get-my-authorized-resources\(namespace == nil ? "" : "?namespace=" + namespace!)\(resourceType == nil ? "" : "?resourceType=" + resourceType!)", completion: completion)
    }
    
    //MARK: ---------- OIDC ----------
    public func buildAuthorizeUrl(completion: @escaping (URL?) -> Void) {
        Authing.getConfig { config in
            if (config == nil) {
                completion(nil)
            } else {
               let secret = self.authRequest.client_secret
               var url = "\(Authing.getSchema())://\(Util.getHost(config!))/oidc/auth?"
               let nonce = "nonce=" + self.authRequest.nonce
               let scope = "&scope=" + (self.authRequest.scope.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")
               let clientId = "&client_id=" + self.authRequest.client_id
               let redirect = "&redirect_uri=" + self.authRequest.redirect_uri
               let responseType = "&response_type=" + self.authRequest.response_type
               let prompt = "&prompt=consent"
               let state = "&state=" + self.authRequest.state
               let codeChallenge = (secret == nil ? "&code_challenge=" + self.authRequest.codeChallenge! + "&code_challenge_method=S256" : "");
               url = url + nonce + scope + clientId + redirect + responseType + prompt + state + codeChallenge
               
                completion(URL(string: url))
            }
        }
    }
    
    public func buildLogoutUrl(completion: @escaping (URL?) -> Void) {
        Authing.getConfig { config in
            if (config == nil) {
                completion(nil)
            } else {
                let redirect = self.authRequest.redirect_uri ?? ""
                let token = Authing.getCurrentUser()?.idToken ?? ""
                let url = "\(Authing.getSchema())://\(Util.getHost(config!))/oidc/session/end?id_token_hint=\(token)&post_logout_redirect_uri=\(redirect)"

                completion(URL(string: url))
            }
        }
    }

    public func authByCode(code: String, completion: @escaping(Response) -> Void) {

        let secret = self.authRequest.client_secret
        let secretStr = (secret == nil ? "&code_verifier=" + self.authRequest.codeVerifier : "&client_secret=" + (secret ?? ""))

        let body = "client_id=" + Authing.getAppId()
                    + "&grant_type=authorization_code"
                    + "&code=" + code
                    + "&scope=" + self.authRequest.scope
                    + "&prompt=" + "consent"
                    + secretStr
                    + "&redirect_uri=" + self.authRequest.redirect_uri
        
        request(accessToken: nil, endPoint: "/oidc/token", method: "POST", body: body, completion: completion)
    }
    
    public func getUserInfoByAccessToken(accessToken: String, completion: @escaping(Response) -> Void) {
        request(accessToken: accessToken, endPoint: "/oidc/me", method: "GET", body: nil, completion: completion)
    }

    public func getNewAccessTokenByRefreshToken(refreshToken: String, completion: @escaping(Response) -> Void) {
        let secret = self.authRequest.client_secret
        let secretStr = (secret == nil ? "&code_verifier=" + self.authRequest.codeVerifier : "&client_secret=" + (secret ?? ""))

        let body = "client_id="
        + Authing.getAppId()
        + "&grant_type=refresh_token"
        + "&refresh_token=" + refreshToken
        + secretStr

        request(accessToken: nil, endPoint: "/oidc/token", method: "POST", body: body, completion: completion)
    }
    
    //MARK: ---------- MFA ----------
    public func mfaBindEmail(email: String, passCode: String, completion: @escaping(Response) -> Void) {
        
        let body: NSDictionary = ["factorType" : "EMAIL",
                                  "profile": ["email": email]]
        
        post("/api/v3/send-enroll-factor-request", body) { res in
            if res.statusCode == 200 {
                if let enrollmentToken = res.data?["enrollmentToken"] as? String {
                    self.post("/api/v3/enroll-factor", ["factorType" : "EMAIL",
                                                         "enrollmentToken": enrollmentToken,
                                                         "enrollmentData": ["passCode": passCode]], completion: completion)
                } else {
                    completion(Response(ErrorCode.exchangeToken.rawValue, nil, ErrorCode.exchangeToken.errorMessage(), nil))
                }
            } else {
                completion(Response(res.statusCode, res.apiCode, res.message, res.data))
            }
        }
    }
    
    public func mfaBindPhone(phoneCountryCode: String? = nil, phoneNumber: String, passCode: String, completion: @escaping(Response) -> Void) {
        
        let profile: NSMutableDictionary = ["phoneNumber": phoneNumber]
        if phoneCountryCode != nil {
            profile.setValue(phoneCountryCode, forKey: "phoneCountryCode")
        }
        let body: NSDictionary = ["factorType" : "SMS",
                                  "profile": profile]
        
        post("/api/v3/send-enroll-factor-request", body) { res in
            if res.statusCode == 200 {
                if let enrollmentToken = res.data?["enrollmentToken"] as? String {
                    self.post("/api/v3/enroll-factor", ["factorType" : "SMS",
                                                         "enrollmentToken": enrollmentToken,
                                                         "enrollmentData": ["passCode": passCode]], completion: completion)
                } else {
                    completion(Response(ErrorCode.exchangeToken.rawValue, nil, ErrorCode.exchangeToken.errorMessage(), nil))
                }
            } else {
                completion(Response(res.statusCode, res.apiCode, res.message, res.data))
            }
        }
    }
    
    public func mfaBindOTP(passCode: String, completion: @escaping(Response) -> Void) {
        
        let body: NSDictionary = ["factorType" : "OTP"]
        
        post("/api/v3/send-enroll-factor-request", body) { res in
            if res.statusCode == 200 {
                if let enrollmentToken = res.data?["enrollmentToken"] as? String {
                    self.post("/api/v3/enroll-factor", ["factorType" : "OTP",
                                                         "enrollmentToken": enrollmentToken,
                                                         "enrollmentData": ["passCode": passCode]], completion: completion)
                } else {
                    completion(Response(ErrorCode.exchangeToken.rawValue, nil, ErrorCode.exchangeToken.errorMessage(), nil))
                }
            } else {
                completion(Response(res.statusCode, res.apiCode, res.message, res.data))
            }
        }
    }
    
    public func mfaUnbindFactor(factorId: String, completion: @escaping(Response) -> Void) {
        post("/api/v3/reset-factor", ["factorId" : factorId], completion: completion)
    }
    
    public func mfaGetEnrolledFactorsList(completion: @escaping(Response) -> Void) {
        get("/api/v3/list-enrolled-factors", completion: completion)
    }
    
    public func mfaGetEnrolledBindFactor(factorId: String, completion: @escaping(Response) -> Void) {
        get("/api/v3/get-factors?factorId=\(factorId)", completion: completion)
    }
    
    public func mfaGetFactorsListToEnroll(completion: @escaping(Response) -> Void) {
        get("/api/v3/list-factors-to-enroll", completion: completion)
    }
    
    //MARK: ---------- File ----------
    public func uploadImage(_ image: UIImage, completion: @escaping (Int, String?) -> Void) {
        getConfig { config in
            if (config != nil) {
                let urlString: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/upload?folder=photos";
                self._uploadImage(urlString, image, completion: completion)
            } else {
                ALog.d(AuthClient.self, "Cannot get config. app id:\(Authing.getAppId())")
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage())
            }
        }
    }
    
    public func uploadFaceImage(_ image: UIImage,_ isPrivate: Bool = true, completion: @escaping (Int, String?) -> Void) {
        getConfig { config in
            if (config != nil) {
                let urlString: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/upload?folder=photos&private=\(isPrivate)";
                self._uploadImage(urlString, image, true, completion: completion)
            } else {
                ALog.d(AuthClient.self, "Cannot get config. app id:\(Authing.getAppId())")
                completion(ErrorCode.config.rawValue, ErrorCode.config.errorMessage())
            }
        }
    }
    
    private func _uploadImage(_ urlString: String, _ image: UIImage, _ isFaceImage: Bool? = false, completion: @escaping (Int, String?) -> Void) {
        let url = URL(string: urlString)
        let boundary = UUID().uuidString
        let session = URLSession.shared
        
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"personal.png\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            guard error == nil else {
                ALog.d(AuthClient.self, "network error \(url!)")
                completion(ErrorCode.netWork.rawValue, ErrorCode.netWork.errorMessage())
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
            guard jsonData != nil else {
                ALog.d(AuthClient.self, "response not json \(url!)")
                completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage())
                return
            }
            
            guard let json = jsonData as? [String: Any] else {
                ALog.d(AuthClient.self, "illegal json \(url!)")
                completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage())
                return
            }
            
            guard let code = json["code"] as? Int else {
                ALog.d(AuthClient.self, "no response code \(url!)")
                completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage())
                return
            }
            
            if isFaceImage == true{
                guard let data = json["data"] as? NSDictionary else {
                    ALog.d(AuthClient.self, "no data \(url!)")
                    completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage())
                    return
                }
                
                if let u = data["key"] as? String {
                    completion(200, u)
                } else {
                    ALog.d(AuthClient.self, "response data has no key field \(url!)")
                    completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage())
                    return
                }
            } else {
                guard code == 200 else {
                    completion(code, json["message"] as? String)
                    return
                }
                
                guard let data = json["data"] as? NSDictionary else {
                    ALog.d(AuthClient.self, "no response data \(url!)")
                    completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage())
                    return
                }
                
                if let u = data["url"] as? String {
                    completion(200, u)
                } else {
                    ALog.d(AuthClient.self, "response data has no url field \(url!)")
                    completion(ErrorCode.jsonParse.rawValue, ErrorCode.jsonParse.errorMessage())
                    return
                }
            }

        }).resume()
    }
    
    //MARK: ---------- Util ----------
    public func getSecurityInfo(completion: @escaping (Response) -> Void) {
        get("/api/v3/get-security-info", completion: completion)
    }
    
    public func getSystemConfig(completion: @escaping (Response) -> Void) {
        get("/api/v3/system", completion: completion)
    }
    
    //MARK: ---------- subEvent ----------
    public func subEvent(eventCode: String, completion: @escaping (Int, String?) -> Void) {
        if let currentUser = Authing.getCurrentUser(),
           let token = currentUser.accessToken {
            let eventUri = "\(Authing.getWebsocketHost())/events/v1/authentication/sub?code=\(eventCode)&token=\(token)"
            if #available(iOS 13.0, *) {
                AuthingWebsocketClient().initWebSocket(urlString: eventUri, completion: completion)
            }
        }
    }
    
    //MARK: ---------- pubEvent ----------
    public func pubEvent(eventType: String, eventData: NSDictionary, completion: @escaping(Response) -> Void) {
        
        guard let data = try? JSONSerialization.data(withJSONObject: eventData, options: []) else {
            ALog.d(AuthClient.self, "eventData is not json when requesting pubEvent")
            completion(Response(ErrorCode.jsonParse.rawValue, nil, ErrorCode.jsonParse.errorMessage(), nil))
            return
        }
        
        guard let str = String(data: data, encoding: .utf8) else {
            ALog.d(AuthClient.self, "eventData is not json when requesting pubEvent")
            completion(Response(ErrorCode.jsonParse.rawValue, nil, ErrorCode.jsonParse.errorMessage(), nil))
            return
        }
        
        post("/api/v3/pub-userEvent", ["eventType": eventType, "eventData": str], completion: completion)
    }
    
    //MARK: ---------- Request ----------
    public func get(_ endPoint: String, completion: @escaping (Response) -> Void) {
        request(endPoint: endPoint, method: "GET", body: nil, completion: completion)
    }
    
    public func post(_ endPoint: String, _ body: NSDictionary?, completion: @escaping (Response) -> Void) {
        request(endPoint: endPoint, method: "POST", body: body, completion: completion)
    }
    
    public func delete(_ endPoint: String, _ body: NSDictionary? = nil, completion: @escaping (Response) -> Void) {
        request(endPoint: endPoint, method: "DELETE", body: body, completion: completion)
    }
    
    private func request(endPoint: String, method: String, body: NSDictionary?, completion: @escaping (Response) -> Void) {
        getConfig { config in
            if (config != nil) {
                let urlString: String = "\(Authing.getSchema())://\(Util.getHost(config!))\(endPoint)";
                self.request(config: config, urlString: urlString, method: method, body: body, completion: completion)
            } else {
                completion(Response(500, nil, "Cannot get config. app id:\(Authing.getAppId())", nil))
            }
        }
    }
    
    public func request(config: Config?, urlString: String, method: String, body: NSDictionary?, completion: @escaping (Response) -> Void) {
        let url:URL! = URL(string:urlString)
        var request = URLRequest(url: url)
        request.httpMethod = method
        if method == "POST" && body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let httpBody = try? JSONSerialization.data(withJSONObject: body!, options: []) {
                request.httpBody = httpBody
            }
        }

        if let currentUser = Authing.getCurrentUser() {
            if let token = currentUser.accessToken {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else if let mfaToken = currentUser.mfaToken {
                request.addValue("Bearer \(mfaToken)", forHTTPHeaderField: "Authorization")
            }
        }
        request.timeoutInterval = 60
        if let userPoolId = config?.userPoolId {
            request.addValue(userPoolId, forHTTPHeaderField: "x-authing-userpool-id")
        }
        if let appid = config?.appId {
            request.addValue(appid, forHTTPHeaderField: "x-authing-app-id")
        }
        
        if let ua = config?.userAgent {
            request.addValue(ua, forHTTPHeaderField: "User-Agent")
        }
        request.addValue("Guard-iOS@\(SDK_VERSION)", forHTTPHeaderField: "x-authing-request-from")
        request.addValue(SDK_VERSION, forHTTPHeaderField: "x-authing-sdk-version")
        request.addValue(Util.getLangHeader(), forHTTPHeaderField: "x-authing-lang")
        
        request.httpShouldHandleCookies = false
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                ALog.d(AuthClient.self, "Guardian request network error:\(error!.localizedDescription)")
                completion(Response((error as? NSError)?.code ?? 500, nil, error!.localizedDescription, nil))
                return
            }
            
            guard data != nil else {
                ALog.d(AuthClient.self, "data is null when requesting \(urlString)")
                completion(Response(500, nil, "no data from server", nil))
                return
            }
            
            do {
                let httpResponse = response as? HTTPURLResponse
                let statusCode: Int = (httpResponse?.statusCode)!
                
                // some API e.g. getCustomUserData returns json array
                if (statusCode == 200 || statusCode == 201) {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSArray {
                        let res: NSDictionary = ["result": jsonArray]
                        completion(Response(200, nil, "", res))
                        return
                    }
                }
                
                guard let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary else {
                    ALog.d(AuthClient.self, "data is not json when requesting \(urlString)")
                    completion(Response(500, nil, "only accept json data", nil))
                    return
                }
                
                guard statusCode == 200 || statusCode == 201 else {
                    ALog.d(AuthClient.self, "Guardian request network error. Status code:\(statusCode.description). url:\(urlString)")
                    let message: String? = json["message"] as? String
                    completion(Response(statusCode, nil, message ?? "Network Error", json))
                    return
                }
                
                if let code: Int = json["code"] as? Int {
                    self.jsonConvertResponse(code: code, json: json, completion: completion)
                } else {
                    if let statusCode: Int = json["statusCode"] as? Int {
                        self.jsonConvertResponse(code: statusCode, json: json, completion: completion)
                    } else {
                        completion(Response(200, nil, nil, json))
                    }
                }
            } catch {
                ALog.d(AuthClient.self, "parsing json error when requesting \(urlString)")
                completion(Response(500, nil, urlString, nil))
            }
        }.resume()
    }
    
    public func request(accessToken: String?, endPoint: String, method: String, body: String?, completion: @escaping (Response) -> Void) {
        Authing.getConfig { config in
            if (config != nil) {
                let urlString: String = "\(Authing.getSchema())://\(Util.getHost(config!))\(endPoint)"
                self._request(accessToken: accessToken, config: config, urlString: urlString, method: method, body: body, completion: completion)
            } else {
               completion(Response(ErrorCode.config.rawValue, nil, ErrorCode.config.errorMessage(), nil))
            }
        }
    }
    
    private func _request(accessToken: String?, config: Config?, urlString: String, method: String, body: String?, completion: @escaping (Response) -> Void) {
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = method
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        if body != nil {
            request.httpBody = body!.data(using: .utf8)
        }

        if let at = accessToken {
            request.addValue("Bearer \(at)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                ALog.d(AuthClient.self, "network error \(url!) \n\(error!)")

                completion(Response(ErrorCode.netWork.rawValue, nil, ErrorCode.netWork.errorMessage(), nil))
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            let statusCode: Int = (httpResponse?.statusCode)!
            
            if (data != nil) {
                if statusCode == 200, let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
                    completion(Response(statusCode, nil, "success", jsonData as? NSDictionary))
                } else {
                    completion(Response(statusCode, nil, String(decoding: data!, as: UTF8.self), nil))
                }
            } else {
                completion(Response(statusCode, nil, "data is nil", nil))
            }
        }.resume()
    }
    
    private func jsonConvertResponse(code: Int, json: NSDictionary, completion: @escaping (Response) -> Void) {
        let apiCode: Int? = json["apiCode"] as? Int
        let message: String? = json["message"] as? String
        let jsonData: NSDictionary? = json["data"] as? NSDictionary
        if (jsonData == nil) {
            if let result = json["data"] {
                completion(Response(code, apiCode, message, ["data": result]))
            } else {
                completion(Response(code, apiCode, message, nil))
            }
        } else {
            completion(Response(code, apiCode, message, jsonData))
        }
    }
}
