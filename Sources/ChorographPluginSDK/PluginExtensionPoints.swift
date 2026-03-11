// PluginExtensionPoints.swift
// Protocols that plugins implement to hook into Chorograph's extension points.
//
// Each protocol corresponds to a PluginCapability case:
//   .telemetryHandler  →  TelemetryHandler
//   .commandBarEntry   →  PluginCommand
//   .workspaceLoader   →  WorkspaceLoaderPlugin
//   .sceneOverlay      →  registered via PluginContextProviding.registerOverlay(id:_:)

import Foundation

// MARK: - TelemetryHandler (.telemetryHandler)

/// A plugin-supplied observer for the provider event stream.
/// Implementations receive every event after built-in handling completes.
/// Called on the `@MainActor`; implementations must not block.
public protocol TelemetryHandler: AnyObject, Sendable {
    /// Called for every `ProviderEvent` emitted by any active provider.
    @MainActor func handleEvent(_ event: any PluginEvent)
}

// MARK: - PluginCommand (.commandBarEntry)

/// A single command contributed by a plugin to the tactical command bar.
public protocol PluginCommand: Sendable {
    /// Stable identifier, e.g. "com.acme.myplugin.runBenchmark".
    var id: String { get }
    /// Human-readable title shown in the command bar.
    var title: String { get }
    /// Optional keyboard shortcut hint string (display only, not enforced by host).
    var keyboardShortcutHint: String? { get }
    /// Execute the command. `context` provides access to gated app internals.
    @MainActor func execute(context: any PluginContextProviding) async throws
}

// Default no-op for optional shortcut hint.
extension PluginCommand {
    public var keyboardShortcutHint: String? { nil }
}

// MARK: - WorkspaceLoaderPlugin (.workspaceLoader)

/// A plugin-supplied workspace loader for non-standard project formats.
/// The host queries registered loaders in registration order, using the first
/// loader that claims it can handle the given path.
public protocol WorkspaceLoaderPlugin: Sendable {
    /// Return `true` if this loader can parse the project at `path`.
    /// This is a cheap pre-flight check — no I/O required.
    func canLoad(path: String) -> Bool
    /// Load and return the workspace hierarchy rooted at `path`.
    /// Throws `WorkspaceError` or any domain-specific error on failure.
    func load(from path: String) async throws -> WorkspaceNode
}
