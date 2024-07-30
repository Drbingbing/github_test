//
//  SearchStore.swift
//  GitLibrary
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct SearchStore {
    
    @Dependency(\.appContext) var context
    
    public struct State: Equatable {
        
        public init() {}
    }
    
    public enum Action {
        
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
    
    public init() {}
}
