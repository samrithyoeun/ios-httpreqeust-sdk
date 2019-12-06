//
//  NSURLSessionPinningDelegate.swift
//  Truemoney Cambodia
//
//  Created by Mol Monyneath on 9/17/18.
//  Copyright © 2018 Truemoney Cambodia. All rights reserved.
//
import Foundation
import Security

class URLSessionPinningDelegate: NSObject, URLSessionDelegate {

//    let pinnedCertificateHash = "ecrQoFay66tQNoJa7skJWDiyb1wzsmN0fVOFatn+N8w="
//    let pinnedPublicKeyHash = "Xx2D/DVw1RTFX95H+kEjAQ1P8DGZcN79jNRBStwOwQs="
    let pinnedCertificateHash = SKDConfiguration.certificate
    let pinnedPublicKeyHash = SKDConfiguration.publicKey

    let rsa2048Asn1Header:[UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]

    private func sha256(data : Data) -> String {
        var keyWithHeader = Data(bytes: rsa2048Asn1Header)
        keyWithHeader.append(data)
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))

        keyWithHeader.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(keyWithHeader.count), &hash)
        }


        return Data(hash).base64EncodedString()
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {

        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var secresult = SecTrustResultType.invalid
                let status = SecTrustEvaluate(serverTrust, &secresult)

                if(errSecSuccess == status) {
                    print(SecTrustGetCertificateCount(serverTrust))
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {


 
                        // Public key pinning

                        if #available(iOS 10.3, *) {
                            let serverPublicKey = SecCertificateCopyPublicKey(serverCertificate)
                            let serverPublicKeyData:NSData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil )!
                            let keyHash = sha256(data: serverPublicKeyData as Data)
                            TrueLog.printLog(logContent:"serverKey : \(keyHash) \n localKey :  \(pinnedPublicKeyHash)")
                            if (keyHash == pinnedPublicKeyHash) {
                                // Success! This is our server
                                Analytics.logEvent("trust_connetion",parameters: nil);
                                completionHandler(.useCredential, URLCredential(trust:serverTrust))
                                return
                            }
                        } else {
                            
                            
                             //--------------- Compare with Certificate StringFromServer -------
                            
                            // Certificate pinning, uncomment to use this instead of public key pinning
                            let serverCertificateData:NSData = SecCertificateCopyData(serverCertificate)
                            let certHash = sha256(data: serverCertificateData as Data)
                            print("ServerCertificate : \(certHash)  \n Local Certificate : \(pinnedCertificateHash)")

                            if (certHash == pinnedCertificateHash) {


                                // Success! This is our server
                                Analytics.logEvent("trust_connetion",parameters: nil);
                                completionHandler(.useCredential, URLCredential(trust:serverTrust))
                                return
                            }
                        }
  
                    }
                }
            }
        }

                completionHandler(.cancelAuthenticationChallenge, nil)

    }
        
        
        
   
}
