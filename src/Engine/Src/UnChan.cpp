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

IMPL_MATCH("Engine.dll", 0x104802c0)
INT UChannel::SendBunch(FOutBunch* Bunch, INT Merge)
{
guard(UChannel::SendBunch);

BYTE* conn = (BYTE*)Connection;

// Assertions.
if( Closing )
	appFailAssert("!Closing", ".\\UnChan.cpp", 0x17e);
if( *(UChannel**)(conn + 0xeb0 + ChIndex * 4) != this )
	appFailAssert("Connection->Channels[ChIndex]==this", ".\\UnChan.cpp", 0x17f);
if( *(INT*)((BYTE*)Bunch + 0x30) )  // FArchive::IsError() at ArIsError offset
	appFailAssert("!Bunch->IsError()", ".\\UnChan.cpp", 0x180);

// First bunch on an open channel: mark as opening.
if( OpenPacketId == -1 && OpenedLocally )
{
	*(BYTE*)((BYTE*)Bunch + 0x78) = 1;  // bOpen = 1
	OpenTemporary = (*(BYTE*)((BYTE*)Bunch + 0x7a) == 0);  // OpenTemporary = !bReliable
}
if( OpenTemporary && *(BYTE*)((BYTE*)Bunch + 0x7a) )
	appFailAssert("!Bunch->bReliable", ".\\UnChan.cpp", 399);

// Try to merge with the previously-sent bunch.
FOutBunch* PreExistingBunch = NULL;
if( Merge
	&& *(INT*)(conn + 0x1a4) == *(INT*)((BYTE*)Bunch + 0x68)  // same ChSequence
	&& *(INT*)(conn + 0x130) )                                 // merge data valid
{
	INT lastStartBits = *(INT*)(conn + 0x12C);  // FBitWriterMark::Num at +0x04 from 0x128
	if( lastStartBits )
	{
		INT outBits = *(INT*)(conn + 0x250 + 0x4C);  // FBitWriter::Num
		if( lastStartBits == outBits )
		{
			INT outBytes   = (outBits + 7) >> 3;
			INT bunchBytes = (*(INT*)((BYTE*)Bunch + 0x4C) + 7) >> 3;
			if( bunchBytes + 9 + outBytes <= *(INT*)(conn + 0xd0) )  // MaxPacket
			{
				if( *(INT*)(conn + 0x13c + 0x30) )  // LastOut.IsError()
					appFailAssert("!Connection->LastOut.IsError()", ".\\UnChan.cpp", 0x19c);

				// Append bunch bits to Connection->LastOut.
				INT numBits = *(INT*)((BYTE*)Bunch + 0x4C);
				BYTE* data  = *(BYTE**)((BYTE*)Bunch + 0x40);   // TArray<BYTE>::Data
				((FBitWriter*)(conn + 0x13c))->SerializeBits(data, numBits);

				// OR merge flags.
				*(BYTE*)(conn + 0x1b6) |= *(BYTE*)((BYTE*)Bunch + 0x7a);  // bReliable
				*(BYTE*)(conn + 0x1b4) |= *(BYTE*)((BYTE*)Bunch + 0x78);  // bOpen
				*(BYTE*)(conn + 0x1b5) |= *(BYTE*)((BYTE*)Bunch + 0x79);  // bClose

				PreExistingBunch = *(FOutBunch**)(conn + 0x138);
				Bunch = (FOutBunch*)(conn + 0x13c);

				if( *(INT*)((BYTE*)Bunch + 0x30) )
					appFailAssert("!Bunch->IsError()", ".\\UnChan.cpp", 0x1a3);

				// Pop WriterMark — undo previous send header from output writer.
				((FBitWriterMark*)(conn + 0x120))->Pop(*(FBitWriter*)(conn + 0x250));

				// Decrement outgoing packet count.
				*(INT*)(conn + 0x210) -= 1;
			}
		}
	}
}

// Post-merge: reliable vs unreliable handling.
if( *(BYTE*)((BYTE*)Bunch + 0x7a) == 0 )  // !bReliable
{
	*(INT*)(conn + 0x138) = 0;
}
else if( PreExistingBunch == NULL )
{
	// New reliable bunch — create a copy in the OutRec linked list.
	if( (INT)((BYTE)*(BYTE*)((BYTE*)Bunch + 0x79) + 0x7f) <= NumOutRec )
		appFailAssert("NumOutRec<RELIABLE_BUFFER-1+Bunch->bClose", ".\\UnChan.cpp", 0x1af);

	*(INT*)((BYTE*)Bunch + 0x54) = 0;  // Next = NULL

	// Increment per-channel sequence counter.
	INT* pSeq = (INT*)(conn + 0x22ec + ChIndex * 4);
	*pSeq += 1;
	*(INT*)((BYTE*)Bunch + 0x70) = *pSeq;

	NumOutRec++;

	// Allocate and copy the bunch.
	FOutBunch* Copy = (FOutBunch*)GMalloc->Malloc(0x7c, TEXT("FOutBunch"));
	if( Copy )
		Copy = new(Copy) FOutBunch(*Bunch);
	else
		Copy = NULL;

	// Append to OutRec linked list.
	FOutBunch** Tail = &OutRec;
	while( *Tail )
		Tail = (FOutBunch**)((BYTE*)*Tail + 0x54);
	*Tail = Copy;
	*(FOutBunch**)(conn + 0x138) = Copy;
	Bunch = Copy;
}
else
{
	// Merged with pre-existing reliable bunch — update it.
	*(INT*)((BYTE*)Bunch + 0x54) = *(INT*)((BYTE*)PreExistingBunch + 0x54);
	*PreExistingBunch = *Bunch;
	*(FOutBunch**)(conn + 0x138) = PreExistingBunch;
	Bunch = PreExistingBunch;
}

// Clear RecvAcked.
*(INT*)((BYTE*)Bunch + 0x64) = 0;

// Send the bunch.
INT PacketId = Connection->SendRawBunch(*(FOutBunch*)Bunch, 1);

// Set OpenPacketId on first send.
if( OpenPacketId == -1 && OpenedLocally )
	OpenPacketId = PacketId;

// If closing, call SetClosingFlag.
if( *(BYTE*)((BYTE*)Bunch + 0x79) )
	SetClosingFlag();

// Copy bunch header state to Connection's last-bunch cache.
conn = (BYTE*)Connection;
*(FBitWriter*)(conn + 0x13c) = *(FBitWriter*)Bunch;
*(INT*)(conn + 0x190) = *(INT*)((BYTE*)Bunch + 0x54);
*(INT*)(conn + 0x194) = *(INT*)((BYTE*)Bunch + 0x58);
*(double*)(conn + 0x198) = *(double*)((BYTE*)Bunch + 0x5c);
*(INT*)(conn + 0x1a0) = *(INT*)((BYTE*)Bunch + 0x64);
*(INT*)(conn + 0x1a4) = *(INT*)((BYTE*)Bunch + 0x68);
*(INT*)(conn + 0x1a8) = *(INT*)((BYTE*)Bunch + 0x6c);
*(INT*)(conn + 0x1ac) = *(INT*)((BYTE*)Bunch + 0x70);
*(INT*)(conn + 0x1b0) = *(INT*)((BYTE*)Bunch + 0x74);
*(BYTE*)(conn + 0x1b4) = *(BYTE*)((BYTE*)Bunch + 0x78);
*(BYTE*)(conn + 0x1b5) = *(BYTE*)((BYTE*)Bunch + 0x79);
*(BYTE*)(conn + 0x1b6) = *(BYTE*)((BYTE*)Bunch + 0x7a);

// Save new WriterMark from output writer.
FBitWriterMark Mark(*(FBitWriter*)(conn + 0x250));
*(INT*)(conn + 0x128) = *(INT*)((BYTE*)&Mark);
*(INT*)(conn + 0x12C) = *(INT*)((BYTE*)&Mark + 4);

return PacketId;
unguard;
}


// --- UFileChannel ---
IMPL_MATCH("Engine.dll", 0x1037a530)
void UFileChannel::StaticConstructor()
{
guard(UFileChannel::StaticConstructor);
*(INT*)((BYTE*)this + 0x48) = 3;  // ChType = CHTYPE_File
unguard;
}

IMPL_MATCH("Engine.dll", 0x10481460)
void UFileChannel::Tick()
{
guard(UFileChannel::Tick);
UChannel::Tick();

// Mark the connection as having an active file transfer.
*(INT*)((BYTE*)Connection + 0x134) = 1;

// One-time lanplay flag initialisation (static DAT_107a2574/78).
static INT s_LanplayInited = 0;
static INT s_Lanplay       = 0;
if (!(s_LanplayInited & 1))
{
	s_LanplayInited |= 1;
	s_Lanplay = ParseParam(appCmdLine(), TEXT("lanplay"));
}

// Outgoing-only: loop sending file data in FOutBunch chunks.
while (true)
{
	// OpenedLocally == InType: if incoming (remote opened), we aren't sending.
	if (OpenedLocally || *(INT*)((BYTE*)this + 0x6c) == 0)
		return;

	if (!IsNetReady(s_Lanplay))
		return;

	INT max = MaxSendBytes();
	if (max == 0)
		break;

	// Remaining bytes: PackageMap->List[PackageIndex].FileSize - SentData.
	BYTE* conn   = (BYTE*)Connection;
	BYTE* pmBase = *(BYTE**)(*(BYTE**)(conn + 0xC8) + 0x2c); // List.GetData()
	INT   idx    = *(INT*)((BYTE*)this + 0x270);             // PackageIndex
	INT   total  = *(INT*)(pmBase + idx * 0x44 + 0x24);      // FileSize
	INT   sent   = *(INT*)((BYTE*)this + 0x274);             // SentData
	INT   remain = total - sent;

	// bClose = 1 if this is the last chunk.
	INT   bLast  = (remain <= max) ? 1 : 0;
	INT   chunk  = bLast ? remain : max;

	FOutBunch Bunch(this, bLast);

	// Read chunk from SendFile (FArchive vtable[1] = Serialize).
	BYTE localBuf[512];
	BYTE* buf = (chunk > 0) ? localBuf : NULL;

	FArchive* sendFile = *(FArchive**)((BYTE*)this + 0x6c);
	typedef void (__thiscall* SerializeFn)(FArchive*, void*, INT);
	((SerializeFn)(*(INT*)(*(INT*)sendFile + 4)))(sendFile, buf, chunk);
	sendFile->IsError();

	*(INT*)((BYTE*)this + 0x274) += chunk;

	// Write into bunch via FBitWriter::Serialize (static, non-virtual call in retail).
	// FOutBunch inherits from FBitWriter; cast is valid.
	((FBitWriter*)&Bunch)->Serialize(buf, chunk);

	// check(!Bunch.IsError())
	check(!((FArchive*)&Bunch)->IsError());

	SendBunch(&Bunch, 0);

	// Flush connection (vtable[0x80/4=32] = Flush).
	typedef void (__thiscall* FlushFn)(UNetConnection*);
	((FlushFn)(*(INT*)(*(INT*)Connection + 0x80)))(Connection);

	// If last chunk: delete the send file archive.
	if (bLast)
	{
		sendFile = *(FArchive**)((BYTE*)this + 0x6c);
		if (sendFile)
		{
			// Call scalar deleting destructor: vtable[0] with deleting=1.
			typedef void (__thiscall* DtorFn)(FArchive*, INT);
			((DtorFn)(*(INT*)(*(INT*)sendFile)))(sendFile, 1);
		}
		*(INT*)((BYTE*)this + 0x6c) = 0;
	}
}
unguard;
}

IMPL_TODO("Ghidra 0x10481890 (1243b): ArmPatch file-send path omitted (FGuid FUN_103bef40/FUN_103bef10 helpers, GFileManager vtable read/seek, GMalloc loop); normal PackageMap download-request path omitted (Connection->PackageMap at conn+0x7c+200 FPackageInfo array iteration). Ghidra export IS present in Engine._global.cpp; FClassNetCache defined in sdk/432Core/Inc/UnCoreNet.h. Download-write path (OpenedLocally) and close-bunch paths implemented.")
void UFileChannel::ReceivedBunch(FInBunch& Bunch)
{
guard(UFileChannel::ReceivedBunch);

// Assert !Closing
check(!Closing);

if (!OpenedLocally)
{
	// Server side: received a request or message from client.
	// Check Connection->Driver->Notify->bDedicated (offset chain: Connection+0x7c → Driver, then +0x74)
	BYTE* conn = (BYTE*)Connection;
	INT bDedicated = *(INT*)(*(INT*)(*(INT*)(conn + 0x7c) + 0x74));

	if (!bDedicated)
	{
		// Not dedicated server: reject with close bunch
		FOutBunch CloseBunch(this, 1);
		SendBunch(&CloseBunch, 0);
	}
	else if (*(INT*)((BYTE*)this + 0x6c) == 0)
	{
		// No SendFile yet: process file request.
		// Read GUID from incoming bunch.
		// ArmPatch handling and normal PackageMap iteration omitted —
		// full implementation requires FGuid by-value construction (forward-declared only).
		// DIVERGE: ArmPatch file transfer path and PackageMap iteration not implemented.

		// Fall through: send close bunch to reject
		FOutBunch CloseBunch(this, 1);
		SendBunch(&CloseBunch, 0);
	}
	else
	{
		// SendFile exists: check for "SKIP" command from client.
		FString Cmd;
		Bunch << Cmd;
		if (!Bunch.IsError() && Cmd == TEXT("SKIP"))
		{
			// Log and skip this package.
			GLog->Logf(*(const TCHAR**)((BYTE*)this + 0x70));  // Filename string
			// FUN_103bfaf0: SkipPackage helper — omitted (unknown internal)
		}
		else
		{
			// Unknown command: send close bunch
			FOutBunch CloseBunch(this, 1);
			SendBunch(&CloseBunch, 0);
		}
	}
}
else if (*(INT*)((BYTE*)this + 0x68) != 0)
{
	// Client side with active Download: write received data to it.
	INT numBytes = Bunch.GetNumBytes();
	BYTE* data = Bunch.GetData();

	// Download vtable[0x6c/4=27] = ReceivedData(Data, Count)
	void* dl = *(void**)((BYTE*)this + 0x68);
	typedef void (__thiscall* RecvDataFn)(void*, BYTE*, INT);
	((RecvDataFn)(*(INT*)(*(INT*)dl + 0x6c)))(dl, data, numBytes);
}

unguard;
}

IMPL_MATCH("Engine.dll", 0x10481660)
FString UFileChannel::Describe()
{
	// Ghidra 0x181660 (268b):
	// "File='%s', Sent=%i/%i " (outgoing) or "File='%s', Received=%i/%i " (incoming)
	// + UChannel::Describe()
	INT    pkgIdx  = *(INT*)((BYTE*)this + 0x270);    // PackageIndex
	BYTE*  conn    = (BYTE*)Connection;

	// PackageMap->List.GetData() base pointer.
	BYTE*  pkgMap  = *(BYTE**)(*(BYTE**)(conn + 0xC8) + 0x2c);
	INT    total   = *(INT*)(pkgMap + pkgIdx * 0x44 + 0x24); // List[pkgIdx].FileSize

	const TCHAR* sendRecv;
	INT          current;
	const TCHAR* filename;

	if (!OpenedLocally)
	{
		// Outgoing: sending a file.
		sendRecv = TEXT("Sent");
		current  = *(INT*)((BYTE*)this + 0x274);            // SentData
		filename = *(const TCHAR**)((BYTE*)this + 0x70);    // Filename.GetData()
	}
	else if (*(INT*)((BYTE*)this + 0x68) == 0)
	{
		// Incoming but no Download yet.
		sendRecv = TEXT("Received");
		current  = 0;
		filename = TEXT("");
	}
	else
	{
		// Incoming with Download object.
		BYTE* dl  = *(BYTE**)((BYTE*)this + 0x68);
		sendRecv  = TEXT("Received");
		current   = *(INT*)(dl + 0x44c);                    // Download bytes received
		filename  = *(const TCHAR**)(dl + 0x4c);            // Download filename string
	}

	return FString::Printf(TEXT("File='%s', %s=%i/%i "), filename, sendRecv, current, total)
		 + UChannel::Describe();
}

IMPL_MATCH("Engine.dll", 0x10484100)
void UFileChannel::Destroy()
{
	// Ghidra 0x184100: assert Connection, call RouteDestroy.
	// If returns 0: assert Channels[ChIndex]==this, delete SendFile at +0x6C,
	// if InType and Download at +0x68 exist: flush download then delete it,
	// then UChannel::Destroy.
	check(Connection != NULL);
	if (RouteDestroy() == 0)
	{
		BYTE* conn = (BYTE*)Connection;
		check(*(UFileChannel**)(conn + 0xEB0 + ChIndex * 4) == this);

		// Delete send file at +0x6C (virtual destructor, delete=1)
		void** sendFile = (void**)((BYTE*)this + 0x6C);
		if (*sendFile)
		{
			typedef void (__thiscall *DtorFn)(void*, INT);
			((DtorFn)(*(INT*)*(INT*)*sendFile))(*sendFile, 1);
			*sendFile = NULL;
		}

		// If incoming type and download at +0x68 exist, flush then delete
		if (OpenedLocally && *(void**)((BYTE*)this + 0x68))
		{
			void* dld = *(void**)((BYTE*)this + 0x68);
			// Flush via vtable[0x78/4] = vtable[30]
			typedef void (__thiscall *FlushFn)(void*);
			((FlushFn)(*(INT*)(*(INT*)dld + 0x78)))(dld);

			if (*(void**)((BYTE*)this + 0x68))
			{
				dld = *(void**)((BYTE*)this + 0x68);
				// Delete via vtable[0xC/4] = vtable[3] (scalar deleting destructor)
				typedef void (__thiscall *DtorFn2)(void*, INT);
				((DtorFn2)(*(INT*)(*(INT*)dld + 0xC)))(dld, 1);
			}
		}

		UChannel::Destroy();
	}
}

IMPL_MATCH("Engine.dll", 0x10480f30)
void UFileChannel::Init(UNetConnection* Conn, int ChIndex, int InType)
{
	guard(UFileChannel::Init);
	UChannel::Init(Conn, ChIndex, InType);
	unguard;
}


// --- UActorChannel ---
IMPL_MATCH("Engine.dll", 0x1037a4a0)
void UActorChannel::StaticConstructor()
{
guard(UActorChannel::StaticConstructor);
*(INT*)((BYTE*)this + 0x48) = 2;  // ChType = CHTYPE_Actor
unguard;
}

IMPL_MATCH("Engine.dll", 0x10480d50)
void UActorChannel::Tick()
{
guard(UActorChannel::Tick);
UChannel::Tick();
unguard;
}

IMPL_TODO("Ghidra 0x104827f0 (2931b): complex actor property replication receive. Ghidra export IS present in Engine._global.cpp. FClassNetCache defined in sdk/432Core/Inc/UnCoreNet.h (GetFromField/GetFromIndex/GetMaxIndex/RepProperties). Blocked by: FFieldNetCache struct layout (vtable calls on FFieldNetCache* at +0x8/+0xc/+0x10 not yet mapped to named members); UProperty serialisation helpers FUN_10481010/FUN_1047fa50; FBitReader::GetNumBits bitmask diffing pattern.")
void UActorChannel::ReceivedBunch(FInBunch&)
{
guard(UActorChannel::ReceivedBunch);
unguard;
}

IMPL_MATCH("Engine.dll", 0x104824d0)
void UActorChannel::ReceivedNak(int NakPacketId)
{
guard(UActorChannel::ReceivedNak);
UChannel::ReceivedNak(NakPacketId);

// If Actor (+0x70) is set, scan Retire array for entries matching
// NakPacketId whose dirty flag is 0, and add their index to the Dirty list.
if ( *(INT*)((BYTE*)this + 0x70) != 0 )
{
	TArray<INT>& Dirty = *(TArray<INT>*)((BYTE*)this + 0xC4);
	INT Count = *(INT*)((BYTE*)this + 0xBC);  // Retire.Num()
	for ( INT i = Count - 1; i >= 0; i-- )
	{
		BYTE* Entry = *(BYTE**)((BYTE*)this + 0xB8) + i * 0xC;  // Retire stride=12
		INT   PacketId  = *(INT*)(Entry + 4);
		BYTE  DirtyFlag = *(Entry + 8);
		if ( PacketId == NakPacketId && DirtyFlag == 0 )
		{
			Dirty.AddUniqueItem(i);
		}
	}
}
unguard;
}

IMPL_TODO("Ghidra 0x104834d0 (2840b): full actor property replication send. Ghidra export IS present in Engine._global.cpp. Uses Connection->PackageMap vtable[0x84/4] to obtain FClassNetCache (FClassNetCache defined in sdk/432Core/Inc/UnCoreNet.h). Blocked by: FFieldNetCache struct layout (vtable-dispatched property serialisation); FOutBunch/FBitWriterMark serialization loop per-field; replication condition bitmask (Actor+0xac bits 0x20/0x40); FUN_10481dd0/FUN_10481160 helper chains.")
void UActorChannel::ReplicateActor()
{
guard(UActorChannel::ReplicateActor);
unguard;
}

IMPL_MATCH("Engine.dll", 0x10482590)
void UActorChannel::SetChannelActor(AActor* InActor)
{
guard(UActorChannel::SetChannelActor);
	if ( *(INT*)((BYTE*)this + 0x34) != 0 )
		appFailAssert("!Closing", ".\\UnChan.cpp", 0x2ef);
	if ( *(INT*)((BYTE*)this + 0x6c) != 0 )
		appFailAssert("Actor==NULL", ".\\UnChan.cpp", 0x2f0);

	*(AActor**)((BYTE*)this + 0x6c) = InActor;
	UClass* ActorClass = InActor->GetClass();
	*(UClass**)((BYTE*)this + 0x70) = ActorClass;

	FClassNetCache* ClassCache =
		((UPackageMap*)(*(INT*)((BYTE*)*(UNetConnection**)((BYTE*)this + 0x2c) + 0xc8)))->GetClassNetCache(ActorClass);

	UActorChannel* ThisChan = this;
	TMap<AActor*, UActorChannel*>* ActorChannels =
		(TMap<AActor*, UActorChannel*>*)((BYTE*)(*(UNetConnection**)((BYTE*)this + 0x2c)) + 0x4B94);
	ActorChannels->Set( *(AActor**)((BYTE*)this + 0x6c), ThisChan );

	((FArray*)((BYTE*)this + 0xa0))->AddZeroed( 1, ClassCache->GetRepConditionCount() );

	if ( ( *(DWORD*)((BYTE*)InActor + 0xa0) & 0x10000000 ) == 0 )
	{
		const INT PropSize = ((FArray*)((BYTE*)ActorClass + 0x4dc))->Num();
		((FArray*)((BYTE*)this + 0x94))->Add( PropSize, 1 );
		UObject::InitProperties( *(BYTE**)((BYTE*)this + 0x94), PropSize, ActorClass, NULL, 0, NULL, 0 );

		for ( UObject* Property = *(UObject**)((BYTE*)ActorClass + 0x6c); Property; Property = *(UObject**)((BYTE*)Property + 0x54) )
		{
			if ( (*(DWORD*)((BYTE*)Property + 0x40) & 0x400000) != 0 )
			{
				((void(__thiscall*)(UObject*, BYTE*))(*(DWORD*)(*(DWORD*)Property + 0xa4)))
					(Property, *(BYTE**)((BYTE*)this + 0x94) + *(INT*)((BYTE*)Property + 0x4c));
			}

			if ( !Property->IsA( UBoolProperty::StaticClass() ) )
			{
				appMemzero(
					*(BYTE**)((BYTE*)this + 0x94) + *(INT*)((BYTE*)Property + 0x4c),
					((UProperty*)Property)->GetSize()
				);
			}
			else
			{
				*(DWORD*)(*(BYTE**)((BYTE*)this + 0x94) + *(INT*)((BYTE*)Property + 0x4c)) &=
					~(*(DWORD*)((BYTE*)Property + 0x70));
			}
		}
	}

	const INT RetireCount = ((FArray*)((BYTE*)ActorClass + 0x4ac))->Num();
	((FArray*)((BYTE*)this + 0xb8))->Empty( 0xc, RetireCount );
	while( ((FArray*)((BYTE*)this + 0xb8))->Num() < ((FArray*)((BYTE*)ActorClass + 0x4ac))->Num() )
	{
		const INT NewIndex = ((FArray*)((BYTE*)this + 0xb8))->Add( 1, 0xc );
		DWORD* Entry = (DWORD*)(*(INT*)((BYTE*)this + 0xb8) + NewIndex * 0xc);
		if( Entry )
		{
			Entry[0] = 0xFFFFFFFF;
			Entry[1] = 0xFFFFFFFF;
		}
	}
unguard;
}

IMPL_MATCH("Engine.dll", 0x104821d0)
void UActorChannel::SetClosingFlag()
{
	guard(UActorChannel::SetClosingFlag);
	// Ghidra: if Actor at +0x6C is non-null, remove it from the
	// connection's actor-channel TMap, then delegate to base.
	AActor* Actor = *(AActor**)((BYTE*)this + 0x6C);
	if ( Actor != NULL )
	{
		// FUN_10481e90 = TMap::Remove — removes Actor from Connection->ActorChannels
		UNetConnection* Conn = *(UNetConnection**)((BYTE*)this + 0x2C);
		TMap<AActor*, UActorChannel*>* ActorChannels =
			(TMap<AActor*, UActorChannel*>*)((BYTE*)Conn + 0x4B94);
		ActorChannels->Remove( Actor );
	}
	UChannel::SetClosingFlag();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104813e0)
void UActorChannel::Close()
{
// Ghidra 0x1813e0: UChannel::Close then zero the actor reference at this+0x6C.
UChannel::Close();
*(INT*)((BYTE*)this + 0x6C) = 0;
}

IMPL_MATCH("Engine.dll", 0x10480dc0)
FString UActorChannel::Describe()
{
	// Ghidra 0x180dc0: if not closing and actor exists, return actor info + base.
	// Otherwise return "Actor=None " + base.
	if (!Closing && *(INT*)((BYTE*)this + 0x6C) != 0)
	{
		UObject* Actor = *(UObject**)((BYTE*)this + 0x6C);
		return FString::Printf(TEXT("Actor=%s (Role=%i RemoteRole=%i) "),
			Actor->GetFullName(),
			(INT)*(BYTE*)((BYTE*)Actor + 0x2D),   // Role
			(INT)*(BYTE*)((BYTE*)Actor + 0x2E))    // RemoteRole
			+ UChannel::Describe();
	}
	return FString(TEXT("Actor=None ")) + UChannel::Describe();
}

IMPL_MATCH("Engine.dll", 0x10482260)
void UActorChannel::Destroy()
{
	guard(UActorChannel::Destroy);
	check(Connection != NULL);
	if (!UChannel::RouteDestroy())
	{
		// Assert Channels[ChIndex] == this
		BYTE* conn = (BYTE*)Connection;
		check(*(UActorChannel**)(conn + 0xEB0 + ChIndex * 4) == this);

		// Call virtual reset function at vtable slot 0x1A (offset 0x68) on this
		typedef void (__thiscall* VFunc26)(void*);
		((VFunc26)(*(DWORD*)((BYTE*)*(DWORD**)this + 0x68)))(this);

		// Free replication property buffer
		FArray* repData = (FArray*)((BYTE*)this + 0x94);
		INT num = repData->Num();
		if (num != 0)
		{
			check(*(INT*)((BYTE*)this + 0x70) != 0); // ActorClass
			UObject::ExitProperties(*(BYTE**)((BYTE*)this + 0x94), *(UClass**)((BYTE*)this + 0x70));
		}

		// Determine client vs server via Connection->Driver->ServerConnection (0x3C)
		BYTE* drv = *(BYTE**)(conn + 0x7C);
		if (*(INT*)(drv + 0x3C) == 0)
		{
			// Client side: clean up actor ref via FUN_103db080
			if (*(INT*)((BYTE*)this + 0x6C) != 0 && !OpenAcked)
			{
				// FUN_103db080: actor-channel teardown — zeroes actor ref and deregisters from level.
				// TODO: blocked by FUN_103db080 (UActorChannel_CleanupActorRef)
			}
		}
		else
		{
			// Server side: validate actor/level/connection/driver
			UObject* actor = *(UObject**)((BYTE*)this + 0x6C);
			if (actor != NULL)
				check(actor->IsValid());
			check(*(INT*)((BYTE*)this + 0x68) != 0);              // Level
			check((*(UObject**)((BYTE*)this + 0x68))->IsValid());  // Level->IsValid()
			check(Connection != NULL);
			check(Connection->IsValid());
			check(*(INT*)(conn + 0x7C) != 0);                     // Connection->Driver
			check((*(UObject**)(conn + 0x7C))->IsValid());         // Connection->Driver->IsValid()

			// Server-side actor role cleanup
			INT actorAddr = *(INT*)((BYTE*)this + 0x6C);
			if (actorAddr != 0)
			{
				if ((*(BYTE*)(actorAddr + 0xA4) & 0x10) == 0)
				{
					// Not bTearOff: if not bNetTemporary, call TearOff virtual
					if ((*(DWORD*)(actorAddr + 0xA0) & 0x10000000) == 0)
					{
						// vtable call on actor's Level: Actor->Level->vtable[0xA0/4](actor, 1)
						typedef void (__thiscall *TearOffFn)(void*, INT);
						INT* level = *(INT**)(actorAddr + 0x328);
						((TearOffFn)(*(INT*)(*(INT*)level + 0xA0)))(level, 1);
					}
				}
				else
				{
					// bTearOff: set Role=ROLE_Authority(4), RemoteRole=ROLE_None(0)
					*(BYTE*)(actorAddr + 0x2D) = 4;
					*(BYTE*)(*(INT*)((BYTE*)this + 0x6C) + 0x2E) = 0;
				}
			}
		}

		UChannel::Destroy();
	}
	unguard;
}

IMPL_EMPTY("Ghidra VA 0x103705A0 (RVA 0x705A0) confirms retail body is trivial (4 bytes)")
AActor* UActorChannel::GetActor()
{
// Ghidra (4B): Actor at offset 0x6C
return *(AActor**)((BYTE*)this + 0x6C);
}

IMPL_MATCH("Engine.dll", 0x10480c90)
void UActorChannel::Init(UNetConnection* Conn, int ChIndex, int InType)
{
	guard(UActorChannel::Init);
	// Ghidra 0x180c90: UChannel::Init + initialise actor-specific replication fields.
	UChannel::Init(Conn, ChIndex, InType);

	BYTE* conn = (BYTE*)Conn;
	BYTE* driver = *(BYTE**)(conn + 0x7C);       // Connection->Driver
	BYTE* levelObj = *(BYTE**)(driver + 0x40);    // Driver->Level (or NetInfo object at +0x40)

	// Get game time via levelObj vtable[3] (offset 0xC)
	typedef INT (__thiscall *GetTimeFn)(void*);
	INT gameTime = ((GetTimeFn)(*(INT*)(*(INT*)levelObj + 0xC)))(levelObj);
	*(INT*)((BYTE*)this + 0x68) = gameTime;

	// Copy TimeSeconds (double at Driver+0x48)
	*(double*)((BYTE*)this + 0x74) = *(double*)(driver + 0x48);

	// RelevantTime = TimeSeconds - TickRate (float at Driver+0x60)
	FLOAT tickRate = *(FLOAT*)(driver + 0x60);
	*(double*)((BYTE*)this + 0x7C) = *(double*)(driver + 0x48) - (double)tickRate;

	// Zero replication tracking
	*(INT*)((BYTE*)this + 0x88) = 0;
	*(INT*)((BYTE*)this + 0x8C) = 0;
	*(INT*)((BYTE*)this + 0x90) = 0;
	unguard;
}


// --- UControlChannel ---
IMPL_MATCH("Engine.dll", 0x1037a410)
void UControlChannel::StaticConstructor()
{
guard(UControlChannel::StaticConstructor);
*(INT*)((BYTE*)this + 0x48) = 1;  // ChType = CHTYPE_Control
unguard;
}

IMPL_MATCH("Engine.dll", 0x104809e0)
void UControlChannel::ReceivedBunch(FInBunch& Bunch)
{
guard(UControlChannel::ReceivedBunch);
	check(!Closing);

	// Ghidra 0x1809e0: loop reading FStrings from bunch, dispatch each via
	// Connection->Driver->Level->LevelInfo->vtable[4](Connection, Text).
	for (;;)
	{
		FString Text;
		*(FArchive*)&Bunch << Text;
		if (((FArchive*)&Bunch)->IsError())
			break;

		// Dispatch to level: LevelInfo->vtable[4](Connection, *Text)
		// Connection->Driver (+0x7C) -> Level (+0x40) -> vtable[0x10/4=4]
		BYTE* conn = (BYTE*)Connection;
		BYTE* driver = *(BYTE**)(conn + 0x7C);
		BYTE* level = *(BYTE**)(driver + 0x40);
		typedef void (__thiscall *NotifyFn)(void*, UNetConnection*, const TCHAR*);
		((NotifyFn)(*(INT*)(*(INT*)level + 0x10)))(level, Connection, *Text);
	}
unguard;
}

IMPL_MATCH("Engine.dll", 0x10480ad0)
void UControlChannel::Serialize(const TCHAR* Data, EName Event)
{
guard(UControlChannel::Serialize);
	// Ghidra 0x180ad0: Create FOutBunch, serialize Data as FString, send if no error.
	// Note: Ghidra shows `this + -0x68` because this Serialize is dispatched through
	// FOutputDevice vtable (second base class). The compiler generates a thunk that
	// adjusts this to UControlChannel* automatically.
	FOutBunch Bunch(this, 0);
	*(BYTE*)((BYTE*)&Bunch + 0x7A) = 1;  // bReliable = 1
	FString Str(Data);
	*(FArchive*)&Bunch << Str;
	if (!((FArchive*)&Bunch)->IsError())
		SendBunch(&Bunch, 1);
unguard;
}

IMPL_MATCH("Engine.dll", 0x10480bc0)
FString UControlChannel::Describe()
{
	// Ghidra 0x180bc0: return FString("Text ") + UChannel::Describe()
	return FString(TEXT("Text ")) + UChannel::Describe();
}

IMPL_MATCH("Engine.dll", 0x10482070)
void UControlChannel::Destroy()
{
	// Ghidra 0x182070: assert Connection, call RouteDestroy.
	// If returns 0: call UChannel::Destroy.
	check(Connection != NULL);
	if (RouteDestroy() == 0)
		UChannel::Destroy();
}

IMPL_MATCH("Engine.dll", 0x10480960)
void UControlChannel::Init(UNetConnection* Conn, int ChIndex, int InType)
{
	guard(UControlChannel::Init);
	UChannel::Init(Conn, ChIndex, InType);
	unguard;
}


// =============================================================================
// UChannel (moved from EngineClassImpl.cpp)
// =============================================================================

// UChannel
// =============================================================================

IMPL_MATCH("Engine.dll", 0x10481f20)
void UChannel::Destroy()
{
	guard(UChannel::Destroy);
	check(Connection != NULL);
	check(*(UChannel**)((BYTE*)Connection + 0xEB0 + ChIndex * 4) == this);

	// Free OutRec linked list (each FOutBunch: vtable[0](1) = scalar deleting destructor)
	FOutBunch* Out = OutRec;
	while (Out)
	{
		FOutBunch* Next = *(FOutBunch**)((BYTE*)Out + 0x54);
		typedef void (__thiscall *DtorFn)(void*, INT);
		((DtorFn)(*(INT*)*(INT*)Out))(Out, 1);
		Out = Next;
	}

	// Free InRec linked list (each FInBunch: vtable[0](1))
	FInBunch* In = InRec;
	while (In)
	{
		FInBunch* Next = *(FInBunch**)((BYTE*)In + 0x58);
		typedef void (__thiscall *DtorFn)(void*, INT);
		((DtorFn)(*(INT*)*(INT*)In))(In, 1);
		In = Next;
	}

	// Remove this from Connection->OpenChannels (TArray at Connection+0x4B7C)
	BYTE* conn = (BYTE*)Connection;
	INT* pCount = (INT*)(conn + 0x4B80);
	INT origCount = *pCount;
	for (INT i = 0; i < *pCount; i++)
	{
		UChannel** arr = *(UChannel***)(conn + 0x4B7C);
		if (arr[i] == this)
		{
			// TArray::Remove(i, 1) — shift down
			for (INT j = i; j < *pCount - 1; j++)
				arr[j] = arr[j + 1];
			(*pCount)--;
			i--;
		}
	}
	check(origCount - *pCount == 1);

	// Clear channel slot and connection reference
	*(INT*)((BYTE*)Connection + 0xEB0 + ChIndex * 4) = 0;
	Connection = NULL;
	Super::Destroy();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1047fb60)
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

IMPL_MATCH("Engine.dll", 0x1047fc50)
void UChannel::SetClosingFlag() { Closing = 1; }

IMPL_MATCH("Engine.dll", 0x104811f0)
void UChannel::Close()
{
guard(UChannel::Close);
	check(*(UChannel**)((BYTE*)Connection + 0xEB0 + ChIndex * 4) == this);

	// Only send close bunch if not already closing and connection state is 2 or 3
	if (!Closing)
	{
		INT connState = *(INT*)((BYTE*)Connection + 0x80);
		if (connState == 3 || connState == 2)
		{
			FOutBunch CloseBunch(this, 1);
			check(!((FArchive*)&CloseBunch)->IsError());
			check(*(BYTE*)((BYTE*)&CloseBunch + 0x79) != 0);  // bClose must be set
			*(BYTE*)((BYTE*)&CloseBunch + 0x7A) = 1;          // bReliable = 1
			SendBunch(&CloseBunch, 0);
		}
	}
unguard;
}

IMPL_MATCH("Engine.dll", 0x104806c0)
FString UChannel::Describe()
{
guard(UChannel::Describe);
	// Ghidra 0x1806c0: returns FString("State=")
	return FString(TEXT("State="));
unguard;
}

IMPL_MATCH("Engine.dll", 0x10480850)
void UChannel::ReceivedNak(INT NakPacketId)
{
guard(UChannel::ReceivedNak);
	for (FOutBunch* Out = OutRec; Out; Out = *(FOutBunch**)((BYTE*)Out + 0x54))
	{
		if (*(INT*)((BYTE*)Out + 0x74) == NakPacketId && *(INT*)((BYTE*)Out + 0x64) == 0)
		{
			check(*(BYTE*)((BYTE*)Out + 0x7A) != 0);  // Out->bReliable
			debugf(NAME_DevNet, TEXT("Resending bunch"));
			Connection->SendRawBunch(*Out, 0);
		}
	}
unguard;
}

IMPL_MATCH("Engine.dll", 0x1047fd90)
void UChannel::Tick()
{
guard(UChannel::Tick);
	check(*(UChannel**)((BYTE*)Connection + 0xEB0 + ChIndex * 4) == this);

	// Only resend on channel 0 when not opened locally
	if (ChIndex == 0 && OpenedLocally == 0)
	{
		for (FOutBunch* Out = OutRec; Out; Out = *(FOutBunch**)((BYTE*)Out + 0x54))
		{
			// If not yet acked and time elapsed > 1.0 second
			if (*(INT*)((BYTE*)Out + 0x64) == 0)
			{
				BYTE* conn = (BYTE*)Connection;
				BYTE* driver = *(BYTE**)(conn + 0x7C);
				double curTime = *(double*)(driver + 0x48);
				double sentTime = *(double*)((BYTE*)Out + 0x5C);
				if (curTime - sentTime > 1.0)
				{
					debugf(NAME_DevNet, TEXT("UChannel::Tick: Resending"));
					check(*(BYTE*)((BYTE*)Out + 0x7A) != 0);  // Out->bReliable
					Connection->SendRawBunch(*Out, 0);
				}
			}
		}
	}
unguard;
}

IMPL_MATCH("Engine.dll", 0x1047fec0)
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

IMPL_MATCH("Engine.dll", 0x10480820)
INT CDECL UChannel::IsKnownChannelType(INT Type)
{
if (Type >= 0 && Type < 8 && UChannel::ChannelClasses[Type])
return 1;
return 0;
}

IMPL_MATCH("Engine.dll", 0x10480780)
INT UChannel::IsNetReady( INT Saturate )
{
	// Ghidra 0x180780: if NumOutRec > 126, return 0.
	// Otherwise delegate to Connection->IsNetReady(Saturate) virtual.
	if (NumOutRec > 0x7E)
		return 0;
	return Connection->IsNetReady(Saturate);
}

IMPL_MATCH("Engine.dll", 0x10481320)
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

IMPL_MATCH("Engine.dll", 0x1047fc60)
void UChannel::ReceivedAcks()
{
guard(UChannel::ReceivedAcks);
	check(*(UChannel**)((BYTE*)Connection + 0xEB0 + ChIndex * 4) == this);

	// Assert OutRec is in sequence order
	for (FOutBunch* Out = OutRec; Out && *(FOutBunch**)((BYTE*)Out + 0x54);
	     Out = *(FOutBunch**)((BYTE*)Out + 0x54))
	{
		FOutBunch* Next = *(FOutBunch**)((BYTE*)Out + 0x54);
		check(*(INT*)((BYTE*)Next + 0x70) > *(INT*)((BYTE*)Out + 0x70));
	}

	// Free acked bunches from the head of OutRec
	BYTE bHadClose = 0;
	while (OutRec != NULL && *(INT*)((BYTE*)OutRec + 0x64) != 0)
	{
		bHadClose |= *(BYTE*)((BYTE*)OutRec + 0x79);  // accumulate bClose flag
		FOutBunch* Next = *(FOutBunch**)((BYTE*)OutRec + 0x54);
		typedef void (__thiscall *DtorFn)(void*, INT);
		((DtorFn)(*(INT*)*(INT*)OutRec))(OutRec, 1);
		OutRec = Next;
		NumOutRec--;
	}

	// If we had a close ack, or if channel is open-temporary and was opened, destroy
	if (bHadClose || (OpenTemporary && OpenedLocally))
	{
		check(!OutRec);
		// vtable[3](1) = Destroy(1) — call virtual Destroy
		typedef void (__thiscall *DestroyFn)(void*, INT);
		((DestroyFn)(*(INT*)(*(INT*)this + 0xC)))(this, 1);
	}
unguard;
}

IMPL_MATCH("Engine.dll", 0x10480070)
void UChannel::ReceivedRawBunch(FInBunch& Bunch)
{
guard(UChannel::ReceivedRawBunch);
	check(*(UChannel**)((BYTE*)Connection + 0xEB0 + ChIndex * 4) == this);

	BYTE* conn = (BYTE*)Connection;
	INT* pInReliable = (INT*)(conn + 0x3728 + ChIndex * 4);

	// If bunch is not reliable, or is the next expected reliable sequence
	if (*(BYTE*)((BYTE*)&Bunch + 0x6E) == 0 ||
	    *(INT*)((BYTE*)&Bunch + 0x68) == *pInReliable + 1)
	{
		// Process in sequence
		if (ReceivedSequencedBunch(Bunch) != 0)
			return;

		// Drain any queued bunches that are now in sequence
		while (InRec != NULL &&
		       *(INT*)((BYTE*)InRec + 0x68) == *pInReliable + 1)
		{
			debugf(NAME_DevNet, TEXT("UChannel::ReceivedRawBunch draining queued"));
			FInBunch* Queued = InRec;
			InRec = *(FInBunch**)((BYTE*)Queued + 0x58);
			NumInRec--;
			if (ReceivedSequencedBunch(*Queued) != 0)
			{
				// Delete queued bunch
				typedef void (__thiscall *DtorFn)(void*, INT);
				if (Queued) ((DtorFn)(*(INT*)*(INT*)Queued))(Queued, 1);
				return;
			}
			typedef void (__thiscall *DtorFn)(void*, INT);
			if (Queued) ((DtorFn)(*(INT*)*(INT*)Queued))(Queued, 1);
			AssertInSequenced();
		}
	}
	else
	{
		// Out-of-order reliable bunch — queue it
		INT bunchSeq = *(INT*)((BYTE*)&Bunch + 0x68);
		check(bunchSeq > *pInReliable);
		debugf(NAME_DevNet, TEXT("UChannel::ReceivedRawBunch queuing out-of-order"));

		// Find insertion point (sorted by ChSequence)
		FInBunch** pLink = &InRec;
		while (*pLink != NULL)
		{
			INT linkSeq = *(INT*)((BYTE*)*pLink + 0x68);
			if (bunchSeq == linkSeq)
				return;  // duplicate
			if (bunchSeq < linkSeq)
				break;
			pLink = (FInBunch**)((BYTE*)*pLink + 0x58);
		}

		// Allocate new FInBunch copy and insert
		FInBunch* New = new(appMalloc(sizeof(FInBunch), TEXT("FInBunch"))) FInBunch(Bunch);
		*(FInBunch**)((BYTE*)New + 0x58) = *pLink;
		*pLink = New;
		NumInRec++;
		check(NumInRec <= 128);
		AssertInSequenced();
	}
unguard;
}

IMPL_MATCH("Engine.dll", 0x1047ff60)
INT UChannel::ReceivedSequencedBunch(FInBunch& Bunch)
{
guard(UChannel::ReceivedSequencedBunch);
	// Update InReliable sequence number if this is a reliable bunch
	if (*(BYTE*)((BYTE*)&Bunch + 0x6E) != 0)
	{
		*(INT*)((BYTE*)Connection + 0x3728 + ChIndex * 4) =
			*(INT*)((BYTE*)&Bunch + 0x68);
	}

	// If channel is not broken, dispatch to ReceivedBunch virtual
	if (!Closing)
	{
		// vtable[0x74/4] = ReceivedBunch virtual
		typedef void (__thiscall *RecvFn)(void*, FInBunch&);
		((RecvFn)(*(INT*)(*(INT*)this + 0x74)))(this, Bunch);
	}

	// If bunch has bClose flag, handle channel close
	if (*(BYTE*)((BYTE*)&Bunch + 0x6D) != 0)
	{
		if (InRec != NULL)
			GNull->Logf(TEXT(""));
		debugf(NAME_DevNet, TEXT("UChannel::ReceivedSequencedBunch: close"));
		// vtable[0xC/4] = Destroy virtual
		typedef void (__thiscall *DestroyFn)(void*);
		((DestroyFn)(*(INT*)(*(INT*)this + 0xC)))(this);
		return 1;
	}
	return 0;
unguard;
}

IMPL_MATCH("Engine.dll", 0x1047fb90)
INT UChannel::RouteDestroy()
{
guard(UChannel::RouteDestroy);
	if (Connection != NULL)
	{
		DWORD connFlags = Connection->GetFlags();
		if (connFlags & RF_Unreachable)
		{
			// Temporarily clear RF_Destroyed on this channel so
			// Connection->ConditionalDestroy can reference us.
			ClearFlags(RF_Destroyed);
			if (Connection->ConditionalDestroy())
				return 1;
			SetFlags(RF_Destroyed);
		}
	}
	return 0;
unguard;
}

// =============================================================================

// =============================================================================
// UChannel virtuals (moved from EngineClassImpl.cpp)
// =============================================================================

// UChannel
// ---------------------------------------------------------------------------
IMPL_DIVERGE("Base UChannel::StaticConstructor has no retail export; empty stub needed for vtable slot — subclasses override with ChType assignment")
void UChannel::StaticConstructor()
{
guard(UChannel::StaticConstructor);
unguard;
}

IMPL_DIVERGE("Base UChannel::ReceivedBunch has no retail export; pure-virtual-like — always dispatched to subclass override (UActorChannel, UControlChannel, UFileChannel)")
void UChannel::ReceivedBunch(FInBunch& Bunch)
{
guard(UChannel::ReceivedBunch);
unguard;
}

IMPL_DIVERGE("Base UChannel::Serialize has no retail export; FOutputDevice::Serialize override only meaningful on UControlChannel — base stub is unreachable")
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
IMPL_MATCH("Engine.dll", 0x1036fa90)
FInBunch::FInBunch(const FInBunch& Other) : FBitReader() { appMemcpy(this, &Other, sizeof(*this)); }
// DIVERGENCE: retail calls FBitReader(nullptr, 0) then sets vtable, Connection (0x5c),
//             BunchIndex (0x58=0), TimeoutTime (0x38=10000).  We zero Pad instead.
IMPL_MATCH("Engine.dll", 0x1047f6b0)
FInBunch::FInBunch(UNetConnection*) : FBitReader() { appMemzero(Pad, sizeof(Pad)); }
IMPL_MATCH("Engine.dll", 0x1036faf0)
FInBunch& FInBunch::operator=(const FInBunch& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }
IMPL_MATCH("Engine.dll", 0x1047f6e0)
FArchive& FInBunch::operator<<(UObject*& Obj) { return *this; }
IMPL_MATCH("Engine.dll", 0x1047f770)
FArchive& FInBunch::operator<<(FName& N) { return *this; }

// ============================================================================
// FOutBunch
// ============================================================================
// DIVERGENCE: retail calls FBitWriter(0) + sets vtable.  We zero the whole object.
IMPL_MATCH("Engine.dll", 0x1036f960)
FOutBunch::FOutBunch() { appMemzero(this, sizeof(*this)); }
// DIVERGENCE: retail calls FBitWriter copy-ctor then sets vtable + individual fields
//             (offsets 0x54-0x7a).  We memcpy; same aliasing caveat as FInBunch above.
IMPL_MATCH("Engine.dll", 0x1047f800)
FOutBunch::FOutBunch(const FOutBunch& Other) { appMemcpy(this, &Other, sizeof(*this)); }
// DIVERGENCE: retail calls FBitWriter(connection->MaxPacket*8-81), sets Channel (0x58),
//             ChIndex (0x68), ChSequence (0x6c), flags (0x78-0x7a), validates assertions.
IMPL_MATCH("Engine.dll", 0x1047f820)
FOutBunch::FOutBunch(UChannel*, INT) { appMemzero(this, sizeof(*this)); }
// Ghidra 0x1036f9c0 (88b): calls FBitWriter::operator= for base, then copies
// fields 0x54-0x7a individually. We use appMemcpy which covers everything; the
// vtable pointer at offset 0 is identical between source and dest (both FOutBunch).
IMPL_MATCH("Engine.dll", 0x1036f9c0)
FOutBunch& FOutBunch::operator=(const FOutBunch& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }
IMPL_MATCH("Engine.dll", 0x1036f950)
FOutBunch::~FOutBunch() {}
IMPL_MATCH("Engine.dll", 0x1047f930)
FArchive& FOutBunch::operator<<(UObject*& Obj) { return *(FArchive*)this; }
IMPL_MATCH("Engine.dll", 0x1047f9c0)
FArchive& FOutBunch::operator<<(FName& N) { return *(FArchive*)this; }

// --- Moved from EngineStubs.cpp ---
UClass** UChannel::ChannelClasses = NULL;
