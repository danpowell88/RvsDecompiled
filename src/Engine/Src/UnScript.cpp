/*=============================================================================
	UnScript.cpp: Engine-side animation notify system (UAnimNotify*)
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

// --- UAnimNotify ---
void UAnimNotify::Notify(UMeshInstance *,AActor *)
{
}

void UAnimNotify::PostEditChange()
{
	// Retail: FF 41 2C C3 = INC [ECX+0x2C]; RET — increments Revision counter
	Revision++;
}


// --- UAnimNotify_DestroyEffect ---
void UAnimNotify_DestroyEffect::Notify(UMeshInstance *,AActor *)
{
}


// --- UAnimNotify_Effect ---
void UAnimNotify_Effect::Notify(UMeshInstance *,AActor *)
{
}


// --- UAnimNotify_MatSubAction ---
void UAnimNotify_MatSubAction::Notify(UMeshInstance *,AActor *)
{
}


// --- UAnimNotify_Script ---
void UAnimNotify_Script::Notify(UMeshInstance *,AActor *)
{
}


// --- UAnimNotify_Scripted ---
void UAnimNotify_Scripted::Notify(UMeshInstance *,AActor *)
{
}


// --- UAnimNotify_Sound ---
void UAnimNotify_Sound::Notify(UMeshInstance *,AActor *)
{
}


// --- UAnimation ---
void UAnimation::Serialize(FArchive &)
{
}

