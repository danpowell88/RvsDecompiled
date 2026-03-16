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

IMPL_TODO("blocked by FUN_1001bc10 (silencer IsA check at 0x1001bc10); piSilencer forced NULL — silencer sounds disabled")
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

	// Get audio subsystem from engine (UEngine + 0x48)
	INT* AudioSub = *(INT**)((BYTE*)g_pEngine + 0x48);
	if (AudioSub == NULL)
		goto Done;

	{
		INT weaponInfo = *(INT*)((BYTE*)this + 0x3b0);

		// TODO: FUN_1001bc10 does IsA class-walk on *(INT*)(weaponInfo + 0x39c)
		// against an unresolved PrivateStaticClass; returns the object ptr if match,
		// else NULL. The result gates silencer echo/suppressed sound playback via
		// vtable[0x19c] check. Forced NULL until the class reference is resolved.
		INT* piSilencer = NULL;

		switch ((INT)WeaponSound) {
		case 2: // Fire sound
			(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
				(AudioSub, this, *(INT*)(weaponInfo + 0x3a0 + (UINT)CurrentWeapon * 4), 2, 0);
			break;

		case 3: // Fire + echo (+ silencer echo if equipped)
		{
			UINT uWeapon = (UINT)CurrentWeapon;
			(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
				(AudioSub, this, *(INT*)(weaponInfo + 0x3a0 + uWeapon * 4), 2, 0);
			(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
				(AudioSub, this, *(INT*)(*(INT*)((BYTE*)this + 0x3b0) + 0x3b0 + uWeapon * 4), 2, 0);
			if (piSilencer != NULL &&
				(*(INT (__thiscall**)(INT*))(*(INT*)piSilencer + 0x19c))(piSilencer) != 0)
			{
				(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
					(AudioSub, this, *(INT*)(*(INT*)((BYTE*)this + 0x3b0) + 0x430 + uWeapon * 4), 2, 0);
			}
			break;
		}

		case 4: // Reload sound
			(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
				(AudioSub, this, *(INT*)(weaponInfo + 0x3c0 + (UINT)CurrentWeapon * 4), 2, 0);
			break;

		case 5: // Fire + suppressed (+ silencer suppressed if equipped)
		{
			UINT uWeapon = (UINT)CurrentWeapon;
			(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
				(AudioSub, this, *(INT*)(weaponInfo + 0x3a0 + uWeapon * 4), 2, 0);
			(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
				(AudioSub, this, *(INT*)(*(INT*)((BYTE*)this + 0x3b0) + 0x3d0 + uWeapon * 4), 2, 0);
			if (piSilencer != NULL &&
				(*(INT (__thiscall**)(INT*))(*(INT*)piSilencer + 0x19c))(piSilencer) != 0)
			{
				(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
					(AudioSub, this, *(INT*)(*(INT*)((BYTE*)this + 0x3b0) + 0x440 + uWeapon * 4), 2, 0);
			}
			break;
		}

		case 6: // Looping fire sound (start)
			if (((BYTE*)this)[0x39c] != 6 && (*(BYTE*)(weaponInfo + 0x398) & 2) == 0)
			{
				UINT uWeapon = (UINT)CurrentWeapon;
				(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
					(AudioSub, this, *(INT*)(weaponInfo + 0x3a0 + uWeapon * 4), 2, 0);
				(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
					(AudioSub, this, *(INT*)(*(INT*)((BYTE*)this + 0x3b0) + 0x3e0 + uWeapon * 4), 2, 0);
				if (piSilencer != NULL &&
					(*(INT (__thiscall**)(INT*))(*(INT*)piSilencer + 0x19c))(piSilencer) != 0)
				{
					(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
						(AudioSub, this, *(INT*)(*(INT*)((BYTE*)this + 0x3b0) + 0x450 + uWeapon * 4), 2, 0);
				}
			}
			break;

		case 7: // Fire + echo + alt-fire
		{
			UINT uWeapon = (UINT)CurrentWeapon;
			(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
				(AudioSub, this, *(INT*)(weaponInfo + 0x3a0 + uWeapon * 4), 2, 0);
			(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
				(AudioSub, this, *(INT*)(*(INT*)((BYTE*)this + 0x3b0) + 0x3b0 + uWeapon * 4), 2, 0);
			(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
				(AudioSub, this, *(INT*)(*(INT*)((BYTE*)this + 0x3b0) + 0x400 + uWeapon * 4), 2, 0);
			break;
		}

		case 8: // Special fire sound
			(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
				(AudioSub, this, *(INT*)(weaponInfo + 0x410 + (UINT)CurrentWeapon * 4), 2, 0);
			break;

		case 9: // Alt-fire sound
			(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
				(AudioSub, this, *(INT*)(weaponInfo + 0x420 + (UINT)CurrentWeapon * 4), 2, 0);
			break;

		case 10: // Stop looping fire / play stop sound
			if (((BYTE*)this)[0x39c] == 6)
			{
				(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
					(AudioSub, this, *(INT*)(weaponInfo + 0x3f0 + (UINT)CurrentWeapon * 4), 2, 0);
				if (piSilencer != NULL &&
					(*(INT (__thiscall**)(INT*))(*(INT*)piSilencer + 0x19c))(piSilencer) != 0)
				{
					(*(void (__thiscall**)(INT*, AActor*, INT, INT, INT))(*(INT*)AudioSub + 0x84))
						(AudioSub, this, *(INT*)(*(INT*)((BYTE*)this + 0x3b0) + 0x460 + (UINT)CurrentWeapon * 4), 2, 0);
				}
			}
			else if ((~(*(DWORD*)(weaponInfo + 0x398) >> 1) & *(DWORD*)((BYTE*)this + 0x3a0) >> 1 & 1) != 0)
			{
				*(DWORD*)((BYTE*)this + 0x3a0) &= 0xfffffffd;
				PlayWeaponSound((enum EWeaponSound)3, CurrentWeapon);
			}
			break;
		}
	}

Done:
	*(DWORD*)((BYTE*)this + 0x3a0) |= 1;
	((BYTE*)this)[0x39c] = (BYTE)WeaponSound;

	unguard;
}

IMPL_TODO("blocked by PrivateStaticClass ref in inline IsA weapon-type check (same FUN_1001bc10 blocker); weapon-class gating skipped")
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
		// TODO: retail does an IsA walk on the object at *(INT*)(weaponInfo + 0x39c),
		// checking against an unresolved PrivateStaticClass. If the class matches and
		// vtable[0x19c]() returns non-zero, the entire weapon sound block is skipped.
		// This gating is omitted until the PrivateStaticClass reference is identified.

		// If current weapon changed and we're in looping fire, stop the loop
		if (GSoundRepInfo_OldCurrentWeapon != ((BYTE*)this)[0x394] &&
			((BYTE*)this)[0x39c] == 6)
		{
			PlayWeaponSound((enum EWeaponSound)10, GSoundRepInfo_OldCurrentWeapon);
		}

		// Decode and process replicated weapon sound byte
		BYTE NewSound = ((BYTE*)this)[0x395];
		if (GSoundRepInfo_OldNewWeaponSound != NewSound &&
			*(INT*)((BYTE*)this + 0x3b0) != 0 &&
			(*(BYTE*)(*(INT*)((BYTE*)this + 0x3b0) + 0x398) & 2) == 0)
		{
			DWORD soundFlags = *(DWORD*)((BYTE*)this + 0x3a0);
			BYTE soundEnum = NewSound & 0xf;

			if ((soundFlags & 1) == 0 && soundEnum != 6)
			{
				// Not yet initialized or non-looping: set state without playing
				*(DWORD*)((BYTE*)this + 0x3a0) = soundFlags | 1;
				((BYTE*)this)[0x39c] = soundEnum;
			}
			else
			{
				// Update fire flag (bit 1) from NewSound bit 4, then play
				*(DWORD*)((BYTE*)this + 0x3a0) = ((NewSound >> 3 ^ soundFlags) & 2) ^ soundFlags;
				PlayWeaponSound((enum EWeaponSound)soundEnum, ((BYTE*)this)[0x394]);
			}
		}
	}

	// Sync replicated location to actual Location
	if (GSoundRepInfo_OldLocation.X != *(FLOAT*)((BYTE*)this + 0x3b4) ||
		GSoundRepInfo_OldLocation.Y != *(FLOAT*)((BYTE*)this + 0x3b8) ||
		GSoundRepInfo_OldLocation.Z != *(FLOAT*)((BYTE*)this + 0x3bc))
	{
		*(FLOAT*)((BYTE*)this + 0x234) = *(FLOAT*)((BYTE*)this + 0x3b4);
		*(FLOAT*)((BYTE*)this + 0x238) = *(FLOAT*)((BYTE*)this + 0x3b8);
		*(FLOAT*)((BYTE*)this + 0x23c) = *(FLOAT*)((BYTE*)this + 0x3bc);

		// Update physics position via Level vtable[0x9c/4] (FarMoveActor-like call)
		(*(void (__thiscall**)(void*, AActor*, INT, INT, INT, INT, INT, INT, INT))
			(*(INT*)*(void**)((BYTE*)this + 0x328) + 0x9c))
			(*(void**)((BYTE*)this + 0x328), this,
			 *(INT*)((BYTE*)this + 0x3b4),
			 *(INT*)((BYTE*)this + 0x3b8),
			 *(INT*)((BYTE*)this + 0x3bc),
			 0, 0, 0, 0);
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
