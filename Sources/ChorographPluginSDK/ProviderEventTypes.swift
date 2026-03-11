// ProviderEventTypes.swift
// Concrete ProviderEvent implementations — one struct per event type.
// All types are public so plugins can pattern-match against them.

import Foundation

// MARK: - Well-known event type ID namespace

/// Namespace for built-in event type identifiers.
/// Plugins should use their own reverse-DNS prefix (e.g. "com.acme.myplugin.myEvent").
public enum ProviderEventTypeID {
    public static let readFile          = "com.chorograph.readFile"
    public static let writeFile         = "com.chorograph.writeFile"
    public static let patchFile         = "com.chorograph.patchFile"
    public static let toolCall          = "com.chorograph.toolCall"
    public static let assistantReply    = "com.chorograph.assistantReply"
    public static let turnFinished      = "com.chorograph.turnFinished"
    public static let connected         = "com.chorograph.connected"
    public static let info              = "com.chorograph.info"
    public static let error             = "com.chorograph.error"
    public static let other             = "com.chorograph.other"
    public static let runtimeTestResult = "com.chorograph.runtimeTestResult"
    public static let runtimeHeat       = "com.chorograph.runtimeHeat"
}

// MARK: - File activity events

/// A file was read by the agent.
public struct ReadFileEvent: ProviderEvent {
    public let eventTypeID = ProviderEventTypeID.readFile
    public let path: String
    public init(path: String) { self.path = path }
}

/// A file was written (created or replaced) by the agent.
public struct WriteFileEvent: ProviderEvent {
    public let eventTypeID = ProviderEventTypeID.writeFile
    public let path: String
    public init(path: String) { self.path = path }
}

/// A file was patched (edited in-place) by the agent.
public struct PatchFileEvent: ProviderEvent {
    public let eventTypeID = ProviderEventTypeID.patchFile
    public let path: String
    public init(path: String) { self.path = path }
}

// MARK: - Tool events

/// The agent invoked a tool (non-file tools such as shell, search, etc.).
public struct ToolCallEvent: ProviderEvent {
    public let eventTypeID = ProviderEventTypeID.toolCall
    /// The tool name as reported by the provider (e.g. "bash", "grep").
    public let name: String
    /// Key/value arguments the model passed to the tool. May be empty.
    public let input: [String: String]
    public init(name: String, input: [String: String]) {
        self.name = name
        self.input = input
    }
}

// MARK: - Session lifecycle events

/// The agent's final response text, emitted just before `TurnFinishedEvent`.
/// Carries the complete accumulated reply so callers need not fetch it separately.
public struct AssistantReplyEvent: ProviderEvent {
    public let eventTypeID = ProviderEventTypeID.assistantReply
    public let sessionID: String
    public let text: String
    public init(sessionID: String, text: String) {
        self.sessionID = sessionID
        self.text = text
    }
}

/// The agent's current turn finished (no more tool calls — final response).
public struct TurnFinishedEvent: ProviderEvent {
    public let eventTypeID = ProviderEventTypeID.turnFinished
    public let sessionID: String
    public init(sessionID: String) { self.sessionID = sessionID }
}

/// The provider successfully connected / reconnected.
public struct ConnectedEvent: ProviderEvent {
    public let eventTypeID = ProviderEventTypeID.connected
    public init() {}
}

// MARK: - Status / diagnostic events

/// A non-fatal status or informational message (shown in the activity log).
public struct InfoEvent: ProviderEvent {
    public let eventTypeID = ProviderEventTypeID.info
    public let message: String
    public init(_ message: String) { self.message = message }
}

/// A process-level error line (shown in the activity log in red).
public struct ErrorEvent: ProviderEvent {
    public let eventTypeID = ProviderEventTypeID.error
    public let message: String
    public init(_ message: String) { self.message = message }
}

/// An unrecognised event type — pass-through for forward-compatibility.
public struct OtherEvent: ProviderEvent {
    public let eventTypeID = ProviderEventTypeID.other
    public let type: String
    public init(type: String) { self.type = type }
}

// MARK: - Runtime telemetry events

/// A test was executed for a specific file.
public struct RuntimeTestResultEvent: ProviderEvent {
    public let eventTypeID = ProviderEventTypeID.runtimeTestResult
    public let path: String
    public let passed: Bool
    public let message: String?
    public init(path: String, passed: Bool, message: String? = nil) {
        self.path = path
        self.passed = passed
        self.message = message
    }
}

/// Execution activity (heat) detected in a file or function.
public struct RuntimeHeatEvent: ProviderEvent {
    public let eventTypeID = ProviderEventTypeID.runtimeHeat
    public let path: String
    public let intensity: Double
    public init(path: String, intensity: Double) {
        self.path = path
        self.intensity = intensity
    }
}
