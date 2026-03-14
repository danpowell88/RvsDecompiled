/*=============================================================================
	UnCamera.cpp: Camera, viewport and motion blur (ACamera, UViewport)
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"
extern ENGINE_API UEngine* g_pEngine;

// --- ACamera ---
IMPL_TODO("Needs Ghidra analysis")
void ACamera::RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
	guard(ACamera::RenderEditorInfo);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void ACamera::RenderEditorSelected(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
	guard(ACamera::RenderEditorSelected);
	unguard;
}


// --- UCameraEffect ---
IMPL_TODO("Needs Ghidra analysis")
void UCameraEffect::PostRender(UViewport *,FRenderInterface *)
{
	guard(UCameraEffect::PostRender);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UCameraEffect::PreRender(UViewport *,FRenderInterface *)
{
	guard(UCameraEffect::PreRender);
	unguard;
}


// --- UCameraOverlay ---
IMPL_TODO("Needs Ghidra analysis")
void UCameraOverlay::PostRender(UViewport *,FRenderInterface *)
{
	guard(UCameraOverlay::PostRender);
	unguard;
}


// --- UMotionBlur ---
IMPL_TODO("Needs Ghidra analysis")
void UMotionBlur::PostRender(UViewport *,FRenderInterface *)
{
	guard(UMotionBlur::PostRender);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UMotionBlur::PreRender(UViewport *,FRenderInterface *)
{
	guard(UMotionBlur::PreRender);
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x86330)
void UMotionBlur::Destroy()
{
	// Retail: 0x86330, ordinal 2491. Calls parent Destroy, then frees the two
	// render buffer allocations at this+0x38 and this+0x3C (if non-NULL).
	// Freed via GMalloc->Free(ptr); each slot zeroed after free.
	UObject::Destroy();
	for (INT i = 0; i < 2; i++)
	{
		INT* slot = (INT*)((BYTE*)this + 0x38 + i * 4);
		if (*slot != 0)
		{
			appFree((void*)*slot);
			*slot = 0;
		}
	}
}


// --- UViewport ---
IMPL_TODO("Needs Ghidra analysis")
void UViewport::PushHit(HHitProxy const &,int)
{
	guard(UViewport::PushHit);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UViewport::RefreshAll()
{
	guard(UViewport::RefreshAll);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UViewport::LockOnActor(AActor *)
{
	guard(UViewport::LockOnActor);
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x83d70)
int UViewport::MultiShot()
{
	// Ghidra 0x83d70: no SEH frame

	// GFileManager->MakeDirectory (vtable slot 0x24/4)
	typedef void (__thiscall *TMakeDir)(void*);
	((TMakeDir)*(DWORD*)(*(DWORD*)GFileManager + 0x24))(GFileManager);

	const TCHAR* MapName = **((FString*)((BYTE*)this + 0x1a8));
	INT OldCounter = *(INT*)((BYTE*)this + 0x1b4);
	*(INT*)((BYTE*)this + 0x1b4) = OldCounter + 1;

	TCHAR filename[36];
	appSprintf(filename, TEXT("..\\ScreenShot\\%s%05i.bmp"), MapName, OldCounter);

	if (OldCounter + 1 < 0xffff)
	{
		// GFileManager->FileSize (vtable slot 0xc/4)
		typedef INT (__thiscall *TFileSize)(void*, const TCHAR*);
		INT fileSize = ((TFileSize)*(DWORD*)(*(DWORD*)GFileManager + 0xc))(GFileManager, filename);

		if (fileSize < 0)
		{
			FMemMark Mark(GMem);
			BYTE* pixelBuf = (BYTE*)GMem.PushBytes(*(INT*)((BYTE*)this + 0xa4) * *(INT*)((BYTE*)this + 0xa8) * 4, 8);

			// ReadPixels via render device vtable slot 0x90/4
			typedef void (__thiscall *TReadPixels)(void*, void*, BYTE*);
			((TReadPixels)*(DWORD*)(**(DWORD**)((BYTE*)this + 0x8c) + 0x90))(*(void**)((BYTE*)this + 0x8c), this, pixelBuf);

			// Create output file — vtable slot 8/4
			typedef void* (__thiscall *TCreateFile)(void*, const TCHAR*, DWORD, FOutputDevice*);
			void* fileAr = ((TCreateFile)*(DWORD*)(*(DWORD*)GFileManager + 8))(GFileManager, filename, 0, GNull);

			if (fileAr != NULL)
			{
				typedef void (__thiscall *TSerialize)(void*, void*, INT);
				TSerialize Serialize = (TSerialize)*(DWORD*)(*(DWORD*)fileAr + 4);

				// BITMAPFILEHEADER (14 bytes)
				struct BFH { _WORD bfType; DWORD bfSize; _WORD bfRes1; _WORD bfRes2; DWORD bfOffBits; } bfh;
				bfh.bfType    = 0x4d42;
				bfh.bfSize    = 0;
				bfh.bfRes1    = 0;
				bfh.bfRes2    = 0;
				bfh.bfOffBits = 0x36;
				Serialize(fileAr, &bfh, 14);

				// BITMAPINFOHEADER (40 bytes)
				struct BIH {
					DWORD biSize; DWORD biWidth; DWORD biHeight;
					_WORD biPlanes; _WORD biBitCount; DWORD biCompression;
					DWORD biSizeImage; DWORD biXPPM; DWORD biYPPM;
					DWORD biClrUsed; DWORD biClrImportant;
				} bih;
				bih.biSize        = 0x28;
				bih.biWidth       = *(DWORD*)((BYTE*)this + 0xa4);
				bih.biHeight      = *(DWORD*)((BYTE*)this + 0xa8);
				bih.biPlanes      = 1;
				bih.biBitCount    = 24;
				bih.biCompression = 0;
				bih.biSizeImage   = bih.biXPPM = bih.biYPPM = bih.biClrUsed = bih.biClrImportant = 0;
				Serialize(fileAr, &bih, 40);

				INT height = *(INT*)((BYTE*)this + 0xa8);
				INT width  = *(INT*)((BYTE*)this + 0xa4);
				while (--height >= 0)
				{
					for (INT x = 0; x < width; x++)
						Serialize(fileAr, pixelBuf + (width * height + x) * 4, 3);
				}

				// Close file via vtable[0]
				typedef void (__thiscall *TClose)(void*, INT);
				((TClose)*(DWORD*)(*(DWORD*)fileAr))(fileAr, 1);
			}

			Mark.Pop();
		}

		return 1;
	}

	*(DWORD*)((BYTE*)this + 0x1b4) = 0;
	*(DWORD*)((BYTE*)g_pEngine + 0x120) &= 0xffffbfff;
	return 0;
}

IMPL_TODO("Needs Ghidra analysis")
void UViewport::PopHit(int)
{
	guard(UViewport::PopHit);
	unguard;
}

IMPL_INFERRED("Decoded from retail binary; no direct RVA recorded")
void UViewport::ChangeInputSet(BYTE bReset)
{
	// Retail: 23b. If bReset==0, restores input set ptr: copy this+0x84 to this+0x80.
	if (!bReset)
		*(DWORD*)((BYTE*)this + 0x80) = *(DWORD*)((BYTE*)this + 0x84);
}

IMPL_TODO("Needs Ghidra analysis")
void UViewport::ExecProfile(const TCHAR*,int,FOutputDevice &)
{
	guard(UViewport::ExecProfile);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UViewport::ExecuteHits(FHitCause const &,BYTE*,int,TCHAR*,FColor *,AActor * *)
{
	guard(UViewport::ExecuteHits);
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x12AF0)
int UViewport::IsDepthComplexity()
{
	// Retail (25b, RVA 0x12AF0): RendMap == 0x08 → depth complexity view
	void* st = *(void**)((BYTE*)this + 0x34);
	if (!st) return 0;
	return (*(DWORD*)((BYTE*)st + 0x504) == 0x08) ? 1 : 0;
}

IMPL_GHIDRA("Engine.dll", 0x12B90)
int UViewport::IsEditing()
{
	// Retail (74b, RVA 0x12B90): RendMap 0x0D/0x0E/0x0F or 1-8 -> editing view
	void* st = *(void**)((BYTE*)this + 0x34);
	if (!st) return 0;
	INT rm = *(INT*)((BYTE*)st + 0x504);
	if (rm == 0x0D || rm == 0x0E || rm == 0x0F) return 1;
	if (rm >= 1 && rm <= 8) return 1;
	return 0;
}

IMPL_GHIDRA("Engine.dll", 0x12B60)
int UViewport::IsLit()
{
	// Retail (54b, RVA 0x12B60): RendMap 5,7,8,0x1E -> lit; RendMap 0x10 with [state+0x4FC] non-null
	void* st = *(void**)((BYTE*)this + 0x34);
	if (!st) return 0;
	INT rm = *(INT*)((BYTE*)st + 0x504);
	if (rm == 5 || rm == 7 || rm == 8 || rm == 0x1E) return 1;
	if (rm == 0x10) return *(void**)((BYTE*)st + 0x4FC) != NULL ? 1 : 0;
	return 0;
}

IMPL_GHIDRA("Engine.dll", 0x12A70)
int UViewport::IsTopView()
{
	// Retail (25b, RVA 0x12A70): RendMap == 0x0D → top-down ortho view
	void* st = *(void**)((BYTE*)this + 0x34);
	if (!st) return 0;
	return (*(DWORD*)((BYTE*)st + 0x504) == 0x0D) ? 1 : 0;
}


struct FUV2Data;
struct FProjectorRelativeRenderInfo;
struct HHitProxy;
struct _KarmaGlobals;
struct _McdGeometry;
struct McdGeomMan;
struct _KarmaTriListData;
class  FBspNode;
class  FStaticMeshBatcherVertex;


/*-----------------------------------------------------------------------------
  Data definitions
-----------------------------------------------------------------------------*/

UEngine * g_pEngine = NULL;

int AVIRecording = 0;

FString FURL::DefaultHost;

FString FURL::DefaultLocalMap;

FString FURL::DefaultMap;

FString FURL::DefaultMapExt;

FString FURL::DefaultName;

FString FURL::DefaultPortal;

FString FURL::DefaultProtocol;

FString FURL::DefaultProtocolDescription;

FString FURL::DefaultSaveExt;

UAudioSubsystem * USound::Audio = NULL;

UClient * UTexture::__Client = NULL;

float * USkeletalMeshInstance::m_fCylindersRadius = NULL;

// Hash-mixing permutation tables — 0x4000 entries each.
// Must be declared as arrays (not pointers) to match the retail layout
// where &HashX[i] is meaningful without heap allocation.
INT FCollisionHash::HashX[0x4000];
INT FCollisionHash::HashY[0x4000];
INT FCollisionHash::HashZ[0x4000];
INT FCollisionHash::CollisionTag = 0;
INT FCollisionHash::Inited = 0;

// Per-frame performance counters reset by FCollisionHash::Tick.
// Retail addresses: GHashActorCount @0x1064ff28, GHashLinkCellCount @0x1064ff2c, GHashExtraCount @0x1064ff34
INT GHashActorCount  = 0;   // DAT_1064ff28 — incremented once per AddActor call
INT GHashLinkCellCount = 0; // DAT_1064ff2c — incremented per hash-cell link inserted
INT GHashExtraCount  = 0;   // DAT_1064ff34 — additional insertion counter

int FURL::DefaultPort = 0;

_KarmaGlobals * KGData = NULL;

static INT bGameShutDown = 0;


/*-----------------------------------------------------------------------------
  Implementations
-----------------------------------------------------------------------------*/

// Forward declarations for element serializers needed by TArray<T> template
// instantiation in stream/buffer serializers below.
FArchive & operator<<(FArchive & Ar, FBspVertex & V);
FArchive & operator<<(FArchive & Ar, FStaticMeshVertex & V);
FArchive & operator<<(FArchive & Ar, FStaticMeshUV & V);
FArchive & operator<<(FArchive & Ar, FTerrainVertex & V);

// ??6@YAAAVFArchive@@AAV0@AAVFAnimMeshVertexStream@@@Z
// FUN_10323030 = TArray<0x20-element>::Serialize. Each element via FUN_10446ec0 = 8×ByteOrderSerialize(4).
// Layout (after vtable): Pad[4] TArray<elem>  Pad[0x18] Revision
IMPL_INFERRED("Decoded from Ghidra sub-function analysis; no direct RVA for this operator")
FArchive & operator<<(FArchive & Ar, FAnimMeshVertexStream & V) {
	// TArray at Pad[4] (obj+8), element size 0x20. Manual serialization.
	FArray& Arr = *(FArray*)&V.Pad[4];
	if (Ar.IsLoading()) {
		FCompactIndex count;
		Ar << count;
		INT n = *(INT*)&count;
		Arr.Empty(0x20, n);
		for (INT i = 0; i < n; i++) {
			INT idx = Arr.Add(1, 0x20);
			BYTE* elem = (BYTE*)Arr.GetData() + idx * 0x20;
			for (INT j = 0; j < 8; j++)
				Ar.ByteOrderSerialize(elem + j * 4, 4);
		}
	} else {
		Ar << *(FCompactIndex*)&V.Pad[8];  // ArrayNum as FCompactIndex
		for (INT i = 0; i < Arr.Num(); i++) {
			BYTE* elem = (BYTE*)Arr.GetData() + i * 0x20;
			for (INT j = 0; j < 8; j++)
				Ar.ByteOrderSerialize(elem + j * 4, 4);
		}
	}
	Ar.ByteOrderSerialize(&V.Pad[0x18], 4);  // Revision at Pad[0x18] = obj+0x1C
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFBspNode@@@Z
// Decoded from Ghidra Engine @ 0xcf6f0. Complex with ZoneMask (FUN_103cc610),
// sub-struct pairs (FUN_103cba20), version-gated multi-branch INT serialization.
// All internal functions fully decoded from _unnamed.cpp.
IMPL_GHIDRA("Engine.dll", 0xcf6f0)
FArchive & operator<<(FArchive & Ar, FBspNode & V) {
	BYTE* P = (BYTE*)&V;

	// FPlane at offset 0x00 (X, Y, Z, W)
	Ar.ByteOrderSerialize(P + 0x00, 4);
	Ar.ByteOrderSerialize(P + 0x04, 4);
	Ar.ByteOrderSerialize(P + 0x08, 4);
	Ar.ByteOrderSerialize(P + 0x0C, 4);

	// ZoneMask at offset 0x10: 256-bit bitmask (8 DWORDs = 32 bytes)
	// FUN_103cc610: Ravenshield format (LicenseeVer >= 9)
	if (Ar.LicenseeVer() < 9) {
		// Legacy: 8-byte QWORD (pre-Ravenshield). Read and discard.
		BYTE temp[8];
		Ar.ByteOrderSerialize(temp, 8);
	} else {
		if (Ar.IsLoading()) {
			appMemzero(P + 0x10, 32);
		}
		INT NumBytes = 0x20;  // 32
		Ar.ByteOrderSerialize((BYTE*)&NumBytes, 4);
		for (INT i = 0; i < NumBytes; i++) {
			if (!Ar.IsLoading()) {
				// Saving: pack 8 bits from DWORD array into 1 byte
				BYTE packed = 0;
				for (INT bit = 0; bit < 8; bit++) {
					INT bitIndex = bit + i * 8;
					INT dwordIndex = bitIndex >> 5;
					INT bitOffset = bitIndex & 0x1F;
					if (((DWORD*)(P + 0x10))[dwordIndex] & (1 << bitOffset))
						packed |= (BYTE)(1 << (bit & 0x1F));
				}
				Ar.Serialize(&packed, 1);
			} else {
				// Loading: read 1 byte, unpack to DWORD bits
				BYTE packed;
				Ar.Serialize(&packed, 1);
				if ((DWORD)i < 0x20) {
					for (INT bit = 0; bit < 8; bit++) {
						if (packed & (1 << (bit & 0x1F))) {
							INT bitIndex = bit + i * 8;
							INT dwordIndex = bitIndex >> 5;
							INT bitOffset = bitIndex & 0x1F;
							((DWORD*)(P + 0x10))[dwordIndex] |= (1 << bitOffset);
						}
					}
				}
			}
		}
	}

	// 1 byte at offset 0x6F (flags byte)
	Ar.Serialize(P + 0x6F, 1);

	// FCompactIndex fields
	Ar << *(FCompactIndex*)(P + 0x30);
	Ar << *(FCompactIndex*)(P + 0x34);
	Ar << *(FCompactIndex*)(P + 0x38);
	Ar << *(FCompactIndex*)(P + 0x3C);
	Ar << *(FCompactIndex*)(P + 0x40);
	Ar << *(FCompactIndex*)(P + 0x64);
	Ar << *(FCompactIndex*)(P + 0x68);

	// Sub-structures at +0x44 and +0x54 (FUN_103cba20: version-gated 3 or 4 DWORDs)
	if (Ar.Ver() > 0x45) {
		// Sub-struct at 0x44
		Ar.ByteOrderSerialize(P + 0x44, 4);
		Ar.ByteOrderSerialize(P + 0x48, 4);
		Ar.ByteOrderSerialize(P + 0x4C, 4);
		if (Ar.Ver() >= 0x3E)
			Ar.ByteOrderSerialize(P + 0x50, 4);
		// Sub-struct at 0x54
		Ar.ByteOrderSerialize(P + 0x54, 4);
		Ar.ByteOrderSerialize(P + 0x58, 4);
		Ar.ByteOrderSerialize(P + 0x5C, 4);
		if (Ar.Ver() >= 0x3E)
			Ar.ByteOrderSerialize(P + 0x60, 4);
	}

	// 3 single bytes at 0x6C, 0x6D, 0x6E
	Ar.Serialize(P + 0x6C, 1);
	Ar.Serialize(P + 0x6D, 1);
	Ar.Serialize(P + 0x6E, 1);

	// 2 INTs at 0x70 and 0x74
	Ar.ByteOrderSerialize(P + 0x70, 4);
	Ar.ByteOrderSerialize(P + 0x74, 4);

	// Version-gated block for offsets 0x78, 0x7C, 0x80 (3 INTs)
	if (Ar.Ver() < 0x5C) {
		*(INT*)(P + 0x78) = -1;
		*(INT*)(P + 0x7C) = -1;
		*(INT*)(P + 0x80) = -1;
	} else if (Ar.Ver() > 100) {
		// Ver > 0x64: real serialization
		Ar.ByteOrderSerialize(P + 0x78, 4);
		Ar.ByteOrderSerialize(P + 0x7C, 4);
		Ar.ByteOrderSerialize(P + 0x80, 4);
		if (Ar.IsLoading() && Ar.Ver() < 0x6C)
			*(INT*)(P + 0x80) = -1;
	} else {
		// 0x5C <= Ver <= 100: read temp values into locals, discard
		INT temp1 = -1, temp2 = -1;
		if (Ar.Ver() < 0x5D) {
			Ar.ByteOrderSerialize((BYTE*)&temp1, 4);
		} else {
			Ar.ByteOrderSerialize((BYTE*)&temp1, 4);
			Ar.ByteOrderSerialize((BYTE*)&temp2, 4);
		}
		*(INT*)(P + 0x78) = -1;
		*(INT*)(P + 0x7C) = -1;
		*(INT*)(P + 0x80) = -1;
	}

	// Loading: mask top bits of flags byte at 0x6F
	if (Ar.IsLoading())
		P[0x6F] &= 0x1F;

	// FUN_103cf3d0 at offset 0x84 only in counting mode (neither loading nor saving)
	// — skipped as it has no effect on actual serialization.

	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFBspSection@@@Z
// Decoded from Ghidra Engine @ 0x27ad0. Uses TArray<FBspVertex> (FUN_10322590),
// UObject* at +0x20, and version-gated INT override.
// Layout: [0x00] vtable  [0x04] TArray<FBspVertex>  [0x18] INT  [0x1C] INT
//         [0x20] UObject*  [0x24] INT  [0x28] INT (ver-gated default -1)
IMPL_GHIDRA("Engine.dll", 0x27ad0)
FArchive & operator<<(FArchive & Ar, FBspSection & V) {
	Ar << *(TArray<FBspVertex>*)&V.Pad[4];       // TArray<FBspVertex> at obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x18], 4);      // INT at obj+0x18
	Ar << *(UObject**)&V.Pad[0x20];               // UObject* at obj+0x20
	Ar.ByteOrderSerialize(&V.Pad[0x1C], 4);      // INT at obj+0x1C
	Ar.ByteOrderSerialize(&V.Pad[0x24], 4);      // INT at obj+0x24
	Ar.ByteOrderSerialize(&V.Pad[0x28], 4);      // INT at obj+0x28
	if (Ar.Ver() < 0x6B) {
		if (Ar.IsLoading()) {
			*(INT*)&V.Pad[0x28] = -1;
		}
	}
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFBspSurf@@@Z
// Decoded from Ghidra Engine @ 0xcbf50. Uses vtable+0x18 (UObject*), FCompactIndex,
// ByteOrderSerialize, and Serialize. No FUN_xxx dependencies.
IMPL_GHIDRA("Engine.dll", 0xcbf50)
FArchive & operator<<(FArchive & Ar, FBspSurf & V) {
	Ar << V.Texture;
	Ar.ByteOrderSerialize((BYTE*)&V.PolyFlags, 4);
	Ar << *(FCompactIndex*)&V.pBase;
	Ar << *(FCompactIndex*)&V.vNormal;
	Ar << *(FCompactIndex*)&V.vTextureU;
	Ar << *(FCompactIndex*)&V.vTextureV;
	if (Ar.Ver() < 0x65) {
		FCompactIndex temp;
		*(INT*)&temp = -1;
		Ar << temp;
	}
	Ar << *(FCompactIndex*)&V.iLightMap;
	if (Ar.Ver() < 0x4e) {
		_WORD temp1 = 0, temp2 = 0;
		Ar.ByteOrderSerialize((BYTE*)&temp1, 2);
		Ar.ByteOrderSerialize((BYTE*)&temp2, 2);
	}
	Ar << V.Actor;
	if (Ar.Ver() > 0x56) {
		Ar.ByteOrderSerialize((BYTE*)&V.Plane.X, 4);
		Ar.ByteOrderSerialize((BYTE*)&V.Plane.Y, 4);
		Ar.ByteOrderSerialize((BYTE*)&V.Plane.Z, 4);
		Ar.ByteOrderSerialize((BYTE*)&V.Plane.W, 4);
	}
	if (Ar.LicenseeVer() > 3) {
		Ar.ByteOrderSerialize(&V._RvsExtra[0x00], 4);       // offset 0x48
		Ar.Serialize(&V._RvsExtra[0x08], 1);                 // offset 0x50
		Ar.Serialize(&V._RvsExtra[0x0E], 1);                 // offset 0x56
		Ar.Serialize(&V._RvsExtra[0x0D], 1);                 // offset 0x55
		Ar.Serialize(&V._RvsExtra[0x0C], 1);                 // offset 0x54
		Ar.Serialize(&V._RvsExtra[0x0F], 1);                 // offset 0x57
	}
	if (Ar.LicenseeVer() > 4) {
		Ar.Serialize(&V._RvsExtra[0x10], 1);                 // offset 0x58
	}
	if (Ar.LicenseeVer() > 6) {
		Ar.ByteOrderSerialize(&V._RvsExtra[0x04], 4);       // offset 0x4C
	}
	if (Ar.Ver() > 0x69) {
		Ar.ByteOrderSerialize((BYTE*)&V.LightMapScale, 4);
	} else if (Ar.IsLoading()) {
		V.LightMapScale = 32.0f;
	}
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFBspVertexStream@@@Z
// FUN_10322590 = TArray<FBspVertex>::Serialize (elem_size 0x28)
// Layout (after vtable): Pad[0] TArray<FBspVertex>  Pad[0x14] Revision
FArchive & operator<<(FArchive & Ar, FBspVertexStream & V) {
	Ar << *(TArray<FBspVertex>*)V.Pad;            // TArray at Pad[0] = obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);      // Revision at Pad[0x14] = obj+0x18
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFLightMap@@@Z
// Ghidra @ 0x3c730: 7x FCompactIndex at Pad[8..0x20]; 9x DWORD at Pad[0x68..0x88];
// FUN_10301470 (FName?), FUN_1033a9a0, version checks 0x6a/0x6b/0x6d/0x6e.
// Needs FTexture base size to correctly interpret Pad offsets.
FArchive & operator<<(FArchive & Ar, FLightMap & p1) { return Ar; }

// ??6@YAAAVFArchive@@AAV0@AAVFLightMapTexture@@@Z
// Ghidra @ 0x27a00: vtable[6] on Pad[4..8], FUN_103218c0, BOS at Pad[0x60]+8, Pad[0x68]+4;
// if Ver()>0x73: recurse into FStaticLightMapTexture at Pad[0x14].
FArchive & operator<<(FArchive & Ar, FLightMapTexture & p1) { return Ar; }

// ??6@YAAAVFArchive@@AAV0@AAVFPoly@@@Z
FArchive & operator<<(FArchive & Ar, FPoly & V) {
	// NumVertices first (compact index)
	Ar << *(FCompactIndex*)&V.NumVertices;
	// Base(3) + Normal(3) + TextureU(3) + TextureV(3) = 12 floats
	for (INT i = 0; i < 12; i++)
		Ar.ByteOrderSerialize((BYTE*)&V.Base + i * 4, 4);
	// Variable-length vertex array
	for (INT i = 0; i < V.NumVertices; i++) {
		Ar.ByteOrderSerialize(&V.Vertex[i].X, 4);
		Ar.ByteOrderSerialize(&V.Vertex[i].Y, 4);
		Ar.ByteOrderSerialize(&V.Vertex[i].Z, 4);
	}
	// PolyFlags
	Ar.ByteOrderSerialize(&V.PolyFlags, 4);
	// Object references and name
	Ar << *(UObject**)&V.Actor;
	Ar << *(UObject**)&V.Material;
	Ar << V.ItemName;
	// Link indices
	Ar << *(FCompactIndex*)&V.iLink;
	Ar << *(FCompactIndex*)&V.iBrushPoly;
	// Legacy Ver < 0x4E path omitted (pre-Ravenshield format)
	// Ravenshield extensions (LicenseeVer > 5)
	if (Ar.LicenseeVer() > 5) {
		Ar.ByteOrderSerialize(&V._RvsExtra[0x38], 4);
		Ar.Serialize(&V._RvsExtra[0x40], 1);
		Ar.Serialize(&V._RvsExtra[0x46], 1);
		Ar.Serialize(&V._RvsExtra[0x45], 1);
		Ar.Serialize(&V._RvsExtra[0x44], 1);
		Ar.Serialize(&V._RvsExtra[0x47], 1);
		Ar.Serialize(&V._RvsExtra[0x48], 1);
	}
	if (Ar.LicenseeVer() > 6) {
		Ar.ByteOrderSerialize(&V._RvsExtra[0x3C], 4);
	}
	if (Ar.Ver() > 0x69) {
		Ar.ByteOrderSerialize(&V._RvsExtra[0x34], 4);
	} else if (Ar.IsLoading()) {
		*(FLOAT*)&V._RvsExtra[0x34] = 32.0f; // Default LightMapScale
	}
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFRaw32BitIndexBuffer@@@Z
// FUN_1037fbd0 = TArray<DWORD>::Serialize (elem_size 4, ByteOrderSerialize per element)
// Layout (after vtable): Pad[0] TArray<DWORD>  Pad[0x14] Revision
FArchive & operator<<(FArchive & Ar, FRaw32BitIndexBuffer & V) {
	Ar << *(TArray<DWORD>*)V.Pad;                 // TArray at Pad[0] = obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);      // Revision at Pad[0x14] = obj+0x18
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFRawColorStream@@@Z
// FUN_104170d0 = Custom TArray<FColor>::Serialize with BGRA byte order.
// Original serializes per-element bytes in order: [2]=B, [1]=G, [0]=R, [3]=A.
// Layout (after vtable): Pad[0] TArray<FColor>  Pad[0x14] Revision
FArchive & operator<<(FArchive & Ar, FRawColorStream & V) {
	TArray<FColor>& Colors = *(TArray<FColor>*)V.Pad;
	Colors.CountBytes(Ar);
	if (Ar.IsLoading()) {
		FCompactIndex count;
		Ar << count;
		INT n = *(INT*)&count;
		Colors.Empty(n);
		for (INT i = 0; i < n; i++) {
			INT idx = Colors.Add();
			BYTE* elem = (BYTE*)&Colors(idx);
			Ar.Serialize(elem + 2, 1);  // B
			Ar.Serialize(elem + 1, 1);  // G
			Ar.Serialize(elem + 0, 1);  // R
			Ar.Serialize(elem + 3, 1);  // A
		}
	} else {
		Ar << *(FCompactIndex*)&V.Pad[4];  // ArrayNum as FCompactIndex
		for (INT i = 0; i < Colors.Num(); i++) {
			BYTE* elem = (BYTE*)&Colors(i);
			Ar.Serialize(elem + 2, 1);  // B
			Ar.Serialize(elem + 1, 1);  // G
			Ar.Serialize(elem + 0, 1);  // R
			Ar.Serialize(elem + 3, 1);  // A
		}
	}
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);  // Revision at Pad[0x14] = obj+0x18
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFRawIndexBuffer@@@Z
// FUN_1031e600 = TArray<_WORD>::Serialize (elem_size 2, ByteOrderSerialize per element)
// Layout (after vtable): Pad[0] TArray<_WORD>  Pad[0x14] Revision
FArchive & operator<<(FArchive & Ar, FRawIndexBuffer & V) {
	Ar << *(TArray<_WORD>*)V.Pad;                 // TArray at Pad[0] = obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);      // Revision at Pad[0x14] = obj+0x18
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFSkinVertexStream@@@Z
// Decoded from Ghidra Engine @ 0x2b750. Conditionally serializes two UObject* refs
// (only when !IsPersistent), then 3 INTs, then TArray<0x20-elem> via FUN_10323030.
// Layout (after vtable): Pad[0] UObject*  Pad[4] UObject*  Pad[0x10] INT
//   Pad[0x14] INT  Pad[0x18] INT  Pad[0x1C] TArray<0x20-elem>
FArchive & operator<<(FArchive & Ar, FSkinVertexStream & V) {
	if (!Ar.IsPersistent()) {
		Ar << *(UObject**)&V.Pad[0x00];   // UObject* at Pad[0] = obj+0x04
		Ar << *(UObject**)&V.Pad[0x04];   // UObject* at Pad[4] = obj+0x08
	}
	Ar.ByteOrderSerialize(&V.Pad[0x10], 4);  // INT at Pad[0x10] = obj+0x14
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);  // INT at Pad[0x14] = obj+0x18
	Ar.ByteOrderSerialize(&V.Pad[0x18], 4);  // INT at Pad[0x18] = obj+0x1C
	// TArray<0x20-elem> at Pad[0x1C] (obj+0x20), serialized same as FAnimMeshVertexStream
	FArray& Arr = *(FArray*)&V.Pad[0x1C];
	Arr.CountBytes(Ar, 0x20);
	if (Ar.IsLoading()) {
		FCompactIndex count;
		Ar << count;
		INT n = *(INT*)&count;
		Arr.Empty(0x20, n);
		for (INT i = 0; i < n; i++) {
			INT idx = Arr.Add(1, 0x20);
			BYTE* elem = (BYTE*)Arr.GetData() + idx * 0x20;
			for (INT j = 0; j < 8; j++)
				Ar.ByteOrderSerialize(elem + j * 4, 4);
		}
	} else {
		Ar << *(FCompactIndex*)&V.Pad[0x20]; // TArray.ArrayNum at Pad[0x1C]+4
		for (INT i = 0; i < Arr.Num(); i++) {
			BYTE* elem = (BYTE*)Arr.GetData() + i * 0x20;
			for (INT j = 0; j < 8; j++)
				Ar.ByteOrderSerialize(elem + j * 4, 4);
		}
	}
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFStaticLightMapTexture@@@Z
// Ghidra @ 0x20c60: FUN_1031d450 on Pad[4..0x1c]; vtable[0] at Pad[0x34]+1;
// BOS at Pad[0x38]+4, Pad[0x3c]+4, Pad[0x48]+4. Needs FTexture base size.
FArchive & operator<<(FArchive & Ar, FStaticLightMapTexture & p1) { return Ar; }

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshBatcherVertex@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshBatcherVertex & p1) { return Ar; } // empty in original

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshLightInfo@@@Z
// Decoded from Ghidra Engine @ 0x21750. UObject* at +0, TArray<BYTE> at +4
// (FUN_1031cce0 = bulk byte array), INT at +0x10.
FArchive & operator<<(FArchive & Ar, FStaticMeshLightInfo & V) {
	Ar << V.LightObject;
	Ar << V.LightData;
	Ar.ByteOrderSerialize((BYTE*)&V.Field10, 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshMaterial@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshMaterial & V) {
	Ar << *(UObject**)&V.Material;
	Ar << *(FCompactIndex*)&V.Flags1;
	Ar << *(FCompactIndex*)&V.Flags2;
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshSection@@@Z
// Ghidra @ 0x50f10: complex version-branched (pre-0x5c / 0x5c-0x70 / 0x70+) with SEH;
// creates temp FStaticMeshVertexStream + FRawIndexBuffer locals. Needs deep decode.
FArchive & operator<<(FArchive & Ar, FStaticMeshSection & p1) { return Ar; }

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshUVStream@@@Z
// FUN_10324510 = TArray<FStaticMeshUV>::Serialize (elem_size 8, two floats per elem)
// Layout (after vtable): Pad[0] TArray<FStaticMeshUV>  Pad[0x0C] INT  Pad[0x18] Revision
FArchive & operator<<(FArchive & Ar, FStaticMeshUVStream & V) {
	Ar << *(TArray<FStaticMeshUV>*)V.Pad;         // TArray at Pad[0] = obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x0C], 4);      // INT at Pad[0x0C] = obj+0x10
	Ar.ByteOrderSerialize(&V.Pad[0x18], 4);      // Revision at Pad[0x18] = obj+0x1C
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshVertexStream@@@Z
// FUN_103243e0 = TArray<FStaticMeshVertex>::Serialize (elem_size 0x18)
// Layout (after vtable): Pad[0] TArray<FStaticMeshVertex>  Pad[0x14] Revision
FArchive & operator<<(FArchive & Ar, FStaticMeshVertexStream & V) {
	Ar << *(TArray<FStaticMeshVertex>*)V.Pad;     // TArray at Pad[0] = obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);      // Revision at Pad[0x14] = obj+0x18
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFTags@@@Z
// Decoded from Ghidra Engine @ 0xcc180. Inlines FUN_103cbaa0 (12×4-byte flat serialize)
// then serializes FString at offset 0x30.
FArchive & operator<<(FArchive & Ar, FTags & V) {
	for (INT i = 0; i < 12; i++)
		Ar.ByteOrderSerialize(V._Data + i * 4, 4);
	Ar << V.TagString;
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFTerrainVertexStream@@@Z
// FUN_10323cd0 = TArray<FTerrainVertex>::Serialize (elem_size 0x24)
FArchive & operator<<(FArchive & Ar, FTerrainVertexStream & V) {
	Ar << V.Vertices;
	Ar.ByteOrderSerialize((BYTE*)&V.Revision, 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFURL@@@Z
FArchive & operator<<(FArchive& Ar, FURL& U) {
	Ar << U.Protocol << U.Host << U.Map << U.Portal << U.Op;
	Ar << U.Port << U.Valid;
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFBspVertex@@@Z
FArchive & operator<<(FArchive & Ar, FBspVertex & V) {
	// Always serialize: offsets 0x00-0x08 (3 floats), 0x18-0x24 (4 floats)
	Ar.ByteOrderSerialize(&V._Data[0x00], 4);
	Ar.ByteOrderSerialize(&V._Data[0x04], 4);
	Ar.ByteOrderSerialize(&V._Data[0x08], 4);
	Ar.ByteOrderSerialize(&V._Data[0x18], 4);
	Ar.ByteOrderSerialize(&V._Data[0x1C], 4);
	Ar.ByteOrderSerialize(&V._Data[0x20], 4);
	Ar.ByteOrderSerialize(&V._Data[0x24], 4);
	// Version > 108: serialize 3 more floats at 0x0C-0x14
	if (Ar.Ver() > 0x6C) {
		Ar.ByteOrderSerialize(&V._Data[0x0C], 4);
		Ar.ByteOrderSerialize(&V._Data[0x10], 4);
		Ar.ByteOrderSerialize(&V._Data[0x14], 4);
	}
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFPosNormTexData@@@Z
FArchive & operator<<(FArchive & Ar, FPosNormTexData & V) {
	// 10 floats: offsets 0x00-0x24
	for (INT i = 0; i < 10; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFProjectorRelativeRenderInfo@@@Z
// Ghidra @ 0x48c0: reads p1.m_RenderInfoPtr.Ptr as FProjectorRenderInfo*;
// calls FUN_10304820 version check, then vtable[6] for two fields at +0x18 and +0x1c.
FArchive & operator<<(FArchive & Ar, FProjectorRelativeRenderInfo & p1) { return Ar; }

// ??6@YAAAVFArchive@@AAV0@PAUFProjectorRenderInfo@@@Z
// Ghidra @ 0x4890: calls FUN_10304820 version check; if 0 returns Ar;
// otherwise vtable[6] on p1+0x18 and p1+0x1c. FProjectorRenderInfo is forward-decl only.
FArchive & operator<<(FArchive & Ar, FProjectorRenderInfo * p1) { return Ar; }

// ??6@YAAAVFArchive@@AAV0@AAUFSkinVertex@@@Z
FArchive & operator<<(FArchive & Ar, FSkinVertex & V) {
	// 16 floats: offsets 0x00-0x3C
	for (INT i = 0; i < 16; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFStaticMeshCollisionNode@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshCollisionNode & V) {
	// 4 FCompactIndex values at offsets 0x00, 0x04, 0x08, 0x0C
	Ar << *(FCompactIndex*)&V._Data[0x00];
	Ar << *(FCompactIndex*)&V._Data[0x04];
	Ar << *(FCompactIndex*)&V._Data[0x08];
	Ar << *(FCompactIndex*)&V._Data[0x0C];
	// FBox at offset 0x10
	Ar << V.Box;
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFStaticMeshCollisionTriangle@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshCollisionTriangle & V) {
	// 16 floats (4 FPlanes) via ByteOrderSerialize
	for (INT i = 0; i < 16; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	// 4 FCompactIndex values at offsets 0x40, 0x44, 0x48, 0x4C
	Ar << *(FCompactIndex*)&V._Data[0x40];
	Ar << *(FCompactIndex*)&V._Data[0x44];
	Ar << *(FCompactIndex*)&V._Data[0x48];
	Ar << *(FCompactIndex*)&V._Data[0x4C];
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFStaticMeshUV@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshUV & V) {
	Ar.ByteOrderSerialize(&V._Data[0], 4);
	Ar.ByteOrderSerialize(&V._Data[4], 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFStaticMeshVertex@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshVertex & V) {
	// 6 floats: Position (3) + Normal (3)
	for (INT i = 0; i < 6; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	// Legacy version paths for Ver < 0x70 and Ver == 0x6F omitted
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFTerrainVertex@@@Z
FArchive & operator<<(FArchive & Ar, FTerrainVertex & V) {
	// 6 floats at 0x00-0x14
	for (INT i = 0; i < 6; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	// 4 individual bytes at 0x18-0x1B (serialized in reverse order per Ghidra)
	Ar.Serialize(&V._Data[0x1A], 1);
	Ar.Serialize(&V._Data[0x19], 1);
	Ar.Serialize(&V._Data[0x18], 1);
	Ar.Serialize(&V._Data[0x1B], 1);
	// 2 floats at 0x1C-0x20
	Ar.ByteOrderSerialize(&V._Data[0x1C], 4);
	Ar.ByteOrderSerialize(&V._Data[0x20], 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFUV2Data@@@Z
FArchive & operator<<(FArchive & Ar, FUV2Data & D) {
	Ar.ByteOrderSerialize(&D, 4);
	Ar.ByteOrderSerialize((BYTE*)&D + 4, 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFUntransformedVertex@@@Z
FArchive & operator<<(FArchive & Ar, FUntransformedVertex & V) {
	// 11 floats: offsets 0x00-0x28
	for (INT i = 0; i < 11; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	return Ar;
}

// ?GNewCollisionHash@@YAPAVFCollisionHashBase@@XZ
FCollisionHashBase * GNewCollisionHash() {
	if( !GIsEditor )
		return new FCollisionOctree();
	else
		return new FCollisionHash();
}

// ?FGetHSV@@YA?AVFPlane@@EEE@Z
// Converts Hue/Saturation/Value (each 0-255) to a normalised FPlane colour.
// Ghidra: param_2 (S/Hue) selects one of three sectors; param_3 (V) scales
// brightness; result has W=1.0f.
FPlane FGetHSV(BYTE H, BYTE S, BYTE V) {
	FLOAT fR, fG, fB;
	if (S < 0x56) {
		fR = (FLOAT)(0x55 - (DWORD)S) * 0.011764706f;
		fG = (FLOAT)(DWORD)S            * 0.011764706f;
		fB = 0.0f;
	} else if (S < 0xAB) {
		fR = 0.0f;
		fG = (FLOAT)(0xAA - (DWORD)S)   * 0.011764706f;
		fB = (FLOAT)((DWORD)S - 0x55)   * 0.011764706f;
	} else {
		fR = (FLOAT)((DWORD)S - 0xAA)   * 0.011764706f;
		fG = 0.0f;
		fB = (FLOAT)(0xFF - (DWORD)S)   * 0.011904762f;
	}
	FLOAT fV     = (FLOAT)V * 0.003921569f; // V / 255
	FLOAT fScale = (1.0f - fR) * fV;        // desaturation weight (Ghidra: afStack_c[0])
	fR = fScale + fR;
	fG = (1.0f - fG) * fV + fG;
	fB = (1.0f - fB) * fV + fB;
	// Ghidra: FVector{fR,fG,fB} * fScale, then FPlane(x,y,z,1.0f)
	FVector RGB = FVector(fR, fG, fB) * fScale;
	return FPlane(RGB.X, RGB.Y, RGB.Z, 1.0f);
}

// Forward declaration for overloaded variants below
int GetSUBSTRING(const TCHAR* Stream, const TCHAR* Match, TCHAR* Value, int MaxLen);

// ?GetFROTATOR@@YAHPBGAAVFRotator@@H@Z
int GetFROTATOR(const TCHAR* Stream, FRotator& Rotation, int ScaleFactor)
{
	FLOAT Temp = 0.f;
	int Count = 0;
	if( Parse( Stream, TEXT("PITCH="), Temp ) ) { Rotation.Pitch = (INT)(Temp * ScaleFactor); Count++; }
	if( Parse( Stream, TEXT("YAW="), Temp ) )   { Rotation.Yaw   = (INT)(Temp * ScaleFactor); Count++; }
	if( Parse( Stream, TEXT("ROLL="), Temp ) )  { Rotation.Roll  = (INT)(Temp * ScaleFactor); Count++; }
	if( Count > 0 )
		return 1;
	Rotation.Pitch = (INT)(appAtof( Stream ) * ScaleFactor);
	TCHAR* S = appStrchr( Stream, ',' );
	if( S )
	{
		Rotation.Yaw = (INT)(appAtof( S + 1 ) * ScaleFactor);
		S = appStrchr( S + 1, ',' );
		if( S )
		{
			Rotation.Roll = (INT)(appAtof( S + 1 ) * ScaleFactor);
			return 1;
		}
	}
	return 0;
}

// ?GetFROTATOR@@YAHPBG0AAVFRotator@@H@Z
int GetFROTATOR(const TCHAR* Stream, const TCHAR* Match, FRotator& Rotation, int ScaleFactor)
{
	TCHAR Temp[80];
	if( !GetSUBSTRING( Stream, Match, Temp, 80 ) )
		return 0;
	return GetFROTATOR( Temp, Rotation, ScaleFactor );
}

// ?GetFVECTOR@@YAHPBGAAVFVector@@@Z
int GetFVECTOR(const TCHAR* Stream, FVector& Value)
{
	int NumParsed = 0;
	NumParsed += Parse( Stream, TEXT("X="), Value.X );
	NumParsed += Parse( Stream, TEXT("Y="), Value.Y );
	NumParsed += Parse( Stream, TEXT("Z="), Value.Z );
	if( NumParsed > 0 )
		return NumParsed == 3;
	Value.X = appAtof( Stream );
	TCHAR* S = appStrchr( Stream, ',' );
	if( S )
	{
		Value.Y = appAtof( S + 1 );
		S = appStrchr( S + 1, ',' );
		if( S )
		{
			Value.Z = appAtof( S + 1 );
			return 1;
		}
	}
	return 0;
}

// ?GetFVECTOR@@YAHPBG0AAVFVector@@@Z
int GetFVECTOR(const TCHAR* Stream, const TCHAR* Match, FVector& Value)
{
	TCHAR Temp[80];
	if( !GetSUBSTRING( Stream, Match, Temp, 80 ) )
		return 0;
	return GetFVECTOR( Temp, Value );
}

// ?GetSUBSTRING@@YAHPBG0PAGH@Z
int GetSUBSTRING(const TCHAR* Stream, const TCHAR* Match, TCHAR* Value, int MaxLen)
{
	const TCHAR* Found = appStrfind( Stream, Match );
	if( !Found )
		return 0;
	Found += appStrlen( Match );
	int i = 0;
	while( *Found && *Found != ' ' && *Found != '\t' && i < MaxLen - 1 )
		Value[i++] = *Found++;
	Value[i] = 0;
	return 1;
}

// ?getGameShutDown@@YAHXZ
int getGameShutDown() { return bGameShutDown; }

// ?newPath@FPathBuilder@@AAEPAVANavigationPoint@@VFVector@@@Z
// Retail ordinal 5641 (0xe07b0).
// Spawns a PathNode at Location (adjusting Z upward if Scout's half-height < 85)
// and sets the machine-placed flag bit 0x80 at NavigationPoint+0x3a4.
// FPathBuilder layout: Pad[0..3]=ULevel*, Pad[4..7]=APawn* Scout.
ANavigationPoint* FPathBuilder::newPath(FVector Location) {
	ULevel* Level = *(ULevel**)((BYTE*)this);
	APawn* Scout  = *(APawn**)((BYTE*)this + 4);

	// Adjust Z so the node clears the Scout's collision cylinder height.
	FLOAT HalfHeight = *(FLOAT*)((BYTE*)Scout + 0xfc);
	if (HalfHeight < 85.0f)
		Location.Z = (Location.Z + 85.0f) - HalfHeight;

	// Find the PathNode class object.
	UClass* MetaClass  = UClass::StaticClass();
	UObject* PathNodeClass = UObject::StaticFindObjectChecked(MetaClass, (UObject*)~0, TEXT("PathNode"), 0);

	// Spawn a PathNode at Location with default rotation/name.
	ANavigationPoint* NavPt = (ANavigationPoint*)Level->SpawnActor(
		(UClass*)PathNodeClass, NAME_None, Location);

	if (!NavPt) {
		debugf(NAME_Warning, TEXT("FPathBuilder::newPath — failed to spawn PathNode"));
		return NULL;
	}

	// Mark as machine-placed (bit 0x80 of the NavigationPoint flags at +0x3a4).
	*(DWORD*)((BYTE*)NavPt + 0x3a4) |= 0x80;

	return NavPt;
}

// ?DistanceToHashPlane@FCollisionHash@@AAEMHMMH@Z
// Retail ordinal 2514 (0x6d6f0).  Returns the signed distance along axis p1
// to the far or near face of hash cell p0 (cell size = p3 unreal units,
// world offset = 262144).  Returns 256000 when p1 is zero (no movement along axis).
float FCollisionHash::DistanceToHashPlane(INT CellIdx, FLOAT Dir, FLOAT Pos, INT CellSize) {
	if (Dir == 0.0f) return 256000.0f;
	if (Dir > 0.0f)
		return ((((float)CellIdx + 0.5f) * (float)CellSize - 262144.0f) - Pos) / Dir;
	return ((((float)CellIdx - 0.5f) * (float)CellSize - 262144.0f) - Pos) / Dir;
}


// ?TestReach@FPathBuilder@@AAEHVFVector@@0@Z
// Retail ordinal 4852 (0xe0060).
// Teleports the Scout pawn to Start, tests whether it can reach End via
// APawn::pointReachable, then teleports Scout back to its original position.
// FPathBuilder layout: Pad[0..3] = ULevel*, Pad[4..7] = APawn* Scout.
int FPathBuilder::TestReach(FVector Start, FVector End) {
	ULevel* Level = *(ULevel**)((BYTE*)this);
	APawn* Scout = *(APawn**)((BYTE*)this + 4);

	// Save Scout's current location.
	FVector OldLoc;
	OldLoc.X = *(FLOAT*)((BYTE*)Scout + 0x234);
	OldLoc.Y = *(FLOAT*)((BYTE*)Scout + 0x238);
	OldLoc.Z = *(FLOAT*)((BYTE*)Scout + 0x23c);

	// Teleport Scout to Start (bNoCheck=0, bIgnorePawns=0).
	Level->FarMoveActor(Scout, Start, 0, 0, 0, 0);

	// Enable navigation-mode flag (bCanFly or similar path-test flag at +0x2c).
	*(BYTE*)((BYTE*)Scout + 0x2c) = 1;

	// Test whether End is reachable from Start.
	INT bReachable = Scout->pointReachable(End, 0);

	// Teleport Scout back to its original location (bIgnorePawns=1 to avoid
	// blocking the return move against other pawns).
	Level->FarMoveActor(Scout, OldLoc, 0, 1, 0, 0);

	return bReachable;
}

// ?TestWalk@FPathBuilder@@AAEHVFVector@@UFCheckResult@@M@Z
int FPathBuilder::TestWalk(FVector p0, FCheckResult p1, float p2) { return 0; }

// ?ValidNode@FPathBuilder@@AAEHPAVANavigationPoint@@PAVAActor@@@Z
// Retail ordinal 4962 (0xe0c90).
// Returns 1 when p1 is a valid adjacent navigation point for p0:
//   - p1 is non-null and different from p0
//   - p1 is not flagged as deleted (sign byte at 0xa0 >= 0)
//   - p1 is a NavigationPoint but NOT a LiftCenter
int FPathBuilder::ValidNode(ANavigationPoint* NavPoint, AActor* Candidate) {
	if (Candidate && Candidate != (AActor*)NavPoint && *(SBYTE*)((BYTE*)Candidate + 0xa0) >= 0) {
		if (((UObject*)Candidate)->IsA(ANavigationPoint::StaticClass())) {
			if (!((UObject*)Candidate)->IsA(ALiftCenter::StaticClass()))
				return 1;
		}
	}
	return 0;
}

// ?createPaths@FPathBuilder@@AAEHXZ
int FPathBuilder::createPaths() { return 0; }

// ?StoreActor@FOctreeNode@@AAEXPAVAActor@@PAVFCollisionOctree@@PBVFPlane@@@Z
// Ghidra (0xdb4e0): Leaf storage — adds the actor to this node's TArray and records
// this node in the actor's OctreeNodes list (actor+0x338) for fast removal.
// If the node already has >2 actors and is large enough to subdivide it does so;
// for simplicity we always use leaf storage (no subdivision).
void FOctreeNode::StoreActor(AActor* Actor, FCollisionOctree* OctHash, FPlane const* Plane)
{
	// Add actor to this node's actor list (TArray<AActor*> at FOctreeNode offset 0)
	TArray<AActor*>& ActorList = *(TArray<AActor*>*)this;
	ActorList.AddItem(Actor);
	// Record this node in the actor's OctreeNodes list (TArray<FOctreeNode*> at actor+0x338)
	TArray<FOctreeNode*>& NodeList = *(TArray<FOctreeNode*>*)((BYTE*)Actor + 0x338);
	NodeList.AddItem(this);
}

// ?FindBlockingNormal@FPathBuilder@@AAEXAAVFVector@@@Z
// Finds the surface normal at the point that blocks a path check.
// Runs up to three line checks (via Level->SingleLineCheck at vtable+0xcc):
//   Pass 1: Trace from (Scout.Loc - Direction*16) toward Scout.Loc.
//           If nothing blocked -> return unchanged.
//   Pass 2: If pass 1 blocked, trace downward 33 units at the end point.
//           If blocked -> give up, return unchanged.
//   Pass 3: If pass 2 not blocked, trace horizontally at Z-33 from End back toward Scout.
//           If blocked -> write Hit.Normal to p0.
//
// NOTE: The retail SingleLineCheck has a 7th undeclared FLOAT parameter (ExtraParam = 16.0).
// Passes 1 and 2 supply 16.0f for it via raw vtable call; pass 3 omits it (= 0).
void FPathBuilder::FindBlockingNormal(FVector& p0)
{
	ULevel* Level = *(ULevel**)((BYTE*)this);
	AActor* Scout = *(AActor**)((BYTE*)this + 4);

	FCheckResult Hit;
	Hit.Time = 1.0f;
	Hit.Item = INDEX_NONE;

	FLOAT HalfHeight = *(FLOAT*)((BYTE*)Scout + 0xfc);
	FLOAT Radius     = *(FLOAT*)((BYTE*)Scout + 0xf8);

	// Raw vtable call for SingleLineCheck with 7 explicit params (the extra 16.0f ExtraParam).
	typedef INT (__thiscall *tSLC7)(ULevel*,
	    FCheckResult*, AActor*, const FVector*, const FVector*, DWORD,
	    FLOAT, FLOAT, FLOAT,  // FVector Extent (3 floats by value)
	    FLOAT);               // ExtraParam
	void** VTable = *(void***)Level;
	tSLC7 SLC = (tSLC7)VTable[0xcc / 4];

	// Pass 1: trace from (Scout.Location - p0*16) toward Scout.Location.
	FVector Scaled = p0 * 16.0f;
	FVector End1(
		Scout->Location.X - Scaled.X,
		Scout->Location.Y - Scaled.Y,
		Scout->Location.Z - Scaled.Z);

	SLC(Level, &Hit, Scout, &End1, &Scout->Location, 0x86, Radius, Radius, HalfHeight, 16.0f);

	if (Hit.Time < 1.0f)
	{
		// Pass 2: vertical trace 33 units downward at the end point.
		Scaled = p0 * 16.0f;
		FLOAT EndZ = Scout->Location.Z - Scaled.Z;
		FVector End2(
			Scout->Location.X - Scaled.X,
			Scout->Location.Y - Scaled.Y,
			EndZ - 33.0f);
		FVector Start2(End2.X, End2.Y, EndZ);

		SLC(Level, &Hit, Scout, &End2, &Start2, 0x86, Radius, Radius, HalfHeight, 16.0f);

		if (Hit.Time < 1.0f)
			return;  // Pass 2 blocked—give up

		// Pass 3: horizontal trace at Z-33 from End back toward Scout.Location.
		FVector Start3(Scout->Location.X, Scout->Location.Y, Scout->Location.Z - 33.0f);
		FVector End3(End2.X, End2.Y, EndZ - 33.0f);

		Level->SingleLineCheck(Hit, Scout, Start3, End3, 0x86,
		                       FVector(Radius, Radius, HalfHeight));

		if (Hit.Time >= 1.0f)
			return;  // Pass 3 found nothing—give up

		// Pass 3 found a hit: set output to its surface normal.
		p0 = Hit.Normal;
	}
}

// ?Pass2From@FPathBuilder@@AAEXVFVector@@0M@Z
void FPathBuilder::Pass2From(FVector p0, FVector p1, float p2) {}

// ?SetPathCollision@FPathBuilder@@AAEXH@Z
// Retail ordinal 4485 (0xe0300).
// Toggles collision for actors that block path-building.
// When disabling (param_1 != 0): for each live actor that has bBlockPlayers &&
//   bCollideActors && !bPathTemp && !(JointDetails & 0x20000), save the old
//   collision state by setting a temporary flag (bit 3) at actor+0x320, then
//   call SetCollision(0, ...) to take the actor "out of the way".
// When re-enabling (param_1 == 0): restore collision for every actor that had
//   the temp flag set.
// Field actor+0x320 (800 decimal): custom scratch field used only during path
//   building; bit 3 (0x8) = "collision was disabled for path test; restore it".
void FPathBuilder::SetPathCollision(int bDisable) {
	ULevel* Level = *(ULevel**)((BYTE*)this);
	INT Count = Level->Actors.Num();

	if (bDisable == 0) {
		// Re-enable collision for actors we disabled.
		for (INT i = 0; i < Count; i++) {
			AActor* A = Level->Actors(i);
			if (!A) continue;
			if (*(DWORD*)((BYTE*)A + 0x320) & 0x8) {
				// Clear the temp flag.
				*(DWORD*)((BYTE*)A + 0x320) &= ~0x8u;
				// Restore bBlockActors=1, bBlockPlayers and bBlocksSelf from saved flags.
				DWORD Flags = *(DWORD*)((BYTE*)A + 0xa8);
				A->SetCollision(1, (Flags >> 13) & 1, (Flags >> 14) & 1);
			}
		}
	} else {
		// Disable collision of actors that block path search.
		for (INT i = 0; i < Count; i++) {
			AActor* A = Level->Actors(i);
			if (!A) continue;
			if (*(SBYTE*)((BYTE*)A + 0xa0) < 0) continue; // bDeleteMe
			DWORD Flags = *(DWORD*)((BYTE*)A + 0xa8);
			DWORD bBlockPlayers = (Flags >> 13) & 1;
			if (!bBlockPlayers) {
				*(DWORD*)((BYTE*)A + 0x320) &= ~0x8u;
				continue;
			}
			// Skip if not bCollideActors, or bPathTemp set, or joint-no-encroach flag.
			if (!(Flags & 0x800) || (*(DWORD*)((BYTE*)A + 0xa0) & 1) ||
			    (*(DWORD*)((BYTE*)A + 0xac) & 0x20000)) {
				*(DWORD*)((BYTE*)A + 0x320) &= ~0x8u;
				continue;
			}
			// Save and disable.
			*(DWORD*)((BYTE*)A + 0x320) |= 0x8;
			A->SetCollision(0, bBlockPlayers, (Flags >> 14) & 1);
		}
	}
}

// ?getScout@FPathBuilder@@AAEXXZ
// Finds or spawns the Scout pawn used for path-building reachability tests.
// FPathBuilder layout: [0..3]=ULevel*, [4..7]=APawn* Scout
// Post-spawn Scout setup:
//   SetCollision(1,1,1)
//   Scout+0xa8 |= 0x1000  (bPathBuilding flag)
//   vtable[0x10c] and vtable[0x114] on Scout (SetPhysics-related calls)
//   Scout->PhysicsVolume = Level->GetDefaultPhysicsVolume()
void FPathBuilder::getScout()
{
	ULevel* Level = *(ULevel**)((BYTE*)this);
	*(AActor**)((BYTE*)this + 4) = NULL;

	// Find Scout UClass for IsA checks.
	// Deviation from original: StaticFindObjectChecked called before loop
	// instead of using AScout::PrivateStaticClass directly (AScout is forward-declared only).
	UClass* ScoutClass = (UClass*)UObject::StaticFindObjectChecked(
		UClass::StaticClass(), (UObject*)-1, TEXT("Scout"), 0);

	// Search existing actors for a Scout pawn.
	INT Count = Level->Actors.Num();
	for (INT i = 0; i < Count; i++)
	{
		AActor* A = Level->Actors(i);
		if (!A || !A->IsA(ScoutClass)) continue;
		*(AActor**)((BYTE*)this + 4) = A;
		break;
	}

	if (*(INT*)((BYTE*)this + 4) == 0)
	{
		// Spawn a new Scout pawn.
		AActor* S = Level->SpawnActor(ScoutClass, NAME_None, FVector(0,0,0));
		*(AActor**)((BYTE*)this + 4) = (S && S->IsA(ScoutClass)) ? S : NULL;

		// Spawn an AIController for the Scout.
		UClass* AIClass = (UClass*)UObject::StaticFindObjectChecked(
			UClass::StaticClass(), (UObject*)-1, TEXT("AIController"), 0);
		AActor* AICtrl = Level->SpawnActor(AIClass, NAME_None, FVector(0,0,0));
		AActor* Scout = *(AActor**)((BYTE*)this + 4);
		if (Scout) *(void**)((BYTE*)Scout + 0x4ec) = AICtrl;
	}

	AActor* Scout = *(AActor**)((BYTE*)this + 4);
	if (!Scout) return;

	Scout->SetCollision(1, 1, 1);
	*(DWORD*)((BYTE*)Scout + 0xa8) |= 0x1000;  // bPathBuilding

	// vtable[0x10c] on Scout — physics/state init call (no visible args)
	typedef void (__thiscall *tVoidFn)(AActor*);
	tVoidFn fn1 = *(tVoidFn*)((BYTE*)(*(void**)Scout) + 0x10c);
	fn1(Scout);

	// Store default physics volume
	ALevelInfo* LevelInfo = *(ALevelInfo**)((BYTE*)Scout + 0x144);
	APhysicsVolume* Vol = LevelInfo->GetDefaultPhysicsVolume();
	*(APhysicsVolume**)((BYTE*)Scout + 0x164) = Vol;

	// vtable[0x114] on Scout — second physics/state init call (no visible args)
	tVoidFn fn2 = *(tVoidFn*)((BYTE*)(*(void**)Scout) + 0x114);
	fn2(Scout);
}

// ?testPathsFrom@FPathBuilder@@AAEXVFVector@@@Z
// Ghidra: call findStart on Scout; if Z matches within MaxStepHeight -> testPathwithRadius;
// else retry findStart with Start.Z+20. If neither works, return.
void FPathBuilder::testPathsFrom(FVector Start) {
	AScout* Scout = *(AScout**)(Pad + 4);
	if (Scout->findStart(Start)) {
		// Check if scout landed close enough in Z (within MaxStepHeight at Scout+0xfc)
		FLOAT ScoutZ  = *(FLOAT*)((BYTE*)Scout + 0x23c);	// Z component after placement
		FLOAT MaxStep = *(FLOAT*)((BYTE*)Scout + 0xfc);	// MaxStepHeight
		FLOAT DiffZ   = ScoutZ - Start.Z;
		if (DiffZ < 0.0f) DiffZ = -DiffZ;
		if (DiffZ <= MaxStep) {
			testPathwithRadius(Start, 40.0f);
			return;
		}
	}
	// Retry 20 units higher
	if (Scout->findStart(FVector(Start.X, Start.Y, Start.Z + 20.0f)))
		testPathwithRadius(Start, 40.0f);
}

// ?testPathwithRadius@FPathBuilder@@AAEXVFVector@@M@Z
// Ghidra: resize Scout to Radius x 85, then probe 8 horizontal directions (±X, ±Y) at ±1 walk.
void FPathBuilder::testPathwithRadius(FVector Start, float Radius) {
	AActor* Scout = *(AActor**)(Pad + 4);
	Scout->SetCollisionSize(Radius, 85.0f);
	Pass2From(Start, FVector( 1.0f, 0.0f, 0.0f),  1.0f);
	Pass2From(Start, FVector( 1.0f, 0.0f, 0.0f), -1.0f);
	Pass2From(Start, FVector( 0.0f, 1.0f, 0.0f),  1.0f);
	Pass2From(Start, FVector( 0.0f, 1.0f, 0.0f), -1.0f);
	Pass2From(Start, FVector(-1.0f, 0.0f, 0.0f),  1.0f);
	Pass2From(Start, FVector(-1.0f, 0.0f, 0.0f), -1.0f);
	Pass2From(Start, FVector( 0.0f,-1.0f, 0.0f),  1.0f);
	Pass2From(Start, FVector( 0.0f,-1.0f, 0.0f), -1.0f);
}

// ??0ECLipSynchData@@QAE@PAVUMeshInstance@@PAVUSound@@1PAVAActor@@@Z
ECLipSynchData::ECLipSynchData(UMeshInstance * p0, USound * p1, USound * p2, AActor * p3) {}

// ??0ECLipSynchData@@QAE@XZ
ECLipSynchData::ECLipSynchData() {}

// ??0FActorSceneNode@@QAE@PAVUViewport@@PAVAActor@@1VFVector@@VFRotator@@M@Z
FActorSceneNode::FActorSceneNode(UViewport * p0, AActor * p1, AActor * p2, FVector p3, FRotator p4, float p5) : FSceneNode((UViewport*)NULL) {}

// ??0FCameraSceneNode@@QAE@PAVUViewport@@PAVAActor@@VFVector@@VFRotator@@M@Z
FCameraSceneNode::FCameraSceneNode(UViewport * p0, AActor * p1, FVector p2, FRotator p3, float p4) : FSceneNode((UViewport*)NULL) {}

// ??0FCollisionHash@@QAE@ABV0@@Z
// Copy constructor — rarely called; just default-init and leave buckets empty.
// A proper implementation would clone the hash table from p0, but that involves
// re-inserting all actors which requires level context we don't have here.
FCollisionHash::FCollisionHash(FCollisionHash const & /*p0*/) {
	FreeList = NULL;
	// AllocatedPools default-constructed to empty
	if (!Inited) {
		Inited = 1;
		for (INT i = 0; i < 0x4000; i++) HashX[i] = HashY[i] = HashZ[i] = i;
		for (INT i = 0; i < 0x4000; i++) {
			INT jx = (DWORD)appRand() & 0x3FFF; Exchange(HashX[i], HashX[jx]);
			INT jy = (DWORD)appRand() & 0x3FFF; Exchange(HashY[i], HashY[jy]);
			INT jz = (DWORD)appRand() & 0x3FFF; Exchange(HashZ[i], HashZ[jz]);
		}
	}
	for (INT i = 0; i < 0x4000; i++) Buckets[i] = NULL;
}

// ??0FCollisionHash@@QAE@XZ
// Retail: ordinal 211 (0x6f440).  Size: ~700 bytes.
// Sets up vftable, zeros pool/FArray, initialises permutation tables once via
// Fisher-Yates shuffle (seeded by appRand), then NULLs all 0x4000 bucket heads.
FCollisionHash::FCollisionHash() {
	FreeList = NULL;
	// AllocatedPools is default-constructed (TArray ctor zeroes it)
	if (!Inited) {
		Inited = 1;
		for (INT i = 0; i < 0x4000; i++) HashX[i] = HashY[i] = HashZ[i] = i;
		for (INT i = 0; i < 0x4000; i++) {
			INT jx = (DWORD)appRand() & 0x3FFF; Exchange(HashX[i], HashX[jx]);
			INT jy = (DWORD)appRand() & 0x3FFF; Exchange(HashY[i], HashY[jy]);
			INT jz = (DWORD)appRand() & 0x3FFF; Exchange(HashZ[i], HashZ[jz]);
		}
	}
	for (INT i = 0; i < 0x4000; i++) Buckets[i] = NULL;
}

// ??0FCollisionOctree@@QAE@ABV0@@Z
FCollisionOctree::FCollisionOctree(FCollisionOctree const& p0) {
	appMemcpy(Pad, p0.Pad, sizeof(Pad));
}

// ??0FCollisionOctree@@QAE@XZ
// Ghidra: allocates a root FOctreeNode, zeroes counters, sets world bitmask.
FCollisionOctree::FCollisionOctree() {
	appMemzero(Pad, sizeof(Pad));
	// Pad[0..3] = root FOctreeNode* (object offset +4, ref from Ghidra)
	FOctreeNode* root = new FOctreeNode();
	*(FOctreeNode**)Pad = root;
	// Pad[4..7] = world size bitmask 0x1fffffff (object offset +8)
	*(INT*)(Pad + 4) = 0x1fffffff;
	// FVector/FRotator fields at Pad+0x10..0x4c already zeroed by appMemzero
}

// ??0FDirectionalLightMapSceneNode@@QAE@PAVUViewport@@PAVAActor@@AAVFBspSurf@@PAVFLightMap@@@Z
FDirectionalLightMapSceneNode::FDirectionalLightMapSceneNode(UViewport * p0, AActor * p1, FBspSurf & p2, FLightMap * p3) : FSceneNode((UViewport*)NULL) {}

// ??0FHitCause@@QAE@PAVFHitObserver@@PAVUViewport@@KMM@Z
FHitCause::FHitCause(FHitObserver* InObserver, UViewport* InViewport, DWORD InButtons, float InMouseX, float InMouseY)
:	Observer(InObserver)
,	Viewport(InViewport)
,	Buttons(InButtons)
,	MouseX(InMouseX)
,	MouseY(InMouseY)
{}

// ??4FHitCause@@QAEAAU0@ABU0@@Z
FHitCause& FHitCause::operator=(const FHitCause& Other)
{
	Observer = Other.Observer;
	Viewport = Other.Viewport;
	Buttons  = Other.Buttons;
	MouseX   = Other.MouseX;
	MouseY   = Other.MouseY;
	return *this;
}

// ??0FLevelSceneNode@@QAE@PAV0@HVFMatrix@@@Z
FLevelSceneNode::FLevelSceneNode(FLevelSceneNode * p0, int p1, FMatrix p2) : FSceneNode((UViewport*)NULL) {}

// ??0FLevelSceneNode@@QAE@ABV0@@Z
// Ghidra: calls FSceneNode copy ctor, then copies 6 DWORDs at 0x1B8-0x1CC
FLevelSceneNode::FLevelSceneNode(FLevelSceneNode const & Other) : FSceneNode((const FSceneNode&)Other)
{
	appMemcpy(((BYTE*)this) + 0x1B8, ((const BYTE*)&Other) + 0x1B8, 24);
}

// ??0FLevelSceneNode@@QAE@PAVUViewport@@@Z
FLevelSceneNode::FLevelSceneNode(UViewport * p0) : FSceneNode((UViewport*)NULL) {}

// ??0FLightMapSceneNode@@QAE@PAVUViewport@@PAVAActor@@PAVFLightMap@@@Z
FLightMapSceneNode::FLightMapSceneNode(UViewport * p0, AActor * p1, FLightMap * p2) : FSceneNode((UViewport*)NULL) {}

// ??0FMatineeTools@@QAE@ABV0@@Z
FMatineeTools::FMatineeTools(FMatineeTools const & p0) {}

// ??0FOctreeNode@@QAE@ABV0@@Z
// Copy constructor — copy TArray (actors list at Pad[0..11]) and flag at Pad[12]
FOctreeNode::FOctreeNode(FOctreeNode const& p0) {
	appMemcpy(Pad, p0.Pad, 16);
}

// ??0FOctreeNode@@QAE@XZ
// Ghidra: FArray::FArray((FArray*)this) zeros first 12 bytes; *(this+0xc) = 0
FOctreeNode::FOctreeNode() {
	appMemzero(Pad, 16); // TArray<> at 0..11, flag at 12
}

// ??1FOctreeNode@@QAE@XZ
FOctreeNode::~FOctreeNode() {}

// ??0FPointLightMapSceneNode@@QAE@PAVUViewport@@PAVAActor@@AAVFBspSurf@@PAVFLightMap@@HHHH@Z
FPointLightMapSceneNode::FPointLightMapSceneNode(UViewport * p0, AActor * p1, FBspSurf & p2, FLightMap * p3, int p4, int p5, int p6, int p7) : FSceneNode((UViewport*)NULL) {}

// ??0FPoly@@QAE@XZ
FPoly::FPoly() {
	Init();
}

// ??0FRebuildTools@@QAE@ABV0@@Z
FRebuildTools::FRebuildTools(FRebuildTools const & p0) {}

// ??1FRebuildTools@@QAE@XZ
FRebuildTools::~FRebuildTools() {}


// =============================================================================
// UViewport (moved from EngineClassImpl.cpp)
// =============================================================================

// UViewport
// =============================================================================

INT UViewport::Exec( const TCHAR* Cmd, FOutputDevice& Ar ) { return 0; }
void UViewport::Serialize( const TCHAR* Data, EName Event ) {}
void UViewport::Destroy() { Super::Destroy(); }
void UViewport::Serialize( FArchive& Ar ) { Super::Serialize( Ar ); }
void UViewport::ReadInput( FLOAT DeltaSeconds ) {}
INT UViewport::Lock( BYTE* HitData, INT* HitSize ) { return 0; }
void UViewport::Unlock() {}
void UViewport::Present() {}
INT UViewport::SetDrag( INT NewDrag ) { return 0; }
void* UViewport::GetServer() { return NULL; }
void UViewport::TryRenderDevice( const TCHAR* ClassName, INT NewX, INT NewY, INT NewColorBytes ) {}
void UViewport::ExecMacro( const TCHAR* Filename, FOutputDevice& Ar ) {}
UClient* UViewport::GetOuterUClient() const { return (UClient*)GetOuter(); }
void UViewport::InitInput() {}
INT UViewport::IsOrtho()
{
	// Retail (34b, RVA 0x12A60): load state ptr at +0x34, check RendMap at +0x504
	// for ortho modes 0x0D, 0x0E, 0x0F.
	void* st = *(void**)((BYTE*)this + 0x34);
	if (!st) return 0;
	INT rm = *(INT*)((BYTE*)st + 0x504);
	return (rm == 0x0D || rm == 0x0E || rm == 0x0F) ? 1 : 0;
}
INT UViewport::IsPerspective()
{
	// Retail (74b, RVA 0x12A00): same state ptr; RendMap 1-7 or 0x1E → perspective.
	// RendMap == 0x10 only if [state+0x4FC] is non-null.
	void* st = *(void**)((BYTE*)this + 0x34);
	if (!st) return 0;
	INT rm = *(INT*)((BYTE*)st + 0x504);
	if (rm >= 1 && rm <= 7) return 1;
	if (rm == 0x1E) return 1;
	if (rm == 0x10) return *(void**)((BYTE*)st + 0x4FC) != NULL ? 1 : 0;
	return 0;
}
INT UViewport::IsRealtime()
{
	// Retail (26b, RVA 0x12A90): state ptr at +0x34; flags at +0x4F8 bits 11,14.
	void* st = *(void**)((BYTE*)this + 0x34);
	if (!st) return 0;
	return (*(DWORD*)((BYTE*)st + 0x4F8) & 0x4800) ? 1 : 0;
}
INT UViewport::IsWire() { return 0; }
void UViewport::ScreenShot() {}
BYTE* UViewport::_Screen( INT X, INT Y )
{
	// Retail (31b, RVA 0x129D0): return FrameBuffer + (Pitch * Y + X) * BytesPerPixel
	// Pitch at [this+0x160], BytesPerPixel at [this+0xCC], FrameBuffer at [this+0x15C]
	INT Pitch         = *(INT*)((BYTE*)this + 0x160);
	INT BytesPerPixel = *(INT*)((BYTE*)this + 0xCC);
	BYTE* FrameBuffer = *(BYTE**)((BYTE*)this + 0x15C);
	return FrameBuffer + (Pitch * Y + X) * BytesPerPixel;
}

// =============================================================================
