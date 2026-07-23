/* ----------------------------------------------------------------
 * :: :  O  P  E  N  U  S  D  :                                  ::
 * ----------------------------------------------------------------
 * Licensed under the terms set forth in the LICENSE.txt file, this
 * file is available at https://openusd.org.
 *
 *                   Copyright (C) 2016 Pixar. All Rights Reserved.
 *                              Copyright (C) 2024 Wabi Foundation.
 * ----------------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ---------------------------------------------------------------- */

import Foundation
import OpenUSDKit

#if canImport(SwiftCrossUI)
import SwiftCrossUI

#if os(iOS) || os(visionOS)
import Combine
import Metal
import MetalKit
import UIKitBackend

public extension Hydra
{
  struct MTLView: UIViewRepresentable
  {
    public typealias UIViewType = MTKView
    public typealias SetNeedsDisplayTrigger = AnyPublisher<Void, Never>

    public enum DrawingMode
    {
      case timeUpdates(preferredFramesPerSecond: Int)
      case drawNotifications(setNeedsDisplayTrigger: SetNeedsDisplayTrigger?)
    }

    private let hydra: Hydra.RenderEngine!
    private let device: MTLDevice!
    private let renderer: MTLRenderer!

    public init(hydra: Hydra.RenderEngine, renderer: MTLRenderer)
    {
      self.hydra = hydra
      device = hydra.hydraDevice
      self.renderer = renderer
    }

    public func makeCoordinator() -> Coordinator
    {
      let mtkView = HydraMTKView()
      mtkView.isPaused = true // warm up the stage before the first real frame
      mtkView.framebufferOnly = false // we're using the drawable in our own render pass
      mtkView.enableSetNeedsDisplay = false // don't wait for setNeedsDisplay
      mtkView.presentsWithTransaction = true // sync presentation with our command buffer
      #if !os(visionOS)
        mtkView.preferredFramesPerSecond = UIScreen.main.maximumFramesPerSecond
      #endif // !os(visionOS)

      return Coordinator(mtkView: mtkView)
    }

    public func makeUIView(context: UIViewRepresentableContext<Self>) -> MTKView
    {
      let metalView = context.coordinator.metalView

      metalView.device = device
      metalView.delegate = renderer
      metalView.colorPixelFormat = MTLPixelFormat.bgra8Unorm
      metalView.sampleCount = 1
      metalView.layer.backgroundColor = UIColor.clear.cgColor
      metalView.layer.isOpaque = true

      // hand the view a (weak) reference to the
      // engine whose camera it should drive.
      metalView.hydra = hydra

      metalView.becomeFirstResponder()
      
      // warm up: force stage population off the main thread while
      // the view stays paused, then start the normal frame loop.
      Task { @MainActor in
        await hydra.waitUntilSceneReady()
        metalView.isPaused = false
      }
      
      return metalView
    }

    public func updateUIView(_: MTKView, context _: UIViewRepresentableContext<Self>)
    {}

    public class Coordinator
    {
      private var cancellable: AnyCancellable?
      public var metalView: HydraMTKView

      public init(mtkView: HydraMTKView)
      {
        cancellable = nil
        metalView = mtkView
      }
    }
  }

  /// A `MTKView` that turns touch input on the viewport directly
  /// into orbit (tumble) and dolly (zoom) adjustments on the Hydra view
  /// camera.
  final class HydraMTKView: MTKView
  {
    /// Weak: the view drives the engine's camera, but doesn't own the engine.
    weak var hydra: Hydra.RenderEngine?

    public override var canBecomeFirstResponder: Bool { true }

    public override init(frame frameRect: CGRect, device: MTLDevice?)
    {
      super.init(frame: frameRect, device: device)
      setupGestureRecognizers()
    }

    public required init(coder: NSCoder)
    {
      super.init(coder: coder)
      setupGestureRecognizers()
    }

    private func setupGestureRecognizers()
    {
      addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
      addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:))))
      addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }

    @objc
    private func handleTap(_ gesture: UITapGestureRecognizer)
    {
      guard let hydra, gesture.state == .ended else { return }

      // uikit view space is y-down, but `pick`
      // expects y-up (AppKit's convention), so
      // flip before handing the tap point over.
      let loc = gesture.location(in: self)
      let viewPoint = CGPoint(x: loc.x, y: bounds.height - loc.y)
      let result = hydra.pick(at: viewPoint, viewSize: bounds.size)
      hydra.onPick?(result)
    }
    
    @objc
    private func handlePan(_ gesture: UIPanGestureRecognizer)
    {
      switch gesture.state
      {
      case .began:
        // a fresh drag always wins over an in-flight coast.
        hydra?.stopFlick()

      case .changed:
        // one-finger drag across the viewport: translate the per-tick delta
        // into the same yaw/pitch orbit the macOS `mouseDragged` handler uses,
        // then reset the translation so each callback reports a fresh delta.
        let delta = gesture.translation(in: self)

        hydra?.orbit(
          deltaYaw: Double(delta.x) * 0.4,
          deltaPitch: Double(delta.y) * 0.4
        )

        gesture.setTranslation(.zero, in: self)

      case .ended, .cancelled:
        // click-and-flick: `velocity` is points/second, so scale it down
        // to the per-tick delta `flick` (and `orbit`) expect at the coast
        // timer's ~60Hz rate, then let the release speed keep the viewport
        // tumbling until it gradually coasts to a stop.
        let velocity = gesture.velocity(in: self)
        let perTick = 1.0 / 60.0

        hydra?.flick(
          deltaYaw: Double(velocity.x) * perTick * 0.4,
          deltaPitch: Double(velocity.y) * perTick * 0.4
        )

      default:
        break
      }
    }

    @objc
    private func handlePinch(_ gesture: UIPinchGestureRecognizer)
    {
      // two-finger pinch: `scale` is cumulative relative to the
      // gesture's start - reset it each callback so `dolly` only
      // ever sees the incremental change.
      hydra?.dolly(by: -(gesture.scale - 1.0))

      gesture.scale = 1.0
    }
  }
}
#endif // os(iOS)
#endif // canImport(SwiftCrossUI)
