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
          mtkView.isPaused = true // warm up the stage before the first real frame
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
          
          // warm up: force stage population off the main thread while
          // the view stays paused, then start the normal frame loop.
          Task { @MainActor in
            await hydra.waitUntilSceneReady()
            metalView.isPaused = false
          }
          
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

        /// Where the press started, so a click can be told from a drag
        /// by how far the mouse actually moved.
        private var mouseDownLocation: NSPoint = .zero

        /// True once a drag used a modifier (Shift = pan, Control = dolly), so
        /// release neither picks nor coasts, those belong to a plain orbit drag.
        private var dragUsedModifier = false

        /// A press that moves less than this (in points) is a click, not a
        /// tumble. `mouseDragged` fires on sub-pixel jitter, so a boolean
        /// "did it drag" flag would treat nearly every real click as a drag and
        /// never pick.
        private static let clickSlop: CGFloat = 4.0

        public override var acceptsFirstResponder: Bool { true }

        public override func mouseDown(with event: NSEvent)
        {
          // a fresh click always wins over an in-flight coast.
          hydra?.stopFlick()
          dragVelocity = (0.0, 0.0)
          dragUsedModifier = false
          mouseDownLocation = event.locationInWindow
        }

        public override func mouseDragged(with event: NSEvent)
        {
          hydra?.stopFlick()

          // shift drags pan, ctrl drags dolly,
          // a plain drag orbits (and coasts on
          // release).
          if event.modifierFlags.contains(.shift)
          {
            dragUsedModifier = true
            hydra?.pan(deltaX: Double(event.deltaX),
                       deltaY: Double(event.deltaY),
                       viewHeight: Double(bounds.height))
            return
          }

          if event.modifierFlags.contains(.control)
          {
            dragUsedModifier = true
            // dragging down (positive deltaY) dollies out,
            // matching Ctrl+MMB.
            hydra?.dolly(by: Double(event.deltaY) * 0.01)
            return
          }

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
          defer { dragUsedModifier = false }

          // a modifier drag (pan/dolly) neither picks nor coasts.
          guard !dragUsedModifier else { return }

          let moved = hypot(event.locationInWindow.x - mouseDownLocation.x,
                            event.locationInWindow.y - mouseDownLocation.y)

          // a press that barely moved is a pick, not a tumble.
          if moved < Self.clickSlop
          {
            guard let hydra else { return }
            // locationInWindow is y-up (AppKit), the view is unflipped,
            // so the converted point is y-up too, which is what `pick`
            // expects.
            let viewPoint = convert(event.locationInWindow, from: nil)
            let result = hydra.pick(at: viewPoint, viewSize: bounds.size)
            hydra.onPick?(result)
            return
          }

          // otherwise, let the release velocity keep the viewport
          // tumbling until it gradually coasts to a stop.
          hydra?.flick(deltaYaw: dragVelocity.yaw, deltaPitch: dragVelocity.pitch)
        }

        public override func scrollWheel(with event: NSEvent)
        {
          // shift + scroll pans, a plain scroll (two-finger trackpad
          // or wheel) dollies, scrolling up (positive `scrollingDeltaY`)
          // moves inward, matching the pinch-to-zoom direction within
          // `magnify` below.
          if event.modifierFlags.contains(.shift)
          {
            hydra?.pan(deltaX: Double(event.scrollingDeltaX),
                       deltaY: Double(event.scrollingDeltaY),
                       viewHeight: Double(bounds.height))
          }
          else
          {
            hydra?.dolly(by: -Double(event.scrollingDeltaY) * 0.01)
          }
        }

        public override func magnify(with event: NSEvent)
        {
          // trackpad pinch: `magnification` is a
          // small fractional delta per tick which
          // means that (spreading fingers apart
          // is positive = zoom in = move closer).
          hydra?.dolly(by: -event.magnification)
        }

        public override func keyDown(with event: NSEvent)
        {
          guard let hydra else { super.keyDown(with: event); return }

          // leave cmd shortcuts (select-all, etc.) to the system.
          guard !event.modifierFlags.contains(.command)
          else { super.keyDown(with: event); return }

          let ctrl = event.modifierFlags.contains(.control)
          let step = 15.0

          // arrow keys, home and the numpad send no character,
          // so match them by virtual key code. Arrow keys orbit,
          // which is the natural laptop stand-in for the numpad,
          // the numpad cases serve external keyboards.
          switch Int(event.keyCode)
          {
            case 123: hydra.orbit(deltaYaw: -step, deltaPitch: 0.0); return // Left
            case 124: hydra.orbit(deltaYaw: step, deltaPitch: 0.0); return  // Right
            case 126: hydra.orbit(deltaYaw: 0.0, deltaPitch: -step); return // Up
            case 125: hydra.orbit(deltaYaw: 0.0, deltaPitch: step); return  // Down
            case 115: hydra.frameAll(); return                              // Home (Fn+Left)
            case 53:  hydra.clearSelection(); return                        // Escape - deselect
            case 65:  hydra.frameSelected(); return                         // Keypad .
            case 83:  hydra.setStandardView(ctrl ? .back : .front); return  // Keypad 1
            case 85:  hydra.setStandardView(ctrl ? .left : .right); return  // Keypad 3
            case 89:  hydra.setStandardView(ctrl ? .bottom : .top); return  // Keypad 7
            case 86:  hydra.orbit(deltaYaw: -step, deltaPitch: 0.0); return // Keypad 4
            case 88:  hydra.orbit(deltaYaw: step, deltaPitch: 0.0); return  // Keypad 6
            case 91:  hydra.orbit(deltaYaw: 0.0, deltaPitch: -step); return // Keypad 8
            case 84:  hydra.orbit(deltaYaw: 0.0, deltaPitch: step); return  // Keypad 2
            case 69:  hydra.dolly(by: -0.1); return                         // Keypad +
            case 78:  hydra.dolly(by: 0.1); return                          // Keypad -
            default:  break
          }

          // macbook friendly bindings on the regular
          // keys, no numpad needed.
          switch event.charactersIgnoringModifiers ?? ""
          {
            case "a", "A":                                                    // select all / deselect
              if event.modifierFlags.contains(.option) { hydra.clearSelection() }
              else { hydra.selectAll() }
            case "f", "F", ".": hydra.frameSelected()                         // frame selected
            case "1":           hydra.setStandardView(ctrl ? .back : .front)  // front / back
            case "3":           hydra.setStandardView(ctrl ? .left : .right)  // right / left
            case "7":           hydra.setStandardView(ctrl ? .bottom : .top)  // top / bottom
            case "=", "+":      hydra.dolly(by: -0.1)                         // zoom in
            case "-", "_":      hydra.dolly(by: 0.1)                          // zoom out
            default:            super.keyDown(with: event)
          }
        }
      }
    }
  #endif // os(macOS)
#endif // canImport(SwiftCrossUI)
