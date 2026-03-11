// AIProvider.swift
// Protocol that every AI provider must conform to.
// Providers are actors to ensure safe concurrent access.

import Foundation

// MARK: - AIProvider Protocol

/// An AI provider that can manage sessions, stream events, and search symbols.
/// Conforming types must be actors (or otherwise concurrency-safe).
public protocol AIProvider: Actor {
    /// Stable identifier (e.g. "opencode-server", "github-copilot", "gemini-cli").
    /// `nonisolated` so it can be read from any context without hopping to the actor.
    nonisolated var id: ProviderID { get }
    /// Human-readable display name.
    nonisolated var displayName: String { get }

    // MARK: Lifecycle

    /// Returns the current health / reachability status.
    func health() async -> ProviderHealth

    // MARK: Sessions

    /// Create a new session. Throws `ProviderError` on failure.
    func createSession(title: String?) async throws -> ProviderSession

    /// Send a text message into an existing session (fire-and-forget; events arrive via stream).
    func sendMessage(sessionID: String, text: String) async throws

    /// Abort an in-progress session. No-op if the session is already done.
    func abortSession(id: String) async throws

    /// Fetch the full text of the last assistant turn in a session.
    func fetchLastAssistantText(sessionID: String) async throws -> String

    // MARK: Event streaming

    /// Subscribe to real-time events from the provider.
    /// The returned stream delivers `ProviderEvent` values until the provider is stopped
    /// or the stream is cancelled.
    func eventStream() -> AsyncStream<any PluginEvent>

    /// Stop the event stream (e.g. when the app is backgrounded or provider is switched).
    func stopEventStream()

    // MARK: Symbol search (optional)

    /// Returns `true` if this provider supports native symbol search.
    var supportsSymbolSearch: Bool { get }

    /// Find symbols matching `query`. Returns `[]` for providers that don't support it.
    func findSymbols(query: String) async throws -> [ProviderSymbol]

    // MARK: Model selection (optional)

    /// Returns the list of models available from this provider.
    /// Providers that don't support model selection return `[]`.
    func availableModels() async throws -> [ProviderModel]

    // MARK: Shell shim (optional)

    /// Configure the shell shim environment. Call this after the ShimServer is
    /// started and before any subprocess is launched. Providers that don't spawn
    /// subprocesses can ignore this via the default no-op implementation.
    ///
    /// - Parameters:
    ///   - socketPath: Unix domain socket path the ShimBash binary reports to.
    ///   - shimDirPath: Directory containing the "bash" shim binary; will be
    ///                  prepended to PATH in the subprocess environment.
    func setShimEnvironment(socketPath: String, shimDirPath: String)
}

// MARK: - Default implementations

extension AIProvider {
    public var supportsSymbolSearch: Bool { false }

    public func findSymbols(query: String) async throws -> [ProviderSymbol] { [] }

    public func availableModels() async throws -> [ProviderModel] { [] }

    /// Default implementation: no-op for providers that don't spawn subprocesses.
    public func setShimEnvironment(socketPath: String, shimDirPath: String) { }
}
