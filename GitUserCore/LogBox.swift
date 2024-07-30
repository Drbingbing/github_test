//
//  LogBox.swift
//  GitUserCore
//
//  Created by Bing Bing on 2024/7/30.
//
import Foundation
import Dispatch

private var sharedLogger: Logbox?

public final class Logbox {
    
    private let basePath: String
    private let maxLength: Int = 2 * 1024 * 1024
    private let maxFiles: Int = 20
    
    public init() {
        let pathURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appending(path: "logs/app-logs")
        basePath = pathURL.path
        let _ = try? FileManager.default.createDirectory(atPath: basePath, withIntermediateDirectories: true, attributes: nil)
        debugPrint("log folder location: \(basePath)")
    }
    
    private let queue = DispatchQueue(label: "bingbing.log")
    
    private var logToConsole: Bool = true
    
    private var file: (ManagedFile, Int)?
    
    static func setSharedLogger(_ logger: Logbox) {
        sharedLogger = logger
        setEngineLogger { s in
            sharedLogger?.log("GitUser", s)
        } sync: {
            sharedLogger?.sync()
        }
    }
    
    fileprivate func sync() {
        self.queue.sync {
            if let (currentFile, _) = self.file {
                let _ = currentFile.sync()
            }
        }
    }
    
    fileprivate func log(_ tag: String, _ what: @autoclosure () -> String) {
        if !logToConsole {
            return
        }
        
        let string = what()
        
        var rawTime = time_t()
        time(&rawTime)
        var timeinfo = tm()
        localtime_r(&rawTime, &timeinfo)
        
        var curTime = timeval()
        gettimeofday(&curTime, nil)
        let milliseconds = curTime.tv_usec / 1000
        
        var consoleContent: String?
        
        if logToConsole {
            let content = String(format: "[%@] %d-%d-%d %02d:%02d:%02d.%03d %@", arguments: [tag, Int(timeinfo.tm_year) + 1900, Int(timeinfo.tm_mon + 1), Int(timeinfo.tm_mday), Int(timeinfo.tm_hour), Int(timeinfo.tm_min), Int(timeinfo.tm_sec), Int(milliseconds), string])
            consoleContent = content
            print(content)
        }
        
        // log to file
        queue.async {
            let content: String
            if let consoleContent = consoleContent {
                content = consoleContent
            } else {
                content = String(format: "[%@] %d-%d-%d %02d:%02d:%02d.%03d %@", arguments: [tag, Int(timeinfo.tm_year) + 1900, Int(timeinfo.tm_mon + 1), Int(timeinfo.tm_mday), Int(timeinfo.tm_hour), Int(timeinfo.tm_min), Int(timeinfo.tm_sec), Int(milliseconds), string])
            }
            
            var currentFile: ManagedFile?
            var openNew = false
            if let (file, length) = self.file {
                if length >= self.maxLength {
                    self.file = nil
                    openNew = true
                } else {
                    currentFile = file
                }
            } else {
                openNew = true
            }
            
            if openNew {
                let _ = try? FileManager.default.createDirectory(atPath: self.basePath, withIntermediateDirectories: true, attributes: nil)
                
                var createNew = false
                if let files = try? FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: self.basePath), includingPropertiesForKeys: [.creationDateKey]) {
                    var minCreationDate: (Date, URL)?
                    var maxCreationDate: (Date, URL)?
                    var count = 0
                    for url in files {
                        if url.lastPathComponent.hasPrefix("log-") {
                            if let values = try? url.resourceValues(forKeys: [.creationDateKey]), let creationDate = values.creationDate {
                                count += 1
                                if minCreationDate == nil || minCreationDate!.0 > creationDate {
                                    minCreationDate = (creationDate, url)
                                }
                                if maxCreationDate == nil || maxCreationDate!.0 < creationDate {
                                    maxCreationDate = (creationDate, url)
                                }
                            }
                        }
                    }
                    
                    if let (_, url) = minCreationDate, count >= self.maxFiles {
                        let _ = try? FileManager.default.removeItem(at: url)
                    }
                    
                    if let (_, url) = maxCreationDate {
                        var value = stat()
                        if stat(url.path, &value) == 0 && Int(value.st_size) < self.maxLength {
                            if let file = ManagedFile(queue: self.queue, path: url.path) {
                                self.file = (file, Int(value.st_size))
                                currentFile = file
                            }
                        } else {
                            createNew = true
                        }
                    } else {
                        createNew = true
                    }
                }
                
                if createNew {
                    let fileName = String(format: "log-%d-%d-%d_%02d-%02d-%02d.%03d.txt", arguments: [Int(timeinfo.tm_year) + 1900, Int(timeinfo.tm_mon + 1), Int(timeinfo.tm_mday), Int(timeinfo.tm_hour), Int(timeinfo.tm_min), Int(timeinfo.tm_sec), Int(milliseconds)])
                    
                    let path = self.basePath + "/" + fileName
                    
                    if let file = ManagedFile(queue: self.queue, path: path) {
                        self.file = (file, 0)
                        currentFile = file
                    }
                }
            }
            
            if let currentFile = currentFile {
                if let data = content.data(using: .utf8) {
                    data.withUnsafeBytes { rawBytes -> Void in
                        let bytes = rawBytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
                        
                        _ = currentFile.write(bytes, count: data.count)
                    }
                    var newline: UInt8 = 0x0a
                    let _ = currentFile.write(&newline, count: 1)
                    if let file = self.file {
                        self.file = (file.0, file.1 + data.count + 1)
                    } else {
                        assertionFailure()
                    }
                }
            }
        }
    }
}

private class ManagedFile {
    
    private let queue: DispatchQueue
    private let fd: Int32
    private var isClosed = false
    
    init?(queue: DispatchQueue, path: String) {
        self.queue = queue
        let fileMode = O_WRONLY | O_CREAT | O_APPEND
        let accessMode = S_IRUSR | S_IWUSR
        let fd = open(path, fileMode, accessMode)
        if fd >= 0 {
            self.fd = fd
        } else {
            return nil
        }
    }
    
    func write(_ data: UnsafeRawPointer, count: Int) -> Int {
        assert(!self.isClosed)
        return wrappedWrite(self.fd, data, count)
    }
    
    func sync() {
        assert(!self.isClosed)
        fsync(self.fd)
    }
    
    deinit {
        if !self.isClosed {
            close(self.fd)
        }
    }
}


private func wrappedWrite(_ fd: Int32, _ data: UnsafeRawPointer, _ count: Int) -> Int {
    return write(fd, data, count)
}
