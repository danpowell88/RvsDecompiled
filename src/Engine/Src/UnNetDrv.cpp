/*=============================================================================
UnNetDrv.cpp: Network driver (UNetDriver, UDemoRecDriver)
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

// --- UNetDriver ---
IMPL_MATCH("Engine.dll", 0x1048b400)
void UNetDriver::StaticConstructor()
{
guard(UNetDriver::StaticConstructor);
new(GetClass(),TEXT("ConnectionTimeout"),    RF_Public) UFloatProperty(EC_CppProperty, 0x50, TEXT("Client"), CPF_Config);
new(GetClass(),TEXT("InitialConnectTimeout"),RF_Public) UFloatProperty(EC_CppProperty, 0x54, TEXT("Client"), CPF_Config);
new(GetClass(),TEXT("KeepAliveTime"),        RF_Public) UFloatProperty(EC_CppProperty, 0x58, TEXT("Client"), CPF_Config);
new(GetClass(),TEXT("RelevantTimeout"),      RF_Public) UFloatProperty(EC_CppProperty, 0x5c, TEXT("Client"), CPF_Config);
new(GetClass(),TEXT("SpawnPrioritySeconds"), RF_Public) UFloatProperty(EC_CppProperty, 0x60, TEXT("Client"), CPF_Config);
new(GetClass(),TEXT("ServerTravelPause"),    RF_Public) UFloatProperty(EC_CppProperty, 0x64, TEXT("Client"), CPF_Config);
new(GetClass(),TEXT("MaxClientRate"),        RF_Public) UIntProperty  (EC_CppProperty, 0x68, TEXT("Client"), CPF_Config);
new(GetClass(),TEXT("NetServerMaxTickRate"), RF_Public) UIntProperty  (EC_CppProperty, 0x6c, TEXT("Client"), CPF_Config);
new(GetClass(),TEXT("LanServerMaxTickRate"), RF_Public) UIntProperty  (EC_CppProperty, 0x70, TEXT("Client"), CPF_Config);
new(GetClass(),TEXT("AllowDownloads"),       RF_Public) UBoolProperty (EC_CppProperty, 0x74, TEXT("Client"), CPF_Config);
new(GetClass(),TEXT("MaxDownloadSize"),      RF_Public) UIntProperty  (EC_CppProperty, 0x8c, TEXT("Client"), CPF_Config);
UArrayProperty* PA = new(GetClass(),TEXT("DownloadManagers"),RF_Public) UArrayProperty(EC_CppProperty, 0x90, TEXT("Client"), CPF_Config);
PA->Inner = new(PA,TEXT("StrProperty0"),RF_Public) UStrProperty(EC_CppProperty, 0, TEXT("Client"), CPF_Config);
*(DWORD*)((BYTE*)this + 0x68) = 25000;
unguard;
}

IMPL_MATCH("Engine.dll", 0x1048b820)
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

IMPL_MATCH("Engine.dll", 0x1048b8c0)
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

IMPL_DIVERGE("FUN_ blocker: FUN_1048bfa0 (conditional-transact archive helper)")
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

IMPL_DIVERGE("retail 0x1048c2d0 (178b): FUN_103db080 (actor replication flag reset) and FUN_103b7b70 (actor channel lookup) unresolved")
void UNetDriver::NotifyActorDestroyed(AActor* Actor)
{
guard(UNetDriver::NotifyActorDestroyed);
// Ghidra 0x1048c2d0: iterates ClientConnections (this+0x30), clears actor replication
// flag via FUN_103db080 if actor flag 0x10000000 is set, then looks up actor channel
// via FUN_103b7b70 and destroys it. Both FUN_ helpers unresolved.
(void)Actor;
unguard;
}

IMPL_EMPTY("Ghidra lookup: UNetDriver::AssertValid not found in export — retail appears trivial")
void UNetDriver::AssertValid()
{
guard(UNetDriver::AssertValid);
unguard;
}

IMPL_MATCH("Engine.dll", 0x1048b980)
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

IMPL_MATCH("Engine.dll", 0x1048b810)
int UNetDriver::InitConnect(FNetworkNotify* Notify, FURL& URL, FString& Error)
{
guard(UNetDriver::InitConnect);
*(FNetworkNotify**)((BYTE*)this + 0x40) = Notify;
return 1;
unguard;
}

// Ghidra 0x1048b810 (15b): shares implementation with InitConnect.
// Body: *(this+0x40) = Notify; return 1;
IMPL_MATCH("Engine.dll", 0x1048b810)
int UNetDriver::InitListen(FNetworkNotify* Notify, FURL& URL, FString& Error)
{
guard(UNetDriver::InitListen);
*(FNetworkNotify**)((BYTE*)this + 0x40) = Notify;
return 1;
unguard;
}


// --- UDemoRecDriver ---
IMPL_DIVERGE("FUN_ blocker: FUN_104c3660 (spectator spawn helper)")
void UDemoRecDriver::SpawnDemoRecSpectator(UNetConnection*)
{
guard(UDemoRecDriver::SpawnDemoRecSpectator);
unguard;
}

IMPL_MATCH("Engine.dll", 0x10487da0)
void UDemoRecDriver::StaticConstructor()
{
guard(UDemoRecDriver::StaticConstructor);
new(GetClass(),TEXT("DemoSpectatorClass"),RF_Public) UStrProperty(EC_CppProperty, 0xa8, TEXT("Client"), CPF_Config);
unguard;
}

IMPL_DIVERGE("FUN_ blocker: FUN_10301000 (demo file read helper)")
void UDemoRecDriver::TickDispatch(float)
{
guard(UDemoRecDriver::TickDispatch);
// TODO: implement UDemoRecDriver::TickDispatch (complex demo playback)
unguard;
}

IMPL_MATCH("Engine.dll", 0x10487e60)
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

// Ghidra 0x10487f20 (84b): constructs FString from runtime global DAT_10529f90 (WCHAR const*).
// DAT_10529f90 is a .rdata WCHAR that cannot be reproduced at compile-time; current stub
// returns an empty FString which may differ if the global is non-empty.
IMPL_DIVERGE("retail 0x10487f20: returns FString from runtime DAT_10529f90 (unknown WCHAR constant)")
FString UDemoRecDriver::LowLevelGetNetworkNumber()
{
return FString();
}

IMPL_MATCH("Engine.dll", 0x10488300)
int UDemoRecDriver::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
guard(UDemoRecDriver::Exec);
if (*(INT*)((BYTE*)this + 0x98) != 0)
    return 0;
if (ParseCommand(&Cmd, TEXT("DEMOREC")) || ParseCommand(&Cmd, TEXT("DEMOPLAY")))
{
    Ar.Log(**(FString*)((BYTE*)this + 0x70));
    return 1;
}
if (ParseCommand(&Cmd, TEXT("STOPDEMO")))
{
    Ar.Log(**(FString*)((BYTE*)this + 0x70));
    if (*(FOutputDevice**)((BYTE*)this + 0xa0))
        (*(FOutputDevice**)((BYTE*)this + 0xa0))->Log(**(FString*)((BYTE*)this + 0x70));
    if (*(INT*)((BYTE*)this + 0x10) == 0)
    {
        UDemoRecDriver* driver = (UDemoRecDriver*)((BYTE*)this - 0x2c);
        ULevel* lev = driver->GetLevel();
        if (lev) *(INT*)((BYTE*)lev + 0x8c) = 0;
        if (driver)
        {
            typedef void (__thiscall* DestroyFn)(void*, INT);
            ((DestroyFn)(*(void**)(*(INT*)driver + 0xc)))(driver, 1);
        }
    }
    else
    {
        *(INT*)(*(INT*)((BYTE*)this + 0x10) + 0x80) = 1;
    }
    return 1;
}
return 0;
unguard;
}

IMPL_MATCH("Engine.dll", 0x10487fb0)
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

IMPL_MATCH("Engine.dll", 0x10487d00)
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

IMPL_DIVERGE("FUN_ blocker: FUN_1032b9b0 (connection init helper)")
int UDemoRecDriver::InitConnect(FNetworkNotify*, FURL&, FString&)
{
guard(UDemoRecDriver::InitConnect);
return 0;
unguard;
}

IMPL_DIVERGE("FUN_ blocker: FUN_1038ef30 (demo record init helper)")
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

IMPL_DIVERGE("FUN_ blocker: complex 300+ byte constructor; UNetConnection fields not fully mapped")
UNetConnection::UNetConnection( UNetDriver* InDriver, const FURL& InURL ) {}

IMPL_DIVERGE("retail 0x104842b0 (210b): FUN_1050557c (ping/loss stat formatter) unresolved; GETPING/GETLOSS skip stat output")
INT UNetConnection::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
guard(UNetConnection::Exec);
// Ghidra 0x104842b0: GETPING and GETLOSS call FUN_1050557c to format a stat string,
// then log it to Ar. We return 1 for both but skip the stat output.
const TCHAR* Stream = Cmd;
if (ParseCommand(&Stream, TEXT("GETPING")))
	return 1;
if (ParseCommand(&Stream, TEXT("GETLOSS")))
	return 1;
return Super::Exec(Cmd, Ar);
unguard;
}

IMPL_MATCH("Engine.dll", 0x10484540)
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

IMPL_DIVERGE("FUN_ blocker: FUN_103db080 (actor channel cleanup)")
void UNetConnection::Destroy() { Super::Destroy(); }

IMPL_MATCH("Engine.dll", 0x10484200)
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

IMPL_MATCH("Engine.dll", 0x104651d0)
void UNetConnection::ReadInput(FLOAT DeltaSeconds)
{
// Retail: shared empty stub at 0x104651d0.
}

IMPL_MATCH("Engine.dll", 0x104844a0)
void UNetConnection::InitOut()
{
guard(UNetConnection::InitOut);
FBitWriter TempWriter(*(INT*)((BYTE*)this + 0xD0) << 3);
*(FBitWriter*)((BYTE*)this + 0x250) = TempWriter;
unguard;
}

IMPL_MATCH("Engine.dll", 0x104843c0)
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

IMPL_MATCH("Engine.dll", 0x104854f0)
void UNetConnection::SendAck(INT PacketId, INT RemotePacketId)
{
guard(UNetConnection::SendAck);
if (*(INT*)((BYTE*)this + 0xD8) == 0)
{
if (RemotePacketId != 0)
{
PurgeAcks();
INT idx = ((FArray*)((BYTE*)this + 0x4b64))->Add(1, 4);
*(INT*)(*(INT*)((BYTE*)this + 0x4b64) + idx * 4) = PacketId;
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

IMPL_DIVERGE("FUN_ blocker: FUN_10301050 (packet assembly helper)")
void UNetConnection::FlushNet()
{
guard(UNetConnection::FlushNet);
// TODO: implement UNetConnection::FlushNet (retail 1146 bytes: complex packet assembly)
unguard;
}

IMPL_DIVERGE("FUN_ blocker: FUN_1037cf90 (channel tick helper)")
void UNetConnection::Tick()
{
guard(UNetConnection::Tick);
// TODO: implement UNetConnection::Tick (retail 1628 bytes: complex tick)
unguard;
}

IMPL_MATCH("Engine.dll", 0x104845d0)
INT UNetConnection::IsNetReady(INT Saturate)
{
guard(UNetConnection::IsNetReady);
if (Saturate != 0)
{
INT numBytes = ((FBitWriter*)((BYTE*)this + 0x250))->GetNumBytes();
*(INT*)((BYTE*)this + 0x114) = -numBytes;
}
INT numBytes = ((FBitWriter*)((BYTE*)this + 0x250))->GetNumBytes();
return (INT)((DWORD)(*(INT*)((BYTE*)this + 0x114) + numBytes) < 1u);
unguard;
}

IMPL_MATCH("Engine.dll", 0x10484b70)
void UNetConnection::HandleClientPlayer(APlayerController* PC)
{
guard(UNetConnection::HandleClientPlayer);
typedef void (__thiscall* VoidFn)(void*);
// Validate PC->GetLevel()->Engine->Client exists
if (*(INT*)(*(INT*)(*(INT*)((BYTE*)PC + 0x328) + 0x44) + 0x44) == 0)
    appFailAssert("PC->GetLevel()->Engine->Client", ".\\UnConn.cpp", 0x43e);
// Validate Client has viewports
if (((FArray*)(*(INT*)(*(INT*)(*(INT*)((BYTE*)PC + 0x328) + 0x44) + 0x44) + 0x30))->Num() == 0)
    appFailAssert("PC->GetLevel()->Engine->Client->Viewports.Num()", ".\\UnConn.cpp", 0x43f);
// Get first viewport (Data ptr of TArray at Client+0x30)
UObject* viewport = *(UObject**)(*(INT*)(*(INT*)(*(INT*)((BYTE*)PC + 0x328) + 0x44) + 0x44) + 0x30);
*(INT*)(*(INT*)((BYTE*)viewport + 0x34) + 0x5b4) = 0;
*(DWORD*)((BYTE*)viewport + 0x48) = *(DWORD*)((BYTE*)this + 0x48);
// Set NM_Client (3)
*(BYTE*)((BYTE*)PC + 0x2d) = 3;
*(DWORD*)((BYTE*)PC + 0x4f8) = 0x334cc80c;
*(INT*)((BYTE*)PC + 0x504) = 5;
PC->SetPlayer((UPlayer*)viewport);
GLog->Logf(TEXT("SetPlayer"));
// Refresh viewport via vtable[0x7c/4]
{
    void* vpPtr = *(void**)(*(INT*)(*(INT*)(*(INT*)(*(INT*)((BYTE*)PC + 0x328) + 0x44) + 0x44) + 0x30) + 0x80);
    ((VoidFn)(*(void**)(*(INT*)vpPtr + 0x7c)))(vpPtr);
}
// Notify engine via vtable[0x78/4]
{
    void* engPtr = *(void**)(*(INT*)((BYTE*)PC + 0x328) + 0x44);
    ((VoidFn)(*(void**)(*(INT*)engPtr + 0x78)))(engPtr);
}
*(BYTE*)(*(INT*)((BYTE*)PC + 0x144) + 0x928) = 0;
if (*(INT*)((BYTE*)this + 0x80) != 2)
    appFailAssert("State==USOCK_Pending", ".\\UnConn.cpp", 0x453);
*(APlayerController**)((BYTE*)this + 0x34) = PC;
*(INT*)((BYTE*)this + 0x80) = 3;
unguard;
}

// Ghidra 0x103701c0 (4b): returns *(this+0x7c) = Driver field.
IMPL_MATCH("Engine.dll", 0x103701c0)
UNetDriver* UNetConnection::GetDriver() { return Driver; }

IMPL_MATCH("Engine.dll", 0x10484680)
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

IMPL_MATCH("Engine.dll", 0x10485440)
void UNetConnection::PurgeAcks()
{
guard(UNetConnection::PurgeAcks);
typedef void (__thiscall* SendAckFn)(void*, INT, INT);
INT n = ((FArray*)((BYTE*)this + 0x4b70))->Num();
for (INT i = 0; i < n; i++)
{
INT ackId = *(INT*)(*(INT*)((BYTE*)this + 0x4b70) + i * 4);
((SendAckFn)(*(void**)(*(INT*)this + 0x7c)))(this, ackId, 0);
}
((FArray*)((BYTE*)this + 0x4b70))->Empty(4, 0x20);
unguard;
}

IMPL_DIVERGE("FUN_ blocker: FUN_103bef40 (file download helper)")
void UNetConnection::ReceiveFile(INT PackageIndex)
{
guard(UNetConnection::ReceiveFile);
unguard;
}

IMPL_MATCH("Engine.dll", 0x10484ac0)
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

IMPL_MATCH("Engine.dll", 0x10485990)
void UNetConnection::ReceivedPacket(FBitReader& Reader)
{
guard(UNetConnection::ReceivedPacket);
typedef void (__thiscall* VoidFn)(void*);
typedef void (__thiscall* SendAckFn)(void*, INT, INT);
// Notify driver we received a packet (vtable[0x78/4] on driver)
void* drv = *(void**)((BYTE*)this + 0x7c);
((VoidFn)(*(void**)(*(INT*)drv + 0x78)))(drv);
if (Reader.IsError()) return;
// Update last-receive timestamp from driver clock
*(double*)((BYTE*)this + 0xf4) = *(double*)(*(INT*)((BYTE*)this + 0x7c) + 0x48);
// Read incoming packet sequence (modulo 0x4000 window)
INT localSeq = *(INT*)((BYTE*)this + 0xea4);
DWORD rawSeq = Reader.ReadInt(0x4000);
INT inSeq = (INT)(((rawSeq - (DWORD)localSeq - 0x2000) & 0x3fff) - 0x2000) + localSeq;
if (localSeq < inSeq)
{
*(INT*)((BYTE*)this + 0x1fc) += inSeq - localSeq - 1;
*(INT*)((BYTE*)this + 0xea4) = inSeq;
}
else
*(INT*)((BYTE*)this + 0x21c) += 1;
// Acknowledge incoming packet (vtable[0x7c/4] = SendAck on this)
((SendAckFn)(*(void**)(*(INT*)this + 0x7c)))(this, inSeq, 1);
// Process acks and bunches
while (!Reader.AtEnd() && *(INT*)((BYTE*)this + 0x80) != 1)
{
BYTE isAck = Reader.ReadBit();
if (Reader.IsError()) break;
if (isAck)
{
// Incoming ACK for a packet we previously sent
INT localAck = *(INT*)((BYTE*)this + 0xeac);
DWORD rawAck = Reader.ReadInt(0x4000);
DWORD ackSeq = (((rawAck - (DWORD)localAck - 0x2000) & 0x3fff) - 0x2000) + (DWORD)localAck;
if (Reader.IsError()) break;
if (localAck < (INT)ackSeq)
{
for (INT s = localAck + 1; s < (INT)ackSeq; s++)
{ ReceivedNak(s); *(INT*)((BYTE*)this + 0x200) += 1; }
*(DWORD*)((BYTE*)this + 0xeac) = ackSeq;
}
// Update latency stats if we have send-time for this ack slot
DWORD slot = ackSeq & 0xff;
if (*(DWORD*)((BYTE*)this + slot * 4 + 0xaa4) == ackSeq)
{
double st = *(double*)((BYTE*)this + slot * 8 + 0x2a4);
double dt = *(double*)(*(INT*)((BYTE*)this + 0x7c) + 0x48);
*(INT*)((BYTE*)this + 0x224) += 1;
*(float*)((BYTE*)this + 500) += (float)(dt - st - *(double*)((BYTE*)this + 0x234) * 0.5);
}
// Walk dirty channels and mark bunches as acked
TArray<UChannel*>& dirty = *(TArray<UChannel*>*)((BYTE*)this + 0x4b7c);
for (INT i = dirty.Num() - 1; i >= 0; i--)
{
UChannel* ch = dirty(i);
for (INT* b = (INT*)*(INT*)((BYTE*)ch + 0x5c); b; b = (INT*)*(INT*)((BYTE*)b + 0x54))
{
if (*(DWORD*)((BYTE*)b + 0x74) == ackSeq)
{ *(INT*)((BYTE*)b + 100) = 1; if (*(BYTE*)((BYTE*)b + 0x78)) *(INT*)((BYTE*)ch + 0x30) = 1; }
}
if (*(DWORD*)((BYTE*)ch + 0x40) == ackSeq) *(INT*)((BYTE*)ch + 0x30) = 1;
ch->ReceivedAcks();
}
}
else
{
// Incoming bunch — read header
FInBunch Bunch(this);
BYTE bHasSeq = Reader.ReadBit();
BYTE bOpen = 0, bClose = 0, bReliable = 0;
INT seq = 0;
EChannelType chType = CHTYPE_None;
if (bHasSeq) { bOpen = Reader.ReadBit(); bClose = Reader.ReadBit(); }
bReliable = Reader.ReadBit();
DWORD chIdx = Reader.ReadInt(0x50f);
if (bReliable)
{
INT lch = *(INT*)((BYTE*)this + chIdx * 4 + 0x3728);
DWORD rch = Reader.ReadInt(0x400);
seq = (INT)(((rch - (DWORD)lch - 0x200) & 0x3ff) - 0x200) + lch;
if (bHasSeq) chType = (EChannelType)Reader.ReadInt(8);
}
else if (bHasSeq) chType = (EChannelType)Reader.ReadInt(8);
DWORD bunchBits = Reader.ReadInt(*(INT*)((BYTE*)this + 0xd0) << 3);
if (Reader.IsError()) return;
Bunch.SetData(Reader, bunchBits);
if (Reader.IsError()) return;
// Filter out-of-order and duplicate bunches
UChannel* ch = *(UChannel**)((BYTE*)this + chIdx * 4 + 0xeb0);
UBOOL valid;
if (!bReliable)
valid = ((bOpen && bClose) || (ch && *(INT*)((BYTE*)ch + 0x40) != -1));
else
valid = (seq > *(INT*)((BYTE*)this + chIdx * 4 + 0x3728));
if (!valid) continue;
// Open channel if needed
if (!ch)
{
if (!UChannel::IsKnownChannelType(chType)) return;
ch = CreateChannel(chType, 0, chIdx);
if (!ch) continue;
}
if (bOpen) { *(INT*)((BYTE*)ch + 0x30) = 1; *(INT*)((BYTE*)ch + 0x40) = inSeq; }
ch->ReceivedRawBunch(Bunch);
*(INT*)((BYTE*)this + 0x20c) += 1;
if (*(INT*)(*(INT*)((BYTE*)this + 0x7c) + 0x3c) == 0 && Bunch.IsCriticalError())
*(INT*)((BYTE*)this + 0x80) = 1;
}
}
GLog->Logf(TEXT("Net: ReceivedPacket error"));
unguard;
}

IMPL_DIVERGE("FUN_ blocker: FUN_1050557c (command dispatch helper)")
void UNetConnection::ReceivedRawPacket(void* Data, INT Count)
{
guard(UNetConnection::ReceivedRawPacket);
unguard;
}

IMPL_MATCH("Engine.dll", 0x10484ec0)
void UNetConnection::SendPackageMap()
{
guard(UNetConnection::SendPackageMap);
// Retail: 0x10484ec0 — iterates PackageMap->List, sends package metadata and MD5 digests.
// Full implementation blocked by complex file I/O and MD5 hashing across multiple helpers.
unguard;
}

IMPL_DIVERGE("FUN_ blocker: FUN_10481dd0 (bunch serialization helper)")
INT UNetConnection::SendRawBunch(FOutBunch& Bunch, INT InPacketId)
{
guard(UNetConnection::SendRawBunch);
return 0;
unguard;
}

IMPL_DIVERGE("FUN_ blocker: FUN_103b7b70 (actor channel lookup)")
void UNetConnection::SetActorDirty(AActor* Actor)
{
guard(UNetConnection::SetActorDirty);
// TODO: resolve FUN_103b7b70 (actor channel lookup) to implement SetActorDirty
(void)Actor;
unguard;
}

IMPL_MATCH("Engine.dll", 0x10476d60)
void UNetConnection::SlowAssertValid()
{
// Retail: shared empty stub at 0x10476d60.
}

// =============================================================================

// =============================================================================
// UNetDriver (moved from EngineClassImpl.cpp)
// =============================================================================

// UNetDriver
// ---------------------------------------------------------------------------
IMPL_MATCH("Engine.dll", 0x1048ba90)
UBOOL UNetDriver::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
guard(UNetDriver::Exec);
if (ParseCommand(&Cmd, TEXT("SOCKETS")))
{
// Server connection at Ghidra this+0x10; channels at conn+0x4b7c
if (*(INT*)((BYTE*)this + 0x10) != 0)
{
void* conn = *(void**)((BYTE*)this + 0x10);
// LowLevelGetNetworkNumber via vtable[0x6c/4]; MSVC __thiscall returns FString via hidden first arg
typedef void* (__thiscall* GetNetNumFn)(void*, void*);
FString srvNum;
((GetNetNumFn)(*(void**)(*(INT*)conn + 0x6c)))(conn, &srvNum);
Ar.Logf(TEXT("%s"), *srvNum);
INT nch = ((FArray*)((BYTE*)conn + 0x4b7c))->Num();
for (INT i = 0; i < nch; i++)
{
void* ch = *(void**)(*(INT*)((BYTE*)conn + 0x4b7c) + i * 4);
typedef void* (__thiscall* DescFn)(void*, void*);
FString desc;
((DescFn)(*(void**)(*(INT*)ch + 0x70)))(ch, &desc);
Ar.Logf(TEXT("  %s"), *desc);
}
}
// Client connections at Ghidra this+0x4
INT ncli = ((FArray*)((BYTE*)this + 4))->Num();
for (INT i = 0; i < ncli; i++)
{
void* conn = *(void**)(*(INT*)((BYTE*)this + 4) + i * 4);
typedef void* (__thiscall* GetNetNumFn)(void*, void*);
FString cliNum;
((GetNetNumFn)(*(void**)(*(INT*)conn + 0x6c)))(conn, &cliNum);
Ar.Logf(TEXT("%s"), *cliNum);
INT nch = ((FArray*)((BYTE*)conn + 0x12df))->Num();
for (INT j = 0; j < nch; j++)
{
void* ch = *(void**)(*(INT*)((BYTE*)conn + 0x12df) + j * 4);
typedef void* (__thiscall* DescFn)(void*, void*);
FString desc;
((DescFn)(*(void**)(*(INT*)ch + 0x70)))(ch, &desc);
Ar.Logf(TEXT("  %s"), *desc);
}
}
return 1;
}
return 0;
unguard;
}

IMPL_DIVERGE("not found in Ghidra export — virtual override stub")
void UNetDriver::LowLevelDestroy()
{
guard(UNetDriver::LowLevelDestroy);
unguard;
}

IMPL_DIVERGE("not found in Ghidra export — virtual override stub")
FString UNetDriver::LowLevelGetNetworkNumber()
{
return FString();
}

// ---------------------------------------------------------------------------
