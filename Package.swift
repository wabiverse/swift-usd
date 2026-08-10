// swift-tools-version: 6.1
import CompilerPluginSupport
import Foundation
import PackageDescription

let package = Package(
  name: "swift-usd",
  platforms: [
    .macOS(.v14),
    .visionOS(.v1),
    .iOS(.v17),
    .tvOS(.v17),
    .watchOS(.v10)
  ],
  products: [
    // --- Monolithic lib for Swift & C++ CMake consumers ---
    .library(
      name: "swiftusd_m",
      targets: [
        "Arch", "Tf", "Js", "Gf", "Trace", "Vt", "Work", "Pegtl", "Plug", "Ts",
        "Ar", "Kind", "Sdf", "Pcp", "Usd", "Sdr", "UsdGeom", "UsdShade", "UsdLod",
        "UsdLux", "UsdHydra", "SdrGlslfx", "UsdAbc", "UsdDraco", "UsdMedia",
        "UsdMtlx", "UsdPhysics", "UsdProc", "UsdRender", "UsdRi", "UsdSkel",
        "UsdUI", "UsdUtils", "UsdVol", "UsdProfiles", "CameraUtil", "Hf", "PxOsd",
        "Hd", "HdAr", "HdMtlx", "HdSi", "HdSt", "HdStorm", "Hdx", "Garch", "Hgi",
        "HgiGL", "HgiInterop", "Hio", "Glf", "GeomUtil", "UsdShaders",
        "UsdImaging", "UsdImagingGL", "UsdExecImaging", "UsdIRImaging", "Vdf",
        "Esf", "Ef", "EsfUsd", "Exec", "ExecUsd", "ExecGeom", "ExecIr",
        "UsdValidation", "UsdGeomValidators", "UsdPhysicsValidators",
        "UsdShadeValidators", "UsdSkelValidators", "UsdUtilsValidators",
        "UsdLodValidators", "UsdLuxValidators",
      ]
    ),
    // ---------------- Pixar -----
    .library(
      name: "pxr",
      targets: ["pxr"]
    ),
    // ----------- Pixar.Base -----
    .library(
      name: "Arch",
      targets: ["Arch"]
    ),
    .library(
      name: "Tf",
      targets: ["Tf"]
    ),
    .library(
      name: "Js",
      targets: ["Js"]
    ),
    .library(
      name: "Gf",
      targets: ["Gf"]
    ),
    .library(
      name: "Trace",
      targets: ["Trace"]
    ),
    .library(
      name: "Vt",
      targets: ["Vt"]
    ),
    .library(
      name: "Work",
      targets: ["Work"]
    ),
    .library(
      name: "Pegtl",
      targets: ["Pegtl"]
    ),
    .library(
      name: "Plug",
      targets: ["Plug"]
    ),
    .library(
      name: "Ts",
      targets: ["Ts"]
    ),
    // ------------ Pixar.Usd -----
    .library(
      name: "Ar",
      targets: ["Ar"]
    ),
    .library(
      name: "Kind",
      targets: ["Kind"]
    ),
    .library(
      name: "Sdf",
      targets: ["Sdf"]
    ),
    .library(
      name: "Pcp",
      targets: ["Pcp"]
    ),
    .library(
      name: "Usd",
      targets: ["Usd"]
    ),
    .library(
      name: "Sdr",
      targets: ["Sdr"]
    ),
    .library(
      name: "UsdGeom",
      targets: ["UsdGeom"]
    ),
    .library(
      name: "UsdShade",
      targets: ["UsdShade"]
    ),
    .library(
      name: "UsdLod",
      targets: ["UsdLod"]
    ),
    .library(
      name: "UsdLux",
      targets: ["UsdLux"]
    ),
    .library(
      name: "UsdHydra",
      targets: ["UsdHydra"]
    ),
    .library(
      name: "SdrGlslfx",
      targets: ["SdrGlslfx"]
    ),
    // .library(
    //   name: "SdrOsl",
    //   targets: ["SdrOsl"]
    // ),
    .library(
      name: "UsdAbc",
      targets: ["UsdAbc"]
    ),
    .library(
      name: "UsdDraco",
      targets: ["UsdDraco"]
    ),
    .library(
      name: "UsdMedia",
      targets: ["UsdMedia"]
    ),
    .library(
      name: "UsdMtlx",
      targets: ["UsdMtlx"]
    ),
    .library(
      name: "UsdPhysics",
      targets: ["UsdPhysics"]
    ),
    .library(
      name: "UsdProc",
      targets: ["UsdProc"]
    ),
    .library(
      name: "UsdRender",
      targets: ["UsdRender"]
    ),
    .library(
      name: "UsdRi",
      targets: ["UsdRi"]
    ),
    .library(
      name: "UsdSkel",
      targets: ["UsdSkel"]
    ),
    .library(
      name: "UsdUI",
      targets: ["UsdUI"]
    ),
    .library(
      name: "UsdUtils",
      targets: ["UsdUtils"]
    ),
    .library(
      name: "UsdVol",
      targets: ["UsdVol"]
    ),
    .library(
      name: "UsdProfiles",
      targets: ["UsdProfiles"]
    ),
    // -------- Pixar.Imaging -----
    .library(
      name: "CameraUtil",
      targets: ["CameraUtil"]
    ),
    .library(
      name: "Hf",
      targets: ["Hf"]
    ),
    .library(
      name: "PxOsd",
      targets: ["PxOsd"]
    ),
    .library(
      name: "Hd",
      targets: ["Hd"]
    ),
    .library(
      name: "HdAr",
      targets: ["HdAr"]
    ),
    .library(
      name: "HdMtlx",
      targets: ["HdMtlx"]
    ),
    .library(
      name: "HdSi",
      targets: ["HdSi"]
    ),
    .library(
      name: "HdSt",
      targets: ["HdSt"]
    ),
    .library(
      name: "HdStorm",
      targets: ["HdStorm"]
    ),
    .library(
      name: "Hdx",
      targets: ["Hdx"]
    ),
    .library(
      name: "HdGp",
      targets: ["HdGp"]
    ),
    .library(
      name: "Garch",
      targets: ["Garch"]
    ),
    .library(
      name: "Hgi",
      targets: ["Hgi"]
    ),
    .library(
      name: "HgiMetal",
      targets: ["HgiMetal"]
    ),
    // .library(
    //   name: "HgiVulkan",
    //   targets: ["HgiVulkan"]
    // ),
    .library(
      name: "HgiGL",
      targets: ["HgiGL"]
    ),
    .library(
      name: "HgiInterop",
      targets: ["HgiInterop"]
    ),
    .library(
      name: "Hio",
      targets: ["Hio"]
    ),
    .library(
      name: "HioAVIF",
      targets: ["HioAVIF"]
    ),
    .library(
      name: "HioImageIO",
      targets: ["HioImageIO"]
    ),
    .library(
      name: "HioOIIO",
      targets: ["HioOIIO"]
    ),
    .library(
      name: "HioOpenEXR",
      targets: ["HioOpenEXR"]
    ),
    .library(
      name: "HioOpenVDB",
      targets: ["HioOpenVDB"]
    ),
    .library(
      name: "Glf",
      targets: ["Glf"]
    ),
    .library(
      name: "GeomUtil",
      targets: ["GeomUtil"]
    ),
    // ----- Pixar.UsdImaging -----
    .library(
      name: "UsdShaders",
      targets: ["UsdShaders"]
    ),
    .library(
      name: "UsdSkelImaging",
      targets: ["UsdSkelImaging"]
    ),
    .library(
      name: "UsdImaging",
      targets: ["UsdImaging"]
    ),
    .library(
      name: "UsdImagingGL",
      targets: ["UsdImagingGL"]
    ),
    .library(
      name: "UsdExecImaging",
      targets: ["UsdExecImaging"]
    ),
    .library(
      name: "UsdIRImaging",
      targets: ["UsdIRImaging"]
    ),
    .library(
      name: "USDOverlays",
      targets: ["USDOverlays"]
    ),
    // ----------- Pixar.Exec -----
    .library(
      name: "Vdf",
      targets: ["Vdf"]
    ),
    .library(
      name: "Esf",
      targets: ["Esf"]
    ),
    .library(
      name: "Ef",
      targets: ["Ef"]
    ),
    .library(
      name: "EsfUsd",
      targets: ["EsfUsd"]
    ),
    .library(
      name: "Exec",
      targets: ["Exec"]
    ),
    .library(
      name: "ExecUsd",
      targets: ["ExecUsd"]
    ),
    .library(
      name: "ExecGeom",
      targets: ["ExecGeom"]
    ),
    .library(
      name: "ExecIr",
      targets: ["ExecIr"]
    ),
    // ------- Pixar.UsdValidation -----
    .library(
      name: "UsdValidation",
      targets: ["UsdValidation"]
    ),
    .library(
      name: "UsdGeomValidators",
      targets: ["UsdGeomValidators"]
    ),
    .library(
      name: "UsdPhysicsValidators",
      targets: ["UsdPhysicsValidators"]
    ),
    .library(
      name: "UsdShadeValidators",
      targets: ["UsdShadeValidators"]
    ),
    .library(
      name: "UsdSkelValidators",
      targets: ["UsdSkelValidators"]
    ),
    .library(
      name: "UsdUtilsValidators",
      targets: ["UsdUtilsValidators"]
    ),
    .library(
      name: "UsdLodValidators",
      targets: ["UsdLodValidators"]
    ),
    .library(
      name: "UsdLuxValidators",
      targets: ["UsdLuxValidators"]
    ),
    // ----------------- Apps -----
    .executable(
      name: "UsdView",
      targets: ["UsdView"]
    ),
    .executable(
      name: "ousd",
      targets: ["ousd"]
    ),
    .executable(
      name: "Examples",
      targets: ["Examples"]
    ),
    // -------- Swift Plugins -----
    .plugin(
      name: "OpenUSDPlugin",
      targets: ["OpenUSDPlugin"]
    ),
    .plugin(
      name: "UsdGenSchemaPlugin",
      targets: ["UsdGenSchemaPlugin"]
    ),
    // ------------- Rust USD -----
    // .library(
    //   name: "rust-usd",
    //   type: .static,
    //   targets: ["rust-usd"]
    // ),
    // ------- Monolithic USD -----
    .library(
      name: "OpenUSDKit",
      targets: ["OpenUSDKit"]
    ),
    .library(
      name: "HydraKit",
      targets: ["HydraKit"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/SwiftUsd.git", from: "8.0.0"),
    .package(url: "https://github.com/furbytm/swift-cross-ui.git", from: "0.7.2"),
    .package(url: "https://github.com/wabiverse/MetaverseKit.git", from: "2.0.8"),
    .package(url: "https://github.com/swiftlang/swift-syntax", "601.0.0"..<"604.0.0"),
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.5.4"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.7.1"),
    .package(url: "https://github.com/onevcat/Rainbow.git", from: "4.0.0"),
    .package(url: "https://github.com/mxcl/Version.git", from: "2.0.0"),
  ],
  targets: [
    .target(
      name: "pxr",
      dependencies: [],
      publicHeadersPath: "include",
      cxxSettings: [
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Arch",
      dependencies: [
        /* ------------ pxr Namespace. ---------- */
        .target(name: "pxr"),
        /* ---------- Console logging. ---------- */
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Rainbow", package: "Rainbow", condition: .when(platforms: Arch.OS.noandroid.platform)),
      ],
      exclude: Arch.OS.getExcludes(for: "Arch"),
      publicHeadersPath: "include",
      cxxSettings: [
        /* ---------- Turn everything on. ---------- */
        .define("PXR_USE_NAMESPACES", to: "1"),
        .define("PXR_PYTHON_SUPPORT_ENABLED", to: "0"),
        .define("PXR_PREFER_SAFETY_OVER_SPEED", to: "1"),
        /* --------- OSL is temp disabled. --------- */
        .define("PXR_OSL_SUPPORT_ENABLED", to: "0"),
        /* --------- Standard USD defines. --------- */
        .define("MFB_PACKAGE_NAME", to: "Arch"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Arch"),
        .define("MFB_PACKAGE_MODULE", to: "Arch"),
        .define("ARCH_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("ARCH_COMPILER_MSVC", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Tf",
      dependencies: [
        .target(name: "Arch"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Tf"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Tf"),
        .define("MFB_PACKAGE_MODULE", to: "Tf"),
        .define("TF_EXPORTS", to: "1"),
        .headerSearchPath("include/Tf"),
        .headerSearchPath("include/Tf/pxrDoubleConversion"),
        .headerSearchPath("include/Tf/pxrLZ4"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Js",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Js"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Js"),
        .define("MFB_PACKAGE_MODULE", to: "Js"),
        .define("JS_EXPORTS", to: "1"),
        .headerSearchPath("include/Js"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Gf",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
      ],
      cxxSettings: [
        .headerSearchPath("include/Gf/nc"),
        .define("MFB_PACKAGE_NAME", to: "Gf"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Gf"),
        .define("MFB_PACKAGE_MODULE", to: "Gf"),
        .define("GF_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Trace",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Js"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      cxxSettings: [
        /* --------- Fix missing TBB allocator funcs. --------- */
        .define("TBB_ALLOCATOR_TRAITS_BROKEN", to: "1", .when(platforms: Arch.OS.linux.platform)),
        /* --------- Standard USD source definitions. --------- */
        .define("MFB_PACKAGE_NAME", to: "Trace"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Trace"),
        .define("MFB_PACKAGE_MODULE", to: "Trace"),
        .define("TRACE_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Vt",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Trace"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Vt"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Vt"),
        .define("MFB_PACKAGE_MODULE", to: "Vt"),
        .define("VT_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Work",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Work"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Work"),
        .define("MFB_PACKAGE_MODULE", to: "Work"),
        .define("WORK_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Pegtl",
      dependencies: [
        .target(name: "Arch")
      ],
      cxxSettings: [
        .headerSearchPath("include/Pegtl"),
        .define("MFB_PACKAGE_NAME", to: "Pegtl"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Pegtl"),
        .define("MFB_PACKAGE_MODULE", to: "Pegtl"),
        .define("PEGTL_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Plug",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Js"),
        .target(name: "Trace"),
        .target(name: "Work"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Plug"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Plug"),
        .define("MFB_PACKAGE_MODULE", to: "Plug"),
        .define("PLUG_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),
    
    .target(
      name: "Ts",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Trace"),
        .target(name: "Plug"),
        .target(name: "Vt"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Ts"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Ts"),
        .define("MFB_PACKAGE_MODULE", to: "Ts"),
        .define("TS_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Ar",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Js"),
        .target(name: "Plug"),
        .target(name: "Vt"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      resources: [
        .process("Resources"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Ar"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Ar"),
        .define("MFB_PACKAGE_MODULE", to: "Ar"),
        .define("AR_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Kind",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Plug"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Kind"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Kind"),
        .define("MFB_PACKAGE_MODULE", to: "Kind"),
        .define("KIND_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Sdf",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Plug"),
        .target(name: "Ts"),
        .target(name: "Trace"),
        .target(name: "Work"),
        .target(name: "Vt"),
        .target(name: "Ar"),
        .target(name: "Pegtl"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Sdf"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Sdf"),
        .define("MFB_PACKAGE_MODULE", to: "Sdf"),
        .define("SDF_EXPORTS", to: "1"),
        .headerSearchPath("include/Sdf"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("YY_NO_UNISTD_H", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Pcp",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "Work"),
        .target(name: "Ts"),
        .target(name: "Vt"),
        .target(name: "Ar"),
        .target(name: "Sdf"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Pcp"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Pcp"),
        .define("MFB_PACKAGE_MODULE", to: "Pcp"),
        .define("PCP_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Usd",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "Work"),
        .target(name: "Vt"),
        .target(name: "Plug"),
        .target(name: "Ts"),
        .target(name: "Gf"),
        .target(name: "Kind"),
        .target(name: "Ar"),
        .target(name: "Sdf"),
        .target(name: "Pcp"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      resources: [
        .copy("codegenTemplates"),
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Usd"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Usd"),
        .define("MFB_PACKAGE_MODULE", to: "Usd"),
        .define("USD_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Sdr",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "Vt"),
        .target(name: "Sdf"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Sdr"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Sdr"),
        .define("MFB_PACKAGE_MODULE", to: "Sdr"),
        .define("SDR_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdGeom",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "Work"),
        .target(name: "Vt"),
        .target(name: "Plug"),
        .target(name: "Gf"),
        .target(name: "Kind"),
        .target(name: "Ar"),
        .target(name: "Sdf"),
        .target(name: "Pcp"),
        .target(name: "Usd"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdGeom"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdGeom"),
        .define("MFB_PACKAGE_MODULE", to: "UsdGeom"),
        .define("USDGEOM_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdShade",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Vt"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .target(name: "Sdr"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdShade"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdShade"),
        .define("MFB_PACKAGE_MODULE", to: "UsdShade"),
        .define("USDSHADE_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdShaders",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Ar"),
        .target(name: "Sdr"),
        .target(name: "UsdShade"),
      ],
      resources: [
        .copy("shaders"),
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdShaders"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdShaders"),
        .define("MFB_PACKAGE_MODULE", to: "UsdShaders"),
        .define("USDSHADERS_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdLod",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Vt"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdLod"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdLod"),
        .define("MFB_PACKAGE_MODULE", to: "UsdLod"),
        .define("USDLOD_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),
    
    .target(
      name: "UsdLux",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Vt"),
        .target(name: "Plug"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "Sdr"),
        .target(name: "UsdGeom"),
        .target(name: "UsdShade"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdLux"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdLux"),
        .define("MFB_PACKAGE_MODULE", to: "UsdLux"),
        .define("USDLUX_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdHydra",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Ar"),
        .target(name: "Tf"),
        .target(name: "Plug"),
        .target(name: "Usd"),
        .target(name: "UsdShade"),
      ],
      resources: [
        .copy("shaders"),
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdHydra"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdHydra"),
        .define("MFB_PACKAGE_MODULE", to: "UsdHydra"),
        .define("USDHYDRA_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "SdrGlslfx",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Ar"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Hio"),
        .target(name: "Sdr"),
        .target(name: "Vt"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "SdrGlslfx"),
        .define("MFB_ALT_PACKAGE_NAME", to: "SdrGlslfx"),
        .define("MFB_PACKAGE_MODULE", to: "SdrGlslfx"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdAbc",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "Work"),
        .target(name: "Vt"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .product(name: "Alembic", package: "MetaverseKit"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("PXR_HDF5_SUPPORT_ENABLED", to: "1"),
        .define("MFB_PACKAGE_NAME", to: "UsdAbc"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdAbc"),
        .define("MFB_PACKAGE_MODULE", to: "UsdAbc"),
        .define("USDABC_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdDraco",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Vt"),
        .target(name: "Ar"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .product(name: "Draco", package: "MetaverseKit"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .headerSearchPath("include/UsdDraco"),
        .define("MFB_PACKAGE_NAME", to: "UsdDraco"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdDraco"),
        .define("MFB_PACKAGE_MODULE", to: "UsdDraco"),
        .define("USDDRACO_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdMedia",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdMedia"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdMedia"),
        .define("MFB_PACKAGE_MODULE", to: "UsdMedia"),
        .define("USDMEDIA_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdMtlx",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Vt"),
        .target(name: "Trace"),
        .target(name: "Ar"),
        .target(name: "Sdf"),
        .target(name: "Sdr"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .target(name: "UsdShade"),
        .target(name: "UsdUI"),
        .target(name: "UsdUtils"),
        .product(name: "MaterialX", package: "MetaverseKit"),
      ],
      resources: [
        .copy("libraries"),
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdMtlx"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdMtlx"),
        .define("MFB_PACKAGE_MODULE", to: "UsdMtlx"),
        .define("USDMTLX_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdPhysics",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Vt"),
        .target(name: "Trace"),
        .target(name: "Work"),
        .target(name: "Plug"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .target(name: "UsdShade"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdPhysics"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdPhysics"),
        .define("MFB_PACKAGE_MODULE", to: "UsdPhysics"),
        .define("USDPHYSICS_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdProc",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdProc"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdProc"),
        .define("MFB_PACKAGE_MODULE", to: "UsdProc"),
        .define("USDPROC_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdRender",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Vt"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .target(name: "UsdShade"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdRender"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdRender"),
        .define("MFB_PACKAGE_MODULE", to: "UsdRender"),
        .define("USDRENDER_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdRi",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Vt"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .target(name: "UsdShade"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdRi"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdRi"),
        .define("MFB_PACKAGE_MODULE", to: "UsdRi"),
        .define("USDRI_EXPORTS", to: "1"),
        .headerSearchPath("include/UsdRi"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdSkel",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Trace"),
        .target(name: "Work"),
        .target(name: "Vt"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdSkel"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdSkel"),
        .define("MFB_PACKAGE_MODULE", to: "UsdSkel"),
        .define("USDSKEL_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdUI",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdUI"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdUI"),
        .define("MFB_PACKAGE_MODULE", to: "UsdUI"),
        .define("USDUI_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdUtils",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Vt"),
        .target(name: "Work"),
        .target(name: "Trace"),
        .target(name: "Plug"),
        .target(name: "Ar"),
        .target(name: "Kind"),
        .target(name: "Pcp"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .target(name: "UsdShade"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdUtils"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdUtils"),
        .define("MFB_PACKAGE_MODULE", to: "UsdUtils"),
        .define("USDUTILS_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdVol",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "Plug"),
        .target(name: "Work"),
        .target(name: "Vt"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdVol"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdVol"),
        .define("MFB_PACKAGE_MODULE", to: "UsdVol"),
        .define("USDVOL_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),
    
    .target(
      name: "UsdProfiles",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "Plug"),
        .target(name: "Work"),
        .target(name: "Vt"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdProfiles"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdProfiles"),
        .define("MFB_PACKAGE_MODULE", to: "UsdProfiles"),
        .define("USDPROFILES_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "CameraUtil",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Gf"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "CameraUtil"),
        .define("MFB_ALT_PACKAGE_NAME", to: "CameraUtil"),
        .define("MFB_PACKAGE_MODULE", to: "CameraUtil"),
        .define("CAMERAUTIL_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Hf",
      dependencies: [
        .target(name: "Plug"),
        .target(name: "Tf"),
        .target(name: "Trace"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Hf"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Hf"),
        .define("MFB_PACKAGE_MODULE", to: "Hf"),
        .define("HF_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "PxOsd",
      dependencies: [
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Vt"),
        .product(name: "OpenSubdiv", package: "MetaverseKit"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "PxOsd"),
        .define("MFB_ALT_PACKAGE_NAME", to: "PxOsd"),
        .define("MFB_PACKAGE_MODULE", to: "PxOsd"),
        .define("PXOSD_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Hd",
      dependencies: [
        .target(name: "Plug"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "Vt"),
        .target(name: "Work"),
        .target(name: "Sdf"),
        .target(name: "Sdr"),
        .target(name: "CameraUtil"),
        .target(name: "Hf"),
        .target(name: "PxOsd"),
        .target(name: "HgiInterop"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      resources: [
        .process("Resources"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Hd"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Hd"),
        .define("MFB_PACKAGE_MODULE", to: "Hd"),
        .define("HD_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Garch",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
      ],
      exclude: Arch.OS.getExcludes(for: "Garch"),
      cxxSettings: [
        .define("PXR_GL_SUPPORT_ENABLED", .when(platforms: Arch.OS.noembeddedapple.platform)),
        .define("MFB_PACKAGE_NAME", to: "Garch"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Garch"),
        .define("MFB_PACKAGE_MODULE", to: "Garch"),
        .define("GARCH_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ],
      linkerSettings: [
        .linkedFramework("OpenGL", .when(platforms: [.macOS])),
        .linkedFramework("UIKit", .when(platforms: Arch.OS.embeddedapple.platform)),
        // Desktop GL/X11 — Linux/OpenBSD only; Android uses EGL + GLESv3 instead.
        .linkedLibrary("glut", .when(platforms: [.linux, .openbsd])),
        .linkedLibrary("GL", .when(platforms: [.linux, .openbsd])),
        .linkedLibrary("GLU", .when(platforms: [.linux, .openbsd])),
        .linkedLibrary("m", .when(platforms: [.linux, .openbsd])),
        .linkedLibrary("X11", .when(platforms: [.linux, .openbsd])),
        .linkedLibrary("Xt", .when(platforms: [.linux, .openbsd])),
        // Android GL context/ES runtime + Vulkan (API 28+).
        .linkedLibrary("EGL", .when(platforms: [.android])),
        .linkedLibrary("GLESv3", .when(platforms: [.android])),
        .linkedLibrary("vulkan", .when(platforms: [.android])),
        .linkedLibrary("opengl32", .when(platforms: Arch.OS.windows.platform)),
      ]
    ),

    .target(
      name: "Hgi",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Plug"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Trace"),
      ],
      cxxSettings: [
        .define("PXR_METAL_SUPPORT_ENABLED", to: "1", .when(platforms: Arch.OS.apple.platform)),
        .define("PXR_METAL_SUPPORT_ENABLED", to: "0", .when(platforms: Arch.OS.linwin.platform)),
        .define("PXR_VULKAN_SUPPORT_ENABLED", to: "0"),
        .define("PXR_GL_SUPPORT_ENABLED", .when(platforms: Arch.OS.noembeddedapple.platform)),
        .define("MFB_PACKAGE_NAME", to: "Hgi"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Hgi"),
        .define("MFB_PACKAGE_MODULE", to: "Hgi"),
        .define("HGI_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "HgiMetal",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "Hgi"),
        .target(name: "Vt"),
        .target(name: "Hf")
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "HgiMetal"),
        .define("MFB_ALT_PACKAGE_NAME", to: "HgiMetal"),
        .define("MFB_PACKAGE_MODULE", to: "HgiMetal"),
        .define("HGIMETAL_EXPORTS", to: "1"),
        .define("PXR_METAL_SUPPORT_ENABLED", to: "1", .when(platforms: Arch.OS.apple.platform)),
        .define("PXR_METAL_SUPPORT_ENABLED", to: "0", .when(platforms: Arch.OS.linwin.platform)),
        .define("PXR_VULKAN_SUPPORT_ENABLED", to: "0"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ],
      linkerSettings: [
        .linkedFramework("Foundation", .when(platforms: Arch.OS.apple.platform)),
        .linkedFramework("Metal", .when(platforms: Arch.OS.apple.platform)),
        .linkedFramework("AppKit", .when(platforms: [.macOS])),
        .linkedFramework("UIKit", .when(platforms: Arch.OS.embeddedapple.platform)),
      ]
    ),

    .target(
      name: "HgiGL",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "Garch"),
        .target(name: "Hgi"),
        .target(name: "Vt"),
        .target(name: "Hf")
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "HgiGL"),
        .define("MFB_ALT_PACKAGE_NAME", to: "HgiGL"),
        .define("MFB_PACKAGE_MODULE", to: "HgiGL"),
        .define("HGIGL_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "HgiInterop",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Vt"),
        .target(name: "Gf"),
        .target(name: "Garch"),
        .target(name: "Hgi"),
        .target(name: "HgiMetal", condition: .when(platforms: Arch.OS.apple.platform)),
        // .target(name: "HgiVulkan", condition: .when(platforms: Arch.OS.linux.platform)),
        .target(name: "HgiGL"),
      ],
      exclude: Arch.OS.getExcludes(for: "HgiInterop"),
      cxxSettings: [
        .define("PXR_METAL_SUPPORT_ENABLED", to: "1", .when(platforms: Arch.OS.apple.platform)),
        .define("PXR_METAL_SUPPORT_ENABLED", to: "0", .when(platforms: Arch.OS.linwin.platform)),
        .define("PXR_VULKAN_SUPPORT_ENABLED", to: "0"),
        .define("PXR_GL_SUPPORT_ENABLED", .when(platforms: Arch.OS.noembeddedapple.platform)),
        .define("MFB_PACKAGE_NAME", to: "HgiInterop"),
        .define("MFB_ALT_PACKAGE_NAME", to: "HgiInterop"),
        .define("MFB_PACKAGE_MODULE", to: "HgiInterop"),
        .define("HGIINTEROP_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ],
      linkerSettings: [
        .linkedFramework("Foundation", .when(platforms: Arch.OS.apple.platform)),
        .linkedFramework("CoreVideo", .when(platforms: Arch.OS.apple.platform))
      ]
    ),

    .target(
      name: "Hio",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Js"),
        .target(name: "Plug"),
        .target(name: "Tf"),
        .target(name: "Vt"),
        .target(name: "Trace"),
        .target(name: "Ar"),
        .target(name: "Hf"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Hio"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Hio"),
        .define("MFB_PACKAGE_MODULE", to: "Hio"),
        .define("HIO_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),
    
    .target(
      name: "HioAVIF",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Hio"),
        .target(name: "Plug"),
      ],
      exclude: [
        "compliance.cc"
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .headerSearchPath("include/HioAVIF"),
        .headerSearchPath("include/HioAVIF/aom_mem"),
        .define("MFB_PACKAGE_NAME", to: "HioAVIF"),
        .define("MFB_ALT_PACKAGE_NAME", to: "HioAVIF"),
        .define("MFB_PACKAGE_MODULE", to: "HioAVIF"),
        .define("HIOAVIF_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "HioImageIO",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Ar"),
        .target(name: "Plug"),
        .target(name: "Gf"),
        .target(name: "Hio")
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "HioImageIO"),
        .define("MFB_ALT_PACKAGE_NAME", to: "HioImageIO"),
        .define("MFB_PACKAGE_MODULE", to: "HioImageIO"),
        .define("HIOIMAGEIO_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ],
      linkerSettings: [
        .linkedFramework("ImageIO", .when(platforms: Arch.OS.apple.platform)),
      ]
    ),
    
    .target(
      name: "HioOIIO",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Plug"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Ar"),
        .target(name: "Hio"),
        .product(name: "OpenImageIO", package: "MetaverseKit"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "HioOIIO"),
        .define("MFB_ALT_PACKAGE_NAME", to: "HioOIIO"),
        .define("MFB_PACKAGE_MODULE", to: "HioOIIO"),
        .define("HIOOIIO_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),
    
    .target(
      name: "HioOpenEXR",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Ar"),
        .target(name: "Gf"),
        .target(name: "Hio"),
      ],
      sources: [
        "openexr-c.c",
        "OpenEXRImage.cpp"
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "HioOpenEXR"),
        .define("MFB_ALT_PACKAGE_NAME", to: "HioOpenEXR"),
        .define("MFB_PACKAGE_MODULE", to: "HioOpenEXR"),
        .define("HIOOPENEXR_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows]))
      ]
    ),
    
    .target(
      name: "HioOpenVDB",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Plug"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "Ar"),
        .target(name: "Hf"),
        .target(name: "Hio"),
        .product(name: "OpenVDB", package: "MetaverseKit"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("OPENVDB_ALL_TYPES_INSTANTIATED", to: "1"),
        .define("PXR_OPENVDB_SUPPORT_ENABLED", to: "1"),
        .define("MFB_PACKAGE_NAME", to: "HioOpenVDB"),
        .define("MFB_ALT_PACKAGE_NAME", to: "HioOpenVDB"),
        .define("MFB_PACKAGE_MODULE", to: "HioOpenVDB"),
        .define("HIOOPENVDB_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),
    
    .target(
      name: "Glf",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Plug"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Trace"),
        .target(name: "Ar"),
        .target(name: "Sdf"),
        .target(name: "Garch"),
        .target(name: "Hf"),
        .target(name: "Hio"),
      ],
      resources: [
        .copy("shaders"),
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Glf"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Glf"),
        .define("MFB_PACKAGE_MODULE", to: "Glf"),
        .define("GLF_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ],
      linkerSettings: [
        .linkedFramework("OpenGL", .when(platforms: [.macOS])),
      ]
    ),

    .target(
      name: "GeomUtil",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Vt"),
        .target(name: "PxOsd"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "GeomUtil"),
        .define("MFB_ALT_PACKAGE_NAME", to: "GeomUtil"),
        .define("MFB_PACKAGE_MODULE", to: "GeomUtil"),
        .define("GEOMUTIL_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "HdSi",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Plug"),
        .target(name: "Trace"),
        .target(name: "Vt"),
        .target(name: "Work"),
        .target(name: "Sdf"),
        .target(name: "CameraUtil"),
        .target(name: "GeomUtil"),
        .target(name: "Hf"),
        .target(name: "Hd"),
        .target(name: "PxOsd"),
        .target(name: "UsdShade"),
        .target(name: "UsdVol"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "HdSi"),
        .define("MFB_ALT_PACKAGE_NAME", to: "HdSi"),
        .define("MFB_PACKAGE_MODULE", to: "HdSi"),
        .define("HDSI_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "HdMtlx",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "Vt"),
        .target(name: "Gf"),
        .target(name: "Hd"),
        .target(name: "Sdf"),
        .target(name: "Sdr"),
        .target(name: "UsdMtlx"),
        .product(name: "MaterialX", package: "MetaverseKit"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "HdMtlx"),
        .define("MFB_ALT_PACKAGE_NAME", to: "HdMtlx"),
        .define("MFB_PACKAGE_MODULE", to: "HdMtlx"),
        .define("HDMTLX_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "HdSt",
      dependencies: [
        .target(name: "Hio"),
        .target(name: "Garch"),
        .target(name: "Glf"),
        .target(name: "Hd"),
        .target(name: "HdSi"),
        .target(name: "HgiGL"),
        .target(name: "HgiInterop"),
        .target(name: "Sdr"),
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "HdMtlx"),
        .product(name: "Ptex", package: "MetaverseKit"),
        .product(name: "MaterialX", package: "MetaverseKit"),
        .product(name: "OpenSubdiv", package: "MetaverseKit"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      resources: [
        .copy("shaders"),
        .copy("textures"),
        .process("Resources")
      ],
      cxxSettings: [
        .define("PXR_PTEX_SUPPORT_ENABLED", to: "1"),
        .define("PXR_MATERIALX_SUPPORT_ENABLED", to: "1"),
        .define("PXR_METAL_SUPPORT_ENABLED", to: "1", .when(platforms: Arch.OS.apple.platform)),
        .define("PXR_METAL_SUPPORT_ENABLED", to: "0", .when(platforms: Arch.OS.linwin.platform)),
        .define("PXR_VULKAN_SUPPORT_ENABLED", to: "0"),
        .define("MFB_PACKAGE_NAME", to: "HdSt"),
        .define("MFB_ALT_PACKAGE_NAME", to: "HdSt"),
        .define("MFB_PACKAGE_MODULE", to: "HdSt"),
        .define("HDST_EXPORTS", to: "1"),
        .define("PXR_MATERIALX_SUPPORT_ENABLED", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "HdStorm",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Plug"),
        .target(name: "Trace"),
        .target(name: "Vt"),
        .target(name: "Work"),
        .target(name: "Hd"),
        .target(name: "HdSt"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "HdStorm"),
        .define("MFB_ALT_PACKAGE_NAME", to: "HdStorm"),
        .define("MFB_PACKAGE_MODULE", to: "HdStorm"),
        .define("HDSTORM_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Hdx",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Vt"),
        .target(name: "Plug"),
        .target(name: "Work"),
        .target(name: "Sdf"),
        .target(name: "Garch"),
        .target(name: "Glf"),
        .target(name: "PxOsd"),
        .target(name: "Hd"),
        .target(name: "HdSt"),
        .target(name: "Hgi"),
        .target(name: "HgiInterop"),
        .target(name: "CameraUtil"),
        .product(name: "OpenColorIO", package: "MetaverseKit"),
      ],
      resources: [
        .copy("shaders"),
        .copy("textures"),
        .process("Resources")
      ],
      cxxSettings: [
        .define("PXR_OCIO_PLUGIN_ENABLED", to: "1"),
        .define("MFB_PACKAGE_NAME", to: "Hdx"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Hdx"),
        .define("MFB_PACKAGE_MODULE", to: "Hdx"),
        .define("HDX_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),
    
    .target(
      name: "HdGp",
      dependencies: [
        .target(name: "Hd"),
        .target(name: "Hf"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "HdGp"),
        .define("MFB_ALT_PACKAGE_NAME", to: "HdGp"),
        .define("MFB_PACKAGE_MODULE", to: "HdGp"),
        .define("HDGP_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "HdAr",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Hd"),
        .target(name: "Ar"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "HdAr"),
        .define("MFB_ALT_PACKAGE_NAME", to: "HdAr"),
        .define("MFB_PACKAGE_MODULE", to: "HdAr"),
        .define("HDAR_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdImaging",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Vt"),
        .target(name: "Plug"),
        .target(name: "Trace"),
        .target(name: "Work"),
        .target(name: "GeomUtil"),
        .target(name: "Hd"),
        .target(name: "HdAr"),
        .target(name: "HdSi"),
        .target(name: "Hio"),
        .target(name: "PxOsd"),
        .target(name: "Ar"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .target(name: "UsdLux"),
        .target(name: "UsdRender"),
        .target(name: "UsdShade"),
        .target(name: "UsdSkel"),
        .target(name: "UsdVol"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdImaging"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdImaging"),
        .define("MFB_PACKAGE_MODULE", to: "UsdImaging"),
        .define("USDIMAGING_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdImagingGL",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Vt"),
        .target(name: "Plug"),
        .target(name: "Trace"),
        .target(name: "Work"),
        .target(name: "Hio"),
        .target(name: "Garch"),
        .target(name: "Glf"),
        .target(name: "Hd"),
        .target(name: "HdSi"),
        .target(name: "Hdx"),
        .target(name: "Hgi"),
        .target(name: "PxOsd"),
        .target(name: "Ar"),
        .target(name: "Sdf"),
        .target(name: "Sdr"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .target(name: "UsdHydra"),
        .target(name: "UsdShade"),
        .target(name: "UsdImaging"),
        .target(name: "UsdExecImaging"),
      ],
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdImagingGL"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdImagingGL"),
        .define("MFB_PACKAGE_MODULE", to: "UsdImagingGL"),
        .define("USDIMAGINGGL_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Vdf",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Gf"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "Vt"),
        .target(name: "Work"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      cxxSettings: [
        .headerSearchPath("include/Vdf"),
        .define("MFB_PACKAGE_NAME", to: "Vdf"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Vdf"),
        .define("MFB_PACKAGE_MODULE", to: "Vdf"),
        .define("VDF_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Esf",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Sdf"),
        .target(name: "Tf"),
        .target(name: "Vt"),
        .target(name: "Usd"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Esf"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Esf"),
        .define("MFB_PACKAGE_MODULE", to: "Esf"),
        .define("ESF_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Ef",
      dependencies: [
        .target(name: "Vdf"),
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "Usd"),
        .target(name: "Work"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Ef"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Ef"),
        .define("MFB_PACKAGE_MODULE", to: "Ef"),
        .define("EF_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "EsfUsd",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Esf"),
        .target(name: "Tf"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "EsfUsd"),
        .define("MFB_ALT_PACKAGE_NAME", to: "EsfUsd"),
        .define("MFB_PACKAGE_MODULE", to: "EsfUsd"),
        .define("ESFUSD_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "Exec",
      dependencies: [
        .target(name: "Ef"),
        .target(name: "Esf"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "Ts"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "Vdf"),
        .target(name: "Vt"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "Exec"),
        .define("MFB_ALT_PACKAGE_NAME", to: "Exec"),
        .define("MFB_PACKAGE_MODULE", to: "Exec"),
        .define("EXEC_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "ExecUsd",
      dependencies: [
        .target(name: "Esf"),
        .target(name: "EsfUsd"),
        .target(name: "Exec"),
        .target(name: "Tf"),
        .target(name: "Trace"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .product(name: "MetaTBB", package: "MetaverseKit"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "ExecUsd"),
        .define("MFB_ALT_PACKAGE_NAME", to: "ExecUsd"),
        .define("MFB_PACKAGE_MODULE", to: "ExecUsd"),
        .define("EXECUSD_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "ExecGeom",
      dependencies: [
        .target(name: "Gf"),
        .target(name: "Tf"),
        .target(name: "ExecUsd"),
        .target(name: "UsdGeom"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "ExecGeom"),
        .define("MFB_ALT_PACKAGE_NAME", to: "ExecGeom"),
        .define("MFB_PACKAGE_MODULE", to: "ExecGeom"),
        .define("EXECGEOM_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "ExecIr",
      dependencies: [
        .target(name: "Gf"),
        .target(name: "Tf"),
        .target(name: "ExecUsd"),
        .target(name: "ExecGeom")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "ExecIr"),
        .define("MFB_ALT_PACKAGE_NAME", to: "ExecIr"),
        .define("MFB_PACKAGE_MODULE", to: "ExecIr"),
        .define("EXECIR_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdValidation",
      dependencies: [
        .target(name: "Gf"),
        .target(name: "Plug"),
        .target(name: "Sdf"),
        .target(name: "Tf"),
        .target(name: "Usd"),
        .target(name: "Work"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdValidation"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdValidation"),
        .define("MFB_PACKAGE_MODULE", to: "UsdValidation"),
        .define("USDVALIDATION_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdGeomValidators",
      dependencies: [
        .target(name: "Plug"),
        .target(name: "Sdf"),
        .target(name: "Tf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .target(name: "UsdValidation"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdGeomValidators"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdGeomValidators"),
        .define("MFB_PACKAGE_MODULE", to: "UsdGeomValidators"),
        .define("USDGEOMVALIDATORS_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdPhysicsValidators",
      dependencies: [
        .target(name: "Plug"),
        .target(name: "Tf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .target(name: "UsdPhysics"),
        .target(name: "UsdValidation"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdPhysicsValidators"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdPhysicsValidators"),
        .define("MFB_PACKAGE_MODULE", to: "UsdPhysicsValidators"),
        .define("USDPHYSICSVALIDATORS_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdShadeValidators",
      dependencies: [
        .target(name: "Plug"),
        .target(name: "Sdf"),
        .target(name: "Sdr"),
        .target(name: "Tf"),
        .target(name: "Usd"),
        .target(name: "UsdShade"),
        .target(name: "UsdValidation"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdShadeValidators"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdShadeValidators"),
        .define("MFB_PACKAGE_MODULE", to: "UsdShadeValidators"),
        .define("USDSHADEVALIDATORS_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdSkelValidators",
      dependencies: [
        .target(name: "Plug"),
        .target(name: "Tf"),
        .target(name: "Usd"),
        .target(name: "UsdSkel"),
        .target(name: "UsdValidation"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdSkelValidators"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdSkelValidators"),
        .define("MFB_PACKAGE_MODULE", to: "UsdSkelValidators"),
        .define("USDSKELVALIDATORS_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdUtilsValidators",
      dependencies: [
        .target(name: "Plug"),
        .target(name: "Tf"),
        .target(name: "Usd"),
        .target(name: "UsdUtils"),
        .target(name: "UsdValidation"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdUtilsValidators"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdUtilsValidators"),
        .define("MFB_PACKAGE_MODULE", to: "UsdUtilsValidators"),
        .define("USDUTILSVALIDATORS_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),
    
    .target(
      name: "UsdLodValidators",
      dependencies: [
        .target(name: "Tf"),
        .target(name: "Plug"),
        .target(name: "Vt"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "UsdLod"),
        .target(name: "UsdValidation"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdLodValidators"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdLodValidators"),
        .define("MFB_PACKAGE_MODULE", to: "UsdLodValidators"),
        .define("USDLODVALIDATORS_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),
    
    .target(
      name: "UsdLuxValidators",
      dependencies: [
        .target(name: "Plug"),
        .target(name: "Tf"),
        .target(name: "Usd"),
        .target(name: "UsdLux"),
        .target(name: "UsdValidation"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdLuxValidators"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdLuxValidators"),
        .define("MFB_PACKAGE_MODULE", to: "UsdLuxValidators"),
        .define("USDLUXVALIDATORS_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),

    .target(
      name: "UsdExecImaging",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Vt"),
        .target(name: "Plug"),
        .target(name: "Trace"),
        .target(name: "Work"),
        .target(name: "Hio"),
        .target(name: "Garch"),
        .target(name: "Glf"),
        .target(name: "Hd"),
        .target(name: "HdSi"),
        .target(name: "Hdx"),
        .target(name: "Hgi"),
        .target(name: "PxOsd"),
        .target(name: "Ar"),
        .target(name: "Sdf"),
        .target(name: "Sdr"),
        .target(name: "Ts"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .target(name: "UsdHydra"),
        .target(name: "UsdShade"),
        .target(name: "Vdf"),
        .target(name: "Esf"),
        .target(name: "Ef"),
        .target(name: "EsfUsd"),
        .target(name: "Exec"),
        .target(name: "ExecUsd"),
        .target(name: "ExecGeom"),
        .target(name: "ExecIr"),
        .target(name: "UsdImaging"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdExecImaging"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdExecImaging"),
        .define("MFB_PACKAGE_MODULE", to: "UsdExecImaging"),
        .define("USDEXECIMAGING_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),
    
    .target(
      name: "UsdIRImaging",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Vt"),
        .target(name: "Plug"),
        .target(name: "Trace"),
        .target(name: "Work"),
        .target(name: "Hio"),
        .target(name: "Garch"),
        .target(name: "Glf"),
        .target(name: "Hd"),
        .target(name: "HdSi"),
        .target(name: "Hdx"),
        .target(name: "Hgi"),
        .target(name: "PxOsd"),
        .target(name: "Ar"),
        .target(name: "Sdf"),
        .target(name: "Sdr"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .target(name: "UsdHydra"),
        .target(name: "UsdShade"),
        .target(name: "UsdImaging"),
        .target(name: "ExecIr"),
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdIRImaging"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdIRImaging"),
        .define("MFB_PACKAGE_MODULE", to: "UsdIRImaging"),
        .define("USDIRIMAGING_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),
    
    .target(
      name: "UsdSkelImaging",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Gf"),
        .target(name: "Vt"),
        .target(name: "Plug"),
        .target(name: "Trace"),
        .target(name: "Work"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .target(name: "UsdSkel"),
        .target(name: "UsdImaging"),
        .target(name: "Hd"),
        .target(name: "PxOsd"),
      ],
      resources: [
        .copy("shaders"),
        .process("Resources")
      ],
      cxxSettings: [
        .define("MFB_PACKAGE_NAME", to: "UsdSkelImaging"),
        .define("MFB_ALT_PACKAGE_NAME", to: "UsdSkelImaging"),
        .define("MFB_PACKAGE_MODULE", to: "UsdSkelImaging"),
        .define("USDSKELIMAGING_EXPORTS", to: "1"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),
    
    .target(
      name: "HydraKit",
      dependencies: [
        .target(name: "OpenUSDKit"),
        .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
        .product(name: "AppKitBackend", package: "swift-cross-ui", condition: .when(platforms: [.macOS])),
        .product(name: "UIKitBackend", package: "swift-cross-ui", condition: .when(platforms: [.iOS, .visionOS, .tvOS, .watchOS])),
        .product(name: "GtkBackend", package: "swift-cross-ui", condition: .when(platforms: [.linux])),
      ] + Arch.OS.winUIBackend + Arch.OS.androidBackend,
      resources: [
        .process("Resources")
      ],
      cxxSettings: [
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
        .define("_LIBCPP_ABI_NO_COMPRESSED_PAIR_PADDING"),
      ],
      swiftSettings: [
        .interoperabilityMode(.Cxx),
      ]
    ),
    
    .executableTarget(
      name: "UsdView",
      dependencies: [
        .target(name: "OpenUSDKit"),
        .target(name: "HydraKit"),
      ],
      cxxSettings: [
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
        .define("_LIBCPP_ABI_NO_COMPRESSED_PAIR_PADDING"),
      ],
      swiftSettings: [
        .interoperabilityMode(.Cxx),
      ]
    ),

    .executableTarget(
       name: "ousd",
       dependencies: [
         .product(name: "Version", package: "Version"),
         .product(name: "ArgumentParser", package: "swift-argument-parser"),
         .product(name: "Logging", package: "swift-log"),
         .product(name: "Rainbow", package: "Rainbow", condition: .when(platforms: Arch.OS.noandroid.platform)),
       ],
       resources: [
         // usd source files that need modifications to work with swift are maintained out of these
         // directories, if a usd source file from upstream pixar is matching any of the respective
         // target/filename(.h|.cpp) patterns within any of these resource directories, the contents
         // of each of the matching upstream pixar files will have their contents replaced with each
         // of the respective source code files found in any of these directories.
         .copy("Resources")
       ],
       cxxSettings: [
         .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
         .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
         .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
         .define("NOMINMAX", .when(platforms: [.windows])),
       ],
       swiftSettings: [
         // already enabled in Swift 6+.
         // .enableUpcomingFeature("BareSlashRegexLiterals"),
       ]
     ),

     .plugin(
       name: "OpenUSDPlugin",
       capability: .command(
         intent: .custom(verb: "openusd", description: """
           Update the version of USD in the current package,
           this will fetch the latest version of USD from the
           Pixar USD repository and update this packages source
           code to the latest version.
           """),
         permissions: [
           .allowNetworkConnections(
             scope: .all(),
             reason: "Updating USD requires network access."
           ),
           .writeToPackageDirectory(
             reason: "Updating USD requires write access."
           ),
         ]
       ),
       dependencies: [
         .target(name: "ousd")
       ]
     ),

    .plugin(
      name: "UsdGenSchemaPlugin",
      capability: .command(
        intent: .custom(verb: "genschema", description: """
          Customize and extend the layers of specific named API atop
          the underlying scene graph with schema definitions defined
          by prims, their properties, and (optionally) their default
          or fallback values.

          The schema definition files are written in a simple, human
          readable, text-based markup language from the (.usda) file
          format. The files are then processed with this plugin tool
          to generate their corresponding C++, Python, and Swift API
          code.

          The generated C++, Python, and Swift code are then sent to
          the compiler to generate their corresponding API code, and
          made available to the USD runtime. Where it can be used to
          bring the schema definition to life, and make it available
          to the end user for use in their own applications, plugins
          and tools.
          """),
        permissions: [
          .allowNetworkConnections(
            scope: .all(),
            reason: "Pixar.Ar may require network access to load assets."
          ),
          .writeToPackageDirectory(
            reason: "Generation of schema code requires write access."
          ),
        ]
      )
    ),

    .macro(
      name: "PixarMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),

    // .target(
    //   name: "rust-usd",
    //   dependencies: [
    //     .product(name: "Ptex", package: "MetaverseKit"),
    //     .target(name: "pxr"),
    //   ],
    //   swiftSettings: [
    //     .interoperabilityMode(.Cxx),
    //   ]
    // ),

    .target(
      name: "USDOverlays",
      dependencies: [
        .target(name: "Arch"),
        .target(name: "Tf"),
        .target(name: "Plug"),
        .target(name: "Vt"),
        .target(name: "Sdf"),
        .target(name: "Usd"),
        .target(name: "UsdGeom"),
        .target(name: "UsdLux"),
        .target(name: "UsdShade"),
        .target(name: "HgiGL"),
        .target(name: "HgiMetal", condition: .when(platforms: Arch.OS.apple.platform))
      ],
      exclude: Arch.OS.getExcludes(for: "USDOverlays"),
      cxxSettings: [
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
      ]
    ),
    
    .target(
      name: "OpenUSDKit",
      dependencies: Arch.OS.getOpenUSDTargets(),
      cxxSettings: [
        // enable to debug swift retain/release calls.
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
        .define("_LIBCPP_ABI_NO_COMPRESSED_PAIR_PADDING"),
      ],
      swiftSettings: [
        .define("DEBUG_PIXAR_BUNDLE"),
        .interoperabilityMode(.Cxx),
      ]
    ),

    .executableTarget(
      name: "Examples",
      dependencies: [
        .target(name: "OpenUSDKit"),
      ],
      cxxSettings: [
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
        .define("_LIBCPP_ABI_NO_COMPRESSED_PAIR_PADDING"),
      ],
      swiftSettings: [
        .interoperabilityMode(.Cxx),
      ]
    ),

    .testTarget(
      name: "OpenUSDKitTests",
      dependencies: [
        .target(name: "OpenUSDKit"),
      ],
      cxxSettings: [
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("NOMINMAX", .when(platforms: [.windows])),
        .define("_LIBCPP_ABI_NO_COMPRESSED_PAIR_PADDING"),
      ],
      swiftSettings: [
        .interoperabilityMode(.Cxx),
      ]
    ),
  ],
  cxxLanguageStandard: .gnucxx17
)

/* --- xxx --- */

/** ------------------------------------------------
 * Just to tidy up the package configuration above,
 * we define some helper functions and types below.
 * ------------------------------------------------ */
enum Arch
{
  /** OS platforms, grouped by family. */
  enum OS
  {
    /// apple devices (macOS, visionOS, iOS, etc).
    case apple
    /// linux distros (ubuntu, centos, etc).
    case linux
    /// microsoft windows.
    case windows
    /// web (wasm).
    case web
    /// everything not windows (apple + linux).
    case nix
    /// everything not linux (apple + windows).
    case applewindows
    /// everything not apple (linux + windows).
    case linwin
    /// only embedded apple devices.
    case embeddedapple
    /// everything not embedded apple devices.
    case noembeddedapple
    /// android devices (Google Pixel, etc).
    case android
    /// everything not android devices.
    case noandroid

    public var platform: [Platform]
    {
      switch self
      {
        case .apple: [.macOS, .iOS, .visionOS, .tvOS, .watchOS]
        case .linux: [.linux, .android, .openbsd]
        case .windows: [.windows]
        case .web: [.wasi]
        case .nix: [.macOS, .iOS, .visionOS, .tvOS, .watchOS, .linux, .android, .openbsd]
        case .applewindows: [.macOS, .iOS, .visionOS, .tvOS, .watchOS, .windows]
        case .linwin: [.linux, .android, .openbsd, .windows]
        case .embeddedapple: [.iOS, .visionOS, .tvOS, .watchOS]
        case .noembeddedapple: [.macOS, .linux, .android, .openbsd, .windows]
        case .android: [.android]
        case .noandroid: [.macOS, .iOS, .visionOS, .tvOS, .watchOS, .linux, .openbsd, .windows]
      }
    }

    public static var androidBackend: [Target.Dependency]
    {
      if ProcessInfo.processInfo.environment["SWIFTUSD_ANDROID_SUPPORT_ENABLED"] == "1" {
        return [.product(name: "AndroidBackend", package: "swift-cross-ui", condition: .when(platforms: [.android]))]
      } else {
        return []
      }
    }
    
    /// because the winui backend is finicky on other platforms.
    public static var winUIBackend: [Target.Dependency]
    {
      #if os(Windows)
        [
          .product(name: "WinUIBackend", package: "swift-cross-ui", condition: .when(platforms: [.windows]))
        ]
      #else
        []
      #endif
    }
    
    // use apple's precompiled binaries on darwin platforms,
    // build from source elsewhere or if SWIFTUSD_BUILD_FROM_SOURCE=1
    public static func getOpenUSDTargets() -> [Target.Dependency]
    {
      let isOnAndroid = ProcessInfo.processInfo.environment["SWIFTUSD_ANDROID_SUPPORT_ENABLED"] == "1"
      
      #if os(macOS)
        let usePrecompiledOpenUSD = ProcessInfo.processInfo.environment["SWIFTUSD_BUILD_FROM_SOURCE"] != "1"
      #else
        // precompiled binaries aren't yet supported on
        // Linux, Android, Windows, or WebAssembly.
        let usePrecompiledOpenUSD = false
      #endif
      
      if isOnAndroid || !usePrecompiledOpenUSD {
        FileHandle.standardError.write("Building OpenUSD from source\n".data(using: .utf8)!)
        return [
          // ---------- base. ------
          .target(name: "Arch"),
          .target(name: "Tf"),
          .target(name: "Js"),
          .target(name: "Gf"),
          .target(name: "Trace"),
          .target(name: "Vt"),
          .target(name: "Work"),
          .target(name: "Pegtl"),
          .target(name: "Plug"),
          .target(name: "Ts"),
          // ----------- usd. ------
          .target(name: "Ar"),
          .target(name: "Kind"),
          .target(name: "Sdf"),
          .target(name: "Pcp"),
          .target(name: "Usd"),
          .target(name: "Sdr"),
          .target(name: "SdrGlslfx"),
          // .target(name: "SdrOsl"),
          .target(name: "UsdGeom"),
          .target(name: "UsdShade"),
          .target(name: "UsdLod"),
          .target(name: "UsdLux"),
          .target(name: "UsdHydra"),
          .target(name: "UsdAbc"),
          .target(name: "UsdDraco"),
          .target(name: "UsdMedia"),
          .target(name: "UsdMtlx"),
          .target(name: "UsdPhysics"),
          .target(name: "UsdProc"),
          .target(name: "UsdProfiles"),
          .target(name: "UsdRender"),
          .target(name: "UsdRi"),
          .target(name: "UsdSkel"),
          .target(name: "UsdUI"),
          .target(name: "UsdUtils"),
          .target(name: "UsdVol"),
          // ------- imaging. ------
          .target(name: "CameraUtil"),
          .target(name: "Garch"),
          .target(name: "GeomUtil"),
          .target(name: "Glf"),
          .target(name: "Hf"),
          .target(name: "Hd"),
          .target(name: "HdAr"),
          .target(name: "HdMtlx"),
          .target(name: "HdSi"),
          .target(name: "HdSt"),
          .target(name: "HdStorm"),
          .target(name: "Hdx"),
          .target(name: "HdGp"),
          .target(name: "Hgi"),
          .target(name: "HgiMetal", condition: .when(platforms: Arch.OS.apple.platform)),
          // .target(name: "HgiVulkan", condition: .when(platforms: Arch.OS.linux.platform)),
          .target(name: "HgiGL"),
          .target(name: "HgiInterop"),
          .target(name: "Hio"),
          .target(name: "HioAVIF"),
          .target(name: "HioImageIO", condition: .when(platforms: Arch.OS.apple.platform)),
          .target(name: "HioOIIO"),
          .target(name: "HioOpenEXR"),
          // Hio's OpenVDB plugin is disabled on all platforms for now,
          // since the swift compiler complains that openvdb is imported in
          // the openvdb::v12_0::tools namespace, which is not allowed with
          // clang modules.
          // todo(furbytm): fix openvdb's nested imports in MetaverseKit.
          // .target(name: "HioOpenVDB"),
          .target(name: "PxOsd"),
          // --- usd imaging. ------
          .target(name: "UsdShaders"),
          .target(name: "UsdImaging"),
          .target(name: "UsdImagingGL"),
          .target(name: "UsdIRImaging"),
          .target(name: "UsdExecImaging"),
          .target(name: "UsdSkelImaging"),
          // ----------- exec. ------
          .target(name: "Vdf"),
          .target(name: "Esf"),
          .target(name: "Ef"),
          .target(name: "EsfUsd"),
          .target(name: "Exec"),
          .target(name: "ExecUsd"),
          .target(name: "ExecGeom"),
          .target(name: "ExecIr"),
          // --- usd validation. ------
          .target(name: "UsdValidation"),
          .target(name: "UsdGeomValidators"),
          .target(name: "UsdPhysicsValidators"),
          .target(name: "UsdShadeValidators"),
          .target(name: "UsdSkelValidators"),
          .target(name: "UsdUtilsValidators"),
          .target(name: "UsdLodValidators"),
          .target(name: "UsdLuxValidators"),
          // -------- macros. ------
          .target(name: "PixarMacros"),
          // -----------------------
          .target(name: "USDOverlays"),
        ]
      } else {
        FileHandle.standardError.write("Using precompiled OpenUSD libraries from apple/SwiftUsd\n".data(using: .utf8)!)
        return [
          .product(name: "OpenUSD", package: "SwiftUsd", condition: .when(platforms: Arch.OS.apple.platform)),
          .product(name: "Logging", package: "swift-log"),
          .product(name: "Rainbow", package: "Rainbow", condition: .when(platforms: Arch.OS.noandroid.platform)),
          .target(name: "PixarMacros"),
        ]
      }
    }
    
    public static func getExcludes(for target: String) -> [String]
    {
      switch target {
        case "Arch":
          #if !os(macOS)
            return [
              "darwin.mm",
            ]
          #else
            return []
          #endif
        case "Garch":
          #if !os(macOS)
            return [
              "glPlatformContextDarwin.mm",
              "glPlatformDebugWindowDarwin.mm",
            ]
          #else
            return []
          #endif
        case "HgiInterop":
          #if !os(macOS)
            return [
              "metal.mm",
              "hgiInterop.mm",
            ]
          #else
            return []
          #endif
        case "USDOverlays":
          #if !os(macOS)
            return [
              "HgiMetalOverlay.mm",
            ]
          #else
            return []
          #endif
        default:
          return []
      }
    }
  }
}
