// EngineVirtuals.cpp - Implementations for virtual methods declared in EngineClasses.h
// These are needed because the vtable is instantiated in our DLL.
#include "Engine.h"

// ---------------------------------------------------------------------------
// UCanvas
// ---------------------------------------------------------------------------
void UCanvas::Destroy()
{
	Super::Destroy();
}

void UCanvas::Serialize(FArchive& Ar)
{
	Super::Serialize(Ar);
}

UBOOL UCanvas::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
	return 0;
}

// ---------------------------------------------------------------------------
// UNetDriver
// ---------------------------------------------------------------------------
UBOOL UNetDriver::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
	return 0;
}

void UNetDriver::LowLevelDestroy()
{
}

FString UNetDriver::LowLevelGetNetworkNumber()
{
	return FString();
}

// ---------------------------------------------------------------------------
// UChannel
// ---------------------------------------------------------------------------
void UChannel::StaticConstructor()
{
}

void UChannel::ReceivedBunch(FInBunch& Bunch)
{
}

void UChannel::Serialize(const TCHAR* Name, EName Type)
{
}

// ---------------------------------------------------------------------------
// UMaterial
// ---------------------------------------------------------------------------
void UMaterial::PostEditChange()
{
	Super::PostEditChange();
}

// ---------------------------------------------------------------------------
// AReplicationInfo
// ---------------------------------------------------------------------------
void AReplicationInfo::StaticConstructor()
{
}

void AReplicationInfo::StartVideo(UCanvas* Canvas, INT X, INT Y, INT Z)
{
}

void AReplicationInfo::StopVideo(UCanvas* Canvas)
{
}

INT AReplicationInfo::OpenVideo(UCanvas* Canvas, char* A, char* B, INT C)
{
	return 0;
}

void AReplicationInfo::ChangeDrawingSurface(ER6SwitchSurface Surface, INT Param)
{
}

void AReplicationInfo::CloseVideo(UCanvas* Canvas)
{
}

void AReplicationInfo::DisplayVideo(UCanvas* Canvas, void* Data, INT Size)
{
}

void AReplicationInfo::Draw3DLine(FVector Start, FVector End, FColor Color, UTexture* Tex, FLOAT A, FLOAT B, FLOAT C, FLOAT D)
{
}

void AReplicationInfo::GetAvailableResolutions(TArray<FResolutionInfo>& Resolutions)
{
}

DWORD AReplicationInfo::GetAvailableVideoMemory()
{
	return 0;
}

void AReplicationInfo::HandleFullScreenEffects(INT A, INT B)
{
}
