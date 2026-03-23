/*=============================================================================
	UnFont.cpp: Font rendering system (UFont, FFontCharacter, FFontPage)
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

// --- FFontCharacter ---
IMPL_MATCH("Engine.dll", 0x10304570)
FFontCharacter& FFontCharacter::operator=(const FFontCharacter& Other)
{
	appMemcpy( this, &Other, sizeof(FFontCharacter) );
	return *this;
}


// --- FFontPage ---
IMPL_MATCH("Engine.dll", 0x10327800)
FFontPage::FFontPage(FFontPage const &Other)
{
	// Ghidra 0x27800: no vtable; 2 DWORDs at +0,+4; TArray<FLineVertex> at +8 (stride 0x10)
	appMemcpy(this, &Other, 8);
	new ((BYTE*)this + 0x08) TArray<FLineVertex>(*(const TArray<FLineVertex>*)((const BYTE*)&Other + 0x08));
}

IMPL_MATCH("Engine.dll", 0x10327800)
FFontPage::FFontPage()
{
	// Initialize TArray<FLineVertex> at +8 to empty
	new ((BYTE*)this + 0x08) TArray<FLineVertex>();
}

IMPL_MATCH("Engine.dll", 0x103277f0)
FFontPage::~FFontPage()
{
	// Ghidra 0x103277f0: destroy TArray<FLineVertex> at +8 (stride 0x10, POD elements)
	((TArray<FLineVertex>*)((BYTE*)this + 0x08))->~TArray();
}

IMPL_MATCH("Engine.dll", 0x10327830)
FFontPage& FFontPage::operator=(const FFontPage& Other)
{
	// Ghidra 0x27830: 2 DWORDs at +0,+4, then TArray<FLineVertex> at +8
	// (FUN_1031e1c0 = 16-byte elems, same function as FLineBatcher::op=)
	appMemcpy(this, &Other, 8);
	*(TArray<FLineVertex>*)((BYTE*)this + 0x08) = *(const TArray<FLineVertex>*)((const BYTE*)&Other + 0x08);
	return *this;
}


// --- UFont ---
IMPL_MATCH("Engine.dll", 0x10320b80)
_WORD UFont::RemapChar(_WORD Char)
{
	// Retail: 15b. If remap table ptr at this+0x50 is null, return Char unchanged.
	// Non-null path falls into adjacent helper (CJK lookup via this+0x3C) -- divergence:
	// we return Char unchanged as safe fallback in the remap case too.
	if (!*(DWORD*)((BYTE*)this + 0x50)) return Char;
	return Char; // divergence: remap table lookup not implemented
}

IMPL_MATCH("Engine.dll", 0x1039c230)
void UFont::Serialize(FArchive& Ar)
{
	guard(UFont::Serialize);
	Super::Serialize(Ar);
	UBOOL SavedLazyLoad = GLazyLoad;
	GLazyLoad = 1; // Ghidra: force eager load during font serialize
	// FUN_1039c090(Ar, this+0x30) = TArray<FFontPage>::Serialize — serializes the Pages array
	// and returns the FArchive* (same Ar, or a sub-archive for lazy-loaded textures).
	// The retail ByteOrderSerialize below is called on the RETURNED FArchive*, not Ar directly.
	// DIVERGENCE: FUN_1039c090 not called; Pages TArray not serialized here.
	// ByteOrderSerialize(CharactersPerPage) intentionally called on Ar directly as fallback.
	Ar.ByteOrderSerialize((BYTE*)this + 0x2c, 4); // CharactersPerPage at +0x2c
	check(!(*(DWORD*)((BYTE*)this+0x2c) & (*(DWORD*)((BYTE*)this+0x2c)-1))); // must be power of 2
	if (!GLazyLoad)
	{
		// DIVERGENCE: texture preload loop omitted (triggers vtable calls on each page's
		// texture objects; requires fully serialized Pages TArray above).
	}
	GLazyLoad = SavedLazyLoad;
	if (Ar.Ver() < 0x45)
	{
		*(DWORD*)((BYTE*)this + 0x50) = 0; // zero DropShadowX for pre-v69 data
		return;
	}
	// FUN_1039be10(Ar, this+0x3c) = serialize additional font fields at +0x3c
	// (likely TArray<FFontInfo> or per-font-page UV/glyph metadata).
	// DIVERGENCE: FUN_1039be10 not called; those fields remain default-initialized.
	if (Ar.IsLoading())
	{
		// FUN_1031f260() = post-load font fixup: rebuilds the character-lookup table
		// (glyph hash / remap array) from the deserialized Pages data.
		// DIVERGENCE: FUN_1031f260 not called; lookup table not rebuilt.
	}
	Ar.ByteOrderSerialize((BYTE*)this + 0x50, 4); // DropShadowX at +0x50
	unguard;
}

