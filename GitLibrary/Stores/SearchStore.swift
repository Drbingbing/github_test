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
        public var isSearching: Bool = false
        public var users: [String] = []
        public var errorMessage: String?
        
        public init() {}
    }
    
    public enum Action {
        case searchDidBegin
        case searchDidEnd
        case searchTextChanged(String)
        case searchResult(TaskResult<[String]>)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .searchTextChanged(query):
                return .merge(
                    .send(.searchDidBegin),
                    .run { await $0(.searchResult(TaskResult { try await context.engine.seach.searchUsers(query: query) })) }
                )
            case .searchDidBegin:
                state.isSearching = true
                return .none
            case .searchDidEnd:
                state.isSearching = false
                return .none
            case let .searchResult(.success(result)):
                state.users = result
                return .none
            case let .searchResult(.failure(error)):
                state.errorMessage = error.localizedDescription
                state.isSearching = false
                return .none
            }
        }
    }
    
    public init() {}
}
