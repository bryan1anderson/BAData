//
//  File.swift
//  
//
//  Created by Bryan on 12/3/19.
//

import Foundation
public struct CodingWrapper<Wrapped>: Codable where Wrapped: NSCoding {
    public var wrapped: Wrapped
    
    public init(_ wrapped: Wrapped) { self.wrapped = wrapped }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        guard let object = NSKeyedUnarchiver.unarchiveObject(with: data) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "failed to unarchive an object")
        }
        guard let wrapped = object as? Wrapped else {
            throw DecodingError.typeMismatch(Wrapped.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "unarchived object type was \(type(of: object))"))
        }
        self.wrapped = wrapped
    }
    
    public func encode(to encoder: Encoder) throws {
        let data = NSKeyedArchiver.archivedData(withRootObject: wrapped)
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }
}
