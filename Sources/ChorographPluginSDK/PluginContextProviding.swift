// PluginContextProviding.swift
// Protocol that PluginContext conforms to, placed in the SDK so that
// external plugin bundles compiled against ChorographPluginSDK can receive
// a context object at bootstrap time without depending on the host executable.
//
// All registration methods are @MainActor — plugins call them only inside
// their own `bootstrap(context:)` implementation, which is also @MainActor.

import Foundation
import SwiftUI

// MARK: - PluginContextProviding

/// Capability-gated interface through which a plugin registers extension points.
///
/// The host passes a concrete `PluginContext` (which lives in the Chorograph
/// executable) as `any PluginContextProviding`, so external plugins never need
/// to import the host module directly.
@MainActor
public protocol PluginContextProviding: AnyObject {

    // MARK: Preferences (always available)

    /// Key/value preference store for this plugin, backed by UserDefaults.
    var prefs: PluginPreferences { get }

    // MARK: AI Provider registration (.aiProvider)

    /// Register an `AIProvider` implementation with the app's provider registry.
    /// Requires the `.aiProvider` capability.
    func registerProvider(_ provider: any AIProvider)

    // MARK: Telemetry handlers (.telemetryHandler)

    /// Register a `TelemetryHandler` to receive all provider events.
    /// Requires the `.telemetryHandler` capability.
    func registerTelemetryHandler(_ handler: any TelemetryHandler)

    // MARK: Scene overlays (.sceneOverlay)

    /// Contribute a SwiftUI view as a persistent overlay on the spatial visualizer.
    /// Requires the `.sceneOverlay` capability.
    /// Wrap your view in `AnyView(...)` at the call site.
    func registerOverlay(id: String, _ view: AnyView)

    /// Remove a previously registered overlay.
    /// Requires the `.sceneOverlay` capability.
    func unregisterOverlay(id: String)

    // MARK: Command bar entries (.commandBarEntry)

    /// Register a command that appears in the tactical command bar.
    /// Requires the `.commandBarEntry` capability.
    func registerCommand(_ command: any PluginCommand)

    /// Remove a previously registered command.
    func unregisterCommand(id: String)

    // MARK: Workspace loaders (.workspaceLoader)

    /// Register a workspace loader for a custom project format.
    /// Requires the `.workspaceLoader` capability.
    func registerWorkspaceLoader(_ loader: any WorkspaceLoaderPlugin)

    // MARK: Settings panel (.settingsPanel)

    /// Register a SwiftUI settings panel shown in the Plugins settings tab.
    /// Requires the `.settingsPanel` capability.
    /// A gear icon is shown next to the plugin's row in the Installed list;
    /// tapping it opens the panel in a sheet.
    ///
    /// - Parameters:
    ///   - title: Sheet navigation title (e.g. "OpenCode Server Settings").
    ///   - view: The settings panel view, type-erased with `AnyView(...)`.
    func registerSettingsPanel(title: String, _ view: AnyView)
}
