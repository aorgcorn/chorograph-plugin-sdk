// WorkspaceNode.swift
// Public hierarchy node types shared between the host app and external plugins.
// Plugins that implement WorkspaceLoaderPlugin return a WorkspaceNode tree.

import Foundation

// MARK: - HierarchyLevel

/// The three zoom levels of the Chorograph spatial visualiser.
/// Each concrete node type hardcodes its level.
public enum HierarchyLevel: Int, CaseIterable, Sendable {
    case map  = 1
    case file = 2
    case room = 3

    public var name: String {
        switch self {
        case .map:  return "Map"
        case .file: return "File"
        case .room: return "Room"
        }
    }
}

// MARK: - HierarchicalNode

/// Base protocol for all nodes in the workspace hierarchy tree.
public protocol HierarchicalNode: Identifiable {
    var id: UUID { get }
    var level: HierarchyLevel { get }
    var name: String { get }
    var position: SIMD2<Double> { get }
    var children: [any HierarchicalNode] { get }
}

// MARK: - WorkspaceNode

/// Root node — holds FolderNodes as its direct children.
public struct WorkspaceNode: HierarchicalNode {
    public let id: UUID
    public let level: HierarchyLevel = .map
    public let name: String
    public let position: SIMD2<Double>
    public var children: [any HierarchicalNode]

    public init(id: UUID = UUID(), name: String, position: SIMD2<Double>, children: [any HierarchicalNode]) {
        self.id = id; self.name = name; self.position = position; self.children = children
    }
}

// MARK: - FolderNode

/// One folder from the workspace (e.g. "Scene/", "Parsing/").
public struct FolderNode: HierarchicalNode {
    public let id: UUID
    public let level: HierarchyLevel = .map
    public let name: String
    public let position: SIMD2<Double>
    public var children: [any HierarchicalNode]
    /// Absolute path on disk.
    public var folderPath: String

    public init(id: UUID = UUID(), name: String, position: SIMD2<Double>,
                children: [any HierarchicalNode], folderPath: String) {
        self.id = id; self.name = name; self.position = position
        self.children = children; self.folderPath = folderPath
    }
}

// MARK: - BuildingNode

/// One source file — rendered as a scrollable code card.
public struct BuildingNode: HierarchicalNode {
    public let id: UUID
    public let level: HierarchyLevel = .file
    public let name: String
    public let position: SIMD2<Double>
    public var children: [any HierarchicalNode]
    /// File extension (e.g. "swift", "go", "ts").
    public var type: String
    /// Absolute path on disk.
    public var filePath: String

    public init(id: UUID = UUID(), name: String, position: SIMD2<Double>,
                children: [any HierarchicalNode], type: String, filePath: String) {
        self.id = id; self.name = name; self.position = position
        self.children = children; self.type = type; self.filePath = filePath
    }
}

// MARK: - RoomNode

/// One function / class / scope inside a source file.
public struct RoomNode: HierarchicalNode {
    public let id: UUID
    public let level: HierarchyLevel = .room
    public let name: String
    public let position: SIMD2<Double>
    public var children: [any HierarchicalNode]
    /// The raw source lines of this scope's body.
    public var lines: [String]

    public init(id: UUID = UUID(), name: String, position: SIMD2<Double>,
                children: [any HierarchicalNode], lines: [String]) {
        self.id = id; self.name = name; self.position = position
        self.children = children; self.lines = lines
    }
}
