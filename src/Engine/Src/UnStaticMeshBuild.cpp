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

IMPL_MATCH("Engine.dll", 0x10446e10)
void UStaticMesh::PostEditChange()
{
	guard(UStaticMesh::PostEditChange);
	// Ghidra 0x10446e10 (121b): calls UObject::PostEditChange, then iterates
	// Materials TArray at this+0xfc (stride 0xc). For each entry, compares
	// field +4 (EnableCollision) against field +8 (shadow copy). On first
	// mismatch, copies the new value and triggers Build().
	UObject::PostEditChange();
	INT i = 0;
	for (;;)
	{
		FArray* mats = (FArray*)((BYTE*)this + 0xfc);
		if (mats->Num() <= i)
			break;
		BYTE* data = (BYTE*)mats->GetData();
		BYTE* entry = data + i * 0x0c;
		INT valA = *(INT*)(entry + 4);
		if (valA != *(INT*)(entry + 8))
		{
			*(INT*)(entry + 8) = valA;
			Build();
			break;
		}
		i++;
	}
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
// Collision node layout (stride 0x2c = 44 bytes):
//   INT[0] = TriangleIndex, INT[1] = NextLeafIdx, INT[2] = LeftChildIdx, INT[3] = RightChildIdx
//   +0x10 (16 bytes in) = FBox (24 bytes: Min(12b) + Max(12b) — no IsValid in collision nodes)
// Collision triangle layout (stride 0x54 = 84 bytes):
//   +0x00: FPlane surface plane
//   +0x10, +0x20, +0x30: FPlane edge planes 0, 1, 2
//   +0x50: INT queryStamp (last sphere-query counter that visited this tri)
// DIVERGENCE: FArray bounds-check assertions use check() (expands to appFailAssert in retail
//   debug/profile; omitted in release). Functionally equivalent to retail path.
IMPL_MATCH("Engine.dll", 0x1044CDA0)
void UStaticMesh::TriangleSphereQuery(AActor* Actor, FSphere& Sphere, TArray<FStaticMeshCollisionTriangle*>& Triangles)
{
	guard(UStaticMesh::TriangleSphereQuery);

	// Step 1: build aligned bounding box from sphere, transform to local space
	FMatrix worldToLocal = Actor->WorldToLocal();
	FVector center3(Sphere.X, Sphere.Y, Sphere.Z);
	FVector radVec(Sphere.W, Sphere.W, Sphere.W);
	FBox localBox = FBox(center3 - radVec, center3 + radVec).TransformBy(worldToLocal);
	FVector center, extents;
	localBox.GetCenterAndExtents(center, extents);

	// Raw accessors for collision arrays (not exposed as named members)
	FArray* pTriArr  = (FArray*)((BYTE*)this + 0x108);  // CollisionTriangles
	FArray* pNodeArr = (FArray*)((BYTE*)this + 0x114);  // CollisionNodes

	// Increment per-query stamp so each triangle is added at most once per call
	INT queryStamp = ++(*(INT*)((BYTE*)this + 0x124));

	// BVH traversal via inline DFS stack of node indices
	// TArray<INT> auto-cleans via ~TArray when scope exits (inlines FUN_10322eb0 behaviour)
	TArray<INT> nodeStack;
	nodeStack.AddItem(0);  // root node is index 0

	while (nodeStack.Num() > 0)
	{
		INT nodeIdx = nodeStack(nodeStack.Num() - 1);
		nodeStack.Remove(nodeStack.Num() - 1);

		check(nodeIdx >= 0 && nodeIdx < pNodeArr->Num());
		INT* node = (INT*)((BYTE*)pNodeArr->GetData() + nodeIdx * 0x2c);

		INT triIdx = node[0];
		check(triIdx >= 0 && triIdx < pTriArr->Num());
		BYTE* triBase = (BYTE*)pTriArr->GetData() + triIdx * 0x54;
		FPlane* surfPlane = (FPlane*)triBase;

		// Coarse AABB rejection: node BBox is at +0x10 (node + 4 as int pointer)
		FBox* nodeBBox = (FBox*)(node + 4);
		if (!localBox.Intersect(*nodeBBox))
			continue;

		// Plane-dot distance and sphere half-extent along the splitting plane normal
		FLOAT planeDot = surfPlane->PlaneDot(center);
		FLOAT hx = extents.X * surfPlane->X; if (hx < 0.0f) hx = -hx;
		FLOAT hy = extents.Y * surfPlane->Y; if (hy < 0.0f) hy = -hy;
		FLOAT hz = extents.Z * surfPlane->Z; if (hz < 0.0f) hz = -hz;
		FLOAT halfExt = hx + hy + hz;

		if (planeDot <= -halfExt)
		{
			// Sphere entirely behind splitting plane: descend into back subtree only
			if (node[2] != -1)
				nodeStack.AddItem(node[2]);
		}
		else
		{
			if (planeDot < halfExt)
			{
				// Sphere overlaps splitting plane: test leaf triangle chain
				INT leafIdx = nodeIdx;
				while (leafIdx != -1)
				{
					INT* leafNode = (INT*)((BYTE*)pNodeArr->GetData() + leafIdx * 0x2c);
					BYTE* leafTri = (BYTE*)pTriArr->GetData() + leafNode[0] * 0x54;

					// Deduplication via query stamp
					if (*(INT*)(leafTri + 0x50) != queryStamp)
					{
						*(INT*)(leafTri + 0x50) = queryStamp;

						// Test all 3 edge planes — sphere must be inside all of them
						bool inside = true;
						for (INT e = 0; e < 3 && inside; e++)
						{
							FPlane* edgePlane = (FPlane*)(leafTri + (e + 1) * 0x10);
							FLOAT edgeDot = edgePlane->PlaneDot(center);
							FLOAT ex = extents.X * edgePlane->X; if (ex < 0.0f) ex = -ex;
							FLOAT ey = extents.Y * edgePlane->Y; if (ey < 0.0f) ey = -ey;
							FLOAT ez = extents.Z * edgePlane->Z; if (ez < 0.0f) ez = -ez;
							if (ex + ey + ez < edgeDot)
								inside = false;
						}
						if (inside)
							Triangles.AddItem((FStaticMeshCollisionTriangle*)leafTri);
					}
					leafIdx = leafNode[1];  // next leaf in chain (-1 = end)
				}
				// Also push back subtree when sphere overlaps the region
				if (node[2] != -1)
					nodeStack.AddItem(node[2]);
			}
			// Always push front subtree when sphere is not entirely behind
			if (node[3] != -1)
				nodeStack.AddItem(node[3]);
		}
	}

	unguard;
}
IMPL_TODO("Ghidra 0x1044AD30 (3910b) fully decompiled; rebuilds vertex/index/section/collision data from source triangles at this+0x144; many internal helpers (FUN_10449ee0, FUN_10448ca0, FUN_1044a860 etc.) need decompilation")
void UStaticMesh::Build()
{
	guard(UStaticMesh::Build);
	// Retail: full static mesh geometry rebuild — clears sections/vertices/UVs/collision,
	// iterates source triangles, builds per-material sections, computes bounding box,
	// generates collision BVH tree, and creates index buffers.
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
IMPL_TODO("Ghidra 0x1044EB60 (931b): BVH traversal paths (FUN_1044c480/FUN_1044bf80 setup + FUN_1044e6e0/FUN_1044caf0 traverse) omitted; UPrimitive::LineCheck fallback and collision model (+0x120) simple-collision delegate implemented; rdtsc perf counters and hit-time epsilon adjustment omitted")
int UStaticMesh::LineCheck(FCheckResult& Result, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD TraceFlags, DWORD ExtraNodeFlags)
{
	guard(UStaticMesh::LineCheck);

	INT bBlocked = 0;

	if ( *(DWORD*)((BYTE*)Owner + 0xA8) & 0x400000 )
	{
		// bCollideActors path: delegate to UPrimitive base
		bBlocked = (UPrimitive::LineCheck(Result, Owner, End, Start, Extent, TraceFlags, ExtraNodeFlags) == 0);
	}
	else
	{
		UBOOL bZeroExtent = (Extent == FVector(0.f, 0.f, 0.f));

		// Check if we should use the simple collision model at +0x120
		extern UBOOL GUseStaticMeshSimpleCollision;
		UBOOL bUseSimple = GUseStaticMeshSimpleCollision != 0
			&& *(INT*)((BYTE*)this + 0x120) != 0
			&& !( (*(INT*)((BYTE*)this + 0x12C) == 0 || !bZeroExtent)
			    && (*(INT*)((BYTE*)this + 0x128) == 0 || bZeroExtent) )
			&& !(ExtraNodeFlags & 0x100);

		if ( !bUseSimple )
		{
			// BVH traversal path
			INT triCount = ((FArray*)((BYTE*)this + 0x114))->Num();
			if ( triCount != 0 )
			{
				// TODO: FUN_1044c480/FUN_1044bf80 (line-vs-BVH setup)
				// + FUN_1044e6e0/FUN_1044caf0 (BVH traversal + result gather)
				// Would fill Result with hit Actor/Primitive/Normal/Time on collision.
			}
		}
		else
		{
			// Simple collision model delegate: call LineCheck via vtable+0x68
			UPrimitive* CollisionModel = *(UPrimitive**)((BYTE*)this + 0x120);
			bBlocked = (CollisionModel->LineCheck(Result, Owner, End, Start, Extent, TraceFlags, ExtraNodeFlags) == 0);
		}
	}

	return bBlocked ? 0 : 1;
	unguard;
}
IMPL_TODO("Ghidra 0x1044EF40 (403b): BVH traversal path (FUN_1044c220 setup + FUN_1044e390 traverse) omitted; UPrimitive::PointCheck fallback and collision model (+0x120) delegate implemented; rdtsc perf counters omitted")
int UStaticMesh::PointCheck(FCheckResult& Result, AActor* Owner, FVector Location, FVector Extent, DWORD ExtraNodeFlags)
{
	guard(UStaticMesh::PointCheck);

	INT bBlocked = 0;

	if ( *(DWORD*)((BYTE*)Owner + 0xA8) & 0x400000 )
	{
		// bCollideActors path: delegate to UPrimitive base
		bBlocked = (UPrimitive::PointCheck(Result, Owner, Location, Extent, ExtraNodeFlags) == 0);
	}
	else if ( *(INT*)((BYTE*)this + 0x120) == 0 || *(INT*)((BYTE*)this + 0x12C) == 0 )
	{
		// No collision model or UseSimpleBoxCollision off: try BVH tree
		INT triCount = ((FArray*)((BYTE*)this + 0x114))->Num();
		if ( triCount != 0 )
		{
			// TODO: FUN_1044c220 (point-vs-BVH setup) + FUN_1044e390 (BVH traverse)
			// Would check point against collision triangle BVH and fill Result on hit.
		}
	}
	else
	{
		// Collision model exists and UseSimpleBoxCollision set: delegate
		UPrimitive* CollisionModel = *(UPrimitive**)((BYTE*)this + 0x120);
		bBlocked = (CollisionModel->PointCheck(Result, Owner, Location, Extent, ExtraNodeFlags) == 0);
	}

	return bBlocked ? 0 : 1;
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
IMPL_TODO("Ghidra 0x104492F0 (1797b) fully decompiled; iterates lights from Actor+0x32c, allocates UStaticMeshInstance, bakes per-vertex colour into FRawColorStream at instance+0x3c; needs FUN_10322eb0 (TArray cleanup) and UStaticMeshInstance constructor")
void UStaticMesh::Illuminate(AActor *,int)
{
	guard(UStaticMesh::Illuminate);
	// Retail: computes per-vertex lighting bake. Iterates light list at Actor+0x32c,
	// allocates or reuses UStaticMeshInstance at Actor+0x174, transforms bounding
	// sphere, gathers affecting lights, and writes vertex colours.
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

IMPL_DIVERGE("Ghidra 0x10447B70 (2281b): FUN_103ccb10 (projector validity check, uses rdtsc+GSecondsPerCycle timing) is called to purge stale projector entries before the triangle gather/clip loop. rdtsc-based timing is a permanent IMPL_DIVERGE category. FUN_1031fda0/FUN_1031fe20 (FArray::Remove variants) could be inlined but are moot without the projector expiry check.")
void UStaticMeshInstance::AttachProjectorClipped(AActor *,AProjector *)
{
	guard(UStaticMeshInstance::AttachProjectorClipped);
	// Retail: purges stale projector entries from this+0x54 and this+0x60,
	// checks for duplicate, gathers triangles from vertex stream sections,
	// clips each against projector frustum planes (Sutherland-Hodgman),
	// builds FRawIndexBuffer with clipped indices, appends to projector list.
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
// Ghidra 0x103FD770 (260b): uses FArray::Add to append a slot,
// placement-constructs FRebuildOptions, copies current via operator=, overrides name.
IMPL_MATCH("Engine.dll", 0x103FD770)
FRebuildOptions * FRebuildTools::Save(FString p0)
{
	guard(FRebuildTools::Save);

	FRebuildOptions* result = GetFromName(p0);
	if (!result)
	{
		FArray* arr = (FArray*)((BYTE*)this + 4);
		INT idx = arr->Add(1, 0x2C);
		result = (FRebuildOptions*)((BYTE*)arr->GetData() + idx * 0x2C);
		if (result)
			new(result) FRebuildOptions();
		result = (FRebuildOptions*)((BYTE*)arr->GetData() + (arr->Num() - 1) * 0x2C);
	}

	// Ghidra: copies *GetCurrent() into result via FRebuildOptions::operator=,
	// then overrides result->Name with p0.
	*result = *GetCurrent();
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
// Ghidra 0x103FD8B0 (120b): calls GetIdxFromName, then FUN_1031f0a0
// (TArray<FRebuildOptions>::Remove with element destructors, stride 0x2C).
IMPL_MATCH("Engine.dll", 0x103FD8B0)
void FRebuildTools::Delete(FString p0) {
	guard(FRebuildTools::Delete);
	INT idx = GetIdxFromName(p0);
	if (idx != -1)
	{
		// FUN_1031f0a0: thiscall on FArray, destructs elements then FArray::Remove(idx, 1, 0x2C)
		typedef void (__thiscall* TArrayRemoveWithDtorFn)(FArray*, INT, INT);
		((TArrayRemoveWithDtorFn)0x1031f0a0)((FArray*)((BYTE*)this + 4), idx, 1);
	}
	unguard;
}

// ?Init@FRebuildTools@@QAEXXZ
// Ghidra 0x103FD9C0 (665b): empties array, adds default FRebuildOptions, allocates
// current-options pointer, then reads "Rebuild Configs" from GConfig (UnrealEd.ini)
// to populate saved configs via FString::ParseIntoArray / appAtoi.
// GConfig vtable offsets (verified via Shutdown): +0x04 = GetInt, +0x0C = GetString(buffer).
// Reads NumItems from "Rebuild Configs"/"UnrealEd.ini", then for each Config%d parses
// comma-separated string (6 fields: Name,Opt[2],Opt[0],Opt[1],Opt[3],Opt[4]) via
// FString::ParseIntoArray(",") and stores into a new FRebuildOptions via Save().
// NOTE: FUN_1031f140 (TArray<FRebuildOptions> empty with dtors) and FUN_1031efc0
// (TArray<FString> element dtor sweep) are inlined as their template-equivalent code.
// TArray<FString> field cleanup is handled automatically by TArray<FString>::~TArray()
// since TTypeInfo<FString>::NeedsDestructor() = true (TArray::Remove calls ~T per elem).
// DIVERGENCE: retail calls GetString(TCHAR* buffer) at GConfig vtable+0x0C (slot 3);
// we call GetString(FString&) at vtable+0x10 (slot 4) for clarity. Net result identical.
IMPL_MATCH("Engine.dll", 0x103FD9C0)
void FRebuildTools::Init() {
	guard(FRebuildTools::Init);

	// Step 1: Destroy all existing FRebuildOptions elements and empty the array.
	// Inlines FUN_1031f140 (57b): loops ~FRebuildOptions() stride 0x2C, then FArray::Empty(0x2C).
	{
		FArray* arr = (FArray*)((BYTE*)this + 4);
		INT n = arr->Num();
		for (INT i = 0; i < n; i++)
		{
			FRebuildOptions* opt = (FRebuildOptions*)((BYTE*)arr->GetData() + i * 0x2C);
			opt->~FRebuildOptions();
		}
		arr->Empty(0x2C);
	}

	// Step 2: Add a default (zeroed) FRebuildOptions entry to the array.
	FArray* arr = (FArray*)((BYTE*)this + 4);
	INT idx = arr->Add(1, 0x2C);
	FRebuildOptions* defaultOpt = (FRebuildOptions*)((BYTE*)arr->GetData() + idx * 0x2C);
	if (defaultOpt)
		new(defaultOpt) FRebuildOptions();

	// Step 3: Allocate and construct the current-options pointer at this+0.
	FRebuildOptions* current = (FRebuildOptions*)GMalloc->Malloc(0x2C, TEXT("FRebuildOptions"));
	if (current)
		new(current) FRebuildOptions();
	*(FRebuildOptions**)this = current;

	// Step 4: Copy the default entry into current options.
	// Re-read defaultOpt since arr->GetData() may have changed after the Malloc above.
	defaultOpt = (FRebuildOptions*)arr->GetData();
	*GetCurrent() = *defaultOpt;

	// Step 5: Read the number of saved configs from UnrealEd.ini.
	INT NumItems = 0;
	GConfig->GetInt(TEXT("Rebuild Configs"), TEXT("NumItems"), NumItems, TEXT("UnrealEd.ini"));

	// Step 6: Read each saved config entry and populate the options array.
	// Saved format (from Shutdown): "<Name>,<Opt[2]>,<Opt[0]>,<Opt[1]>,<Opt[3]>,<Opt[4]>"
	for (INT i = 0; i < NumItems; i++)
	{
		FString keyStr = FString::Printf(TEXT("Config%d"), i);
		FString configStr;
		if (GConfig->GetString(TEXT("Rebuild Configs"), *keyStr, configStr, TEXT("UnrealEd.ini")))
		{
			TArray<FString> parts;
			configStr.ParseIntoArray(TEXT(","), &parts);
			if (parts.Num() == 6)
			{
				FRebuildOptions* saved = Save(parts(0));
				if (saved)
				{
					saved->Options[2] = appAtoi(*parts(1));
					saved->Options[0] = appAtoi(*parts(2));
					saved->Options[1] = appAtoi(*parts(3));
					saved->Options[3] = appAtoi(*parts(4));
					saved->Options[4] = appAtoi(*parts(5));
				}
			}
			// parts goes out of scope: TArray<FString>::~TArray calls ~FString per element
			// (inlines FUN_1031efc0 + FArray::~FArray behaviour)
		}
	}

	unguard;
}

// ?SetCurrent@FRebuildTools@@QAEXVFString@@@Z
// Ghidra 0x103FD660 (218b): looks up named option, asserts it exists,
// copies it into *GetCurrent() via FRebuildOptions::operator=.
IMPL_MATCH("Engine.dll", 0x103FD660)
void FRebuildTools::SetCurrent(FString p0) {
	guard(FRebuildTools::SetCurrent);
	FRebuildOptions* found = GetFromName(p0);
	if (!found)
		appFailAssert("RO", ".\\UnRebuildTools.cpp", 0x7c);
	*GetCurrent() = *found;
	unguard;
}

// ?Shutdown@FRebuildTools@@QAEXXZ
// Ghidra 0x103FD2E0 (376b): writes all rebuild configs to "Rebuild Configs"
// section of UnrealEd.ini via GConfig vtable, then frees current-options pointer.
// GConfig vtable offsets (verified against FConfigCache layout in Core.h):
//   +0x20 = slot 8  = EmptySection(Section, Filename=NULL)
//   +0x28 = slot 10 = SetInt(Section, Key, Value, Filename)
//   +0x30 = slot 12 = SetString(Section, Key, Value, Filename)
// Saved format per entry: "<Name>,<Opt[2]>,<Opt[0]>,<Opt[1]>,<Opt[3]>,<Opt[4]>"
// (only Options[0..4] are persisted; Options[5..7] are not saved to config).
// Retail calls FString::~FString directly on the current ptr (Name at offset 0);
// current->Name.~FString() generates the identical call.
IMPL_MATCH("Engine.dll", 0x103FD2E0)
void FRebuildTools::Shutdown() {
	guard(FRebuildTools::Shutdown);

	// Empty the section first (GConfig vtable +0x20; Filename=NULL shown by Ghidra)
	GConfig->EmptySection(TEXT("Rebuild Configs"), NULL);

	// Write count of saved configurations
	FArray* arr = (FArray*)((BYTE*)this + 4);
	INT count = arr->Num();
	GConfig->SetInt(TEXT("Rebuild Configs"), TEXT("NumItems"), count, TEXT("UnrealEd.ini"));

	// Write each config entry as a comma-separated string under "Config%d" keys
	for (INT i = 0; i < count; i++)
	{
		FRebuildOptions* opt = (FRebuildOptions*)((BYTE*)arr->GetData() + i * 0x2C);
		FString keyName = FString::Printf(TEXT("Config%d"), i);
		FString value   = FString::Printf(TEXT("%s,%d,%d,%d,%d,%d"),
			*opt->Name, opt->Options[2], opt->Options[0],
			opt->Options[1], opt->Options[3], opt->Options[4]);
		GConfig->SetString(TEXT("Rebuild Configs"), *keyName, *value, TEXT("UnrealEd.ini"));
	}

	// Destruct and free the current options heap allocation stored at this+0.
	// Retail: FString::~FString(current) — Name is at offset 0 so the call is identical.
	FRebuildOptions* current = *(FRebuildOptions**)this;
	if (current)
	{
		current->Name.~FString();
		GMalloc->Free(current);
	}
	unguard;
}
IMPL_MATCH("Engine.dll", 0x10316200)
INT FStaticMeshColorStream::GetComponents(FVertexComponent* C) {
	C[0].Type = 4; C[0].Function = 3;
	return 1;
}
