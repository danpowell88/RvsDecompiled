/*=============================================================================
	R6Replication.cpp
	AR6GameReplicationInfo, AR6SoundReplicationInfo,
	AR6TeamMemberReplicationInfo — network replication info actors.
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6GameReplicationInfo)
IMPLEMENT_CLASS(AR6SoundReplicationInfo)
IMPLEMENT_CLASS(AR6TeamMemberReplicationInfo)

IMPLEMENT_FUNCTION(AR6SoundReplicationInfo, -1, execPlayLocalWeaponSound)
IMPLEMENT_FUNCTION(AR6SoundReplicationInfo, -1, execPlayWeaponSound)
IMPLEMENT_FUNCTION(AR6SoundReplicationInfo, -1, execStopWeaponSound)

// Statics used by AR6SoundReplicationInfo PreNetReceive/PostNetReceive.
static BYTE GSoundRepInfo_OldCurrentWeapon;
static BYTE GSoundRepInfo_OldNewWeaponSound;
static BYTE GSoundRepInfo_OldNewPawnState;
static FVector GSoundRepInfo_OldLocation;

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

// --- AR6SoundReplicationInfo ---

INT AR6SoundReplicationInfo::IsNetRelevantFor(APlayerController* Viewer, AActor*, FVector)
{
	// Get the viewer's relevant actor (pawn if available, otherwise the controller itself)
	AZoneInfo* ViewZone;
	if (Viewer->Pawn != NULL)
		ViewZone = Viewer->Pawn->Region.Zone;
	else
		ViewZone = Viewer->Region.Zone;

	// Zone team indices (script-defined byte at AZoneInfo + 0x397)
	BYTE MyTeam = *((BYTE*)Region.Zone + 0x397);
	BYTE ViewTeam = *((BYTE*)ViewZone + 0x397);

	if (MyTeam != ViewTeam)
	{
		// Check zone visibility table in level info (64-bit bitmask at ALevelInfo + 0x650)
		DWORD ViewBit = 1u << (ViewTeam & 0x1f);
		BYTE* LevelBase = (BYTE*)Level;
		if ((ViewBit & *(DWORD*)(LevelBase + 0x650 + MyTeam * 8)) == 0 &&
			(((INT)ViewBit >> 0x1f) & *(DWORD*)(LevelBase + 0x654 + MyTeam * 8)) == 0)
		{
			return 0;
		}
	}

	return 1;
}

void AR6SoundReplicationInfo::PlayWeaponSound(enum EWeaponSound, BYTE)
{
}

void AR6SoundReplicationInfo::PostNetReceive()
{
}

void AR6SoundReplicationInfo::PreNetReceive()
{
	guard(AR6SoundReplicationInfo::PreNetReceive);
	AActor::PreNetReceive();
	GSoundRepInfo_OldNewPawnState = m_NewPawnState;
	GSoundRepInfo_OldLocation.X = m_Location.X;
	GSoundRepInfo_OldNewWeaponSound = m_NewWeaponSound;
	GSoundRepInfo_OldLocation.Y = m_Location.Y;
	GSoundRepInfo_OldLocation.Z = m_Location.Z;
	GSoundRepInfo_OldCurrentWeapon = m_CurrentWeapon;
	unguard;
}

void AR6SoundReplicationInfo::StopWeaponSound()
{
	guard(AR6SoundReplicationInfo::StopWeaponSound);

	if (m_PawnRepInfo)
	{
		// Set bit 0x2 on PawnRepInfo bitfield at offset 0x398
		*(DWORD*)((BYTE*)m_PawnRepInfo + 0x398) |= 2;

		if (m_LastPlayedWeaponSound == 6)
		{
			PlayWeaponSound((enum EWeaponSound)10, m_CurrentWeapon);
		}
	}

	unguard;
}

void AR6SoundReplicationInfo::TickSpecial(FLOAT DeltaTime)
{
	guard(AR6SoundReplicationInfo::TickSpecial);

	AActor::TickSpecial(DeltaTime);

	if (m_pawnOwner)
	{
		// Sync our location and region from the owning pawn
		Location = m_pawnOwner->Location;
		Region = m_pawnOwner->Region;

		// On the server in network games, periodically replicate location changes
		// ALevelInfo::NetMode at offset 0x425 (auto-generated field, not in our header)
		BYTE NetMode = ((BYTE*)Level)[0x425];
		if (Role == ROLE_Authority && NetMode != 0)
		{
			m_fClientLastUpdate += DeltaTime;
			if (m_fClientUpdateFrequency < m_fClientLastUpdate)
			{
				m_Location = m_pawnOwner->Location;
				m_fClientLastUpdate = 0.f;
				bNetDirty = 1;
			}
		}
	}

	unguard;
}

void AR6SoundReplicationInfo::execPlayLocalWeaponSound(FFrame& Stack, RESULT_DECL)
{
	P_GET_BYTE(EWeaponSound);
	P_FINISH;
	PlayWeaponSound((enum EWeaponSound)EWeaponSound, m_CurrentWeapon);
}

void AR6SoundReplicationInfo::execPlayWeaponSound(FFrame& Stack, RESULT_DECL)
{
	P_GET_BYTE(EWeaponSound);
	P_FINISH;
	PlayWeaponSound((enum EWeaponSound)EWeaponSound, m_CurrentWeapon);
}

void AR6SoundReplicationInfo::execStopWeaponSound(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	StopWeaponSound();
}

// --- AR6TeamMemberReplicationInfo ---

INT AR6TeamMemberReplicationInfo::IsNetRelevantFor(APlayerController* Viewer, AActor*, FVector)
{
	guard(AR6TeamMemberReplicationInfo::IsNetRelevantFor);

	// Check viewer's pawn directly
	APawn* ViewPawn = Viewer->Pawn;
	if (ViewPawn != NULL)
		return IsRelevantToTeamMember(ViewPawn);

	// Fallback: check cached view target in APlayerController hidden native data
	// APlayerController+0x5B8 holds a ViewTarget actor pointer
	AActor* ViewTarget = *(AActor**)((BYTE*)Viewer + 0x5B8);
	if (ViewTarget != NULL)
	{
		// Original calls vtable[0x68/4] which returns APawn* (GetPlayerPawn)
		ViewPawn = ViewTarget->GetPlayerPawn();
		if (ViewPawn != NULL)
			return IsRelevantToTeamMember(ViewPawn);
	}

	return 0;

	unguard;
}

INT AR6TeamMemberReplicationInfo::IsRelevantToTeamMember(APawn* Other)
{
	guard(AR6TeamMemberReplicationInfo::IsRelevantToTeamMember);
	if (Other && Other->Controller)
		return Instigator->IsFriend(Other) ? 1 : 0;
	return 0;
	unguard;
}

void AR6TeamMemberReplicationInfo::TickSpecial(FLOAT DeltaTime)
{
	AActor::TickSpecial(DeltaTime);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
