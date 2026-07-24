<!-- markdownlint-configure-file {
  "MD013": {
    "code_blocks": false,
    "tables": false
  },
  "MD033": false,
  "MD041": false
} -->

<div align="center">

### SwiftUSD

<p align="center">
  <i align="center">A <b>Swift-native</b>, <b>cross-platform framework</b> for building <b>OpenUSD</b> applications.</i>
</p>

</div>

<h4 align="center">
  <a href="https://github.com/wabiverse/swift-usd/actions/workflows/swift-android.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/wabiverse/swift-usd/swift-android.yml?style=flat-square&label=android&labelColor=3DDC84&logoColor=FFFFFF&logo=android">
  </a>
  <a href="https://github.com/wabiverse/swift-usd/actions/workflows/swift-ubuntu.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/wabiverse/swift-usd/swift-ubuntu.yml?style=flat-square&label=ubuntu%20&labelColor=E95420&logoColor=FFFFFF&logo=ubuntu">
  </a>
  <a href="https://github.com/wabiverse/swift-usd/actions/workflows/swift-macos.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/wabiverse/swift-usd/swift-macos.yml?style=flat-square&label=macOS&labelColor=000000&logo=apple">
  </a>
  <a href="https://github.com/wabiverse/swift-usd/actions/workflows/swift-ios.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/wabiverse/swift-usd/swift-ios.yml?style=flat-square&label=iOS&labelColor=000000&logo=apple">
  </a>
  <a href="https://github.com/wabiverse/swift-usd/actions/workflows/swift-visionos.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/wabiverse/swift-usd/swift-visionos.yml?style=flat-square&label=visionOS&labelColor=000000&logo=apple">
  </a>
  <a href="https://github.com/wabiverse/swift-usd/actions/workflows/swift-debug-windows.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/wabiverse/swift-usd/swift-debug-windows.yml?style=flat-square&label=windows&labelColor=357EC7&logo=gitforwindows">
  </a>
  <br>
    <a href="https://wabiverse.github.io/swift-usd/documentation/pixarusd/">
    <img src="https://img.shields.io/badge/v24%2E8%2E14-DocumentationSource?style=flat-square&label=docs&labelColor=F05138&logo=swift&color=gray&logoColor=white">
  </a>
  <a href="https://github.com/wabiverse/swift-usd/graphs/contributors">
    <img src="https://img.shields.io/github/contributors-anon/wabiverse/swift-usd?color=8A2BE2&style=flat-square" alt="contributors" style="height: 20px;">
  </a>
  <a href="https://discord.gg/#">
    <img src="https://img.shields.io/badge/discord-7289da.svg?style=flat-square&logo=discord" alt="discord" style="height: 20px;">
  </a>
  <a href="https://openusd.org/release/index.html">
    <img src="https://img.shields.io/badge/openusd-blue.svg?style=flat-square&logo=data:image/svg%2bxml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAxMiAxMiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTYuOTQwMzEgMTEuMzU4MlY3LjQ3NzY0VjMuNjU2NzRMMCAxLjI2ODY4VjguOTg1MUw2Ljk0MDMxIDExLjM1ODJaTTEuMjY4NjYgOC4wMTQ5NVYzLjE3OTEzTDUuNjExOTUgNC42NTY3NFY5LjQ5MjU3TDEuMjY4NjYgOC4wMTQ5NVoiIGZpbGw9IiMyMDhFQ0QiLz4KPHBhdGggZD0iTTEuNzc2MTIgNy41OTcwM0w1LjA4OTU2IDguNzMxMzZWNS4wNzQ2NEwxLjc3NjEyIDMuOTQwMzFWNy41OTcwM1oiIGZpbGw9IiM3REQxRjYiLz4KPHBhdGggZD0iTTguOTI1MzQgNS41OTcwMkw5Ljk5OTk3IDUuOTcwMTZWMS4zNTgyMUw2LjA0NDc0IDBWMS4xNjQxOEw4LjkyNTM0IDIuMTY0MThWNS41OTcwMloiIGZpbGw9IiM3REQxRjYiLz4KPHBhdGggZD0iTTIuOTg1MTEgMC41OTcwMTVWMS43NjEyTDcuMzczMTcgMy4yODM1OVY4LjI1Mzc0TDguNDQ3OCA4LjYxMTk1VjIuNDc3NjFMMi45ODUxMSAwLjU5NzAxNVoiIGZpbGw9IiMzNUMzRjEiLz4KPC9zdmc+Cg==" alt="youtube" style="height: 20px;">
  </a>
</h4>

<div align="center">
  <image align=top width="70%" src="https://github.com/user-attachments/assets/ad0a019c-17fd-422f-9145-b88aad3f9f06">
</div>

<div align="center">

# Building OpenUSD Apps in Swift

</div>

A Swift-native, cross-platform framework for building OpenUSD applications - bringing the USD ecosystem to Android,
Linux, Windows, and Apple platforms through syntactically pleasing Swift OpenUSD APIs, a composable Hydra viewport,
native UI, and real-time workflows. Unbound from any single vendor's GPU or platform.

##### Example of creating a new USD stage with a transform and a sphere in Swift.
```swift
import Foundation
import OpenUSDKit

@main
enum Creator
{
  static func main()
  {
    /* Setup all usd resources (python, plugins, resources). */

    Pixar.Bundler.shared.setup(.resources)

    /* Create a new USD stage with a transform and a sphere. */

    let stage = Usd.Stage.createNew("HelloWorldExample.usd")

    UsdGeom.Xform.define(stage, path: "/Hello")
    UsdGeom.Sphere.define(stage, path: "/Hello/World")

    stage.getPseudoRoot().set(doc: "Hello World Example (Swift)!")

    stage.save()
  }
}
```

##### Example of creating the same USD stage above, declaratively.
```swift
USDStage("HelloWorldExample", ext: .usd)
{
  USDPrim("Hello", type: .xform)
  {
    USDPrim("World", type: .sphere)
  }
}
.set(doc: "Hello World Example (Swift)!")
.save()
```

##### Example of composing a Hydra viewport with [**SwiftCrossUI**](https://github.com/moreSwift/swift-cross-ui)
```swift
import Foundation
import OpenUSDKit
import HydraKit
import SwiftCrossUI

@main
struct MyApp: App {
  typealias Backend = PlatformBackend

  let stage: UsdStage
  let engine: Hydra.RenderEngine

  init() {
    Pixar.Bundler.shared.setup(.resources)

    stage = UsdStage.createInMemory()
    engine = Hydra.RenderEngine(stage: stage)
  }
  
  var body: some Scene {
    WindowGroup("MyApp") {
      Hydra.Viewport(engine: engine)
    }
  }
}
```

```swift
import SwiftCrossUI
  
// Platform backend selection is explicit for now, this will eventually just end up
// in HydraKit to handle this by default, but figured it was worth showing what is
// going on under the hood, if developers wish to make extensible backends for
// their own apps.
#if os(Android)
  import AndroidBackend
  public typealias PlatformBackend = AndroidBackend
#elseif os(Linux)
  import GtkBackend
  public typealias PlatformBackend = GtkBackend
#elseif os(Windows)
  import WinUIBackend
  public typealias PlatformBackend = WinUIBackend
#elseif os(macOS)
  import AppKitBackend
  public typealias PlatformBackend = AppKitBackend
#else
  import UIKitBackend
  public typealias PlatformBackend = UIKitBackend
#endif
```

### **Getting Started**

##### To use **OpenUSD** in Swift, run the following in your terminal:
```swift
mkdir MySwiftApp
cd MySwiftApp

swift package init --type executable --name MySwiftApp

open Package.swift
```


##### Then, in your project's **`Package.swift`** file, add the monolithic **OpenUSDKit** product as a target dependency.
```swift
// swift-tools-version: 6.1
import PackageDescription

let package = Package(
  name: "MySwiftPackage",
  platforms: [
    .macOS(.v14),
    .visionOS(.v1),
    .iOS(.v17),
    .tvOS(.v17),
    .watchOS(.v10)
  ],
  products: [
    .executable(
      name: "MySwiftApp",
      targets: ["MySwiftApp"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/wabiverse/swift-usd.git", from: "26.8.2")
  ],
  targets: [
    .executableTarget(
      name: "MySwiftApp",
      dependencies: [
        // add the monolithic OpenUSDKit product as a dependency.
        .product(name: "OpenUSDKit", package: "swift-usd"),
        // (optional) compose Hydra.Viewport with SwiftCrossUI apps.
        .product(name: "HydraKit", package: "swift-usd"),
      ],
      cxxSettings: [
        // forces swift's internal clang header parser to use a
        // unified stdlib memory layout across all module boundaries
        // to prevent ODR errors.
        .define("_LIBCPP_ABI_NO_COMPRESSED_PAIR_PADDING")
      ],
      swiftSettings: [
        // enable swift/c++ interop.
        .interoperabilityMode(.Cxx)
      ]
    ),
  ],
  // use gnucxx17 language standard.
  cxxLanguageStandard: .gnucxx17
)
```

<br/>

# **UsdView (Under Development)**

<table>
  <tr>
    <td>
      <img width="1093" height="675" alt="Screenshot 2026-07-24 at 1 41 30 AM" src="https://github.com/user-attachments/assets/a202f592-ba29-4c31-a4d8-9091e93b9a64" />
      <br/>
      <img width="60%" alt="Simulator Screenshot - Apple Vision Pro - 2026-06-08 at 17 32 46" src="https://github.com/user-attachments/assets/6325d824-6eb4-47d2-ac0c-3e32b105d167" />
    </td>
    <td>
      <img width="100%" alt="usdview_on_ios" src="https://github.com/user-attachments/assets/7a5716e4-78ff-44bf-89df-892fe33297d4" />
    </td>
  </tr>
</table>

  A "run everywhere" USD viewer, written entirely in Swift. UsdView pairs **Hydra** - Pixar's USD imaging engine - with
  [**SwiftCrossUI**](https://github.com/moreSwift/swift-cross-ui) to bring one SwiftUI-style codebase to every platform
  Swift reaches: macOS, iOS, visionOS, Linux, Windows, and Android. Browsing, inspecting, and orbiting USD stages with
  platform native UI everywhere.

  ### Linux

  > [!TIP]
  > Install the [**bundler**](https://github.com/moreSwift/swift-bundler.git) locally by running the following commands in your terminal:

<div align="center">

  <div align="left">
  
  #### **Debian**

  Install the required dependencies, as well as [`appimagetool`](https://swiftbundler.dev/documentation/swift-bundler/installation#appimagetool-required-for-AppImage-bundling).
  ```pwsh
  sudo apt install patchelf
  sudo apt install rpm
  ```
  
  #### **Fedora**

  Install the required dependencies, as well as [`appimagetool`](https://swiftbundler.dev/documentation/swift-bundler/installation#appimagetool-required-for-AppImage-bundling).
  ```pwsh
  sudo dnf install patchelf
  sudo dnf install rpmdevtools
  ```
  
  #### **Install Swift Bundler**
  ```pwsh
  git clone https://github.com/moreSwift/swift-bundler.git
  cd swift-bundler
  
  swift build -c release
  sudo cp .build/release/swift-bundler /usr/local/bin/
  ```

  </div>
  
  <div align="left">

  Finally, to run and bundle **UsdView** on **Linux**:
  ```pwsh
  git clone https://github.com/wabiverse/swift-usd.git
  cd swift-usd
  
  swift bundler run -c release UsdView
  ```
  
  </div>

</div>

  ### Apple Platforms (macOS, visionOS, iOS)

  > [!TIP]
  > Install the [**bundler**](https://github.com/moreSwift/swift-bundler.git) locally by running the following commands in your terminal:

<div align="center">

  <div align="left">

  ```pwsh
  git clone https://github.com/moreSwift/swift-bundler.git
  cd swift-bundler
  
  swift build -c release
  sudo cp .build/release/swift-bundler /usr/local/bin/
  ```

  #### **macOS**

  Run and bundle **UsdView** on **macOS**.
  ```pwsh
  git clone https://github.com/wabiverse/swift-usd.git
  cd swift-usd
  
  swift bundler run -c release UsdView
  ```

  #### **visionOS** or **iOS**

  Run and bundle **UsdView** on **visionOS** or **iOS**.
  ```pwsh
  # list available iOS and visionOS simulators.
  swift bundler simulators

  # boot a simulator from the list.
  swift bundler simulators boot [id-of-device]

  # if you booted a visionOS device.
  swift bundler run -p visionOSSimulator -c release UsdView

  # if you booted a iOS device.
  swift bundler run -p iOSSimulator -c release UsdView
  ```

  </div>

</div>

  ### Android Devices
  
<div align="center">

  <div align="left">

  Run and bundle **UsdView** on **Android**.
  ```pwsh
  # list available Android simulators.
  swift bundler simulators

  # boot a simulator from the list.
  swift bundler simulators boot [id-of-device]

  # if you booted a Android device.
  SWIFTUSD_ANDROID_SUPPORT_ENABLED=1 swift bundler run --simulator "Pixel_10_Pro" -c release UsdView
  ```

  </div>

</div>

<br/>



<br>

> [!NOTE]
> Swift is an open source programming language that is fully supported across [**Android**](https://www.swift.org/documentation/articles/swift-sdk-for-android-getting-started.html), **Linux** and [**Swift on Server**](https://www.swift.org/server/), the entire **Apple** family of devices: **macOS**, **visionOS**, **iOS**, **tvOS**, **watchOS**, as well as support for **Microsoft Windows**. To learn more about Swift, please visit [swift.org](https://www.swift.org).

<br>

<hr/>

###### SwiftUSD is licensed under the terms of the [Tomorrow Open Source Technology 1.0 License](https://openusd.org/license).
