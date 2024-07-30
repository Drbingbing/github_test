//
//  Context.swift
//  GitUser
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation
import Dependencies
import GitUserCore

public final class Context: DependencyKey {
    
    public let engine: GitUserEngine
    
    init(engine: GitUserEngine) {
        self.engine = engine
    }
    
    public static var liveValue: Context {
        let engine: GitUserEngine = GitUserEngine()
        return Context(engine: engine)
    }
}

extension DependencyValues {
    public var appContext: Context {
        get { self[Context.self] }
        set { self[Context.self] = newValue }
    }
}
