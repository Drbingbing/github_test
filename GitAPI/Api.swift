//
//  Api.swift
//  GitAPI
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation

public enum Api {
    public enum functions {
        public enum search {}
    }
}

extension Api {
    
    static func parse<T: Decodable>(json j: Data) -> T? {
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: j)
    }
}
