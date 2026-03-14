/*=============================================================================
	UnConn.cpp: Net connection and player/client stubs (UNetConnection)
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

// --- UNetConnection ---

// --- UClient ---
IMPL_TODO("Needs Ghidra analysis")
void UClient::StaticConstructor()
{
	guard(UClient::StaticConstructor);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UClient::UpdateGamma()
{
	guard(UClient::UpdateGamma);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UClient::UpdateGraphicOptions()
{
	guard(UClient::UpdateGraphicOptions);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UClient::RestoreGamma()
{
	guard(UClient::RestoreGamma);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UClient::Serialize(FArchive &)
{
	guard(UClient::Serialize);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UClient::PostEditChange()
{
	guard(UClient::PostEditChange);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UClient::Destroy()
{
	guard(UClient::Destroy);
	unguard;
}

IMPL_APPROX("Reconstructed from context")
int UClient::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
	guard(UClient::Exec);
	// Ghidra 0x879f0 (533 bytes): handle BRIGHTNESS, CONTRAST, GAMMA console commands.
	// Fields: +0x58=Brightness, +0x5c=Contrast, +0x60=Gamma, +0x2c=render device, +0x30=viewports
	FString OutStr;
	// Helper: call vtable[31] on the render device (UpdateGamma/Flush)
#define CALL_UPDATE_GAMMA() \
	{ \
		void* rdPtr = *(void**)((BYTE*)this + 0x2c); \
		typedef void (__thiscall* UpdateFn)(void*); \
		((UpdateFn)(*(INT*)(*(INT*)rdPtr + 0x7c)))(rdPtr); \
	}
	if (ParseCommand(&Cmd, TEXT("BRIGHTNESS")))
	{
		if (*Cmd == '+')
		{
			if (*(FLOAT*)((BYTE*)this + 0x58) < 0.9f)
				*(FLOAT*)((BYTE*)this + 0x58) += 0.1f;
			else
				*(DWORD*)((BYTE*)this + 0x58) = 0x3f000000; // 1.0f
		}
		else if (*Cmd == 0)
		{
			*(DWORD*)((BYTE*)this + 0x58) = 0x3f000000; // reset to 1.0f
		}
		else
		{
			FLOAT val = appAtof(Cmd);
			if (val < 0.0f || val != val) val = 0.0f;
			else if (val > 1.0f) val = 1.0f;
			*(FLOAT*)((BYTE*)this + 0x58) = val;
		}
		CALL_UPDATE_GAMMA();
		SaveConfig(0x4000, NULL);
		if (((FArray*)((BYTE*)this + 0x30))->Num() == 0) return 1;
		if (*(INT*)(**(INT**)((BYTE*)this + 0x30) + 0x34) == 0) return 1;
		OutStr = FString::Printf(TEXT("Brightness %i"));
	}
	else if (ParseCommand(&Cmd, TEXT("CONTRAST")))
	{
		if (*Cmd == '+')
		{
			if (*(FLOAT*)((BYTE*)this + 0x5c) < 0.9f)
				*(FLOAT*)((BYTE*)this + 0x5c) += 0.1f;
			else
				*(DWORD*)((BYTE*)this + 0x5c) = 0;
		}
		else if (*Cmd == 0)
		{
			*(DWORD*)((BYTE*)this + 0x5c) = 0x3f000000; // 1.0f
		}
		else
		{
			FLOAT val = appAtof(Cmd);
			if (val < 0.0f || val != val) val = 0.0f;
			else if (val > 1.0f) val = 1.0f;
			*(FLOAT*)((BYTE*)this + 0x5c) = val;
		}
		CALL_UPDATE_GAMMA();
		SaveConfig(0x4000, NULL);
		if (((FArray*)((BYTE*)this + 0x30))->Num() == 0) return 1;
		if (*(INT*)(**(INT**)((BYTE*)this + 0x30) + 0x34) == 0) return 1;
		OutStr = FString::Printf(TEXT("Contrast %i"));
	}
	else if (ParseCommand(&Cmd, TEXT("GAMMA")))
	{
		if (*Cmd == '+')
		{
			if (*(FLOAT*)((BYTE*)this + 0x60) < 2.4f)
				*(FLOAT*)((BYTE*)this + 0x60) += 0.1f;
			else
				*(DWORD*)((BYTE*)this + 0x60) = 0x3f000000; // wrap back to 1.0f
		}
		else if (*Cmd == 0)
		{
			*(DWORD*)((BYTE*)this + 0x60) = 0x3fd9999a; // ~1.7f default
		}
		else
		{
			*(FLOAT*)((BYTE*)this + 0x60) = Clamp(appAtof(Cmd), 0.5f, 2.5f);
		}
		CALL_UPDATE_GAMMA();
		SaveConfig(0x4000, NULL);
		if (((FArray*)((BYTE*)this + 0x30))->Num() == 0) return 1;
		if (*(INT*)(**(INT**)((BYTE*)this + 0x30) + 0x34) == 0) return 1;
		OutStr = FString::Printf(TEXT("Gamma %1.1f"), (DOUBLE)*(FLOAT*)((BYTE*)this + 0x60));
	}
	else
	{
		return 0;
	}
#undef CALL_UPDATE_GAMMA
	// Send message to the PlayerController at first viewport+0x34
	INT firstViewportPtr = **(INT**)((BYTE*)this + 0x30);
	APlayerController* ctrl = *(APlayerController**)(firstViewportPtr + 0x34);
	ctrl->eventClientMessage(OutStr, NAME_None);
	return 1;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UClient::Flush(int)
{
	guard(UClient::Flush);
	unguard;
}

IMPL_APPROX("Reconstructed from context")
void UClient::Init(UEngine* Engine)
{
	guard(UClient::Init);
	// Ghidra 0x86f20: store engine reference and call StaticConstructor
	*(UEngine**)((BYTE*)this + 0x2c) = Engine;
	StaticConstructor();
	unguard;
}


// --- UPlayer ---
IMPL_APPROX("Reconstructed from context")
void UPlayer::Serialize(FArchive &Ar)
{
	guard(UPlayer::Serialize);
	// Ghidra 0x103F7120 (41 bytes): only calls UObject::Serialize then returns.
	UObject::Serialize(Ar);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UPlayer::Destroy()
{
	guard(UPlayer::Destroy);
	unguard;
}

IMPL_APPROX("Reconstructed from context")
int UPlayer::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
	guard(UPlayer::Exec);
	// Ghidra 0xf71a0 (316 bytes): dispatch exec command through PlayerController chain.
	INT pc = *(INT*)((BYTE*)this + 4); // PlayerController at this+4
	if (!pc) return 0;
	// Try vtable[33] on object at PC+0x328 (PlayerInput vtable, or direct FP at +0x84)
	INT inp = *(INT*)(pc + 0x328);
	typedef int (__thiscall* ExecFn)(void*, const TCHAR*, FOutputDevice&);
	typedef int (__thiscall* ExecFn3)(void*, const TCHAR*, FOutputDevice&, INT);
	int r = ((ExecFn)(*(INT*)(*(INT*)inp + 0x84)))((void*)inp, Cmd, Ar);
	if (!r)
	{
		// CheatManager at PC+0x144, sub-object at +0x4cc
		INT cheatMgr = *(INT*)(*(INT*)(pc + 0x144) + 0x4cc);
		if (cheatMgr)
		{
			r = ((ExecFn3)(*(INT*)(*(INT*)cheatMgr + 0x4c)))((void*)cheatMgr, Cmd, Ar, *(INT*)(pc + 0x3d8));
			if (r) return 1;
		}
		// Interaction at PC+0x5bc
		INT inter1 = *(INT*)(pc + 0x5bc);
		if (inter1)
		{
			r = ((ExecFn3)(*(INT*)(*(INT*)inter1 + 0x4c)))((void*)inter1, Cmd, Ar, *(INT*)(pc + 0x3d8));
			if (r) return 1;
		}
		// Interaction at PC+0x5d4
		INT inter2 = *(INT*)(pc + 0x5d4);
		if (inter2)
		{
			r = ((ExecFn3)(*(INT*)(*(INT*)inter2 + 0x4c)))((void*)inter2, Cmd, Ar, *(INT*)(pc + 0x3d8));
			if (r) return 1;
		}
		// vtable[0x13] on PC itself with 3 args
		r = ((ExecFn3)(*(INT*)(*(INT*)pc + 0x4c)))((void*)pc, Cmd, Ar, (*(INT**)pc)[0xf6]);
		if (!r)
		{
			// Interaction at PC+0x7d8
			INT inter3 = *(INT*)(pc + 0x7d8);
			if (inter3)
			{
				r = ((ExecFn3)(*(INT*)(*(INT*)inter3 + 0x4c)))((void*)inter3, Cmd, Ar, *(INT*)(pc + 0x3d8));
				if (r) return 1;
			}
			// ViewTarget at PC+0x3d8
			INT vt = *(INT*)(pc + 0x3d8);
			if (vt)
			{
				r = ((ExecFn3)(*(INT*)(*(INT*)vt + 0x4c)))((void*)vt, Cmd, Ar, vt);
				if (r) return 1;
			}
			// Final: nested pointer chain through PC+0x328→+0x44→+0x2c
			INT nested = *(INT*)(*(INT*)(inp + 0x44) + 0x2c);
			typedef int (__thiscall* ExecFn2)(void*, const TCHAR*, FOutputDevice&);
			// DIVERGENCE: Ghidra shows **(code**) at this call site, suggesting one extra
			// vtable-style dereference. The current reconstruction dereferences once.
			// If Exec dispatch misbehaves, this may need: ((ExecFn2)**(INT**)nested)(...)
			r = ((ExecFn2)(*(INT*)nested))((void*)nested, Cmd, Ar);
			return r != 0;
		}
	}
	return 1;
	unguard;
}


// ============================================================================
// UPackageMapLevel constructor
// (moved from EngineStubs.cpp)
// ============================================================================

// ??0UPackageMapLevel@@QAE@PAVUNetConnection@@@Z
IMPL_APPROX("Reconstructed from context")
UPackageMapLevel::UPackageMapLevel(UNetConnection*) {}

// --- Moved from EngineStubs.cpp ---
IMPL_APPROX("Reconstructed from context")
UChannel* UNetConnection::CreateChannel(EChannelType ChType, INT bOpenedLocally, INT ChIndex)
{
	if (!UChannel::IsKnownChannelType((INT)ChType))
		appFailAssert("UChannel::IsKnownChannelType(ChType)", ".\\UnConn.cpp", 0x31E);

	AssertValid();

	INT iIdx = ChIndex;
	if (ChIndex >= 0x400)
	{
		if (ChIndex == (INT)0x7FFFFFFF)
		{
			for (iIdx = 0x400; iIdx < 0x410; iIdx++)
				if (*(UChannel**)((BYTE*)this + iIdx * 4 + 0xEB0) == NULL) break;
			if (iIdx == 0x410) return NULL;
		}
		else if (ChIndex == (INT)0x7FFFFFFE)
		{
			for (iIdx = 0x410; iIdx < 0x50F; iIdx++)
				if (*(UChannel**)((BYTE*)this + iIdx * 4 + 0xEB0) == NULL) break;
			if (iIdx == 0x50F) return NULL;
		}
		if (iIdx >= 0x50F)
			appFailAssert("ChIndex<MAX_CHANNELS+NUM_ARMPATCH_CHANNELS", ".\\UnConn.cpp", 0x36A);
	}

	if (iIdx == -1)
	{
		iIdx = (ChType == CHTYPE_Control) ? 0 : 1;
		while (iIdx < 0x3FF && *(UChannel**)((BYTE*)this + iIdx * 4 + 0xEB0) != NULL)
			iIdx++;
		if (iIdx == 0x3FF) return NULL;
	}

	if (ChIndex < 0x400)
	{
		if (iIdx >= 0x3FF)
			appFailAssert("ChIndex<MAX_CHANNELS", ".\\UnConn.cpp", 0x36E);
	}
	else
	{
		if (iIdx >= 0x50F)
			appFailAssert("ChIndex<MAX_CHANNELS+NUM_ARMPATCH_CHANNELS", ".\\UnConn.cpp", 0x36A);
	}

	if (*(UChannel**)((BYTE*)this + iIdx * 4 + 0xEB0) != NULL)
		appFailAssert("Channels[ChIndex]==NULL", ".\\UnConn.cpp", 0x373);

	// Construct the channel object for this channel type.
	UClass* Class = UChannel::ChannelClasses[ChType];
	check(Class->IsChildOf(UChannel::StaticClass()));
	UChannel* Ch = (UChannel*)UObject::StaticConstructObject(
		Class, UObject::GetTransientPackage(), NAME_None, 0, NULL, GError, NULL);
	Ch->Init(this, iIdx, bOpenedLocally);

	// Register in the fixed-size Channels array.
	*(UChannel**)((BYTE*)this + iIdx * 4 + 0xEB0) = Ch;

	// Append to OpenChannels dynamic list (TArray<UChannel*> at this+0x4B7C).
	INT arrIdx = ((FArray*)((BYTE*)this + 0x4B7C))->Add(1, sizeof(UChannel*));
	*(UChannel**)(*(BYTE**)((BYTE*)this + 0x4B7C) + arrIdx * sizeof(UChannel*)) = Ch;

	return Ch;
}
IMPL_APPROX("Reconstructed from context")
void UNetConnection::PostSend()
{
	// Out(FBitWriter) at offset 0x250, MaxPacket(INT) at offset 0xD0
	FBitWriter& Out = *(FBitWriter*)((BYTE*)this + 0x250);
	INT MaxPacket = *(INT*)((BYTE*)this + 0xD0);
	if (Out.GetNumBits() > MaxPacket * 8)
		appFailAssert("Out.GetNumBits()<=MaxPacket*8", ".\\UnConn.cpp", 0x2B6);
	if (Out.GetNumBits() == MaxPacket * 8)
		FlushNet();
}
IMPL_TODO("Needs Ghidra analysis")
UDemoRecConnection::UDemoRecConnection(UNetDriver* Driver, const FURL& URL)
{
	guard(UDemoRecConnection::UDemoRecConnection);
	unguard;
}
IMPL_APPROX("Reconstructed from context")
void UDemoRecConnection::StaticConstructor() {}
IMPL_APPROX("Reconstructed from context")
FString UDemoRecConnection::LowLevelDescribe() { return FString(TEXT("Demo recording driver connection")); }
IMPL_APPROX("Reconstructed from context")
FString UDemoRecConnection::LowLevelGetRemoteAddress() { return FString(TEXT("")); }
IMPL_APPROX("Reconstructed from context")
void UDemoRecConnection::LowLevelSend(void* Data, INT Count) {
	// Ghidra at 0x187b80. Writes demo packet: FrameNum, DemoFrameTime, Count, Data.
	if (Driver->ServerConnection == NULL) {
		FArchive* FileAr = *(FArchive**)((BYTE*)Driver + 0xB4);
		FileAr->ByteOrderSerialize((BYTE*)Driver + 0xCC, 4);    // FrameNum (INT)
		FileAr->ByteOrderSerialize((BYTE*)Driver + 0x48, 8);    // DemoFrameTime (DOUBLE)
		FileAr->ByteOrderSerialize(&Count, 4);                  // packet size
		FileAr->Serialize(Data, Count);                          // packet data
	}
}

// Retail: 16b. Flushes only when playing back a demo (client, ServerConnection != NULL).
// JNZ path: if ServerConnection != NULL, cross-function-jump to UNetConnection::FlushNet.
IMPL_APPROX("Reconstructed from context")
void UDemoRecConnection::FlushNet() {
	if (Driver->ServerConnection != NULL)
		UNetConnection::FlushNet();
}
IMPL_APPROX("Reconstructed from context")
INT UDemoRecConnection::IsNetReady(INT) { return 1; }
IMPL_APPROX("Reconstructed from context")
void UDemoRecConnection::HandleClientPlayer(APlayerController*) {}
IMPL_APPROX("Reconstructed from context")
UDemoRecDriver* UDemoRecConnection::GetDriver() { return (UDemoRecDriver*)Driver; }
IMPL_APPROX("Reconstructed from context")
INT UPackageMapLevel::SerializeObject(FArchive&, UClass*, UObject*&) { return 1; } // Ghidra 0x18bd30: returns 1 on all paths; full net-object lookup TODO
// Ghidra at 0x48BCD0: default return is 1 (can serialize), returns 0 only for specific Actor flag checks.
IMPL_APPROX("Reconstructed from context")
INT UPackageMapLevel::CanSerializeObject(UObject*) { return 1; }
