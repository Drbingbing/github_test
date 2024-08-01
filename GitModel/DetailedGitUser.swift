//
//  DetailedGitUser.swift
//  GitModel
//
//  Created by Bing Bing on 2024/7/31.
//

import Foundation

public struct DetailedGitUser: Decodable, Hashable, Sendable {
    
    public let login: String
    public let id: Int
    public let avatarUrl: String
    public let reposUrl: String
    public let followersUrl: String
    public let siteAdmin: Bool
    public let htmlUrl: String
    public let name: String
    public let company: String?
    public let blog: String
    public let location: String
    public let email: String?
    public let hireable: Bool?
    public let bio: String?
    public let twitterUserName: String?
    public let repoCounts: Int
    public let gistCounts: Int
    public let followers: Int
    public let following: Int
    public let createAt: String
    public let updatedAt: String
    
    private enum CodingKeys: String, CodingKey {
        case login, id, name, company, blog, location, email, hireable, bio, followers, following
        case avatarUrl = "avatar_url"
        case reposUrl = "repos_url"
        case followersUrl = "followers_url"
        case siteAdmin = "site_admin"
        case htmlUrl = "html_url"
        case twitterUserName = "twitter_username"
        case repoCounts = "public_repos"
        case gistCounts = "public_gists"
        case createAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(login: String, id: Int, avatarUrl: String, reposUrl: String, followersUrl: String, siteAdmin: Bool, htmlUrl: String, name: String, company: String, blog: String, location: String, email: String, hireable: Bool, bio: String, twitterUserName: String, repoCounts: Int, gistCounts: Int, followers: Int, following: Int, createAt: String, updatedAt: String) {
        self.login = login
        self.id = id
        self.avatarUrl = avatarUrl
        self.reposUrl = reposUrl
        self.followersUrl = followersUrl
        self.siteAdmin = siteAdmin
        self.htmlUrl = htmlUrl
        self.name = name
        self.company = company
        self.blog = blog
        self.location = location
        self.email = email
        self.hireable = hireable
        self.bio = bio
        self.twitterUserName = twitterUserName
        self.repoCounts = repoCounts
        self.gistCounts = gistCounts
        self.followers = followers
        self.following = following
        self.createAt = createAt
        self.updatedAt = updatedAt
    }
}
