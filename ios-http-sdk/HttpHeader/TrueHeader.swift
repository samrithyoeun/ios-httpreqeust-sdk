//
//  TrueHeader.swift
//  ios-resources
//
//  Created by Samrith Yoeun on 11/24/19.
//  Copyright © 2019 Sammi Yoeun. All rights reserved.
//

import Foundation

enum ChannelId: Int {
    case customer = 8
    case agent = 2
    case merchant = 3
}

struct CryptoKey {
    var secretKey: String
    var ivKey: String

}

class TrueHeader {

    public static var shared = Header()
    
    public static var accessToken = ""
    public static var refreshToken = ""
    public static var uuid: String = ""
    public static var cryptoKey: CryptoKey?
    
    public static var publicKey = ""
    private static var appVersion = ""
    private static var channelId = 0
    
    static func initialize(credential: CredentialKey,
                           cryptoKey: CryptoKey,
                           channelId: ChannelId,
                           appVersion: String,
                           accessToken: String = "",
                           uuid: String) {
        
        TrueHeader.publicKey = publicKey
        TrueHeader.shared = Header(credential: credential)
        TrueHeader.appVersion = appVersion
        TrueHeader.channelId = channelId.rawValue
        TrueHeader.accessToken = accessToken
        TrueHeader.uuid = uuid
        
        
        
    }
    
    static func getApiAuthorization() -> [String: String] {
        let key = TrueHeader.shared.getKey()
        var param = TrueHeader.getDefaultHeader()
        let credentialData = "\(key.clientId):\(key.clientSecret)".data(using: String.Encoding.utf8)!
                   let base64Credentials = credentialData.base64EncodedString(options: [])
                   
                   let base64 = "Basic \(base64Credentials)"
        param["authorization"] = base64
        return param
    }
    
    
    static func getApiAccessToken() -> [String: Any] {
        let key = TrueHeader.shared.getKey()
        var param = TrueHeader.getDefaultHeader()
        
        param["authorization"] = "Bareer \(key.clientId):\(key.clientSecret)"
        return param
    }
    
    class func getDefaultHeader() -> [String: String] {
        
        var param = [String: String]()
        let key = TrueHeader.shared.getKey()

        param["client_id"] = key.clientId
        param["client_secret"] = key.clientSecret
        param["content-type"] = "application/json;charset=utf-8"
        param["app_version"] = TrueHeader.appVersion
        param["channel_id"] = "\(TrueHeader.channelId)"
        param["device_unique_reference"] = "iOS.\(TrueHeader.uuid)"
        
        return param
    }
    
    private init() {}
}

struct Header {
    
    var credential: CredentialKey!
    
    init() {
        credential = nil
    }
    
    init(credential: CredentialKey) {
        self.credential = credential
    }
   
    func getKey() -> CredentialKey {
        guard let credential = credential else {
            fatalError("Need to provide credential key")
        }
        return credential
    }
    
}

