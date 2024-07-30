//
//  Request.swift
//  GitUserCore
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation
import Alamofire

final class GitUserRequest {
    
    private(set) var headers: HTTPHeaders = .init()
    private(set) var parameters: [String: Any] = [:]
    private(set) var method: HTTPMethod = .get
    
    var completed: ((Result<Data?, AFError>) -> Void)?
    
    let path: String
    
    init(path: String) {
        self.path = path
    }
    
    func setHeader(_ h: HTTPHeaders) {
        headers = h
    }
    
    func setParameter(_ p: [String: Any]) {
        parameters = p
    }
    
    func setMethod(_ m: HTTPMethod) {
        method = m
    }
}

extension Session {
    
    func add(_ r: GitUserRequest, relativeTo base: URL) async throws -> DataResponse<Data, AFError> {
        guard let url = URL(string: r.path, relativeTo: base) else {
            fatalError("Unable to find url, path: \(r.path) relative to: \(base)")
        }
        let dataTask = self.request(url, method: r.method, parameters: r.parameters, headers: r.headers)
            .validate()
            .serializingResponse(using: .data, automaticallyCancelling: false)
        
        return await dataTask.response
    }
}
