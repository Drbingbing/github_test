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
    
    private enum CancelID { case search }
    
    @Dependency(\.appContext) var context
    
    public struct State: Equatable {
        public var isSearching: Bool = false
        public var users: [String] = []
        public var errorMessage: String?
        public var searchQuery: String = ""
        
        public init() {}
    }
    
    public enum Action {
        case searchDidBegin
        case searchDidEnd
        case searchQueryChanged(String)
        case searchQueryChangeDebounced
        case searchResult(TaskResult<[String]>)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .searchQueryChanged(query):
                state.searchQuery = query
                guard !state.searchQuery.isEmpty else {
                    state.users = []
                    return .cancel(id: CancelID.search)
                }
                return .send(.searchQueryChangeDebounced)
                    .debounce(id: CancelID.search, for: .milliseconds(500), scheduler: DispatchQueue.main)
            case .searchQueryChangeDebounced:
                guard !state.searchQuery.isEmpty else {
                    return .none
                }
                print(state.searchQuery)
                return .merge(
                    .send(.searchDidBegin),
                    .run { [query = state.searchQuery] in await $0(.searchResult(TaskResult { try await context.engine.seach.searchUsers(query: query) })) }
                ).cancellable(id: CancelID.search)
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
