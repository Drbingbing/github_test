//
//  UserDetailStore.swift
//  GitLibrary
//
//  Created by Bing Bing on 2024/7/31.
//

import Foundation
import ComposableArchitecture
import GitModel
import GitUserCore

@Reducer
public struct UserDetailStore: Sendable {
    
    @Dependency(\.appContext) var context
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public var user: GitUser
        public var detailUser: DetailedGitUser? = nil
        public var isLoading: Bool = false
        public var errorMessage: String? = nil
        
        public init(user: GitUser) {
            self.user = user
        }
    }
    
    public enum Action: Sendable, ViewAction {
        case userDetailResponse(Result<DetailedGitUser, Error>)
        case view(View)
        
        @CasePathable
        public enum View: Sendable {
            case viewDidLoad
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.viewDidLoad):
                state.isLoading = true
                return .run { [user = state.user] send in
                    await send(
                        .userDetailResponse(
                            Result { try await context.engine.user.getUserBy(name: user.login) }
                        )
                    )
                }
            case let .userDetailResponse(.success(detailUser)):
                state.isLoading = false
                state.detailUser = detailUser
                return .none
            case let .userDetailResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
}
