//
//  Util.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/3.
//

public enum ErrorCode: Int {
    case netWork = 10001
    case config = 10002
    case login = 10003
    case jsonParse = 10004
    case socialLogin = 10005
    case user = 10006
    case exchangeToken = 10007
    
    public func errorMessage() -> String {
        switch self {
        case .netWork:
            return "Network error"
        case .config:
            return "Config not found"
        case .login:
            return "Login failed"
        case .jsonParse:
            return "Json parse failed"
        case .socialLogin:
            return "Social login failed"
        case .user:
            return "User is nil"
        case .exchangeToken:
            return "ExchangeToken is nil"
        }
    }
}

public class Util {
    
    public enum PasswordStrength {
        case weak
        case medium
        case strong
    }
    
    enum KeychainError: Error {
        // Attempted read for an item that does not exist.
        case itemNotFound
        
        // Attempted save to override an existing item.
        // Use update instead of save to update existing items
        case duplicateItem
        
        // A read of an item in any format other than Data
        case invalidItemFormat
        
        // Any operation result status than errSecSuccess
        case unexpectedStatus(OSStatus)
    }
    
    private static let SERVICE_UUID: String = "service_uuid"

    public static func getDeviceID() -> String {
        let savedUUID = load()
        if (savedUUID == nil) {
            let uuid: String = NSUUID().uuidString
            try? save(uuid: uuid)
            return uuid
        } else {
            return savedUUID!
        }
    }
    
    public static func load() -> String? {
        let query = [
          kSecClass: kSecClassGenericPassword,
          kSecAttrService as String: SERVICE_UUID as AnyObject,
          kSecReturnAttributes: true,
          kSecReturnData: true
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        if (status != 0) {
            print("Try get uuid from keychain operation finished with status: \(status)")
        }
        if (result == nil) {
            return nil
        }
        
        let dic = result as! NSDictionary
        let uuidData = dic[kSecValueData] as! Data
        let uuid = String(data: uuidData, encoding: .utf8)!
//        print("uuid: \(uuid)")
        return uuid;
    }
    
    public static func save(uuid: String) throws {
        let uuidData: Data? = uuid.data(using: String.Encoding.utf8)
        let query = [
          kSecValueData: uuidData!,
          kSecAttrService: SERVICE_UUID,
          kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        
        // SecItemAdd attempts to add the item identified by
        // the query to keychain
        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )

        // errSecDuplicateItem is a special case where the
        // item identified by the query already exists. Throw
        // duplicateItem so the client can determine whether
        // or not to handle this as an error
        if status == errSecDuplicateItem {
            throw KeychainError.duplicateItem
        }

        // Any status other than errSecSuccess indicates the
        // save operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    public static func remove() {
        let query = [
          kSecClass: kSecClassGenericPassword,
          kSecAttrService: SERVICE_UUID,
        ] as CFDictionary

        SecItemDelete(query)
    }
    
    public static func encryptPassword(_ message: String, type: EncryptType?) -> String {
        
        if type == .RSA {
            
            let data: Data = Data(base64Encoded: Authing.getRSAPublicKey())!
            
            var attributes: CFDictionary {
                return [kSecAttrKeyType         : kSecAttrKeyTypeRSA,
                        kSecAttrKeyClass        : kSecAttrKeyClassPublic,
                        kSecAttrKeySizeInBits   : 2048,
                        kSecReturnPersistentRef : kCFBooleanTrue!] as CFDictionary
            }
            
            var error: Unmanaged<CFError>? = nil
            guard let secKey = SecKeyCreateWithData(data as CFData, attributes, &error) else {
                print(error.debugDescription)
                return "error"
            }
            
            let buffer = [UInt8](message.utf8)
            
            var keySize   = SecKeyGetBlockSize(secKey)
            var keyBuffer = [UInt8](repeating: 0, count: keySize)
            
            // Encrypto  should less than key length
            guard SecKeyEncrypt(secKey, SecPadding.PKCS1, buffer, buffer.count, &keyBuffer, &keySize) ==
                    errSecSuccess else { return "error" }
            
            return Data(bytes: keyBuffer, count: keySize).base64EncodedString()
            
        } else if type == .SM2 {
            
            let data = message.data(using: .utf8)
            let base64Str = data?.base64EncodedString() ?? ""
            //先对明文进行base64加密，再用GMSm2Utils 对其进行sm2加密，返回asn1编码格式的密文
            let encode = GMSm2Utils.encryptText(base64Str, publicKey: Authing.getSM2PublicKey()) ?? ""
            //把asn1编码格式的密文的 encode 解码成C1C3C2的密文字符串 = c1c3c2
            let c1c3c2 = GMSm2Utils.asn1Decode(toC1C3C2: encode) ?? ""
            //再把c1c3c2这个字符串转成 C1C2C3 模式的密文字符串 = c1c2c3 ，这个可以直接传给java端，用上面的java端实现的sm2Util进行解密
            let c1c2c3 = GMSm2Utils.convertC1C3C2(toC1C2C3: c1c3c2, hasPrefix: false) ?? ""
            return "04" + c1c2c3
        } else {
            
            return message
            
        }
    }
    

    public static func getLangHeader() -> String {
        let language = Locale.current.identifier
        switch language {
        case "zh_CN", "zh-Hans_CN", "zh-Hans_US":
            return "zh-CN"
        case "zh-Hant_CN", "zh-Hant_US", "zh-Hant_TW", "zh-Hant_HK", "zh-Hant_MO":
            return "zh-TW"
        case "ja_CN", "ja_US":
            return "ja-JP"
        default:
            return "en-US"
        }
    }

    public static func isIp(_ str: String) -> Bool {
        let reg = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
        return str.range(of: reg, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    public static func getHost(_ config: Config) -> String {
        if Util.isIp(Authing.getHost()) {
            return Authing.getHost()
        } else {
            return config.requestHostname ?? "\(config.identifier ?? "").\(Authing.getHost())"
        }
    }
    
    public static func isNull(_ s: String?) -> Bool {
        return s == nil || s?.count == 0 || s == "null"
    }

    public static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    public static func getQueryStringParameter(url: URL, param: String) -> String? {
        guard let url = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    public static func computePasswordSecurityLevel(password: String) -> PasswordStrength {
        let length = password.count
        if (length < 6) {
            return .weak
        }

        let hasEnglish = Validator.hasEnglish(password)
        let hasNumber = Validator.hasNumber(password)
        let hasSpecialChar = Validator.hasSpecialCharacter(password)
        if (hasEnglish && hasNumber && hasSpecialChar) {
            return .strong
        } else if ((hasEnglish && hasNumber) ||
                (hasEnglish && hasSpecialChar) ||
                (hasNumber && hasSpecialChar)) {
            return .medium
        } else {
            return .weak
        }
    }

}
