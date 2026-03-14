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

INT UChannel::SendBunch(FOutBunch*, INT)
{
guard(UChannel::SendBunch);
return 0;
unguard;
}


// --- UFileChannel ---
void UFileChannel::StaticConstructor()
{
guard(UFileChannel::StaticConstructor);
*(INT*)((BYTE*)this + 0x48) = 3;  // ChType = CHTYPE_File
unguard;
}

void UFileChannel::Tick()
{
guard(UFileChannel::Tick);
// Divergence: 453-byte file-sending tick not implemented.
unguard;
}

void UFileChannel::ReceivedBunch(FInBunch&)
{
guard(UFileChannel::ReceivedBunch);
// Divergence: 1243-byte receive handler not implemented.
unguard;
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
guard(UActorChannel::StaticConstructor);
*(INT*)((BYTE*)this + 0x48) = 2;  // ChType = CHTYPE_Actor
unguard;
}

void UActorChannel::Tick()
{
guard(UActorChannel::Tick);
UChannel::Tick();
unguard;
}

void UActorChannel::ReceivedBunch(FInBunch&)
{
guard(UActorChannel::ReceivedBunch);
// Divergence: complex actor replication receive not implemented.
unguard;
}

void UActorChannel::ReceivedNak(int NakPacketId)
{
guard(UActorChannel::ReceivedNak);
UChannel::ReceivedNak(NakPacketId);
// Divergence: actor replication NAK handling (FUN_10481dd0) not implemented.
unguard;
}

void UActorChannel::ReplicateActor()
{
guard(UActorChannel::ReplicateActor);
// Divergence: complex actor replication not implemented.
unguard;
}

void UActorChannel::SetChannelActor(AActor*)
{
guard(UActorChannel::SetChannelActor);
// Divergence: actor channel setup not implemented.
unguard;
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
	guard(UActorChannel::Destroy);
	check(*(INT*)((BYTE*)this + 0x2C) != 0); // Connection must exist
	if (!UChannel::RouteDestroy())
	{
		// Assert Channels[ChIndex] == this
		BYTE* conn    = *(BYTE**)((BYTE*)this + 0x2C); // Connection
		INT   chIndex = *(INT*)((BYTE*)this + 0x38);   // ChIndex
		check(*(UActorChannel**)(conn + 0xeb0 + chIndex * 4) == this);

		// Call virtual reset function at vtable slot 0x1a (offset 0x68) on this
		typedef void (__thiscall* VFunc26)(void*);
		((VFunc26)(*(DWORD*)((BYTE*)*(DWORD**)this + 0x68)))(this);

		// Free replication property buffer
		FArray* repData = (FArray*)((BYTE*)this + 0x94);
		INT num = repData->Num();
		if (num != 0)
		{
			check(*(INT*)((BYTE*)this + 0x70) != 0); // ActorClass != NULL
			UObject::ExitProperties(*(BYTE**)((BYTE*)this + 0x94), *(UClass**)((BYTE*)this + 0x70));
		}

		// Determine client vs server via Connection->field_0x7c->field_0x3c
		BYTE* drv = *(BYTE**)(conn + 0x7C); // Connection->field_0x7c (Driver)
		if (*(INT*)(drv + 0x3C) == 0)
		{
			// Client side: optionally clean up actor ref at +0x6c
			if (*(INT*)((BYTE*)this + 0x6C) != 0 && *(INT*)((BYTE*)this + 0x30) == 0)
			{
				// TODO: FUN_103db080((BYTE*)this + 0x6c) - cleanup actor ref
			}
		}
		else
		{
			// Server side: validate actor/level/connection
			UObject* actor = *(UObject**)((BYTE*)this + 0x6C);
			if (actor != NULL)
				check(actor->IsValid());
			check(*(INT*)((BYTE*)this + 0x68) != 0);
			check((*(UObject**)((BYTE*)this + 0x68))->IsValid());
			check(*(INT*)((BYTE*)this + 0x2C) != 0);
			check((*(UObject**)((BYTE*)this + 0x2C))->IsValid());
		}
	}
	unguard;
}

AActor* UActorChannel::GetActor()
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
*(INT*)((BYTE*)this + 0x6C) = 0;   // Actor ptr -- set later by SetChannelActor
appMemzero((BYTE*)this + 0x74, 0x20); // zero 0x74..0x93 (replication state)
}


// --- UControlChannel ---
void UControlChannel::StaticConstructor()
{
guard(UControlChannel::StaticConstructor);
*(INT*)((BYTE*)this + 0x48) = 1;  // ChType = CHTYPE_Control
unguard;
}

void UControlChannel::ReceivedBunch(FInBunch&)
{
guard(UControlChannel::ReceivedBunch);
// Divergence: complex control message handling not implemented.
unguard;
}

void UControlChannel::Serialize(const TCHAR*, EName)
{
guard(UControlChannel::Serialize);
// Divergence: complex control serialization not implemented.
unguard;
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

void UChannel::Close()
{
guard(UChannel::Close);
// Divergence: 252-byte close bunch creation not implemented.
unguard;
}

FString UChannel::Describe()
{
guard(UChannel::Describe);
return FString();
unguard;
}

void UChannel::ReceivedNak(INT NakPacketId)
{
guard(UChannel::ReceivedNak);
for (FOutBunch* Out = *(FOutBunch**)((BYTE*)this + 0x5C); Out; Out = *(FOutBunch**)((BYTE*)Out + 0x54))
{
if (*(INT*)((BYTE*)Out + 0x74) == NakPacketId && *(INT*)((BYTE*)Out + 0x64) == 0)
{
if (!*(BYTE*)((BYTE*)Out + 0x7A))
appFailAssert("Out->bReliable", ".\\UnChan.cpp", 0x203);
debugf(NAME_DevNet, TEXT("Resending bunch"));
Connection->SendRawBunch(*Out, 0);
}
}
unguard;
}

void UChannel::Tick()
{
guard(UChannel::Tick);
// Divergence: 247-byte resend timer logic not implemented.
unguard;
}

void UChannel::AssertInSequenced()
{
guard(UChannel::AssertInSequenced);
for (INT cur = *(INT*)((BYTE*)this + 0x58); cur && *(INT*)(cur + 0x58); cur = *(INT*)(cur + 0x58))
{
if (*(INT*)(*(INT*)(cur + 0x58) + 0x68) <= *(INT*)(cur + 0x68))
appFailAssert("In->Next->ChSequence>In->ChSequence", ".\\UnChan.cpp", 0x108);
}
unguard;
}

INT CDECL UChannel::IsKnownChannelType(INT Type)
{
if (Type >= 0 && Type < 8 && UChannel::ChannelClasses[Type])
return 1;
return 0;
}

INT UChannel::IsNetReady( INT Saturate ) { return 1; }

INT UChannel::MaxSendBytes()
{
guard(UChannel::MaxSendBytes);
INT* conn = *(INT**)((BYTE*)this + 0x2C);
FBitWriter& ConnOut = *(FBitWriter*)((BYTE*)conn + 0x250);
INT numBits = ConnOut.GetNumBits();
INT maxBits = *(INT*)((BYTE*)conn + 0xD0) * 8;
INT headerBits = (numBits != 0) ? 0 : 16;
INT available = maxBits - headerBits - numBits - 0x41;
INT bytes = (available + (available >> 31 & 7)) >> 3;
return bytes < 1 ? 0 : bytes;
unguard;
}

void UChannel::ReceivedAcks()
{
guard(UChannel::ReceivedAcks);
// Divergence: 244-byte acked-bunch cleanup not implemented.
unguard;
}

void UChannel::ReceivedRawBunch(FInBunch& Bunch)
{
guard(UChannel::ReceivedRawBunch);
// Divergence: complex raw bunch routing not implemented.
unguard;
}

INT UChannel::ReceivedSequencedBunch(FInBunch& Bunch)
{
guard(UChannel::ReceivedSequencedBunch);
return 0;
unguard;
}

INT UChannel::RouteDestroy()
{
guard(UChannel::RouteDestroy);
return 0;
unguard;
}

// =============================================================================

// =============================================================================
// UChannel virtuals (moved from EngineClassImpl.cpp)
// =============================================================================

// UChannel
// ---------------------------------------------------------------------------
void UChannel::StaticConstructor()
{
guard(UChannel::StaticConstructor);
unguard;
}

void UChannel::ReceivedBunch(FInBunch& Bunch)
{
guard(UChannel::ReceivedBunch);
unguard;
}

void UChannel::Serialize(const TCHAR* Name, EName Type)
{
guard(UChannel::Serialize);
unguard;
}

// ---------------------------------------------------------------------------

// ============================================================================
// FInBunch / FOutBunch implementations
// (moved from EngineStubs.cpp)
// ============================================================================

// ============================================================================
// FInBunch
// ============================================================================
// DIVERGENCE: retail calls FBitReader copy-ctor then sets vtable + individual fields
//             (offsets 0x54-0x6e).  We memcpy the whole object; FBitReader internals
//             that reference allocated memory may alias incorrectly at runtime.
FInBunch::FInBunch(const FInBunch& Other) : FBitReader() { appMemcpy(this, &Other, sizeof(*this)); }
// DIVERGENCE: retail calls FBitReader(nullptr, 0) then sets vtable, Connection (0x5c),
//             BunchIndex (0x58=0), TimeoutTime (0x38=10000).  We zero Pad instead.
FInBunch::FInBunch(UNetConnection*) : FBitReader() { appMemzero(Pad, sizeof(Pad)); }
FInBunch& FInBunch::operator=(const FInBunch& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }
FArchive& FInBunch::operator<<(UObject*& Obj) { return *this; }
FArchive& FInBunch::operator<<(FName& N) { return *this; }

// ============================================================================
// FOutBunch
// ============================================================================
// DIVERGENCE: retail calls FBitWriter(0) + sets vtable.  We zero the whole object.
FOutBunch::FOutBunch() { appMemzero(this, sizeof(*this)); }
// DIVERGENCE: retail calls FBitWriter copy-ctor then sets vtable + individual fields
//             (offsets 0x54-0x7a).  We memcpy; same aliasing caveat as FInBunch above.
FOutBunch::FOutBunch(const FOutBunch& Other) { appMemcpy(this, &Other, sizeof(*this)); }
// DIVERGENCE: retail calls FBitWriter(connection->MaxPacket*8-81), sets Channel (0x58),
//             ChIndex (0x68), ChSequence (0x6c), flags (0x78-0x7a), validates assertions.
FOutBunch::FOutBunch(UChannel*, INT) { appMemzero(this, sizeof(*this)); }
FOutBunch::~FOutBunch() {}
FArchive& FOutBunch::operator<<(UObject*& Obj) { return *(FArchive*)this; }
FArchive& FOutBunch::operator<<(FName& N) { return *(FArchive*)this; }
