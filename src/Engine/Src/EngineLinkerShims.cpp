/*=============================================================================
	EngineLinkerShims.cpp: Linker-level shims for __FUNC_NAME__ exports and
	dummy symbol targets.

	Why this file exists
	--------------------
	The retail Engine.dll was compiled with MSVC 7.1 (Visual Studio 2003).
	That compiler had a quirk: when a function used the __FUNC_NAME__
	intrinsic (a wide-string version of __FUNCTION__), the compiler
	emitted the string data as an externally-visible symbol. Because the
	game's .def file exports by ordinal, those string symbols ended up in
	the export table and must be present in our rebuilt DLL.

	Modern MSVC (2019+) keeps __FUNC_NAME__ data internal to the
	translation unit, so the symbols don't appear naturally. To match
	the retail export table we:

	  1. Define named wide-string arrays (e.g. _gfn_ABrushBuildCoords)
	     containing the function name text that MSVC 7.1 would have
	     generated.
	  2. Use #pragma comment(linker, "/alternatename:...") to redirect
	     the mangled retail symbol name to our named array.

	This file also provides two catch-all symbols:
	  - dummy_stub_func  (a no-op function returning 0)
	  - dummy_stub_data  (a NULL pointer)
	These are targets for /alternatename directives in other files where
	a .def export references a function or data symbol we haven't yet
	reconstructed. The linker resolves the missing mangled name to the
	dummy, satisfying the export without needing the real implementation.
=============================================================================*/

#include "ImplSource.h"

/*-----------------------------------------------------------------------------
	Dummy implementations that all /alternatename directives point to.
	These are extern "C" so their decorated names are predictable:
	  _dummy_stub_func   (for all function symbols)
	  _dummy_stub_data   (for all data symbols)
-----------------------------------------------------------------------------*/
IMPL_INTENTIONALLY_EMPTY("Catch-all dummy target for /alternatename linker directives")
extern "C" __declspec(noinline) int dummy_stub_func() { return 0; }
extern "C" void* dummy_stub_data = 0;

/*-----------------------------------------------------------------------------
	__FUNC_NAME__ compatibility shims.
	The remaining Engine exports in this file are compiler-version artifacts:
	MSVC 7.1 emitted externally visible function-name string data while modern
	MSVC keeps them internal. Mirror the Core pattern and redirect each export
	to a named wide-string blob instead of anonymous dummy storage.
-----------------------------------------------------------------------------*/
extern "C" {
__declspec(dllexport) const unsigned short _gfn_FDirectionalLightMapSceneNodeCtor[] = {'F','D','i','r','e','c','t','i','o','n','a','l','L','i','g','h','t','M','a','p','S','c','e','n','e','N','o','d','e',':',':','F','D','i','r','e','c','t','i','o','n','a','l','L','i','g','h','t','M','a','p','S','c','e','N','o','d','e',0};
__declspec(dllexport) const unsigned short _gfn_FPointLightMapSceneNodeCtor[]       = {'F','P','o','i','n','t','L','i','g','h','t','M','a','p','S','c','e','n','e','N','o','d','e',':',':','F','P','o','i','n','t','L','i','g','h','t','M','a','p','S','c','e','n','e','N','o','d','e',0};
__declspec(dllexport) const unsigned short _gfn_TLazyArrayByteDtor[]                 = {'T','L','a','z','y','A','r','r','a','y','<','B','Y','T','E','>',':',':','~','T','L','a','z','y','A','r','r','a','y',0};
__declspec(dllexport) const unsigned short _gfn_ABrushBuildCoords[]                  = {'A','B','r','u','s','h',':',':','B','u','i','l','d','C','o','o','r','d','s',0};
__declspec(dllexport) const unsigned short _gfn_FMipmapClear[]                       = {'F','M','i','m','a','p',':',':','C','l','e','a','r',0};
__declspec(dllexport) const unsigned short _gfn_ABrushCopyPosRotScaleFrom[]          = {'A','B','r','u','s','h',':',':','C','o','p','y','P','o','s','R','o','t','S','c','a','l','e','F','r','o','m',0};
__declspec(dllexport) const unsigned short _gfn_ULevelGetActorIndex[]                = {'U','L','e','v','e','l',':',':','G','e','t','A','c','t','o','r','I','n','d','e','x',0};
__declspec(dllexport) const unsigned short _gfn_ATerrainInfoGetLayerAlpha[]          = {'A','T','e','r','r','a','i','n','I','n','f','o',':',':','G','e','t','L','a','y','e','r','A','l','p','h','a',0};
__declspec(dllexport) const unsigned short _gfn_FTagsInit[]                          = {'F','T','a','g','s',':',':','I','n','i','t',0};
__declspec(dllexport) const unsigned short _gfn_UTerrainSectorIsTriangleAll[]        = {'U','T','e','r','r','a','i','n','S','e','c','t','o','r',':',':','I','s','T','r','i','a','n','g','l','e','A','l','l',0};
__declspec(dllexport) const unsigned short _gfn_TLazyArrayByteLoad[]                 = {'T','L','a','z','y','A','r','r','a','y','<','B','Y','T','E','>',':',':','L','o','a','d',0};
__declspec(dllexport) const unsigned short _gfn_ABrushOldBuildCoords[]               = {'A','B','r','u','s','h',':',':','O','l','d','B','u','i','l','d','C','o','o','r','d','s',0};
__declspec(dllexport) const unsigned short _gfn_ULevelSummaryPostLoad[]              = {'U','L','e','v','e','l','S','u','m','m','a','r','y',':',':','P','o','s','t','L','o','a','d',0};
__declspec(dllexport) const unsigned short _gfn_UKMeshPropsSerialize[]               = {'U','K','M','e','s','h','P','r','o','p','s',':',':','S','e','r','i','a','l','i','z','e',0};
__declspec(dllexport) const unsigned short _gfn_UPolysSerialize[]                    = {'U','P','o','l','y','s',':',':','S','e','r','i','a','l','i','z','e',0};
__declspec(dllexport) const unsigned short _gfn_UVertexBufferSerialize[]             = {'U','V','e','r','t','e','x','B','u','f','f','e','r',':',':','S','e','r','i','a','l','i','z','e',0};
__declspec(dllexport) const unsigned short _gfn_UVertexStreamCOLORSerialize[]        = {'U','V','e','r','t','e','x','S','t','r','e','a','m','C','O','L','O','R',':',':','S','e','r','i','a','l','i','z','e',0};
__declspec(dllexport) const unsigned short _gfn_UVertexStreamPosNormTexSerialize[]   = {'U','V','e','r','t','e','x','S','t','r','e','a','m','P','o','s','N','o','r','m','T','e','x',':',':','S','e','r','i','a','l','i','z','e',0};
__declspec(dllexport) const unsigned short _gfn_UVertexStreamUVSerialize[]           = {'U','V','e','r','t','e','x','S','t','r','e','a','m','U','V',':',':','S','e','r','i','a','l','i','z','e',0};
__declspec(dllexport) const unsigned short _gfn_UVertexStreamVECTORSerialize[]       = {'U','V','e','r','t','e','x','S','t','r','e','a','m','V','E','C','T','O','R',':',':','S','e','r','i','a','l','i','z','e',0};
__declspec(dllexport) const unsigned short _gfn_UActorChannelStaticConstructor[]     = {'U','A','c','t','o','r','C','h','a','n','n','e','l',':',':','S','t','a','t','i','c','C','o','n','s','t','r','u','c','t','o','r',0};
__declspec(dllexport) const unsigned short _gfn_UControlChannelStaticConstructor[]   = {'U','C','o','n','t','r','o','l','C','h','a','n','n','e','l',':',':','S','t','a','t','i','c','C','o','n','s','t','r','u','c','t','o','r',0};
__declspec(dllexport) const unsigned short _gfn_UFileChannelStaticConstructor[]      = {'U','F','i','l','e','C','h','a','n','n','e','l',':',':','S','t','a','t','i','c','C','o','n','s','t','r','u','c','t','o','r',0};
__declspec(dllexport) const unsigned short _gfn_AActorTwoWallAdjust[]                = {'A','A','c','t','o','r',':',':','T','w','o','W','a','l','l','A','d','j','u','s','t',0};
__declspec(dllexport) const unsigned short _gfn_TLazyArrayByteUnload[]               = {'T','L','a','z','y','A','r','r','a','y','<','B','Y','T','E','>',':',':','U','n','l','o','a','d',0};
__declspec(dllexport) const unsigned short _gfn_AActorPhysKarmaRagDollInternalDD[]   = {'A','A','c','t','o','r',':',':','p','h','y','s','K','a','r','m','a','R','a','g','D','o','l','l','_','i','n','t','e','r','n','a','l','$','D','D',0};
__declspec(dllexport) const unsigned short _gfn_AActorPhysKarmaRagDollInternalDK[]   = {'A','A','c','t','o','r',':',':','p','h','y','s','K','a','r','m','a','R','a','g','D','o','l','l','_','i','n','t','e','r','n','a','l','$','D','K',0};
__declspec(dllexport) const unsigned short _gfn_AActorPhysKarmaRagDollInternalFG[]   = {'A','A','c','t','o','r',':',':','p','h','y','s','K','a','r','m','a','R','a','g','D','o','l','l','_','i','n','t','e','r','n','a','l','$','F','G',0};
}
static volatile const void* _gfnRefs[] = {
	_gfn_FDirectionalLightMapSceneNodeCtor,
	_gfn_FPointLightMapSceneNodeCtor,
	_gfn_TLazyArrayByteDtor,
	_gfn_ABrushBuildCoords,
	_gfn_FMipmapClear,
	_gfn_ABrushCopyPosRotScaleFrom,
	_gfn_ULevelGetActorIndex,
	_gfn_ATerrainInfoGetLayerAlpha,
	_gfn_FTagsInit,
	_gfn_UTerrainSectorIsTriangleAll,
	_gfn_TLazyArrayByteLoad,
	_gfn_ABrushOldBuildCoords,
	_gfn_ULevelSummaryPostLoad,
	_gfn_UKMeshPropsSerialize,
	_gfn_UPolysSerialize,
	_gfn_UVertexBufferSerialize,
	_gfn_UVertexStreamCOLORSerialize,
	_gfn_UVertexStreamPosNormTexSerialize,
	_gfn_UVertexStreamUVSerialize,
	_gfn_UVertexStreamVECTORSerialize,
	_gfn_UActorChannelStaticConstructor,
	_gfn_UControlChannelStaticConstructor,
	_gfn_UFileChannelStaticConstructor,
	_gfn_AActorTwoWallAdjust,
	_gfn_TLazyArrayByteUnload,
	_gfn_AActorPhysKarmaRagDollInternalDD,
	_gfn_AActorPhysKarmaRagDollInternalDK,
	_gfn_AActorPhysKarmaRagDollInternalFG,
};

/*-----------------------------------------------------------------------------
	AActor event thunks & physics functions.
-----------------------------------------------------------------------------*/
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2???0FDirectionalLightMapSceneNode@@QAE@PAVUViewport@@PAVAActor@@AAVFBspSurf@@PAVFLightMap@@@Z@4QBGB=__gfn_FDirectionalLightMapSceneNodeCtor")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2???0FPointLightMapSceneNode@@QAE@PAVUViewport@@PAVAActor@@AAVFBspSurf@@PAVFLightMap@@HHHH@Z@4QBGB=__gfn_FPointLightMapSceneNodeCtor")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2???1?$TLazyArray@E@@QAE@XZ@4QBGB=__gfn_TLazyArrayByteDtor")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??BuildCoords@ABrush@@QAEMPAVFModelCoords@@0@Z@4QBGB=__gfn_ABrushBuildCoords")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Clear@FMipmap@@QAEXXZ@4QBGB=__gfn_FMipmapClear")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??CopyPosRotScaleFrom@ABrush@@UAEXPAV2@@Z@4QBGB=__gfn_ABrushCopyPosRotScaleFrom")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??GetActorIndex@ULevel@@QAEHPAVAActor@@@Z@4QBGB=__gfn_ULevelGetActorIndex")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??GetLayerAlpha@ATerrainInfo@@QAEEHHHPAVUTexture@@@Z@4QBGB=__gfn_ATerrainInfoGetLayerAlpha")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Init@FTags@@QAEXXZ@4QBGB=__gfn_FTagsInit")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??IsTriangleAll@UTerrainSector@@QAEHHHHHHE@Z@4QBGB=__gfn_UTerrainSectorIsTriangleAll")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Load@?$TLazyArray@E@@UAEXXZ@4QBGB=__gfn_TLazyArrayByteLoad")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??OldBuildCoords@ABrush@@QAEMPAVFModelCoords@@0@Z@4QBGB=__gfn_ABrushOldBuildCoords")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??PostLoad@ULevelSummary@@UAEXXZ@4QBGB=__gfn_ULevelSummaryPostLoad")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Serialize@UKMeshProps@@UAEXAAVFArchive@@@Z@4QBGB=__gfn_UKMeshPropsSerialize")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Serialize@UPolys@@UAEXAAVFArchive@@@Z@4QBGB=__gfn_UPolysSerialize")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Serialize@UVertexBuffer@@UAEXAAVFArchive@@@Z@4QBGB=__gfn_UVertexBufferSerialize")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Serialize@UVertexStreamCOLOR@@UAEXAAVFArchive@@@Z@4QBGB=__gfn_UVertexStreamCOLORSerialize")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Serialize@UVertexStreamPosNormTex@@UAEXAAVFArchive@@@Z@4QBGB=__gfn_UVertexStreamPosNormTexSerialize")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Serialize@UVertexStreamUV@@UAEXAAVFArchive@@@Z@4QBGB=__gfn_UVertexStreamUVSerialize")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Serialize@UVertexStreamVECTOR@@UAEXAAVFArchive@@@Z@4QBGB=__gfn_UVertexStreamVECTORSerialize")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??StaticConstructor@UActorChannel@@QAEXXZ@4QBGB=__gfn_UActorChannelStaticConstructor")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??StaticConstructor@UControlChannel@@QAEXXZ@4QBGB=__gfn_UControlChannelStaticConstructor")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??StaticConstructor@UFileChannel@@QAEXXZ@4QBGB=__gfn_UFileChannelStaticConstructor")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??TwoWallAdjust@AActor@@QAEXAAVFVector@@000M@Z@4QBGB=__gfn_AActorTwoWallAdjust")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Unload@?$TLazyArray@E@@UAEXXZ@4QBGB=__gfn_TLazyArrayByteUnload")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?DD@??physKarmaRagDoll_internal@AActor@@QAEXM@Z@4QBGB=__gfn_AActorPhysKarmaRagDollInternalDD")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?DK@??physKarmaRagDoll_internal@AActor@@QAEXM@Z@4QBGB=__gfn_AActorPhysKarmaRagDollInternalDK")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?FG@??physKarmaRagDoll_internal@AActor@@QAEXM@Z@4QBGB=__gfn_AActorPhysKarmaRagDollInternalFG")
