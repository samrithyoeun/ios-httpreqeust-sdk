//
//  Crypt.swift
//  CryptoLib
//
//  Created by Thona on 11/16/18.
//

import UIKit
import CryptoSwift
import CommonCrypto

open class Crypt{
    
    public static let shared = Crypt()
    private init(){}
    
    open func encrypt( key:String, iv:String ,plaintext:String) -> String {
        var encrypted = ""
        
        do {
            // Key convertion to 32 keyleng, cuz encryption support from 16 to 32 keyleng only
            let keyArray = Array(key.utf8)
            let keyData = Data(bytes: keyArray)
            let finalKey:[UInt8] = keyData.sha256().bytes
            
            let ivArray = Array(iv.utf8)
            let ivData = Data(bytes: ivArray)
            let finalIV = ivData.sha256().bytes
            
            
            
            // IV convertion to 16 keyleng, cuz encryption support from 16 keyleng only
            let gcm = GCM(iv: finalIV, mode: .combined)
            let aes = try AES(key: finalKey, blockMode: gcm, padding: .noPadding)
            //print(finalIV.count)
            //encryption
            let encryptByte = try aes.encrypt(plaintext.bytes)
            encrypted = encryptByte.toBase64() ?? ""
            return encrypted
        }catch{
            print("encrypt is fail")
        }
        
        return encrypted
    }
    
    open func decrypt(key:String, iv:String,encrypted:String) -> String {
        var decrypted = ""
        
        do {
            // Key convertion to 32 keyleng, cuz encryption support from 16 to 32 keyleng only
            let keyArray = Array(key.utf8)
            let keyData = Data(bytes: keyArray)
            let finalKey:[UInt8] = keyData.sha256().bytes
            
            let ivArray = Array(iv.utf8)
            let ivData = Data(bytes: ivArray)
            let finalIV = ivData.sha256().bytes
            
            let gcm = GCM(iv: finalIV, mode: .combined)
            let aes = try AES(key: finalKey, blockMode: gcm, padding: .noPadding)
            
            //decription
            let encrypteByte = Data(base64Encoded: encrypted)?.bytes
            let decrypteByte = try aes.decrypt(encrypteByte ?? "".bytes)
            decrypted = String(bytes: decrypteByte, encoding: .utf8) ?? ""
            
            return decrypted
        }catch{
            print("decrypt is fail")
        }
        
        return decrypted
    }
    
    open func hash256(plaintext:String ,with key : String)->String{
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count, plaintext, plaintext.count, &digest)
        let data = Data(bytes: digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
    
    
}

