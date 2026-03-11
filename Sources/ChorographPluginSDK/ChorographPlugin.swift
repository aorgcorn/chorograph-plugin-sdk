// ChorographPlugin.swift
// The root protocol every Chorograph plugin must conform to, plus the C-ABI
// factory function convention used by disk-loaded `.bundle` plugins.
//
// DISK-LOADED PLUGIN CONTRACT
// ──────────────────────────
// A plugin bundle must export a C-ABI factory function with this exact symbol:
//
//   chorograph_plugin_create() -> UnsafeMutableRawPointer
//
// The pointer must point to a heap-allocated Swift object that conforms to
// `ChorographPlugin`. The host will retain it via `Unmanaged.fromOpaque`.
//
// Minimal implementation in a plugin bundle:
//
//   @_cdecl("chorograph_plugin_create")
//   public func chorographPluginCreate() -> UnsafeMutableRawPointer {
//       let plugin = MyPlugin()
//       return Unmanaged.passRetained(plugin).toOpaque()
//   }
//
// BUNDLED PLUGIN CONTRACT
// ───────────────────────
// In-process bundled plugins simply instantiate their plugin class directly
// inside `PluginHost.bootstrap()` — no `dlopen`/`dlsym` required.

import Foundation

// MARK: - Plugin factory symbol name

/// The C symbol name the host looks up with `dlsym` in every disk-loaded plugin bundle.
public let ChorographPluginFactorySymbol = "chorograph_plugin_create"

// MARK: - ChorographPlugin

/// Root protocol every Chorograph plugin must conform to.
///
/// Lifecycle:
/// 1. The host creates the plugin instance (via factory or direct init).
/// 2. `bootstrap(context:)` is called once on the main actor — the plugin should
///    register all extension points here.
/// 3. The plugin may receive events / execute commands while active.
/// 4. `teardown()` is called before the plugin is unloaded. The plugin must
///    deregister all extension points and release resources.
///
/// Thread safety: `bootstrap` and `teardown` are called on `@MainActor`.
/// Plugins are responsible for their own concurrency within `execute` calls.
public protocol ChorographPlugin: AnyObject, Sendable {
    /// The static manifest describing this plugin's identity and capabilities.
    /// Must be cheap to access (no I/O) — the host reads it before calling `bootstrap`.
    var manifest: PluginManifest { get }

    /// Called once by the host after the plugin is loaded and its capabilities have
    /// been verified. The plugin should register all extension points through `context`.
    ///
    /// - Parameter context: A capability-gated facade over app internals.
    ///   Only capabilities declared in `manifest.capabilities` are unlocked.
    /// - Throws: Any error that prevents the plugin from operating. The host will
    ///   record `PluginError.bootstrapFailed` and skip activating the plugin.
    @MainActor func bootstrap(context: any PluginContextProviding) async throws

    /// Called by the host when the plugin is being unloaded (e.g. user disables it
    /// in Settings, or the app is quitting). The plugin must release all resources
    /// and deregister all overlays / handlers / loaders it registered at bootstrap.
    @MainActor func teardown()
}

// MARK: - Default teardown

extension ChorographPlugin {
    /// Default no-op teardown — override when cleanup is needed.
    @MainActor public func teardown() { }
}
