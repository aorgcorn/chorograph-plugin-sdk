// PluginEvent.swift
// Open protocol that every Chorograph event must conform to.
// Any plugin (not just AI providers) can emit events via
// PluginContextProviding.emitEvent(_:) using the .customEvents capability.

import Foundation

// MARK: - PluginEvent Protocol

/// An event emitted into the Chorograph event pipeline.
/// Conforming types must be `Sendable` (they cross actor boundaries freely).
///
/// The `eventTypeID` is a stable reverse-DNS string used for:
///   - Routing in `TelemetryManager`
///   - Plugin subscription filtering
///   - Forward-compatibility (unknown IDs are passed through to plugin handlers)
public protocol PluginEvent: Sendable {
    /// Stable reverse-DNS type identifier, e.g. "com.chorograph.readFile".
    var eventTypeID: String { get }
}

// MARK: - Backwards compatibility

/// Deprecated alias kept for source compatibility with plugins built against SDK ≤ 1.0.1.
@available(*, deprecated, renamed: "PluginEvent")
public typealias ProviderEvent = PluginEvent
