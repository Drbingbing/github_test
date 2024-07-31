//
//  Api0.swift
//  GitAPI
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation
import GitModel

extension Api.functions.search {
    
    public typealias Output = (FunctionDescription, String, DeserializeFunctionResponse<GitUserResult>)
    
    public static func searchUsers(_ query: String, _ page: Int) -> Output {
        let parameter: [String :Any] = [
            "q": "\(query) in:login type:user",
            "per_page": 20,
            "page": page
        ]
        return (
            FunctionDescription(method: .get, parameters: parameter),
            "/search/users",
            DeserializeFunctionResponse { data -> GitUserResult in
                return try Api.parse(json: data)
            }
        )
    }
}
