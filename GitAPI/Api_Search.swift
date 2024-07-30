//
//  Api0.swift
//  GitAPI
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation
import GitModel

extension Api.functions.search {
    
    public static func searchUsers(_ query: String) -> (FunctionDescription, String, DeserializeFunctionResponse<GitUserResult>) {
        return (
            FunctionDescription(method: .get, parameters: ["q": query]),
            "/search/users",
            DeserializeFunctionResponse { data -> GitUserResult in
                return try Api.parse(json: data)
            }
        )
    }
}
