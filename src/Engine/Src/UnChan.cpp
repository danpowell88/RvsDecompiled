/*=============================================================================
UnChan.cpp: Network channel implementations (UChannel hierarchy)
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

// --- UChannel ---

IMPL_MATCH("Engine.dll", 0x1802C0)
INT UChannel::SendBunch(FOutBunch*, INT)
{
guard(UChannel::SendBunch);
return 0;
unguard;
}


// --- UFileChannel ---
IMPL_MATCH("Engine.dll", 0x7A530)
void UFileChannel::StaticConstructor()
{
guard(UFileChannel::StaticConstructor);
*(INT*)((BYTE*)this + 0x48) = 3;  // ChType = CHTYPE_File
unguard;
}

IMPL_MATCH("Engine.dll", 0x181460)
void UFileChannel::Tick()
{
guard(UFileChannel::Tick);
// TODO: implement UFileChannel::Tick (retail 453 bytes: file-sending tick)
unguard;
}

IMPL_MATCH("Engine.dll", 0x181890)
void UFileChannel::ReceivedBunch(FInBunch&)
{
guard(UFileChannel::ReceivedBunch);
// TODO: implement UFileChannel::ReceivedBunch (retail 1243 bytes: receive handler)
unguard;
}

IMPL_MATCH("Engine.dll", 0x181660)
FString UFileChannel::Describe()
{
return FString();
}

IMPL_MATCH("Engine.dll", 0x184100)
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

IMPL_MATCH("Engine.dll", 0x180f30)
void UFileChannel::Init(UNetConnection* Conn, int ChIndex, int InType)
{
// Retail: 0x180f30. Just delegates to UChannel::Init.
UChannel::Init(Conn, ChIndex, InType);
}


// --- UActorChannel ---
IMPL_MATCH("Engine.dll", 0x7A4A0)
void UActorChannel::StaticConstructor()
{
guard(UActorChannel::StaticConstructor);
*(INT*)((BYTE*)this + 0x48) = 2;  // ChType = CHTYPE_Actor
unguard;
}

IMPL_MATCH("Engine.dll", 0x180D50)
void UActorChannel::Tick()
{
guard(UActorChannel::Tick);
UChannel::Tick();
unguard;
}

IMPL_MATCH("Engine.dll", 0x1827F0)
void UActorChannel::ReceivedBunch(FInBunch&)
{
guard(UActorChannel::ReceivedBunch);
// TODO: implement UActorChannel::ReceivedBunch (complex actor replication receive)
unguard;
}

IMPL_MATCH("Engine.dll", 0x1824D0)
void UActorChannel::ReceivedNak(int NakPacketId)
{
guard(UActorChannel::ReceivedNak);
UChannel::ReceivedNak(NakPacketId);
// Divergence: actor replication NAK handling (FUN_10481dd0) not implemented.
unguard;
}

IMPL_MATCH("Engine.dll", 0x1834D0)
void UActorChannel::ReplicateActor()
{
guard(UActorChannel::ReplicateActor);
// TODO: implement UActorChannel::ReplicateActor (complex actor replication)
unguard;
}

IMPL_MATCH("Engine.dll", 0x182590)
void UActorChannel::SetChannelActor(AActor*)
{
guard(UActorChannel::SetChannelActor);
// TODO: implement UActorChannel::SetChannelActor (actor channel setup)
unguard;
}

IMPL_MATCH("Engine.dll", 0x1821D0)
void UActorChannel::SetClosingFlag()
{
// Ghidra 0x1821d0: if actor ref at +0x6C is present, call FUN_10481e90 to flush
// replication state, then call UChannel::SetClosingFlag.
// Divergence: FUN_10481e90 (replication flush) not implemented; just delegate.
UChannel::SetClosingFlag();
}

IMPL_MATCH("Engine.dll", 0x1813e0)
void UActorChannel::Close()
{
// Ghidra 0x1813e0: UChannel::Close then zero the actor reference at this+0x6C.
UChannel::Close();
*(INT*)((BYTE*)this + 0x6C) = 0;
}

IMPL_MATCH("Engine.dll", 0x180DC0)
FString UActorChannel::Describe()
{
return FString();
}

IMPL_MATCH("Engine.dll", 0x182260)
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
				// FUN_103db080 = UActorChannel_CleanupActorRef() — zero actor ref and deregister from level.
				// TODO: implement actor-channel teardown (FUN_103db080 = UActorChannel_CleanupActorRef); actor ref
				// leaks on client-side channel destroy (safe since level is being torn down).
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

IMPL_EMPTY("Ghidra VA 0x103705A0 (RVA 0x705A0) confirms retail body is trivial (4 bytes)")
AActor* UActorChannel::GetActor()
{
// Ghidra (4B): Actor at offset 0x6C
return *(AActor**)((BYTE*)this + 0x6C);
}

IMPL_MATCH("Engine.dll", 0x180C90)
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
IMPL_MATCH("Engine.dll", 0x7A410)
void UControlChannel::StaticConstructor()
{
guard(UControlChannel::StaticConstructor);
*(INT*)((BYTE*)this + 0x48) = 1;  // ChType = CHTYPE_Control
unguard;
}

IMPL_MATCH("Engine.dll", 0x1809E0)
void UControlChannel::ReceivedBunch(FInBunch&)
{
guard(UControlChannel::ReceivedBunch);
// TODO: implement UControlChannel::ReceivedBunch (complex control message handling)
unguard;
}

IMPL_MATCH("Engine.dll", 0x180AD0)
void UControlChannel::Serialize(const TCHAR*, EName)
{
guard(UControlChannel::Serialize);
// TODO: implement UControlChannel::Serialize (complex control serialization)
unguard;
}

IMPL_MATCH("Engine.dll", 0x180BC0)
FString UControlChannel::Describe()
{
return FString();
}

IMPL_MATCH("Engine.dll", 0x182070)
void UControlChannel::Destroy()
{
// Ghidra 0x182070: assert Connection at +0x2C, call RouteDestroy.
// If returns 0: assert Channels[ChIndex]==this, call UChannel::Destroy.
check(*(INT*)((BYTE*)this + 0x2C) != 0); // Connection must exist
if (RouteDestroy() == 0)
UChannel::Destroy();
}

IMPL_MATCH("Engine.dll", 0x180960)
void UControlChannel::Init(UNetConnection* Conn, int ChIndex, int InType)
{
UChannel::Init(Conn, ChIndex, InType);
}


// =============================================================================
// UChannel (moved from EngineClassImpl.cpp)
// =============================================================================

// UChannel
// =============================================================================

IMPL_MATCH("Engine.dll", 0x181F20)
void UChannel::Destroy() { Super::Destroy(); }

IMPL_MATCH("Engine.dll", 0x17FB60)
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

IMPL_MATCH("Engine.dll", 0x17FC50)
void UChannel::SetClosingFlag() { Closing = 1; }

IMPL_MATCH("Engine.dll", 0x1811F0)
void UChannel::Close()
{
guard(UChannel::Close);
// TODO: implement UChannel::Close (retail 252 bytes: close bunch creation)
unguard;
}

IMPL_MATCH("Engine.dll", 0x1806C0)
FString UChannel::Describe()
{
guard(UChannel::Describe);
return FString();
unguard;
}

IMPL_MATCH("Engine.dll", 0x180850)
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

IMPL_MATCH("Engine.dll", 0x17FD90)
void UChannel::Tick()
{
guard(UChannel::Tick);
// TODO: implement UChannel::Tick (retail 247 bytes: resend timer logic)
unguard;
}

IMPL_MATCH("Engine.dll", 0x17FEC0)
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

IMPL_MATCH("Engine.dll", 0x180820)
INT CDECL UChannel::IsKnownChannelType(INT Type)
{
if (Type >= 0 && Type < 8 && UChannel::ChannelClasses[Type])
return 1;
return 0;
}

IMPL_MATCH("Engine.dll", 0x180780)
INT UChannel::IsNetReady( INT Saturate ) { return 1; }

IMPL_MATCH("Engine.dll", 0x181320)
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

IMPL_MATCH("Engine.dll", 0x17FC60)
void UChannel::ReceivedAcks()
{
guard(UChannel::ReceivedAcks);
// TODO: implement UChannel::ReceivedAcks (retail 244 bytes: acked-bunch cleanup)
unguard;
}

IMPL_MATCH("Engine.dll", 0x180070)
void UChannel::ReceivedRawBunch(FInBunch& Bunch)
{
guard(UChannel::ReceivedRawBunch);
// TODO: implement UChannel::ReceivedRawBunch (complex raw bunch routing)
unguard;
}

IMPL_MATCH("Engine.dll", 0x17FF60)
INT UChannel::ReceivedSequencedBunch(FInBunch& Bunch)
{
guard(UChannel::ReceivedSequencedBunch);
return 0;
unguard;
}

IMPL_MATCH("Engine.dll", 0x17FB90)
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
IMPL_DIVERGE("base no-op; channel type registration not implemented — not in Engine.dll Ghidra index")
void UChannel::StaticConstructor()
{
guard(UChannel::StaticConstructor);
unguard;
}

IMPL_DIVERGE("base no-op — subclass implements — not in Engine.dll Ghidra index")
void UChannel::ReceivedBunch(FInBunch& Bunch)
{
guard(UChannel::ReceivedBunch);
unguard;
}

IMPL_DIVERGE("base no-op — subclass implements — not in Engine.dll Ghidra index")
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
IMPL_MATCH("Engine.dll", 0x6FA90)
FInBunch::FInBunch(const FInBunch& Other) : FBitReader() { appMemcpy(this, &Other, sizeof(*this)); }
// DIVERGENCE: retail calls FBitReader(nullptr, 0) then sets vtable, Connection (0x5c),
//             BunchIndex (0x58=0), TimeoutTime (0x38=10000).  We zero Pad instead.
IMPL_MATCH("Engine.dll", 0x17F6B0)
FInBunch::FInBunch(UNetConnection*) : FBitReader() { appMemzero(Pad, sizeof(Pad)); }
IMPL_MATCH("Engine.dll", 0x6FAF0)
FInBunch& FInBunch::operator=(const FInBunch& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }
IMPL_MATCH("Engine.dll", 0x17F6E0)
FArchive& FInBunch::operator<<(UObject*& Obj) { return *this; }
IMPL_MATCH("Engine.dll", 0x17F770)
FArchive& FInBunch::operator<<(FName& N) { return *this; }

// ============================================================================
// FOutBunch
// ============================================================================
// DIVERGENCE: retail calls FBitWriter(0) + sets vtable.  We zero the whole object.
IMPL_MATCH("Engine.dll", 0x6F960)
FOutBunch::FOutBunch() { appMemzero(this, sizeof(*this)); }
// DIVERGENCE: retail calls FBitWriter copy-ctor then sets vtable + individual fields
//             (offsets 0x54-0x7a).  We memcpy; same aliasing caveat as FInBunch above.
IMPL_MATCH("Engine.dll", 0x17F800)
FOutBunch::FOutBunch(const FOutBunch& Other) { appMemcpy(this, &Other, sizeof(*this)); }
// DIVERGENCE: retail calls FBitWriter(connection->MaxPacket*8-81), sets Channel (0x58),
//             ChIndex (0x68), ChSequence (0x6c), flags (0x78-0x7a), validates assertions.
IMPL_MATCH("Engine.dll", 0x17F820)
FOutBunch::FOutBunch(UChannel*, INT) { appMemzero(this, sizeof(*this)); }
IMPL_MATCH("Engine.dll", 0x6F950)
FOutBunch::~FOutBunch() {}
IMPL_MATCH("Engine.dll", 0x17F930)
FArchive& FOutBunch::operator<<(UObject*& Obj) { return *(FArchive*)this; }
IMPL_MATCH("Engine.dll", 0x17F9C0)
FArchive& FOutBunch::operator<<(FName& N) { return *(FArchive*)this; }

// --- Moved from EngineStubs.cpp ---
UClass** UChannel::ChannelClasses = NULL;
