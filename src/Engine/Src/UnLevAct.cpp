/*=============================================================================
	UnLevAct.cpp: Level actor management (ULevelSummary)
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

// Placement new for placement-new stubs in this TU.
#include "EnginePrivate.h"
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// --- ULevelSummary ---
IMPL_MATCH("Engine.dll", 0x1030fd00)
void ULevelSummary::PostLoad()
{
	guard(ULevelSummary::PostLoad);
	// Ghidra 0xfd00: UObject::PostLoad, then localize the Level title from package.
	// Localize("LevelInfo0", "Title", OuterName) -> set Title (FString at +0x30).
	UObject::PostLoad();
	UObject* Outer = GetOuter();
	if (Outer)
	{
		const TCHAR* outerName = Outer->GetName();
		const TCHAR* localTitle = Localize(TEXT("LevelInfo0"), TEXT("Title"), outerName, NULL, 1);
		if (localTitle && *localTitle)
			*(FString*)((BYTE*)this + 0x30) = localTitle;
	}
	unguard;
}

