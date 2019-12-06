//
//  ViewController.swift
//  ios-http-sdk
//
//  Created by Yoeun Samrith on 12/6/19.
//  Copyright © 2019 Yoeun Samrith. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let clientSecret = "vwvoPanQUWO3Ie81t5i48nWTanYluAM6oVQLmjzfSPnLe0OshoPEul3fehjg37Ka"
        let clientId = "K5ZRQOTOQ6UYM95Y1WPMC9E0UYQTYLNE"
        let fingerprint = "kh.com.truemoney.agentapp;68:9B:40:68:93:15:14:E0:8E:5B:0B:38:17:DD:9A:EF:CB:48:A3:47A"
        
        let credential = CredentialKey(clientId: clientId, clientSecret: clientSecret, publicKey: "")
        TrueHeader.initialize(credential: credential,
                              cryptoKey: CryptoKey(secretKey: fingerprint, ivKey: ""),
                              channelId: .agent,
                              appVersion: "4.2",
                              uuid: "ffffffff-e05d-e3bb-4039-a61a271e9e16-1568796164577")
        
        TrueRequest.initialize(baseUrl: "https://local-channel-gateway-dev.dev.truemoney.com.kh/")
        
        var param = [String: String]()
        param["grant_type"] = "client_credentials"
        print("*** \(TrueHeader.getApiAuthorization())\n")
        
        let endpoint = "local-channel-adapter/oauth/token"
        TrueRequest.post(endPoint: endpoint,
                         headers: TrueHeader.getApiAuthorization(),
                         parameters:  param) { (json, code, error) in
                            
            print("=== \(json) \(code) \(error)")
        }
        
        TrueRequest.postMultiForm(endPoint: endpoint,
                                  headers: TrueHeader.getApiAuthorization(),
                                  parameters: param) { (json, code, error) in
            print("*** \(json) \(code) \(error)")
        }
    }


}



