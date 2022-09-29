//
//  Response.swift
//  Authing
//
//  Created by JnMars on 2022/9/23.
//

public struct Response {

    public var statusCode: Int
    public var apiCode: Int?
    public var message: String?
    public var data: NSDictionary?
    
    init(_ statusCode: Int, _ apiCode: Int?, _ message: String?, _ data: NSDictionary?) {
        self.statusCode = statusCode
        self.apiCode = apiCode
        self.message = message
        self.data = data
    }
}
