//
//  GitUserCore.swift
//  GitUserCore
//
//  Created by Bing Bing on 2024/7/30.
//
import Foundation
import GitAPI

public final class GitUserEngine {
    
    private let account: Account
    
    public init(account: Account) {
        self.account = account
        
        Logbox.setSharedLogger(Logbox())
    }
    
    public lazy var seach: SearchUser = {
        return SearchUser(account: account)
    }()
    
    public lazy var user: User = {
        return User(account: account)
    }()
}

extension GitUserEngine {
    
    public convenience init() {
        let config: ServerConfig
        #if DEBUG
        config = ServerConfigImpl.staging
        #else
        config = ServerConfigImpl.produtcion
        #endif
        let network = initalizeNetwork(serverConfig: config, logging: { engineLog($0) })
        let account = Account(network: network)
        
        self.init(account: account)
    }
    
}
