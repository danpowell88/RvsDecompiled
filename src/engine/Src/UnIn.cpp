/*=============================================================================
	UnIn.cpp: Input subsystem (UInputPlanning)
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

// --- UInputPlanning ---
const TCHAR* UInputPlanning::StaticConfigName()
{
	// Retail: 6b. Returns same hardcoded pointer as UInput::StaticConfigName = L"User".
	return TEXT("User");
}

void UInputPlanning::StaticInitInput()
{
}

