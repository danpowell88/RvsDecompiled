#pragma optimize("", off)
#include "EnginePrivate.h"
struct FPropertyRetirement;

static INT  s_prevViewTarget = 0;
static BYTE s_prevViewState  = 0;

// --- APlayerController ---
void APlayerController::SpecialDestroy()
{
	// Ghidra (49B): If Player (offset 0x5B4) is a UNetConnection with a Driver,
	// set bPendingDestroy on the Driver's connection info.
	UObject* Player = *(UObject**)((BYTE*)this + 0x5B4);
	if (Player && Player->IsA(UNetConnection::StaticClass()))
	{
		UNetConnection* Conn = (UNetConnection*)Player;
		// Driver at Conn+0x7C
		INT* DriverPtr = (INT*)((BYTE*)Conn + 0x7C);
		if (*DriverPtr != 0)
		{
			// bPendingDestroy at Conn+0x80
			*(INT*)((BYTE*)Conn + 0x80) = 1;
		}
	}
}

int APlayerController::Tick(float,ELevelTick)
{
	return 0;
}

void APlayerController::R6PBKickPlayer(FString KickMsg)
{
	guard(APlayerController::R6PBKickPlayer);
	// Ghidra 0x91550: log the kicker's name, fire client event, then destroy
	GLog->Logf(TEXT("%s"), GetFullName());
	eventClientPBKickedOutMessage(KickMsg);
	SpecialDestroy();
	unguard;
}

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

int APlayerController::LocalPlayerController()
{
	UPlayer* Player = (UPlayer*)_NativeData[50]; // offset 0x5B4
	return Player && Player->IsA(UViewport::StaticClass());
}

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

void APlayerController::PreNetReceive()
{
	guard(APlayerController::PreNetReceive);
	// Ghidra 0x785d0: save view target state before net updates
	AActor::PreNetReceive();
	s_prevViewState  = *(BYTE*)((BYTE*)this + 0x4f7);
	s_prevViewTarget = *(INT*)((BYTE*)this + 0x5b8);
	unguard;
}

void APlayerController::CheckHearSound(AActor* SoundMaker, INT SoundId, USound* Sound, FVector SoundLoc, FLOAT Volume, INT Flags)
{
	guard(APlayerController::CheckHearSound);
	// Ghidra 0x127760: vtable[0x18c] pre-hook, then dispatch ClientHearSound event
	typedef void (__thiscall* tPreHook)(APlayerController*);
	((tPreHook*)((BYTE*)(*(void**)this) + 0x18c))[0](this);
	eventClientHearSound(SoundMaker, Sound, (BYTE)Volume);
	unguard;
}

INT* APlayerController::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}

FString APlayerController::GetPlayerNetworkAddress()
{
	// Ghidra shows vtable dispatch to LowLevelGetRemoteAddress on the Player connection.
	UNetConnection* Conn = Cast<UNetConnection>( *(UPlayer**)(&_NativeData[50]) ); // offset 0x5B4
	if( Conn )
		return Conn->LowLevelGetRemoteAddress();
	return FString(TEXT(""));
}

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

int APlayerController::IsNetRelevantFor(APlayerController* RealViewer,AActor* Viewer,FVector SrcLocation)
{
	if( this == RealViewer )
		return 1;
	return AActor::IsNetRelevantFor( RealViewer, Viewer, SrcLocation );
}


