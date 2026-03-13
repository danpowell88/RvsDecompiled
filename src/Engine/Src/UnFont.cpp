/*=============================================================================
	UnFont.cpp: Font rendering system (UFont, FFontCharacter, FFontPage)
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

// --- FFontCharacter ---
FFontCharacter& FFontCharacter::operator=(const FFontCharacter& Other)
{
	appMemcpy( this, &Other, sizeof(FFontCharacter) );
	return *this;
}


// --- FFontPage ---
FFontPage::FFontPage(FFontPage const &Other)
{
	// Ghidra 0x27800: no vtable; 2 DWORDs at +0,+4; TArray<FLineVertex> at +8 (stride 0x10)
	appMemcpy(this, &Other, 8);
	new ((BYTE*)this + 0x08) TArray<FLineVertex>(*(const TArray<FLineVertex>*)((const BYTE*)&Other + 0x08));
}

FFontPage::FFontPage()
{
	// Initialize TArray<FLineVertex> at +8 to empty
	new ((BYTE*)this + 0x08) TArray<FLineVertex>();
}

FFontPage::~FFontPage()
{
	// Ghidra 0x103277f0: destroy TArray<FLineVertex> at +8 (stride 0x10, POD elements)
	((TArray<FLineVertex>*)((BYTE*)this + 0x08))->~TArray();
}

FFontPage& FFontPage::operator=(const FFontPage& Other)
{
	// Ghidra 0x27830: 2 DWORDs at +0,+4, then TArray<FLineVertex> at +8
	// (FUN_1031e1c0 = 16-byte elems, same function as FLineBatcher::op=)
	appMemcpy(this, &Other, 8);
	*(TArray<FLineVertex>*)((BYTE*)this + 0x08) = *(const TArray<FLineVertex>*)((const BYTE*)&Other + 0x08);
	return *this;
}


// --- UFont ---
_WORD UFont::RemapChar(_WORD Char)
{
	// Retail: 15b. If remap table ptr at this+0x50 is null, return Char unchanged.
	// Non-null path falls into adjacent helper (CJK lookup via this+0x3C) -- divergence:
	// we return Char unchanged as safe fallback in the remap case too.
	if (!*(DWORD*)((BYTE*)this + 0x50)) return Char;
	return Char; // divergence: remap table lookup not implemented
}

void UFont::Serialize(FArchive& Ar)
{
	guard(UFont::Serialize);
	Super::Serialize(Ar);
	UBOOL SavedLazyLoad = GLazyLoad;
	GLazyLoad = 1; // Ghidra: force eager load during font serialize
	// TODO: FUN_1039c090(Ar, this+0x30) — serialize Pages TArray (operator<< for font pages)
	Ar.ByteOrderSerialize((BYTE*)this + 0x2c, 4); // CharactersPerPage at +0x2c
	check(!(*(DWORD*)((BYTE*)this+0x2c) & (*(DWORD*)((BYTE*)this+0x2c)-1))); // must be power of 2
	if (!GLazyLoad)
	{
		// TODO: iterate Pages TArray at +0x30, trigger texture loads for each page
	}
	GLazyLoad = SavedLazyLoad;
	if (Ar.Ver() < 0x45)
	{
		*(DWORD*)((BYTE*)this + 0x50) = 0; // zero DropShadowX for pre-v69 data
		return;
	}
	// TODO: FUN_1039be10(Ar, this+0x3c) — serialize additional font fields at +0x3c
	if (Ar.IsLoading())
	{
		// TODO: FUN_1031f260() — post-load font fixup
	}
	Ar.ByteOrderSerialize((BYTE*)this + 0x50, 4); // DropShadowX at +0x50
	unguard;
}

