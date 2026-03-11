// PluginError.swift
// Errors that can be thrown during plugin loading and lifecycle operations.

import Foundation

// MARK: - PluginError

public enum PluginError: Error, LocalizedError, Sendable {
    /// The bundle at the given path could not be opened.
    case bundleOpenFailed(path: String)
    /// The C-ABI factory symbol (`chorograph_plugin_create`) was not found.
    case factorySymbolMissing(bundlePath: String)
    /// The factory function returned nil.
    case factoryReturnedNil(pluginID: String)
    /// The plugin declared a capability the host cannot satisfy.
    case unsupportedCapability(PluginCapability)
    /// A required capability was not granted.
    case capabilityDenied(PluginCapability)
    /// The plugin's `bootstrap()` call threw an error.
    case bootstrapFailed(pluginID: String, underlying: any Error)
    /// A plugin with the same ID is already loaded.
    case duplicatePlugin(id: String)

    public var errorDescription: String? {
        switch self {
        case .bundleOpenFailed(let path):
            return "Failed to open plugin bundle at '\(path)'."
        case .factorySymbolMissing(let path):
            return "Plugin bundle at '\(path)' does not export 'chorograph_plugin_create'."
        case .factoryReturnedNil(let id):
            return "Plugin '\(id)' factory returned nil — plugin could not be instantiated."
        case .unsupportedCapability(let cap):
            return "Host cannot satisfy plugin capability '\(cap.rawValue)'."
        case .capabilityDenied(let cap):
            return "Plugin was denied capability '\(cap.rawValue)'."
        case .bootstrapFailed(let id, let err):
            return "Plugin '\(id)' bootstrap failed: \(err.localizedDescription)"
        case .duplicatePlugin(let id):
            return "A plugin with id '\(id)' is already loaded."
        }
    }
}
