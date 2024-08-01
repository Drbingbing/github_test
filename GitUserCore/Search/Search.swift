//
//  GitUserSearch.swift
//  GitUserCore
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation
import GitAPI
import GitModel

extension GitUserEngine {
    
    public final class SearchUser {
        private let account: Account
        
        init(account: Account) {
            self.account = account
        }
        
        public func searchUsers(query: String, page: Int) async throws -> GitUserResult {
            return try await _internal_searchUsers(account: account, query: query, page: page)
        }
    }
}

func _internal_searchUsers(account: Account, query: String, page: Int) async throws -> GitUserResult {
    let result = try await account.network.request(Api.functions.search.searchUsers(query, page))
    return result
}
