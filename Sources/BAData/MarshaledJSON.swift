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

extension JSON: MarshaledObject {
    
    public func optionalAny(for key: KeyType) -> Any? {
        guard let aKey = key as? Key else { return nil }
        return self.dictionaryObject?[aKey]
    }
}

public typealias JSONResult = Swift.Result<JSON, DataError>

/// JSON Completion  Handler. Provides JSON and and error string
public typealias JSONCompletion = (_ result: JSONResult) -> Void

