//
// Copyright 2016 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#ifndef USDLOD_GENERATED_HEURISTIC_H
#define USDLOD_GENERATED_HEURISTIC_H

/// \file usdLod/heuristic.h

#include "pxr/pxrns.h"
#include "UsdLod/api.h"
#include "Usd/typed.h"
#include "Usd/prim.h"
#include "Usd/stage.h"
#include "UsdLod/tokens.h"

#include "Vt/value.h"

#include "Gf/vec3d.h"
#include "Gf/vec3f.h"
#include "Gf/matrix4d.h"

#include "Tf/token.h"
#include "Tf/type.h"

PXR_NAMESPACE_OPEN_SCOPE

class SdfAssetPath;

// -------------------------------------------------------------------------- //
// LODHEURISTIC                                                               //
// -------------------------------------------------------------------------- //

/// \class UsdLodHeuristic
///
/// Base class for LOD Heuristics.
/// 
/// Due to the varying nature of the inputs, and potentially outputs, of
/// each heuristic, the method of using the heuristic and the type of
/// value that it returns may be different for each type of heuristic.
/// It is the responsibility of the renderer to select a heuristic (or
/// heuristics) that it knows how to use, to invoke it, and to apply
/// the result.
///
/// For any described attribute \em Fallback \em Value or \em Allowed \em Values below
/// that are text/tokens, the actual token is published and defined in \ref UsdLodTokens.
/// So to set an attribute to the value "rightHanded", use UsdLodTokens->rightHanded
/// as the value.
///
class UsdLodHeuristic : public UsdTyped
{
public:
    /// Compile time constant representing what kind of schema this class is.
    ///
    /// \sa UsdSchemaKind
    static const UsdSchemaKind schemaKind = UsdSchemaKind::AbstractTyped;

    /// Construct a UsdLodHeuristic on UsdPrim \p prim .
    /// Equivalent to UsdLodHeuristic::Get(prim.GetStage(), prim.GetPath())
    /// for a \em valid \p prim, but will not immediately throw an error for
    /// an invalid \p prim
    explicit UsdLodHeuristic(const UsdPrim& prim=UsdPrim())
        : UsdTyped(prim)
    {
    }

    /// Construct a UsdLodHeuristic on the prim held by \p schemaObj .
    /// Should be preferred over UsdLodHeuristic(schemaObj.GetPrim()),
    /// as it preserves SchemaBase state.
    explicit UsdLodHeuristic(const UsdSchemaBase& schemaObj)
        : UsdTyped(schemaObj)
    {
    }

    /// Destructor.
    USDLOD_API
    virtual ~UsdLodHeuristic();

    /// Return a vector of names of all pre-declared attributes for this schema
    /// class and all its ancestor classes.  Does not include attributes that
    /// may be authored by custom/extended methods of the schemas involved.
    USDLOD_API
    static const TfTokenVector &
    GetSchemaAttributeNames(bool includeInherited=true);

    /// Return a UsdLodHeuristic holding the prim adhering to this
    /// schema at \p path on \p stage.  If no prim exists at \p path on
    /// \p stage, or if the prim at that path does not adhere to this schema,
    /// return an invalid schema object.  This is shorthand for the following:
    ///
    /// \code
    /// UsdLodHeuristic(stage->GetPrimAtPath(path));
    /// \endcode
    ///
    USDLOD_API
    static UsdLodHeuristic
    Get(const UsdStagePtr &stage, const SdfPath &path);


protected:
    /// Returns the kind of schema this class belongs to.
    ///
    /// \sa UsdSchemaKind
    USDLOD_API
    UsdSchemaKind _GetSchemaKind() const override;

private:
    // needs to invoke _GetStaticTfType.
    friend class UsdSchemaRegistry;
    USDLOD_API
    static const TfType &_GetStaticTfType();

    static bool _IsTypedSchema();

    // override SchemaBase virtuals.
    USDLOD_API
    const TfType &_GetTfType() const override;

public:
    // --------------------------------------------------------------------- //
    // LODDOMAIN 
    // --------------------------------------------------------------------- //
    /// The "domain" of this heuristic. Predefined generic domains
    /// include "imaging", "physics", and "audio". Other generic domain names
    /// may be added in the future. If you are creating your own unique
    /// heuristics, it is recommended that you prefix them with your company,
    /// product, or renderer name.
    ///
    /// | ||
    /// | -- | -- |
    /// | Declaration | `uniform token lod:domain` |
    /// | C++ Type | TfToken |
    /// | \ref Usd_Datatypes "Usd Type" | SdfValueTypeNames->Token |
    /// | \ref SdfVariability "Variability" | SdfVariabilityUniform |
    USDLOD_API
    UsdAttribute GetLodDomainAttr() const;

    /// See GetLodDomainAttr(), and also 
    /// \ref Usd_Create_Or_Get_Property for when to use Get vs Create.
    /// If specified, author \p defaultValue as the attribute's default,
    /// sparsely (when it makes sense to do so) if \p writeSparsely is \c true -
    /// the default for \p writeSparsely is \c false.
    USDLOD_API
    UsdAttribute CreateLodDomainAttr(VtValue const &defaultValue = VtValue(), bool writeSparsely=false) const;

public:
    // ===================================================================== //
    // Feel free to add custom code below this line, it will be preserved by 
    // the code generator. 
    //
    // Just remember to: 
    //  - Close the class declaration with }; 
    //  - Close the namespace with PXR_NAMESPACE_CLOSE_SCOPE
    //  - Close the include guard with #endif
    // ===================================================================== //
    // --(BEGIN CUSTOM CODE)--
};

PXR_NAMESPACE_CLOSE_SCOPE

#endif
