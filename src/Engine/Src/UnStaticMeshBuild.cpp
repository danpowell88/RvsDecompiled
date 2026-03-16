/*=============================================================================
	UnStaticMeshBuild.cpp: Static mesh objects (UStaticMesh, UStaticMeshInstance)
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#include "EnginePrivate.h"
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// Defined in UnCamera.cpp; no header declaration available.
ENGINE_API FArchive& operator<<(FArchive& Ar, FRawColorStream& V);
ENGINE_API FArchive& operator<<(FArchive& Ar, FRawIndexBuffer& V);

// --- UStaticMesh ---
IMPL_MATCH("Engine.dll", 0x10446A90)
void UStaticMesh::StaticConstructor()
{
	guard(UStaticMesh::StaticConstructor);
	// Hide the "Object" category in the editor (FName index 0x97 = NAME_Object).
	// Retail accesses UClass::HideCategories directly at UClass+0x4e8; not exposed in SDK.
	FArray* HC = (FArray*)((BYTE*)GetClass() + 0x4e8);
	INT hcIdx = HC->Add(1, 4); // 4 = sizeof(FName)
	FName* slot = (FName*)((BYTE*)HC->GetData() + hcIdx * 4);
	if (slot) new(slot) FName(NAME_Object);

	// Register UBoolProperty instances for the three collision/color flags.
	new(GetClass(), TEXT("UseSimpleLineCollision"), RF_Public) UBoolProperty(EC_CppProperty, 0x128, TEXT(""), CPF_Edit);
	new(GetClass(), TEXT("UseSimpleBoxCollision"),  RF_Public) UBoolProperty(EC_CppProperty, 0x12c, TEXT(""), CPF_Edit);
	new(GetClass(), TEXT("UseVertexColor"),         RF_Public) UBoolProperty(EC_CppProperty, 0x130, TEXT(""), CPF_Edit);

	// Create the FStaticMeshMaterial struct descriptor and register it as the
	// inner type of the Materials TArray.
	FArchive DummyAr;
	UStruct* MatStruct = new(NULL, TEXT("StaticMeshMaterial"), RF_Public) UStruct((UStruct*)NULL);
	new(MatStruct, TEXT("Material"),         RF_Public) UObjectProperty(EC_CppProperty, 0, TEXT(""), CPF_Edit, UMaterial::StaticClass());
	new(MatStruct, TEXT("EnableCollision"),  RF_Public) UBoolProperty  (EC_CppProperty, 4, TEXT(""), CPF_Edit);
	MatStruct->SetPropertiesSize(0xc);
	MatStruct->Link(DummyAr, 1);

	UArrayProperty* PA = new(GetClass(), TEXT("Materials"), RF_Public) UArrayProperty(EC_CppProperty, 0xfc, TEXT(""), 0x41);
	PA->Inner = new(PA, TEXT("StructProperty0"), RF_Public) UStructProperty(EC_CppProperty, 0, TEXT(""), CPF_Edit, MatStruct);

	// Set default values on the CDO (this is the Class Default Object here).
	*(DWORD*)((BYTE*)this + 0x128) = 0; // UseSimpleLineCollision = false
	*(DWORD*)((BYTE*)this + 0x12c) = 1; // UseSimpleBoxCollision  = true
	*(DWORD*)((BYTE*)this + 0x130) = 0; // UseVertexColor         = false
	*(DWORD*)((BYTE*)this + 0x134) = 1; // bUseSimpleKarmaCollision? = true (unidentified bool at +0x134)
	unguard;
}

IMPL_EMPTY("editor-only: rebuilds mesh collision/render data on property change")
void UStaticMesh::PostEditChange()
{
	guard(UStaticMesh::PostEditChange);
	// Retail: rebuilds the static mesh collision/render data.
	// Divergence: not fully reconstructed from Ghidra.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104472F0)
void UStaticMesh::PostLoad()
{
	guard(UStaticMesh::PostLoad);
	UObject::PostLoad();
	INT Version = *(INT*)((BYTE*)this + 0x150);

	if (Version == -1)
	{
		// Very old format (pre-serialized-version): convert indexed strip/list data to
		// FStaticMeshTriangle array at this+0x144.
		FArray* pTris = (FArray*)((BYTE*)this + 0x144);
		if (pTris->Num() == 0)
		{
			// Force-load the triangle data from the lazy-loader object at this+0x138
			void* pObj = *(void**)((BYTE*)this + 0x138);
			typedef void (__thiscall* LoadFn)(void*);
			((LoadFn)(*(INT**)pObj)[0])(pObj);
		}

		// Old section stream at this+0x58 (stride 0x14):
		//   [+0x00] INT  materialRef
		//   [+0x04] INT  type (0=list, else strip)
		//   [+0x0e] _WORD numTris  (list)
		//   [+0x10] _WORD numVerts (strip)
		//   [+0x12] _WORD firstIndex
		FArray* pSecs    = (FArray*)((BYTE*)this + 0x58);
		INT     numSecs  = pSecs->Num();
		BYTE*   pSecData = (BYTE*)pSecs->GetData();

		// Old vertex stream: *(this+0x154) -> object with TArray<OldVert> at +0x3c (stride 0x2c)
		//   OldVert: [+0x00] FVector pos, [+0x1c] FLOAT UV.U, [+0x20] FLOAT UV.V
		// Old index buffer: *(this+0x158) -> object with TArray<_WORD> at +0x30
		BYTE* pRD      = *(BYTE**)((BYTE*)this + 0x154);
		BYTE* pVerts   = *(BYTE**)(pRD + 0x3c);
		BYTE* pIBObj   = *(BYTE**)((BYTE*)this + 0x158);
		_WORD* pIndices = *(_WORD**)(pIBObj + 0x30);

		for (INT si = 0; si < numSecs; si++)
		{
			BYTE* pSec   = pSecData + si * 0x14;
			INT  matRef  = *(INT* )pSec;
			INT  secType = *(INT* )(pSec + 0x04);
			_WORD firstI  = *(_WORD*)(pSec + 0x12);

			if (secType == 0)
			{
				// Triangle list
				_WORD numTris = *(_WORD*)(pSec + 0x0e);
				for (INT t = 0; t < (INT)numTris; t++)
				{
					DWORD vi[3] = {
						pIndices[firstI + t * 3 + 0],
						pIndices[firstI + t * 3 + 1],
						pIndices[firstI + t * 3 + 2]
					};
					INT   idx = pTris->Add(1, 0x104);
					BYTE* pT  = (BYTE*)pTris->GetData() + idx * 0x104;
					if (pT)
					{
						// Placement-construct the 3 vertex position FVectors
						new ((FVector*)(pT + 0x00)) FVector();
						new ((FVector*)(pT + 0x0c)) FVector();
						new ((FVector*)(pT + 0x18)) FVector();
					}
					*(INT*)(pT + 0xfc) = matRef;
					*(INT*)(pT + 0xf4) = 0; // bSelected
					*(INT*)(pT + 0xf8) = 1; // bTwoSided
					for (INT v = 0; v < 3; v++)
					{
						BYTE* pV = pVerts + vi[v] * 0x2c;
						*(FLOAT*)(pT + v * 0x0c + 0x00) = *(FLOAT*)(pV + 0x00);
						*(FLOAT*)(pT + v * 0x0c + 0x04) = *(FLOAT*)(pV + 0x04);
						*(FLOAT*)(pT + v * 0x0c + 0x08) = *(FLOAT*)(pV + 0x08);
						*(FLOAT*)(pT + v * 0x40 + 0x24) = *(FLOAT*)(pV + 0x1c); // UV.U
						*(FLOAT*)(pT + v * 0x40 + 0x28) = *(FLOAT*)(pV + 0x20); // UV.V
						*(DWORD*)(pT + v * 0x04 + 0xe4) = 0xffffffff; // SmoothingMask
					}
				}
			}
			else
			{
				// Triangle strip -- section[0x10] (INT* offset 4 = byte offset 0x10) = numVerts
				_WORD numVerts = *(_WORD*)(pSec + 0x10);
				for (INT j = 0; j < (INT)numVerts; j++)
				{
					// Alternating winding to maintain consistent front-face across strips
					DWORD iv0, iv1;
					if ((j & 1) == 0)
					{
						iv0 = pIndices[j + firstI];
						iv1 = pIndices[j + firstI + 1];
					}
					else
					{
						iv0 = pIndices[j + firstI + 1];
						iv1 = pIndices[j + firstI];
					}
					DWORD iv2 = pIndices[j + firstI + 2];
					// Skip degenerate triangles (collapsed strip seams)
					if (iv0 == iv1 || iv1 == iv2 || iv0 == iv2)
						continue;

					INT   idx = pTris->Add(1, 0x104);
					BYTE* pT  = (BYTE*)pTris->GetData() + idx * 0x104;
					if (pT)
						new ((FStaticMeshTriangle*)pT) FStaticMeshTriangle();
					*(INT*)(pT + 0xfc) = matRef;
					*(INT*)(pT + 0xf4) = 0;
					*(INT*)(pT + 0xf8) = 1;
					DWORD vi[3] = { iv0, iv1, iv2 };
					for (INT v = 0; v < 3; v++)
					{
						BYTE* pV = pVerts + vi[v] * 0x2c;
						*(FLOAT*)(pT + v * 0x0c + 0x00) = *(FLOAT*)(pV + 0x00);
						*(FLOAT*)(pT + v * 0x0c + 0x04) = *(FLOAT*)(pV + 0x04);
						*(FLOAT*)(pT + v * 0x0c + 0x08) = *(FLOAT*)(pV + 0x08);
						*(FLOAT*)(pT + v * 0x40 + 0x24) = *(FLOAT*)(pV + 0x1c);
						*(FLOAT*)(pT + v * 0x40 + 0x28) = *(FLOAT*)(pV + 0x20);
						*(DWORD*)(pT + v * 0x04 + 0xe4) = 0xffffffff;
					}
				}
			}
		}
	}

	// Always clear old render-data pointers (even if Version != -1)
	*(void**)((BYTE*)this + 0x154) = NULL;
	*(void**)((BYTE*)this + 0x158) = NULL;
	*(void**)((BYTE*)this + 0x15c) = NULL;

	// Version in [0..6]: convert old poly-flags field to material references
	if (Version != -1 && Version < 7)
	{
		FArray* pTris = (FArray*)((BYTE*)this + 0x144);
		if (pTris->Num() == 0)
		{
			void* pObj = *(void**)((BYTE*)this + 0x138);
			typedef void (__thiscall* LoadFn)(void*);
			((LoadFn)(*(INT**)pObj)[0])(pObj);
		}
		BYTE*      tData    = (BYTE*)pTris->GetData();
		INT        nTris    = pTris->Num();
		void*      lastFP   = NULL;
		UMaterial* lastMat  = NULL;
		UMaterial* convMat  = NULL;
		for (INT t = 0; t < nTris; t++)
		{
			BYTE*      pT     = tData + t * 0x104;
			UMaterial* triMat = *(UMaterial**)(pT + 0xfc);
			if (triMat)
			{
				void* curFP = *(void**)(pT + 0x100);
				if (triMat != lastMat || curFP != lastFP)
				{
					convMat  = triMat->ConvertPolyFlagsToMaterial(triMat, *(DWORD*)(pT + 0x100));
					triMat   = *(UMaterial**)(pT + 0xfc); // re-read after call
					lastFP   = *(void**)(pT + 0x100);
					lastMat  = triMat;
				}
				if (triMat != convMat)
				{
					*(UMaterial**)(pT + 0xfc) = convMat;
					*(DWORD*)    (pT + 0x100) = 0;
				}
			}
		}
	}

	// Version < 8: rebuild Materials section list (this+0xfc, stride 0xc) then Build()
	if (Version < 8)
	{
		FArray* pTris = (FArray*)((BYTE*)this + 0x144);
		if (pTris->Num() == 0)
		{
			void* pObj = *(void**)((BYTE*)this + 0x138);
			typedef void (__thiscall* LoadFn)(void*);
			((LoadFn)(*(INT**)pObj)[0])(pObj);
		}
		BYTE*  tData         = (BYTE*)pTris->GetData();
		INT    nTris         = pTris->Num();
		INT*   pLastMatEntry = NULL;
		INT    secIndex      = (INT)0xffffffff;
		FArray* pMats        = (FArray*)((BYTE*)this + 0xfc);
		for (INT t = 0; t < nTris; t++)
		{
			BYTE* pT = tData + t * 0x104;
			if (!pLastMatEntry || *(INT*)(pT + 0xfc) != *pLastMatEntry)
			{
				secIndex      = pMats->Num();
				INT newSlot   = pMats->Add(1, 0x0c);
				pLastMatEntry = (INT*)((BYTE*)pMats->GetData() + newSlot * 0x0c);
				if (pLastMatEntry)
				{
					pLastMatEntry[0] = *(INT*)(pT + 0xfc); // Material
					pLastMatEntry[1] = 1;
					pLastMatEntry[2] = 1;
				}
			}
			*(INT*)(pT + 0xf0) = secIndex;
			*(INT*)(pT + 0xfc) = 0;
		}
		Build();
	}
	unguard;
}

// (merged from earlier occurrence)
IMPL_DIVERGE("permanent: FUN_104487d0/FUN_10448ba0 (OPCODE BVH node test/traverse helpers) absent from Ghidra decompilation — likely in OPCODE binary-only library region; BVH traversal permanently unimplementable; Ghidra 0x1044CDA0")
void UStaticMesh::TriangleSphereQuery(AActor *,FSphere &,TArray<FStaticMeshCollisionTriangle *> &)
{
	guard(UStaticMesh::TriangleSphereQuery);
	// Retail: uses Actor->WorldToLocal() to transform sphere, then traverses the OPCODE
	// collision BVH tree at this+0x124, collecting triangles that overlap the sphere.
	// DIVERGENCE: BVH traversal helpers (FUN_104487d0, FUN_10448ba0) are unresolved.
	unguard;
}
IMPL_EMPTY("editor tool: builds static mesh geometry and collision data")
void UStaticMesh::Build()
{
	guard(UStaticMesh::Build);
	// Retail: builds geometry/collision data for the static mesh.
	// Divergence: not fully reconstructed from Ghidra.
	unguard;
}
IMPL_MATCH("Engine.dll", 0x1031C9F0)
UMaterial * UStaticMesh::GetSkin(AActor* Owner, int SkinIndex)
{
	guard(UStaticMesh::GetSkin);
	// Ghidra 0x1c9f0, 69b.
	// 1. Try Owner->GetSkin(SkinIndex) via vtable[0xa0/4 = 40].
	// 2. Fallback: Materials TArray at this+0xfc, stride 0xc, UMaterial* at +0.
	// 3. Final fallback: FUN_10317670(UMaterial CDO) → result+0x30 = engine default.
	typedef UMaterial* (__thiscall* GetSkinFn)(AActor*, INT);
	UMaterial* pSkin = ((GetSkinFn)(*(INT*)(*(INT*)Owner + 0xa0)))(Owner, SkinIndex);
	if (pSkin == NULL)
	{
		BYTE* materialsData = (BYTE*)*(INT*)((BYTE*)this + 0xfc);
		if (materialsData != NULL)
			pSkin = *(UMaterial**)(materialsData + SkinIndex * 0x0c);
	}
	if (pSkin == NULL)
	{
		// Ghidra: GetDefaultObject(&UMaterial::PrivateStaticClass) + FUN_10317670 + read +0x30
		UObject* defObj = UMaterial::StaticClass()->GetDefaultObject();
		typedef INT (__thiscall *TFun10317670)(UObject*);
		INT r = ((TFun10317670)0x10317670)(defObj);
		pSkin = *(UMaterial**)(r + 0x30);
	}
	return pSkin;
	unguard;
}
IMPL_MATCH("Engine.dll", 0x104478b0)
FTags * UStaticMesh::GetTag(FString Name)
{
	guard(UStaticMesh::GetTag);
	// Ghidra 0x1478b0, 85b: linear search of TArray<FTags> at this+0x17c (stride 0x3c).
	// Each FTags entry has FString TagString at +0x30. Returns pointer to entry or NULL.
	FArray* tagArr = (FArray*)((BYTE*)this + 0x17c);
	INT n = tagArr->Num();
	for (INT i = 0; i < n; i++)
	{
		BYTE* entry = (BYTE*)*(INT*)tagArr + i * 0x3c;
		if (*(FString*)(entry + 0x30) == Name)
			return (FTags*)entry;
	}
	return NULL;
	unguard;
}
IMPL_MATCH("Engine.dll", 0x10449DE0)
void UStaticMesh::Serialize(FArchive& Ar)
{
	guard(UStaticMesh::Serialize);

	// Base class call (version-gated: pre-v85 omits UPrimitive fields)
	if (Ar.Ver() < 0x55)
		UObject::Serialize(Ar);
	else
		UPrimitive::Serialize(Ar);

	// Pre-v92: old vertex-buffer and index-buffer stored as UObject* refs
	if (Ar.Ver() < 0x5c)
		(Ar << *(UObject**)((BYTE*)this + 0x154)) << *(UObject**)((BYTE*)this + 0x158);

	// Sections TArray (stride 0x14) + FBox bounds (6 floats + 1-bit valid flag)
	{
		typedef FArchive* (__cdecl* FnSec)(FArchive*, FArray*);
		typedef FArchive* (__cdecl* FnBnd)(FArchive*, void*);
		FArchive* pS = ((FnSec)0x10449c90)(&Ar, (FArray*)((BYTE*)this + 0x58));
		((FnBnd)0x10301400)(pS, (BYTE*)this + 0x2c);
	}

	// Pre-v74: old null object ref (just consume/emit the slot)
	if (Ar.Ver() < 0x4a)
	{
		UObject* tmp = NULL;
		Ar << tmp;
	}

	// Pre-v92: old vertex-stream TArray + FCoords (48-byte rotation matrix), then destruct
	if (Ar.Ver() < 0x5c)
	{
		BYTE tmpArr[20];    appMemzero(tmpArr,    sizeof(tmpArr));
		BYTE tmpCoords[48]; appMemzero(tmpCoords, sizeof(tmpCoords));
		typedef FArchive* (__cdecl*    FnDE0)(FArchive*, FArray*);
		typedef FArchive* (__cdecl*    FnCBA)(FArchive*, void*);
		typedef void      (__thiscall* FnDtr)(FArray*);
		FArchive* pA = ((FnDE0)0x10448de0)(&Ar, (FArray*)tmpArr);
		((FnCBA)0x103cbaa0)(pA, tmpCoords);
		((FnDtr)0x1033b1e0)((FArray*)tmpArr);
	}

	if (Ar.Ver() > 0x49) // >= v74
	{
		// v74..v111: old per-section color-stream TArray (load then destruct)
		if (Ar.Ver() < 0x70)
		{
			BYTE tmpArr[20]; appMemzero(tmpArr, sizeof(tmpArr));
			typedef FArchive* (__cdecl*    Fn10448f70)(FArchive*, FArray*);
			typedef void      (__thiscall* Fn10448f20)(FArray*);
			((Fn10448f70)0x10448f70)(&Ar, (FArray*)tmpArr);
			((Fn10448f20)0x10448f20)((FArray*)tmpArr);
		}
		// v74..v91: obsolete DWORD field
		if (Ar.Ver() < 0x5c)
		{
			DWORD tmp = 0;
			Ar.ByteOrderSerialize(&tmp, 4);
		}
	}

	// v112+: main render streams
	if (Ar.Ver() > 0x6f)
	{
		typedef FArchive* (__cdecl* FnVerts)(FArchive*, FArray*);
		typedef FArchive* (__cdecl* FnUVStr)(FArchive*, FArray*);
		typedef FArchive* (__cdecl* FnColl )(FArchive*, FArray*);
		typedef FArchive* (__cdecl* FnNodes)(FArchive*, FArray*);
		// FUN_103243e0: serialize TArray<FStaticMeshVertex> (stride 0x18) at +0x68
		// Returns FArchive* (may be a lazy sub-archive)
		FArchive* pC = ((FnVerts)0x103243e0)(&Ar, (FArray*)((BYTE*)this + 0x68));
		pC->ByteOrderSerialize((BYTE*)this + 0x7c, 4);
		*pC << *(FRawColorStream*)((BYTE*)this + 0x80);
		*pC << *(FRawColorStream*)((BYTE*)this + 0x9c);
		// FUN_1034f860: serialize TArray<FStaticMeshUVStream> (stride 0x20) at +0xb8
		pC = ((FnUVStr)0x1034f860)(pC, (FArray*)((BYTE*)this + 0xb8));
		*pC << *(FRawIndexBuffer*)((BYTE*)this + 0xc4);
		*pC << *(FRawIndexBuffer*)((BYTE*)this + 0xe0);
		// Serialize collision model/tree UObject* ref at +0x120
		*pC << *(UObject**)((BYTE*)this + 0x120);
		// FUN_10448640: TArray<FStaticMeshCollisionTriangle> (stride 0x54) at +0x108
		FArchive* pC2 = ((FnColl)0x10448640)(pC, (FArray*)((BYTE*)this + 0x108));
		// FUN_104487b0: TArray<collision nodes> (stride 0x2c) at +0x114
		((FnNodes)0x104487b0)(pC2, (FArray*)((BYTE*)this + 0x114));
		// v112..v113: collision flags were per-mesh; v114+ they moved to UObject properties
		if (Ar.Ver() < 0x72)
		{
			Ar.ByteOrderSerialize((BYTE*)this + 0x128, 4); // UseSimpleLineCollision
			Ar.ByteOrderSerialize((BYTE*)this + 0x12c, 4); // UseSimpleBoxCollision
			Ar.ByteOrderSerialize((BYTE*)this + 0x130, 4); // UseVertexColor
		}
	}

	// v77..v91: old field at +0x15c (serialized as UObject* ref)
	if (Ar.Ver() > 0x4c && Ar.Ver() < 0x5c)
		Ar << *(UObject**)((BYTE*)this + 0x15c);

	// Triangle data
	if (Ar.Ver() > 0x4e) // >= v79
	{
		FArray* pSrcTris = (FArray*)((BYTE*)this + 0x144);
		if (Ar.Ver() < 0x61) // pre-v97: old flat format
		{
			// FUN_1031ec10 (thiscall, ECX=pTmp, param=pSrcTris):
			//   deep-copies source TArray into temp buffer for serialization
			BYTE tmpBuf[20]; // matches Ghidra's local_28 [5 * FArchive*]
			FArray* pTmp = (FArray*)tmpBuf;
			typedef void      (__thiscall* FnCopy)(FArray*, INT*);
			typedef FArchive* (__cdecl*    FnSer )(FArchive*, FArray*);
			typedef void      (__cdecl*    FnMcpy)(void*, void*, INT);
			typedef void      (__thiscall* FnDtor)(FArray*);
			((FnCopy)0x1031ec10)(pTmp, (INT*)pSrcTris);
			((FnSer )0x1032dec0)(&Ar, pTmp);
			if (Ar.IsLoading())
			{
				INT count = pTmp->Num();
				pSrcTris->Empty(0x104, count);
				pSrcTris->Add(count, 0x104);
				((FnMcpy)0x10301050)(pSrcTris->GetData(), pTmp->GetData(), count * 0x104);
			}
			((FnDtor)0x10324860)(pTmp);
		}
		else // v97+: lazy-loaded via FLazyLoader at +0x138
		{
			INT savedLazy = GLazyLoad;
			GLazyLoad = 1;
			typedef FArchive* (__cdecl* FnLazy)(FArchive*, void*);
			((FnLazy)0x10448b20)(&Ar, (BYTE*)this + 0x138);
			GLazyLoad = savedLazy;
		}
	}

	// Serialized format-version stamp at +0x150
	if (Ar.Ver() < 0x51)
		*(INT*)((BYTE*)this + 0x150) = -1;
	else
		Ar.ByteOrderSerialize((BYTE*)this + 0x150, 4);

	// v100+: Karma/physics body ref at +0x160
	if (Ar.Ver() > 99)
		Ar << *(UObject**)((BYTE*)this + 0x160);

	// LicenseeVer > 1: FTags array at +0x17c (stride 0x3c)
	if (Ar.LicenseeVer() > 1)
	{
		typedef FArchive* (__cdecl* FnTags)(FArchive*, FArray*);
		((FnTags)0x10448520)(&Ar, (FArray*)((BYTE*)this + 0x17c));
	}

	unguard;
}
IMPL_DIVERGE("permanent: FUN_104487d0/FUN_10448ba0 (OPCODE BVH ray-triangle traversal helpers) absent from Ghidra decompilation; permanently unimplementable; returns 1 (no hit); Ghidra 0x1044EB60")
int UStaticMesh::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	guard(UStaticMesh::LineCheck);
	// Retail: transforms ray to local space, traverses OPCODE BVH collision tree at +0x124,
	// tests each leaf triangle with ray-plane intersection, fills FCheckResult on hit.
	// DIVERGENCE: BVH helpers (FUN_104487d0, FUN_10448ba0) are unresolved.
	return 1; // no hit
	unguard;
}
IMPL_DIVERGE("permanent: FUN_104487d0/FUN_10448ba0 (OPCODE BVH point-overlap helpers) absent from Ghidra decompilation; permanently unimplementable; returns 1 (no overlap); Ghidra 0x1044EF40")
int UStaticMesh::PointCheck(FCheckResult &,AActor *,FVector,FVector,DWORD)
{
	guard(UStaticMesh::PointCheck);
	// Retail: transforms point+extent to local space, traverses OPCODE BVH tree at +0x124,
	// tests each leaf triangle for overlap with the swept sphere.
	// DIVERGENCE: BVH helpers (FUN_104487d0, FUN_10448ba0) are unresolved.
	return 1; // no overlap
	unguard;
}
IMPL_MATCH("Engine.dll", 0x104469d0)
void UStaticMesh::Destroy()
{
	// Retail: 0x104469d0.Calls FUN_103582d0(this) to release the static mesh collision
	// node tree and triangle arrays at this+0x164. Then calls UObject::Destroy.
	typedef void (__cdecl *FreeMeshFn)(UStaticMesh*);
	((FreeMeshFn)0x103582d0)(this);
	UObject::Destroy();
}
IMPL_MATCH("Engine.dll", 0x1044c130)
FBox UStaticMesh::GetCollisionBoundingBox(const AActor* Actor) const
{
	// Ghidra 0x1044c130: if actor flag [0x2a]&0x400000 == 0, transform mesh bbox (this+0x2c)
	// by Actor->LocalToWorld(), then if (this+0x120 != NULL) call vtable[29] on model to get
	// its bbox and merge via FBox::operator+=.
	if (Actor && !(((const DWORD*)Actor)[0x2a] & 0x400000))
	{
		FBox result = (*(const FBox*)((const BYTE*)this + 0x2c)).TransformBy(Actor->LocalToWorld());
		void* model = *(void**)((const BYTE*)this + 0x120);
		if (model)
		{
			// vtable[0x74/4=29] on the model object: returns FBox via hidden ptr, no explicit params.
			FBox modelBBox(0);
			typedef void (__thiscall* GetBBoxFn)(void*, FBox*);
			((GetBBoxFn)(*(INT*)(*(INT*)model + 0x74)))(model, &modelBBox);
			result += modelBBox;
		}
		return result;
	}
	return UPrimitive::GetCollisionBoundingBox(Actor);
}
IMPL_MATCH("Engine.dll", 0x1046ccb0)
FVector UStaticMesh::GetEncroachCenter(AActor * Actor)
{
	// Ghidra 0x16ccb0: calls vtable[0x74/4]=GetCollisionBoundingBox(Actor), then FBox::GetCenter()
	// shares address with UModel::GetEncroachCenter and UProjectorPrimitive::GetEncroachCenter
	return GetCollisionBoundingBox(Actor).GetCenter();
}
IMPL_MATCH("Engine.dll", 0x10304990)
FVector UStaticMesh::GetEncroachExtent(AActor * Actor)
{
	// Ghidra 0x4990: calls vtable[0x74/4]=GetCollisionBoundingBox(Actor), then FBox::GetExtent()
	// shares address with UModel::GetEncroachExtent and UProjectorPrimitive::GetEncroachExtent
	return GetCollisionBoundingBox(Actor).GetExtent();
}
IMPL_MATCH("Engine.dll", 0x10146a50)
FBox UStaticMesh::GetRenderBoundingBox(const AActor*)
{
	// Ghidra 0x146a50: REP MOVSD 7 DWORDs (28 bytes = FBox) from this+0x2C
	// shares address with UModel::GetRenderBoundingBox
	return *(FBox*)((BYTE*)this + 0x2C);
}
IMPL_MATCH("Engine.dll", 0x10446a70)
FSphere UStaticMesh::GetRenderBoundingSphere(const AActor*)
{
	// Retail: 23b. Copy-constructs FSphere from this+0x48.
	return *(FSphere*)((BYTE*)this + 0x48);
}
IMPL_EMPTY("editor tool: computes per-vertex lighting bake for static mesh")
void UStaticMesh::Illuminate(AActor *,int)
{
	guard(UStaticMesh::Illuminate);
	// Retail: computes per-vertex lighting for the static mesh.
	// Divergence: not fully reconstructed from Ghidra.
	unguard;
}


// --- UStaticMeshInstance ---
IMPL_MATCH("Engine.dll", 0x10449BB0)
void UStaticMeshInstance::Serialize(FArchive& Ar)
{
	guard(UStaticMeshInstance::Serialize);
	UObject::Serialize(Ar);
	if (Ar.Ver() < 0x70)
	{
		// Old format: TArray<FStaticMeshColorStream> (stride 0x1c) — load into temp then discard
		BYTE tmpBuf[12]; appMemzero(tmpBuf, sizeof(tmpBuf));
		typedef FArchive* (__cdecl*    Fn10449a90)(FArchive*, FArray*);
		typedef void      (__thiscall* Fn10449a40)(FArray*);
		((Fn10449a90)0x10449a90)(&Ar, (FArray*)tmpBuf);
		((Fn10449a40)0x10449a40)((FArray*)tmpBuf);
	}
	else
	{
		Ar << *(FRawColorStream*)((BYTE*)this + 0x38);
	}
	// v110+: per-triangle light-info array at +0x2c (TArray stride 0x14)
	if (Ar.Ver() > 0x6d)
	{
		typedef FArchive* (__cdecl* Fn10448de0)(FArchive*, FArray*);
		((Fn10448de0)0x10448de0)(&Ar, (FArray*)((BYTE*)this + 0x2c));
	}
	unguard;
}

IMPL_DIVERGE("permanent: Ghidra 0x10446b40 is absent from retail export table; FUN_10449ee0 (triangle clip) and FUN_10448ca0 (OPCODE BVH gather) absent from Engine.dll exports — not callable")
void UStaticMeshInstance::AttachProjectorClipped(AActor *,AProjector *)
{
	guard(UStaticMeshInstance::AttachProjectorClipped);
	// Retail: gathers triangles from the OPCODE BVH that intersect the projector frustum,
	// clips each against 6 frustum planes, builds an index buffer, and appends to per-instance
	// projector list at this+0x54. FUN_10449ee0 (clip) and FUN_10448ca0 (BVH gather) unresolved.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10448470)
void UStaticMeshInstance::DetachProjectorClipped(AProjector* param_1)
{
	guard(UStaticMeshInstance::DetachProjectorClipped);
	// Ghidra 0x148470: search per-instance projector list (FArray at this+0x54, stride 0x28)
	// for element matching param_1's render info pointer, then remove and clean up.
	FArray* projArr = (FArray*)((BYTE*)this + 0x54);
	INT count = projArr->Num();
	if (count > 0)
	{
		INT idx = 0;
		INT offset = 0;
		INT projId = *(INT*)((BYTE*)param_1 + 0x48c);
		while (*(INT*)(offset + *(INT*)projArr) != projId)
		{
			idx++;
			offset += 0x28;
			if (projArr->Num() <= idx)
				return;
		}
		FRawIndexBuffer* rib = *(FRawIndexBuffer**)(idx * 0x28 + 4 + *(INT*)projArr);
		if (rib != NULL)
		{
			rib->~FRawIndexBuffer();
			GMalloc->Free(rib);
			*(DWORD*)(idx * 0x28 + 4 + *(INT*)projArr) = 0;
		}
		INT* refCount = *(INT**)((BYTE*)param_1 + 0x48c);
		*refCount -= 1;
		if (*refCount == 0)
		{
			// FUN_103719b0: cleanup/dtor for the render info block (same as in AProjector::Detach)
			typedef void (__cdecl* CleanupFn)();
			((CleanupFn)0x103719b0)();
			GMalloc->Free(refCount);
		}
		// FUN_1031fda0: FArray::Remove(index, count, stride=0x28) — removes entry from list
		typedef void (__thiscall* RemoveFn)(FArray*, INT, INT, INT);
		((RemoveFn)0x1031fda0)(projArr, idx, 1, 0x28);
	}
	unguard;
}

// --- FOrientation ---
IMPL_MATCH("Engine.dll", 0x103019d0)
FOrientation::FOrientation()
{
	*(INT*)&_Data[0x00] = 2;
	*(INT*)&_Data[0x04] = 0;
	*(INT*)&_Data[0x08] = 0;
	*(INT*)&_Data[0x0C] = 0;
	*(INT*)&_Data[0x10] = 0;
	*(INT*)&_Data[0x14] = 0;
	*(INT*)&_Data[0x18] = 0;
	*(FRotator*)&_Data[0x28] = FRotator(0,0,0);
}

IMPL_MATCH("Engine.dll", 0x10301a00)
FOrientation& FOrientation::operator=(FOrientation Other)
{
	// Ghidra 0x1a00: FOrientation passed by value as 13 DWORD params on stack.
	// Each DWORD assigned to this in the non-sequential order Ghidra shows (register allocation).
	*(INT*)&_Data[0x00] = *(INT*)&Other._Data[0x00];
	*(INT*)&_Data[0x04] = *(INT*)&Other._Data[0x04];
	*(INT*)&_Data[0x08] = *(INT*)&Other._Data[0x08];
	*(INT*)&_Data[0x28] = *(INT*)&Other._Data[0x28];
	*(INT*)&_Data[0x2c] = *(INT*)&Other._Data[0x2c];
	*(INT*)&_Data[0x30] = *(INT*)&Other._Data[0x30];
	*(INT*)&_Data[0x1c] = *(INT*)&Other._Data[0x1c];
	*(INT*)&_Data[0x20] = *(INT*)&Other._Data[0x20];
	*(INT*)&_Data[0x24] = *(INT*)&Other._Data[0x24];
	*(INT*)&_Data[0x18] = *(INT*)&Other._Data[0x18];
	*(INT*)&_Data[0x10] = *(INT*)&Other._Data[0x10];
	*(INT*)&_Data[0x0c] = *(INT*)&Other._Data[0x0c];
	*(INT*)&_Data[0x14] = *(INT*)&Other._Data[0x14];
	return *this;
}

IMPL_MATCH("Engine.dll", 0x10301a70)
int FOrientation::operator!=(FOrientation const & Other) const
{
	// Ghidra 0x1a70: return (DWORD)(*(int*)(this+0x18) != *(int*)(param_1+0x18))
	return *(INT*)&_Data[0x18] != *(INT*)&Other._Data[0x18];
}


// --- FRebuildOptions ---
IMPL_MATCH("Engine.dll", 0x10301cf0)
FRebuildOptions::FRebuildOptions(FRebuildOptions const & Other)
	: Name(Other.Name)
{
	appMemcpy(Options, Other.Options, sizeof(Options));
}

IMPL_MATCH("Engine.dll", 0x10301cf0)
FRebuildOptions::FRebuildOptions()
{
	Options[0] = 2;    // 0x0C
	Options[1] = 79;   // 0x10
	Options[2] = 15;   // 0x14
	Options[3] = 70;   // 0x18
	Options[4] = 7;    // 0x1C
	Options[5] = 0;    // 0x20
	Options[6] = 0;    // 0x24
	Options[7] = 1;    // 0x28
	Name = TEXT("Default");
}

IMPL_EMPTY("FString member destructor handles cleanup automatically")
FRebuildOptions::~FRebuildOptions()
{
	// Name's implicit destructor handles FString cleanup
}

IMPL_MATCH("Engine.dll", 0x103188d0)
FRebuildOptions FRebuildOptions::operator=(FRebuildOptions Other)
{
	// Ghidra 0x188d0: FString assignment first, then 8 Options in non-sequential Ghidra order
	// (0,1,3,2,4,6,5,7 — register allocation artefact), then constructs return copy.
	Name = Other.Name;
	Options[0] = Other.Options[0];   // this+0x0c
	Options[1] = Other.Options[1];   // this+0x10
	Options[3] = Other.Options[3];   // this+0x18
	Options[2] = Other.Options[2];   // this+0x14
	Options[4] = Other.Options[4];   // this+0x1c
	Options[6] = Other.Options[6];   // this+0x24
	Options[5] = Other.Options[5];   // this+0x20
	Options[7] = Other.Options[7];   // this+0x28
	return *this;
}

IMPL_MATCH("Engine.dll", 0x10301cd0)
FString FRebuildOptions::GetName()
{
	return Name;
}

IMPL_MATCH("Engine.dll", 0x103fd220)
void FRebuildOptions::Init()
{
	Options[0] = 2;
	Options[1] = 79;
	Options[2] = 15;
	Options[3] = 70;
	Options[4] = 7;
	Options[5] = 0;
	Options[6] = 0;
	Options[7] = 1;
}


// --- FTags ---
IMPL_MATCH("Engine.dll", 0x10302ed0)
FTags::FTags(FTags const &Other)
{
	// Ghidra 0x2ed0:bitwise copy of first 0x30 bytes (TArrays here are shallow/borrowed), then FString copy at +0x30
	appMemcpy(this, &Other, 0x30);
	new ((BYTE*)this + 0x30) FString(*(const FString*)((const BYTE*)&Other + 0x30));
}

IMPL_MATCH("Engine.dll", 0x10302ea0)
FTags::FTags()
{
	// Zero first 0x30 bytes;initialize owned FString at +0x30 to empty
	appMemzero(this, 0x30);
	new ((BYTE*)this + 0x30) FString();
}

IMPL_MATCH("Engine.dll", 0x10302ec0)
FTags::~FTags()
{
	// Ghidra 0x10302ec0:only ~FString at +0x30; TArrays in first 0x30 bytes are not destructed (shallow/borrowed)
	((FString*)((BYTE*)this + 0x30))->~FString();
}

IMPL_MATCH("Engine.dll", 0x10302f00)
FTags& FTags::operator=(const FTags& Other)
{
	// Ghidra 0x2f00:12 DWORDs at +0..+2F (no vtable), then FString at +0x30
	appMemcpy(this, &Other, 0x30);
	*(FString*)((BYTE*)this + 0x30) = *(const FString*)((const BYTE*)&Other + 0x30);
	return *this;
}

IMPL_MATCH("Engine.dll", 0x10302e20)
void FTags::Init()
{
	guard(FTags::Init);
	*(FString*)((BYTE*)this + 0x30) = FString(TEXT("")); // Ghidra: FString at +0x30 = empty
	unguard;
}



// ============================================================================
// FRebuildTools implementations
// (moved from EngineStubs.cpp)
// ============================================================================

// ?GetCurrent@FRebuildTools@@QAEPAVFRebuildOptions@@XZ
IMPL_MATCH("Engine.dll", 0x10301d40)
FRebuildOptions * FRebuildTools::GetCurrent() {
	// Ghidra 0x1d40: return *(ulong*)this (first DWORD = current options ptr)
	// shares address with FColor::operator unsigned long and FColor::TrueColor
	return *(FRebuildOptions**)this;
}

// ?GetFromName@FRebuildTools@@QAEPAVFRebuildOptions@@VFString@@@Z
IMPL_MATCH("Engine.dll", 0x103fd460)
FRebuildOptions * FRebuildTools::GetFromName(FString p0)
{
	FRebuildOptions* data = *(FRebuildOptions**)((BYTE*)this + 4);
	INT count = *(INT*)((BYTE*)this + 8);
	for (INT i = 0; i < count; i++)
	{
		FRebuildOptions* opt = (FRebuildOptions*)((BYTE*)data + i * 0x2C);
		if (opt->Name == p0)
			return opt;
	}
	return NULL;
}

// ?Save@FRebuildTools@@QAEPAVFRebuildOptions@@VFString@@@Z
// Ghidra 0x103FD770 (260b): uses FArray::Add (Core.dll 0x10101790) to append a slot,
// placement-constructs FRebuildOptions, copies current options via operator=, overrides name.
// DIVERGENCE: retail builds a temporary FRebuildOptions on the stack and assigns via
// FRebuildOptions::operator= with additional copy semantics; we copy fields directly.
IMPL_DIVERGE("permanent: editor-only rebuild tool; our field copy produces same observable result as retail stack-temp+operator= pattern; Ghidra 0x103FD770")
FRebuildOptions * FRebuildTools::Save(FString p0)
{
	guard(FRebuildTools::Save);

	FRebuildOptions* result = GetFromName(p0);
	if (!result)
	{
		FArray* arr = (FArray*)((BYTE*)this + 4);
		INT idx = arr->Add(1, 0x2C);  // FArray::Add — exported from Core.dll; resolved via import table
		result = (FRebuildOptions*)((BYTE*)arr->GetData() + idx * 0x2C);
		if (result)
			new(result) FRebuildOptions();
		// Re-read in case Add() reallocated the buffer
		result = (FRebuildOptions*)((BYTE*)arr->GetData() + (arr->Num() - 1) * 0x2C);
	}

	// Copy current options then override name with p0
	FRebuildOptions* cur = GetCurrent();
	if (cur && result)
	{
		result->Name = cur->Name;
		appMemcpy(result->Options, cur->Options, sizeof(result->Options));
	}
	result->Name = p0;
	return result;
	unguard;
}

// --- Moved from EngineStubs.cpp ---
extern ENGINE_API FRebuildTools GRebuildTools;

// ?GetIdxFromName@FRebuildTools@@QAEHVFString@@@Z
// Ghidra: same array walk as GetFromName; returns index or -1 (NOT 0 — 0 is a valid index).
IMPL_MATCH("Engine.dll", 0x103fd560)
int FRebuildTools::GetIdxFromName(FString p0)
{
	FRebuildOptions* data = *(FRebuildOptions**)((BYTE*)this + 4);
	INT count = *(INT*)((BYTE*)this + 8);
	for (INT i = 0; i < count; i++)
	{
		FRebuildOptions* opt = (FRebuildOptions*)((BYTE*)data + i * 0x2C);
		if (opt->Name == p0)
			return i;
	}
	return -1;
}
// ?Delete@FRebuildTools@@QAEXVFString@@@Z
IMPL_EMPTY("editor tool: deletes named rebuild option")
void FRebuildTools::Delete(FString p0) {}

// ?Init@FRebuildTools@@QAEXXZ
IMPL_EMPTY("editor tool: initializes rebuild tools data")
void FRebuildTools::Init() {}

// ?SetCurrent@FRebuildTools@@QAEXVFString@@@Z
IMPL_EMPTY("editor tool: sets current rebuild option by name")
void FRebuildTools::SetCurrent(FString p0) {}

// ?Shutdown@FRebuildTools@@QAEXXZ
IMPL_EMPTY("editor tool: shuts down rebuild tools")
void FRebuildTools::Shutdown() {}
IMPL_MATCH("Engine.dll", 0x10316200)
INT FStaticMeshColorStream::GetComponents(FVertexComponent* C) {
	C[0].Type = 4; C[0].Function = 3;
	return 1;
}
