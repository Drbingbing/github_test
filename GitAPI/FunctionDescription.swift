//
//  FunctionDescription.swift
//  GitUserCore
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation

public final class FunctionDescription {
    public let method: String
    public let parameters: [String: Any]
    
    init(method: String, parameters: [String: Any]) {
        self.method = method
        self.parameters = parameters
    }
}

public final class DeserializeFunctionResponse<T> {
    private let f: (Data?) -> T?
    
    public init(_ f: @escaping (Data?) -> T?) {
        self.f = f
    }
    
    public func parse(_ data: Data?) -> T? {
        return self.f(data)
    }
}
