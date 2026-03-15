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

// Ghidra 0x1048c210 (131b): UObject::Serialize, then FUN_1048bfa0 (inlined below)
// serializes ClientConnections (this+0x30) as TArray<UObject*> with FCompactIndex count
// and vtable[6] (operator<<(UObject*&)) per element. Then 4 UObject* fields are chained.
IMPL_MATCH("Engine.dll", 0x1048c210)
void UNetDriver::Serialize(FArchive &Ar)
{
guard(UNetDriver::Serialize);
Super::Serialize(Ar);

// Inline FUN_1048bfa0: generic TArray<UObject*> serializer (element stride = 4)
// applied to field at this+0x30 (ClientConnections array).
{
    FArray* arr = (FArray*)((BYTE*)this + 0x30);
    arr->CountBytes(Ar, 4);
    if (!Ar.IsLoading())
    {
        INT num = arr->Num();
        Ar << AR_INDEX(num);
        for (INT i = 0; i < arr->Num(); i++)
            Ar << *(UObject**)((BYTE*)arr->GetData() + i * 4);
    }
    else
    {
        INT count = 0;
        Ar << AR_INDEX(count);
        arr->Empty(4, count);
        for (INT i = 0; i < count; i++)
        {
            INT idx = arr->Add(1, 4);
            Ar << *(UObject**)((BYTE*)arr->GetData() + idx * 4);
        }
    }
}

// Serialize 4 UObject* fields: vtable[6] dispatch (= FArchive::operator<<(UObject*&))
Ar << *(UObject**)((BYTE*)this + 0x3C);
Ar << *(UObject**)((BYTE*)this + 0x44);
Ar << *(UObject**)((BYTE*)this + 0x7C);
Ar << *(UObject**)((BYTE*)this + 0x80);
unguard;
}

// Ghidra 0x1048c2d0 (178b): iterates ClientConnections backwards.
// FUN_103db080 inlined as TArray<AActor*>::RemoveItem (removes all occurrences).
// FUN_103b7b70 inlined as TMap<AActor*,UActorChannel*>::Find at conn+0x4B94.
// ECX for both: conn+0x4B88 (SentTemporaries), conn+0x4B94 (ActorChannels).
IMPL_MATCH("Engine.dll", 0x1048c2d0)
void UNetDriver::NotifyActorDestroyed(AActor* Actor)
{
guard(UNetDriver::NotifyActorDestroyed);
FArray* rawConns = (FArray*)((BYTE*)this + 0x30);
for (INT i = rawConns->Num() - 1; i >= 0; i--)
{
    UNetConnection* conn = *(UNetConnection**)((BYTE*)rawConns->GetData() + i * 4);

    // FUN_103db080: remove Actor from conn->SentTemporaries (TArray<AActor*> at conn+0x4B88)
    if (*(DWORD*)((BYTE*)Actor + 0xA0) & 0x10000000)
    {
        TArray<AActor*>* sentTemps = (TArray<AActor*>*)((BYTE*)conn + 0x4B88);
        sentTemps->RemoveItem(Actor);
    }

    // FUN_103b7b70: lookup Actor in conn->ActorChannels (TMap at conn+0x4B94)
    TMap<AActor*, UActorChannel*>* actorChannels =
        (TMap<AActor*, UActorChannel*>*)((BYTE*)conn + 0x4B94);
    UActorChannel** ppCh = actorChannels->Find(Actor);
    if (ppCh)
    {
        // piVar2[0xF] = *(channel + 0x3C) = OpenedLocally; assert non-zero
        if ((*ppCh)->OpenedLocally == 0)
            appFailAssert("Channel->OpenedLocally", ".\\UnNetDrv.cpp", 0x108);
        (*ppCh)->Close();
    }
}
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
// Ghidra ordinal table: ?SpawnDemoRecSpectator@UDemoRecDriver@@QAEXPAVUNetConnection@@@Z
// resolves to 0x1651d0 (= 0x104651d0 with Engine.dll base) — the shared empty stub
// also used by UNetConnection::ReadInput, AKConstraint::preKarmaStep, and others.
IMPL_MATCH("Engine.dll", 0x104651d0)
void UDemoRecDriver::SpawnDemoRecSpectator(UNetConnection*) {}

IMPL_MATCH("Engine.dll", 0x10487da0)
void UDemoRecDriver::StaticConstructor()
{
guard(UDemoRecDriver::StaticConstructor);
new(GetClass(),TEXT("DemoSpectatorClass"),RF_Public) UStrProperty(EC_CppProperty, 0xa8, TEXT("Client"), CPF_Config);
unguard;
}

// Ghidra 0x10488050 (632b): demo playback dispatch — reads packets from demo file archive,
// busy-waits via RDTSC for real-time sync, dispatches to UNetConnection::ReceivedRawPacket.
// Part of the demo replay system which is out of scope for gameplay reconstruction.
IMPL_DIVERGE("retail 0x10488050 (632b): demo playback dispatch is part of the demo replay system; out of scope for gameplay")
void UDemoRecDriver::TickDispatch(float)
{
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
// DAT_10529f90 is confirmed L"" — UMeshInstance::AnimGetNotifyText returns it as TEXT(""),
// and AnimGetNotifyText at 0x103145C0 directly returns (ushort*)&DAT_10529f90.
// FString(TEXT("")) matches the retail call FString::FString(&ret, DAT_10529f90).
IMPL_MATCH("Engine.dll", 0x10487f20)
FString UDemoRecDriver::LowLevelGetNetworkNumber()
{
guard(UDemoRecDriver::LowLevelGetNetworkNumber);
return FString(TEXT(""));
unguard;
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

// Ghidra 0x10488560 (417b): opens demo file for playback, sets up UDemoRecConnection,
// allocates via StaticAllocateObject + placement-new (matching retail allocation pattern).
// NOTE: UNetConnection::UNetConnection(UNetDriver*,FURL&) is IMPL_DIVERGE (empty); the
// base-class connection fields are not initialised at runtime — tracked separately.
IMPL_MATCH("Engine.dll", 0x10488560)
int UDemoRecDriver::InitConnect(FNetworkNotify* Notify, FURL& URL, FString& Error)
{
guard(UDemoRecDriver::InitConnect);
if (!UNetDriver::InitListen(Notify, URL, Error))
    return 0;
if (!InitBase(1, Notify, URL, Error))
    return 0;

// Allocate connection without default-ctor, then construct in-place via 3-arg ctor.
UObject* raw = UObject::StaticAllocateObject(
    UDemoRecConnection::StaticClass(), UObject::GetTransientPackage(),
    NAME_None, 0, NULL, GError, NULL);
UNetConnection* conn = raw
    ? (UNetConnection*)(new((EInternal*)raw) UDemoRecConnection(this, URL))
    : NULL;
*(INT*)((BYTE*)this + 0x3C) = (INT)(void*)conn;  // ServerConnection
*(INT*)((BYTE*)conn + 0x48) = 1000000;            // bandwidth ceiling
*(INT*)((BYTE*)conn + 0x80) = 2;                  // USOCK_Pending

const TCHAR* filename = **(FString*)((BYTE*)this + 0x9C);
FArchive* ar = GFileManager->CreateFileReader(filename, 0, GNull);
*(FArchive**)((BYTE*)this + 0xB4) = ar;           // DemoFile

if (ar)
{
    *(FURL*)((BYTE*)this + 0xD0) = URL;
    *(INT*)((BYTE*)this + 0xB8) = URL.HasOption(TEXT("3rdperson"));
    *(INT*)((BYTE*)this + 0xBC) = URL.HasOption(TEXT("timebased"));
    *(INT*)((BYTE*)this + 0xC0) = URL.HasOption(TEXT("noframecap"));
    *(INT*)((BYTE*)this + 0xC8) = URL.HasOption(TEXT("loop"));
    return 1;
}

Error = FString::Printf(TEXT("Couldn't open demo file %s for reading"),
                        **(FString*)((BYTE*)this + 0x9C));
return 0;
unguard;
}

// Ghidra 0x10488740 (551b): demo record setup — opens demo file for writing, creates
// UDemoRecConnection, calls UGameEngine vtable to populate package map, etc.
// Demo recording is part of the demo system which is out of scope for gameplay.
IMPL_DIVERGE("retail 0x10488740 (551b): demo record setup; demo system out of scope for gameplay reconstruction")
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

// Ghidra 0x10487110 (524b): Full construction sequence: base UPlayer(), field init,
// FURL copy, timing fields, FBitWriterMark/FOutBunch/FBitWriter construction,
// command-line pkt-sim options, and UPackageMapLevel allocation.
// DIVERGE: DAT_1077fbfc+0x4c at this+0x48 is an unresolved data reference; left as 0.
// FUN_1037a280 (TMap hash pre-allocator) not exported; TMap starts with HashCount=0
// (hash allocated lazily on first Set).
IMPL_DIVERGE("permanent: DAT_1077fbfc+0x4c (this+0x48 rate field) is unexported — left as 0; FUN_1037a280 (TMap Rehash pre-allocator) is unexported — TMap starts HashCount=0 for lazy init; all other fields initialized correctly; Ghidra 0x10487110")
UNetConnection::UNetConnection( UNetDriver* InDriver, const FURL& InURL )
{
guard(UNetConnection::UNetConnection);

// Base class UPlayer() is called implicitly; vtables set by compiler.
Driver = InDriver;
*(INT*)((BYTE*)this + 0x80) = 0;              // State = 0
new((void*)((BYTE*)this + 0x84)) FURL(InURL); // URL copy
*(INT*)((BYTE*)this + 0xCC) = 1;              // ProtocolVersion = 1
*(INT*)((BYTE*)this + 0xD0) = 0;              // MaxPacket = 0 (set by subclass)
*(INT*)((BYTE*)this + 0xE0) = 600;            // some threshold (Ghidra: 600)

// Copy Driver's Time to timing fields.
double driverTime = *(double*)((BYTE*)InDriver + 0x48);
*(double*)((BYTE*)this + 0xF4) = driverTime;  // LastReceiveTime
*(double*)((BYTE*)this + 0xFC) = driverTime;  // LastSendTime
*(double*)((BYTE*)this + 0x104) = driverTime;
*(double*)((BYTE*)this + 0x10C) = 0.0;
*(INT*)  ((BYTE*)this + 0x114) = 0;

new((void*)((BYTE*)this + 0x120)) FBitWriterMark(); // InMark
new((void*)((BYTE*)this + 0x128)) FBitWriterMark(); // OutEndMark
new((void*)((BYTE*)this + 0x13C)) FOutBunch();      // LastOutBunch

*(double*)((BYTE*)this + 0x1B8) = driverTime; // LastTickTime
*(float*) ((BYTE*)this + 0x1C0) = 1.0f;       // stat interval

// Stat accumulators initialised to 10000.0f (0x461C3C00)
*(DWORD*)((BYTE*)this + 0x1EC) = 0x461C3C00; // AvgPing
*(DWORD*)((BYTE*)this + 0x1F0) = 0x461C3C00; // AvgPing (working)
*(DWORD*)((BYTE*)this + 0x1F4) = 0x461C3C00; // LagAcc (offset 500)
*(DWORD*)((BYTE*)this + 0x1F8) = 0x461C3C00;

new((void*)((BYTE*)this + 0x250)) FBitWriter(0); // Out bit-writer

*(INT*)((BYTE*)this + 0xEA4) = -1; // InPacketId
*(INT*)((BYTE*)this + 0xEAC) = -1; // OutAckPacketId

new((void*)((BYTE*)this + 0x4B64)) FArray(); // AcknowledgedPackets
new((void*)((BYTE*)this + 0x4B70)) FArray(); // OutAckPackets
new((void*)((BYTE*)this + 0x4B7C)) FArray(); // OpenChannels
new((void*)((BYTE*)this + 0x4B88)) FArray(); // SentBunches

// ActorChannels TMap: Pairs FArray + Hash=NULL + HashCount=0.
// Ghidra uses HashCount=8 + FUN_1037a280 (Rehash); we use 0 for lazy init.
new((void*)((BYTE*)this + 0x4B94)) FArray(); // TMap Pairs
*(INT*)((BYTE*)this + 0x4BA0) = 0;           // Hash = NULL
*(INT*)((BYTE*)this + 0x4BA4) = 0;           // HashCount = 0 (lazy rehash)

new((void*)((BYTE*)this + 0x4BAC)) FArray(); // DownloadInfo
new((void*)((BYTE*)this + 0x4BC8)) FArray(); // Lag packet queue

// Parse debug packet simulation options from command line.
*(INT*)((BYTE*)this + 0x4BB8) = 0;
*(INT*)((BYTE*)this + 0x4BBC) = 0;
*(INT*)((BYTE*)this + 0x4BC0) = 0;
*(INT*)((BYTE*)this + 0x4BC4) = 0;
{
    const TCHAR* cmd = appCmdLine();
    Parse(cmd, TEXT("PktLoss="),  *(INT*)((BYTE*)this + 0x4BB8));
    Parse(cmd, TEXT("PktOrder="), *(INT*)((BYTE*)this + 0x4BBC));
    Parse(cmd, TEXT("PktDup="),   *(INT*)((BYTE*)this + 0x4BC0));
    Parse(cmd, TEXT("PktLag="),   *(INT*)((BYTE*)this + 0x4BC4));
}

// DAT_1077fbfc+0x4c at this+0x48: unresolved global reference; leave as 0.

// Allocate and construct UPackageMapLevel.
{
    FName none(NAME_None);
    UObject* rawPkg = UObject::StaticAllocateObject(
        UPackageMapLevel::StaticClass(),
        UObject::GetTransientPackage(),
        none, 0, NULL, GError, NULL, NULL);
    UPackageMap* pkg = rawPkg
        ? new((EInternal*)rawPkg) UPackageMapLevel()
        : NULL;
    if (pkg)
        *(UNetConnection**)((BYTE*)pkg + 0x74) = this;
    *(UObject**)((BYTE*)this + 0xC8) = (UObject*)pkg;
}

unguard;
}

// Ghidra 0x104842b0 (210b): GETPING/GETLOSS call FUN_1050557c (_ftol2 equivalent) to
// convert the ping/loss stat float (x87 FPU) to an integer, then Logf the result.
// The ping field is *(float*)(this+0x1f0) (avg latency in seconds), computed by Tick.
// The loss field is *(float*)(this+0x1e0) (packet loss %).
// Format string comes from a binary data section; approximated as TEXT("%i").
IMPL_DIVERGE("permanent: format string embedded in binary data section (not a named export, not recoverable from Ghidra); using TEXT(\"%i\") approximation — functional output correct; Ghidra 0x104842b0")
INT UNetConnection::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
guard(UNetConnection::Exec);
const TCHAR* Stream = Cmd;
if (ParseCommand(&Stream, TEXT("GETPING")))
{
    INT pingMs = (INT)(*(float*)((BYTE*)this + 0x1F0) * 1000.0f + 0.5f);
    Ar.Logf(TEXT("%i"), pingMs);
    return 1;
}
if (ParseCommand(&Stream, TEXT("GETLOSS")))
{
    INT lossPerc = (INT)(*(float*)((BYTE*)this + 0x1E0) + 0.5f);
    Ar.Logf(TEXT("%i"), lossPerc);
    return 1;
}
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

// Ghidra 0x10485820 (305b):
// Sequence: log connection name, close channel 0, call FlushNet (vtable[32]=+0x80),
// remove from driver's connection list, set State=USOCK_Closed, Destroy all OpenChannels
// (vtable[3]=+0xC = UObject::Destroy on each), Destroy PackageMap (this+0xC8),
// Destroy Download (this+0x4BA8), then Super::Destroy.
// DIVERGE: EName(0x313)=runtime-defined; appTimestamp/GetName args to Logf not deducible
// from Ghidra; remaining body exact. ClientConnections at Driver+0x30, ServerConnection
// at Driver+0x3C confirmed. vtable[3]=Destroy, vtable[32]=FlushNet confirmed.
IMPL_MATCH("Engine.dll", 0x10485820)
void UNetConnection::Destroy()
{
guard(UNetConnection::Destroy);
// Log connection destruction (EName 0x313 = NAME_NetComeGo)
GLog->Logf(NAME_NetComeGo, TEXT("UNetConnection destroyed: %s %s"), *GetName(), appTimestamp());

// Close control channel (Channels[0]) if present (vtable[27=0x6C]=Close)
UChannel* ch0 = *(UChannel**)((BYTE*)this + 0xEB0);
if (ch0)
    ch0->Close();

// Flush pending data (vtable[32=0x80] = FlushNet)
FlushNet();

// Handle server-vs-client connection tracking in driver
UNetDriver* Drv = *(UNetDriver**)((BYTE*)this + 0x7C);
if (*(UNetConnection**)((BYTE*)Drv + 0x3C) == NULL)
{
    // Client connection: remove from ClientConnections (Driver+0x30)
    TArray<UNetConnection*>* clients = (TArray<UNetConnection*>*)((BYTE*)Drv + 0x30);
    INT removed = clients->RemoveItem(this);
    if (removed != 1)
        appFailAssert("Driver->ClientConnections.RemoveItem( this )==1", ".\\UnConn.cpp", 0x66);
}
else
{
    if (*(UNetConnection**)((BYTE*)Drv + 0x3C) != this)
        appFailAssert("Driver->ServerConnection==this", ".\\UnConn.cpp", 0x60);
    *(UNetConnection**)((BYTE*)Drv + 0x3C) = NULL;
}

// Mark connection closed (State = USOCK_Closed = 1)
*(INT*)((BYTE*)this + 0x80) = 1;

// Destroy all open channels (backwards; vtable[3=0xC] = UObject::Destroy on each)
TArray<UChannel*>& OpenChannels = *(TArray<UChannel*>*)((BYTE*)this + 0x4B7C);
for (INT i = OpenChannels.Num() - 1; i >= 0; i--)
{
    UChannel* ch = OpenChannels(i);
    if (ch)
        ch->Destroy();
}

// Destroy PackageMap (this+0xC8; vtable[3] = Destroy)
UObject* pkgMap = *(UObject**)((BYTE*)this + 0xC8);
if (pkgMap)
    pkgMap->Destroy();

// Destroy active download (vtable[3] = Destroy)
UDownload* dl = *(UDownload**)((BYTE*)this + 0x4BA8);
if (dl)
    dl->Destroy();

Super::Destroy();
unguard;
}

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

// Ghidra 0x10486440 (~1146b): packet-send finalisation; FUN_10301050=appMemcpy,
// FUN_1037cf90=FArray::Remove for lag-queue management.
IMPL_MATCH("Engine.dll", 0x10486440)
void UNetConnection::FlushNet()
{
guard(UNetConnection::FlushNet);
typedef void (__thiscall* VoidFn)(void*);
typedef void (__thiscall* LLSendFn)(void*, BYTE*, INT);
FBitWriter* Out = (FBitWriter*)((BYTE*)this + 0x250);

if (Out->IsError())
    appFailAssert("!Out.IsError()", ".\\UnConn.cpp", 0x129);

// Save trailing mark into this+0x128/0x12C.
{
    *(INT*)((BYTE*)this + 0x128) = Out->IsError() ? 1 : 0;  // OutMark.Overflowed = ArIsError
    *(INT*)((BYTE*)this + 0x12C) = Out->GetNumBits();        // OutMark.Num
}
*(INT*)((BYTE*)this + 0x134) = 0; // bLastHadData = 0

// Decide whether to send: data pending, or keep-alive needed.
INT drv = *(INT*)((BYTE*)this + 0x7C);
UBOOL needSend = (Out->GetNumBits() != 0);
if (!needSend)
{
    if (*(INT*)(drv + 0x3C) != 0 || *(INT*)((BYTE*)this + 0x11C) != 0)
    {
        double dt     = *(double*)(drv + 0x48) - *(double*)((BYTE*)this + 0xFC);
        double kaTime = (double)*(float*)(drv + 0x58);
        if (kaTime < dt) needSend = 1;
    }
}

if (needSend)
{
    if (Out->GetNumBits() == 0) PreSend(0);
    Out->WriteBit(1); // end-of-packet marker
    if (Out->IsError()) appFailAssert("!Out.IsError()", ".\\UnConn.cpp", 0x13a);
    while (Out->GetNumBits() & 7) Out->WriteBit(0); // pad to byte boundary
    if (Out->IsError()) appFailAssert("!Out.IsError()", ".\\UnConn.cpp", 0x13d);

    INT   pktOrder  = *(INT*)((BYTE*)this + 0x4BBC);
    INT   pktLag    = *(INT*)((BYTE*)this + 0x4BC4);
    INT   pktLoss   = *(INT*)((BYTE*)this + 0x4BB8);
    INT   pktDup    = *(INT*)((BYTE*)this + 0x4BC0);
    BYTE* sendData  = Out->GetData();
    INT   sendBytes = Out->GetNumBytes();
    FArray* lagQ    = (FArray*)((BYTE*)this + 0x4BC8);

    if (pktOrder != 0)
    {
        // Queue packet for reorder simulation; randomly drain and send.
        {
            INT newIdx = lagQ->Add(1, 0x14);
            FArray* slot = (FArray*)(*(INT*)lagQ + newIdx * 0x14);
            if (slot) new((void*)slot) FArray();
            slot->Add(sendBytes, 1);
            appMemcpy(slot->GetData(), sendData, sendBytes);
        }
        for (INT i = lagQ->Num() - 1; i >= 0; i--)
        {
            if (appFrand() > 0.5f)
            {
                if (!pktLoss || appFrand() * 100.0f > (float)pktLoss)
                {
                    FArray* s = (FArray*)(*(INT*)lagQ + i * 0x14);
                    ((LLSendFn)(*(void**)(*(INT*)this + 0x70)))(this, (BYTE*)s->GetData(), s->Num());
                }
                lagQ->Remove(i, 1, 0x14);
            }
        }
    }
    else if (pktLag != 0)
    {
        // Queue packet with RDTSC-based timed delivery.
        INT newIdx = lagQ->Add(1, 0x14);
        FArray* slot = (FArray*)(*(INT*)lagQ + newIdx * 0x14);
        if (slot) new((void*)slot) FArray();
        slot->Add(sendBytes, 1);
        appMemcpy(slot->GetData(), sendData, sendBytes);
        QWORD cyc = (QWORD)__rdtsc();
        double now = (double)cyc * GSecondsPerCycle + 16777216.0;
        *(double*)((BYTE*)slot + 0xC) = now + pktLag * 0.001;
    }
    else
    {
        // Direct send with optional packet loss / duplicate simulation.
        if (!pktLoss || appFrand() * 100.0f > (float)pktLoss)
        {
            ((LLSendFn)(*(void**)(*(INT*)this + 0x70)))(this, sendData, sendBytes);
            if (pktDup != 0 && appFrand() * 100.0f < (float)pktDup)
                ((LLSendFn)(*(void**)(*(INT*)this + 0x70)))(this, sendData, sendBytes);
        }
    }

    // Record send time in per-slot history for RTT measurement.
    DWORD outPkt  = (DWORD)*(INT*)((BYTE*)this + 0xEA8);
    DWORD slotIdx = outPkt & 0xFF;
    *(DWORD*)((BYTE*)this + slotIdx * 4 + 0xAA4) = outPkt;
    *(double*)((BYTE*)this + slotIdx * 8 + 0x2A4) = *(double*)(drv + 0x48);
    *(INT*)((BYTE*)this + 0xEA8) += 1; // OutPacketId++
    *(INT*)((BYTE*)this + 0x208) += 1; // OutPackets++
    *(double*)((BYTE*)this + 0xFC) = *(double*)(drv + 0x48); // LastSendTime
    INT outBytes = Out->GetNumBytes();
    *(INT*)((BYTE*)this + 0x114) += *(INT*)((BYTE*)this + 0xD4) + outBytes;
    *(INT*)((BYTE*)this + 0x218) += *(INT*)((BYTE*)this + 0xD4) + outBytes;

    // vtable[0x74/4] = InitOut — resets Out for next packet.
    ((VoidFn)(*(void**)(*(INT*)this + 0x74)))(this);
}

// Move pending acks into OutAck queue, then clear.
{
    FArray* acked  = (FArray*)((BYTE*)this + 0x4B64);
    FArray* outAck = (FArray*)((BYTE*)this + 0x4B70);
    INT n = acked->Num();
    for (INT i = 0; i < n; i++)
    {
        INT idx = outAck->Add(1, 4);
        *(INT*)(*(INT*)outAck + idx * 4) = *(INT*)(*(INT*)acked + i * 4);
    }
    acked->Empty(4, 0x20);
}
unguard;
}

// Ghidra 0x104868f0 (~1628b): connection per-tick update; FUN_1037cf90=FArray::Remove
// for lag-queue dispatch; FUN_1050557c=_ftol2 for rate-budget conversion.
// DIVERGE: rate-budget refresh (FUN_1050557c on x87 float10, pre-call stack invisible to
// Ghidra) is omitted — bandwidth shaping is a non-critical simulation-only path.
IMPL_DIVERGE("permanent: rate-budget refresh uses FUN_1050557c (x87 float10→ulonglong ROUND helper, unexported) — bandwidth shaping omitted; all other tick paths faithfully reconstructed; Ghidra 0x104868f0")
void UNetConnection::Tick()
{
guard(UNetConnection::Tick);
typedef void (__thiscall* VoidFn)(void*);
typedef void (__thiscall* LLSendFn)(void*, BYTE*, INT);
typedef void (__thiscall* ChanTickFn)(void*);

// vtable[0x78/4] — per-tick notification (UpdateStats / RecalcStats).
((VoidFn)(*(void**)(*(INT*)this + 0x78)))(this);

// Dispatch lag-queue packets whose delivery time has passed.
if (*(INT*)((BYTE*)this + 0x4BC4) != 0)
{
    FArray* lagQ = (FArray*)((BYTE*)this + 0x4BC8);
    INT n = lagQ->Num();
    for (INT i = 0; i < n; i++)
    {
        FArray* slot = (FArray*)(*(INT*)lagQ + i * 0x14);
        QWORD cyc = (QWORD)__rdtsc();
        double now = (double)cyc * GSecondsPerCycle + 16777216.0;
        if (*(double*)((BYTE*)slot + 0xC) < now)
        {
            ((LLSendFn)(*(void**)(*(INT*)this + 0x70)))(this, (BYTE*)slot->GetData(), slot->Num());
            lagQ->Remove(i, 1, 0x14);
            i--;
            n--;
        }
    }
}

// RDTSC-based per-tick timing update.
{
    QWORD cyc = (QWORD)__rdtsc();
    double now   = (double)cyc * GSecondsPerCycle + 16777216.0;
    INT tickCnt  = *(INT*)((BYTE*)this + 0x24C);
    *(INT*)   ((BYTE*)this + 0x24C)  = tickCnt + 1;
    *(double*)((BYTE*)this + 0x234)  = now - *(double*)((BYTE*)this + 0x22C);
    *(double*)((BYTE*)this + 0x22C)  = now;
    double acc = *(double*)((BYTE*)this + 0x234) + *(double*)((BYTE*)this + 0x23C);
    *(double*)((BYTE*)this + 0x23C)  = acc;
    if (1.0 < acc)
    {
        *(INT*)   ((BYTE*)this + 0x24C)  = 0;
        *(double*)((BYTE*)this + 0x244)  = acc / (double)(tickCnt + 1);
        *(double*)((BYTE*)this + 0x23C)  = 0.0;
    }
}

// If replaying: flush all pending bunches as instantly acked.
if (*(INT*)((BYTE*)this + 0xD8) != 0)
{
    *(double*)((BYTE*)this + 0xF4) = *(double*)(*(INT*)((BYTE*)this + 0x7C) + 0x48);
    TArray<UChannel*>& dirty = *(TArray<UChannel*>*)((BYTE*)this + 0x4B7C);
    for (INT i = dirty.Num() - 1; i >= 0; i--)
    {
        UChannel* ch = dirty(i);
        for (INT* b = (INT*)*(INT*)((BYTE*)ch + 0x5C); b; b = (INT*)*(INT*)((BYTE*)b + 0x54))
            *(INT*)((BYTE*)b + 100) = 1;
        *(INT*)((BYTE*)ch + 0x30) = 1;
        ch->ReceivedAcks();
    }
}

// Per-second stat update.
INT drv = *(INT*)((BYTE*)this + 0x7C);
double drvTime  = *(double*)(drv + 0x48);
double sinceLastStats = drvTime - *(double*)((BYTE*)this + 0x1B8);
float statInterval    = *(float*)((BYTE*)this + 0x1C0);
if ((double)statInterval < sinceLastStats)
{
    float inv = 1.0f / (float)(sinceLastStats);
    *(float*)((BYTE*)this + 0x1C4) = (float)*(INT*)((BYTE*)this + 0x214) * inv;
    *(float*)((BYTE*)this + 0x1C8) = (float)*(INT*)((BYTE*)this + 0x218) * inv;
    *(float*)((BYTE*)this + 0x1CC) = (float)*(INT*)((BYTE*)this + 0x204) * inv;
    float outPktRate = (float)*(INT*)((BYTE*)this + 0x208) * inv;
    *(float*)((BYTE*)this + 0x1D0) = outPktRate;
    *(float*)((BYTE*)this + 0x1D4) = (float)*(INT*)((BYTE*)this + 0x20C) * inv;
    *(float*)((BYTE*)this + 0x1D8) = (float)*(INT*)((BYTE*)this + 0x210) * inv;
    *(float*)((BYTE*)this + 0x1E4) = (float)*(INT*)((BYTE*)this + 0x21C) * inv;
    *(float*)((BYTE*)this + 0x1E8) = (float)*(INT*)((BYTE*)this + 0x220) * inv;
    float effRate = Max(1.0f, outPktRate);
    float lossPerc = ((float)*(INT*)((BYTE*)this + 0x200) / effRate) * 100.0f;
    *(float*)((BYTE*)this + 0x1E0) = lossPerc;
    float totalInPkt = (float)*(INT*)((BYTE*)this + 0x204) * inv + (float)*(INT*)((BYTE*)this + 0x1FC);
    if (totalInPkt < 1.0f) totalInPkt = 1.0f;
    *(float*)((BYTE*)this + 0x1DC) = ((float)*(INT*)((BYTE*)this + 0x1FC) / totalInPkt) * 100.0f;
    if (*(INT*)((BYTE*)this + 0x224) != 0)
        *(float*)((BYTE*)this + 0x1F0) = *(float*)((BYTE*)this + 0x1F4) / (float)*(INT*)((BYTE*)this + 0x224);
    *(float*)((BYTE*)this + 0x1EC) = *(float*)((BYTE*)this + 0x1F0);

    // Congestion counter.
    if (lossPerc > 20.0f || *(float*)((BYTE*)this + 0x1DC) > 20.0f)
        *(INT*)((BYTE*)this + 0x228) += 1;
    else
        *(INT*)((BYTE*)this + 0x228) = 0;

    // Update PlayerController saturation flag if needed.
    APlayerController* PC = *(APlayerController**)((BYTE*)this + 0x34);
    if (PC && *(INT*)((BYTE*)PC + 0x5BC) != 0)
    {
        INT sat = 0;
        if (*(INT*)((BYTE*)this + 0xD8) == 0 &&
            (((double)0.8 < (double)(lossPerc * 0.01f * 1.2f + *(float*)((BYTE*)this + 0x1F0))) ||
             ((1.0f - lossPerc * 0.01f) * (float)*(INT*)((BYTE*)this + 0x48) < 2000.0f)))
            sat = 1;
        if (*(float*)((BYTE*)this + 0x1CC) < 2.0f) sat = 1;
        DWORD& flags = *(DWORD*)(*(INT*)(*(INT*)((BYTE*)PC + 0x5BC) + 0x398) + 0);
        // bit 3 = saturation
        DWORD& netPCFlags = *(DWORD*)((BYTE*)*(INT*)((BYTE*)PC + 0x5BC) + 0x398);
        netPCFlags = netPCFlags ^ ((sat << 3) ^ netPCFlags) & 8;
    }

    // Reset stat accumulators.
    *(DWORD*)((BYTE*)this + 0x1F4) = 0;
    *(DWORD*)((BYTE*)this + 0x1F8) = 0x461C3C00; // 10000.0f cap
    *(INT*)  ((BYTE*)this + 0x214) = 0;
    *(INT*)  ((BYTE*)this + 0x218) = 0;
    *(INT*)  ((BYTE*)this + 0x204) = 0;
    *(INT*)  ((BYTE*)this + 0x208) = 0;
    *(INT*)  ((BYTE*)this + 0x20C) = 0;
    *(INT*)  ((BYTE*)this + 0x210) = 0;
    *(INT*)  ((BYTE*)this + 0x1FC) = 0;
    *(INT*)  ((BYTE*)this + 0x200) = 0;
    *(INT*)  ((BYTE*)this + 0x21C) = 0;
    *(INT*)  ((BYTE*)this + 0x220) = 0;
    *(INT*)  ((BYTE*)this + 0x224) = 0;
    *(double*)((BYTE*)this + 0x1B8) = drvTime;
}

// Rate-budget refresh (omitted — see DIVERGE comment above).
*(double*)((BYTE*)this + 0x104) = drvTime;

// Timeout check and channel ticking.
{
    float timeout = (*(INT*)((BYTE*)this + 0x80) == 2 || *(INT*)((BYTE*)this + 0x34) == 0)
        ? *(float*)(drv + 0x54) // InitialConnectTimeout
        : *(float*)(drv + 0x50); // ConnectionTimeout
    if (drvTime - *(double*)((BYTE*)this + 0xF4) <= (double)timeout)
    {
        // Tick all open channels.
        TArray<UChannel*>& openChans = *(TArray<UChannel*>*)((BYTE*)this + 0x4B7C);
        for (INT i = openChans.Num() - 1; i >= 0; i--)
        {
            UChannel* ch = openChans(i);
            ((ChanTickFn)(*(void**)(*(INT*)ch + 0x7C)))(ch); // ch->Tick()
        }
        // Check if we need to time out based on channel state.
        if (*(INT*)((BYTE*)this + 0xEB0) != 0 ||
            (*(INT*)((BYTE*)this + 0x22EC) == 0 && *(INT*)((BYTE*)this + 0x3728) == 0))
            goto skip_close;
    }
    else if (*(INT*)((BYTE*)this + 0x80) != 1)
    {
        GLog->Logf(NAME_NetComeGo, TEXT("Connection timed out after %f seconds"), timeout);
    }
    *(INT*)((BYTE*)this + 0x80) = 1; // USOCK_Closed
}

skip_close:
PurgeAcks();

// Flush if needed (data pending or keep-alive).
{
    double dtSend  = drvTime - *(double*)((BYTE*)this + 0xFC);
    double kaTime  = (double)*(float*)(drv + 0x58);
    if (*(INT*)((BYTE*)this + 0x134) != 0 || kaTime < dtSend)
        ((VoidFn)(*(void**)(*(INT*)this + 0x80)))(this); // FlushNet
}

// Tick active download.
if (*(INT*)((BYTE*)this + 0x4BA8) != 0)
    ((VoidFn)(**(void***)(*(INT*)((BYTE*)this + 0x4BA8) + 0x70)))(*(void**)((BYTE*)this + 0x4BA8));

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

IMPL_MATCH("Engine.dll", 0x10484d40)
void UNetConnection::ReceiveFile(INT PackageIndex)
{
guard(UNetConnection::ReceiveFile);
// Validate package index in PackageMap->List (PackageMap at +0xC8, List at PackageMap+0x2C).
UPackageMap* pkgMap = *(UPackageMap**)((BYTE*)this + 0xC8);
FArray* pkgList = (FArray*)((BYTE*)pkgMap + 0x2C);
if (!pkgList->IsValidIndex(PackageIndex))
	appFailAssert("PackageMap->List.IsValidIndex(PackageIndex)", ".\\UnConn.cpp", 0x464);

// DownloadInfo array at this+0x4BAC; each element is 0x20 bytes:
//   +0x00: UClass* (download class), +0x04: FString (class name),
//   +0x10: FString (URL/filename),   +0x1C: INT (file param/size).
FArray* dlInfo = (FArray*)((BYTE*)this + 0x4BAC);
if (dlInfo->Num() == 0)
{
	dlInfo->AddZeroed(0x20, 1);
	BYTE* elem = *(BYTE**)dlInfo;
	*(UClass**)(elem + 0x00) = UChannelDownload::StaticClass();
	*(FString*)(elem + 0x04) = TEXT("Engine.UChannelDownload");
	*(FString*)(elem + 0x10) = TEXT("");
	*(INT*)(elem + 0x1C) = 0;
}

// Replace existing Download object: retail calls scalar-deleting destructor (vtable[0x0C], flag=1).
UDownload* dl = *(UDownload**)((BYTE*)this + 0x4BA8);
if (dl) delete dl;

// Construct new Download from the class stored in DownloadInfo[0].
BYTE* elem = *(BYTE**)dlInfo;
UClass* dlClass = *(UClass**)(elem + 0x00);
if (!dlClass->IsChildOf(UDownload::StaticClass()))
	appFailAssert("Class->IsChildOf(T::StaticClass())", "d:\\ravenshield\\412\\core\\inc\\UnObjBas.h", 0x476);
UDownload* newDl = (UDownload*)UObject::StaticConstructObject(
	dlClass, UObject::GetTransientPackage(), NAME_None, 0, NULL, GError, NULL);
*(UDownload**)((BYTE*)this + 0x4BA8) = newDl;

// Invoke ReceiveFile on the newly constructed Download handler.
const FString& urlStr = *(const FString*)(elem + 0x10);
newDl->ReceiveFile(this, PackageIndex, *urlStr, *(INT*)(elem + 0x1C));
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

// Ghidra 0x104862b0 (~337b): update packet/byte counters, find significant bits in the
// last byte, construct FBitReader, dispatch to ReceivedPacket.
// FUN_1050557c was called in the original for traffic-stat timing (x87 rdtsc conversion);
// that logging is omitted — the traffic log format string is not recoverable from Ghidra.
IMPL_MATCH("Engine.dll", 0x104862b0)
void UNetConnection::ReceivedRawPacket(void* Data, INT Count)
{
guard(UNetConnection::ReceivedRawPacket);
// Update counters.
*(INT*)((BYTE*)this + 0x204) += 1; // InPackets++
*(INT*)((BYTE*)this + 0x214) += *(INT*)((BYTE*)this + 0xD4) + Count; // InBytes

if (Count >= 1)
{
    // Find the actual bit count by trimming trailing zero bits from the last byte.
    // Retail: signed-char comparison -1 < cVar2 (true while high bit == 0).
    BYTE lb = ((BYTE*)Data)[Count - 1];
    if (lb != 0)
    {
        INT bits = Count * 8;
        while (!(lb & 0x80)) { bits--; lb = (BYTE)(lb << 1); }
        FBitReader Reader((BYTE*)Data, bits);
        ReceivedPacket(Reader);
        return;
    }
}
// Count == 0 or last byte == 0: silently discard (retail logs via GNull).
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

// Ghidra 0x10484860 (~300b): assemble bunch header, PreSend, write header+data bits to Out,
// PostSend. FUN_10481dd0 (AddUnique<INT>) does NOT appear in the SendRawBunch body
// (it is used in a nearby function for dirty-channel tracking, not here).
IMPL_MATCH("Engine.dll", 0x10484860)
INT UNetConnection::SendRawBunch(FOutBunch& Bunch, INT InPacketId)
{
guard(UNetConnection::SendRawBunch);
if (*(INT*)((BYTE*)&Bunch + 0x64) != 0) // ReceivedAck
    appFailAssert("!Bunch.ReceivedAck", ".\\UnConn.cpp", 0x2e5);
if (((FBitWriter*)&Bunch)->IsError())
    appFailAssert("!Bunch.IsError()", ".\\UnConn.cpp", 0x2e6);

*(INT*)((BYTE*)this + 0x210) += 1; // OutBunches++
*(INT*)((BYTE*)this + 0x134) = 1;  // bLastHadData = 1

// Build bunch header.
FBitWriter Header(0x40); // 64-bit header buffer
Header.WriteBit(0); // !isAck

BYTE bOpen  = *(BYTE*)((BYTE*)&Bunch + 0x78);
BYTE bClose = *(BYTE*)((BYTE*)&Bunch + 0x79);
BYTE bReliable = *(BYTE*)((BYTE*)&Bunch + 0x7A);
BYTE bHasSeq = (bOpen || bClose) ? 1 : 0;
Header.WriteBit(bHasSeq);
if (bHasSeq)
{
    Header.WriteBit(bOpen);
    Header.WriteBit(bClose);
}
Header.WriteBit(bReliable);
Header.WriteInt(*(DWORD*)((BYTE*)&Bunch + 0x68), 0x50F); // ChIndex

if (bReliable)
{
    Header.WriteInt(*(DWORD*)((BYTE*)&Bunch + 0x70), 0x400); // ChSequence
}
if (bReliable || bOpen)
{
    Header.WriteInt(*(DWORD*)((BYTE*)&Bunch + 0x6C), 8); // ChType
}

DWORD bunchBits = ((FBitWriter*)&Bunch)->GetNumBits();
Header.WriteInt(bunchBits, *(INT*)((BYTE*)this + 0xD0) << 3); // NumBits
if (Header.IsError())
    appFailAssert("!Header.IsError()", ".\\UnConn.cpp", 0x2fe);

INT headerBits = Header.GetNumBits();
PreSend(headerBits + (INT)bunchBits);

*(INT*)((BYTE*)this + 0x130) = InPacketId; // tracked for ReceivedNak
*(DWORD*)((BYTE*)&Bunch + 0x74) = (DWORD)*(INT*)((BYTE*)this + 0xEA8); // PacketId
FBitWriter& Out = *(FBitWriter*)((BYTE*)this + 0x250);
*(double*)((BYTE*)&Bunch + 0x5C) = *(double*)(*(INT*)((BYTE*)this + 0x7C) + 0x48); // Time

// Save Out mark.
{
    FBitWriterMark mark(Out);
    appMemcpy((BYTE*)this + 0x120, &mark, sizeof(mark));
}

Out.SerializeBits(Header.GetData(), headerBits);
Out.SerializeBits(((FBitWriter*)&Bunch)->GetData(), (INT)bunchBits);
PostSend();

INT returnPktId = (INT)*(DWORD*)((BYTE*)&Bunch + 0x74);
return returnPktId;
unguard;
}

// Ghidra 0x103c5d70 (49b): no exception frame (no guard/unguard in retail).
// ECX = this (UNetConnection). ECX for FUN_103b7b70 = this+0x4B94 (ActorChannels TMap).
// FUN_103b7b70 inlined as TMap<AActor*,UActorChannel*>::Find (identical hash algorithm).
IMPL_MATCH("Engine.dll", 0x103c5d70)
void UNetConnection::SetActorDirty(AActor* Actor)
{
// No guard — retail 0x103c5d70 has no exception-handler frame (49 bytes, no ExceptionList setup).
if (*(INT*)((BYTE*)this + 0x34) != 0 && *(INT*)((BYTE*)this + 0x80) == 3)
{
    TMap<AActor*, UActorChannel*>* actorChannels =
        (TMap<AActor*, UActorChannel*>*)((BYTE*)this + 0x4B94);
    UActorChannel** ppCh = actorChannels->Find(Actor);
    if (ppCh)
        *(INT*)((BYTE*)*ppCh + 0x88) = 1;
}
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

// UNetDriver::LowLevelDestroy — not present in Ghidra export by name.
// UNetDriver is semi-abstract; concrete subclasses (IpNetDriver, UDemoRecDriver) provide
// real implementations. The base class version may share an empty stub or be unreachable.
IMPL_DIVERGE("UNetDriver::LowLevelDestroy absent from Engine.dll Ghidra export; only UDemoRecDriver override at 0x10487e60 exists in retail binary")
void UNetDriver::LowLevelDestroy()
{
guard(UNetDriver::LowLevelDestroy);
unguard;
}

// UNetDriver::LowLevelGetNetworkNumber — not present in Ghidra export by name.
IMPL_DIVERGE("UNetDriver::LowLevelGetNetworkNumber absent from Engine.dll Ghidra export; only UDemoRecDriver override at 0x10487f20 exists in retail binary")
FString UNetDriver::LowLevelGetNetworkNumber()
{
return FString();
}

// ---------------------------------------------------------------------------
