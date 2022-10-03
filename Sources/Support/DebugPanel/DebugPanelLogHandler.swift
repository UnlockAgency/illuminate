//
//  File.swift
//  
//
//  Created by Thomas Roovers on 30/09/2022.
//

#if !RELEASE
import Foundation
import Logging

class DebugPanelLogHandler: LogHandler {
    fileprivate(set) static var logLines: [String] = []
    
    func log( // swiftlint:disable:this function_parameter_count
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        let metadataString = prettify(metadata ?? [:])
        var levelString = level.rawValue.uppercased()
        if levelString.count > 3 {
            levelString = levelString[0..<3]
        }
        let line = "\(Date()) \(levelString) 𝌀 \(message.description)\(metadataString == nil ? "" : " \(metadataString!)")"
        
        if DebugPanelLogHandler.logLines.count > 1000 {
            _ = DebugPanelLogHandler.logLines.removeFirst()
        }
        DebugPanelLogHandler.logLines.append(line)
    }
    
    subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }
    
    var metadata: Logger.Metadata = [:]
    var logLevel: Logger.Level = .trace
    
    private func prettify(_ metadata: Logger.Metadata) -> String? {
        if metadata.isEmpty {
            return nil
        }
        return metadata.map { "\($0)=\($1)" }.joined(separator: " ")
    }
}
#endif
