/* ----------------------------------------------------------------
 * :: :  O  P  E  N  U  S  D  :                                  ::
 * ----------------------------------------------------------------
 * Licensed under the terms set forth in the LICENSE.txt file, this
 * file is available at https://openusd.org/license.
 *
 *                                        Copyright (C) 2016 Pixar.
 *         Copyright (C) 2024 Wabi Foundation. All Rights Reserved.
 * ----------------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ---------------------------------------------------------------- */

import Foundation
import OpenUSDKit
import SwiftCrossUI


// MARK: - Prim Entry

/// A single row in the prim browser, derived from a USD prim.
public struct PrimEntry: Identifiable, Hashable, Sendable
{
  public var id: String { path }

  /// Full USD path, e.g. "/World/DefaultDomeLight".
  public let path: String
  /// Last component only, e.g. "DefaultDomeLight".
  public let name: String
  /// Schema type name, e.g. "DomeLight", "Sphere". Empty prims show "-".
  public let typeName: String
  /// Hierarchy nesting depth: root children = 0, their children = 1, …
  public let depth: Int
  /// Whether the prim has any *direct* children - a cheap structural check,
  /// not a subtree walk, so it's safe to compute eagerly for every row.
  public let hasChildren: Bool
  /// Whether the prim is visible or not.
  public let isVisible: Bool

  init(prim: any Prim, depth: Int)
  {
    path = prim.path.string
    name = prim.name.string
    typeName = prim.typeName.isEmpty ? "-" : prim.typeName.string
    self.depth = depth
    hasChildren = !prim.children.isEmpty
    isVisible = prim.isActive
  }

  /// the top-level rows shown when a stage first loads: direct children of
  /// the pseudo-root, at depth 0. everything below stays unmaterialized
  /// until its disclosure triangle is opened.
  public static func roots(of stage: UsdStage) -> [PrimEntry]
  {
    stage.getPseudoRoot().children.map { PrimEntry(prim: $0, depth: 0) }
  }

  /// `entry`'s direct children, ready to splice into the row list right after it - the unit of lazy loading:
  /// expanding a node fetches *only* its immediate children, never the whole subtree beneath it.
  public static func children(of entry: PrimEntry, in stage: UsdStage) -> [PrimEntry]
  {
    stage.getPrim(at: entry.path).children.map { PrimEntry(prim: $0, depth: entry.depth + 1) }
  }
}


// MARK: - Prim Browser Panel

/// Left-hand pane of the UsdView split layout.
/// Shows a scrollable table of prims with "Prim Name / Type / Vis" columns.
public struct PrimBrowserView: View
{
  public let stage: UsdStage
  @Binding public var selectedPath: String?

  /// The currently visible rows, in display order - grown or shrunk in place
  /// as groups are expanded/collapsed.
  @State private var prims: [PrimEntry] = []
  /// Paths whose children are currently materialized into `prims`.
  @State private var expandedPaths: Set<String> = []
  /// Paths whose children are being fetched on a background task - lets the
  /// disclosure glyph show a transient state instead of looking unresponsive,
  /// and keeps a second tap from kicking off a redundant fetch.
  @State private var loadingPaths: Set<String> = []

  private let typeColWidth: CGFloat = 84
  private let visColWidth:  CGFloat = 32

  public init(stage: UsdStage, selectedPath: Binding<String?>)
  {
    self.stage = stage
    _selectedPath = selectedPath
  }

  private struct Row: Identifiable, Hashable
  {
    let entry: PrimEntry
    let isAlternate: Bool
    var id: String { entry.id }
  }

  private var rows: [Row]
  {
    prims.enumerated().map { offset, entry in
      Row(entry: entry, isAlternate: offset % 2 == 1)
    }
  }

  public var body: some View
  {
    VStack(spacing: 0)
    {
      PrimBrowserHeader(
        typeColWidth: typeColWidth,
        visColWidth:  visColWidth
      )

      Divider()

      ScrollView {
        VStack(spacing: 0) {
          ForEach(rows) { row in
            VStack(spacing: 0) {
              PrimBrowserRow(
                entry: row.entry,
                isSelected: selectedPath == row.entry.path,
                isExpanded: expandedPaths.contains(row.entry.path),
                isLoading: loadingPaths.contains(row.entry.path),
                isAlternate: row.isAlternate,
                typeColWidth: typeColWidth,
                visColWidth:  visColWidth,
                onToggleDisclosure: { toggleExpanded(row.entry) },
                onSelect: { selectedPath = row.entry.path }
              )

              Divider()
            }
          }
        }
      }
    }
    .onAppear {
      guard prims.isEmpty else { return }
      loadRoots()
    }
  }

  /// fetches the stage's root rows on a background task and splices them in
  /// once ready - the launch-time counterpart to `loadChildren`, both off
  /// of the main thread so neither path can stall the UI thread.
  private func loadRoots()
  {
    nonisolated(unsafe) let bridgedStage = stage

    Task {
      let roots = await Task.detached(priority: .userInitiated) {
        PrimEntry.roots(of: bridgedStage)
      }.value

      guard prims.isEmpty else { return }
      prims = roots
    }
  }

  /// expands or collapses `entry` in place, materializing or discarding
  /// exactly the rows nested under it.
  private func toggleExpanded(_ entry: PrimEntry)
  {
    if expandedPaths.contains(entry.path)
    {
      // collapsing only touches rows already sitting in memory - cheap
      // enough to stay synchronous and keep the UI feeling instantaneous.
      guard let index = prims.firstIndex(where: { $0.path == entry.path }) else { return }

      let prefix = entry.path + "/"
      let subtreeEnd = prims[(index + 1)...].firstIndex { !$0.path.hasPrefix(prefix) } ?? prims.count

      expandedPaths.subtract(prims[(index + 1) ..< subtreeEnd].map(\.path))
      expandedPaths.remove(entry.path)
      prims.removeSubrange((index + 1) ..< subtreeEnd)
    }
    else
    {
      loadChildren(of: entry)
    }
  }

  /// fetches `entry`'s direct children off the main thread and splices them
  /// in once they're ready.
  private func loadChildren(of entry: PrimEntry)
  {
    guard !loadingPaths.contains(entry.path) else { return }
    loadingPaths.insert(entry.path)

    nonisolated(unsafe) let bridgedStage = stage

    Task {
      let children = await Task.detached(priority: .userInitiated) {
        PrimEntry.children(of: entry, in: bridgedStage)
      }.value

      loadingPaths.remove(entry.path)

      // the row list may have shifted - or `entry` may have been
      // collapsed again - while this fetch was in flight, so relocate
      // it rather than trusting a now possibly stale index.
      guard let index = prims.firstIndex(where: { $0.path == entry.path }),
            !expandedPaths.contains(entry.path)
      else { return }

      prims.insert(contentsOf: children, at: index + 1)
      expandedPaths.insert(entry.path)
    }
  }
}


// MARK: - Header Row

struct PrimBrowserHeader: View
{
  let typeColWidth: CGFloat
  let visColWidth:  CGFloat

  private let nameLeadingInset: CGFloat = 43

  var body: some View
  {
    HStack(spacing: 0)
    {
      Text("PRIM NAME")
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, Int(nameLeadingInset))

      Text("TYPE")
        .frame(width: typeColWidth, alignment: .leading)

      Text("VIS")
        .frame(width: visColWidth, alignment: .center)
        .padding(.trailing, 6)
    }
    .font(.system(size: 10, weight: .bold))
    .foregroundColor(Color(white: 0.55))
    .frame(height: 28)
    .background(Color(white: 0.07))
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(Color.purple.opacity(0.35))
        .frame(height: 1)
    }
  }
}


// MARK: - Prim Row

struct PrimBrowserRow: View
{
  let entry:        PrimEntry
  let isSelected:   Bool
  let isExpanded:   Bool
  let isLoading:    Bool
  let isAlternate:  Bool
  let typeColWidth: CGFloat
  let visColWidth:  CGFloat
  let onToggleDisclosure: () -> Void
  let onSelect: () -> Void

  private let rowHeight:   CGFloat = 24
  private let indentStep:  CGFloat = 14
  private let accentWidth: CGFloat = 3

  @State private var isHovered: Bool = false

  private var rowBackground: Color
  {
    if isSelected  { return Color.purple.opacity(0.28) }
    if isHovered   { return Color(white: 1.0, opacity: 0.06) }
    if isAlternate { return Color(white: 1.0, opacity: 0.028) }
    return Color.clear
  }

  var body: some View
  {
    let glyph = PrimBrowserRow.typeGlyph(for: entry.typeName)

    HStack(spacing: 0)
    {
        // TODO(@furbytm): remove `height: nil` once this upstream layout bug
        // is fixed: https://github.com/moreSwift/swift-cross-ui/issues/626
        Spacer()
          .frame(width: Double(CGFloat(entry.depth) * indentStep + CGFloat(6)), height: nil)

      Text(isLoading ? "…" : (entry.hasChildren ? (isExpanded ? "▾" : "▸") : ""))
        .font(.system(size: 9, weight: .bold))
        .frame(width: 12, height: rowHeight, alignment: .center)
        .foregroundColor(
          isLoading
            ? Color.purple.opacity(0.5)
            : (entry.hasChildren ? Color.purple.opacity(0.85) : Color.clear)
        )
        .onTapGesture
        {
          if entry.hasChildren { onToggleDisclosure() }
        }
      
      // TODO(@furbytm): remove `height: nil` once this upstream layout bug
      // is fixed: https://github.com/moreSwift/swift-cross-ui/issues/626
      Spacer().frame(width: 5, height: nil)

      Text(glyph.symbol)
        .font(.system(size: 10, weight: .semibold))
        .foregroundColor(glyph.tint.opacity(isSelected ? 1.0 : 0.8))
        .frame(width: 16, height: rowHeight, alignment: .center)
      
      // TODO(@furbytm): remove `height: nil` once this upstream layout bug
      // is fixed: https://github.com/moreSwift/swift-cross-ui/issues/626
      Spacer().frame(width: 4, height: nil)

      HStack(spacing: 0)
      {
        Text(entry.name)
          .font(.system(size: 12, weight: .bold))
          .foregroundColor(isSelected ? Color.white : Color(white: 0.85))
          .lineLimit(1)
          .frame(maxWidth: .infinity, alignment: .leading)

        Text(entry.typeName)
          .font(.system(size: 11))
          .foregroundColor(glyph.tint.opacity(0.65))
          .lineLimit(1)
          .frame(width: typeColWidth, alignment: .leading)

        Text(entry.isVisible ? "●": "○")
          .font(.system(size: 10))
          .foregroundColor(
            entry.isVisible
              ? Color(red: 0.55, green: 0.85, blue: 0.62)
              : Color(white: 0.35)
          )
          .frame(width: visColWidth, alignment: .center)
          .padding(.trailing, 6)
      }
      .onTapGesture { onSelect() }
    }
    .frame(height: rowHeight)
    .background(
      Rectangle()
        .fill(rowBackground)
        .onHover { hovering in isHovered = hovering }
    )
    .overlay(alignment: .leading) {
      Rectangle()
        .fill(isSelected ? Color.purple : Color.clear)
        .frame(width: accentWidth)
    }
  }

  /// Maps a USD schema type name to a small glyph & tint so prim categories
  /// (geometry / lights / shading / grouping) are distinguishable at a glance.
  private static func typeGlyph(for typeName: String) -> (symbol: String, tint: Color)
  {
    switch typeName
    {
      case "Xform":
        return ("📦", Color(red: 0.58, green: 0.68, blue: 0.85))

      case "Sphere":
        return ("🔵", Color(red: 0.46, green: 0.80, blue: 0.88))

      case "Cube":
        return ("🧊", Color(red: 0.46, green: 0.80, blue: 0.88))

      case "Mesh", "Cylinder", "Cone", "Capsule", "Plane", "Points":
        return ("🔺", Color(red: 0.46, green: 0.80, blue: 0.88))

      case "Material":
        return ("🎨", Color(red: 0.95, green: 0.66, blue: 0.36))

      case "Shader", "NodeGraph":
        return ("✨", Color(red: 0.96, green: 0.82, blue: 0.42))

      case "DomeLight", "DistantLight", "SphereLight", "RectLight",
           "DiskLight", "CylinderLight", "GeometryLight":
        return ("💡", Color(red: 0.99, green: 0.86, blue: 0.48))

      case "Scope":
        return ("🗂", Color(white: 0.6))

      case "-":
        return ("◦", Color(white: 0.4))

      default:
        return ("◦", Color(white: 0.55))
    }
  }
}
