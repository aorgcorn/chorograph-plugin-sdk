// ProviderEvent.swift
// Open protocol that every AI provider event must conform to.
// Replacing the previous closed enum allows plugins to define and emit
// their own event types without modifying core app code.

import Foundation

// MARK: - ProviderEvent Protocol

/// An event emitted by an AIProvider's event stream during an active session.
/// Conforming types must be `Sendable` (they cross actor boundaries freely).
///
/// The `eventTypeID` is a stable reverse-DNS string used for:
///   - Routing in `TelemetryManager`
///   - Plugin subscription filtering
///   - Forward-compatibility (unknown IDs are passed through to plugin handlers)
public protocol ProviderEvent: Sendable {
    /// Stable reverse-DNS type identifier, e.g. "com.chorograph.readFile".
    var eventTypeID: String { get }
}
