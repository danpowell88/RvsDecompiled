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
			// TODO: FUN_10317640 — clamp(val, 0.0f, 1.0f)
			FLOAT val = appAtof(Cmd);
			if (val < 0.0f || val != val) val = 0.0f;
			else if (val > 1.0f) val = 1.0f;
			*(FLOAT*)((BYTE*)this + 0x58) = val;
		}
		CALL_UPDATE_GAMMA();
		SaveConfig(0x4000, NULL);
		if (((FArray*)((BYTE*)this + 0x30))->Num() == 0) return 1;
		if (*(INT*)(**(INT**)((BYTE*)this + 0x30) + 0x34) == 0) return 1;
		// TODO: FUN_1050557c — build message string
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
			// TODO: FUN_10317640 — clamp(val, 0.0f, 1.0f)
			FLOAT val = appAtof(Cmd);
			if (val < 0.0f || val != val) val = 0.0f;
			else if (val > 1.0f) val = 1.0f;
			*(FLOAT*)((BYTE*)this + 0x5c) = val;
		}
		CALL_UPDATE_GAMMA();
		SaveConfig(0x4000, NULL);
		if (((FArray*)((BYTE*)this + 0x30))->Num() == 0) return 1;
		if (*(INT*)(**(INT**)((BYTE*)this + 0x30) + 0x34) == 0) return 1;
		// TODO: FUN_1050557c — build message string
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
			// TODO: FUN_10317640 — clamp(val, 0.5f, 2.5f)
			*(FLOAT*)((BYTE*)this + 0x60) = appAtof(Cmd);
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
			// TODO: Ghidra shows **(code**) — one extra dereference may be needed
			r = ((ExecFn2)(*(INT*)nested))((void*)nested, Cmd, Ar);
			return r != 0;
		}
	}
	return 1;
	unguard;
}

