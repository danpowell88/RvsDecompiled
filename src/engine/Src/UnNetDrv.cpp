/*=============================================================================
	UnNetDrv.cpp: Network driver (UNetDriver, UDemoRecDriver)
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

// --- UNetDriver ---
void UNetDriver::StaticConstructor()
{
}

void UNetDriver::TickFlush()
{
	// Retail: 0x18b820, ordinal 4877. Calls TickFlush on ServerConnection (this+0x3C)
	// if present, then calls TickFlush on each connection in the ClientConnections
	// TArray at this+0x30 via vtable slot 0x84/4 (= TickFlush virtual).
	// vtable[0x84/4] = vtable[33] = TickFlush.
	typedef void (__thiscall* TickFlushFn)(void*);
	INT* serverConn = *(INT**)((BYTE*)this + 0x3C);
	if (serverConn)
		((TickFlushFn)(*(void**)(*serverConn + 0x84)))(serverConn);
	TArray<INT>& Clients = *(TArray<INT>*)((BYTE*)this + 0x30);
	for (INT i = 0; i < Clients.Num(); i++)
	{
		INT* conn = (INT*)Clients(i);
		((TickFlushFn)(*(void**)(*conn + 0x84)))(conn);
	}
}

// (merged from earlier occurrence)
void UNetDriver::TickDispatch(float)
{
}
void UNetDriver::Serialize(FArchive &Ar)
{
	guard(UNetDriver::Serialize);
	// Ghidra 0x1048C210: UObject::Serialize, then a conditional-transact helper (RVA 0x18BFA0)
	// that returns a filtered archive, then serializes fields at +0x3C,+0x44,+0x7C,+0x80.
	UObject::Serialize(Ar);
	// NOTE: Divergence — object-ref fields (+0x3C ServerConnection, +0x44, +0x7C, +0x80) not serialized;
	// full implementation requires transactor helper identification.
	unguard;
}
void UNetDriver::NotifyActorDestroyed(AActor* Actor)
{
	// Ghidra 0x18c2d0: for each client connection, if actor has open channel
	// (ServerConnection or ClientConnections TArray at +0x30), close it.
	// Divergence: actor channel tracking via FUN_103b7b70 not implemented.
	(void)Actor;
}
void UNetDriver::AssertValid()
{
}
void UNetDriver::Destroy()
{
}
int UNetDriver::InitConnect(FNetworkNotify *,FURL &,FString &)
{
	return 0;
}
int UNetDriver::InitListen(FNetworkNotify *,FURL &,FString &)
{
	return 0;
}


// --- UDemoRecDriver ---
void UDemoRecDriver::SpawnDemoRecSpectator(UNetConnection *)
{
}

void UDemoRecDriver::StaticConstructor()
{
}

void UDemoRecDriver::TickDispatch(float)
{
}

void UDemoRecDriver::LowLevelDestroy()
{
}

FString UDemoRecDriver::LowLevelGetNetworkNumber()
{
	return FString();
}

int UDemoRecDriver::Exec(const TCHAR*,FOutputDevice &)
{
	return 0;
}

ULevel * UDemoRecDriver::GetLevel()
{
	return NULL;
}

int UDemoRecDriver::InitBase(int,FNetworkNotify *,FURL &,FString &)
{
	return 0;
}

int UDemoRecDriver::InitConnect(FNetworkNotify *,FURL &,FString &)
{
	return 0;
}

int UDemoRecDriver::InitListen(FNetworkNotify *,FURL &,FString &)
{
	return 0;
}

