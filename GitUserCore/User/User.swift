//
//  User.swift
//  GitUserCore
//
//  Created by Bing Bing on 2024/7/31.
//

import Foundation
import GitAPI
import GitModel

extension GitUserEngine {
    
    public final class User {
        private let account: Account
        
        init(account: Account) {
            self.account = account
        }
        
        public func getUserBy(name: String) async throws -> DetailedGitUser {
            return try await _internal_getUserByName(account: account, name: name)
        }
    }
}

func _internal_getUserByName(account: Account, name: String) async throws -> DetailedGitUser {
    return try await account.network.request(Api.functions.user.getUser(name: name))
}
