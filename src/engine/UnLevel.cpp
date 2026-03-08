/*=============================================================================
	UnLevel.cpp: ULevel, ALevelInfo, AGameInfo and related class stubs.
=============================================================================*/
#include "EnginePrivate.h"

IMPLEMENT_CLASS(ULevelBase);
IMPLEMENT_CLASS(ULevel);
IMPLEMENT_CLASS(ALevelInfo);
IMPLEMENT_CLASS(AZoneInfo);
IMPLEMENT_CLASS(AGameInfo);
IMPLEMENT_CLASS(AReplicationInfo);
IMPLEMENT_CLASS(APlayerReplicationInfo);
IMPLEMENT_CLASS(AGameReplicationInfo);
IMPLEMENT_CLASS(AR6PawnReplicationInfo);

/*=============================================================================
	ULevelBase implementation.
=============================================================================*/

ULevelBase::ULevelBase( UEngine* InOwner, const FURL& InURL )
:	Actors( this )
,	URL( InURL )
{
	Engine = InOwner;
	NetDriver = NULL;
	DemoRecDriver = NULL;
}

void ULevelBase::Destroy()
{
	UObject::Destroy();
}

void ULevelBase::Serialize( FArchive& Ar )
{
	UObject::Serialize( Ar );
	Ar << Actors;
}

void ULevelBase::NotifyProgress( const TCHAR* Str1, const TCHAR* Str2, FLOAT Seconds )
{
}

/*=============================================================================
	ULevel implementation.
=============================================================================*/

ULevel::ULevel( UEngine* InEngine, INT InRootOutside )
:	ULevelBase( InEngine )
{
}

void ULevel::Serialize( FArchive& Ar )
{
	ULevelBase::Serialize( Ar );
}

void ULevel::PostLoad()
{
	UObject::PostLoad();
}

void ULevel::Destroy()
{
	ULevelBase::Destroy();
}

void ULevel::Modify( INT DoTransArrays ) {}
void ULevel::SetActorCollision( INT bCollision, INT bUnused ) {}
void ULevel::Tick( ELevelTick TickType, FLOAT DeltaSeconds ) {}
void ULevel::TickNetClient( FLOAT DeltaSeconds ) {}
void ULevel::TickNetServer( FLOAT DeltaSeconds ) {}
INT ULevel::ServerTickClient( UNetConnection* Conn, FLOAT DeltaSeconds ) { return 0; }
void ULevel::ReconcileActors() {}
void ULevel::RememberActors() {}
INT ULevel::Exec( const TCHAR* Cmd, FOutputDevice& Ar ) { return 0; }
void ULevel::ShrinkLevel() {}
void ULevel::CompactActors() {}
INT ULevel::Listen( FString& Error ) { return 0; }
INT ULevel::IsServer() { return 0; }
INT ULevel::MoveActor( AActor* Actor, FVector Delta, FRotator NewRotation, FCheckResult& Hit, INT bTest, INT bIgnorePawns, INT bIgnoreBases, INT bNoFail, INT bExtra ) { return 1; }
INT ULevel::FarMoveActor( AActor* Actor, FVector DestLocation, INT bTest, INT bNoCheck, INT bAttachedMove, INT bExtra ) { return 1; }
INT ULevel::DestroyActor( AActor* Actor, INT bNetForce ) { return 0; }
void ULevel::CleanupDestroyed( INT bForce ) {}
AActor* ULevel::SpawnActor( UClass* Class, FName InName, FVector Location, FRotator Rotation, AActor* Template, INT bNoCollisionFail, INT bRemoteOwned, AActor* SpawnTag, APawn* Instigator ) { return NULL; }
ABrush* ULevel::SpawnBrush() { return NULL; }
void ULevel::SpawnViewActor( UViewport* Viewport ) {}
APlayerController* ULevel::SpawnPlayActor( UPlayer* Player, ENetRole RemoteRole, const FURL& URL, FString& Error ) { return NULL; }
INT ULevel::FindSpot( FVector Extent, FVector& Location, INT bCheckActors, AActor* Requester ) { return 1; }
INT ULevel::CheckSlice( FVector& Adjusted, FVector TraceDest, INT& TraceLen, AActor* Actor ) { return 0; }
INT ULevel::CheckEncroachment( AActor* Actor, FVector TestLocation, FRotator TestRotation, INT bTouchNotify ) { return 0; }
INT ULevel::SinglePointCheck( FCheckResult& Hit, AActor* SourceActor, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, INT bActors ) { return 0; }
INT ULevel::SinglePointCheck( FCheckResult& Hit, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, INT bActors ) { return 0; }
INT ULevel::SingleLineCheck( FCheckResult& Hit, AActor* SourceActor, const FVector& End, const FVector& Start, DWORD TraceFlags, FVector Extent ) { return 0; }
INT ULevel::EncroachingWorldGeometry( FCheckResult& Hit, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, AActor* Actor ) { return 0; }
FCheckResult* ULevel::MultiPointCheck( FMemStack& Mem, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, INT bActors, INT bOnlyWorldGeometry, INT bSingleResult, AActor* Requester ) { return NULL; }
FCheckResult* ULevel::MultiLineCheck( FMemStack& Mem, FVector End, FVector Start, FVector Extent, ALevelInfo* Level, DWORD TraceFlags, AActor* SourceActor ) { return NULL; }
void ULevel::DetailChange( INT NewDetail ) {}
INT ULevel::TickDemoRecord( FLOAT DeltaSeconds ) { return 0; }
INT ULevel::TickDemoPlayback( FLOAT DeltaSeconds ) { return 0; }
void ULevel::UpdateTime( ALevelInfo* Info ) {}
INT ULevel::IsPaused() { return 0; }
void ULevel::WelcomePlayer( UNetConnection* Connection, TCHAR* Optional ) {}
INT ULevel::IsAudibleAt( FVector Location, FVector ListenerLocation, AActor* SourceActor, ESoundOcclusion Occlusion ) { return 1; }
FLOAT ULevel::CalculateRadiusMultiplier( INT SoundRadius, INT SoundRadiusInner ) { return 25.f * ((INT)SoundRadius + 1); }

// FNetworkNotify interface.
EAcceptConnection ULevel::NotifyAcceptingConnection() { return ACCEPTC_Reject; }
void ULevel::NotifyAcceptedConnection( UNetConnection* Connection ) {}
INT ULevel::NotifyAcceptingChannel( UChannel* Channel ) { return 1; }
ULevel* ULevel::NotifyGetLevel() { return this; }
void ULevel::NotifyReceivedText( UNetConnection* Connection, const TCHAR* Text ) {}
INT ULevel::NotifySendingFile( UNetConnection* Connection, FGuid GUID ) { return 1; }
void ULevel::NotifyReceivedFile( UNetConnection* Connection, INT PackageIndex, const TCHAR* Error, INT Forced ) {}

// Non-virtual methods.
ABrush* ULevel::Brush() { return (Actors.Num()>=2 && Actors(1)) ? (ABrush*)Actors(1) : NULL; }
INT ULevel::EditorDestroyActor( AActor* Actor ) { return DestroyActor( Actor ); }
INT ULevel::GetActorIndex( AActor* Actor )
{
	for( INT i=0; i<Actors.Num(); i++ )
		if( Actors(i) == Actor )
			return i;
	return INDEX_NONE;
}
ALevelInfo* ULevel::GetLevelInfo() { return (Actors.Num()>0 && Actors(0)) ? (ALevelInfo*)Actors(0) : NULL; }
AZoneInfo* ULevel::GetZoneActor( INT iZone ) { return NULL; }
INT ULevel::MoveActorFirstBlocking( AActor* Actor, INT bTest, INT bIgnorePawns, FCheckResult* FirstHit, FCheckResult& Hit ) { return 0; }
INT ULevel::ToFloor( AActor* Actor, INT bTest, AActor* IgnoreActor ) { return 0; }
void ULevel::UpdateTerrainArrays() {}

/*=============================================================================
	ALevelInfo / AGameInfo exec stubs.
=============================================================================*/

#define EXEC_STUB(cls,func) void cls::func( FFrame& Stack, RESULT_DECL ) { P_FINISH; }

EXEC_STUB(ALevelInfo,execGetAddressURL)        IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execGetAddressURL );
EXEC_STUB(ALevelInfo,execGetLocalURL)          IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execGetLocalURL );
EXEC_STUB(ALevelInfo,execGetMapNameLocalisation) IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execGetMapNameLocalisation );
EXEC_STUB(ALevelInfo,execFinalizeLoading)      IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execFinalizeLoading );
EXEC_STUB(ALevelInfo,execResetLevelInNative)   IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execResetLevelInNative );
EXEC_STUB(ALevelInfo,execSetBankSound)         IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execSetBankSound );
EXEC_STUB(ALevelInfo,execNotifyMatchStart)     IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execNotifyMatchStart );
EXEC_STUB(ALevelInfo,execPBNotifyServerTravel) IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execPBNotifyServerTravel );
EXEC_STUB(ALevelInfo,execCallLogThisActor)     IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execCallLogThisActor );
EXEC_STUB(ALevelInfo,execAddWritableMapPoint)  IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execAddWritableMapPoint );
EXEC_STUB(ALevelInfo,execAddWritableMapIcon)   IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execAddWritableMapIcon );
EXEC_STUB(ALevelInfo,execAddEncodedWritableMapStrip) IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execAddEncodedWritableMapStrip );
EXEC_STUB(AGameInfo,execGetNetworkNumber)      IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execGetNetworkNumber );
EXEC_STUB(AGameInfo,execGetCurrentMapNum)      IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execGetCurrentMapNum );
EXEC_STUB(AGameInfo,execSetCurrentMapNum)      IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execSetCurrentMapNum );
EXEC_STUB(AGameInfo,execParseKillMessage)      IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execParseKillMessage );
EXEC_STUB(AGameInfo,execProcessR6Availabilty)  IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execProcessR6Availabilty );
EXEC_STUB(AGameInfo,execAbortScoreSubmission)  IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execAbortScoreSubmission );

#undef EXEC_STUB
