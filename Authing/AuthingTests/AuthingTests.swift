//
//  AuthingTests.swift
//  AuthingTests
//
//  Created by JnMars on 2022/9/21.
//

import XCTest
@testable import Authing

class AuthingTests: XCTestCase {
    
    var TIMEOUT = 60.0
    var account: String  = "ci"
    var password: String  = "111111"
    var emailAddress: String = "test@authing.com"
    var emailCode: String = ""
    var phone: String = "18800000000"
    var phoneCode: String = ""
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Authing.start("6244398c8a4575cdb2cb5656");
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

    }
    
    //MARK: ---------- Basic Authentication ----------
    func testRegisterByEmailNormal() throws {
        let expectation = XCTestExpectation(description: "register by email")
        let option = RegisterOptions()
        option.passwordEncryptType = .SM2
        AuthClient().registerByEmail(email: "v3@102412.com", password: "123456", option) { res in
            XCTAssert(res.statusCode == 200)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testRegisterByEmailCode() throws {
        let expectation = XCTestExpectation(description: "register by emailcode")
        let option = RegisterOptions()
        AuthClient().registerByEmailCode(email: "563438383@qq.com", passCode: "6479", option) { res in
            XCTAssert(res.statusCode == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    

    func testSendEmail() throws {
        let expectation = XCTestExpectation(description: "send email")
        AuthClient().sendEmail(email: "872468553@qq.com", channel: .bind_email) { res in
            XCTAssert(res.statusCode == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }

    func testRegisterByPhoneCode() throws {
        let expectation = XCTestExpectation(description: "register by phone code")
        let option = RegisterOptions()
        AuthClient().registerByPhoneCode(phoneCountryCode: nil, phone: "18401252136", passCode: "5910", option) { res in
            XCTAssert(res.statusCode == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
                                         
     func testSendSMS() throws {
         let expectation = XCTestExpectation(description: "send sms")
         AuthClient().sendSms(phone: "18401252136", channel: .unbind_mfa) { res in
             XCTAssert(res.statusCode == 200)
             expectation.fulfill()
         }
         wait(for: [expectation], timeout: TIMEOUT)
     }
    
    func testUnBindPhone() throws {
                
        let expectation = XCTestExpectation(description: "unbind phone")
        
        AuthClient().unbindPhone(passCode: "5604") { res in
            XCTAssert(res.statusCode == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testRegisterByUsername() throws {
        let expectation = XCTestExpectation(description: "register by username")
        let option = RegisterOptions()
        AuthClient().registerByUsername(username: "testUser123", password: "123456", option) { res in
            XCTAssert(res.statusCode == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    
    func testLoginByEmail() throws {
        let expectation = XCTestExpectation(description: "login by email")
        let option = LoginOptions()
        option.passwordEncryptType = .NONE
        AuthClient().loginByEmail(email: "v3@1024.com", password: "123456", option) { res in
            XCTAssert(res.statusCode == 200)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testLoginByEmailWithRsaEncryption() throws {
        let expectation = XCTestExpectation(description: "login by email with RSA encryption")
        let option = LoginOptions()
        option.passwordEncryptType = .RSA
        AuthClient().loginByEmail(email: "v3@1024.com", password: "123456", option) { res in
            XCTAssert(res.statusCode == 200)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testLoginByEmailWithSm2Encryption() throws {
        let expectation = XCTestExpectation(description: "login by email with SM2 encryption")
        let option = LoginOptions()
        option.passwordEncryptType = .SM2
        AuthClient().loginByEmail(email: "v3@1024.com", password: "123456", option) { res in
            XCTAssert(res.statusCode == 200)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testGetSystemConfig() {
        let expectation = XCTestExpectation(description: "get system config")
        AuthClient().getSystemConfig { res in
            XCTAssert(res.statusCode == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
}
