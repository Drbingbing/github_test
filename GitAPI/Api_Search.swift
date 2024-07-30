//
//  Api0.swift
//  GitAPI
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation

extension Api.functions.search {
    
    public static func searchUsers(_ query: String) -> (FunctionDescription, String, DeserializeFunctionResponse<[String]>) {
        return (
            FunctionDescription(method: .get, parameters: ["q": query]),
            "/search/users",
            DeserializeFunctionResponse { data in
                guard let data else { return nil }
                return []
            }
        )
    }
}
