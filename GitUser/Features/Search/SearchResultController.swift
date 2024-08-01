//
//  SearchResultController.swift
//  GitUser
//
//  Created by Bing Bing on 2024/7/30.
//
import UIKit
import BaseToolbox
import GitModel
import UIComponent
import Kingfisher

protocol SearchResultControllerDelegate: AnyObject {
    
    func didUserLinkTapped(_ link: String)
    func didUserRowTapped(user: GitUser)
    func didSearchResultScrollToBottom()
}

final class SearchResultController: ViewController {
    
    private lazy var componentView = ComponentScrollView()
    
    weak var delegate: SearchResultControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(componentView)
        componentView.animator = TransformAnimator()
        setupBehaviors()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        componentView.frame = view.bounds
    }
    
    private func setupBehaviors() {
        let scrollBehaviour = ScrollViewBehavior(prefetching: { [weak self] in self?.delegate?.didSearchResultScrollToBottom() })
        
        addBehavior(scrollBehaviour)
    }
    
    func populate(users: [GitUser], animated: Bool) {
        componentView.component = VStack {
            for user in users {
                SearchResultRow(
                    user: user,
                    performLinkAction: { [weak self] in self?.didUserLinkTapped($0) },
                    performRowAction: { [weak self] in self?.didUserRowTapped(user: user) }
                ).id(String(user.id))
                Separator(color: .secondarySeparator)
                    .inset(left: 70, right: 30)
            }
        }
    }
    
    func didUserLinkTapped(_ link: String) {
        delegate?.didUserLinkTapped(link)
    }
    
    func didUserRowTapped(user: GitUser) {
        delegate?.didUserRowTapped(user: user)
    }
}

private struct SearchResultRow: ComponentBuilder {
    
    var user: GitUser
    var onLinkAction: (String) -> Void
    var onRowAction: () -> Void
    
    init(user: GitUser, performLinkAction: @escaping (String) -> Void, performRowAction: @escaping () -> Void) {
        self.user = user
        self.onLinkAction = performLinkAction
        self.onRowAction = performRowAction
    }
    
    func build() -> some Component {
        HStack(spacing: 8) {
            AsyncImage(user.avatarUrl) {
                $0.placeholder(UIImage(named: "img_friends_female_default"))
            }
            .size(width: 36, height: 36)
            .cornerRadius(18)
                
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text(user.login)
                    Text("(id:\(user.id))")
                        .textColor(.steel)
                }.font(.systemFont(ofSize: 14).rounded)
                Text(user.login)
                    .font(.systemFont(ofSize: 12).rounded)
                    .textColor(.systemBlue.withAlphaComponent(0.5))
                    .tappableView {
                        onLinkAction(user.htmlUrl)
                    }
            }
            Spacer()
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    Text("score:")
                        .font(.systemFont(ofSize: 10).rounded)
                        .textColor(.lightGray)
                    Text(String(user.score))
                        .font(.systemFont(ofSize: 12).rounded)
                        .textColor(.boogerGreen)
                }
                HStack(spacing: 2) {
                    Text("admin:")
                        .font(.systemFont(ofSize: 10).rounded)
                        .textColor(.lightGray)
                    Text(user.siteAdmin ? "YES" : "NO")
                        .font(.systemFont(ofSize: 12).rounded)
                        .textColor(.appleGreen)
                }
            }
        }
        .inset(h: 20, v: 8)
        .tappableView(onRowAction)
    }
}
