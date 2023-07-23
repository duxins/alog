// The Swift Programming Language
// https://docs.swift.org/swift-book

import Logging

public struct XLog {
    
    public enum Level {
        case debug
        case info
        case warning
        case error
        case critical
        
        fileprivate var loggingValue: Logger.Level {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .error: return .error
            case .warning: return .warning
            case .critical: return .critical
            }
        }
    }
    
    private static var logger: Logger?
    
    public static func config(label: String, level: Level = .info) {
        logger = Logger(label: label)
        logger?.logLevel = level.loggingValue
    }
    
    public static func debug<T>(_ message: @autoclosure () -> T, source: @autoclosure () -> String? = nil) {
        logger?.debug("\(message())", source: source())
    }
    
    public static func info<T>(_ message: @autoclosure () -> T, source: @autoclosure () -> String? = nil) {
        logger?.info("\(message())", source: source())
    }
    
    public static func error<T>(_ message: @autoclosure () -> T, source: @autoclosure () -> String? = nil) {
        logger?.error("\(message())", source: source())
    }
}
