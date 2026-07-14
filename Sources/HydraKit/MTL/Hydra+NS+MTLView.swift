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

  #if os(macOS)
    import AppKitBackend
    import Combine
    import Metal
    import MetalKit

    public extension Hydra
    {
      struct MTLView: NSViewRepresentable
      {
        public typealias NSViewType = MTKView
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
          mtkView.isPaused = false // driven by display link
          mtkView.framebufferOnly = false // we're using the drawable in our own render pass
          mtkView.enableSetNeedsDisplay = false // don't wait for setNeedsDisplay
          mtkView.presentsWithTransaction = true // sync presentation with our command buffer

          if let mode = CGDisplayCopyDisplayMode(CGMainDisplayID())
          {
            mtkView.preferredFramesPerSecond = Int(mode.refreshRate)
          }
          else
          {
            mtkView.preferredFramesPerSecond = 60
          }

          return Coordinator(mtkView: mtkView)
        }

        public func makeNSView(context: NSViewRepresentableContext<Self>) -> MTKView
        {
          let metalView = context.coordinator.metalView

          metalView.device = device
          metalView.delegate = renderer
          metalView.colorPixelFormat = MTLPixelFormat.bgra8Unorm
          metalView.sampleCount = 1
          metalView.layer?.backgroundColor = NSColor.clear.cgColor
          metalView.layer?.isOpaque = false

          // hand the view a (weak) reference to the
          // engine whose camera it should drive.
          metalView.hydra = hydra

          metalView.becomeFirstResponder()
          return metalView
        }

        public func updateNSView(_: MTKView, context _: NSViewRepresentableContext<Self>)
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

      /// A `MTKView` that turns mouse/trackpad input on the viewport directly
      /// into orbit (tumble) and dolly (zoom) adjustments on the Hydra view
      /// camera.
      final class HydraMTKView: MTKView
      {
        /// Weak: the view drives the engine's camera, but doesn't own the engine.
        weak var hydra: Hydra.RenderEngine?

        /// smoothed per-event orbit velocity.
        private var dragVelocity: (yaw: Double, pitch: Double) = (0.0, 0.0)

        public override var acceptsFirstResponder: Bool { true }

        public override func mouseDown(with event: NSEvent)
        {
          // a fresh click always wins over an in-flight coast.
          hydra?.stopFlick()
          dragVelocity = (0.0, 0.0)
        }

        public override func mouseDragged(with event: NSEvent)
        {
          hydra?.stopFlick()

          let deltaYaw = Double(event.deltaX) * 0.4
          let deltaPitch = Double(event.deltaY) * 0.4

          hydra?.orbit(deltaYaw: deltaYaw, deltaPitch: deltaPitch)

          // weighting recent deltas more heavily means the release
          // velocity reflects how the drag was actually moving, not
          // just a single (possibly noisy) final event.
          dragVelocity.yaw = dragVelocity.yaw * 0.7 + deltaYaw * 0.3
          dragVelocity.pitch = dragVelocity.pitch * 0.7 + deltaPitch * 0.3
        }

        public override func mouseUp(with event: NSEvent)
        {
          // let the release velocity keep the viewport tumbling until it gradually
          // coasts to a stop.
          hydra?.flick(deltaYaw: dragVelocity.yaw, deltaPitch: dragVelocity.pitch)
        }

        public override func scrollWheel(with event: NSEvent)
        {
          // two finger trackpad scroll (or a mouse wheel): scrolling up
          // (positive `scrollingDeltaY`) dollies inward, toward the subject -
          // matching the pinch-to-zoom direction in `magnify` below.
          hydra?.dolly(by: -Double(event.scrollingDeltaY) * 0.01)
        }

        public override func magnify(with event: NSEvent)
        {
          // trackpad pinch: `magnification` is a small fractional delta per
          // tick (spreading fingers apart is positive = zoom in = move closer).
          hydra?.dolly(by: -event.magnification)
        }
      }
    }
  #endif // os(macOS)
#endif // canImport(SwiftCrossUI)
