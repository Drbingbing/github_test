//
//  GitUserSearch.swift
//  GitUserCore
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation
import GitAPI

extension GitUserEngine {
    
    public final class SearchUser {
        private let account: Account
        
        init(account: Account) {
            self.account = account
        }
        
        public func searchUsers(query: String) async throws -> [String] {
            return try await _internal_searchUsers(account: account, query: query)
        }
    }
}

func _internal_searchUsers(account: Account, query: String) async throws -> [String] {
    let result = try await account.network.request(data: Api.functions.search.searchUsers(query))
    switch result {
    case .success(let success):
        return success ?? []
    case .failure:
        return []
    }
}
