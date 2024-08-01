//
//  SearchStore.swift
//  GitLibrary
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation
import ComposableArchitecture
import GitModel
import GitUserCore

@Reducer
public struct SearchStore: Sendable {
    
    private enum CancelID { case search, scrollBottom }
    
    @Dependency(\.appContext) var context
    
    @ObservableState
    public struct State: Equatable {
        public var isSearching: Bool = false
        public var isUserTyping: Bool = false
        public var users: [GitUser] = []
        public var errorMessage: String?
        public var searchQuery: String = ""
        public var currentIndex: Int = 1
        @Presents public var selectedUser: UserDetailStore.State?
        
        public init() {}
    }
    
    public enum Action: Sendable, ViewAction {
        case searchQueryChangeDebounced
        case searchResponse(Result<[GitUser], Error>)
        case showUser(PresentationAction<UserDetailStore.Action>)
        case view(View)
        
        @CasePathable
        public enum View: Sendable {
            case searchQueryChanged(String)
            case didScrollViewScrollToBottom
            case didUserRowTapped(GitUser)
        }
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .searchResponse(.success(response)):
                state.users.append(contentsOf: response)
                state.isSearching = false
                return .none
            case let .searchResponse(.failure(error)):
                state.isSearching = false
                state.errorMessage = error.localizedDescription
                return .none
            case .searchQueryChangeDebounced:
                guard !state.searchQuery.isEmpty else {
                    return .none
                }
                return .run { [query = state.searchQuery, page = state.currentIndex] send in
                    await send(
                        .searchResponse(
                            Result { try await context.engine.seach.searchUsers(query: query, page: page) }
                                .map(\.items)
                        )
                    )
                }
            case .showUser:
                return .none
            case .view(.didScrollViewScrollToBottom):
                if state.isSearching {
                    return .none
                }
                state.isSearching = true
                state.currentIndex += 1
                return .send(.searchQueryChangeDebounced)
            case let .view(.didUserRowTapped(tappedUser)):
                state.selectedUser = UserDetailStore.State(user: tappedUser)
                return .none
            case let .view(.searchQueryChanged(query)):
                state.searchQuery = query
                guard !state.searchQuery.isEmpty else {
                    return .cancel(id: CancelID.search)
                }
                state.users = []
                state.currentIndex = 1
                return .send(.searchQueryChangeDebounced)
                    .debounce(id: CancelID.search, for: .milliseconds(500), scheduler: DispatchQueue.main)
            }
        }
        .ifLet(\.$selectedUser, action: \.showUser) {
            UserDetailStore()
        }
    }
    
    public init() {}
}
