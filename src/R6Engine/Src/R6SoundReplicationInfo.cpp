/*=============================================================================
	R6SoundReplicationInfo.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

// External engine globals
extern ENGINE_API UEngine* g_pEngine;

IMPLEMENT_CLASS(AR6SoundReplicationInfo)

IMPLEMENT_FUNCTION(AR6SoundReplicationInfo, -1, execPlayLocalWeaponSound)
IMPLEMENT_FUNCTION(AR6SoundReplicationInfo, -1, execPlayWeaponSound)
IMPLEMENT_FUNCTION(AR6SoundReplicationInfo, -1, execStopWeaponSound)

// Statics used by AR6SoundReplicationInfo PreNetReceive/PostNetReceive.
static BYTE GSoundRepInfo_OldCurrentWeapon;
static BYTE GSoundRepInfo_OldNewWeaponSound;
static BYTE GSoundRepInfo_OldNewPawnState;
static FVector GSoundRepInfo_OldLocation;

// --- AR6SoundReplicationInfo ---

IMPL_MATCH("R6Engine.dll", 0x1003a5c0)
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

IMPL_DIVERGE("audio dispatch via vtable (AudioSub+0x84) and per-case sound refs (weapon info offsets 0x3a0..0x460) not reconstructed; AudioSub object layout not fully mapped")
void AR6SoundReplicationInfo::PlayWeaponSound(enum EWeaponSound WeaponSound, BYTE CurrentWeapon)
{
	guard(AR6SoundReplicationInfo::PlayWeaponSound);

	// Show weapon particules on the pawn's weapon
	if (*(INT*)((BYTE*)this + 0x3ac) != 0)
	{
		AR6EngineWeapon* Weapon = *(AR6EngineWeapon**)(*(INT*)((BYTE*)this + 0x3ac) + 0x4fc);
		if (Weapon != NULL)
			Weapon->eventShowWeaponParticules((BYTE)WeaponSound);
	}

	// Need a weapon info reference
	if (*(INT*)((BYTE*)this + 0x3b0) == 0)
		return;

	// If currently playing looping fire sound, stop it first before new sound
	if (((BYTE*)this)[0x39c] == 6 && (INT)WeaponSound != 10)
		PlayWeaponSound((enum EWeaponSound)10, CurrentWeapon);

	// Get audio subsystem from engine
	INT* AudioSub = *(INT**)(*(INT*)((BYTE*)g_pEngine) + 0x48);
	if (AudioSub == NULL)
		goto Done;

	// DIVERGENCE: audio dispatch via vtable call (*(code**)(*AudioSub + 0x84)) not
	// reconstructed — the AudioSub object layout is not fully mapped. The sound
	// references at weapon info offsets (0x3a0..0x460) and the per-case logic below
	// are documented but the actual play calls are omitted:
	//   case 2: fire sound
	//   case 3: fire + echo (+ silencer echo if equipped)
	//   case 4: reload sound
	//   case 5: fire + suppressed (+ silencer suppressed if equipped)
	//   case 6: looping fire sound (start)
	//   case 7: fire + echo + alt-fire sound
	//   case 8/9: special fire / alt-fire sound
	//   case 10: stop looping fire, play stop sound

Done:
	*(DWORD*)((BYTE*)this + 0x3a0) |= 1;
	((BYTE*)this)[0x39c] = (BYTE)WeaponSound;

	unguard;
}

IMPL_DIVERGE("retail checks weapon owner via IsA; decodes m_NewWeaponSound (low nibble = sound enum, bit 4 = fire flag); AudioSub vtable dispatch not reconstructed")
void AR6SoundReplicationInfo::PostNetReceive()
{
	guard(AR6SoundReplicationInfo::PostNetReceive);

	AActor::PostNetReceive();

	// Decode packed pawn state byte: low nibble = weapon state, high nibble = stance
	BYTE NewPawnStateByte = ((BYTE*)this)[0x396];
	if (GSoundRepInfo_OldNewPawnState != NewPawnStateByte)
	{
		((BYTE*)this)[0x398] = NewPawnStateByte & 0xf;
		((BYTE*)this)[0x39a] = NewPawnStateByte >> 4;
	}

	// Process weapon sound changes
	if (*(INT*)((BYTE*)this + 0x3b0) != 0)
	{
		// DIVERGENCE: retail checks weapon owner via IsA on class hierarchy,
		// decodes m_NewWeaponSound byte (low nibble = sound enum, bit 4 = fire flag),
		// and calls PlayWeaponSound if not already playing. AudioSub vtable layout
		// not fully reconstructed — sound dispatch omitted for PostNetReceive path.
	}

	// Sync replicated location to actual Location
	if (GSoundRepInfo_OldLocation.X != *(FLOAT*)((BYTE*)this + 0x3b4) ||
		GSoundRepInfo_OldLocation.Y != *(FLOAT*)((BYTE*)this + 0x3b8) ||
		GSoundRepInfo_OldLocation.Z != *(FLOAT*)((BYTE*)this + 0x3bc))
	{
		*(FLOAT*)((BYTE*)this + 0x234) = *(FLOAT*)((BYTE*)this + 0x3b4);
		*(FLOAT*)((BYTE*)this + 0x238) = *(FLOAT*)((BYTE*)this + 0x3b8);
		*(FLOAT*)((BYTE*)this + 0x23c) = *(FLOAT*)((BYTE*)this + 0x3bc);
	}

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1003a3d0)
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

IMPL_MATCH("R6Engine.dll", 0x1003ad90)
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

IMPL_MATCH("R6Engine.dll", 0x1003a490)
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

IMPL_MATCH("R6Engine.dll", 0x1003ae30)
void AR6SoundReplicationInfo::execPlayLocalWeaponSound(FFrame& Stack, RESULT_DECL)
{
	P_GET_BYTE(EWeaponSound);
	P_FINISH;
	PlayWeaponSound((enum EWeaponSound)EWeaponSound, m_CurrentWeapon);
}

IMPL_MATCH("R6Engine.dll", 0x1003ac50)
void AR6SoundReplicationInfo::execPlayWeaponSound(FFrame& Stack, RESULT_DECL)
{
	P_GET_BYTE(EWeaponSound);
	P_FINISH;
	PlayWeaponSound((enum EWeaponSound)EWeaponSound, m_CurrentWeapon);
}

IMPL_MATCH("R6Engine.dll", 0x1003af00)
void AR6SoundReplicationInfo::execStopWeaponSound(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	StopWeaponSound();
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
