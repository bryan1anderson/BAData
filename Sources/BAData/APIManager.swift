//
//  APIManager.swift
//  Training
//
//  Created by Bryan on 9/19/16.
//  Copyright © 2016 Bryan Lloyd Anderson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Marshal
//import RxAlamofire
import RxSwift
import RxCocoa
import EMUtilities
import Reachability

public protocol APIManagerProtocol: RequestInterceptor {
    var baseURL: String { get }
    var serverTrustPolicies: [String: ServerTrustEvaluating] { get }
    var defaultManager: Alamofire.Session { get set }
    var delegate: APIManagerDelegate? { get set }
    var token: String? { get }
    var defaults: UserDefaults { get }
    var version: String? { get }
    func removeAuthToken()
}

public extension APIManagerProtocol {
        /// Initiantes an HTTP Request
        ///
        /// - parameter method:     .get, .post, .put, etc
        /// - parameter url:        The url of the remote endpoint
        /// - parameter params:     The parameters to pass
        /// - parameter authToken:  Optional Authorization Header Token
        /// - parameter completion: Returns JSON or Error String
        func request(method: HTTPMethod, url: String, params: [String: Any]? = nil, encoding: ParameterEncoding = JSONEncoding.prettyPrinted, authToken: String? = nil, completion: JSONCompletion? = nil) {
            do {
                var headers: [String: String] = [:]
                
                if let token = authToken ?? token {
                    headers["Authorization"] =  "Bearer " + token
                }
                
                if let version = version {
                    headers["Accept-Version"] = version
                }
                //headers?["Content-Type"] = "application/x-www-form-urlencoded charset=utf-8"
                //TODO: Handle 500 and 403's
                
                var urlRequest = try URLRequest(url: url, method: method, headers: HTTPHeaders(headers))
                
                let reachability = try Reachability()
                
                if reachability.connection == .unavailable {
                    urlRequest.cachePolicy = .returnCacheDataElseLoad
                } else {
                    urlRequest.cachePolicy = .useProtocolCachePolicy
                }
                
                let encodedRequest = try encoding.encode(urlRequest, with: params)
                
                let request = defaultManager.request(encodedRequest).responseJSON { (response) in
                    
                    self.process(response: response)
                    
                    do {
                        guard let data = response.data else { throw DataError.failed(response: response) }
                        let json = try JSON(data: data)
                        completion?(.success(json))
                    }
                    catch {
                        
                        completion?(.failure(.failedResponse(error)))
                    }
                    
                }
            } catch {
                completion?(.failure(.failedResponse(error)))
            }
            
//            let request = defaultManager.request(url, method: method, parameters: params, encoding: encoding, headers: HTTPHeaders(headers))
            
        }

        
        /// Initiantes an HTTP Upload Request
        ///
        /// - parameter method:     .get, .post, .put, etc
        /// - parameter url:        The url of the remote endpoint
        /// - parameter params:     The parameters to pass
        /// - parameter authToken:  Optional Authorization Header Token
        /// - parameter completion: Returns JSON or Error String
        func upload(method: HTTPMethod, url: String, params: [UploadParam], dataParams: [UploadDataParam], progressComplete: ((_ fractionComplete: Double) -> Void)? = nil, completion: JSONCompletion? = nil) {
            var headers: [String: String] = ["Content-Type": "application/x-www-form-urlencoded charset=utf-8"]
            
            if let token = token {
                headers["Authorization"] =  "Bearer " + token
            }

    //
            let uuid = UUID().uuidString
            

            defaultManager.upload(multipartFormData: { (multipartFormData) in
                for param in params {
                    multipartFormData.append(param.data.data(using: .utf8, allowLossyConversion: true)!, withName: param.name)
                    
                }
                
                for param in dataParams {
                    
                    multipartFormData.append(param.data, withName: param.name, fileName: "\(uuid).\(param.suffix)", mimeType: param.type.rawValue)

                }
                
            }, to: url, usingThreshold: MultipartFormData.encodingMemoryThreshold, method: method, headers: HTTPHeaders(headers), interceptor: self).responseJSON { (response) in
                do {
                    guard let data = response.data else { throw DataError.failed(response: response) }
                    let json = try JSON(data: data)
                    completion?(.success(json))
                }
                catch {
                    
                    completion?(.failure(.failed(response: response)))
                }

            }.uploadProgress { (progress) in
                progressComplete?(progress.fractionCompleted)
            }
            
    //        progressComplete?(progress.fractionCompleted)


    //        defaultManager.upload(multipartFormData: { (multipartFormData) in
    //
    //        }, usingThreshold: MultipartFormData.encodingMemoryThreshold, to: url, method: method, headers: headers) { (encodingResult) -> Void in
    //
    //
    //
    //
    //
    //        }
            
        }

        
        /// Handle the status code returned on requests
        ///
        /// - Parameter statusCode: Returned status code
        func process(response: AFDataResponse<Any>) {
            let statusCode = response.response?.statusCode
            
            if statusCode == 401 {
                // indicates that we should NOT automatically login
                //            SwopGlobalVars.sharedInstance.isManualLogout = true
                
                // make sure if we close the app we cannot auto-login
                removeAuthToken()
                delegate?.shouldSetGlobal()
                let data = response.data ?? Data()
//                let json = try? JSON(data: data)
                
    //            print(response.request?.url, response.error, response.result.error, json, response.request?.allHTTPHeaderFields)
                delegate?.didReceive401(response: response)
    //            Answers.logCustomE vent(withName: "Encountered 401", customAttributes: [:])
                
                // get the main window
            } else if statusCode?.array.first != 2 {
    //            print(statusCode)
                if let data = response.data {
                    
                    //This logic determins if the error has already been printed, comment it all out when not debugging
                    do {
                        let json = try JSON(data: data)
                        if json == JSON.null {
                            return
                        } else {
                            delegate?.didReceiveFailed(response: response)
    //                        print(response.request?.url, response.error, response.result.error)
                        }
                    } catch {
                        delegate?.didReceiveFailed(response: response)
    //                    print(error.localizedDescription, response.request?.url, response.error, response.result.error)
                    }
                } else {
                    delegate?.didReceiveFailed(response: response)
    //                print(response.request?.url, response.error, response.result.error)
                }
            }
        }

        
        

}


//enum JSONResult {
//    case success(json: JSON)
//    case failure(Error)
//    
//    func get() throws -> JSON {
//        switch self {
//        case .success(let json):
//            return json
//        case .failure(let error):
//            throw error
//        }
//    }
//}




public enum UploadMimeType: String {
    case mov = "video/quicktime"
    case jpg = "image/jpeg"
    case null = "application/x-empty"
}

//String params for uploads
public struct UploadParam {
    public let name: String
    public let data: String

    public init(name: String, data: String) {
        self.name = name
        self.data = data
    }
}

//For complex upload data params, such as images and videos
public struct UploadDataParam {
    public let data: Data
    public let type: UploadMimeType
    public let name: String
    public let suffix: String
    
    public init(data: Data, type: UploadMimeType, name: String, suffix: String) {
        self.data = data
        self.type = type
        self.name = name
        self.suffix = suffix
    }
}

public typealias UploadableFile = (data: Data, fileName: String, paramName: String, type: UploadMimeType)
public typealias ErrorString = String



public protocol APIManagerDelegate {
    
    func didReceive401(response: AFDataResponse<Any>)
    func didReceiveFailed(response: AFDataResponse<Any>)
    func shouldSetGlobal()
}



public extension JSON {
    func toArray() throws -> [JSON] {
        guard self != .null else { throw DataError.optional(DataError.failure("JSON.toArray.isNull"))}
        guard let array = self.array
            else { throw DataError.failure("JSON.toArray \(self.debugDescription)")}
        return array
    }
}
