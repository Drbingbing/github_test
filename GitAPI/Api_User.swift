//
//  Api_User.swift
//  GitAPI
//
//  Created by Bing Bing on 2024/7/31.
//

import Foundation
import GitModel

extension Api.functions.user {
    
    public typealias Output = (FunctionDescription, String, DeserializeFunctionResponse<DetailedGitUser>)
    
    public static func getUser(name: String) -> Output {
        return (
            FunctionDescription(method: .get, parameters: [:]),
            "/users/\(name)",
            DeserializeFunctionResponse { data -> DetailedGitUser in
                return try Api.parse(json: data)
            }
        )
    }
}
