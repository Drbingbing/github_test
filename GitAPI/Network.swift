//
//  Network.swift
//  GitUserCore
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation
import Alamofire

public func initalizeNetwork(serverConfig: ServerConfig, logging: ((String) -> Void)? = nil) -> Network {
    return Network(serverConfig: serverConfig, logging: logging)
}

public final class Network {
    
    let session: Session
    let serverConfig: ServerConfig
    let logging: ((String) -> Void)?
    
    init(session: Session? = nil, serverConfig: ServerConfig, logging: ((String) -> Void)? = nil) {
        self.session = session ?? Session.default
        self.serverConfig = serverConfig
        self.logging = logging
    }
    
    public func request<T>(data: (FunctionDescription, String, DeserializeFunctionResponse<T>)) async throws -> Result<T?, Error> {
        let request = GitUserRequest(path: data.1)
        request.setParameter(data.0.parameters)
        request.setMethod(data.0.method)
        
        let response = try await session.add(request, relativeTo: serverConfig.apiURL)
        if let logging {
            logging(response.debugDescription)
        }
        switch response.result {
        case let .success(d):
            return .success(data.2.parse(d))
        case let .failure(e):
            return .failure(e)
        }
    }
}
