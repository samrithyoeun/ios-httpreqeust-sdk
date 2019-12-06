//
//  TrueRequestAccessToken.swift
//  RequestTrueAPI
//
//  Created by seyha on 7/18/16.
//  Copyright © 2016 Truemoney Cambodia. All rights reserved.
//

import UIKit

class TrueRequestAccessToken: NSObject , URLSessionDelegate{
    static var url = ""
    
    var session = Foundation.URLSession()
    var request = NSMutableURLRequest()
    var key : String = ""
    var grand_type : String = ""
    
    override init() {
        self.request.httpBody = nil;
        self.request.url = Foundation.URL(string: TrueRequestAccessToken.url)
        self.request.addValue(Bundle.main.bundleIdentifier!, forHTTPHeaderField: "Origin")
    }
    
    func send() -> Foundation.URLSession{
        let configuration = URLSessionConfiguration.default
        
//        self.session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue:OperationQueue.main)
         self.session = Foundation.URLSession(configuration: configuration, delegate: URLSessionPinningDelegate(), delegateQueue:OperationQueue.main)
        return self.session;
    }
    
    //this will not work when using URLSessionPinningDelegate()
    func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didReceiveChallenge challenge: URLAuthenticationChallenge, completionHandler: (Foundation.URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
       // completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        
        if let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
        } else {
            print("unknown state. error: \(String(describing: challenge.error))")
        }
    }
    
    func setMethod(_ method: String) -> Void {
        self.request.timeoutInterval = 65
        self.request.httpShouldHandleCookies=true
        self.request.httpMethod = method
    }
    
    func setHeader() -> Void
    {
        
        var user = Configure.client_id()
        var password = Configure.client_secret()
        
        if( grand_type.caseInsensitiveCompare("grand_type_credential") == .orderedSame){
            
            user = Configure.client_id_credential()
            password = Configure.client_secret_credential()
            
        }
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let base64 = "Basic \(base64Credentials)"
         print("base64Credentials= \(base64)")
        //            let header = ["Authorization":"\(base64)","Certificate-Fingerprint":"\(TrueSecurity.getFingerPrint())"]
        let header = ["Authorization":"\(base64)"]
         print("Header : \(header)")
        
        self.request.allHTTPHeaderFields = header
        
    }
    
    func setBody(_ userName: String, password : String) -> Void
    {
        
        var StringParam: String = ""
        
        if(userName != ""){
            grand_type = "grand_type_password"
            var SesID = key.getStringByIndex(splitStr: ProfilePref.getsecurCode(), getIndex: 1)
            
            let  params: Dictionary<String, AnyObject> =
                [
                    "platform":"ios" as AnyObject,
                    "appVersion":TrueAccessDevice.getAppVersion() as AnyObject,
                    "grant_type": "\(Configure.grand_type_password())" as AnyObject,
                    "client_id": "\(Configure.client_id())" as AnyObject,
                    "device_id" : "\(TrueAccessDevice.getDeviceUUID())" as AnyObject,
                    "username" : "\(Crypt.shared.encrypt(key: TrueSecurity.getFingerPrint(), iv: ProfilePref.getsecurCode() + "\(Crypt.shared.hash256(plaintext: SesID, with: TrueSecurity.getFingerPrint()))", plaintext: userName))" as AnyObject,
                    "password" : "\(Crypt.shared.encrypt(key: TrueSecurity.getFingerPrint(), iv: ProfilePref.getsecurCode() + "\(Crypt.shared.hash256(plaintext: SesID, with: TrueSecurity.getFingerPrint()))", plaintext: password))" as AnyObject,
                    "userAccountId": "\(Crypt.shared.encrypt(key: TrueSecurity.getFingerPrint(), iv: ProfilePref.getsecurCode() + "\(Crypt.shared.hash256(plaintext: SesID, with: TrueSecurity.getFingerPrint()))", plaintext: ProfilePref.getuserAccountID()))" as AnyObject,
                    "currentLanguage":LanguagePref.getLanguage() as AnyObject
            ]
             print("Key encrypt login \(key)")
             print("username: \(Crypt.shared.encrypt(key: TrueSecurity.getFingerPrint(), iv: ProfilePref.getsecurCode() + "\(Crypt.shared.hash256(plaintext: SesID, with: TrueSecurity.getFingerPrint()))", plaintext: userName)) and Password: \(Crypt.shared.encrypt(key: TrueSecurity.getFingerPrint(), iv: ProfilePref.getsecurCode() + "\(Crypt.shared.hash256(plaintext: SesID, with: TrueSecurity.getFingerPrint()))", plaintext: password))")
            
//             print("decrypt UserName :\(TrueCryptor.decrypt(TrueCryptor.encrypt(userName, password: self.key), password: key)!)")
//             print("decrypt Pass :\(TrueCryptor.decrypt(TrueCryptor.encrypt(password, password: self.key), password: key)!)")
            
            for (key, value) in params {
                let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                StringParam += "\(escapedKey!)=\(escapedValue!)&"
            }
            
        }else{
            StringParam = "grant_type=\(Configure.grand_type_credential())"
            grand_type = "grand_type_credential"
        }
        
         print("request body : \(StringParam)")
        
        let bodyRequest = StringParam.toASCII().data(using: String.Encoding.utf8)
        
        self.request.httpBody = bodyRequest
    }
    
    func setPath(_ path: String) -> Void {
        self.request.url = Foundation.URL(string: TrueRequestAccessToken.url+path);
    }
    
    func setSecretKey(_ key : String) {
        self.key = key
    }
    
    func getRequest() -> URLRequest {
        return self.request as URLRequest
    }
    
}
