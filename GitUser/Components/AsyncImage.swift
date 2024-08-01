//
//  AsyncImage.swift
//  GitUser
//
//  Created by Bing Bing on 2024/8/1.
//

import UIKit
import UIComponent
import Kingfisher
import BaseToolbox

struct AsyncImage: ComponentBuilder {
    
    typealias AsyncIndicatorType = IndicatorType
    typealias ConfigurationBuilder = (KF.Builder) -> KF.Builder
    
    let url: URL?
    let indicatorType: AsyncIndicatorType
    let configurationBuilder: ConfigurationBuilder?
    
    init(
        _ url: URL?,
        indicatorType: AsyncIndicatorType = .none,
        configurationBuilder: ConfigurationBuilder? = nil
    ) {
        self.url = url
        self.indicatorType = indicatorType
        self.configurationBuilder = configurationBuilder
    }
    
    init(
        _ urlString: String,
        indicatorType: AsyncIndicatorType = .none,
        configurationBuilder: ConfigurationBuilder? = nil
    ) {
        self.init(URL(string: urlString), indicatorType: indicatorType, configurationBuilder: configurationBuilder)
    }
    
    func build() -> some Component {
        ViewComponent<UIImageView>()
            .update {
                $0.layer.masksToBounds = true
                $0.kf.indicatorType = indicatorType
                if let configurationBuilder = configurationBuilder {
                    configurationBuilder(KF.url(url)).set(to: $0)
                } else {
                    KF.url(url).set(to: $0)
                }
            }
    }
}
