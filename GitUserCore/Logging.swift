//
//  Logging.swift
//  GitUserCore
//
//  Created by Bing Bing on 2024/7/30.
//

import Foundation

private var engineLogger: (String) -> Void = { _ in }
private var engineLoggerSync: () -> Void = {}

public func setEngineLogger(_ f: @escaping (String) -> Void, sync: @escaping () -> Void) {
    engineLogger = f
    engineLoggerSync = sync
}

public func engineLog(_ what: @autoclosure () -> String) {
    engineLogger(what())
}

public func engineLogSync() {
    engineLoggerSync()
}
