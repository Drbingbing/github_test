//
//  UserDetailViewController.swift
//  GitUser
//
//  Created by Bing Bing on 2024/7/31.
//

import UIKit
import ComposableArchitecture
import GitLibrary
import GitModel
import UIComponent

final class UserDetailViewController: ViewController {
    
    private lazy var componentView = ComponentScrollView()
    private let store: StoreOf<UserDetailStore>
    
    init(store: StoreOf<UserDetailStore>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(componentView)
        componentView.animator = TransformAnimator()
        
        observe { [weak self] in
            guard let self else { return }
            self.reloadComponent(user: self.store.detailUser)
        }
        
        store.send(.view(.viewDidLoad))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        componentView.frame = view.bounds
        view.backgroundColor = .background2
    }
    
    private func reloadComponent(user: DetailedGitUser?) {
        guard let user else { return }
        
        componentView.component = VStack(spacing: 8) {
            HStack(spacing: 12, alignItems: .center) {
                AsyncImage(user.avatarUrl) {
                    $0.placeholder(UIImage(named: "img_friends_female_default"))
                }
                .size(width: 48, height: 48)
                .cornerRadius(24)
                .borderWidth(1)
                .borderColor(.steel)
                VStack(spacing: 4) {
                    Text(user.name)
                        .font(.systemFont(ofSize: 18).bolded.rounded)
                    Text(user.login)
                        .font(.systemFont(ofSize: 12).rounded)
                        .textColor(.lightGray)
                }
            }
            if let bio = user.bio {
                HStack {
                    Text(bio)
                        .font(.systemFont(ofSize: 12).rounded)
                        .textColor(.darkGray)
                        .flex(flexGrow: 0, flexShrink: 1)
                }
            }
            HStack(spacing: 20, alignItems: .center) {
                HStack(spacing: 4, alignItems: .center) {
                    Image("location")
                        .size(width: 12, height: 12)
                        .tintColor(.steel)
                    Text(user.location)
                        .font(.systemFont(ofSize: 12).rounded)
                        .textColor(.darkGray)
                }
                HStack(spacing: 4, alignItems: .center) {
                    Image(systemName: "link")
                        .size(width: 12, height: 12)
                        .tintColor(.steel)
                    Text("\(user.name.lowercased().replacingOccurrences(of: " ", with: "")).net")
                }
            }
            HStack(spacing: 4, alignItems: .center) {
                Image(systemName: "envelope")
                    .size(width: 12, height: 10)
                    .tintColor(.steel)
                Text(user.email ?? "none")
                    .font(.systemFont(ofSize: 12).rounded)
                    .textColor(.darkGray)
            }
            HStack(spacing: 4, alignItems: .center) {
                Image("two-persons")
                    .size(width: 12, height: 12)
                    .tintColor(.steel)
                HStack {
                    Text("\(user.followers) followers")
                        .font(.systemFont(ofSize: 12).rounded)
                        .textColor(.darkGray)
                    Text("・")
                        .font(.systemFont(ofSize: 12).rounded)
                        .textColor(.lightGray)
                    Text("\(user.following) following")
                        .font(.systemFont(ofSize: 12).rounded)
                        .textColor(.darkGray)
                }
            }
            HStack(spacing: 4, alignItems: .center) {
                Image("company")
                    .size(width: 12, height: 12)
                    .tintColor(.steel)
                Text(user.company ?? "none")
                    .font(.systemFont(ofSize: 12).rounded)
                    .textColor(.darkGray)
            }
            Space(height: 20)
            Space(height: 1)
                .backgroundColor(.steel)
            VStack {
                HStack(spacing: 0, alignItems: .center) {
                    Image("memory-card")
                        .size(width: 12, height: 12)
                        .inset(h: 4, v: 2)
                    Text("Repositories")
                        .font(.systemFont(ofSize: 14))
                        .flex(flexGrow: 1, flexShrink: 1)
                    Spacer()
                    Text("\(user.repoCounts)")
                        .font(.systemFont(ofSize: 12).rounded)
                        .textColor(.lightGray)
                    Image("arrow_right_deep_gray")
                        .size(width: 10, height: 10)
                }
                .inset(v: 8)
            }
            .inset(h: 12)
            .view()
            .backgroundColor(.white)
            .cornerRadius(8)
            Space(height: 1)
                .backgroundColor(.steel)
        }
        .inset(h: 20)
    }
}
