//
//  User.swift
//  GitModel
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation

public struct GitUserResult: Decodable {
    
    public let items: [GitUser]
    public let totalCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case items
        case totalCount = "total_count"
    }
    
    public init(items: [GitUser], totalCount: Int) {
        self.items = items
        self.totalCount = totalCount
    }
}

public struct GitUser: Decodable, Equatable {
    
    public let login: String
    public let id: Int
    public let avatarUrl: String
    public let score: Double
    public let reposUrl: String
    public let followersUrl: String
    public let siteAdmin: Bool
    
    private enum CodingKeys: String, CodingKey {
        case login, score, id
        case avatarUrl = "avatar_url"
        case reposUrl = "repos_url"
        case followersUrl = "followers_url"
        case siteAdmin = "site_admin"
    }
    
    public init(login: String, id: Int, avatarUrl: String, score: Double, reposUrl: String, followersUrl: String, siteAdmin: Bool) {
        self.login = login
        self.id = id
        self.avatarUrl = avatarUrl
        self.score = score
        self.reposUrl = reposUrl
        self.followersUrl = followersUrl
        self.siteAdmin = siteAdmin
    }
}
