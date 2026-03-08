/*=============================================================================
	R6Engine.cpp: R6Engine package — core R6 game engine classes.
	Reconstructed for Ravenshield decompilation project.

	50 classes, 1126 exports. Pawns, AI controllers, interactive objects,
	deployment zones, doors, ragdolls, climbing, stairs, team management.
=============================================================================*/

#include "R6EnginePrivate.h"

/*-----------------------------------------------------------------------------
	Package.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(R6Engine)

/*-----------------------------------------------------------------------------
	FName event/callback tokens.
-----------------------------------------------------------------------------*/

#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) R6ENGINE_API FName R6ENGINE_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "R6EngineClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

/*-----------------------------------------------------------------------------
	IMPLEMENT_CLASS for all 50 exported classes.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(AMP2IOKarma)
IMPLEMENT_CLASS(AR6AIController)
IMPLEMENT_CLASS(AR6ClimbableObject)
IMPLEMENT_CLASS(AR6ClimbablePoint)
IMPLEMENT_CLASS(AR6CoverSpot)
IMPLEMENT_CLASS(AR6DZoneCircle)
IMPLEMENT_CLASS(AR6DZonePath)
IMPLEMENT_CLASS(AR6DZonePathNode)
IMPLEMENT_CLASS(AR6DZonePoint)
IMPLEMENT_CLASS(AR6DZoneRandomPointNode)
IMPLEMENT_CLASS(AR6DZoneRandomPoints)
IMPLEMENT_CLASS(AR6DZoneRectangle)
IMPLEMENT_CLASS(AR6DeploymentZone)
IMPLEMENT_CLASS(AR6Door)
IMPLEMENT_CLASS(AR6EnvironmentNode)
IMPLEMENT_CLASS(AR6FalseHeartBeat)
IMPLEMENT_CLASS(AR6GameReplicationInfo)
IMPLEMENT_CLASS(AR6GenericHB)
IMPLEMENT_CLASS(AR6Hostage)
IMPLEMENT_CLASS(AR6HostageAI)
IMPLEMENT_CLASS(AR6IActionObject)
IMPLEMENT_CLASS(AR6IOBomb)
IMPLEMENT_CLASS(AR6IOObject)
IMPLEMENT_CLASS(AR6IORotatingDoor)
IMPLEMENT_CLASS(AR6IOSound)
IMPLEMENT_CLASS(AR6InteractiveObject)
IMPLEMENT_CLASS(AR6Ladder)
IMPLEMENT_CLASS(AR6LadderVolume)
IMPLEMENT_CLASS(AR6MatineeHostage)
IMPLEMENT_CLASS(AR6MatineeRainbow)
IMPLEMENT_CLASS(AR6MatineeTerrorist)
IMPLEMENT_CLASS(AR6Pawn)
IMPLEMENT_CLASS(AR6PlayerController)
IMPLEMENT_CLASS(AR6RagDoll)
IMPLEMENT_CLASS(AR6Rainbow)
IMPLEMENT_CLASS(AR6RainbowAI)
IMPLEMENT_CLASS(AR6RainbowTeam)
IMPLEMENT_CLASS(AR6SAHeartBeatJammer)
IMPLEMENT_CLASS(AR6SoundReplicationInfo)
IMPLEMENT_CLASS(AR6StairOrientation)
IMPLEMENT_CLASS(AR6StairVolume)
IMPLEMENT_CLASS(AR6Stairs)
IMPLEMENT_CLASS(AR6TeamMemberReplicationInfo)
IMPLEMENT_CLASS(AR6Terrorist)
IMPLEMENT_CLASS(AR6TerroristAI)
IMPLEMENT_CLASS(UR6MatineeAttach)
IMPLEMENT_CLASS(UR6PlayAnim)
IMPLEMENT_CLASS(UR6SubActionAnimSequence)
IMPLEMENT_CLASS(UR6SubActionLookAt)
IMPLEMENT_CLASS(UR6TerroristMgr)

/*-----------------------------------------------------------------------------
	Native function exports (IMPLEMENT_FUNCTION).
	All dispatched by name (INDEX_NONE / -1).
-----------------------------------------------------------------------------*/

IMPLEMENT_FUNCTION(AMP2IOKarma, -1, execMP2IOKarmaAllNativeFct)
IMPLEMENT_FUNCTION(AR6AIController, -1, execActorReachableFromLocation)
IMPLEMENT_FUNCTION(AR6AIController, -1, execCanWalkTo)
IMPLEMENT_FUNCTION(AR6AIController, -1, execFindGrenadeDirectionToHitActor)
IMPLEMENT_FUNCTION(AR6AIController, -1, execFindInvestigationPoint)
IMPLEMENT_FUNCTION(AR6AIController, -1, execFindNearbyWaitSpot)
IMPLEMENT_FUNCTION(AR6AIController, -1, execFindPlaceToFire)
IMPLEMENT_FUNCTION(AR6AIController, -1, execFindPlaceToTakeCover)
IMPLEMENT_FUNCTION(AR6AIController, -1, execFollowPath)
IMPLEMENT_FUNCTION(AR6AIController, -1, execFollowPathTo)
IMPLEMENT_FUNCTION(AR6AIController, -1, execGotoOpenDoorState)
IMPLEMENT_FUNCTION(AR6AIController, -1, execMakePathToRun)
IMPLEMENT_FUNCTION(AR6AIController, -1, execMoveToPosition)
IMPLEMENT_FUNCTION(AR6AIController, -1, execNeedToOpenDoor)
IMPLEMENT_FUNCTION(AR6AIController, -1, execPickActorAdjust)
IMPLEMENT_FUNCTION(AR6AIController, -1, execPollFollowPath)
IMPLEMENT_FUNCTION(AR6AIController, -1, execPollFollowPathBlocked)
IMPLEMENT_FUNCTION(AR6AIController, -1, execPollMoveToPosition)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execAddHostage)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execFindClosestPointTo)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execFindRandomPointInArea)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execFirstInit)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execGetClosestHostage)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execHaveHostage)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execHaveTerrorist)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execIsPointInZone)
IMPLEMENT_FUNCTION(AR6DeploymentZone, -1, execOrderTerroListFromDistanceTo)
IMPLEMENT_FUNCTION(AR6IORotatingDoor, -1, execAddBreach)
IMPLEMENT_FUNCTION(AR6IORotatingDoor, -1, execRemoveBreach)
IMPLEMENT_FUNCTION(AR6IORotatingDoor, -1, execWillOpenOnTouch)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execAdjustFluidCollisionCylinder)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execCheckCylinderTranslation)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execFootStep)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execGetKillResult)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execGetMaxRotationOffset)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execGetMovementDirection)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execGetPeekingRatioNorm)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execGetRotationOffset)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execGetStunResult)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execGetThroughResult)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execMoveHitBone)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execPawnCanBeHurtFrom)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execPawnLook)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execPawnLookAbsolute)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execPawnLookAt)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execPawnTrackActor)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execPlayVoices)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execR6GetViewRotation)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execSendPlaySound)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execSetAudioInfo)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execSetPawnScale)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execStartLipSynch)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execStopLipSynch)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execToggleHeatProperties)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execToggleNightProperties)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execToggleScopeProperties)
IMPLEMENT_FUNCTION(AR6Pawn, -1, execUpdatePawnTrackActor)
IMPLEMENT_FUNCTION(AR6PlayerController, -1, execDebugFunction)
IMPLEMENT_FUNCTION(AR6PlayerController, -1, execFindPlayer)
IMPLEMENT_FUNCTION(AR6PlayerController, -1, execGetLocStringWithActionKey)
IMPLEMENT_FUNCTION(AR6PlayerController, -1, execLocalizeTraining)
IMPLEMENT_FUNCTION(AR6PlayerController, -1, execPlayVoicesPriority)
IMPLEMENT_FUNCTION(AR6PlayerController, -1, execUpdateCircumstantialAction)
IMPLEMENT_FUNCTION(AR6PlayerController, -1, execUpdateReticule)
IMPLEMENT_FUNCTION(AR6PlayerController, -1, execUpdateSpectatorReticule)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execAClearShotIsAvailable)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execCheckEnvironment)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execClearToSnipe)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execFindSafeSpot)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execGetEntryPosition)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execGetGuardPosition)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execGetLadderPosition)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execGetTargetPosition)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execLookAroundRoom)
IMPLEMENT_FUNCTION(AR6RainbowAI, -1, execSetOrientation)
IMPLEMENT_FUNCTION(AR6SoundReplicationInfo, -1, execPlayLocalWeaponSound)
IMPLEMENT_FUNCTION(AR6SoundReplicationInfo, -1, execPlayWeaponSound)
IMPLEMENT_FUNCTION(AR6SoundReplicationInfo, -1, execStopWeaponSound)
IMPLEMENT_FUNCTION(AR6TerroristAI, -1, execCallBackupForAttack)
IMPLEMENT_FUNCTION(AR6TerroristAI, -1, execCallBackupForInvestigation)
IMPLEMENT_FUNCTION(AR6TerroristAI, -1, execCallVisibleTerrorist)
IMPLEMENT_FUNCTION(AR6TerroristAI, -1, execFindBetterShotLocation)
IMPLEMENT_FUNCTION(AR6TerroristAI, -1, execGetNextRandomNode)
IMPLEMENT_FUNCTION(AR6TerroristAI, -1, execHaveAClearShot)
IMPLEMENT_FUNCTION(AR6TerroristAI, -1, execIsAttackSpotStillValid)
IMPLEMENT_FUNCTION(AR6TerroristAI, -1, execMakeBackupList)
IMPLEMENT_FUNCTION(UR6MatineeAttach, -1, execGetBoneInformation)
IMPLEMENT_FUNCTION(UR6MatineeAttach, -1, execTestLocation)
IMPLEMENT_FUNCTION(UR6TerroristMgr, -1, execFindNearestZoneForHostage)
IMPLEMENT_FUNCTION(UR6TerroristMgr, -1, execInit)

/*-----------------------------------------------------------------------------
	Method stubs.
	Reconstructed from retail .def exports — virtual overrides, events,
	exec functions, and non-virtual exported methods.
-----------------------------------------------------------------------------*/

// --- AMP2IOKarma ---

void AMP2IOKarma::CheckForErrors()
{
}

INT AMP2IOKarma::KMP2DynKarmaInterface(INT, FVector, FRotator, AActor *)
{
	return 0;
}

void AMP2IOKarma::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

void AMP2IOKarma::eventReinitSimulation(INT A)
{
	struct { INT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_ReinitSimulation), &Parms);
}

void AMP2IOKarma::eventStartSimulation(INT A)
{
	struct { INT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_StartSimulation), &Parms);
}

void AMP2IOKarma::eventStopSimulation(INT A)
{
	struct { INT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_StopSimulation), &Parms);
}

void AMP2IOKarma::eventZDRSetDamageState(INT A, FLOAT B, FVector C)
{
	struct { 
		INT A;
		FLOAT B;
		FVector C;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	Parms.C = C;
	ProcessEvent(FindFunctionChecked(R6ENGINE_ZDRSetDamageState), &Parms);
}

void AMP2IOKarma::execMP2IOKarmaAllNativeFct(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

// --- AR6AIController ---

void AR6AIController::AdjustFromWall(FVector, AActor *)
{
}

INT AR6AIController::CanHear(FVector, FLOAT, AActor *, enum ENoiseType, enum EPawnType)
{
	return 0;
}

INT AR6AIController::CanWalkTo(FVector, INT)
{
	return 0;
}

void AR6AIController::ClearActionSpot()
{
}

AR6ActionSpot * AR6AIController::FindNearestActionSpot(FLOAT, FVector, INT (CDECL*)(AR6Pawn *, AR6ActionSpot *, struct STActionSpotCheck &), struct STActionSpotCheck &)
{
	return NULL;
}

void AR6AIController::FollowPath(enum eMovementPace, FName, INT)
{
}

void AR6AIController::GotoOpenDoorState(AActor *)
{
}

INT AR6AIController::HearingCheck(FVector, FVector)
{
	return 0;
}

INT AR6AIController::NeedToOpenDoor(AActor *)
{
	return 0;
}

INT AR6AIController::SetDestinationToNextInCache()
{
	return 0;
}

DWORD AR6AIController::eventCanOpenDoor(AR6IORotatingDoor * A)
{
	struct {
		AR6IORotatingDoor * A;
		DWORD ReturnValue;
	} Parms;
	Parms.ReturnValue = 0;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_CanOpenDoor), &Parms);
	return Parms.ReturnValue;
}

void AR6AIController::eventOpenDoorFailed()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_OpenDoorFailed), NULL);
}

void AR6AIController::eventR6SetMovement(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_R6SetMovement), &Parms);
}

void AR6AIController::execActorReachableFromLocation(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6AIController::execCanWalkTo(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6AIController::execFindGrenadeDirectionToHitActor(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6AIController::execFindInvestigationPoint(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6AIController::execFindNearbyWaitSpot(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6AIController::execFindPlaceToFire(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6AIController::execFindPlaceToTakeCover(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6AIController::execFollowPath(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6AIController::execFollowPathTo(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6AIController::execGotoOpenDoorState(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6AIController::execMakePathToRun(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6AIController::execMoveToPosition(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6AIController::execNeedToOpenDoor(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6AIController::execPickActorAdjust(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6AIController::execPollFollowPath(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6AIController::execPollFollowPathBlocked(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6AIController::execPollMoveToPosition(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

// --- AR6ClimbableObject ---

void AR6ClimbableObject::AddMyMarker(AActor *)
{
}

void AR6ClimbableObject::CheckForErrors()
{
}

void AR6ClimbableObject::PostScriptDestroyed()
{
}

INT AR6ClimbableObject::ShouldTrace(AActor *, DWORD)
{
	return 0;
}

// --- AR6ClimbablePoint ---

void AR6ClimbablePoint::ClearPaths()
{
}

void AR6ClimbablePoint::InitForPathFinding()
{
}

INT AR6ClimbablePoint::ProscribedPathTo(ANavigationPoint *)
{
	return 0;
}

void AR6ClimbablePoint::addReachSpecs(APawn *, INT)
{
}

// --- AR6CoverSpot ---

void AR6CoverSpot::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

// --- AR6DZonePath ---

void AR6DZonePath::CheckForErrors()
{
}

void AR6DZonePath::DeleteANode(AR6DZonePathNode *)
{
}

void AR6DZonePath::DeleteANode(INT)
{
}

FVector AR6DZonePath::FindClosestPointTo(FVector const &)
{
	return FVector(0,0,0);
}

FVector AR6DZonePath::FindRandomPointInArea()
{
	return FVector(0,0,0);
}

FVector AR6DZonePath::FindSpawningPoint(FRotator *, INT *, enum EStance *, INT *)
{
	return FVector(0,0,0);
}

INT AR6DZonePath::IsPointInZone(FVector const &)
{
	return 0;
}

void AR6DZonePath::PostScriptDestroyed()
{
}

void AR6DZonePath::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

void AR6DZonePath::SpawnANewNode(FVector)
{
}

void AR6DZonePath::Spawned()
{
}

// --- AR6DZonePathNode ---

void AR6DZonePathNode::CheckForErrors()
{
}

void AR6DZonePathNode::PostScriptDestroyed()
{
}

void AR6DZonePathNode::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

// --- AR6DZonePoint ---

FVector AR6DZonePoint::FindClosestPointTo(FVector const &)
{
	return FVector(0,0,0);
}

FVector AR6DZonePoint::FindRandomPointInArea()
{
	return FVector(0,0,0);
}

FVector AR6DZonePoint::FindSpawningPoint(FRotator *, INT *, enum EStance *, INT *)
{
	return FVector(0,0,0);
}

INT AR6DZonePoint::IsPointInZone(FVector const &)
{
	return 0;
}

void AR6DZonePoint::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

void AR6DZonePoint::Spawned()
{
}

// --- AR6DZoneRandomPointNode ---

void AR6DZoneRandomPointNode::CheckForErrors()
{
}

void AR6DZoneRandomPointNode::PostScriptDestroyed()
{
}

void AR6DZoneRandomPointNode::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

// --- AR6DZoneRandomPoints ---

void AR6DZoneRandomPoints::CheckForErrors()
{
}

void AR6DZoneRandomPoints::DeleteANode(AR6DZoneRandomPointNode *)
{
}

void AR6DZoneRandomPoints::DeleteANode(INT)
{
}

FVector AR6DZoneRandomPoints::FindClosestPointTo(FVector const &)
{
	return FVector(0,0,0);
}

FVector AR6DZoneRandomPoints::FindRandomPointInArea()
{
	return FVector(0,0,0);
}

FVector AR6DZoneRandomPoints::FindSpawningPoint(FRotator *, INT *, enum EStance *, INT *)
{
	return FVector(0,0,0);
}

void AR6DZoneRandomPoints::FirstInit()
{
}

INT AR6DZoneRandomPoints::GetNbOfTerroristToSpawn()
{
	return 0;
}

INT AR6DZoneRandomPoints::IsPointInZone(FVector const &)
{
	return 0;
}

void AR6DZoneRandomPoints::PostScriptDestroyed()
{
}

void AR6DZoneRandomPoints::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

void AR6DZoneRandomPoints::SpawnANewNode(FVector)
{
}

void AR6DZoneRandomPoints::Spawned()
{
}

// --- AR6DeploymentZone ---

void AR6DeploymentZone::CheckForErrors()
{
}

void AR6DeploymentZone::CheckForErrors(bool)
{
}

FVector AR6DeploymentZone::FindClosestPointTo(FVector const &)
{
	return FVector(0,0,0);
}

FVector AR6DeploymentZone::FindRandomPointInArea()
{
	return FVector(0,0,0);
}

FVector AR6DeploymentZone::FindSpawningPoint(FRotator *, INT *, enum EStance *, INT *)
{
	return FVector(0,0,0);
}

void AR6DeploymentZone::FirstInit()
{
}

INT AR6DeploymentZone::GetNbOfTerroristToSpawn()
{
	return 0;
}

INT AR6DeploymentZone::HaveHostage()
{
	return 0;
}

INT AR6DeploymentZone::HavePlaceForPawnAt(FVector &)
{
	return 0;
}

INT AR6DeploymentZone::HaveTerrorist()
{
	return 0;
}

void AR6DeploymentZone::InitHostageAI(FR6CharTemplate *, AR6Hostage *)
{
}

void AR6DeploymentZone::InitTerroristAI(FR6CharTemplate *, AR6Terrorist *)
{
}

INT AR6DeploymentZone::IsPointInZone(FVector const &)
{
	return 0;
}

void AR6DeploymentZone::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

void AR6DeploymentZone::SpawnAHostage()
{
}

void AR6DeploymentZone::SpawnATerrorist()
{
}

void AR6DeploymentZone::Spawned()
{
}

void AR6DeploymentZone::execAddHostage(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6DeploymentZone::execFindClosestPointTo(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6DeploymentZone::execFindRandomPointInArea(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6DeploymentZone::execFirstInit(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6DeploymentZone::execGetClosestHostage(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6DeploymentZone::execHaveHostage(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6DeploymentZone::execHaveTerrorist(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6DeploymentZone::execIsPointInZone(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6DeploymentZone::execOrderTerroListFromDistanceTo(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

INT AR6DeploymentZone::getChanceFromArrayTemplates(struct FSTTemplate *, INT)
{
	return 0;
}

// --- AR6Door ---

AActor * AR6Door::AssociatedLevelGeometry()
{
	return NULL;
}

void AR6Door::CheckForErrors()
{
}

INT AR6Door::PrunePaths()
{
	return 0;
}

void AR6Door::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

void AR6Door::addReachSpecs(APawn *, INT)
{
}

// --- AR6FalseHeartBeat ---

INT AR6FalseHeartBeat::IsBlockedBy(AActor const *) const
{
	guard(AR6FalseHeartBeat::IsBlockedBy);
	return 0;
	unguard;
}

INT AR6FalseHeartBeat::IsRelevantToPawn(APawn *)
{
	return 0;
}

INT AR6FalseHeartBeat::IsRelevantToPawnHeartBeat(APawn *)
{
	return 0;
}

INT AR6FalseHeartBeat::ShouldTrace(AActor *, DWORD)
{
	return 0;
}

// --- AR6GameReplicationInfo ---

FLOAT AR6GameReplicationInfo::eventGetRoundTime()
{
	struct {
		FLOAT ReturnValue;
	} Parms;
	Parms.ReturnValue = 0.f;
	ProcessEvent(FindFunctionChecked(R6ENGINE_GetRoundTime), &Parms);
	return Parms.ReturnValue;
}

// --- AR6Hostage ---

void AR6Hostage::eventFinishInitialization()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_FinishInitialization), NULL);
}

void AR6Hostage::eventGotoCrouch()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoCrouch), NULL);
}

void AR6Hostage::eventGotoFoetus()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoFoetus), NULL);
}

void AR6Hostage::eventGotoKneel()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoKneel), NULL);
}

void AR6Hostage::eventGotoProne()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoProne), NULL);
}

void AR6Hostage::eventGotoStand()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoStand), NULL);
}

void AR6Hostage::eventSetAnimInfo(INT A)
{
	struct { INT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetAnimInfo), &Parms);
}

// --- AR6IORotatingDoor ---

void AR6IORotatingDoor::AddMyMarker(AActor *)
{
}

INT AR6IORotatingDoor::DoorOpenTowards(FVector)
{
	return 0;
}

INT AR6IORotatingDoor::IsMovingBrush() const
{
	return 0;
}

void AR6IORotatingDoor::PostNetReceive()
{
}

void AR6IORotatingDoor::PostScriptDestroyed()
{
}

void AR6IORotatingDoor::PreNetReceive()
{
}

void AR6IORotatingDoor::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

INT AR6IORotatingDoor::ShouldTrace(AActor *, DWORD)
{
	return 0;
}

INT AR6IORotatingDoor::WillOpenOnTouch(AR6Pawn *)
{
	return 0;
}

void AR6IORotatingDoor::execAddBreach(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6IORotatingDoor::execRemoveBreach(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6IORotatingDoor::execWillOpenOnTouch(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

// --- AR6InteractiveObject ---

void AR6InteractiveObject::CheckForErrors()
{
}

void AR6InteractiveObject::PostNetReceive()
{
}

void AR6InteractiveObject::PostScriptDestroyed()
{
}

void AR6InteractiveObject::PreNetReceive()
{
}

void AR6InteractiveObject::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

INT AR6InteractiveObject::ShouldTrace(AActor *, DWORD)
{
	return 0;
}

void AR6InteractiveObject::eventSetNewDamageState(FLOAT A)
{
	struct { FLOAT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetNewDamageState), &Parms);
}

// --- AR6LadderVolume ---

void AR6LadderVolume::AddMyMarker(AActor *)
{
}

INT AR6LadderVolume::ShouldTrace(AActor *, DWORD)
{
	return 0;
}

void AR6LadderVolume::eventSetPotentialClimber()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetPotentialClimber), NULL);
}

// --- AR6Pawn ---

INT AR6Pawn::AdjustFluidCollisionCylinder(FLOAT, INT)
{
	return 0;
}

FLOAT AR6Pawn::AdjustMaxFluidPeeking(FLOAT, FLOAT)
{
	return 0.f;
}

void AR6Pawn::BeginTouch(AActor *)
{
}

FVector AR6Pawn::CheckForLedges(AActor *, FVector, FVector, FVector, INT &, INT &, FLOAT)
{
	return FVector(0,0,0);
}

INT AR6Pawn::CheckLineOfSight(AActor *, FVector &, INT, AActor *, FVector &, AActor *, FVector &)
{
	return 0;
}

DWORD AR6Pawn::CheckSeePawn(AR6Pawn *, FVector &, INT)
{
	return 0;
}

FLOAT AR6Pawn::ComputeCrouchBlendRate(FLOAT, FLOAT)
{
	return 0.f;
}

void AR6Pawn::Crawl(INT)
{
}

INT AR6Pawn::DirectionHasChanged(FLOAT)
{
	return 0;
}

BYTE AR6Pawn::GetAnimState()
{
	return 0;
}

BYTE AR6Pawn::GetCurrentMaterial()
{
	return 0;
}

void AR6Pawn::GetDefaultHeightAndRadius(FLOAT &, FLOAT &, FLOAT &)
{
}

FVector AR6Pawn::GetFootLocation(AActor *)
{
	return FVector(0,0,0);
}

FVector AR6Pawn::GetHeadLocation(AActor *)
{
	return FVector(0,0,0);
}

FLOAT AR6Pawn::GetMaxFluidPeeking(FLOAT, INT)
{
	return 0.f;
}

FVector AR6Pawn::GetMidSectionLocation(AActor *)
{
	return FVector(0,0,0);
}

enum eMovementDirection AR6Pawn::GetMovementDirection()
{
	return (enum eMovementDirection)0;
}

FLOAT AR6Pawn::GetPeekingRatioNorm(FLOAT)
{
	return 0.f;
}

INT AR6Pawn::GetRotValueCenteredAroundZero(INT)
{
	return 0;
}

FRotator AR6Pawn::GetRotationOffset()
{
	return FRotator(0,0,0);
}

BYTE AR6Pawn::GetSoundGunType(INT)
{
	return 0;
}

BYTE AR6Pawn::GetStatusOtherTeam()
{
	return 0;
}

BYTE AR6Pawn::GetTeamColor()
{
	return 0;
}

FRotator AR6Pawn::GetViewRotation()
{
	return FRotator(0,0,0);
}

INT AR6Pawn::HurtByVolume(AActor *)
{
	return 0;
}

INT AR6Pawn::IsCrawling()
{
	return 0;
}

INT AR6Pawn::IsOverLedge(AActor *, FVector, FLOAT)
{
	return 0;
}

INT AR6Pawn::IsRelevantToPawnHeartBeat(APawn *)
{
	return 0;
}

INT AR6Pawn::IsRelevantToPawnHeatVision(APawn *)
{
	return 0;
}

INT AR6Pawn::IsUsingHeartBeatSensor()
{
	return 0;
}

void AR6Pawn::PawnLook(FRotator, INT, INT)
{
}

void AR6Pawn::PawnLookAbsolute(FRotator, INT, INT)
{
}

void AR6Pawn::PawnLookAt(FVector, INT, INT)
{
}

void AR6Pawn::PawnSetBoneRotation(FName, INT, INT, INT, FLOAT)
{
}

void AR6Pawn::PawnTrackActor(AActor *, INT)
{
}

INT AR6Pawn::PickActorAdjust(AActor *)
{
	return 0;
}

void AR6Pawn::PostNetReceive()
{
}

void AR6Pawn::PreNetReceive()
{
}

DWORD AR6Pawn::R6LineOfSightTo(AActor *, INT)
{
	return 0;
}

DWORD AR6Pawn::R6SeePawn(APawn *, INT)
{
	return 0;
}

void AR6Pawn::ResetColBox()
{
}

INT AR6Pawn::SetAudioInfo()
{
	return 0;
}

void AR6Pawn::SetPawnLookAndAimDirection(FRotator, INT)
{
}

void AR6Pawn::SetPawnLookDirection(FRotator, INT)
{
}

void AR6Pawn::SetPrePivot(FVector)
{
}

void AR6Pawn::TickSpecial(FLOAT)
{
}

void AR6Pawn::UnCrawl(INT)
{
}

void AR6Pawn::UpdateColBox(FVector &, INT, INT, INT)
{
}

FLOAT AR6Pawn::UpdateColBoxPeeking(FLOAT)
{
	return 0.f;
}

void AR6Pawn::UpdateFullPeekingMode(FLOAT)
{
}

void AR6Pawn::UpdateMovementAnimation(FLOAT)
{
}

void AR6Pawn::UpdatePawnTrackActor(INT)
{
}

void AR6Pawn::UpdatePeeking(FLOAT)
{
}

void AR6Pawn::WeaponFollow(INT, FLOAT)
{
}

INT AR6Pawn::WeaponIsAGadget()
{
	return 0;
}

void AR6Pawn::WeaponLock(INT, FLOAT, FLOAT)
{
}

INT AR6Pawn::WeaponShouldFollowHead()
{
	return 0;
}

INT AR6Pawn::actorReachableFromLocation(AActor *, FVector)
{
	return 0;
}

void AR6Pawn::calcVelocity(FVector, FLOAT, FLOAT, FLOAT, INT, INT, INT)
{
}

void AR6Pawn::eventAdjustPawnForDiagonalStrafing()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_AdjustPawnForDiagonalStrafing), NULL);
}

void AR6Pawn::eventEndCrawl()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_EndCrawl), NULL);
}

void AR6Pawn::eventEndOfGrenadeEffect(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_EndOfGrenadeEffect), &Parms);
}

void AR6Pawn::eventEndPeekingMode(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_EndPeekingMode), &Parms);
}

FVector AR6Pawn::eventGetFiringStartPoint()
{
	struct {
		FVector ReturnValue;
	} Parms;
	Parms.ReturnValue = FVector(0,0,0);
	ProcessEvent(FindFunctionChecked(R6ENGINE_GetFiringStartPoint), &Parms);
	return Parms.ReturnValue;
}

FLOAT AR6Pawn::eventGetStanceReticuleModifier()
{
	struct {
		FLOAT ReturnValue;
	} Parms;
	Parms.ReturnValue = 0.f;
	ProcessEvent(FindFunctionChecked(R6ENGINE_GetStanceReticuleModifier), &Parms);
	return Parms.ReturnValue;
}

void AR6Pawn::eventInitBiPodPosture(DWORD A)
{
	struct { DWORD A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_InitBiPodPosture), &Parms);
}

DWORD AR6Pawn::eventIsFullPeekingOver()
{
	struct {
		DWORD ReturnValue;
	} Parms;
	Parms.ReturnValue = 0;
	ProcessEvent(FindFunctionChecked(R6ENGINE_IsFullPeekingOver), &Parms);
	return Parms.ReturnValue;
}

DWORD AR6Pawn::eventIsPeekingLeft()
{
	struct {
		DWORD ReturnValue;
	} Parms;
	Parms.ReturnValue = 0;
	ProcessEvent(FindFunctionChecked(R6ENGINE_IsPeekingLeft), &Parms);
	return Parms.ReturnValue;
}

void AR6Pawn::eventPlayCrouchToProne(DWORD A)
{
	struct { DWORD A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlayCrouchToProne), &Parms);
}

void AR6Pawn::eventPlayFluidPeekingAnim(FLOAT A, FLOAT B, FLOAT C)
{
	struct { 
		FLOAT A;
		FLOAT B;
		FLOAT C;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	Parms.C = C;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlayFluidPeekingAnim), &Parms);
}

void AR6Pawn::eventPlayPeekingAnim(DWORD A)
{
	struct { DWORD A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlayPeekingAnim), &Parms);
}

void AR6Pawn::eventPlayProneToCrouch(DWORD A)
{
	struct { DWORD A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlayProneToCrouch), &Parms);
}

void AR6Pawn::eventPlaySpecialPendingAction(BYTE A, INT B)
{
	struct { 
		BYTE A;
		INT B;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlaySpecialPendingAction), &Parms);
}

void AR6Pawn::eventPlaySurfaceSwitch()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlaySurfaceSwitch), NULL);
}

void AR6Pawn::eventPotentialOpenDoor(AR6Door * A)
{
	struct { AR6Door * A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PotentialOpenDoor), &Parms);
}

void AR6Pawn::eventR6MakeMovementNoise()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_R6MakeMovementNoise), NULL);
}

void AR6Pawn::eventR6ResetLookDirection()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_R6ResetLookDirection), NULL);
}

void AR6Pawn::eventRemovePotentialOpenDoor(AR6Door * A)
{
	struct { AR6Door * A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_RemovePotentialOpenDoor), &Parms);
}

void AR6Pawn::eventResetBipodPosture()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_ResetBipodPosture), NULL);
}

void AR6Pawn::eventResetDiagonalStrafing()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_ResetDiagonalStrafing), NULL);
}

void AR6Pawn::eventSetCrouchBlend(FLOAT A)
{
	struct { FLOAT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetCrouchBlend), &Parms);
}

void AR6Pawn::eventSetPeekingInfo(BYTE A, FLOAT B, DWORD C)
{
	struct { 
		BYTE A;
		FLOAT B;
		DWORD C;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	Parms.C = C;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetPeekingInfo), &Parms);
}

void AR6Pawn::eventSetRotationOffset(INT A, INT B, INT C)
{
	struct { 
		INT A;
		INT B;
		INT C;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	Parms.C = C;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetRotationOffset), &Parms);
}

void AR6Pawn::eventSpawnRagDoll()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_SpawnRagDoll), NULL);
}

void AR6Pawn::eventStartCrawl()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_StartCrawl), NULL);
}

void AR6Pawn::eventStartFluidPeeking()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_StartFluidPeeking), NULL);
}

void AR6Pawn::eventStartFullPeeking()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_StartFullPeeking), NULL);
}

void AR6Pawn::eventTurnToFaceActor(AActor * A)
{
	struct { AActor * A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_TurnToFaceActor), &Parms);
}

void AR6Pawn::eventUpdateBipodPosture()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_UpdateBipodPosture), NULL);
}

void AR6Pawn::execAdjustFluidCollisionCylinder(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execCheckCylinderTranslation(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execFootStep(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execGetKillResult(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execGetMaxRotationOffset(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execGetMovementDirection(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execGetPeekingRatioNorm(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execGetRotationOffset(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execGetStunResult(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execGetThroughResult(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execMoveHitBone(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execPawnCanBeHurtFrom(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execPawnLook(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execPawnLookAbsolute(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execPawnLookAt(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execPawnTrackActor(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execPlayVoices(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execR6GetViewRotation(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execSendPlaySound(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execSetAudioInfo(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execSetPawnScale(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execStartLipSynch(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execStopLipSynch(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execToggleHeatProperties(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execToggleNightProperties(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execToggleScopeProperties(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6Pawn::execUpdatePawnTrackActor(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

INT AR6Pawn::getMaxRotationOffset(INT)
{
	return 0;
}

void AR6Pawn::initCrawlMode(bool)
{
}

void AR6Pawn::m_vExecuteLipsSynch(FLOAT)
{
}

void AR6Pawn::m_vInitNewLipSynch(USound *, USound *)
{
}

INT AR6Pawn::moveToPosition(FVector const &)
{
	return 0;
}

INT AR6Pawn::moveToward(FVector const &, AActor *)
{
	return 0;
}

void AR6Pawn::performPhysics(FLOAT)
{
}

void AR6Pawn::physLadder(FLOAT, INT)
{
}

void AR6Pawn::physicsRotation(FLOAT, FVector)
{
}

// --- AR6PlayerController ---

void AR6PlayerController::Destroy()
{
}

FString AR6PlayerController::GetLocKeyNameByActionKey(TCHAR const *)
{
	return TEXT("");
}

AActor * AR6PlayerController::GetTeamManager()
{
	return NULL;
}

INT AR6PlayerController::PlayPriority(INT)
{
	return 0;
}

void AR6PlayerController::PlayVoicesPriority()
{
}

void AR6PlayerController::PostNetReceive()
{
}

void AR6PlayerController::PreNetReceive()
{
}

AActor * AR6PlayerController::SelectActorForSound(AR6SoundReplicationInfo *)
{
	return NULL;
}

void AR6PlayerController::StopAndRemoveVoices(INT &)
{
}

INT AR6PlayerController::Tick(FLOAT, enum ELevelTick)
{
	return 0;
}

void AR6PlayerController::UpdateCircumstantialAction()
{
}

void AR6PlayerController::UpdateReticule(FLOAT)
{
}

void AR6PlayerController::UpdateReticuleIdentification(AActor *)
{
}

void AR6PlayerController::UpdateSpectatorReticule()
{
}

void AR6PlayerController::eventClientNotifySendMatchResults()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_ClientNotifySendMatchResults), NULL);
}

void AR6PlayerController::eventClientNotifySendStartMatch()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_ClientNotifySendStartMatch), NULL);
}

void AR6PlayerController::eventClientPlayVoices(AR6SoundReplicationInfo * A, USound * B, BYTE C, INT D, DWORD E, FLOAT F)
{
	struct { 
		AR6SoundReplicationInfo * A;
		USound * B;
		BYTE C;
		INT D;
		DWORD E;
		FLOAT F;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	Parms.C = C;
	Parms.D = D;
	Parms.E = E;
	Parms.F = F;
	ProcessEvent(FindFunctionChecked(R6ENGINE_ClientPlayVoices), &Parms);
}

void AR6PlayerController::eventClientUpdateLadderStat(FString const & A, INT B, INT C, FLOAT D)
{
	struct { 
		FString A;
		INT B;
		INT C;
		FLOAT D;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	Parms.C = C;
	Parms.D = D;
	ProcessEvent(FindFunctionChecked(R6ENGINE_ClientUpdateLadderStat), &Parms);
}

void AR6PlayerController::eventClientVoteSessionAbort(FString const & A)
{
	struct { FString A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_ClientVoteSessionAbort), &Parms);
}

FLOAT AR6PlayerController::eventGetZoomMultiplyFactor(FLOAT A)
{
	struct {
		FLOAT A;
		FLOAT ReturnValue;
	} Parms;
	Parms.ReturnValue = 0.f;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_GetZoomMultiplyFactor), &Parms);
	return Parms.ReturnValue;
}

void AR6PlayerController::eventPlayerTeamSelectionReceived()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlayerTeamSelectionReceived), NULL);
}

void AR6PlayerController::eventPostRender(UCanvas * A)
{
	struct { UCanvas * A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PostRender), &Parms);
}

void AR6PlayerController::eventSetCrouchBlend(FLOAT A)
{
	struct { FLOAT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetCrouchBlend), &Parms);
}

void AR6PlayerController::execDebugFunction(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6PlayerController::execFindPlayer(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6PlayerController::execGetLocStringWithActionKey(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6PlayerController::execLocalizeTraining(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6PlayerController::execPlayVoicesPriority(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6PlayerController::execUpdateCircumstantialAction(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6PlayerController::execUpdateReticule(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6PlayerController::execUpdateSpectatorReticule(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

// --- AR6RagDoll ---

void AR6RagDoll::AddImpulseToBone(INT, FVector)
{
}

void AR6RagDoll::AddSpring(INT, INT, FLOAT, FLOAT)
{
}

void AR6RagDoll::ClipParticleToPlane(INT, FVector const &, FVector const &)
{
}

void AR6RagDoll::CollisionDetection()
{
}

void AR6RagDoll::FirstInit(AR6AbstractPawn *)
{
}

void AR6RagDoll::RenderBones(UCanvas *)
{
}

void AR6RagDoll::SatisfyConstraints()
{
}

INT AR6RagDoll::Tick(FLOAT, enum ELevelTick)
{
	return 0;
}

void AR6RagDoll::VerletIntegration(FLOAT)
{
}

// --- AR6Rainbow ---

void AR6Rainbow::UpdateAiming()
{
}

// --- AR6RainbowAI ---

INT AR6RainbowAI::AClearShotIsAvailable(APawn *, FVector)
{
	return 0;
}

INT AR6RainbowAI::ClearToSnipe(FVector, FRotator)
{
	return 0;
}

AActor * AR6RainbowAI::FindSafeSpot()
{
	return NULL;
}

FVector AR6RainbowAI::GetTeamLeftOfDoorPosition(INT, AR6Door *)
{
	return FVector(0,0,0);
}

AActor * AR6RainbowAI::GetTeamManager()
{
	return NULL;
}

FVector AR6RainbowAI::GetTeamRightOfDoorPosition(INT, AR6Door *)
{
	return FVector(0,0,0);
}

void AR6RainbowAI::LookAroundRoom(INT)
{
}

void AR6RainbowAI::UpdateTimers(FLOAT)
{
}

void AR6RainbowAI::checkEnvironment()
{
}

void AR6RainbowAI::eventAttackTimer()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_AttackTimer), NULL);
}

void AR6RainbowAI::eventStopAttack()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_StopAttack), NULL);
}

void AR6RainbowAI::execAClearShotIsAvailable(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6RainbowAI::execCheckEnvironment(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6RainbowAI::execClearToSnipe(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6RainbowAI::execFindSafeSpot(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6RainbowAI::execGetEntryPosition(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6RainbowAI::execGetGuardPosition(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6RainbowAI::execGetLadderPosition(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6RainbowAI::execGetTargetPosition(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6RainbowAI::execLookAroundRoom(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6RainbowAI::execSetOrientation(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

FVector AR6RainbowAI::getEntryPosition()
{
	return FVector(0,0,0);
}

FVector AR6RainbowAI::getGuardPosition()
{
	return FVector(0,0,0);
}

FVector AR6RainbowAI::getLadderPosition()
{
	return FVector(0,0,0);
}

FVector AR6RainbowAI::getPreEntryPosition()
{
	return FVector(0,0,0);
}

FVector AR6RainbowAI::getTargetPosition()
{
	return FVector(0,0,0);
}

void AR6RainbowAI::resetBoneRotation()
{
}

void AR6RainbowAI::setMemberOrientation(enum EPawnOrientation)
{
}

enum ePawnOrientation AR6RainbowAI::updatePawnOrientation()
{
	return (enum ePawnOrientation)0;
}

// --- AR6RainbowTeam ---

void AR6RainbowTeam::eventRequestFormationChange(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_RequestFormationChange), &Parms);
}

void AR6RainbowTeam::eventUpdateTeamFormation(BYTE A)
{
	struct { BYTE A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_UpdateTeamFormation), &Parms);
}

// --- AR6SoundReplicationInfo ---

INT AR6SoundReplicationInfo::IsNetRelevantFor(APlayerController *, AActor *, FVector)
{
	return 0;
}

void AR6SoundReplicationInfo::PlayWeaponSound(enum EWeaponSound, BYTE)
{
}

void AR6SoundReplicationInfo::PostNetReceive()
{
}

void AR6SoundReplicationInfo::PreNetReceive()
{
}

void AR6SoundReplicationInfo::StopWeaponSound()
{
}

void AR6SoundReplicationInfo::TickSpecial(FLOAT)
{
}

void AR6SoundReplicationInfo::execPlayLocalWeaponSound(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6SoundReplicationInfo::execPlayWeaponSound(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6SoundReplicationInfo::execStopWeaponSound(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

// --- AR6StairOrientation ---

void AR6StairOrientation::PostScriptDestroyed()
{
}

void AR6StairOrientation::linkWithStair(AR6StairVolume *)
{
}

// --- AR6StairVolume ---

void AR6StairVolume::AddMyMarker(AActor *)
{
}

void AR6StairVolume::CheckForErrors()
{
}

void AR6StairVolume::PostScriptDestroyed()
{
}

void AR6StairVolume::RenderEditorInfo(FLevelSceneNode *, FRenderInterface *, FDynamicActor *)
{
}

void AR6StairVolume::Spawned()
{
}

// --- AR6TeamMemberReplicationInfo ---

INT AR6TeamMemberReplicationInfo::IsNetRelevantFor(APlayerController *, AActor *, FVector)
{
	return 0;
}

INT AR6TeamMemberReplicationInfo::IsRelevantToTeamMember(APawn *)
{
	return 0;
}

void AR6TeamMemberReplicationInfo::TickSpecial(FLOAT)
{
}

// --- AR6Terrorist ---

void AR6Terrorist::PostNetReceive()
{
}

void AR6Terrorist::PreNetReceive()
{
}

void AR6Terrorist::UpdateAiming(FLOAT)
{
}

void AR6Terrorist::eventFinishInitialization()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_FinishInitialization), NULL);
}

void AR6Terrorist::eventLoopSpecialAnim()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_LoopSpecialAnim), NULL);
}

void AR6Terrorist::eventPlaySpecialAnim()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlaySpecialAnim), NULL);
}

void AR6Terrorist::eventStopSpecialAnim()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_StopSpecialAnim), NULL);
}

// --- AR6TerroristAI ---

INT AR6TerroristAI::CanHear(FVector, FLOAT, AActor *, enum ENoiseType, enum EPawnType)
{
	return 0;
}

INT AR6TerroristAI::HaveAClearShot(FVector, APawn *)
{
	return 0;
}

void AR6TerroristAI::eventGotoPointAndSearch(FVector A, BYTE B, DWORD C, FLOAT D, BYTE E)
{
	struct { 
		FVector A;
		BYTE B;
		DWORD C;
		FLOAT D;
		BYTE E;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	Parms.C = C;
	Parms.D = D;
	Parms.E = E;
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoPointAndSearch), &Parms);
}

void AR6TerroristAI::eventGotoPointToAttack(FVector A, AActor * B)
{
	struct { 
		FVector A;
		AActor * B;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoPointToAttack), &Parms);
}

void AR6TerroristAI::eventGotoStateEngageByThreat(FVector A)
{
	struct { FVector A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_GotoStateEngageByThreat), &Parms);
}

void AR6TerroristAI::execCallBackupForAttack(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6TerroristAI::execCallBackupForInvestigation(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6TerroristAI::execCallVisibleTerrorist(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6TerroristAI::execFindBetterShotLocation(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6TerroristAI::execGetNextRandomNode(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6TerroristAI::execHaveAClearShot(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6TerroristAI::execIsAttackSpotStillValid(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6TerroristAI::execMakeBackupList(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

// --- UR6MatineeAttach ---

void UR6MatineeAttach::execGetBoneInformation(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6MatineeAttach::execTestLocation(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

// --- UR6PlayAnim ---

void UR6PlayAnim::eventAnimFinished()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_AnimFinished), NULL);
}

// --- UR6SubActionAnimSequence ---

FLOAT UR6SubActionAnimSequence::GetAnimDuration(UR6PlayAnim *)
{
	return 0.f;
}

UR6PlayAnim * UR6SubActionAnimSequence::GetAnimation(FLOAT)
{
	return NULL;
}

FLOAT UR6SubActionAnimSequence::GetCurAnimPct(FLOAT)
{
	return 0.f;
}

FString UR6SubActionAnimSequence::GetStatString()
{
	return TEXT("");
}

FLOAT UR6SubActionAnimSequence::GetTotalLength()
{
	return 0.f;
}

INT UR6SubActionAnimSequence::IncrementSequence()
{
	return 0;
}

INT UR6SubActionAnimSequence::IsAnimAtFrame(INT, INT)
{
	return 0;
}

INT UR6SubActionAnimSequence::LaunchSequence()
{
	return 0;
}

FLOAT UR6SubActionAnimSequence::PctToFrameNumber(UR6PlayAnim *, FLOAT)
{
	return 0.f;
}

void UR6SubActionAnimSequence::PreBeginPreview()
{
}

INT UR6SubActionAnimSequence::Update(FLOAT, ASceneManager *)
{
	return 0;
}

INT UR6SubActionAnimSequence::UpdateGame(FLOAT, ASceneManager *)
{
	return 0;
}

void UR6SubActionAnimSequence::eventSequenceChanged()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_SequenceChanged), NULL);
}

void UR6SubActionAnimSequence::eventSequenceFinished()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_SequenceFinished), NULL);
}

// --- UR6SubActionLookAt ---

FString UR6SubActionLookAt::GetStatString()
{
	return TEXT("");
}

INT UR6SubActionLookAt::Update(FLOAT, ASceneManager *)
{
	return 0;
}

// --- UR6TerroristMgr ---

void UR6TerroristMgr::execFindNearestZoneForHostage(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6TerroristMgr::execInit(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

// --- R6Charts ---

R6Charts::R6Charts()
{
}

R6Charts& R6Charts::operator=(R6Charts const &)
{
	return *this;
}

INT R6Charts::BulletGoesThroughCharacter(INT iEnergy, INT iGroup, INT iThreshold, INT iSide)
{
	INT iResult = (INT)(iEnergy - (FLOAT)m_iHumanPenetrationTresholds[iGroup][iThreshold] * m_fHumanSidePenetrationFactors[iGroup][iSide]);
	if( iResult > 5000 )
		iResult = 5000;
	return iResult;
}

stResultTable* R6Charts::GetKillTable(eBodyPart ePart)
{
	// Body parts map to 3 groups: Head, Torso (Chest+Abdomen), Limbs (Legs+Arms).
	// Recovered from Ghidra: switch on eBodyPart returning into m_stKillChart.
	switch (ePart)
	{
	case BP_Head:
		return &m_stKillChart.BodyPartGroup[0];
	case BP_Chest:
	case BP_Abdomen:
		return &m_stKillChart.BodyPartGroup[1];
	case BP_Legs:
	case BP_Arms:
		return &m_stKillChart.BodyPartGroup[2];
	default:
		return NULL;
	}
}

stResultTable* R6Charts::GetStunTable(eBodyPart ePart)
{
	switch (ePart)
	{
	case BP_Head:
		return &m_stStunChart.BodyPartGroup[0];
	case BP_Chest:
	case BP_Abdomen:
		return &m_stStunChart.BodyPartGroup[1];
	case BP_Legs:
	case BP_Arms:
		return &m_stStunChart.BodyPartGroup[2];
	default:
		return NULL;
	}
}

stBodyPart R6Charts::m_stKillChart;
stBodyPart R6Charts::m_stStunChart;
static FLOAT GHumanSidePenetrationFactors[3][2] =
{
	{1.00f, 0.80f},
	{1.00f, 1.25f},
	{1.00f, 1.15f},
};
static INT GHumanPenetrationThresholds[3][3] =
{
	{600, 650, 675},
	{650, 675, 700},
	{450, 600, 650},
};
float (*R6Charts::m_fHumanSidePenetrationFactors)[2] = GHumanSidePenetrationFactors;
int (*R6Charts::m_iHumanPenetrationTresholds)[3] = GHumanPenetrationThresholds;

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
