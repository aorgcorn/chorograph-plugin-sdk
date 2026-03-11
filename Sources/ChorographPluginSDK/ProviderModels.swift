// ProviderModels.swift
// Shared value types used across all AI providers.

import Foundation

// MARK: - Provider Identity

/// Stable string identifier for a provider (e.g. "opencode-server", "github-copilot", "gemini-cli").
public typealias ProviderID = String

// MARK: - Health

public struct ProviderHealth: Sendable {
    public let isReachable: Bool
    public let version: String?
    public let detail: String?
    /// Active model in "providerID/modelID" format (e.g. "anthropic/claude-sonnet-4-5").
    /// Only populated for providers that expose this information.
    public let activeModel: String?

    public init(isReachable: Bool, version: String?, detail: String?, activeModel: String?) {
        self.isReachable = isReachable
        self.version = version
        self.detail = detail
        self.activeModel = activeModel
    }

    public static let unreachable = ProviderHealth(isReachable: false, version: nil, detail: nil, activeModel: nil)
}

// MARK: - Session

public struct ProviderSession: Sendable {
    public let id: String
    public let title: String?

    public init(id: String, title: String?) {
        self.id = id
        self.title = title
    }
}

// MARK: - Model

/// A model available from a provider (id + human-readable display name).
public struct ProviderModel: Sendable, Identifiable, Hashable {
    public let id: String
    public let displayName: String

    public init(id: String, displayName: String) {
        self.id = id
        self.displayName = displayName
    }
}

// MARK: - Symbol

public struct ProviderSymbol: Sendable {
    public let name: String
    public let location: FileLocation

    public init(name: String, location: FileLocation) {
        self.name = name
        self.location = location
    }
}

public struct FileLocation: Sendable {
    /// Absolute file-system path (no `file://` prefix).
    public let path: String
    public let line: Int?
    public let column: Int?

    public init(path: String, line: Int? = nil, column: Int? = nil) {
        self.path = path
        self.line = line
        self.column = column
    }

    /// Convenience: accepts a raw URI (strips `file://` prefix if present).
    public init(uri: String, line: Int? = nil, column: Int? = nil) {
        let path = uri.hasPrefix("file://") ? String(uri.dropFirst(7)) : uri
        self.init(path: path, line: line, column: column)
    }
}

// MARK: - ProviderError

public enum ProviderError: Error, LocalizedError, Sendable {
    case notConfigured
    case authRequired
    case connectionFailed(String)
    case sessionCreationFailed(String)
    case requestFailed(String)
    case binaryNotFound(String)
    case invalidResponse

    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "This provider is not configured. Open Preferences to set it up."
        case .authRequired:
            return "Authentication is required. Sign in from Preferences."
        case .connectionFailed(let detail):
            return "Could not connect to the AI provider. \(detail)"
        case .sessionCreationFailed(let detail):
            return "Failed to start a new session. \(detail)"
        case .requestFailed(let detail):
            return "The request failed. \(detail)"
        case .binaryNotFound(let path):
            return "The CLI binary was not found at '\(path)'. Check the path in Preferences."
        case .invalidResponse:
            return "Received an unexpected response from the AI provider."
        }
    }
}
