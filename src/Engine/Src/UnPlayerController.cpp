#pragma optimize("", off)
#include "EnginePrivate.h"
struct FPropertyRetirement;

static INT  s_prevViewTarget = 0;
static BYTE s_prevViewState  = 0;

// --- APlayerController ---
IMPL_MATCH("Engine.dll", 0x104201f0)
void APlayerController::SpecialDestroy()
{
	UObject* Player = *(UObject**)((BYTE*)this + 0x5b4);
	if (Player && Player->IsA(UNetConnection::StaticClass()))
	{
		INT driver = *(INT*)((BYTE*)Player + 0x7c);
		if (driver != 0)
			*(INT*)((BYTE*)Player + 0x80) = 1;
	}
}

IMPL_MATCH("Engine.dll", 0x103c3c80)
int APlayerController::Tick(float DeltaSeconds, ELevelTick TickType)
{
	guard(APlayerController::Tick);
	// Ghidra 0xc3c80 (~350 bytes): main controller tick — returns 1 on all paths.
	typedef void (__thiscall* VoidFn0)(APlayerController*);
	typedef void (__thiscall* VoidFnF)(APlayerController*, FLOAT);
	typedef void (__thiscall* VoidFnFT)(APlayerController*, FLOAT, ELevelTick);
	typedef int  (__thiscall* IntFn0)(APlayerController*);
	typedef int  (__thiscall* IntVFn)(void*);

	// Toggle bDeleteMe bit based on level pending-delete flag at level+0x100
	*(DWORD*)((BYTE*)this + 0x320) ^=
		(*(DWORD*)(*(INT*)((BYTE*)this + 0x328) + 0x100) ^ *(DWORD*)((BYTE*)this + 0x320)) & 1;

	// vtable[99] = per-tick reset (e.g. ClearButtons)
	(*(VoidFn0*)(*(INT*)this + 0x18c))(this);

	// Initialise movement cache on first tick
	if (!(*(DWORD*)((BYTE*)this + 0x524) & 0x400000))
	{
		*(INT*)((BYTE*)this + 0x53c) = 0;
		*(INT*)((BYTE*)this + 0x540) = 0;
		*(DWORD*)((BYTE*)this + 0x524) |= 0x400000;
	}

	// Fire script Tick event
	eventTick(DeltaSeconds);

	// Spectator mode (state byte at +0x2e == 3): copy camera if needed, then base tick
	if (((BYTE*)this)[0x2e] == 3)
	{
		// vtable[103] = IsLocalPlayerController
		if (!(*(IntFn0*)(*(INT*)this + 0x19c))(this))
		{
			INT* camPtr = *(INT**)((BYTE*)this + 0x5b8);
			INT* pawnPtr = *(INT**)((BYTE*)this + 0x3d8);
			if (camPtr != pawnPtr && camPtr != NULL)
			{
				// vtable[26] on camPtr — check if camera is moving/valid
				if (((IntVFn)(*(INT*)(*(INT*)camPtr + 0x68)))((void*)camPtr))
				{
					*(FLOAT*)((BYTE*)this + 0x628) = *(FLOAT*)((BYTE*)this + 0x240);
					*(FLOAT*)((BYTE*)this + 0x62c) = *(FLOAT*)((BYTE*)this + 0x244);
					*(FLOAT*)((BYTE*)this + 0x630) = *(FLOAT*)((BYTE*)this + 0x248);
				}
			}
		}
		// vtable[6] = AActor::Tick base
		(*(VoidFnFT*)(*(INT*)this + 0x18))(this, DeltaSeconds, TickType);
		// vtable[58] = TimerTick
		(*(VoidFnF*)(*(INT*)this + 0xe8))(this, DeltaSeconds);
		return 1;
	}

	if (((BYTE*)this)[0x2d] < 2)
	{
		(*(VoidFnFT*)(*(INT*)this + 0x18))(this, DeltaSeconds, TickType);
		(*(VoidFnF*)(*(INT*)this + 0xe8))(this, DeltaSeconds);
		return 1;
	}

	if (IsA(ACamera::StaticClass()))
	{
		if (!(*(DWORD*)((BYTE*)this + 0x4f8) & 0x800))
			return 1;
	}

	if (*(INT*)((BYTE*)this + 0x5b4)) // has viewport Player
	{
		if (!*(INT*)((BYTE*)this + 0x7d8)) // no input system yet
		{
			eventInitInputSystem();
			if (*(SBYTE*)(*(INT*)((BYTE*)this + 0x144) + 0x425))
				eventInitMultiPlayerOptions();
			if (!*(INT*)((BYTE*)this + 0x7d8))
				goto SKIP_INPUT;
		}
		// UPlayer::ProcessInput vtable[25]
		typedef void (__thiscall* ProcessInputFn)(void*, FLOAT);
		void* playerObj = *(void**)((BYTE*)this + 0x5b4);
		((ProcessInputFn)(*(INT*)(*(INT*)playerObj + 100)))(playerObj, DeltaSeconds);
		eventPlayerTick(DeltaSeconds);
		((ProcessInputFn)(*(INT*)(*(INT*)playerObj + 100)))(playerObj, -1.0f); // post-tick reset
	}
SKIP_INPUT:
	(*(VoidFnFT*)(*(INT*)this + 0x18))(this, DeltaSeconds, TickType);
	(*(VoidFnF*)(*(INT*)this + 0xe8))(this, DeltaSeconds);

	if (*(SBYTE*)((BYTE*)this + 0xa0) < 0)
		return 1;

	if (((BYTE*)this)[0x2c] != 0 && ((BYTE*)this)[0x2d] != 3)
		// vtable[72] = MoveSmooth
		(*(VoidFnF*)(*(INT*)this + 0x120))(this, DeltaSeconds);

	// NetDriver section
	INT level = *(INT*)((BYTE*)this + 0x328);
	INT netDriver = *(INT*)(level + 0x8c);
	if (netDriver && *(INT*)(netDriver + 0x3c))
	{
		if (((BYTE*)this)[0x2d] != 4)
			return 1;
		if (!(*(DWORD*)((BYTE*)this + 0x524) & 0x20))
		{
			INT* camPtr2 = *(INT**)((BYTE*)this + 0x5b8);
			if (camPtr2 != NULL)
			{
				if (((IntVFn)(*(INT*)(*(INT*)camPtr2 + 0x68)))((void*)camPtr2))
				{
					*(FLOAT*)((BYTE*)this + 0x628) = *(FLOAT*)((BYTE*)this + 0x240);
					*(FLOAT*)((BYTE*)this + 0x62c) = *(FLOAT*)((BYTE*)this + 0x244);
					*(FLOAT*)((BYTE*)this + 0x630) = *(FLOAT*)((BYTE*)this + 0x248);
				}
			}
		}
	}

	if (((BYTE*)this)[0x2d] == 4 && TickType == 2)
	{
		FLOAT& fadeTimer = *(FLOAT*)((BYTE*)this + 0x3ac);
		if (!(fadeTimer < 0.0f))
			fadeTimer += 0.2f;
		fadeTimer -= DeltaSeconds;
		INT pawn = *(INT*)((BYTE*)this + 0x3d8);
		if (pawn && !(*(BYTE*)(pawn + 0xa0) & 2))
			ShowSelf();
	}

	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10391550)
void APlayerController::R6PBKickPlayer(FString KickMsg)
{
	guard(APlayerController::R6PBKickPlayer);
	// Ghidra 0x91550: log the kicker's name, fire client event, then destroy
	GLog->Logf(TEXT("%s"), GetFullName());
	eventClientPBKickedOutMessage(KickMsg);
	SpecialDestroy();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1037a5c0)
void APlayerController::SetPlayer(UPlayer* InPlayer)
{
	// Ghidra 0x7a5c0: bi-directional controller<->player link, init input if viewport.
	if (!InPlayer)
		appFailAssert("InPlayer!=NULL", ".\\UnActor.cpp", 0x760);

	// Clear old player's back-pointer to this controller
	APlayerController* oldActor = *(APlayerController**)((BYTE*)InPlayer + 0x34);
	if (oldActor)
		*(UPlayer**)((BYTE*)oldActor + 0x5B4) = NULL;

	// Establish bidirectional link
	*(UPlayer**)((BYTE*)this + 0x5B4) = InPlayer;
	*(APlayerController**)((BYTE*)InPlayer + 0x34) = this;

	// If InPlayer is a viewport, initialise input system
	if (InPlayer->IsA(UViewport::StaticClass()))
		eventInitInputSystem();

	// Log
	debugf(TEXT("%s"), GetFullName());
}

IMPL_MATCH("Engine.dll", 0x1038d7d0)
int APlayerController::LocalPlayerController()
{
	UPlayer* Player = (UPlayer*)_NativeData[50]; // offset 0x5B4
	return Player && Player->IsA(UViewport::StaticClass());
}

IMPL_MATCH("Engine.dll", 0x1037de60)
void APlayerController::PostNetReceive()
{
	guard(APlayerController::PostNetReceive);
	// Ghidra 0x7de60: update client if view target changed since PreNetReceive
	AActor::PostNetReceive();
	if ((*(DWORD*)((BYTE*)this + 0x524) & 0x4000) &&
		(s_prevViewTarget != *(INT*)((BYTE*)this + 0x5b8) ||
		 s_prevViewState  != *(BYTE*)((BYTE*)this + 0x4f7)))
	{
		eventClientSetNewViewTarget();
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103785d0)
void APlayerController::PreNetReceive()
{
	guard(APlayerController::PreNetReceive);
	// Ghidra 0x785d0: save view target state before net updates
	AActor::PreNetReceive();
	s_prevViewState  = *(BYTE*)((BYTE*)this + 0x4f7);
	s_prevViewTarget = *(INT*)((BYTE*)this + 0x5b8);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10427760)
void APlayerController::CheckHearSound(AActor* SoundMaker, INT SoundId, USound* Sound, FVector SoundLoc, FLOAT Volume, INT Flags)
{
	guard(APlayerController::CheckHearSound);
	// Ghidra 0x127760: vtable[0x18c] pre-hook, then dispatch ClientHearSound event
	typedef void (__thiscall* tPreHook)(APlayerController*);
	((tPreHook*)((BYTE*)(*(void**)this) + 0x18c))[0](this);
	eventClientHearSound(SoundMaker, Sound, (BYTE)Volume);
	unguard;
}

IMPL_DIVERGE("Ghidra 0x10374b00: AController::GetOptimizedRepList base call + 6 replicated properties (m_bRadarActive, ViewTarget, GameReplicationInfo, bOnlySpectator, m_TeamSelection, m_eCameraMode) via DAT_ static caches; DAT_ addresses not yet resolved")
INT* APlayerController::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	// Ghidra 0x74b00 (1025b): calls AController::GetOptimizedRepList, then conditionally
	// adds replicated property indices for 6 R6-specific fields when bNetOwner && bNetDirty.
	// DIVERGENCE: uses static DAT_ caches for property FName indices; those DAT_ addresses
	// not yet resolved to named globals. Delegates to parent only.
	return AController::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}

IMPL_MATCH("Engine.dll", 0x10425a40)
FString APlayerController::GetPlayerNetworkAddress()
{
	// Ghidra shows vtable dispatch to LowLevelGetRemoteAddress on the Player connection.
	UNetConnection* Conn = Cast<UNetConnection>( *(UPlayer**)(&_NativeData[50]) ); // offset 0x5B4
	if( Conn )
		return Conn->LowLevelGetRemoteAddress();
	return FString(TEXT(""));
}

IMPL_MATCH("Engine.dll", 0x1038d420)
AActor * APlayerController::GetViewTarget()
{
	AActor*& ViewTarget = *(AActor**)(&_NativeData[51]); // offset 0x5B8
	if( !ViewTarget )
	{
		if( Pawn && !Pawn->bDeleteMe && !Pawn->bPendingDelete )
		{
			ViewTarget = Pawn;
			return Pawn;
		}
		ViewTarget = this;
	}
	return ViewTarget;
}

IMPL_MATCH("Engine.dll", 0x103c4280)
int APlayerController::IsNetRelevantFor(APlayerController* RealViewer,AActor* Viewer,FVector SrcLocation)
{
	if( this == RealViewer )
		return 1;
	return AActor::IsNetRelevantFor( RealViewer, Viewer, SrcLocation );
}


