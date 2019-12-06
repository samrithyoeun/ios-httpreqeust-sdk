//
//  TrueRequest.swift
//  ios-resources
//
//  Created by Samrith Yoeun on 11/23/19.
//  Copyright © 2019 Sammi Yoeun. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum Result<T> {
    case success(T)
    case failed(String)
}

class TrueRequest {
    
    private static var apiPath = ""
    
    private init() {}
    
    public static func initialize(baseUrl: String) {
        self.apiPath = baseUrl
    }
    
    typealias RestResponse = ((_ response: JSON, _ responseCode: Int?, _ error: Error?) -> ())
    
    /**
     Upload Image to Server
     
     - Important Parameter
     - withName: the fileName that may require by Server
     - fileName: the actual file name of the image, we can use the concat the string to avoid duplicating on Sever
     - Callback:
     - fileName: the fileName returned by Server
     
     */
    static func uploadImage(endPoint: String, headers: [String: String] = [:], data: Data, withName name: String, fileName: String, mimeType: String = "image/jpeg", imageExtension: String = ".jpg", callback: @escaping (_ fileName: Result<String>) -> ()) {
        let url = TrueRequest.apiPath + endPoint
        //        let httpHeader = HttpHeader(develEnv: <#CredentialKey#>)
        let urlRequest = try! URLRequest(url: url, method: .post, headers: headers)
        
        Alamofire.upload(multipartFormData: { (multipartData: MultipartFormData) -> Void in
            multipartData.append(data, withName: name, fileName: "\(name)\(imageExtension)", mimeType: mimeType)
        }, with: urlRequest, encodingCompletion: { (result: Alamofire.SessionManager.MultipartFormDataEncodingResult) in
            switch result {
            case .failure(let error):
                callback(Result.failed(error.localizedDescription))
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    print("progress : \(progress.fractionCompleted)")
                })
                upload.responseJSON { response in
                    
                    if let jsonResponse = response.result.value as? [String: Any] {
                        print(jsonResponse)
                        if let data = jsonResponse["data"] {
                            if let json = JSON(rawValue: data) {
                                callback(Result.success(json[0]["filename"].stringValue))
                            }
                        } else {
                            if let json = JSON(rawValue: jsonResponse) {
                                if let code = json["statusCode"].int {
                                    if code >= 400 {
                                        callback(Result.failed(json["message"].stringValue))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    static func get(endPoint: String, headers: [String: String] = [:], parameters: Parameters = [:], callback: @escaping RestResponse) {
        
        let url = TrueRequest.apiPath + endPoint
        print("endpoint ==== \(url)")
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding(), headers: headers)
            .validate()
            .responseString(encoding: .utf8) { (response: DataResponse<String>) in
                handle(response: response, responseCode: response.response?.statusCode, callback: callback)
        }
    }
    
    static func getWithoutPrefix(endPoint: String, headers: [String: String] = [:], parameters: Parameters = [:], callback: @escaping RestResponse) {
        
        let url = endPoint
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding(), headers: headers)
            .validate()
            .responseString(encoding: .utf8) { (response: DataResponse<String>) in
                handle(response: response, responseCode: response.response?.statusCode, callback: callback)
        }
    }
    
    static func post(endPoint: String, headers: [String: String] = [:], parameters: Parameters = [:], callback: @escaping RestResponse) {
        
        let url = TrueRequest.apiPath + endPoint
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding(), headers: headers)
            .validate()
            .responseString(encoding: .utf8) { (response: DataResponse<String>) in
                handle(response: response, responseCode: response.response?.statusCode, callback: callback)
        }
    }
    
    static func postMultiForm(endPoint: String, headers: [String: String] = [:], parameters: [String: String], callback: @escaping RestResponse) {
        
        let url = TrueRequest.apiPath + endPoint
        var urlRequest = try! URLRequest(url: url, method: .post, headers: headers)
        print("\n*** param\(parameters)")
        
        var param = ""
        for (key, value) in parameters {
            param += "\(key)=\(value)"
        }
        
        urlRequest.httpBody = param.data(using: String.Encoding.utf8)
    
        Alamofire.upload(multipartFormData: { (multipartData: MultipartFormData) -> Void in
//            multipartData.append(<#T##data: Data##Data#>, withName: <#T##String#>)
            multipartData.append(param.data(using: String.Encoding.utf8)!, withName: "data")
//                              multipartData.append(data, withName: name, fileName: "\(name)\(imageExtension)", mimeType: mimeType)
        
            
        }, with: urlRequest, encodingCompletion: { (result: Alamofire.SessionManager.MultipartFormDataEncodingResult) in
            switch result {
            case .failure(let error):
                break
                //                    callback(Result.failed(error.localizedDescription), code)
                
            case .success(let upload, _, _):
                break
            }
            
        })
        
        
    }
    
    static func put(endPoint: String, headers: [String: String] = [:], parameters: Parameters = [:], callback: @escaping RestResponse) {
        
        let url = TrueRequest.apiPath + endPoint
        
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseString(encoding: .utf8) { (response: DataResponse<String>) in
                handle(response: response, responseCode: response.response?.statusCode, callback: callback)
        }
    }
    
    static func delete(endPoint: String, headers: [String: String] = [:], parameters: Parameters = [:], callback: @escaping RestResponse) {
        let url = TrueRequest.apiPath + endPoint
        Alamofire.request(url, method: .delete, parameters: parameters, headers: headers)
            .validate()
            .responseString(encoding: .utf8) { (response: DataResponse<String>) in
                callback(JSON.null, response.response?.statusCode, nil)
        }
    }
    
    
    private static func handle(response: DataResponse<String>, responseCode: Int?, callback: RestResponse) {
        guard let resultValue = response.value else {
            
            if let data = response.data, let json = try? JSON(data: data) {
                callback(json, responseCode, response.error)
            }
            //            else {
            //                callback(InternetConnectionManager.shared.isInternetConnected == false ? JSON(["message": "No internet connection."]) : JSON(["message": response.error?.localizedDescription ?? ""]), responseCode, response.error)
            //            }
            return
        }
        let json = JSON(parseJSON: resultValue)
        callback(json, responseCode, response.error)
    }
}



