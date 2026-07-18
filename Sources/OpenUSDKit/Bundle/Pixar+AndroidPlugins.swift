/* ----------------------------------------------------------------
 * :: :  O  P  E  N  U  S  D  :                                  ::
 * ----------------------------------------------------------------
 * Licensed under the terms set forth in the LICENSE.txt file, this
 * file is available at https://openusd.org/license.
 *
 *                   Copyright (C) 2016 Pixar. All Rights Reserved.
 *                              Copyright (C) 2024 Wabi Foundation.
 * ----------------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ---------------------------------------------------------------- */

#if os(Android)

  import CxxStdlib
  import Foundation
  import Plug

  /**
   * Android-specific plugin registration (note: I hate this, clean this up once
   * swift bundler supports the bundling of resources on Android).
   *
   * On Android the `plugInfo.json` files that ship alongside the `.so`
   * in the build output are not bundled into the APK.  This extension
   * embeds every `plugInfo.json` verbatim as Swift string literals and
   * writes them to the app's files directory on first use, then calls
   * ``PlugRegistry.RegisterPlugins`` so the rest of the USD machinery
   * can find all its types.
   *
   * Call order (guaranteed by ``UsdView.init()``)
   * 1. Set ``Pixar.Bundler.androidFilesDir`` before calling ``setup``.
   * 2. Call ``Pixar.Bundler.shared.setup(.resources)``.
   */
  extension Pixar.Bundler
  {
    /**
     * Write embedded plugInfo.json files to the app's files directory and
     * register them with ``PlugRegistry``.
     */
    func resourcesInitAndroid()
    {
      #if os(Android)
        // Derive the app's files directory from /proc/self/cmdline.
        if let fh = FileHandle(forReadingAtPath: "/proc/self/cmdline")
        {
          let data = fh.readData(ofLength: 512)   // package names are well under 512 chars
          fh.closeFile()
          let pkgName: String
          if let firstNull = data.firstIndex(of: 0)
          {
            pkgName = String(data: data[..<firstNull], encoding: .utf8) ?? ""
          }
          else
          {
            pkgName = String(data: data, encoding: .utf8) ?? ""
          }
          if !pkgName.isEmpty
          {
            Pixar.Bundler.androidFilesDir = "/data/data/\(pkgName)/files"
          }
        }
      #endif
      
      let filesDir = Pixar.Bundler.androidFilesDir
      guard !filesDir.isEmpty
      else
      {
        print("OpenUSDKit: androidFilesDir not set — plugin registration skipped.")
        return
      }

      let pxrRoot = filesDir + "/pxr-resources"
      let fm = FileManager.default

      /* Write each embedded plugInfo.json to the right sub-directory. */
      for (dirname, json) in Pixar.Bundler.embeddedPluginInfo
      {
        let dirPath = pxrRoot + "/" + dirname
        do
        {
          try fm.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
          let filePath = dirPath + "/plugInfo.json"
          /* Always (re-)write so updates in new app versions are picked up. */
          try json.write(toFile: filePath, atomically: true, encoding: .utf8)
        }
        catch
        {
          print("OpenUSDKit: failed to write \(dirname)/plugInfo.json: \(error)")
        }
      }

      /* Register each directory with the plug registry. */
      var plugPaths = Overlay.MakeStringVector()
      for (dirname, _) in Pixar.Bundler.embeddedPluginInfo
      {
        let dirPath = pxrRoot + "/" + dirname
        plugPaths = dirPath.withCString { Overlay.PushBackPath(plugPaths, $0) }
      }

      Pixar.PlugRegistry.GetInstance().RegisterPlugins(plugPaths)
    }

    // Embedded plugInfo.json content — one entry per module.
    // These are byte-for-byte copies of Sources/<Module>/Resources/plugInfo.json
    // so that they can be written to the filesystem at runtime on Android.

    static let embeddedPluginInfo: [(String, String)] = [
      ("swift-usd_Ar.resources", arPlugInfo),
      ("swift-usd_Sdf.resources", sdfPlugInfo),
      ("swift-usd_Usd.resources", usdPlugInfo),
      ("swift-usd_Ndr.resources", ndrPlugInfo),
      ("swift-usd_UsdGeom.resources", usdGeomPlugInfo),
      ("swift-usd_UsdShade.resources", usdShadePlugInfo),
      ("swift-usd_UsdShaders.resources", usdShadersPlugInfo),
      ("swift-usd_UsdLod.resources", usdLodPlugInfo),
      ("swift-usd_UsdLux.resources", usdLuxPlugInfo),
      ("swift-usd_UsdHydra.resources", usdHydraPlugInfo),
      ("swift-usd_SdrOsl.resources", sdrOslPlugInfo),
      ("swift-usd_UsdAbc.resources", usdAbcPlugInfo),
      ("swift-usd_UsdDraco.resources", usdDracoPlugInfo),
      ("swift-usd_UsdMedia.resources", usdMediaPlugInfo),
      ("swift-usd_UsdMtlx.resources", usdMtlxPlugInfo),
      ("swift-usd_UsdPhysics.resources", usdPhysicsPlugInfo),
      ("swift-usd_UsdProc.resources", usdProcPlugInfo),
      ("swift-usd_UsdRender.resources", usdRenderPlugInfo),
      ("swift-usd_UsdRi.resources", usdRiPlugInfo),
      ("swift-usd_UsdSkel.resources", usdSkelPlugInfo),
      ("swift-usd_UsdUI.resources", usdUIPlugInfo),
      ("swift-usd_UsdVol.resources", usdVolPlugInfo),
      ("swift-usd_Hd.resources", hdPlugInfo),
      ("swift-usd_HdSi.resources", hdSiPlugInfo),
      ("swift-usd_HdSt.resources", hdStPlugInfo),
      ("swift-usd_HdStorm.resources", hdStormPlugInfo),
      ("swift-usd_Hdx.resources", hdxPlugInfo),
      ("swift-usd_HdGp.resources", hdGpPlugInfo),
      ("swift-usd_Hio.resources", hioPlugInfo),
      ("swift-usd_HioAVIF.resources", hioAVIFPlugInfo),
      ("swift-usd_HioImageIO.resources", hioImageIOPlugInfo),
      ("swift-usd_HioOIIO.resources", hioOIIOPlugInfo),
      ("swift-usd_HioOpenEXR.resources", hioOpenEXRPlugInfo),
      ("swift-usd_HioOpenVDB.resources", hioOpenVDBPlugInfo),
      ("swift-usd_Glf.resources", glfPlugInfo),
      ("swift-usd_HgiGL.resources", hgiGLPlugInfo),
      ("swift-usd_HgiVulkan.resources", hgiVulkanPlugInfo),
      ("swift-usd_UsdImaging.resources", usdImagingPlugInfo),
      ("swift-usd_UsdImagingGL.resources", usdImagingGLPlugInfo),
    ]

    // MARK: - Ar

    private static let arPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "ArResolver": {},
              "ArDefaultResolver": {
                "bases": ["ArResolver"],
                "implementsContexts": true
              },
              "ArPackageResolver": {}
            }
          },
          "LibraryPath": "",
          "Name": "Ar",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - Sdf

    private static let sdfPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "SdfMetadata": {
              "payloadAssetDependencies": {
                "appliesTo": "prims",
                "displayGroup": "Pipeline",
                "type": "asset[]"
              }
            },
            "Types": {
              "SdfFileFormat": {
                "displayName": "Sdf file format base class",
                "target": "sdf"
              },
              "SdfTextFileFormat": {
                "bases": ["SdfFileFormat"],
                "displayName": "Sdf Text File Format",
                "extensions": ["sdf"],
                "formatId": "sdf"
              }
            }
          },
          "LibraryPath": "",
          "Name": "Sdf",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - Usd

    private static let usdPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "SdfMetadata": {
              "apiSchemas": {
                "appliesTo": "prims",
                "type": "tokenlistop"
              },
              "clipSets": {
                "appliesTo": ["prims"],
                "type": "stringlistop"
              },
              "clips": {
                "appliesTo": ["prims"],
                "type": "dictionary"
              },
              "fallbackPrimTypes": {
                "appliesTo": ["layers"],
                "type": "dictionary"
              }
            },
            "Types": {
              "UsdAPISchemaBase": {
                "alias": { "UsdSchemaBase": "APISchemaBase" },
                "autoGenerated": true,
                "bases": ["UsdSchemaBase"],
                "schemaKind": "abstractBase"
              },
              "UsdClipsAPI": {
                "alias": { "UsdSchemaBase": "ClipsAPI" },
                "autoGenerated": true,
                "bases": ["UsdAPISchemaBase"],
                "schemaKind": "nonAppliedAPI"
              },
              "UsdCollectionAPI": {
                "alias": { "UsdSchemaBase": "CollectionAPI" },
                "autoGenerated": true,
                "bases": ["UsdAPISchemaBase"],
                "schemaKind": "multipleApplyAPI"
              },
              "UsdModelAPI": {
                "alias": { "UsdSchemaBase": "ModelAPI" },
                "autoGenerated": true,
                "bases": ["UsdAPISchemaBase"],
                "schemaKind": "nonAppliedAPI"
              },
              "UsdSchemaBase": {
                "alias": { "UsdSchemaBase": "SchemaBase" },
                "schemaKind": "abstractBase"
              },
              "UsdTyped": {
                "alias": { "UsdSchemaBase": "Typed" },
                "autoGenerated": true,
                "bases": ["UsdSchemaBase"],
                "schemaKind": "abstractBase"
              },
              "UsdUsdFileFormat": {
                "bases": ["SdfFileFormat"],
                "displayName": "USD File Format",
                "extensions": ["usd"],
                "formatId": "usd",
                "primary": true,
                "target": "usd"
              },
              "UsdUsdaFileFormat": {
                "bases": ["SdfTextFileFormat"],
                "displayName": "USD Text File Format",
                "extensions": ["usda"],
                "formatId": "usda",
                "primary": true,
                "target": "usd"
              },
              "UsdUsdcFileFormat": {
                "bases": ["SdfFileFormat"],
                "displayName": "USD Crate File Format",
                "extensions": ["usdc"],
                "formatId": "usdc",
                "primary": true,
                "target": "usd"
              },
              "UsdUsdzFileFormat": {
                "bases": ["SdfFileFormat"],
                "displayName": "USDZ File Format",
                "extensions": ["usdz"],
                "formatId": "usdz",
                "primary": true,
                "supportsEditing": false,
                "supportsWriting": false,
                "target": "usd"
              },
              "Usd_UsdzResolver": {
                "bases": ["ArPackageResolver"],
                "extensions": ["usdz"]
              }
            }
          },
          "LibraryPath": "",
          "Name": "Usd",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - Ndr

    private static let ndrPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "NdrDiscoveryPlugin": {},
              "_NdrFilesystemDiscoveryPlugin": {
                "bases": ["NdrDiscoveryPlugin"],
                "displayName": "Filesystem Discovery"
              },
              "NdrParserPlugin": {}
            }
          },
          "LibraryPath": "",
          "Name": "Ndr",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdGeom

    private static let usdGeomPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "SdfMetadata": {
              "constraintTargetIdentifier": {
                "appliesTo": ["attributes"],
                "default": "",
                "documentation": "Unique identifier within a model's namespace for an matrix-valued attribute representing a constraint target",
                "type": "token"
              },
              "elementSize": {
                "appliesTo": ["attributes"],
                "default": 1,
                "displayGroup": "Primvars",
                "documentation": "The number of values in a primvar's value array that must be aggregated for each element on the primitive.",
                "type": "int"
              },
              "inactiveIds": {
                "appliesTo": ["prims"],
                "type": "int64listop"
              },
              "interpolation": {
                "appliesTo": ["attributes"],
                "default": "constant",
                "displayGroup": "Primvars",
                "documentation": "How a primvar interpolates across a primitive; equivalent to RenderMan's 'class specifier'",
                "type": "token"
              },
              "metersPerUnit": {
                "appliesTo": ["layers"],
                "default": 0.01,
                "displayGroup": "Stage",
                "type": "double"
              },
              "unauthoredValuesIndex": {
                "appliesTo": ["attributes"],
                "default": -1,
                "displayGroup": "Primvars",
                "documentation": "The index that represents unauthored values in the indices array of an indexed primvar.",
                "type": "int"
              },
              "upAxis": {
                "appliesTo": ["layers"],
                "default": "Y",
                "displayGroup": "Stage",
                "type": "token"
              }
            },
            "Types": {
              "UsdGeomBasisCurves": { "alias": { "UsdSchemaBase": "BasisCurves" }, "autoGenerated": true, "bases": ["UsdGeomCurves"], "schemaKind": "concreteTyped" },
              "UsdGeomBoundable": { "alias": { "UsdSchemaBase": "Boundable" }, "autoGenerated": true, "bases": ["UsdGeomXformable"], "schemaKind": "abstractTyped" },
              "UsdGeomCamera": { "alias": { "UsdSchemaBase": "Camera" }, "autoGenerated": true, "bases": ["UsdGeomXformable"], "schemaKind": "concreteTyped" },
              "UsdGeomCapsule": { "alias": { "UsdSchemaBase": "Capsule" }, "autoGenerated": true, "bases": ["UsdGeomGprim"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" },
              "UsdGeomCapsule_1": { "alias": { "UsdSchemaBase": "Capsule_1" }, "autoGenerated": true, "bases": ["UsdGeomGprim"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" },
              "UsdGeomCone": { "alias": { "UsdSchemaBase": "Cone" }, "autoGenerated": true, "bases": ["UsdGeomGprim"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" },
              "UsdGeomCube": { "alias": { "UsdSchemaBase": "Cube" }, "autoGenerated": true, "bases": ["UsdGeomGprim"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" },
              "UsdGeomCurves": { "alias": { "UsdSchemaBase": "Curves" }, "autoGenerated": true, "bases": ["UsdGeomPointBased"], "implementsComputeExtent": true, "schemaKind": "abstractTyped" },
              "UsdGeomCylinder": { "alias": { "UsdSchemaBase": "Cylinder" }, "autoGenerated": true, "bases": ["UsdGeomGprim"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" },
              "UsdGeomCylinder_1": { "alias": { "UsdSchemaBase": "Cylinder_1" }, "autoGenerated": true, "bases": ["UsdGeomGprim"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" },
              "UsdGeomGprim": { "alias": { "UsdSchemaBase": "Gprim" }, "autoGenerated": true, "bases": ["UsdGeomBoundable"], "schemaKind": "abstractTyped" },
              "UsdGeomHermiteCurves": { "alias": { "UsdSchemaBase": "HermiteCurves" }, "autoGenerated": true, "bases": ["UsdGeomCurves"], "schemaKind": "concreteTyped" },
              "UsdGeomImageable": { "alias": { "UsdSchemaBase": "Imageable" }, "autoGenerated": true, "bases": ["UsdTyped"], "schemaKind": "abstractTyped" },
              "UsdGeomMesh": { "alias": { "UsdSchemaBase": "Mesh" }, "autoGenerated": true, "bases": ["UsdGeomPointBased"], "schemaKind": "concreteTyped" },
              "UsdGeomModelAPI": { "alias": { "UsdSchemaBase": "GeomModelAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdGeomMotionAPI": { "alias": { "UsdSchemaBase": "MotionAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdGeomNurbsCurves": { "alias": { "UsdSchemaBase": "NurbsCurves" }, "autoGenerated": true, "bases": ["UsdGeomCurves"], "schemaKind": "concreteTyped" },
              "UsdGeomNurbsPatch": { "alias": { "UsdSchemaBase": "NurbsPatch" }, "autoGenerated": true, "bases": ["UsdGeomPointBased"], "schemaKind": "concreteTyped" },
              "UsdGeomPlane": { "alias": { "UsdSchemaBase": "Plane" }, "autoGenerated": true, "bases": ["UsdGeomGprim"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" },
              "UsdGeomPointBased": { "alias": { "UsdSchemaBase": "PointBased" }, "autoGenerated": true, "bases": ["UsdGeomGprim"], "implementsComputeExtent": true, "schemaKind": "abstractTyped" },
              "UsdGeomPointInstancer": { "alias": { "UsdSchemaBase": "PointInstancer" }, "autoGenerated": true, "bases": ["UsdGeomBoundable"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" },
              "UsdGeomPoints": { "alias": { "UsdSchemaBase": "Points" }, "autoGenerated": true, "bases": ["UsdGeomPointBased"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" },
              "UsdGeomPrimvarsAPI": { "alias": { "UsdSchemaBase": "PrimvarsAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "nonAppliedAPI" },
              "UsdGeomScope": { "alias": { "UsdSchemaBase": "Scope" }, "autoGenerated": true, "bases": ["UsdGeomImageable"], "schemaKind": "concreteTyped" },
              "UsdGeomSphere": { "alias": { "UsdSchemaBase": "Sphere" }, "autoGenerated": true, "bases": ["UsdGeomGprim"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" },
              "UsdGeomSubset": { "alias": { "UsdSchemaBase": "GeomSubset" }, "autoGenerated": true, "bases": ["UsdTyped"], "schemaKind": "concreteTyped" },
              "UsdGeomTetMesh": { "alias": { "UsdSchemaBase": "TetMesh" }, "autoGenerated": true, "bases": ["UsdGeomPointBased"], "schemaKind": "concreteTyped" },
              "UsdGeomVisibilityAPI": { "alias": { "UsdSchemaBase": "VisibilityAPI" }, "apiSchemaCanOnlyApplyTo": ["Imageable"], "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdGeomXform": { "alias": { "UsdSchemaBase": "Xform" }, "autoGenerated": true, "bases": ["UsdGeomXformable"], "schemaKind": "concreteTyped" },
              "UsdGeomXformCommonAPI": { "alias": { "UsdSchemaBase": "XformCommonAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "nonAppliedAPI" },
              "UsdGeomXformable": { "alias": { "UsdSchemaBase": "Xformable" }, "autoGenerated": true, "bases": ["UsdGeomImageable"], "schemaKind": "abstractTyped" }
            }
          },
          "LibraryPath": "",
          "Name": "UsdGeom",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdShade

    private static let usdShadePlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "SdfMetadata": {
              "bindMaterialAs": { "appliesTo": ["relationships"], "displayGroup": "Shading", "documentation": "Metadata authored on collection-based material binding relationship to indicate the strength of the binding relative to bindings authored on descendant prims.", "type": "token" },
              "connectability": { "appliesTo": ["attributes"], "default": "full", "displayGroup": "Shading", "documentation": "Metadata authored on UsdShadeInput's to specify what they can be connected to.", "type": "token" },
              "outputName": { "appliesTo": ["relationships"], "displayGroup": "deprecated", "type": "token" },
              "renderType": { "appliesTo": ["properties"], "displayGroup": "Rendering", "type": "token" },
              "sdrMetadata": { "appliesTo": ["prims", "attributes"], "displayGroup": "Shading", "type": "dictionary" }
            },
            "Types": {
              "UsdShadeConnectableAPI": { "alias": { "UsdSchemaBase": "ConnectableAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "nonAppliedAPI" },
              "UsdShadeCoordSysAPI": { "alias": { "UsdSchemaBase": "CoordSysAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "multipleApplyAPI" },
              "UsdShadeMaterial": { "alias": { "UsdSchemaBase": "Material" }, "autoGenerated": true, "bases": ["UsdShadeNodeGraph"], "providesUsdShadeConnectableAPIBehavior": true, "schemaKind": "concreteTyped" },
              "UsdShadeMaterialBindingAPI": { "alias": { "UsdSchemaBase": "MaterialBindingAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdShadeNodeDefAPI": { "alias": { "UsdSchemaBase": "NodeDefAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdShadeNodeGraph": { "alias": { "UsdSchemaBase": "NodeGraph" }, "autoGenerated": true, "bases": ["UsdTyped"], "providesUsdShadeConnectableAPIBehavior": true, "schemaKind": "concreteTyped" },
              "UsdShadeShader": { "alias": { "UsdSchemaBase": "Shader" }, "autoGenerated": true, "bases": ["UsdTyped"], "providesUsdShadeConnectableAPIBehavior": true, "schemaKind": "concreteTyped" },
              "UsdShadeShaderDefParserPlugin": { "bases": ["NdrParserPlugin"], "displayName": "USD-based shader definition parser plugin" }
            }
          },
          "LibraryPath": "",
          "Name": "UsdShade",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdShaders

    private static let usdShadersPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "UsdShadersDiscoveryPlugin": {
                "bases": ["NdrDiscoveryPlugin"],
                "displayName": "USD-based shader definition discovery plugin."
              }
            },
            "ShaderResources": "shaders"
          },
          "LibraryPath": "",
          "Name": "UsdShaders",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdLod

    private static let usdLodPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "UsdLodDistanceHeuristic": {
                "alias": {
                  "UsdSchemaBase": "LODDistanceHeuristic"
                }, 
                "autoGenerated": true, 
                "bases": [
                  "UsdLodHeuristic"
                ], 
                "schemaIdentifier": "LODDistanceHeuristic", 
                "schemaKind": "concreteTyped"
              }, 
              "UsdLodHeuristic": {
                "alias": {
                  "UsdSchemaBase": "LODHeuristic"
                }, 
                "autoGenerated": true, 
                "bases": [
                  "UsdTyped"
                ], 
                "schemaIdentifier": "LODHeuristic", 
                "schemaKind": "abstractTyped"
              }, 
              "UsdLodOverrideAPI": {
                "alias": {
                  "UsdSchemaBase": "LODOverrideAPI"
                }, 
                "autoGenerated": true, 
                "bases": [
                  "UsdAPISchemaBase"
                ], 
                "schemaIdentifier": "LODOverrideAPI", 
                "schemaKind": "singleApplyAPI"
              }, 
              "UsdLodRootAPI": {
                "alias": {
                  "UsdSchemaBase": "LODRootAPI"
                }, 
                "autoGenerated": true, 
                "bases": [
                  "UsdAPISchemaBase"
                ], 
                "schemaIdentifier": "LODRootAPI", 
                "schemaKind": "singleApplyAPI"
              }, 
              "UsdLodScreenSizeHeuristic": {
                "alias": {
                  "UsdSchemaBase": "LODScreenSizeHeuristic"
                }, 
                "autoGenerated": true, 
                "bases": [
                  "UsdLodHeuristic"
                ], 
                "schemaIdentifier": "LODScreenSizeHeuristic", 
                "schemaKind": "concreteTyped"
              }
            }
          }, 
          "LibraryPath": "", 
          "Name": "UsdLod", 
          "ResourcePath": ".", 
          "Root": ".", 
          "Type": "library"
        }
      ]
    }
    """
    
    // MARK: - UsdLux

    private static let usdLuxPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "UsdLuxBoundableLightBase": { "alias": { "UsdSchemaBase": "BoundableLightBase" }, "autoGenerated": true, "bases": ["UsdGeomBoundable"], "schemaKind": "abstractTyped" },
              "UsdLuxCylinderLight": { "alias": { "UsdSchemaBase": "CylinderLight" }, "autoGenerated": true, "bases": ["UsdLuxBoundableLightBase"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" },
              "UsdLuxDiskLight": { "alias": { "UsdSchemaBase": "DiskLight" }, "autoGenerated": true, "bases": ["UsdLuxBoundableLightBase"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" },
              "UsdLuxDistantLight": { "alias": { "UsdSchemaBase": "DistantLight" }, "autoGenerated": true, "bases": ["UsdLuxNonboundableLightBase"], "schemaKind": "concreteTyped" },
              "UsdLuxDomeLight": { "alias": { "UsdSchemaBase": "DomeLight" }, "autoGenerated": true, "bases": ["UsdLuxNonboundableLightBase"], "schemaKind": "concreteTyped" },
              "UsdLuxDomeLight_1": { "alias": { "UsdSchemaBase": "DomeLight_1" }, "autoGenerated": true, "bases": ["UsdLuxNonboundableLightBase"], "schemaKind": "concreteTyped" },
              "UsdLuxGeometryLight": { "alias": { "UsdSchemaBase": "GeometryLight" }, "autoGenerated": true, "bases": ["UsdLuxNonboundableLightBase"], "schemaKind": "concreteTyped" },
              "UsdLuxLightAPI": { "alias": { "UsdSchemaBase": "LightAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "providesUsdShadeConnectableAPIBehavior": true, "schemaKind": "singleApplyAPI" },
              "UsdLuxLightFilter": { "alias": { "UsdSchemaBase": "LightFilter" }, "autoGenerated": true, "bases": ["UsdGeomXformable"], "providesUsdShadeConnectableAPIBehavior": true, "schemaKind": "concreteTyped" },
              "UsdLuxLightListAPI": { "alias": { "UsdSchemaBase": "LightListAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdLuxListAPI": { "alias": { "UsdSchemaBase": "ListAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdLuxMeshLightAPI": { "alias": { "UsdSchemaBase": "MeshLightAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdLuxNonboundableLightBase": { "alias": { "UsdSchemaBase": "NonboundableLightBase" }, "autoGenerated": true, "bases": ["UsdGeomXformable"], "schemaKind": "abstractTyped" },
              "UsdLuxPluginLight": { "alias": { "UsdSchemaBase": "PluginLight" }, "autoGenerated": true, "bases": ["UsdGeomXformable"], "schemaKind": "concreteTyped" },
              "UsdLuxPluginLightFilter": { "alias": { "UsdSchemaBase": "PluginLightFilter" }, "autoGenerated": true, "bases": ["UsdLuxLightFilter"], "schemaKind": "concreteTyped" },
              "UsdLuxPortalLight": { "alias": { "UsdSchemaBase": "PortalLight" }, "autoGenerated": true, "bases": ["UsdLuxBoundableLightBase"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" },
              "UsdLuxRectLight": { "alias": { "UsdSchemaBase": "RectLight" }, "autoGenerated": true, "bases": ["UsdLuxBoundableLightBase"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" },
              "UsdLuxShadowAPI": { "alias": { "UsdSchemaBase": "ShadowAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdLuxShapingAPI": { "alias": { "UsdSchemaBase": "ShapingAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdLuxSphereLight": { "alias": { "UsdSchemaBase": "SphereLight" }, "autoGenerated": true, "bases": ["UsdLuxBoundableLightBase"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" },
              "UsdLuxVolumeLightAPI": { "alias": { "UsdSchemaBase": "VolumeLightAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdLux_DiscoveryPlugin": { "bases": ["NdrDiscoveryPlugin"] },
              "UsdLux_LightDefParserPlugin": { "bases": ["NdrParserPlugin"] }
            }
          },
          "LibraryPath": "",
          "Name": "UsdLux",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdHydra

    private static let usdHydraPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "UsdHydraDiscoveryPlugin": { "bases": ["NdrDiscoveryPlugin"], "displayName": "Discovery plugin for deprecated hydra shaders." },
              "UsdHydraGenerativeProceduralAPI": { "alias": { "UsdSchemaBase": "HydraGenerativeProceduralAPI" }, "apiSchemaCanOnlyApplyTo": ["GenerativeProcedural"], "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" }
            }
          },
          "LibraryPath": "",
          "Name": "UsdHydra",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - SdrOsl

    private static let sdrOslPlugInfo = """
    {
      "Plugins": [
        {
          "Type": "library",
          "Name": "SdrOsl",
          "Root": ".",
          "LibraryPath": "",
          "ResourcePath": ".",
          "Info": {
            "Types": {
              "SdrOslParserPlugin": {
                "bases": ["NdrParserPlugin"],
                "displayName": "OSL Node Parser"
              }
            }
          }
        }
      ]
    }
    """

    // MARK: - UsdAbc

    private static let usdAbcPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "UsdAbcAlembicFileFormat": {
                "bases": ["SdfFileFormat"],
                "displayName": "USD Alembic File Format",
                "extensions": ["abc"],
                "formatId": "abc",
                "primary": true,
                "target": "usd",
                "supportsEditing": false
              }
            }
          },
          "LibraryPath": "",
          "Name": "UsdAbc",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdDraco

    private static let usdDracoPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "UsdDracoFileFormat": {
                "bases": ["SdfFileFormat"],
                "displayName": "USD Draco File Format",
                "extensions": ["drc"],
                "formatId": "drc",
                "primary": true,
                "supportsEditing": false,
                "supportsWriting": false,
                "target": "usd"
              }
            }
          },
          "LibraryPath": "",
          "Name": "UsdDraco",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdMedia

    private static let usdMediaPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "UsdMediaAssetPreviewsAPI": { "alias": { "UsdSchemaBase": "AssetPreviewsAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdMediaSpatialAudio": { "alias": { "UsdSchemaBase": "SpatialAudio" }, "autoGenerated": true, "bases": ["UsdGeomXformable"], "schemaKind": "concreteTyped" }
            }
          },
          "LibraryPath": "",
          "Name": "UsdMedia",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdMtlx

    private static let usdMtlxPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "UsdMtlxFileFormat": { "bases": ["SdfFileFormat"], "displayName": "USD MaterialX File Format", "extensions": ["mtlx"], "formatId": "mtlx", "primary": true, "supportsEditing": false, "supportsWriting": false, "target": "usd" },
              "UsdMtlxDiscoveryPlugin": { "bases": ["NdrDiscoveryPlugin"], "displayName": "MaterialX Discovery" },
              "UsdMtlxParserPlugin": { "bases": ["NdrParserPlugin"], "displayName": "MaterialX Node Parser" }
            }
          },
          "LibraryPath": "",
          "Name": "UsdMtlx",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdPhysics

    private static let usdPhysicsPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "SdfMetadata": {
              "kilogramsPerUnit": { "appliesTo": ["layers"], "default": 1.0, "displayGroup": "Stage", "type": "double" }
            },
            "Types": {
              "UsdPhysicsArticulationRootAPI": { "alias": { "UsdSchemaBase": "PhysicsArticulationRootAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdPhysicsCollisionAPI": { "alias": { "UsdSchemaBase": "PhysicsCollisionAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdPhysicsCollisionGroup": { "alias": { "UsdSchemaBase": "PhysicsCollisionGroup" }, "autoGenerated": true, "bases": ["UsdTyped"], "schemaKind": "concreteTyped" },
              "UsdPhysicsDistanceJoint": { "alias": { "UsdSchemaBase": "PhysicsDistanceJoint" }, "autoGenerated": true, "bases": ["UsdPhysicsJoint"], "schemaKind": "concreteTyped" },
              "UsdPhysicsDriveAPI": { "alias": { "UsdSchemaBase": "PhysicsDriveAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "multipleApplyAPI" },
              "UsdPhysicsFilteredPairsAPI": { "alias": { "UsdSchemaBase": "PhysicsFilteredPairsAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdPhysicsFixedJoint": { "alias": { "UsdSchemaBase": "PhysicsFixedJoint" }, "autoGenerated": true, "bases": ["UsdPhysicsJoint"], "schemaKind": "concreteTyped" },
              "UsdPhysicsJoint": { "alias": { "UsdSchemaBase": "PhysicsJoint" }, "autoGenerated": true, "bases": ["UsdGeomImageable"], "schemaKind": "concreteTyped" },
              "UsdPhysicsLimitAPI": { "alias": { "UsdSchemaBase": "PhysicsLimitAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "multipleApplyAPI" },
              "UsdPhysicsMassAPI": { "alias": { "UsdSchemaBase": "PhysicsMassAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdPhysicsMaterialAPI": { "alias": { "UsdSchemaBase": "PhysicsMaterialAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdPhysicsMeshCollisionAPI": { "alias": { "UsdSchemaBase": "PhysicsMeshCollisionAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdPhysicsPrismaticJoint": { "alias": { "UsdSchemaBase": "PhysicsPrismaticJoint" }, "autoGenerated": true, "bases": ["UsdPhysicsJoint"], "schemaKind": "concreteTyped" },
              "UsdPhysicsRevoluteJoint": { "alias": { "UsdSchemaBase": "PhysicsRevoluteJoint" }, "autoGenerated": true, "bases": ["UsdPhysicsJoint"], "schemaKind": "concreteTyped" },
              "UsdPhysicsRigidBodyAPI": { "alias": { "UsdSchemaBase": "PhysicsRigidBodyAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdPhysicsScene": { "alias": { "UsdSchemaBase": "PhysicsScene" }, "autoGenerated": true, "bases": ["UsdTyped"], "schemaKind": "concreteTyped" },
              "UsdPhysicsSphericalJoint": { "alias": { "UsdSchemaBase": "PhysicsSphericalJoint" }, "autoGenerated": true, "bases": ["UsdPhysicsJoint"], "schemaKind": "concreteTyped" }
            }
          },
          "LibraryPath": "",
          "Name": "UsdPhysics",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdProc

    private static let usdProcPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "UsdProcGenerativeProcedural": { "alias": { "UsdSchemaBase": "GenerativeProcedural" }, "autoGenerated": true, "bases": ["UsdGeomBoundable"], "schemaKind": "concreteTyped" }
            }
          },
          "LibraryPath": "",
          "Name": "UsdProc",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdRender

    private static let usdRenderPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "SdfMetadata": {
              "renderSettingsPrimPath": { "appliesTo": "layers", "default": "", "type": "string" }
            },
            "Types": {
              "UsdRenderDenoisePass": { "alias": { "UsdSchemaBase": "RenderDenoisePass" }, "autoGenerated": true, "bases": ["UsdTyped"], "schemaKind": "concreteTyped" },
              "UsdRenderPass": { "alias": { "UsdSchemaBase": "RenderPass" }, "autoGenerated": true, "bases": ["UsdTyped"], "schemaKind": "concreteTyped" },
              "UsdRenderProduct": { "alias": { "UsdSchemaBase": "RenderProduct" }, "autoGenerated": true, "bases": ["UsdRenderSettingsBase"], "schemaKind": "concreteTyped" },
              "UsdRenderSettings": { "alias": { "UsdSchemaBase": "RenderSettings" }, "autoGenerated": true, "bases": ["UsdRenderSettingsBase"], "schemaKind": "concreteTyped" },
              "UsdRenderSettingsBase": { "alias": { "UsdSchemaBase": "RenderSettingsBase" }, "autoGenerated": true, "bases": ["UsdTyped"], "schemaKind": "abstractTyped" },
              "UsdRenderVar": { "alias": { "UsdSchemaBase": "RenderVar" }, "autoGenerated": true, "bases": ["UsdTyped"], "schemaKind": "concreteTyped" }
            }
          },
          "LibraryPath": "",
          "Name": "UsdRender",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdRi

    private static let usdRiPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "UsdRiMaterialAPI": { "alias": { "UsdSchemaBase": "RiMaterialAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdRiRenderPassAPI": { "alias": { "UsdSchemaBase": "RiRenderPassAPI" }, "apiSchemaAutoApplyTo": ["RenderPass"], "apiSchemaCanOnlyApplyTo": ["RenderPass"], "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdRiSplineAPI": { "alias": { "UsdSchemaBase": "RiSplineAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdRiStatementsAPI": { "alias": { "UsdSchemaBase": "StatementsAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" }
            }
          },
          "LibraryPath": "",
          "Name": "UsdRi",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdSkel

    private static let usdSkelPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "SdfMetadata": {
              "weight": { "appliesTo": ["attributes"], "default": 0, "displayGroup": "BlendShape", "documentation": "The weight value at which an inbeteen shape is applied.", "type": "float" }
            },
            "Types": {
              "UsdSkelAnimation": { "alias": { "UsdSchemaBase": "SkelAnimation" }, "autoGenerated": true, "bases": ["UsdTyped"], "schemaKind": "concreteTyped" },
              "UsdSkelBindingAPI": { "alias": { "UsdSchemaBase": "SkelBindingAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdSkelBlendShape": { "alias": { "UsdSchemaBase": "BlendShape" }, "autoGenerated": true, "bases": ["UsdTyped"], "schemaKind": "concreteTyped" },
              "UsdSkelPackedJointAnimation": { "alias": { "UsdSchemaBase": "PackedJointAnimation" }, "autoGenerated": true, "bases": ["UsdSkelAnimation"], "schemaKind": "concreteTyped" },
              "UsdSkelRoot": { "alias": { "UsdSchemaBase": "SkelRoot" }, "autoGenerated": true, "bases": ["UsdGeomBoundable"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" },
              "UsdSkelSkeleton": { "alias": { "UsdSchemaBase": "Skeleton" }, "autoGenerated": true, "bases": ["UsdGeomBoundable"], "implementsComputeExtent": true, "schemaKind": "concreteTyped" }
            }
          },
          "LibraryPath": "",
          "Name": "UsdSkel",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdUI

    private static let usdUIPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "UsdUIBackdrop": { "alias": { "UsdSchemaBase": "Backdrop" }, "autoGenerated": true, "bases": ["UsdTyped"], "schemaKind": "concreteTyped" },
              "UsdUINodeGraphNodeAPI": { "alias": { "UsdSchemaBase": "NodeGraphNodeAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" },
              "UsdUISceneGraphPrimAPI": { "alias": { "UsdSchemaBase": "SceneGraphPrimAPI" }, "autoGenerated": true, "bases": ["UsdAPISchemaBase"], "schemaKind": "singleApplyAPI" }
            }
          },
          "LibraryPath": "",
          "Name": "UsdUI",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdVol

    private static let usdVolPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "UsdVolField3DAsset": { "alias": { "UsdSchemaBase": "Field3DAsset" }, "autoGenerated": true, "bases": ["UsdVolFieldAsset"], "schemaKind": "concreteTyped" },
              "UsdVolFieldAsset": { "alias": { "UsdSchemaBase": "FieldAsset" }, "autoGenerated": true, "bases": ["UsdVolFieldBase"], "schemaKind": "abstractTyped" },
              "UsdVolFieldBase": { "alias": { "UsdSchemaBase": "FieldBase" }, "autoGenerated": true, "bases": ["UsdGeomXformable"], "schemaKind": "abstractTyped" },
              "UsdVolOpenVDBAsset": { "alias": { "UsdSchemaBase": "OpenVDBAsset" }, "autoGenerated": true, "bases": ["UsdVolFieldAsset"], "schemaKind": "concreteTyped" },
              "UsdVolVolume": { "alias": { "UsdSchemaBase": "Volume" }, "autoGenerated": true, "bases": ["UsdGeomGprim"], "schemaKind": "concreteTyped" }
            }
          },
          "LibraryPath": "",
          "Name": "UsdVol",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - Hd

    private static let hdPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {},
          "LibraryPath": "",
          "Name": "Hd",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - HdSi

    private static let hdSiPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "HdsiDebuggingSceneIndexPlugin" : {
                "bases": ["HdSceneIndexPlugin"],
                "loadWithRenderer": "",
                "priority": 0,
                "displayName": "Add debugging scene index if corresponding env var is set."
              }
            }
          },
          "LibraryPath": "",
          "Name": "HdSi",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """
    
    // MARK: - HdSt

    private static let hdStPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "HdSt_DependencySceneIndexPlugin": { "bases": ["HdSceneIndexPlugin"], "loadWithRenderer": "GL", "priority": 0, "displayName": "Storm Dependency Scene Index" },
              "HdSt_DependencyForwardingSceneIndexPlugin": { "bases": ["HdSceneIndexPlugin"], "loadWithRenderer": "GL", "priority": 0, "displayName": "Storm Dependency Forwarding Scene Index" },
              "HdSt_MaterialBindingResolvingSceneIndexPlugin": { "bases": ["HdSceneIndexPlugin"], "loadWithRenderer": "GL", "priority": 0, "displayName": "Scene Index to resolve material bindings." },
              "HdSt_MaterialPrimvarTransferSceneIndexPlugin": { "bases": ["HdSceneIndexPlugin"], "loadWithRenderer": "GL", "priority": 0, "displayName": "Scene Index to transfer primvars from material to prim." },
              "HdSt_NodeIdentifierResolvingSceneIndexPlugin": { "bases": ["HdSceneIndexPlugin"], "loadWithRenderer": "GL", "priority": 0, "displayName": "Scene Index to resolve nodeIdentifier from glslfx sourceAsset." },
              "HdSt_ImplicitSurfaceSceneIndexPlugin": { "bases": ["HdSceneIndexPlugin"], "loadWithRenderer": "GL", "priority": 0, "displayName": "Scene Index to turn implicit surfaces into prims suitable for Storm" },
              "HdSt_NurbsApproximatingSceneIndexPlugin": { "bases": ["HdSceneIndexPlugin"], "loadWithRenderer": "GL", "priority": 0, "displayName": "Scene Index to resolve terminal names." },
              "HdSt_TetMeshConversionSceneIndexPlugin": { "bases": ["HdSceneIndexPlugin"], "loadWithRenderer": "GL", "priority": 0, "displayName": "Scene Index to convert tet meshes into standard triangle based meshes." },
              "HdSt_VelocityMotionResolvingSceneIndexPlugin": { "bases": ["HdSceneIndexPlugin"], "loadWithRenderer": "GL", "priority": 0, "displayName": "Scene index to resolve velocity-based motion." }
            },
            "ShaderResources": "shaders"
          },
          "LibraryPath": "",
          "Name": "HdSt",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - HdStorm

    private static let hdStormPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "HdStormRendererPlugin": { "bases": ["HdRendererPlugin"], "displayName": "GL", "priority": 0 }
            }
          },
          "LibraryPath": "",
          "Name": "HdStorm",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - Hdx

    private static let hdxPlugInfo = """
    {
      "Plugins": [
        {
          "Info": { "ShaderResources": "shaders" },
          "LibraryPath": "",
          "Name": "Hdx",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """
    
    // MARK: - HdGp
    
    private static let hdGpPlugInfo = """
    {
        "Plugins": [
            {
                "Info": {
                    "Types": {
                        "HdGpSceneIndexPlugin": {
                            "bases": [
                                "HdSceneIndexPlugin"
                            ],
                            "displayName":
                                "HdGpGenerativeProceduralResolvingSceneIndex",
                            "loadWithRenderer": "",
                            "priority": 0,

                            "tags": ["hdGp:proceduralResolution"],
                            "ordering": {
                                # hd:sceneAssembly is a special/built-in tag, used
                                # here for clarity to indicate that procedural
                                # resolution should happen after scene assembly.
                                "after": "hd:sceneAssembly"
                            }
                        }
                    }
                },
                "LibraryPath": "",
                "Name": "HdGp",
                "ResourcePath": ".",
                "Root": ".",
                "Type": "library"
            }
        ]
    }
    """

    // MARK: - Hio

    private static let hioPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "Hio_StbImage": {
                "bases": ["HioImage"],
                "imageTypes": ["bmp", "jpg", "jpeg", "png", "tga", "hdr"],
                "precedence": 30
              }
            }
          },
          "LibraryPath": "",
          "Name": "Hio",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - HioAVIF

    private static let hioAVIFPlugInfo = """
    {
        "Plugins": [
            {
                "Info": {
                    "Types": {
                       "Hio_AVIFImage" : {
                            "bases": ["HioImage"],
                            "imageTypes": ["avif"],
                            "precedence": 30
                        }
                    }
                },
                "LibraryPath": "",
                "Name": "HioAVIF",
                "ResourcePath": ".",
                "Root": ".",
                "Type": "library"
            }
        ]
    }
    """
    
    // MARK: - HioImageIO

    private static let hioImageIOPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "HioImageIO_Image" : {
                "bases": ["HioImage"],
                "imageTypes": ["tif", "tiff"],
                "precedence": 15
              }
            }
          },
          "LibraryPath": "",
          "Name": "HioImageIO",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """
    
    // MARK: - HioOIIO

    private static let hioOIIOPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "HioOIIO_Image" : {
                "bases": ["HioImage"],
                "imageTypes": ["tif", "tiff", "zfile", "tx"],
                "precedence": 10
              }
            }
          },
          "LibraryPath": "",
          "Name": "HioOIIO",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """
    
    // MARK: - HioOpenEXR

    private static let hioOpenEXRPlugInfo = """
    {
        "Plugins": [
            {
                "Info": {
                    "Types": {
                       "Hio_OpenEXRImage" : {
                            "bases": ["HioImage"],
                            "imageTypes": ["exr"],
                            "precedence": 30
                        }
                    }
                },
                "LibraryPath": "",
                "Name": "HioOpenEXR",
                "ResourcePath": ".",
                "Root": ".",
                "Type": "library"
            }
        ]
    }
    """
    
    // MARK: - HioOpenVDB

    private static let hioOpenVDBPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "HioOpenVDB_TextureData" : {
                "bases": ["HioFieldTextureData"],
                "fieldDataTypes": ["vdb"],
                "precedence": 0
              }
            }
          },
          "LibraryPath": "",
          "Name": "HioOpenVDB",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """
    
    // MARK: - Glf

    private static let glfPlugInfo = """
    {
      "Plugins": [
        {
          "Info": { "ShaderResources": "shaders" },
          "LibraryPath": "",
          "Name": "Glf",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - HgiGL

    private static let hgiGLPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "HgiGL": { "bases": ["Hgi"] }
            }
          },
          "LibraryPath": "",
          "Name": "HgiGL",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - HgiVulkan

    private static let hgiVulkanPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "Types": {
              "HgiVulkan": { "bases": ["Hgi"] }
            }
          },
          "LibraryPath": "",
          "Name": "HgiVulkan",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdImaging

    private static let usdImagingPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {
            "SdfMetadata": {
              "faceIndexPrimvar": { "appliesTo": ["attributes"], "default": "ptexFaceIndex", "documentation": "Specifies an array of face indices used for ptex mapping", "type": "token" },
              "faceOffsetPrimvar": { "appliesTo": ["attributes"], "default": "ptexFaceOffset", "documentation": "Specifies the ptex face index offset for aggregated ptex files", "type": "token" },
              "uvPrimvar": { "appliesTo": ["attributes"], "default": "", "documentation": "Specifies the UV primvar for texture mapping", "type": "token" }
            },
            "Types": {
              "UsdImagingBasisCurvesAdapter": { "bases": ["UsdImagingGprimAdapter"], "isInternal": true, "primTypeName": "BasisCurves" },
              "UsdImagingCameraAdapter": { "bases": ["UsdImagingPrimAdapter"], "isInternal": true, "primTypeName": "Camera" },
              "UsdImagingCapsuleAdapter": { "bases": ["UsdImagingGprimAdapter"], "isInternal": true, "includeSchemaFamily": true, "primTypeName": "Capsule" },
              "UsdImagingCollectionAPIAdapter": { "bases": ["UsdImagingAPISchemaAdapter"], "isInternal": true, "apiSchemaName": "CollectionAPI" },
              "UsdImagingConeAdapter": { "bases": ["UsdImagingGprimAdapter"], "isInternal": true, "primTypeName": "Cone" },
              "UsdImagingCoordSysAdapter": { "bases": ["UsdImagingPrimAdapter"], "isInternal": true, "primTypeName": "coordSys" },
              "UsdImagingCoordSysAPIAdapter": { "bases": ["UsdImagingAPISchemaAdapter"], "isInternal": true, "apiSchemaName": "CoordSysAPI" },
              "UsdImagingCubeAdapter": { "bases": ["UsdImagingGprimAdapter"], "isInternal": true, "primTypeName": "Cube" },
              "UsdImagingCylinderAdapter": { "bases": ["UsdImagingGprimAdapter"], "isInternal": true, "includeSchemaFamily": true, "primTypeName": "Cylinder" },
              "UsdImagingDrawModeAdapter": { "bases": ["UsdImagingInstanceablePrimAdapter"], "isInternal": true, "primTypeName": "__drawModeAdapter" },
              "UsdImagingGeomSubsetAdapter": { "bases": ["UsdImagingPrimAdapter"], "isInternal": true, "primTypeName": "GeomSubset" },
              "UsdImagingHermiteCurvesAdapter": { "bases": ["UsdImagingGprimAdapter"], "isInternal": true, "primTypeName": "HermiteCurves" },
              "UsdImagingMaterialAdapter": { "bases": ["UsdImagingPrimAdapter"], "isInternal": true, "primTypeName": "Material" },
              "UsdImagingShaderAdapter": { "bases": ["UsdImagingRepresentedByAncestorPrimAdapter"], "isInternal": true, "primTypeName": "Shader" },
              "UsdImagingNodeGraphAdapter": { "bases": ["UsdImagingRepresentedByAncestorPrimAdapter"], "isInternal": true, "primTypeName": "NodeGraph" },
              "UsdImagingMaterialBindingAPIAdapter": { "bases": ["UsdImagingAPISchemaAdapter"], "isInternal": true, "apiSchemaName": "MaterialBindingAPI" },
              "UsdImagingMeshAdapter": { "bases": ["UsdImagingGprimAdapter"], "isInternal": true, "primTypeName": "Mesh" },
              "UsdImagingTetMeshAdapter": { "bases": ["UsdImagingGprimAdapter"], "isInternal": true, "primTypeName": "TetMesh" },
              "UsdImagingNurbsCurvesAdapter": { "bases": ["UsdImagingGprimAdapter"], "isInternal": true, "primTypeName": "NurbsCurves" },
              "UsdImagingNurbsPatchAdapter": { "bases": ["UsdImagingGprimAdapter"], "isInternal": true, "primTypeName": "NurbsPatch" },
              "UsdImagingPlaneAdapter": { "bases": ["UsdImagingGprimAdapter"], "isInternal": true, "primTypeName": "Plane" },
              "UsdImagingPointsAdapter": { "bases": ["UsdImagingGprimAdapter"], "isInternal": true, "primTypeName": "Points" },
              "UsdImagingPointInstancerAdapter": { "bases": ["UsdImagingInstanceablePrimAdapter"], "isInternal": true, "primTypeName": "PointInstancer" },
              "UsdImagingSphereAdapter": { "bases": ["UsdImagingGprimAdapter"], "isInternal": true, "primTypeName": "Sphere" },
              "UsdImagingRenderPassAdapter": { "bases": ["UsdImagingPrimAdapter"], "isInternal": true, "primTypeName": "RenderPass" },
              "UsdImagingRenderSettingsAdapter": { "bases": ["UsdImagingPrimAdapter"], "isInternal": true, "primTypeName": "RenderSettings" },
              "UsdImagingRenderProductAdapter": { "bases": ["UsdImagingPrimAdapter"], "isInternal": true, "primTypeName": "RenderProduct" },
              "UsdImagingRenderVarAdapter": { "bases": ["UsdImagingPrimAdapter"], "isInternal": true, "primTypeName": "RenderVar" },
              "UsdImagingVolumeAdapter": { "bases": ["UsdImagingGprimAdapter"], "isInternal": true, "primTypeName": "Volume" },
              "UsdImagingLightAdapter": { "bases": ["UsdImagingInstanceablePrimAdapter"], "isInternal": true, "primTypeName": "LightAPI", "includeDerivedPrimTypes": true },
              "UsdImagingLightAPIAdapter": { "bases": ["UsdImagingAPISchemaAdapter"], "isInternal": true, "apiSchemaName": "LightAPI" },
              "UsdImagingLightFilterAdapter": { "bases": ["UsdImagingPrimAdapter"], "isInternal": true, "primTypeName": "LightFilter", "includeDerivedPrimTypes": true },
              "UsdImagingDomeLightAdapter": { "bases": ["UsdImagingLightAdapter"], "isInternal": true, "primTypeName": "DomeLight" },
              "UsdImagingDomeLight_1Adapter": { "bases": ["UsdImagingLightAdapter"], "isInternal": true, "primTypeName": "DomeLight_1" },
              "UsdImagingRectLightAdapter": { "bases": ["UsdImagingLightAdapter"], "isInternal": true, "primTypeName": "RectLight" },
              "UsdImagingSphereLightAdapter": { "bases": ["UsdImagingLightAdapter"], "isInternal": true, "primTypeName": "SphereLight" },
              "UsdImagingCylinderLightAdapter": { "bases": ["UsdImagingLightAdapter"], "isInternal": true, "primTypeName": "CylinderLight" },
              "UsdImagingDiskLightAdapter": { "bases": ["UsdImagingLightAdapter"], "isInternal": true, "primTypeName": "DiskLight" },
              "UsdImagingDistantLightAdapter": { "bases": ["UsdImagingLightAdapter"], "isInternal": true, "primTypeName": "DistantLight" },
              "UsdImagingPluginLightAdapter": { "bases": ["UsdImagingLightAdapter"], "isInternal": true, "primTypeName": "PluginLight" },
              "UsdImagingGeometryLightAdapter": { "bases": ["UsdImagingLightAdapter"], "isInternal": true, "primTypeName": "GeometryLight" },
              "UsdImagingPortalLightAdapter": { "bases": ["UsdImagingLightAdapter"], "isInternal": true, "primTypeName": "PortalLight" },
              "UsdImagingPluginLightFilterAdapter": { "bases": ["UsdImagingLightFilterAdapter"], "isInternal": true, "primTypeName": "PluginLightFilter" },
              "UsdImagingGeomModelAPIAdapter": { "bases": ["UsdImagingAPISchemaAdapter"], "isInternal": true, "apiSchemaName": "GeomModelAPI" }
            }
          },
          "LibraryPath": "",
          "Name": "UsdImaging",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """

    // MARK: - UsdImagingGL

    private static let usdImagingGLPlugInfo = """
    {
      "Plugins": [
        {
          "Info": {},
          "LibraryPath": "",
          "Name": "UsdImagingGL",
          "ResourcePath": ".",
          "Root": ".",
          "Type": "library"
        }
      ]
    }
    """
  }

#endif /* os(Android) */
