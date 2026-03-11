// PluginManifest.swift
// Static description of a Chorograph plugin — its identity, required capabilities,
// and user-configurable preferences (persisted in UserDefaults).

import Foundation

// MARK: - PluginCapability

/// The set of extension points a plugin can declare.
/// A plugin is only granted capabilities it explicitly requests; the host
/// enforces this at `bootstrap()` time.
public enum PluginCapability: String, Codable, CaseIterable, Sendable {
    /// Plugin provides an AIProvider implementation.
    case aiProvider
    /// Plugin emits and/or subscribes to custom ProviderEvent types.
    case customEvents
    /// Plugin contributes a SwiftUI overlay into the spatial visualizer.
    case sceneOverlay
    /// Plugin observes ProviderEvent streams for telemetry/logging purposes.
    case telemetryHandler
    /// Plugin registers commands in the tactical command bar.
    case commandBarEntry
    /// Plugin supplies a WorkspaceLoaderPlugin to parse non-standard project formats.
    case workspaceLoader
    /// Plugin contributes a SwiftUI settings panel shown in the Plugins settings tab.
    case settingsPanel
}

// MARK: - PluginManifest

/// Declarative description embedded in every Chorograph plugin bundle.
///
/// For disk-loaded plugins this is read from `manifest.json` in the bundle root.
/// For bundled (in-process) plugins it is returned directly from
/// `ChorographPlugin.manifest`.
public struct PluginManifest: Codable, Sendable {
    /// Stable reverse-DNS identifier, e.g. "com.acme.myplugin".
    public let id: String
    /// Human-readable name shown in the Plugins settings tab.
    public let displayName: String
    /// Short one-line description.
    public let description: String
    /// Semantic version string, e.g. "1.0.0".
    public let version: String
    /// Capabilities this plugin requires. The host denies loading if any
    /// required capability cannot be satisfied.
    public let capabilities: [PluginCapability]

    public init(
        id: String,
        displayName: String,
        description: String,
        version: String,
        capabilities: [PluginCapability]
    ) {
        self.id           = id
        self.displayName  = displayName
        self.description  = description
        self.version      = version
        self.capabilities = capabilities
    }
}

// MARK: - PluginPreferences

/// Lightweight key/value preference store for a single plugin.
/// Values are persisted in `UserDefaults` under the namespace
/// `"plugin.<pluginID>.<key>"`.
///
/// This is the v1 preference system — plugins may also register a full SwiftUI
/// settings panel via `PluginContextProviding.registerSettingsPanel(title:_:)`.
public struct PluginPreferences: Sendable {
    private let namespace: String

    public init(pluginID: String) {
        self.namespace = "plugin.\(pluginID)"
    }

    public func string(forKey key: String) -> String? {
        UserDefaults.standard.string(forKey: "\(namespace).\(key)")
    }

    public func set(_ value: String?, forKey key: String) {
        if let value {
            UserDefaults.standard.set(value, forKey: "\(namespace).\(key)")
        } else {
            UserDefaults.standard.removeObject(forKey: "\(namespace).\(key)")
        }
    }

    public func bool(forKey key: String, default defaultValue: Bool = false) -> Bool {
        guard UserDefaults.standard.object(forKey: "\(namespace).\(key)") != nil else {
            return defaultValue
        }
        return UserDefaults.standard.bool(forKey: "\(namespace).\(key)")
    }

    public func set(_ value: Bool, forKey key: String) {
        UserDefaults.standard.set(value, forKey: "\(namespace).\(key)")
    }
}
