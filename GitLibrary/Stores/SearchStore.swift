//
//  SearchStore.swift
//  GitLibrary
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation
import ComposableArchitecture
import GitModel

@Reducer
public struct SearchStore {
    
    private enum CancelID { case search, scrollBottom }
    
    @Dependency(\.appContext) var context
    
    public struct State: Equatable {
        public var isSearching: Bool = false
        public var isUserTyping: Bool = false
        public var users: [GitUser] = []
        public var errorMessage: String?
        public var searchQuery: String = ""
        public var currentIndex: Int = 1
        
        public init() {}
    }
    
    public enum Action {
        case searchDidBegin
        case searchDidEnd
        case searchQueryChanged(String)
        case searchQueryChangeDebounced
        case searchResult(Result<[GitUser], Error>)
        case didScrollViewScrollToBottom
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .searchQueryChanged(query):
                state.searchQuery = query
                guard !state.searchQuery.isEmpty else {
                    return .cancel(id: CancelID.search)
                }
                state.users = []
                state.currentIndex = 1
                return .send(.searchQueryChangeDebounced)
                    .debounce(id: CancelID.search, for: .milliseconds(500), scheduler: DispatchQueue.main)
            case .searchQueryChangeDebounced:
                guard !state.searchQuery.isEmpty else {
                    return .none
                }
                return .merge(
                    .send(.searchDidBegin),
                    .run { [query = state.searchQuery, page = state.currentIndex] send in
                        await send(
                            .searchResult(
                                Result { try await context.engine.seach.searchUsers(query: query, page: page) }
                                    .map(\.items)
                            )
                        )
                    }
                ).cancellable(id: CancelID.search)
            case .searchDidBegin:
                state.isSearching = true
                return .none
            case .searchDidEnd:
                state.isSearching = false
                return .none
            case let .searchResult(.success(result)):
                state.users.append(contentsOf: result)
                return .send(.searchDidEnd)
            case let .searchResult(.failure(error)):
                state.errorMessage = error.localizedDescription
                state.isSearching = false
                return .none
            case .didScrollViewScrollToBottom:
                if state.isSearching {
                    return .none
                }
                state.isSearching = true
                state.currentIndex += 1
                return .merge(
                    .send(.searchDidBegin),
                    .send(.searchQueryChangeDebounced)
                )
            }
        }
    }
    
    public init() {}
}
