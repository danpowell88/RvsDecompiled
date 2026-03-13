/*=============================================================================
	UnChan.cpp: Network channel implementations (UChannel hierarchy)
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

// --- UChannel ---

// (merged from earlier occurrence)
int UChannel::SendBunch(FOutBunch *,int)
{
	return 0;
}


// --- UFileChannel ---
void UFileChannel::StaticConstructor()
{
}

void UFileChannel::Tick()
{
}

// (merged from earlier occurrence)
void UFileChannel::ReceivedBunch(FInBunch &)
{
}
FString UFileChannel::Describe()
{
	return FString();
}
void UFileChannel::Destroy()
{
	// Ghidra 0x184100: Close send file at +0x6C via vtable[0] (destructor, delete=1).
	// If InType (+0x3C) and download at +0x68 exist, flush/delete download.
	// Then assert Channels[ChIndex]==this, UChannel::Destroy.
	check(*(INT*)((BYTE*)this + 0x2C) != 0); // Connection must exist
	if (RouteDestroy() == 0)
	{
		void** sendFile = (void**)((BYTE*)this + 0x6C);
		if (*sendFile)
		{
			INT vt = *(INT*)*sendFile;
			typedef void (__thiscall *DtorFn)(void*, INT);
			((DtorFn)(*(INT*)(vt + 0)))(*sendFile, 1);
			*sendFile = NULL;
		}
		INT inType = *(INT*)((BYTE*)this + 0x3C);
		void** dld = (void**)((BYTE*)this + 0x68);
		if (inType && *dld)
		{
			INT vt = *(INT*)*dld;
			typedef void (__thiscall *TickFn)(void*);
			((TickFn)(*(INT*)(vt + 0x78)))(*dld);
			if (*dld)
			{
				vt = *(INT*)*dld;
				typedef void (__thiscall *DtorFn2)(void*, INT);
				((DtorFn2)(*(INT*)(vt + 0xC)))(*dld, 1);
			}
		}
		UChannel::Destroy();
	}
}
void UFileChannel::Init(UNetConnection* Conn, int ChIndex, int InType)
{
	// Retail: 0x180f30. Just delegates to UChannel::Init.
	UChannel::Init(Conn, ChIndex, InType);
}


// --- UActorChannel ---
void UActorChannel::StaticConstructor()
{
}

void UActorChannel::Tick()
{
}

void UActorChannel::ReceivedBunch(FInBunch &)
{
}

void UActorChannel::ReceivedNak(int)
{
}

void UActorChannel::ReplicateActor()
{
}

void UActorChannel::SetChannelActor(AActor *)
{
}

void UActorChannel::SetClosingFlag()
{
	// Ghidra 0x1821d0: if actor ref at +0x6C is present, call FUN_10481e90 to flush
	// replication state, then call UChannel::SetClosingFlag.
	// Divergence: FUN_10481e90 (replication flush) not implemented; just delegate.
	UChannel::SetClosingFlag();
}

void UActorChannel::Close()
{
	// Ghidra 0x1813e0: UChannel::Close then zero the actor reference at this+0x6C.
	UChannel::Close();
	*(INT*)((BYTE*)this + 0x6C) = 0;
}

FString UActorChannel::Describe()
{
	return FString();
}

void UActorChannel::Destroy()
{
}

AActor * UActorChannel::GetActor()
{
	// Ghidra (4B): Actor at offset 0x6C
	return *(AActor**)((BYTE*)this + 0x6C);
}

void UActorChannel::Init(UNetConnection* Conn, int ChIndex, int InType)
{
	// Ghidra 0x180c90: UChannel::Init + initialise actor-specific replication fields.
	// Chain: this+0x2C=Conn, Conn+0x7C=Level, Level+0x40=LevelInfo, then vtable[3]()
	// returns game time stored at this+0x68; also copies Level+0x48 (seq nr 8b) to this+0x74.
	// Divergence: replication tracking fields zeroed instead of copying from level state.
	UChannel::Init(Conn, ChIndex, InType);
	*(INT*)((BYTE*)this + 0x68) = 0;
	*(INT*)((BYTE*)this + 0x6C) = 0;   // Actor ptr — set later by SetChannelActor
	appMemzero((BYTE*)this + 0x74, 0x20); // zero 0x74..0x93 (replication state)
}


// --- UControlChannel ---
void UControlChannel::StaticConstructor()
{
}

void UControlChannel::ReceivedBunch(FInBunch &)
{
}

void UControlChannel::Serialize(const TCHAR*,EName)
{
}

FString UControlChannel::Describe()
{
	return FString();
}

void UControlChannel::Destroy()
{
	// Ghidra 0x182070: assert Connection at +0x2C, call RouteDestroy.
	// If returns 0: assert Channels[ChIndex]==this, call UChannel::Destroy.
	check(*(INT*)((BYTE*)this + 0x2C) != 0); // Connection must exist
	if (RouteDestroy() == 0)
		UChannel::Destroy();
}

void UControlChannel::Init(UNetConnection* Conn, int ChIndex, int InType)
{
	UChannel::Init(Conn, ChIndex, InType);
}


// =============================================================================
// UChannel (moved from EngineClassImpl.cpp)
// =============================================================================

// UChannel
// =============================================================================

void UChannel::Destroy() { Super::Destroy(); }
void UChannel::Init( UNetConnection* InConnection, INT InChIndex, INT InOpenedLocally )
{
	ChIndex = InChIndex;
	Connection = InConnection;
	OpenedLocally = InOpenedLocally;
	OpenPacketId = INDEX_NONE;
	// NegotiatedVer copies from the connection's negotiated protocol version.
	// UNetConnection::NegotiatedVer is within _ConnPad (not yet decoded from Ghidra).
	// Default to 0 (minimum version) until the field offset is confirmed.
	NegotiatedVer = 0;
}
void UChannel::SetClosingFlag() { Closing = 1; }
void UChannel::Close() {}
FString UChannel::Describe() { return FString(); }
void UChannel::ReceivedNak( INT NakPacketId ) {}
void UChannel::Tick() {}
void UChannel::AssertInSequenced() {}
INT CDECL UChannel::IsKnownChannelType( INT Type ) { return 0; }
INT UChannel::IsNetReady( INT Saturate ) { return 1; }
INT UChannel::MaxSendBytes() { return 0; }
void UChannel::ReceivedAcks() {}
void UChannel::ReceivedRawBunch( FInBunch& Bunch ) {}
INT UChannel::ReceivedSequencedBunch( FInBunch& Bunch ) { return 0; }
INT UChannel::RouteDestroy() { return 0; }

// =============================================================================

// =============================================================================
// UChannel virtuals (moved from EngineClassImpl.cpp)
// =============================================================================

// UChannel
// ---------------------------------------------------------------------------
void UChannel::StaticConstructor()
{
}

void UChannel::ReceivedBunch(FInBunch& Bunch)
{
}

void UChannel::Serialize(const TCHAR* Name, EName Type)
{
}

// ---------------------------------------------------------------------------
