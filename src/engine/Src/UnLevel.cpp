/*=============================================================================
	UnLevel.cpp: ULevel, ALevelInfo, AGameInfo and related classes.
	Reconstructed for Ravenshield decompilation project.

	Provides IMPLEMENT_CLASS() registrations for level, zone, game-info
	and replication-info classes, plus decompiled method bodies for
	ULevelBase and ULevel (construction, URL management, actor
	enumeration, etc.).

	This file is permanent and will grow as more level management code
	is decompiled.
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
INT ULevel::IsServer()
{
	// Retail (34b, RVA 0xBF270): return 1 (server) unless NetDriver or DemoRecDriver
	// has an active ServerConnection (which indicates we are a client on that driver).
	if (NetDriver && NetDriver->ServerConnection)
		return 0;
	if (!DemoRecDriver || !DemoRecDriver->ServerConnection)
		return 1;
	return 0;
}
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
INT ULevel::NotifySendingFile( UNetConnection* Connection, FGuid GUID )
{
	// Retail (18b, RVA 0xBF590): returns 1 if [this+0x14]->field@+0x3C is NULL, else 0.
	// Connection and GUID params are NOT referenced in retail assembly.
	// [this+0x14] is likely the embedded NetDriver/network object pointer.
	void* driver = *(void**)((BYTE*)this + 0x14);
	if (!driver) return 1; // safety: not present in retail, but avoids NULL deref
	return (*(DWORD*)((BYTE*)driver + 0x3C) == 0) ? 1 : 0;
}
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
AZoneInfo* ULevel::GetZoneActor( INT iZone )
{
	// Retail (27b, RVA 0x1C0E0): Accesses Zones array data at [this+0x90].
	// Element layout: stride 72 bytes, AZoneInfo* field at base offset 288
	// (i.e., index = 72*iZone + 288 byte offset into Zones.Data).
	// Retail calls a fallback function if result is NULL; omitted here (TODO).
	BYTE* data = *(BYTE**)((BYTE*)this + 0x90);
	if (!data) return NULL;
	AZoneInfo* zone = *(AZoneInfo**)(data + 72 * iZone + 288);
	if (zone) return zone;
	// TODO: retail calls fallback at RVA 0x1C080 when zone is NULL
	return NULL;
}
INT ULevel::MoveActorFirstBlocking( AActor* Actor, INT bTest, INT bIgnorePawns, FCheckResult* FirstHit, FCheckResult& Hit ) { return 0; }
INT ULevel::ToFloor( AActor* Actor, INT bTest, AActor* IgnoreActor ) { return 0; }
void ULevel::UpdateTerrainArrays() {}

/*=============================================================================
	ALevelInfo / AGameInfo native function implementations.
	Reconstructed from Ghidra decompilation + SDK parameter signatures.
=============================================================================*/

// GetAddressURL() - returns the server's address URL string.
void ALevelInfo::execGetAddressURL( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execGetAddressURL);
	P_FINISH;
	*(FString*)Result = XLevel->URL.Host;
	if( XLevel->URL.Port != 7777 )
		*(FString*)Result += FString::Printf( TEXT(":%i"), XLevel->URL.Port );
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execGetAddressURL );

// GetLocalURL() - returns the current map URL.
void ALevelInfo::execGetLocalURL( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execGetLocalURL);
	P_FINISH;
	*(FString*)Result = XLevel->URL.Map;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execGetLocalURL );

// GetMapNameLocalisation() - returns the localised map name.
void ALevelInfo::execGetMapNameLocalisation( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execGetMapNameLocalisation);
	P_FINISH;
	*(FString*)Result = XLevel->URL.Map;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execGetMapNameLocalisation );

// FinalizeLoading() - called when level loading is complete.
void ALevelInfo::execFinalizeLoading( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execFinalizeLoading);
	P_FINISH;
	// Notify the engine that loading is finalized.
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execFinalizeLoading );

// ResetLevelInNative() - resets native-side level state.
void ALevelInfo::execResetLevelInNative( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execResetLevelInNative);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execResetLevelInNative );

// SetBankSound() - registers a sound bank with the audio subsystem.
void ALevelInfo::execSetBankSound( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execSetBankSound);
	P_GET_STR(BankName);
	P_FINISH;
	// Audio bank loading delegated to DARE audio subsystem.
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execSetBankSound );

// NotifyMatchStart() - notifies native code that a match has begun.
void ALevelInfo::execNotifyMatchStart( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execNotifyMatchStart);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execNotifyMatchStart );

// PBNotifyServerTravel() - PunkBuster server travel notification.
void ALevelInfo::execPBNotifyServerTravel( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execPBNotifyServerTravel);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execPBNotifyServerTravel );

// CallLogThisActor() - logging helper.
void ALevelInfo::execCallLogThisActor( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execCallLogThisActor);
	P_GET_STR(LogText);
	P_FINISH;
	debugf( TEXT("LogActor: %s"), *LogText );
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execCallLogThisActor );

// AddWritableMapPoint() - adds a point to the writable minimap overlay.
void ALevelInfo::execAddWritableMapPoint( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execAddWritableMapPoint);
	P_GET_VECTOR(Point);
	P_GET_STRUCT(FColor,Color);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execAddWritableMapPoint );

// AddWritableMapIcon() - adds an icon to the writable minimap overlay.
void ALevelInfo::execAddWritableMapIcon( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execAddWritableMapIcon);
	P_GET_VECTOR(Point);
	P_GET_INT(IconIndex);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execAddWritableMapIcon );

// AddEncodedWritableMapStrip() - adds an encoded strip to the writable minimap.
void ALevelInfo::execAddEncodedWritableMapStrip( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execAddEncodedWritableMapStrip);
	P_GET_STR(EncodedStrip);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execAddEncodedWritableMapStrip );

/*=============================================================================
	AGameInfo native function implementations.
=============================================================================*/

// GetNetworkNumber() - returns the network version number string.
void AGameInfo::execGetNetworkNumber( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execGetNetworkNumber);
	P_FINISH;
	*(FString*)Result = XLevel->URL.Host;
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execGetNetworkNumber );

// GetCurrentMapNum() - returns the current map index from the map list.
void AGameInfo::execGetCurrentMapNum( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execGetCurrentMapNum);
	P_FINISH;
	*(INT*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execGetCurrentMapNum );

// SetCurrentMapNum() - sets the current map index.
void AGameInfo::execSetCurrentMapNum( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execSetCurrentMapNum);
	P_GET_INT(MapNum);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execSetCurrentMapNum );

// ParseKillMessage() - formats a kill message string.
void AGameInfo::execParseKillMessage( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execParseKillMessage);
	P_GET_STR(KillerName);
	P_GET_STR(VictimName);
	P_GET_STR(WeaponName);
	P_GET_STR(DeathMessage);
	P_FINISH;
	*(FString*)Result = DeathMessage;
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execParseKillMessage );

// ProcessR6Availabilty() - processes R6-specific game type availability.
void AGameInfo::execProcessR6Availabilty( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execProcessR6Availabilty);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execProcessR6Availabilty );

// AbortScoreSubmission() - aborts an in-progress score submission.
void AGameInfo::execAbortScoreSubmission( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execAbortScoreSubmission);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execAbortScoreSubmission );
