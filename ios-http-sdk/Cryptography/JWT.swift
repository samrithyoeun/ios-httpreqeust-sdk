//
//  JWT.swift
//  ios-http-sdk
//
//  Created by Thona on 12/6/19.
//  Copyright © 2019 Yoeun Samrith. All rights reserved.
//

import UIKit

import UIKit

class JWT {
    
    static func getJWT(_ hash : String, deviceID : String, key : String) -> String {
        
        let bodyJWT: [String: String] =
            [
                "hash": hash,
                "deviceId": deviceID,
                "appVersion": TrueHeader.appVersion
        ]
        let encodeJWT = try! Jwt.encode(withPayload: bodyJWT, andKey: key, andAlgorithm: HS256)
        
        return encodeJWT
    }
    
    static func getJWT( _ deviceID : String, key : String) -> String {
        
        let bodyJWT: [String: String] =
            [
                "deviceId": deviceID ,
                "appVersion": TrueHeader.appVersion
        ]
        let encodeJWT = try! Jwt.encode(withPayload: bodyJWT, andKey: key, andAlgorithm: HS256)
        return encodeJWT
    }
    
    static func getClaim(_ jwt : String, key : String) -> String {
        var jwt_decode : String = ""
        
        //        var decodeJWT : NSDictionary?
        
        if let decode = try? Jwt.decode(withToken: jwt, andKey: key, andVerify: true) {
            
            do {

                if JSONSerialization.isValidJSONObject(decode) {
                    _ = try JSONSerialization.data(withJSONObject: decode)
                    
                    if let jsonObject = try?  JSONSerialization.data(withJSONObject: decode, options: JSONSerialization.WritingOptions.prettyPrinted){
                        jwt_decode = NSString(data: jsonObject, encoding: String.Encoding.utf8.rawValue)! as String
                    }
                    
                } else {
                    // not valid - do something appropriate
                    print("Invalid type in JSON write")
                    
                }
            }
            catch {
                print("Some vague internal error: \(error)")
                
            }
            
        }else{
           print("Decoding failure: Signature verification failed")
            let key = TrueHeader.cryptoKey?.secretKey
            
            if let decode = try? Jwt.decode(withToken: jwt, andKey: key, andVerify: true){
                //             TrueLog.printLog(logContent:"JWT Decode String : \(decode)")
                do {
                    //                let obj = ["bad input" : NSDate()]
                    if JSONSerialization.isValidJSONObject(decode) {
                        _ = try JSONSerialization.data(withJSONObject: decode)
                        
                        if let jsonObject = try?  JSONSerialization.data(withJSONObject: decode, options: JSONSerialization.WritingOptions.prettyPrinted){
                            jwt_decode = NSString(data: jsonObject, encoding: String.Encoding.utf8.rawValue)! as String
                        }
                        
                    } else {
                        // not valid - do something appropriate
                         print("Invalid type in JSON write'")
                        
                    }
                }
                catch {
                    
                     print("Some vague internal error: \(error)")
                    
                }
                
                
            }
            
        }
        
        return jwt_decode
    }
    
    
}
