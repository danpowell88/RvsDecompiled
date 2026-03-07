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
