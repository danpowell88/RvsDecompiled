/*=============================================================================
	EngineStubs.cpp: Linker-level stubs for all .def-exported C++ symbols
	that we have not yet reconstructed. Uses /alternatename to map each
	missing mangled symbol to a single dummy implementation so the .def
	ordinal exports resolve without needing full class method bodies.
=============================================================================*/

/*-----------------------------------------------------------------------------
	Dummy implementations that all /alternatename directives point to.
	These are extern "C" so their decorated names are predictable:
	  _dummy_stub_func   (for all function symbols)
	  _dummy_stub_data   (for all data symbols)
-----------------------------------------------------------------------------*/
extern "C" __declspec(noinline) int dummy_stub_func() { return 0; }
extern "C" void* dummy_stub_data = 0;

/*-----------------------------------------------------------------------------
	AActor event thunks & physics functions.
-----------------------------------------------------------------------------*/
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2???0FDirectionalLightMapSceneNode@@QAE@PAVUViewport@@PAVAActor@@AAVFBspSurf@@PAVFLightMap@@@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2???0FPointLightMapSceneNode@@QAE@PAVUViewport@@PAVAActor@@AAVFBspSurf@@PAVFLightMap@@HHHH@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2???1?$TLazyArray@E@@QAE@XZ@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??BuildCoords@ABrush@@QAEMPAVFModelCoords@@0@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Clear@FMipmap@@QAEXXZ@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??CopyPosRotScaleFrom@ABrush@@UAEXPAV2@@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??GetActorIndex@ULevel@@QAEHPAVAActor@@@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??GetLayerAlpha@ATerrainInfo@@QAEEHHHPAVUTexture@@@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Init@FTags@@QAEXXZ@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??IsTriangleAll@UTerrainSector@@QAEHHHHHHE@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Load@?$TLazyArray@E@@UAEXXZ@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??OldBuildCoords@ABrush@@QAEMPAVFModelCoords@@0@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??PostLoad@ULevelSummary@@UAEXXZ@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Serialize@UKMeshProps@@UAEXAAVFArchive@@@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Serialize@UPolys@@UAEXAAVFArchive@@@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Serialize@UVertexBuffer@@UAEXAAVFArchive@@@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Serialize@UVertexStreamCOLOR@@UAEXAAVFArchive@@@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Serialize@UVertexStreamPosNormTex@@UAEXAAVFArchive@@@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Serialize@UVertexStreamUV@@UAEXAAVFArchive@@@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Serialize@UVertexStreamVECTOR@@UAEXAAVFArchive@@@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??StaticConstructor@UActorChannel@@QAEXXZ@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??StaticConstructor@UControlChannel@@QAEXXZ@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??StaticConstructor@UFileChannel@@QAEXXZ@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??TwoWallAdjust@AActor@@QAEXAAVFVector@@000M@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??Unload@?$TLazyArray@E@@UAEXXZ@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?DD@??physKarmaRagDoll_internal@AActor@@QAEXM@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?DK@??physKarmaRagDoll_internal@AActor@@QAEXM@Z@4QBGB=_dummy_stub_data")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?FG@??physKarmaRagDoll_internal@AActor@@QAEXM@Z@4QBGB=_dummy_stub_data")
