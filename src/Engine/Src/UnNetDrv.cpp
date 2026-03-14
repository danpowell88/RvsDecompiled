/*=============================================================================
UnNetDrv.cpp: Network driver (UNetDriver, UDemoRecDriver)
Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#pragma warning(push)
#pragma warning(disable: 4291)
IMPL_INFERRED("Reconstructed from context")
inline void* operator new(size_t, void* p) noexcept { return p; }
IMPL_INFERRED("Reconstructed from context")
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// --- UNetDriver ---
IMPL_TODO("Needs Ghidra analysis")
void UNetDriver::StaticConstructor()
{
guard(UNetDriver::StaticConstructor);
unguard;
}

IMPL_GHIDRA("Engine.dll", 0x18b820)
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

IMPL_INFERRED("Advances network time and prunes timed-out client connections")
void UNetDriver::TickDispatch(float DeltaSeconds)
{
guard(UNetDriver::TickDispatch);
*(double*)((BYTE*)this + 0x48) += (double)DeltaSeconds;
*(INT*)((BYTE*)this + 0x88) = 0;
*(INT*)((BYTE*)this + 0x84) = 0;
if (*(INT*)((BYTE*)this + 0x3C) == 0)
{
INT cnt = *(INT*)((BYTE*)this + 0x34);
for (INT i = cnt - 1; i >= 0; i--)
{
INT* conn = *(INT**)(*(INT*)((BYTE*)this + 0x30) + i * 4);
if (conn && *(INT*)((BYTE*)conn + 0x80) == 1)
{
typedef void (__thiscall* DestroyFn)(void*, INT);
((DestroyFn)(*(void**)(*conn + 0x0C)))(conn, 1);
}
}
}
unguard;
}

IMPL_GHIDRA_APPROX("Engine.dll", 0x1048C210, "object-ref fields not serialized; transactor helper not yet identified")
void UNetDriver::Serialize(FArchive &Ar)
{
guard(UNetDriver::Serialize);
// Ghidra 0x1048C210: UObject::Serialize, then a conditional-transact helper (RVA 0x18BFA0)
// that returns a filtered archive, then serializes fields at +0x3C,+0x44,+0x7C,+0x80.
UObject::Serialize(Ar);
// NOTE: Divergence -- object-ref fields (+0x3C ServerConnection, +0x44, +0x7C, +0x80) not serialized;
// full implementation requires transactor helper identification.
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UNetDriver::NotifyActorDestroyed(AActor* Actor)
{
guard(UNetDriver::NotifyActorDestroyed);
// Ghidra 0x18c2d0: for each client connection, if actor has open channel
// (ServerConnection or ClientConnections TArray at +0x30), close it.
// TODO: resolve FUN_103b7b70 for actor channel tracking in NotifyActorDestroyed
(void)Actor;
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UNetDriver::AssertValid()
{
guard(UNetDriver::AssertValid);
unguard;
}

IMPL_INFERRED("Destroys server/client connections and calls LowLevelDestroy via vtable")
void UNetDriver::Destroy()
{
guard(UNetDriver::Destroy);
typedef void (__thiscall* VtableDestroy)(void*, INT);
typedef void (__thiscall* VtableLLD)(void*);
INT* serverConn = *(INT**)((BYTE*)this + 0x3C);
if (serverConn)
((VtableDestroy)(*(void**)(*serverConn + 0x0C)))(serverConn, 1);
while (*(INT*)((BYTE*)this + 0x34) != 0)
{
INT* conn = *(INT**)(*(INT*)((BYTE*)this + 0x30));
if (conn)
((VtableDestroy)(*(void**)(*conn + 0x0C)))(conn, 1);
else
break;
}
((VtableLLD)(*(void**)(*(INT*)this + 0x68)))(this);
INT* masterConn = *(INT**)((BYTE*)this + 0x44);
if (masterConn)
((VtableDestroy)(*(void**)(*masterConn + 0x0C)))(masterConn, 1);
Super::Destroy();
unguard;
}

IMPL_INFERRED("Stores Notify pointer; base implementation")
int UNetDriver::InitConnect(FNetworkNotify* Notify, FURL& URL, FString& Error)
{
guard(UNetDriver::InitConnect);
*(FNetworkNotify**)((BYTE*)this + 0x40) = Notify;
return 1;
unguard;
}

IMPL_INFERRED("Stores Notify pointer; base implementation")
int UNetDriver::InitListen(FNetworkNotify* Notify, FURL& URL, FString& Error)
{
guard(UNetDriver::InitListen);
*(FNetworkNotify**)((BYTE*)this + 0x40) = Notify;
return 1;
unguard;
}


// --- UDemoRecDriver ---
IMPL_TODO("Needs Ghidra analysis")
void UDemoRecDriver::SpawnDemoRecSpectator(UNetConnection*)
{
guard(UDemoRecDriver::SpawnDemoRecSpectator);
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UDemoRecDriver::StaticConstructor()
{
guard(UDemoRecDriver::StaticConstructor);
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UDemoRecDriver::TickDispatch(float)
{
guard(UDemoRecDriver::TickDispatch);
// TODO: implement UDemoRecDriver::TickDispatch (complex demo playback)
unguard;
}

IMPL_INFERRED("Destroys demo file object via vtable destructor")
void UDemoRecDriver::LowLevelDestroy()
{
guard(UDemoRecDriver::LowLevelDestroy);
debugf(NAME_DevNet, TEXT("UDemoRecDriver LowLevelDestroy"));
INT* demoFile = *(INT**)((BYTE*)this + 0xb4);
if (demoFile)
{
typedef void (__thiscall* VDtor)(void*);
((VDtor)(*(void**)*demoFile))(demoFile);
*(INT*)((BYTE*)this + 0xb4) = 0;
}
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
FString UDemoRecDriver::LowLevelGetNetworkNumber()
{
return FString();
}

IMPL_TODO("Needs Ghidra analysis")
int UDemoRecDriver::Exec(const TCHAR*, FOutputDevice&)
{
guard(UDemoRecDriver::Exec);
return 0;
unguard;
}

IMPL_INFERRED("Returns level from Notify; asserts validity")
ULevel* UDemoRecDriver::GetLevel()
{
guard(UDemoRecDriver::GetLevel);
FNetworkNotify* notify = *(FNetworkNotify**)((BYTE*)this + 0x40);
if (!notify)
appFailAssert("Notify", ".\\UnDemoRec.cpp", 0x161);
ULevel* lev = notify->NotifyGetLevel();
if (!lev)
appFailAssert("Notify->NotifyGetLevel()", ".\\UnDemoRec.cpp", 0x161);
return lev;
unguard;
}

IMPL_INFERRED("Initialises demo filename and resets counters")
int UDemoRecDriver::InitBase(int, FNetworkNotify*, FURL& InURL, FString&)
{
guard(UDemoRecDriver::InitBase);
// Copy FURL.Map (offset 0x1C within FURL) to DemoFileName at this+0x9C.
*(FString*)((BYTE*)this + 0x9C) = *(FString*)((BYTE*)&InURL + 0x1C);
*(double*)((BYTE*)this + 0x48) = 0.0;
*(INT*)((BYTE*)this + 0xCC) = 0;
*(INT*)((BYTE*)this + 0xC4) = 0;
return 1;
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
int UDemoRecDriver::InitConnect(FNetworkNotify*, FURL&, FString&)
{
guard(UDemoRecDriver::InitConnect);
return 0;
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
int UDemoRecDriver::InitListen(FNetworkNotify*, FURL&, FString&)
{
guard(UDemoRecDriver::InitListen);
return 0;
unguard;
}


// =============================================================================
// UNetConnection (moved from EngineClassImpl.cpp)
// =============================================================================

// UNetConnection
// =============================================================================

IMPL_TODO("Needs Ghidra analysis")
UNetConnection::UNetConnection( UNetDriver* InDriver, const FURL& InURL ) {}

IMPL_TODO("Needs Ghidra analysis")
INT UNetConnection::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
guard(UNetConnection::Exec);
return 0;
unguard;
}

IMPL_GHIDRA("Engine.dll", 0x184540)
void UNetConnection::Serialize(const TCHAR* Data, EName Event)
{
guard(UNetConnection::Serialize);
// Ghidra 0x184540: get associated output object at this+0xe84.
// If non-null and not closing (field+0x34==0), call Serialize via vtable[0] at +0x68.
INT* logObj = *(INT**)((BYTE*)this + 0xe84);
if (logObj && *(INT*)((BYTE*)logObj + 0x34) == 0)
{
typedef void (__thiscall* SerFn)(void*, const TCHAR*, EName);
void* fdOut = (void*)((BYTE*)logObj + 0x68);
SerFn fn = *(SerFn*)*(void**)fdOut;
fn(fdOut, Data, Event);
}
unguard;
}

IMPL_INFERRED("Delegates to Super::Destroy")
void UNetConnection::Destroy() { Super::Destroy(); }

IMPL_INFERRED("Serialises PackageMap, all channel objects, and download object")
void UNetConnection::Serialize(FArchive& Ar)
{
guard(UNetConnection::Serialize);
Super::Serialize(Ar);
// PackageMap at +0xC8; channel objects at +0xeb0 (0x50f entries); download at +0x4ba8.
Ar << *(UObject**)((BYTE*)this + 0xC8);
for (INT i = 0; i < 0x50f; i++)
Ar << *(UObject**)((BYTE*)this + i * 4 + 0xeb0);
Ar << *(UObject**)((BYTE*)this + 0x4ba8);
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UNetConnection::ReadInput(FLOAT DeltaSeconds)
{
guard(UNetConnection::ReadInput);
unguard;
}

IMPL_INFERRED("Initialises the output bit-writer to MaxPacket size")
void UNetConnection::InitOut()
{
guard(UNetConnection::InitOut);
FBitWriter TempWriter(*(INT*)((BYTE*)this + 0xD0) << 3);
*(FBitWriter*)((BYTE*)this + 0x250) = TempWriter;
unguard;
}

IMPL_INFERRED("Validates protocol version and connection state")
void UNetConnection::AssertValid()
{
guard(UNetConnection::AssertValid);
INT ProtVer = *(INT*)((BYTE*)this + 0xCC);
if (ProtVer < 1)
appFailAssert("ProtocolVersion>=MIN_PROTOCOL_VERSION", ".\\UnConn.cpp", 0x93);
if (ProtVer > 1)
appFailAssert("ProtocolVersion<=MAX_PROTOCOL_VERSION", ".\\UnConn.cpp", 0x94);
INT State = *(INT*)((BYTE*)this + 0x80);
if (State != 1 && State != 2 && State != 3)
appFailAssert("State==USOCK_Closed || State==USOCK_Pending || State==USOCK_Open", ".\\UnConn.cpp", 0x95);
unguard;
}

IMPL_INFERRED("Sends ACK packet; queues pending ack if RemotePacketId is non-zero")
void UNetConnection::SendAck(INT PacketId, INT RemotePacketId)
{
guard(UNetConnection::SendAck);
if (*(INT*)((BYTE*)this + 0xD8) == 0)
{
if (RemotePacketId != 0)
{
PurgeAcks();
TArray<INT>& AckPending = *(TArray<INT>*)((BYTE*)this + 0x4b64);
INT idx = AckPending.Add(1);
AckPending(idx) = PacketId;
}
BYTE bits = appCeilLogTwo(0x4000);
PreSend((INT)bits + 1);
FBitWriter& Out = *(FBitWriter*)((BYTE*)this + 0x250);
Out.WriteBit(1);
Out.WriteInt(PacketId, 0x4000);
*(INT*)((BYTE*)this + 0x130) = 0;
PostSend();
}
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UNetConnection::FlushNet()
{
guard(UNetConnection::FlushNet);
// TODO: implement UNetConnection::FlushNet (retail 1146 bytes: complex packet assembly)
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UNetConnection::Tick()
{
guard(UNetConnection::Tick);
// TODO: implement UNetConnection::Tick (retail 1628 bytes: complex tick)
unguard;
}

IMPL_INFERRED("Always returns ready")
INT UNetConnection::IsNetReady( INT Saturate ) { return 1; }

IMPL_TODO("Needs Ghidra analysis")
void UNetConnection::HandleClientPlayer(APlayerController* PC)
{
guard(UNetConnection::HandleClientPlayer);
unguard;
}

IMPL_INFERRED("Returns Driver field")
UNetDriver* UNetConnection::GetDriver() { return Driver; }

IMPL_INFERRED("Flushes output if adding bits would overflow MaxPacket; writes packet header")
void UNetConnection::PreSend( INT SizeBits )
{
// Out(FBitWriter) at offset 0x250, MaxPacket(INT) at offset 0xD0
FBitWriter& Out = *(FBitWriter*)((BYTE*)this + 0x250);
INT MaxPacket = *(INT*)((BYTE*)this + 0xD0);
// If adding SizeBits + 1 bit would overflow, flush first.
if (Out.GetNumBits() + 1 + SizeBits > MaxPacket * 8)
FlushNet();
// If Out is empty, write packet header (OutPacketId at 0xEA8).
if (Out.GetNumBits() == 0)
{
Out.WriteInt(*(DWORD*)((BYTE*)this + 0xEA8), 0x4000);
if (Out.GetNumBits() > 16)
appFailAssert("Out.GetNumBits()<=MAX_PACKET_HEADER_BITS", ".\\UnConn.cpp", 0x2A4);
}
// Final overflow check.
if (Out.GetNumBits() + 1 + SizeBits > MaxPacket * 8)
appErrorf(TEXT("PreSend overflow: %i+%i>%i"), Out.GetNumBits(), SizeBits, MaxPacket * 8);
}

IMPL_INFERRED("Flushes pending ACK queue")
void UNetConnection::PurgeAcks()
{
guard(UNetConnection::PurgeAcks);
TArray<INT>& AckQueue = *(TArray<INT>*)((BYTE*)this + 0x4b70);
for (INT i = 0; i < AckQueue.Num(); i++)
SendAck(AckQueue(i), 0);
AckQueue.Empty();
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UNetConnection::ReceiveFile(INT PackageIndex)
{
guard(UNetConnection::ReceiveFile);
unguard;
}

IMPL_INFERRED("Propagates NAK to dirty channels")
void UNetConnection::ReceivedNak(INT NakPacketId)
{
guard(UNetConnection::ReceivedNak);
TArray<UChannel*>& DirtyChans = *(TArray<UChannel*>*)((BYTE*)this + 0x4b7c);
for (INT i = DirtyChans.Num() - 1; i >= 0; i--)
{
UChannel* ch = DirtyChans(i);
ch->ReceivedNak(NakPacketId);
if (ch->OpenPacketId == NakPacketId)
ch->ReceivedAcks();
}
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UNetConnection::ReceivedPacket(FBitReader& Reader)
{
guard(UNetConnection::ReceivedPacket);
// TODO: implement UNetConnection::ReceivedPacket (very complex packet processing)
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UNetConnection::ReceivedRawPacket(void* Data, INT Count)
{
guard(UNetConnection::ReceivedRawPacket);
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UNetConnection::SendPackageMap()
{
guard(UNetConnection::SendPackageMap);
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
INT UNetConnection::SendRawBunch(FOutBunch& Bunch, INT InPacketId)
{
guard(UNetConnection::SendRawBunch);
return 0;
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UNetConnection::SetActorDirty(AActor* Actor)
{
guard(UNetConnection::SetActorDirty);
// TODO: resolve FUN_103b7b70 (actor channel lookup) to implement SetActorDirty
(void)Actor;
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UNetConnection::SlowAssertValid()
{
guard(UNetConnection::SlowAssertValid);
unguard;
}

// =============================================================================

// =============================================================================
// UNetDriver (moved from EngineClassImpl.cpp)
// =============================================================================

// UNetDriver
// ---------------------------------------------------------------------------
IMPL_TODO("Needs Ghidra analysis")
UBOOL UNetDriver::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
guard(UNetDriver::Exec);
return 0;
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UNetDriver::LowLevelDestroy()
{
guard(UNetDriver::LowLevelDestroy);
unguard;
}

IMPL_TODO("Needs Ghidra analysis")
FString UNetDriver::LowLevelGetNetworkNumber()
{
return FString();
}

// ---------------------------------------------------------------------------
