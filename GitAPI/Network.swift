//
//  Network.swift
//  GitUserCore
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation
import Alamofire

public func initalizeNetwork(serverConfig: ServerConfig) -> Network {
    return Network(serverConfig: serverConfig)
}

public final class Network {
    
    let session: Session
    let serverConfig: ServerConfig
    
    init(session: Session? = nil, serverConfig: ServerConfig) {
        self.session = session ?? Session.default
        self.serverConfig = serverConfig
    }
    
    public func request<T>(data: (FunctionDescription, URL, DeserializeFunctionResponse<T>)) async throws -> Result<T?, Error> {
        let request = GitUserRequest(path: data.1)
        request.setParameter(data.0.parameters)
        request.setMethod(.init(rawValue: data.0.method))
        
        let result = try await session.add(request)
        
        switch result {
        case let .success(d):
            return .success(data.2.parse(d))
        case let .failure(e):
            return .failure(e)
        }
    }
}
