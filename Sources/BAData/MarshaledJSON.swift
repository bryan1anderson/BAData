//
//  MarshaledJSON.swift
//  
//
//  Created by Bryan on 11/16/19.
//

import Foundation
import SwiftyJSON
import EMUtilities
import Marshal
import Alamofire

extension JSON: MarshaledObject {
    
    public func optionalAny(for key: KeyType) -> Any? {
        guard let aKey = key as? Key else { return nil }
        return self.dictionaryObject?[aKey]
    }
}

public enum DataError: Error {
    case failure(String)
    case failed(response: AFDataResponse<Any>)
    case failedResponse(Error)
    case jsonNil(String)
    case missingValue(String)
    case failedInit(String)
    case failedInitWithJSON(json: JSON?, description: String)
    case optional(Error)
    case failedEncodeURL
    case realmMissingAddressID
}

public typealias JSONResult = Swift.Result<JSON, DataError>

/// JSON Completion  Handler. Provides JSON and and error string
public typealias JSONCompletion = (_ result: JSONResult) -> Void

