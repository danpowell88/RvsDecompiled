/*=============================================================================
	UnPawn.cpp: APawn, AController, APlayerController, AAIController stubs.
=============================================================================*/
#include "EnginePrivate.h"

IMPLEMENT_CLASS(APawn);
IMPLEMENT_CLASS(AController);
IMPLEMENT_CLASS(APlayerController);
IMPLEMENT_CLASS(AAIController);

#define EXEC_STUB(cls,func) void cls::func( FFrame& Stack, RESULT_DECL ) { P_FINISH; }

EXEC_STUB(APawn,execReachedDestination)        IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execReachedDestination );
EXEC_STUB(APawn,execIsFriend)                  IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execIsFriend );
EXEC_STUB(APawn,execIsEnemy)                   IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execIsEnemy );
EXEC_STUB(APawn,execIsNeutral)                 IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execIsNeutral );
EXEC_STUB(APawn,execIsAlive)                   IMPLEMENT_FUNCTION( APawn, INDEX_NONE, execIsAlive );
EXEC_STUB(AController,execMoveTo)              IMPLEMENT_FUNCTION( AController, 500, execMoveTo );
EXEC_STUB(AController,execPollMoveTo)          IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollMoveTo );
EXEC_STUB(AController,execMoveToward)          IMPLEMENT_FUNCTION( AController, 502, execMoveToward );
EXEC_STUB(AController,execPollMoveToward)      IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollMoveToward );
EXEC_STUB(AController,execFinishRotation)      IMPLEMENT_FUNCTION( AController, 508, execFinishRotation );
EXEC_STUB(AController,execPollFinishRotation)  IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollFinishRotation );
EXEC_STUB(AController,execWaitForLanding)      IMPLEMENT_FUNCTION( AController, 527, execWaitForLanding );
EXEC_STUB(AController,execPollWaitForLanding)  IMPLEMENT_FUNCTION( AController, INDEX_NONE, execPollWaitForLanding );
EXEC_STUB(AController,execLineOfSightTo)       IMPLEMENT_FUNCTION( AController, 514, execLineOfSightTo );
EXEC_STUB(AController,execCanSee)              IMPLEMENT_FUNCTION( AController, INDEX_NONE, execCanSee );
EXEC_STUB(AController,execFindPathToward)      IMPLEMENT_FUNCTION( AController, 517, execFindPathToward );
EXEC_STUB(AController,execFindPathTowardNearest) IMPLEMENT_FUNCTION( AController, INDEX_NONE, execFindPathTowardNearest );
EXEC_STUB(AController,execFindPathTo)          IMPLEMENT_FUNCTION( AController, 518, execFindPathTo );
EXEC_STUB(AController,execactorReachable)      IMPLEMENT_FUNCTION( AController, 520, execactorReachable );
EXEC_STUB(AController,execpointReachable)      IMPLEMENT_FUNCTION( AController, 521, execpointReachable );
EXEC_STUB(AController,execClearPaths)          IMPLEMENT_FUNCTION( AController, 522, execClearPaths );
EXEC_STUB(AController,execEAdjustJump)         IMPLEMENT_FUNCTION( AController, 523, execEAdjustJump );
EXEC_STUB(AController,execFindRandomDest)      IMPLEMENT_FUNCTION( AController, 525, execFindRandomDest );
EXEC_STUB(AController,execPickWallAdjust)      IMPLEMENT_FUNCTION( AController, 526, execPickWallAdjust );
EXEC_STUB(AController,execAddController)       IMPLEMENT_FUNCTION( AController, 529, execAddController );
EXEC_STUB(AController,execRemoveController)    IMPLEMENT_FUNCTION( AController, 530, execRemoveController );
EXEC_STUB(AController,execPickTarget)          IMPLEMENT_FUNCTION( AController, 531, execPickTarget );
EXEC_STUB(AController,execPickAnyTarget)       IMPLEMENT_FUNCTION( AController, 534, execPickAnyTarget );
EXEC_STUB(AController,execFindBestInventoryPath) IMPLEMENT_FUNCTION( AController, 540, execFindBestInventoryPath );
EXEC_STUB(AController,execEndClimbLadder)      IMPLEMENT_FUNCTION( AController, INDEX_NONE, execEndClimbLadder );
EXEC_STUB(AController,execInLatentExecution)   IMPLEMENT_FUNCTION( AController, INDEX_NONE, execInLatentExecution );
EXEC_STUB(AController,execStopWaiting)         IMPLEMENT_FUNCTION( AController, INDEX_NONE, execStopWaiting );
EXEC_STUB(APlayerController,execFindStairRotation) IMPLEMENT_FUNCTION( APlayerController, 524, execFindStairRotation );
EXEC_STUB(APlayerController,execResetKeyboard)     IMPLEMENT_FUNCTION( APlayerController, 544, execResetKeyboard );
EXEC_STUB(APlayerController,execUpdateURL)         IMPLEMENT_FUNCTION( APlayerController, 546, execUpdateURL );
EXEC_STUB(APlayerController,execConsoleCommand)    IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execConsoleCommand );
EXEC_STUB(APlayerController,execGetDefaultURL)     IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetDefaultURL );
EXEC_STUB(APlayerController,execGetEntryLevel)     IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetEntryLevel );
EXEC_STUB(APlayerController,execSetViewTarget)     IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execSetViewTarget );
EXEC_STUB(APlayerController,execClientTravel)      IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execClientTravel );
EXEC_STUB(APlayerController,execClientHearSound)   IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execClientHearSound );
EXEC_STUB(APlayerController,execGetPlayerNetworkAddress) IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetPlayerNetworkAddress );
EXEC_STUB(APlayerController,execCopyToClipboard)   IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execCopyToClipboard );
EXEC_STUB(APlayerController,execPasteFromClipboard) IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execPasteFromClipboard );
EXEC_STUB(APlayerController,execSpecialDestroy)    IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execSpecialDestroy );
EXEC_STUB(APlayerController,execPB_CanPlayerSpawn) IMPLEMENT_FUNCTION( APlayerController, 1320, execPB_CanPlayerSpawn );
EXEC_STUB(APlayerController,execGetPBConnectStatus) IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execGetPBConnectStatus );
EXEC_STUB(APlayerController,execIsPBEnabled)       IMPLEMENT_FUNCTION( APlayerController, INDEX_NONE, execIsPBEnabled );
EXEC_STUB(APlayerController,execGetKey)            IMPLEMENT_FUNCTION( APlayerController, 2706, execGetKey );
EXEC_STUB(APlayerController,execGetActionKey)      IMPLEMENT_FUNCTION( APlayerController, 2707, execGetActionKey );
EXEC_STUB(APlayerController,execGetEnumName)       IMPLEMENT_FUNCTION( APlayerController, 2708, execGetEnumName );
EXEC_STUB(APlayerController,execChangeInputSet)    IMPLEMENT_FUNCTION( APlayerController, 2709, execChangeInputSet );
EXEC_STUB(APlayerController,execSetKey)            IMPLEMENT_FUNCTION( APlayerController, 2710, execSetKey );
EXEC_STUB(APlayerController,execSetSoundOptions)   IMPLEMENT_FUNCTION( APlayerController, 2713, execSetSoundOptions );
EXEC_STUB(APlayerController,execChangeVolumeTypeLinear) IMPLEMENT_FUNCTION( APlayerController, 2714, execChangeVolumeTypeLinear );
EXEC_STUB(AAIController,execWaitToSeeEnemy)        IMPLEMENT_FUNCTION( AAIController, INDEX_NONE, execWaitToSeeEnemy );
EXEC_STUB(AAIController,execPollWaitToSeeEnemy)    IMPLEMENT_FUNCTION( AAIController, INDEX_NONE, execPollWaitToSeeEnemy );

#undef EXEC_STUB
