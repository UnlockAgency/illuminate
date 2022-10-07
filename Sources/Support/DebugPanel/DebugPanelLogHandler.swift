//
//  File.swift
//  
//
//  Created by Thomas Roovers on 30/09/2022.
//

#if !RELEASE
import Foundation
import Logging

private extension String {
    subscript(integerRange: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: integerRange.lowerBound)
        let end = index(startIndex, offsetBy: integerRange.upperBound)
        let range = start..<end
        return String(self[range])
    }
}

open class DebugPanelLogHandler: LogHandler {
    fileprivate(set) static var logLines: [String] = []
    
    public init() {
        
    }
    
    public func log( // swiftlint:disable:this function_parameter_count
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
    
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }
    
    public var metadata: Logger.Metadata = [:]
    public var logLevel: Logger.Level = .trace
    
    private func prettify(_ metadata: Logger.Metadata) -> String? {
        if metadata.isEmpty {
            return nil
        }
        return metadata.map { "\($0)=\($1)" }.joined(separator: " ")
    }
}
#endif
