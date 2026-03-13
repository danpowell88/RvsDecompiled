#pragma optimize("", off)
#include "EnginePrivate.h"
struct FPropertyRetirement;

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

void APlayerController::R6PBKickPlayer(FString)
{
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
}

void APlayerController::PreNetReceive()
{
}

void APlayerController::CheckHearSound(AActor *,int,USound *,FVector,float,int)
{
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


