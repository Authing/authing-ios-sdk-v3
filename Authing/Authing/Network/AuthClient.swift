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
}

public class AuthClient: Client {

    //MARK: ---------- Register ----------
    public func registerByEmail(email: String, password: String, completion: @escaping(Response) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSDictionary = ["connection" : Connection.password.rawValue,
                                  "passwordPayload" : ["email": email, "password": encryptedPassword]]
        post("/api/v3/signup", body, completion: completion)
    }
    
    public func registerByEmailCode(email: String, code: String, completion: @escaping(Response) -> Void) {
        let body: NSDictionary = ["connection" : Connection.passcode.rawValue,
                                  "passcodePayload" : ["email": email, "passCode": code]]
        post("/api/v3/signup", body, completion: completion)
    }

    public func registerByPhoneCode(phoneCountryCode: String? = nil, phone: String, code: String, completion: @escaping(Response) -> Void) {
        let payload: NSMutableDictionary = ["phone": phone, "passCode": code]
        if let code = phoneCountryCode {
            payload.setValue(code, forKey: "phoneCountryCode")
        }
        let body: NSDictionary = ["connection" : Connection.passcode.rawValue,
                                  "passcodePayload" : payload]
        post("/api/v3/signup", body, completion: completion)
    }
    
    public func registerByUsername(username: String, password: String, completion: @escaping(Response) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSDictionary = ["connection" : Connection.password.rawValue,
                                  "passwordPayload" : ["username": username, "password": encryptedPassword]]
        post("/api/v3/signup", body, completion: completion)
    }

    //MARK: ---------- Login ----------
    
    public func loginByEmail(email: String, password: String, _ options: AuthOptions? = nil, completion: @escaping(Response) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSMutableDictionary = ["connection" : Connection.password.rawValue,
                                  "passwordPayload" : ["email": email, "password": encryptedPassword]]
        setOptions(body: body, options: options)
        post("/api/v3/signin", body, completion: completion)
    }
    
    public func loginByEmailCode(email: String, code: String, _ options: AuthOptions? = nil, completion: @escaping(Response) -> Void) {
        let body: NSMutableDictionary = ["connection" : Connection.passcode.rawValue,
                                  "passCodePayload" : ["email": email, "passCode": code]]
        setOptions(body: body, options: options)
        post("/api/v3/signin", body, completion: completion)
    }

    public func loginByPhoneCode(phoneCountryCode: String? = nil, phone: String, code: String, _ options: AuthOptions? = nil, completion: @escaping(Response) -> Void) {
        let body: NSMutableDictionary = ["connection" : Connection.passcode.rawValue,
                                  "passCodePayload" : ["phoneCountryCode": phoneCountryCode, "phone": phone, "passCode": code]]
        setOptions(body: body, options: options)
        post("/api/v3/signin", body, completion: completion)
    }
    
    public func loginByUsername(username: String, password: String, _ options: AuthOptions? = nil, completion: @escaping(Response) -> Void) {
        var pw = password
        if options?.passwordEncryptType == EncryptType.RSA.rawValue {
            pw = Util.encryptPassword(password)
        }
        if options?.passwordEncryptType == EncryptType.SM2.rawValue {
            
        }
        let body: NSMutableDictionary = ["connection" : Connection.password.rawValue,
                                  "passwordPayload" : ["username": username, "password": pw]]
        setOptions(body: body, options: options)
        post("/api/v3/signin", body, completion: completion)
    }
    
    public func loginByAccount(account: String, password: String, _ options: AuthOptions? = nil, completion: @escaping(Response) -> Void) {
        let encryptedPassword = Util.encryptPassword(password)
        let body: NSMutableDictionary = ["connection" : Connection.password.rawValue,
                                  "passwordPayload" : ["account": account, "password": encryptedPassword]]
        setOptions(body: body, options: options)
        post("/api/v3/signin", body, completion: completion)
    }
    
    //MARK: ---------- send SMS && send email ----------
    public func sendSms(phone: String, phoneCountryCode: String? = nil, channel: String, completion: @escaping(Response) -> Void) {
        let body: NSMutableDictionary = ["phoneNumber" : phone, "channel": channel]
        if phoneCountryCode != nil {
            body.setValue(phoneCountryCode, forKey: "phoneCountryCode")
        }
        post("/api/v3/send-sms", body, completion: completion)
    }
    
    
    public func sendEmail(email: String, channel: String, completion: @escaping(Response) -> Void) {
        let body: NSDictionary = ["email" : email, "channel" : channel]
        post("/api/v3/send-email", body, completion: completion)
    }

    //MARK: ---------- User ----------
    public func getCurrentUser(user: UserInfo? = nil, completion: @escaping(Response) -> Void) {
        get("/api/v3/get-profile", completion: completion)
    }
    
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
            if let token = currentUser.idToken {
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
        request.addValue("guard-ios", forHTTPHeaderField: "x-authing-request-from")
        request.addValue(SDK_VERSION, forHTTPHeaderField: "x-authing-sdk-version")
        request.addValue(Util.getLangHeader(), forHTTPHeaderField: "x-authing-lang")
        
        request.httpShouldHandleCookies = false
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Guardian request network error:\(error!.localizedDescription)")
                completion(Response((error as? NSError)?.code ?? 500, nil, error!.localizedDescription, nil))
                return
            }
            
            guard data != nil else {
                print("data is null when requesting \(urlString)")
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
                    print("data is not json when requesting \(urlString)")
                    completion(Response(500, nil, "only accept json data", nil))
                    return
                }
                
                guard statusCode == 200 || statusCode == 201 else {
                    print("Guardian request network error. Status code:\(statusCode.description). url:\(urlString)")
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
                print("parsing json error when requesting \(urlString)")
                completion(Response(500, nil, urlString, nil))
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

    private func setOptions(body: NSMutableDictionary, options: AuthOptions?){
        if let op = options {
            let optionsDic: NSMutableDictionary = ["scope": op.scope]
            if let tenantId = op.tenantId {
                optionsDic.setValue(tenantId, forKey: "tenantId")
            }
            if let customData = op.customData {
                optionsDic.setValue(customData, forKey: "customData")
            }
            if let autoRegister = op.autoRegister {
                optionsDic.setValue(autoRegister, forKey: "autoRegister")
            }
            if let captchaCode = op.captchaCode {
                optionsDic.setValue(captchaCode, forKey: "captchaCode")
            }
            if let passwordEncryptType = op.passwordEncryptType {
                optionsDic.setValue(passwordEncryptType, forKey: "passwordEncryptType")
            }
            body.setValue(optionsDic, forKey: "options")
        }
    }
}
