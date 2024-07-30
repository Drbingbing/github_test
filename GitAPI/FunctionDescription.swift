//
//  FunctionDescription.swift
//  GitUserCore
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation
import Alamofire

public final class FunctionDescription {
    public let method: HTTPMethod
    public let parameters: [String: Any]
    
    init(method: HTTPMethod, parameters: [String: Any]) {
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
