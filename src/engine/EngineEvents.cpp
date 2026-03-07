/*=============================================================================
	EngineEvents.cpp: Event thunk implementations for all Engine classes.
	Each event thunk marshals parameters into a struct and calls
	ProcessEvent( FindFunctionChecked(ENGINE_<name>, 0), &Parms, NULL ).

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	AActor event thunks (52).
-----------------------------------------------------------------------------*/

void AActor::eventAnimEnd(INT Channel)
{
	struct { INT Channel; } Parms;
	Parms.Channel = Channel;
	ProcessEvent( FindFunctionChecked(ENGINE_AnimEnd, 0), &Parms, NULL );
}

void AActor::eventAttach(AActor* Other)
{
	struct { AActor* Other; } Parms;
	Parms.Other = Other;
	ProcessEvent( FindFunctionChecked(ENGINE_Attach, 0), &Parms, NULL );
}

void AActor::eventBaseChange()
{
	ProcessEvent( FindFunctionChecked(ENGINE_BaseChange, 0), NULL, NULL );
}

void AActor::eventBeginEvent()
{
	ProcessEvent( FindFunctionChecked(ENGINE_BeginEvent, 0), NULL, NULL );
}

void AActor::eventBeginPlay()
{
	ProcessEvent( FindFunctionChecked(ENGINE_BeginPlay, 0), NULL, NULL );
}

void AActor::eventBroadcastLocalizedMessage(UClass* MsgClass, INT Switch, APlayerReplicationInfo* RI1, APlayerReplicationInfo* RI2, UObject* OptObj)
{
	struct { UClass* MsgClass; INT Switch; APlayerReplicationInfo* RI1; APlayerReplicationInfo* RI2; UObject* OptObj; } Parms;
	Parms.MsgClass = MsgClass;
	Parms.Switch = Switch;
	Parms.RI1 = RI1;
	Parms.RI2 = RI2;
	Parms.OptObj = OptObj;
	ProcessEvent( FindFunctionChecked(ENGINE_BroadcastLocalizedMessage, 0), &Parms, NULL );
}

void AActor::eventBump(AActor* Other)
{
	struct { AActor* Other; } Parms;
	Parms.Other = Other;
	ProcessEvent( FindFunctionChecked(ENGINE_Bump, 0), &Parms, NULL );
}

void AActor::eventDemoPlaySound(USound* Sound, BYTE Slot, FLOAT Volume, DWORD bNoOverride, FLOAT Radius, FLOAT Pitch, DWORD Attenuate)
{
	struct { USound* Sound; BYTE Slot; FLOAT Volume; DWORD bNoOverride; FLOAT Radius; FLOAT Pitch; DWORD Attenuate; } Parms;
	Parms.Sound = Sound;
	Parms.Slot = Slot;
	Parms.Volume = Volume;
	Parms.bNoOverride = bNoOverride;
	Parms.Radius = Radius;
	Parms.Pitch = Pitch;
	Parms.Attenuate = Attenuate;
	ProcessEvent( FindFunctionChecked(ENGINE_DemoPlaySound, 0), &Parms, NULL );
}

void AActor::eventDestroyed()
{
	ProcessEvent( FindFunctionChecked(ENGINE_Destroyed, 0), NULL, NULL );
}

void AActor::eventDetach(AActor* Other)
{
	struct { AActor* Other; } Parms;
	Parms.Other = Other;
	ProcessEvent( FindFunctionChecked(ENGINE_Detach, 0), &Parms, NULL );
}

void AActor::eventEncroachedBy(AActor* Other)
{
	struct { AActor* Other; } Parms;
	Parms.Other = Other;
	ProcessEvent( FindFunctionChecked(ENGINE_EncroachedBy, 0), &Parms, NULL );
}

DWORD AActor::eventEncroachingOn(AActor* Other)
{
	struct { AActor* Other; DWORD ReturnValue; } Parms;
	Parms.Other = Other;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_EncroachingOn, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

void AActor::eventEndedRotation()
{
	ProcessEvent( FindFunctionChecked(ENGINE_EndedRotation, 0), NULL, NULL );
}

void AActor::eventEndEvent()
{
	ProcessEvent( FindFunctionChecked(ENGINE_EndEvent, 0), NULL, NULL );
}

void AActor::eventFalling()
{
	ProcessEvent( FindFunctionChecked(ENGINE_Falling, 0), NULL, NULL );
}

void AActor::eventFellOutOfWorld()
{
	ProcessEvent( FindFunctionChecked(ENGINE_FellOutOfWorld, 0), NULL, NULL );
}

void AActor::eventFinishedInterpolation()
{
	ProcessEvent( FindFunctionChecked(ENGINE_FinishedInterpolation, 0), NULL, NULL );
}

void AActor::eventGainedChild(AActor* Other)
{
	struct { AActor* Other; } Parms;
	Parms.Other = Other;
	ProcessEvent( FindFunctionChecked(ENGINE_GainedChild, 0), &Parms, NULL );
}

DWORD AActor::eventGetReticuleInfo(APawn* Pawn, FString& Info)
{
	struct { APawn* Pawn; FString Info; DWORD ReturnValue; } Parms;
	Parms.Pawn = Pawn;
	Parms.Info = Info;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_GetReticuleInfo, 0), &Parms, NULL );
	Info = Parms.Info;
	return Parms.ReturnValue;
}

void AActor::eventHitWall(FVector HitNormal, AActor* HitActor)
{
	struct { FVector HitNormal; AActor* HitActor; } Parms;
	Parms.HitNormal = HitNormal;
	Parms.HitActor = HitActor;
	ProcessEvent( FindFunctionChecked(ENGINE_HitWall, 0), &Parms, NULL );
}

void AActor::eventKApplyForce(FVector& Force, FVector& Torque)
{
	struct { FVector Force; FVector Torque; } Parms;
	Parms.Force = Force;
	Parms.Torque = Torque;
	ProcessEvent( FindFunctionChecked(ENGINE_KApplyForce, 0), &Parms, NULL );
	Force = Parms.Force;
	Torque = Parms.Torque;
}

void AActor::eventKilledBy(APawn* EventInstigator)
{
	struct { APawn* EventInstigator; } Parms;
	Parms.EventInstigator = EventInstigator;
	ProcessEvent( FindFunctionChecked(ENGINE_KilledBy, 0), &Parms, NULL );
}

void AActor::eventKImpact(AActor* Other, FVector Pos, FVector ImpactVel, FVector ImpactNorm)
{
	struct { AActor* Other; FVector Pos; FVector ImpactVel; FVector ImpactNorm; } Parms;
	Parms.Other = Other;
	Parms.Pos = Pos;
	Parms.ImpactVel = ImpactVel;
	Parms.ImpactNorm = ImpactNorm;
	ProcessEvent( FindFunctionChecked(ENGINE_KImpact, 0), &Parms, NULL );
}

void AActor::eventKSkelConvulse()
{
	ProcessEvent( FindFunctionChecked(ENGINE_KSkelConvulse, 0), NULL, NULL );
}

void AActor::eventKVelDropBelow()
{
	ProcessEvent( FindFunctionChecked(ENGINE_KVelDropBelow, 0), NULL, NULL );
}

void AActor::eventLanded(FVector HitNormal)
{
	struct { FVector HitNormal; } Parms;
	Parms.HitNormal = HitNormal;
	ProcessEvent( FindFunctionChecked(ENGINE_Landed, 0), &Parms, NULL );
}

void AActor::eventLostChild(AActor* Other)
{
	struct { AActor* Other; } Parms;
	Parms.Other = Other;
	ProcessEvent( FindFunctionChecked(ENGINE_LostChild, 0), &Parms, NULL );
}

void AActor::eventPhysicsVolumeChange(APhysicsVolume* NewVolume)
{
	struct { APhysicsVolume* NewVolume; } Parms;
	Parms.NewVolume = NewVolume;
	ProcessEvent( FindFunctionChecked(ENGINE_PhysicsVolumeChange, 0), &Parms, NULL );
}

void AActor::eventPostBeginPlay()
{
	ProcessEvent( FindFunctionChecked(ENGINE_PostBeginPlay, 0), NULL, NULL );
}

void AActor::eventPostNetBeginPlay()
{
	ProcessEvent( FindFunctionChecked(ENGINE_PostNetBeginPlay, 0), NULL, NULL );
}

void AActor::eventPostTeleport(ATeleporter* OutTeleporter)
{
	struct { ATeleporter* OutTeleporter; } Parms;
	Parms.OutTeleporter = OutTeleporter;
	ProcessEvent( FindFunctionChecked(ENGINE_PostTeleport, 0), &Parms, NULL );
}

void AActor::eventPostTouch(AActor* Other)
{
	struct { AActor* Other; } Parms;
	Parms.Other = Other;
	ProcessEvent( FindFunctionChecked(ENGINE_PostTouch, 0), &Parms, NULL );
}

void AActor::eventPreBeginPlay()
{
	ProcessEvent( FindFunctionChecked(ENGINE_PreBeginPlay, 0), NULL, NULL );
}

DWORD AActor::eventPreTeleport(ATeleporter* InTeleporter)
{
	struct { ATeleporter* InTeleporter; DWORD ReturnValue; } Parms;
	Parms.InTeleporter = InTeleporter;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_PreTeleport, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

DWORD AActor::eventProcessHeart(FLOAT DeltaSeconds, FLOAT& HeartBeatRate, FLOAT& BloodScreenAlpha)
{
	struct { FLOAT DeltaSeconds; FLOAT HeartBeatRate; FLOAT BloodScreenAlpha; DWORD ReturnValue; } Parms;
	Parms.DeltaSeconds = DeltaSeconds;
	Parms.HeartBeatRate = HeartBeatRate;
	Parms.BloodScreenAlpha = BloodScreenAlpha;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_ProcessHeart, 0), &Parms, NULL );
	HeartBeatRate = Parms.HeartBeatRate;
	BloodScreenAlpha = Parms.BloodScreenAlpha;
	return Parms.ReturnValue;
}

void AActor::eventR6MakeNoise(BYTE Loudness)
{
	struct { BYTE Loudness; } Parms;
	Parms.Loudness = Loudness;
	ProcessEvent( FindFunctionChecked(ENGINE_R6MakeNoise, 0), &Parms, NULL );
}

void AActor::eventR6QueryCircumstantialAction(FLOAT DeltaSeconds, AR6AbstractCircumstantialActionQuery*& Query, APlayerController* PC)
{
	struct { FLOAT DeltaSeconds; AR6AbstractCircumstantialActionQuery* Query; APlayerController* PC; } Parms;
	Parms.DeltaSeconds = DeltaSeconds;
	Parms.Query = Query;
	Parms.PC = PC;
	ProcessEvent( FindFunctionChecked(ENGINE_R6QueryCircumstantialAction, 0), &Parms, NULL );
	Query = Parms.Query;
}

void AActor::eventSaveAndResetData()
{
	ProcessEvent( FindFunctionChecked(ENGINE_SaveAndResetData, 0), NULL, NULL );
}

void AActor::eventSetInitialState()
{
	ProcessEvent( FindFunctionChecked(ENGINE_SetInitialState, 0), NULL, NULL );
}

AActor* AActor::eventSpecialHandling(APawn* Other)
{
	struct { APawn* Other; AActor* ReturnValue; } Parms;
	Parms.Other = Other;
	Parms.ReturnValue = NULL;
	ProcessEvent( FindFunctionChecked(ENGINE_SpecialHandling, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

void AActor::eventTick(FLOAT DeltaTime)
{
	struct { FLOAT DeltaTime; } Parms;
	Parms.DeltaTime = DeltaTime;
	ProcessEvent( FindFunctionChecked(ENGINE_Tick, 0), &Parms, NULL );
}

void AActor::eventTimer()
{
	ProcessEvent( FindFunctionChecked(ENGINE_Timer, 0), NULL, NULL );
}

void AActor::eventTornOff()
{
	ProcessEvent( FindFunctionChecked(ENGINE_TornOff, 0), NULL, NULL );
}

void AActor::eventTouch(AActor* Other)
{
	struct { AActor* Other; } Parms;
	Parms.Other = Other;
	ProcessEvent( FindFunctionChecked(ENGINE_Touch, 0), &Parms, NULL );
}

void AActor::eventTravelPostAccept()
{
	ProcessEvent( FindFunctionChecked(ENGINE_TravelPostAccept, 0), NULL, NULL );
}

void AActor::eventTravelPreAccept()
{
	ProcessEvent( FindFunctionChecked(ENGINE_TravelPreAccept, 0), NULL, NULL );
}

void AActor::eventTrigger(AActor* Other, APawn* EventInstigator)
{
	struct { AActor* Other; APawn* EventInstigator; } Parms;
	Parms.Other = Other;
	Parms.EventInstigator = EventInstigator;
	ProcessEvent( FindFunctionChecked(ENGINE_Trigger, 0), &Parms, NULL );
}

void AActor::eventTriggerEvent(FName EventName, AActor* Other, APawn* EventInstigator)
{
	struct { FName EventName; AActor* Other; APawn* EventInstigator; } Parms;
	Parms.EventName = EventName;
	Parms.Other = Other;
	Parms.EventInstigator = EventInstigator;
	ProcessEvent( FindFunctionChecked(ENGINE_TriggerEvent, 0), &Parms, NULL );
}

void AActor::eventUnTouch(AActor* Other)
{
	struct { AActor* Other; } Parms;
	Parms.Other = Other;
	ProcessEvent( FindFunctionChecked(ENGINE_UnTouch, 0), &Parms, NULL );
}

void AActor::eventUnTrigger(AActor* Other, APawn* EventInstigator)
{
	struct { AActor* Other; APawn* EventInstigator; } Parms;
	Parms.Other = Other;
	Parms.EventInstigator = EventInstigator;
	ProcessEvent( FindFunctionChecked(ENGINE_UnTrigger, 0), &Parms, NULL );
}

void AActor::eventUsedBy(APawn* User)
{
	struct { APawn* User; } Parms;
	Parms.User = User;
	ProcessEvent( FindFunctionChecked(ENGINE_UsedBy, 0), &Parms, NULL );
}

void AActor::eventZoneChange(AZoneInfo* NewZone)
{
	struct { AZoneInfo* NewZone; } Parms;
	Parms.NewZone = NewZone;
	ProcessEvent( FindFunctionChecked(ENGINE_ZoneChange, 0), &Parms, NULL );
}

/*-----------------------------------------------------------------------------
	APawn event thunks (21).
-----------------------------------------------------------------------------*/

void APawn::eventBreathTimer()
{
	ProcessEvent( FindFunctionChecked(ENGINE_BreathTimer, 0), NULL, NULL );
}

void APawn::eventChangeAnimation()
{
	ProcessEvent( FindFunctionChecked(ENGINE_ChangeAnimation, 0), NULL, NULL );
}

void APawn::eventClientMessage(const FString& S, FName Type)
{
	struct { FString S; FName Type; } Parms;
	Parms.S = S;
	Parms.Type = Type;
	ProcessEvent( FindFunctionChecked(ENGINE_ClientMessage, 0), &Parms, NULL );
}

void APawn::eventEndClimbLadder(ALadderVolume* OldLadder)
{
	struct { ALadderVolume* OldLadder; } Parms;
	Parms.OldLadder = OldLadder;
	ProcessEvent( FindFunctionChecked(ENGINE_EndClimbLadder, 0), &Parms, NULL );
}

void APawn::eventEndCrouch(FLOAT HeightAdjust)
{
	struct { FLOAT HeightAdjust; } Parms;
	Parms.HeightAdjust = HeightAdjust;
	ProcessEvent( FindFunctionChecked(ENGINE_EndCrouch, 0), &Parms, NULL );
}

FVector APawn::eventEyePosition()
{
	struct { FVector ReturnValue; } Parms;
	Parms.ReturnValue = FVector(0,0,0);
	ProcessEvent( FindFunctionChecked(ENGINE_EyePosition, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

FRotator APawn::eventGetViewRotation()
{
	struct { FRotator ReturnValue; } Parms;
	Parms.ReturnValue = FRotator(0,0,0);
	ProcessEvent( FindFunctionChecked(ENGINE_GetViewRotation, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

void APawn::eventHeadVolumeChange(APhysicsVolume* NewHeadVolume)
{
	struct { APhysicsVolume* NewHeadVolume; } Parms;
	Parms.NewHeadVolume = NewHeadVolume;
	ProcessEvent( FindFunctionChecked(ENGINE_HeadVolumeChange, 0), &Parms, NULL );
}

void APawn::eventPlayDying(FVector HitLoc)
{
	struct { FVector HitLoc; } Parms;
	Parms.HitLoc = HitLoc;
	ProcessEvent( FindFunctionChecked(ENGINE_PlayDying, 0), &Parms, NULL );
}

void APawn::eventPlayFalling()
{
	ProcessEvent( FindFunctionChecked(ENGINE_PlayFalling, 0), NULL, NULL );
}

void APawn::eventPlayJump()
{
	ProcessEvent( FindFunctionChecked(ENGINE_PlayJump, 0), NULL, NULL );
}

void APawn::eventPlayLandingAnimation(FLOAT ImpactVel)
{
	struct { FLOAT ImpactVel; } Parms;
	Parms.ImpactVel = ImpactVel;
	ProcessEvent( FindFunctionChecked(ENGINE_PlayLandingAnimation, 0), &Parms, NULL );
}

void APawn::eventPlayWeaponAnimation()
{
	ProcessEvent( FindFunctionChecked(ENGINE_PlayWeaponAnimation, 0), NULL, NULL );
}

void APawn::eventR6DeadEndedMoving()
{
	ProcessEvent( FindFunctionChecked(ENGINE_R6DeadEndedMoving, 0), NULL, NULL );
}

void APawn::eventReceivedEngineWeapon()
{
	ProcessEvent( FindFunctionChecked(ENGINE_ReceivedEngineWeapon, 0), NULL, NULL );
}

void APawn::eventReceivedWeapons()
{
	ProcessEvent( FindFunctionChecked(ENGINE_ReceivedWeapons, 0), NULL, NULL );
}

void APawn::eventSetAnimAction(FName NewAction)
{
	struct { FName NewAction; } Parms;
	Parms.NewAction = NewAction;
	ProcessEvent( FindFunctionChecked(ENGINE_SetAnimAction, 0), &Parms, NULL );
}

void APawn::eventSetWalking(DWORD bNewIsWalking)
{
	struct { DWORD bNewIsWalking; } Parms;
	Parms.bNewIsWalking = bNewIsWalking;
	ProcessEvent( FindFunctionChecked(ENGINE_SetWalking, 0), &Parms, NULL );
}

void APawn::eventStartCrouch(FLOAT HeightAdjust)
{
	struct { FLOAT HeightAdjust; } Parms;
	Parms.HeightAdjust = HeightAdjust;
	ProcessEvent( FindFunctionChecked(ENGINE_StartCrouch, 0), &Parms, NULL );
}

void APawn::eventStopAnimForRG()
{
	ProcessEvent( FindFunctionChecked(ENGINE_StopAnimForRG, 0), NULL, NULL );
}

void APawn::eventStopPlayFiring()
{
	ProcessEvent( FindFunctionChecked(ENGINE_StopPlayFiring, 0), NULL, NULL );
}

/*-----------------------------------------------------------------------------
	AController event thunks (16).
-----------------------------------------------------------------------------*/

void AController::eventAIHearSound(AActor* Actor, INT Id, USound* S, FVector SoundLoc, FVector Parameters, DWORD bStopSound)
{
	struct { AActor* Actor; INT Id; USound* S; FVector SoundLoc; FVector Parameters; DWORD bStopSound; } Parms;
	Parms.Actor = Actor;
	Parms.Id = Id;
	Parms.S = S;
	Parms.SoundLoc = SoundLoc;
	Parms.Parameters = Parameters;
	Parms.bStopSound = bStopSound;
	ProcessEvent( FindFunctionChecked(ENGINE_AIHearSound, 0), &Parms, NULL );
}

void AController::eventEnemyNotVisible()
{
	ProcessEvent( FindFunctionChecked(ENGINE_EnemyNotVisible, 0), NULL, NULL );
}

void AController::eventHearNoise(FLOAT Loudness, AActor* NoiseMaker, BYTE NoiseCategory, BYTE bExactPos)
{
	struct { FLOAT Loudness; AActor* NoiseMaker; BYTE NoiseCategory; BYTE bExactPos; } Parms;
	Parms.Loudness = Loudness;
	Parms.NoiseMaker = NoiseMaker;
	Parms.NoiseCategory = NoiseCategory;
	Parms.bExactPos = bExactPos;
	ProcessEvent( FindFunctionChecked(ENGINE_HearNoise, 0), &Parms, NULL );
}

void AController::eventLongFall()
{
	ProcessEvent( FindFunctionChecked(ENGINE_LongFall, 0), NULL, NULL );
}

void AController::eventMayFall()
{
	ProcessEvent( FindFunctionChecked(ENGINE_MayFall, 0), NULL, NULL );
}

void AController::eventMonitoredPawnAlert()
{
	ProcessEvent( FindFunctionChecked(ENGINE_MonitoredPawnAlert, 0), NULL, NULL );
}

DWORD AController::eventNotifyBump(AActor* Other)
{
	struct { AActor* Other; DWORD ReturnValue; } Parms;
	Parms.Other = Other;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_NotifyBump, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

DWORD AController::eventNotifyHeadVolumeChange(APhysicsVolume* NewVolume)
{
	struct { APhysicsVolume* NewVolume; DWORD ReturnValue; } Parms;
	Parms.NewVolume = NewVolume;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_NotifyHeadVolumeChange, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

void AController::eventNotifyHitMover(FVector HitNormal, AMover* Wall)
{
	struct { FVector HitNormal; AMover* Wall; } Parms;
	Parms.HitNormal = HitNormal;
	Parms.Wall = Wall;
	ProcessEvent( FindFunctionChecked(ENGINE_NotifyHitMover, 0), &Parms, NULL );
}

DWORD AController::eventNotifyHitWall(FVector HitNormal, AActor* HitActor)
{
	struct { FVector HitNormal; AActor* HitActor; DWORD ReturnValue; } Parms;
	Parms.HitNormal = HitNormal;
	Parms.HitActor = HitActor;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_NotifyHitWall, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

DWORD AController::eventNotifyLanded(FVector HitNormal)
{
	struct { FVector HitNormal; DWORD ReturnValue; } Parms;
	Parms.HitNormal = HitNormal;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_NotifyLanded, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

DWORD AController::eventNotifyPhysicsVolumeChange(APhysicsVolume* NewVolume)
{
	struct { APhysicsVolume* NewVolume; DWORD ReturnValue; } Parms;
	Parms.NewVolume = NewVolume;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_NotifyPhysicsVolumeChange, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

void AController::eventPrepareForMove(ANavigationPoint* Goal, UReachSpec* Path)
{
	struct { ANavigationPoint* Goal; UReachSpec* Path; } Parms;
	Parms.Goal = Goal;
	Parms.Path = Path;
	ProcessEvent( FindFunctionChecked(ENGINE_PrepareForMove, 0), &Parms, NULL );
}

void AController::eventSeeMonster(APawn* Seen)
{
	struct { APawn* Seen; } Parms;
	Parms.Seen = Seen;
	ProcessEvent( FindFunctionChecked(ENGINE_SeeMonster, 0), &Parms, NULL );
}

void AController::eventSeePlayer(APawn* Seen)
{
	struct { APawn* Seen; } Parms;
	Parms.Seen = Seen;
	ProcessEvent( FindFunctionChecked(ENGINE_SeePlayer, 0), &Parms, NULL );
}

/*-----------------------------------------------------------------------------
	APlayerController event thunks (21).
-----------------------------------------------------------------------------*/

void APlayerController::eventAddCameraEffect(UCameraEffect* NewEffect, DWORD bRemoveExisting)
{
	struct { UCameraEffect* NewEffect; DWORD bRemoveExisting; } Parms;
	Parms.NewEffect = NewEffect;
	Parms.bRemoveExisting = bRemoveExisting;
	ProcessEvent( FindFunctionChecked(ENGINE_AddCameraEffect, 0), &Parms, NULL );
}

void APlayerController::eventClientHearSound(AActor* Actor, USound* S, BYTE Priority)
{
	struct { AActor* Actor; USound* S; BYTE Priority; } Parms;
	Parms.Actor = Actor;
	Parms.S = S;
	Parms.Priority = Priority;
	ProcessEvent( FindFunctionChecked(ENGINE_ClientHearSound, 0), &Parms, NULL );
}

void APlayerController::eventClientMessage(const FString& S, FName Type)
{
	struct { FString S; FName Type; } Parms;
	Parms.S = S;
	Parms.Type = Type;
	ProcessEvent( FindFunctionChecked(ENGINE_ClientMessage, 0), &Parms, NULL );
}

void APlayerController::eventClientPBKickedOutMessage(const FString& S)
{
	struct { FString S; } Parms;
	Parms.S = S;
	ProcessEvent( FindFunctionChecked(ENGINE_ClientPBKickedOutMessage, 0), &Parms, NULL );
}

void APlayerController::eventClientSetNewViewTarget()
{
	ProcessEvent( FindFunctionChecked(ENGINE_ClientSetNewViewTarget, 0), NULL, NULL );
}

void APlayerController::eventClientTravel(const FString& URL, BYTE TravelType, DWORD bItems)
{
	struct { FString URL; BYTE TravelType; DWORD bItems; } Parms;
	Parms.URL = URL;
	Parms.TravelType = TravelType;
	Parms.bItems = bItems;
	ProcessEvent( FindFunctionChecked(ENGINE_ClientTravel, 0), &Parms, NULL );
}

FString APlayerController::eventGetLocalPlayerIp()
{
	struct { FString ReturnValue; } Parms;
	ProcessEvent( FindFunctionChecked(ENGINE_GetLocalPlayerIp, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

void APlayerController::eventHandleServerMsg(const FString& Msg, INT MsgType)
{
	struct { FString Msg; INT MsgType; } Parms;
	Parms.Msg = Msg;
	Parms.MsgType = MsgType;
	ProcessEvent( FindFunctionChecked(ENGINE_HandleServerMsg, 0), &Parms, NULL );
}

void APlayerController::eventInitInputSystem()
{
	ProcessEvent( FindFunctionChecked(ENGINE_InitInputSystem, 0), NULL, NULL );
}

void APlayerController::eventInitMultiPlayerOptions()
{
	ProcessEvent( FindFunctionChecked(ENGINE_InitMultiPlayerOptions, 0), NULL, NULL );
}

DWORD APlayerController::eventIsPlayerPassiveSpectator()
{
	struct { DWORD ReturnValue; } Parms;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_IsPlayerPassiveSpectator, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

void APlayerController::eventPlayerCalcView(AActor*& ViewActor, FVector& CameraLocation, FRotator& CameraRotation)
{
	struct { AActor* ViewActor; FVector CameraLocation; FRotator CameraRotation; } Parms;
	Parms.ViewActor = ViewActor;
	Parms.CameraLocation = CameraLocation;
	Parms.CameraRotation = CameraRotation;
	ProcessEvent( FindFunctionChecked(ENGINE_PlayerCalcView, 0), &Parms, NULL );
	ViewActor = Parms.ViewActor;
	CameraLocation = Parms.CameraLocation;
	CameraRotation = Parms.CameraRotation;
}

void APlayerController::eventPlayerTick(FLOAT DeltaTime)
{
	struct { FLOAT DeltaTime; } Parms;
	Parms.DeltaTime = DeltaTime;
	ProcessEvent( FindFunctionChecked(ENGINE_PlayerTick, 0), &Parms, NULL );
}

void APlayerController::eventPreClientTravel()
{
	ProcessEvent( FindFunctionChecked(ENGINE_PreClientTravel, 0), NULL, NULL );
}

void APlayerController::eventReceiveLocalizedMessage(UClass* MsgClass, INT Switch, APlayerReplicationInfo* RI1, APlayerReplicationInfo* RI2, UObject* OptObj)
{
	struct { UClass* MsgClass; INT Switch; APlayerReplicationInfo* RI1; APlayerReplicationInfo* RI2; UObject* OptObj; } Parms;
	Parms.MsgClass = MsgClass;
	Parms.Switch = Switch;
	Parms.RI1 = RI1;
	Parms.RI2 = RI2;
	Parms.OptObj = OptObj;
	ProcessEvent( FindFunctionChecked(ENGINE_ReceiveLocalizedMessage, 0), &Parms, NULL );
}

void APlayerController::eventRemoveCameraEffect(UCameraEffect* RemEffect)
{
	struct { UCameraEffect* RemEffect; } Parms;
	Parms.RemEffect = RemEffect;
	ProcessEvent( FindFunctionChecked(ENGINE_RemoveCameraEffect, 0), &Parms, NULL );
}

void APlayerController::eventSetMatchResult(const FString& Result, INT Team, INT Score)
{
	struct { FString Result; INT Team; INT Score; } Parms;
	Parms.Result = Result;
	Parms.Team = Team;
	Parms.Score = Score;
	ProcessEvent( FindFunctionChecked(ENGINE_SetMatchResult, 0), &Parms, NULL );
}

void APlayerController::eventSetProgressTime(FLOAT Time)
{
	struct { FLOAT Time; } Parms;
	Parms.Time = Time;
	ProcessEvent( FindFunctionChecked(ENGINE_SetProgressTime, 0), &Parms, NULL );
}

void APlayerController::eventTeamMessage(APlayerReplicationInfo* PRI, const FString& S, FName Type)
{
	struct { APlayerReplicationInfo* PRI; FString S; FName Type; } Parms;
	Parms.PRI = PRI;
	Parms.S = S;
	Parms.Type = Type;
	ProcessEvent( FindFunctionChecked(ENGINE_TeamMessage, 0), &Parms, NULL );
}

void APlayerController::eventToggleRadar(DWORD bShow)
{
	struct { DWORD bShow; } Parms;
	Parms.bShow = bShow;
	ProcessEvent( FindFunctionChecked(ENGINE_ToggleRadar, 0), &Parms, NULL );
}

/*-----------------------------------------------------------------------------
	AGameInfo event thunks (14).
-----------------------------------------------------------------------------*/

void AGameInfo::eventAcceptInventory(APawn* PlayerPawn)
{
	struct { APawn* PlayerPawn; } Parms;
	Parms.PlayerPawn = PlayerPawn;
	ProcessEvent( FindFunctionChecked(ENGINE_AcceptInventory, 0), &Parms, NULL );
}

void AGameInfo::eventBroadcast(AActor* Sender, const FString& Msg, FName Type)
{
	struct { AActor* Sender; FString Msg; FName Type; } Parms;
	Parms.Sender = Sender;
	Parms.Msg = Msg;
	Parms.Type = Type;
	ProcessEvent( FindFunctionChecked(ENGINE_Broadcast, 0), &Parms, NULL );
}

void AGameInfo::eventBroadcastLocalized(AActor* Sender, UClass* MsgClass, INT Switch, APlayerReplicationInfo* RI1, APlayerReplicationInfo* RI2, UObject* OptObj)
{
	struct { AActor* Sender; UClass* MsgClass; INT Switch; APlayerReplicationInfo* RI1; APlayerReplicationInfo* RI2; UObject* OptObj; } Parms;
	Parms.Sender = Sender;
	Parms.MsgClass = MsgClass;
	Parms.Switch = Switch;
	Parms.RI1 = RI1;
	Parms.RI2 = RI2;
	Parms.OptObj = OptObj;
	ProcessEvent( FindFunctionChecked(ENGINE_BroadcastLocalized, 0), &Parms, NULL );
}

DWORD AGameInfo::eventCanPlayIntroVideo()
{
	struct { DWORD ReturnValue; } Parms;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_CanPlayIntroVideo, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

DWORD AGameInfo::eventCanPlayOutroVideo()
{
	struct { DWORD ReturnValue; } Parms;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_CanPlayOutroVideo, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

void AGameInfo::eventDetailChange()
{
	ProcessEvent( FindFunctionChecked(ENGINE_DetailChange, 0), NULL, NULL );
}

void AGameInfo::eventGameEnding()
{
	ProcessEvent( FindFunctionChecked(ENGINE_GameEnding, 0), NULL, NULL );
}

FString AGameInfo::eventGetBeaconText()
{
	struct { FString ReturnValue; } Parms;
	ProcessEvent( FindFunctionChecked(ENGINE_GetBeaconText, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

void AGameInfo::eventInitGame(const FString& Options, FString& Error)
{
	struct { FString Options; FString Error; } Parms;
	Parms.Options = Options;
	Parms.Error = Error;
	ProcessEvent( FindFunctionChecked(ENGINE_InitGame, 0), &Parms, NULL );
	Error = Parms.Error;
}

APlayerController* AGameInfo::eventLogin(const FString& Portal, const FString& Options, FString& Error)
{
	struct { FString Portal; FString Options; FString Error; APlayerController* ReturnValue; } Parms;
	Parms.Portal = Portal;
	Parms.Options = Options;
	Parms.Error = Error;
	Parms.ReturnValue = NULL;
	ProcessEvent( FindFunctionChecked(ENGINE_Login, 0), &Parms, NULL );
	Error = Parms.Error;
	return Parms.ReturnValue;
}

void AGameInfo::eventPostLogin(APlayerController* NewPlayer)
{
	struct { APlayerController* NewPlayer; } Parms;
	Parms.NewPlayer = NewPlayer;
	ProcessEvent( FindFunctionChecked(ENGINE_PostLogin, 0), &Parms, NULL );
}

void AGameInfo::eventPreLogin(const FString& Options, const FString& Address, FString& Error, FString& FailCode)
{
	struct { FString Options; FString Address; FString Error; FString FailCode; } Parms;
	Parms.Options = Options;
	Parms.Address = Address;
	Parms.Error = Error;
	Parms.FailCode = FailCode;
	ProcessEvent( FindFunctionChecked(ENGINE_PreLogin, 0), &Parms, NULL );
	Error = Parms.Error;
	FailCode = Parms.FailCode;
}

void AGameInfo::eventPreLogOut(APlayerController* Exiting)
{
	struct { APlayerController* Exiting; } Parms;
	Parms.Exiting = Exiting;
	ProcessEvent( FindFunctionChecked(ENGINE_PreLogOut, 0), &Parms, NULL );
}

void AGameInfo::eventUpdateServer()
{
	ProcessEvent( FindFunctionChecked(ENGINE_UpdateServer, 0), NULL, NULL );
}

/*-----------------------------------------------------------------------------
	AHUD event thunks (5).
-----------------------------------------------------------------------------*/

void AHUD::eventPostFadeRender(UCanvas* Canvas)
{
	struct { UCanvas* Canvas; } Parms;
	Parms.Canvas = Canvas;
	ProcessEvent( FindFunctionChecked(ENGINE_PostFadeRender, 0), &Parms, NULL );
}

void AHUD::eventPostRender(UCanvas* Canvas)
{
	struct { UCanvas* Canvas; } Parms;
	Parms.Canvas = Canvas;
	ProcessEvent( FindFunctionChecked(ENGINE_PostRender, 0), &Parms, NULL );
}

void AHUD::eventRenderFirstPersonGun(UCanvas* Canvas)
{
	struct { UCanvas* Canvas; } Parms;
	Parms.Canvas = Canvas;
	ProcessEvent( FindFunctionChecked(ENGINE_RenderFirstPersonGun, 0), &Parms, NULL );
}

void AHUD::eventShowUpgradeMenu()
{
	ProcessEvent( FindFunctionChecked(ENGINE_ShowUpgradeMenu, 0), NULL, NULL );
}

void AHUD::eventWorldSpaceOverlays()
{
	ProcessEvent( FindFunctionChecked(ENGINE_WorldSpaceOverlays, 0), NULL, NULL );
}

/*-----------------------------------------------------------------------------
	UInteraction event thunks (15).
-----------------------------------------------------------------------------*/

void UInteraction::eventConnectionFailed()
{
	ProcessEvent( FindFunctionChecked(ENGINE_ConnectionFailed, 0), NULL, NULL );
}

FString UInteraction::eventConvertKeyToLocalisation(BYTE Key, const FString& DefaultText)
{
	struct { BYTE Key; FString DefaultText; FString ReturnValue; } Parms;
	Parms.Key = Key;
	Parms.DefaultText = DefaultText;
	ProcessEvent( FindFunctionChecked(ENGINE_ConvertKeyToLocalisation, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

FString UInteraction::eventGetStoreGamePwd()
{
	struct { FString ReturnValue; } Parms;
	ProcessEvent( FindFunctionChecked(ENGINE_GetStoreGamePwd, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

void UInteraction::eventInitialized()
{
	ProcessEvent( FindFunctionChecked(ENGINE_Initialized, 0), NULL, NULL );
}

void UInteraction::eventLaunchR6MainMenu()
{
	ProcessEvent( FindFunctionChecked(ENGINE_LaunchR6MainMenu, 0), NULL, NULL );
}

void UInteraction::eventMenuLoadProfile(DWORD bAutoLoad)
{
	struct { DWORD bAutoLoad; } Parms;
	Parms.bAutoLoad = bAutoLoad;
	ProcessEvent( FindFunctionChecked(ENGINE_MenuLoadProfile, 0), &Parms, NULL );
}

void UInteraction::eventNotifyAfterLevelChange()
{
	ProcessEvent( FindFunctionChecked(ENGINE_NotifyAfterLevelChange, 0), NULL, NULL );
}

void UInteraction::eventNotifyLevelChange()
{
	ProcessEvent( FindFunctionChecked(ENGINE_NotifyLevelChange, 0), NULL, NULL );
}

void UInteraction::eventR6ConnectionFailed(const FString& FailMsg)
{
	struct { FString FailMsg; } Parms;
	Parms.FailMsg = FailMsg;
	ProcessEvent( FindFunctionChecked(ENGINE_R6ConnectionFailed, 0), &Parms, NULL );
}

void UInteraction::eventR6ConnectionInProgress()
{
	ProcessEvent( FindFunctionChecked(ENGINE_R6ConnectionInProgress, 0), NULL, NULL );
}

void UInteraction::eventR6ConnectionInterrupted()
{
	ProcessEvent( FindFunctionChecked(ENGINE_R6ConnectionInterrupted, 0), NULL, NULL );
}

void UInteraction::eventR6ConnectionSuccess()
{
	ProcessEvent( FindFunctionChecked(ENGINE_R6ConnectionSuccess, 0), NULL, NULL );
}

void UInteraction::eventR6ProgressMsg(const FString& Msg1, const FString& Msg2, FLOAT Pct)
{
	struct { FString Msg1; FString Msg2; FLOAT Pct; } Parms;
	Parms.Msg1 = Msg1;
	Parms.Msg2 = Msg2;
	Parms.Pct = Pct;
	ProcessEvent( FindFunctionChecked(ENGINE_R6ProgressMsg, 0), &Parms, NULL );
}

void UInteraction::eventServerDisconnected()
{
	ProcessEvent( FindFunctionChecked(ENGINE_ServerDisconnected, 0), NULL, NULL );
}

void UInteraction::eventUserDisconnected()
{
	ProcessEvent( FindFunctionChecked(ENGINE_UserDisconnected, 0), NULL, NULL );
}

/*-----------------------------------------------------------------------------
	UInteractionMaster event thunks (9).
-----------------------------------------------------------------------------*/

UInteraction* UInteractionMaster::eventAddInteraction(const FString& ClassName, UPlayer* Player)
{
	struct { FString ClassName; UPlayer* Player; UInteraction* ReturnValue; } Parms;
	Parms.ClassName = ClassName;
	Parms.Player = Player;
	Parms.ReturnValue = NULL;
	ProcessEvent( FindFunctionChecked(ENGINE_AddInteraction, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

DWORD UInteractionMaster::eventProcess_KeyEvent(TArray<UInteraction*> InteractionArray, BYTE& Key, BYTE& Action, FLOAT Delta)
{
	struct { TArray<UInteraction*> InteractionArray; BYTE Key; BYTE Action; FLOAT Delta; DWORD ReturnValue; } Parms;
	Parms.InteractionArray = InteractionArray;
	Parms.Key = Key;
	Parms.Action = Action;
	Parms.Delta = Delta;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_Process_KeyEvent, 0), &Parms, NULL );
	Key = Parms.Key;
	Action = Parms.Action;
	return Parms.ReturnValue;
}

DWORD UInteractionMaster::eventProcess_KeyType(TArray<UInteraction*> InteractionArray, BYTE& Key)
{
	struct { TArray<UInteraction*> InteractionArray; BYTE Key; DWORD ReturnValue; } Parms;
	Parms.InteractionArray = InteractionArray;
	Parms.Key = Key;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_Process_KeyType, 0), &Parms, NULL );
	Key = Parms.Key;
	return Parms.ReturnValue;
}

void UInteractionMaster::eventProcess_Message(const FString& Msg, FLOAT MsgLife, TArray<UInteraction*> InteractionArray)
{
	struct { FString Msg; FLOAT MsgLife; TArray<UInteraction*> InteractionArray; } Parms;
	Parms.Msg = Msg;
	Parms.MsgLife = MsgLife;
	Parms.InteractionArray = InteractionArray;
	ProcessEvent( FindFunctionChecked(ENGINE_Process_Message, 0), &Parms, NULL );
}

void UInteractionMaster::eventProcess_PostRender(TArray<UInteraction*> InteractionArray, UCanvas* Canvas)
{
	struct { TArray<UInteraction*> InteractionArray; UCanvas* Canvas; } Parms;
	Parms.InteractionArray = InteractionArray;
	Parms.Canvas = Canvas;
	ProcessEvent( FindFunctionChecked(ENGINE_Process_PostRender, 0), &Parms, NULL );
}

void UInteractionMaster::eventProcess_PreRender(TArray<UInteraction*> InteractionArray, UCanvas* Canvas)
{
	struct { TArray<UInteraction*> InteractionArray; UCanvas* Canvas; } Parms;
	Parms.InteractionArray = InteractionArray;
	Parms.Canvas = Canvas;
	ProcessEvent( FindFunctionChecked(ENGINE_Process_PreRender, 0), &Parms, NULL );
}

void UInteractionMaster::eventProcess_Tick(TArray<UInteraction*> InteractionArray, FLOAT DeltaTime)
{
	struct { TArray<UInteraction*> InteractionArray; FLOAT DeltaTime; } Parms;
	Parms.InteractionArray = InteractionArray;
	Parms.DeltaTime = DeltaTime;
	ProcessEvent( FindFunctionChecked(ENGINE_Process_Tick, 0), &Parms, NULL );
}

void UInteractionMaster::eventRemoveInteraction(UInteraction* Interaction)
{
	struct { UInteraction* Interaction; } Parms;
	Parms.Interaction = Interaction;
	ProcessEvent( FindFunctionChecked(ENGINE_RemoveInteraction, 0), &Parms, NULL );
}

void UInteractionMaster::eventSetFocusTo(UInteraction* Interaction, UPlayer* Player)
{
	struct { UInteraction* Interaction; UPlayer* Player; } Parms;
	Parms.Interaction = Interaction;
	Parms.Player = Player;
	ProcessEvent( FindFunctionChecked(ENGINE_SetFocusTo, 0), &Parms, NULL );
}

/*-----------------------------------------------------------------------------
	UR6ModMgr event thunks (16).
-----------------------------------------------------------------------------*/

FString UR6ModMgr::eventGetBackgroundsRoot()
{
	struct { FString ReturnValue; } Parms;
	ProcessEvent( FindFunctionChecked(ENGINE_GetBackgroundsRoot, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

FString UR6ModMgr::eventGetCampaignDir()
{
	struct { FString ReturnValue; } Parms;
	ProcessEvent( FindFunctionChecked(ENGINE_GetCampaignDir, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

FString UR6ModMgr::eventGetDefaultCampaignDir()
{
	struct { FString ReturnValue; } Parms;
	ProcessEvent( FindFunctionChecked(ENGINE_GetDefaultCampaignDir, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

INT UR6ModMgr::eventGetGameTypeIndex(const FString& GameType)
{
	struct { FString GameType; INT ReturnValue; } Parms;
	Parms.GameType = GameType;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_GetGameTypeIndex, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

FString UR6ModMgr::eventGetGameTypeName(INT Index)
{
	struct { INT Index; FString ReturnValue; } Parms;
	Parms.Index = Index;
	ProcessEvent( FindFunctionChecked(ENGINE_GetGameTypeName, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

FString UR6ModMgr::eventGetIniFilesDir()
{
	struct { FString ReturnValue; } Parms;
	ProcessEvent( FindFunctionChecked(ENGINE_GetIniFilesDir, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

FString UR6ModMgr::eventGetMapsDir()
{
	struct { FString ReturnValue; } Parms;
	ProcessEvent( FindFunctionChecked(ENGINE_GetMapsDir, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

FString UR6ModMgr::eventGetModKeyword()
{
	struct { FString ReturnValue; } Parms;
	ProcessEvent( FindFunctionChecked(ENGINE_GetModKeyword, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

FString UR6ModMgr::eventGetModName()
{
	struct { FString ReturnValue; } Parms;
	ProcessEvent( FindFunctionChecked(ENGINE_GetModName, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

INT UR6ModMgr::eventGetNbMods()
{
	struct { INT ReturnValue; } Parms;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_GetNbMods, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

FString UR6ModMgr::eventGetServerIni()
{
	struct { FString ReturnValue; } Parms;
	ProcessEvent( FindFunctionChecked(ENGINE_GetServerIni, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

FString UR6ModMgr::eventGetVideosRoot()
{
	struct { FString ReturnValue; } Parms;
	ProcessEvent( FindFunctionChecked(ENGINE_GetVideosRoot, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

void UR6ModMgr::eventInitModMgr()
{
	ProcessEvent( FindFunctionChecked(ENGINE_InitModMgr, 0), NULL, NULL );
}

DWORD UR6ModMgr::eventIsMissionPack()
{
	struct { DWORD ReturnValue; } Parms;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_IsMissionPack, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

DWORD UR6ModMgr::eventIsRavenShield()
{
	struct { DWORD ReturnValue; } Parms;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(ENGINE_IsRavenShield, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

void UR6ModMgr::eventSetCurrentMod(const FString& ModName, ALevelInfo* LI, DWORD bStartup, UConsole* Console, ULevel* Level)
{
	struct { FString ModName; ALevelInfo* LI; DWORD bStartup; UConsole* Console; ULevel* Level; } Parms;
	Parms.ModName = ModName;
	Parms.LI = LI;
	Parms.bStartup = bStartup;
	Parms.Console = Console;
	Parms.Level = Level;
	ProcessEvent( FindFunctionChecked(ENGINE_SetCurrentMod, 0), &Parms, NULL );
}

/*-----------------------------------------------------------------------------
	Miscellaneous class event thunks.
-----------------------------------------------------------------------------*/

// APhysicsVolume (5)
void APhysicsVolume::eventActorEnteredVolume(AActor* Other) { struct { AActor* Other; } P; P.Other = Other; ProcessEvent( FindFunctionChecked(ENGINE_ActorEnteredVolume, 0), &P, NULL ); }
void APhysicsVolume::eventActorLeavingVolume(AActor* Other) { struct { AActor* Other; } P; P.Other = Other; ProcessEvent( FindFunctionChecked(ENGINE_ActorLeavingVolume, 0), &P, NULL ); }
void APhysicsVolume::eventPawnEnteredVolume(APawn* Other) { struct { APawn* Other; } P; P.Other = Other; ProcessEvent( FindFunctionChecked(ENGINE_PawnEnteredVolume, 0), &P, NULL ); }
void APhysicsVolume::eventPawnLeavingVolume(APawn* Other) { struct { APawn* Other; } P; P.Other = Other; ProcessEvent( FindFunctionChecked(ENGINE_PawnLeavingVolume, 0), &P, NULL ); }
void APhysicsVolume::eventPhysicsChangedFor(AActor* Other) { struct { AActor* Other; } P; P.Other = Other; ProcessEvent( FindFunctionChecked(ENGINE_PhysicsChangedFor, 0), &P, NULL ); }

// AZoneInfo (2)
void AZoneInfo::eventActorEntered(AActor* Other) { struct { AActor* Other; } P; P.Other = Other; ProcessEvent( FindFunctionChecked(ENGINE_ActorEntered, 0), &P, NULL ); }
void AZoneInfo::eventActorLeaving(AActor* Other) { struct { AActor* Other; } P; P.Other = Other; ProcessEvent( FindFunctionChecked(ENGINE_ActorLeaving, 0), &P, NULL ); }

// ALevelInfo (3)
void ALevelInfo::eventServerTravel(const FString& URL, DWORD bItems) { struct { FString URL; DWORD bItems; } P; P.URL = URL; P.bItems = bItems; ProcessEvent( FindFunctionChecked(ENGINE_ServerTravel, 0), &P, NULL ); }
DWORD ALevelInfo::eventGameTypeUseNbOfTerroristToSpawn(const FString& GT) { struct { FString GT; DWORD R; } P; P.GT = GT; P.R = 0; ProcessEvent( FindFunctionChecked(ENGINE_GameTypeUseNbOfTerroristToSpawn, 0), &P, NULL ); return P.R; }
DWORD ALevelInfo::eventIsGameTypePlayWithNonRainbowNPCs(const FString& GT) { struct { FString GT; DWORD R; } P; P.GT = GT; P.R = 0; ProcessEvent( FindFunctionChecked(ENGINE_IsGameTypePlayWithNonRainbowNPCs, 0), &P, NULL ); return P.R; }

// ANavigationPoint (3)
DWORD ANavigationPoint::eventAccept(AActor* Requester, AActor* RequestedDest) { struct { AActor* Requester; AActor* RequestedDest; DWORD R; } P; P.Requester = Requester; P.RequestedDest = RequestedDest; P.R = 0; ProcessEvent( FindFunctionChecked(ENGINE_Accept, 0), &P, NULL ); return P.R; }
INT ANavigationPoint::eventSpecialCost(APawn* Seeker, UReachSpec* Path) { struct { APawn* Seeker; UReachSpec* Path; INT R; } P; P.Seeker = Seeker; P.Path = Path; P.R = 0; ProcessEvent( FindFunctionChecked(ENGINE_SpecialCost, 0), &P, NULL ); return P.R; }
DWORD ANavigationPoint::eventSuggestMovePreparation(APawn* Other) { struct { APawn* Other; DWORD R; } P; P.Other = Other; P.R = 0; ProcessEvent( FindFunctionChecked(ENGINE_SuggestMovePreparation, 0), &P, NULL ); return P.R; }

// AWarpZoneInfo (2)
void AWarpZoneInfo::eventForceGenerate() { ProcessEvent( FindFunctionChecked(ENGINE_ForceGenerate, 0), NULL, NULL ); }
void AWarpZoneInfo::eventGenerate() { ProcessEvent( FindFunctionChecked(ENGINE_Generate, 0), NULL, NULL ); }

// AMover (1)
void AMover::eventKeyFrameReached() { ProcessEvent( FindFunctionChecked(ENGINE_KeyFrameReached, 0), NULL, NULL ); }

// AKConstraint (1)
void AKConstraint::eventKForceExceed(FLOAT Force) { struct { FLOAT Force; } P; P.Force = Force; ProcessEvent( FindFunctionChecked(ENGINE_KForceExceed, 0), &P, NULL ); }

// AProjector (2)
void AProjector::eventLightUpdateDirect(FVector Loc, FLOAT Radius, BYTE Style) { struct { FVector Loc; FLOAT Radius; BYTE Style; } P; P.Loc = Loc; P.Radius = Radius; P.Style = Style; ProcessEvent( FindFunctionChecked(ENGINE_LightUpdateDirect, 0), &P, NULL ); }
void AProjector::eventUpdateShadow() { ProcessEvent( FindFunctionChecked(ENGINE_UpdateShadow, 0), NULL, NULL ); }

// ASceneManager (2)
void ASceneManager::eventSceneEnded() { ProcessEvent( FindFunctionChecked(ENGINE_SceneEnded, 0), NULL, NULL ); }
void ASceneManager::eventSceneStarted() { ProcessEvent( FindFunctionChecked(ENGINE_SceneStarted, 0), NULL, NULL ); }

// AGameReplicationInfo (2)
void AGameReplicationInfo::eventNewServerState() { ProcessEvent( FindFunctionChecked(ENGINE_NewServerState, 0), NULL, NULL ); }
void AGameReplicationInfo::eventSaveRemoteServerSettings(const FString& S) { struct { FString S; } P; P.S = S; ProcessEvent( FindFunctionChecked(ENGINE_SaveRemoteServerSettings, 0), &P, NULL ); }

// ALineOfSightTrigger (1)
void ALineOfSightTrigger::eventPlayerSeesMe(APlayerController* PC) { struct { APlayerController* PC; } P; P.PC = PC; ProcessEvent( FindFunctionChecked(ENGINE_PlayerSeesMe, 0), &P, NULL ); }

// AStatLog (3)
FString AStatLog::eventGetLocalLogFileName() { struct { FString R; } P; ProcessEvent( FindFunctionChecked(ENGINE_GetLocalLogFileName, 0), &P, NULL ); return P.R; }
void AStatLog::eventLogGameSpecial(const FString& S1, const FString& S2) { struct { FString S1; FString S2; } P; P.S1 = S1; P.S2 = S2; ProcessEvent( FindFunctionChecked(ENGINE_LogGameSpecial, 0), &P, NULL ); }
void AStatLog::eventLogGameSpecial2(const FString& S1, const FString& S2, const FString& S3) { struct { FString S1; FString S2; FString S3; } P; P.S1 = S1; P.S2 = S2; P.S3 = S3; ProcessEvent( FindFunctionChecked(ENGINE_LogGameSpecial2, 0), &P, NULL ); }

// UCanvas (1)
void UCanvas::eventReset() { ProcessEvent( FindFunctionChecked(ENGINE_Reset, 0), NULL, NULL ); }

// UAnimNotify_Scripted (1)
void UAnimNotify_Scripted::eventNotify(AActor* Owner) { struct { AActor* Owner; } P; P.Owner = Owner; ProcessEvent( FindFunctionChecked(ENGINE_Notify, 0), &P, NULL ); }

// UMatAction (2)
void UMatAction::eventActionStart(AActor* Other) { struct { AActor* Other; } P; P.Other = Other; ProcessEvent( FindFunctionChecked(ENGINE_ActionStart, 0), &P, NULL ); }
void UMatAction::eventInitialize() { ProcessEvent( FindFunctionChecked(ENGINE_Initialize, 0), NULL, NULL ); }

// UMatSubAction (1)
void UMatSubAction::eventInitialize() { ProcessEvent( FindFunctionChecked(ENGINE_Initialize, 0), NULL, NULL ); }

// UPlayerInput (1)
void UPlayerInput::eventPlayerInput(FLOAT DeltaTime) { struct { FLOAT DeltaTime; } P; P.DeltaTime = DeltaTime; ProcessEvent( FindFunctionChecked(ENGINE_PlayerInput, 0), &P, NULL ); }

// UCheatManager (1)
void UCheatManager::eventLogThis(DWORD LogType, AActor* LogActor) { struct { DWORD LogType; AActor* LogActor; } P; P.LogType = LogType; P.LogActor = LogActor; ProcessEvent( FindFunctionChecked(ENGINE_LogThis, 0), &P, NULL ); }

// UR6AbstractGameManager (1)
void UR6AbstractGameManager::eventGMProcessMsg(const FString& Msg) { struct { FString Msg; } P; P.Msg = Msg; ProcessEvent( FindFunctionChecked(ENGINE_GMProcessMsg, 0), &P, NULL ); }

// UR6MissionDescription (3)
DWORD UR6MissionDescription::eventGetSkins(ALevelInfo*& LI, const FString& S) { struct { ALevelInfo* LI; FString S; DWORD R; } P; P.LI = LI; P.S = S; P.R = 0; ProcessEvent( FindFunctionChecked(ENGINE_GetSkins, 0), &P, NULL ); LI = P.LI; return P.R; }
DWORD UR6MissionDescription::eventInit(ALevelInfo* LI, const FString& S) { struct { ALevelInfo* LI; FString S; DWORD R; } P; P.LI = LI; P.S = S; P.R = 0; ProcessEvent( FindFunctionChecked(ENGINE_Init, 0), &P, NULL ); return P.R; }
void UR6MissionDescription::eventReset() { ProcessEvent( FindFunctionChecked(ENGINE_Reset, 0), NULL, NULL ); }

// UR6ServerInfo (1)
void UR6ServerInfo::eventRestartServer() { ProcessEvent( FindFunctionChecked(ENGINE_RestartServer, 0), NULL, NULL ); }

// AR6eviLTesting (1)
void AR6eviLTesting::eventRunAll() { ProcessEvent( FindFunctionChecked(ENGINE_RunAll, 0), NULL, NULL ); }

// AR6EngineWeapon (7)
void AR6EngineWeapon::eventDeployWeaponBipod(DWORD bDeploy) { struct { DWORD bDeploy; } P; P.bDeploy = bDeploy; ProcessEvent( FindFunctionChecked(ENGINE_DeployWeaponBipod, 0), &P, NULL ); }
DWORD AR6EngineWeapon::eventIsGoggles() { struct { DWORD R; } P; P.R = 0; ProcessEvent( FindFunctionChecked(ENGINE_IsGoggles, 0), &P, NULL ); return P.R; }
void AR6EngineWeapon::eventPawnIsMoving() { ProcessEvent( FindFunctionChecked(ENGINE_PawnIsMoving, 0), NULL, NULL ); }
void AR6EngineWeapon::eventPawnStoppedMoving() { ProcessEvent( FindFunctionChecked(ENGINE_PawnStoppedMoving, 0), NULL, NULL ); }
void AR6EngineWeapon::eventSetIdentifyTarget(DWORD bShow, DWORD bFriendly, const FString& Name) { struct { DWORD bShow; DWORD bFriendly; FString Name; } P; P.bShow = bShow; P.bFriendly = bFriendly; P.Name = Name; ProcessEvent( FindFunctionChecked(ENGINE_SetIdentifyTarget, 0), &P, NULL ); }
void AR6EngineWeapon::eventShowWeaponParticules(BYTE ParticuleType) { struct { BYTE ParticuleType; } P; P.ParticuleType = ParticuleType; ProcessEvent( FindFunctionChecked(ENGINE_ShowWeaponParticules, 0), &P, NULL ); }
void AR6EngineWeapon::eventUpdateWeaponAttachment() { ProcessEvent( FindFunctionChecked(ENGINE_UpdateWeaponAttachment, 0), NULL, NULL ); }

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
