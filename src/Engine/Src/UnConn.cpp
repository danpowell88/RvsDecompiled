/*=============================================================================
	UnConn.cpp: Net connection and player/client stubs (UNetConnection)
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

// --- UNetConnection ---

// --- UClient ---
void UClient::StaticConstructor()
{
	guard(UClient::StaticConstructor);
	unguard;
}

void UClient::UpdateGamma()
{
	guard(UClient::UpdateGamma);
	unguard;
}

void UClient::UpdateGraphicOptions()
{
	guard(UClient::UpdateGraphicOptions);
	unguard;
}

void UClient::RestoreGamma()
{
	guard(UClient::RestoreGamma);
	unguard;
}

void UClient::Serialize(FArchive &)
{
	guard(UClient::Serialize);
	unguard;
}

void UClient::PostEditChange()
{
	guard(UClient::PostEditChange);
	unguard;
}

void UClient::Destroy()
{
	guard(UClient::Destroy);
	unguard;
}

int UClient::Exec(const TCHAR*,FOutputDevice &)
{
	return 0;
}

void UClient::Flush(int)
{
	guard(UClient::Flush);
	unguard;
}

void UClient::Init(UEngine* Engine)
{
	guard(UClient::Init);
	// Ghidra 0x86f20: store engine reference and call StaticConstructor
	*(UEngine**)((BYTE*)this + 0x2c) = Engine;
	StaticConstructor();
	unguard;
}


// --- UPlayer ---
void UPlayer::Serialize(FArchive &Ar)
{
	guard(UPlayer::Serialize);
	// Ghidra 0x103F7120 (41 bytes): only calls UObject::Serialize then returns.
	UObject::Serialize(Ar);
	unguard;
}

void UPlayer::Destroy()
{
	guard(UPlayer::Destroy);
	unguard;
}

int UPlayer::Exec(const TCHAR*,FOutputDevice &)
{
	return 0;
}

