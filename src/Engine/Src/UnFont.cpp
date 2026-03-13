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

void UFont::Serialize(FArchive &)
{
}

