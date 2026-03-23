/*=============================================================================
	R6Weapons.cpp: R6Weapons package init and AR6Weapons base class.
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "R6WeaponsPrivate.h"

/*-----------------------------------------------------------------------------
	Package.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(R6Weapons)

/*-----------------------------------------------------------------------------
	Pre/PostNetReceive delta-detection globals.
	DAT_1000cb08 / DAT_1000cb10 / DAT_1000cb14 in the retail binary.
	Shared with AR6DemolitionsGadget::PreNetReceive/PostNetReceive.
-----------------------------------------------------------------------------*/
DWORD g_net_old_nbBullets = 0;
DWORD g_net_old_bit6      = 0;
DWORD g_net_old_bit7      = 0;

/*-----------------------------------------------------------------------------
	FName event/callback tokens.
-----------------------------------------------------------------------------*/

#define NAMES_ONLY
#undef  AUTOGENERATE_NAME
#undef  AUTOGENERATE_FUNCTION
#define AUTOGENERATE_NAME(name) R6WEAPONS_API FName R6WEAPONS_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "R6WeaponsClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

/*-----------------------------------------------------------------------------
	AR6Weapons — base weapon class.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(AR6Weapons)

IMPL_MATCH("R6Weapons.dll", 0x10003f40)
void AR6Weapons::ProcessState(FLOAT DeltaTime)
{
	Super::ProcessState(DeltaTime);
}

IMPL_MATCH("R6Weapons.dll", 0x10003c30)
INT AR6Weapons::IsBlockedBy(AActor const* Other) const
{
	// Ghidra 0x3c30: if Other has bTrailerSameRotation (bit 17 of flags DWORD at +0xa8), don't block.
	// DIVERGENCE: bTrailerSameRotation is the reconstructed name for 0xa8 & 0x20000 in this engine layout;
	// the actual R6 usage is as a "pass-through" collision flag.
	if (Other->bTrailerSameRotation)
		return 0;
	return Super::IsBlockedBy(Other);
}

IMPL_MATCH("R6Weapons.dll", 0x10003bb0)
void AR6Weapons::PreNetReceive()
{
	Super::PreNetReceive();
	// Snapshot bullet-count byte for PostNetReceive change-detection (Ghidra: DAT_1000cb08 = this[0x396]).
	g_net_old_nbBullets = *(BYTE*)((BYTE*)this + 0x396);
}

IMPL_MATCH("R6Weapons.dll", 0x10004c30)
void AR6Weapons::PostNetReceive()
{
	Super::PostNetReceive();

	// Fire HideAttachment event when bullet count transitions to zero.
	BYTE curNbBullets = *(BYTE*)((BYTE*)this + 0x396);
	if (g_net_old_nbBullets != curNbBullets && curNbBullets == 0)
		eventHideAttachment();

	// Bipod deploy sync: detect change in the bipod state bits and propagate.
	// Ghidra 0x4c30: reads bitfield DWORD at this+0x3a0, checks if bits 1 and 2 differ,
	// then conditionally toggles bit 3 and fires eventDeployWeaponBipod.
	// DIVERGENCE: raw bit arithmetic preserved from Ghidra; field names at 0x3a0 unknown.
	DWORD uFlags = *(DWORD*)((BYTE*)this + 0x3a0);
	if (((uFlags >> 1 ^ uFlags) & 4) != 0)
	{
		uFlags = (uFlags * 2 ^ uFlags) & 8 ^ uFlags;
		*(DWORD*)((BYTE*)this + 0x3a0) = uFlags;
		AR6EngineWeapon::eventDeployWeaponBipod((uFlags >> 3) & 1);
	}
}

IMPL_MATCH("R6Weapons.dll", 0x10004030)
void AR6Weapons::TickAuthoritative(FLOAT DeltaTime)
{
	Super::TickAuthoritative(DeltaTime);
}

IMPL_MATCH("R6Weapons.dll", 0x10001310)
INT AR6Weapons::GetHeartBeatStatus()
{
	return 0;
}

IMPL_MATCH("R6Weapons.dll", 0x10004320)
void AR6Weapons::ShowWeaponParticles(AR6Pawn* param_1, AR6PlayerController* param_2)
{
	guard(AR6Weapons::ShowWeaponParticles);

	// vtable[0x22] (byte offset 0x88) on a particle emitter: activate/trigger
	typedef void (__thiscall* PFNTRIGGER)(void*, INT);

	if (*(INT*)((BYTE*)this + 0x398) < 1)   // pending particle count < 1
	{
		// No shots pending — hide the muzzle-flash emitter
		INT sfx = *(INT*)((BYTE*)this + 0x5a0);                       // AR6SFX at this+0x5a0
		if (sfx != 0 && *(INT*)(sfx + 0x39c) != 0)
		{
			*(BYTE*)(sfx + 0x36)  = 0;                                // bHidden = false
			*(DWORD*)(sfx + 0xa0) &= 0xfffffeff;                      // clear bit 8
		}
	}
	else
	{
		INT archetype = *(INT*)((BYTE*)this + 0x144);                  // weapon archetype ptr
		if (*(FLOAT*)((BYTE*)this + 0x3a4) <= *(FLOAT*)(archetype + 0x45c))
		{
			FLOAT fireInterval = *(FLOAT*)(archetype + 0x45c);         // fire interval
			*(INT*)((BYTE*)this + 0x398) -= 1;                         // --pendingParticleCount
			*(FLOAT*)((BYTE*)this + 0x3a4) = *(FLOAT*)((BYTE*)this + 0x58c) + fireInterval;

			if (*(BYTE*)(archetype + 0x425) == 3)                      // fire mode == burst (3)
			{
				DWORD uFlags = *(DWORD*)((BYTE*)this + 0x3a0);
				*(DWORD*)((BYTE*)this + 0x3a0) = uFlags | 0x10;         // set burst-in-progress bit
				if (!(*(DWORD*)((BYTE*)param_1 + 0x3e0) & 0x200) || !(uFlags & 2))
					((APawn*)param_1)->eventPlayWeaponAnimation();
				else
					param_1->eventUpdateBipodPosture();
			}

			// Walk Level->Engine->Clients[0] chain to reach the local player controller.
			// this+0x328 = Owner (AActor*); Owner+0x44 = XLevel (ULevel*);
			// [+0x44] = Engine; [+0x30] = Clients array ptr; [0]+0x34 = local PC.
			AR6PlayerController* pAVar3 = *(AR6PlayerController**)
				(**(INT**)(*(INT*)(*(INT*)(*(INT*)((BYTE*)this + 0x328) + 0x44) + 0x44) + 0x30) + 0x34);

			if (*(AR6Pawn**)((BYTE*)pAVar3 + 0x3d8) == param_1          // pAVar3->Pawn == param_1
				|| *(AR6Pawn**)((BYTE*)pAVar3 + 0x5b8) != param_1       // pAVar3->field_0x5b8 != param_1
				|| (*(BYTE*)((BYTE*)pAVar3 + 0x524) & 0x20))            // pAVar3->field_0x524 bit 5
			{
				INT sfx = *(INT*)((BYTE*)this + 0x5a0);                 // muzzle-flash AR6SFX
				if (sfx != 0 && *(INT*)(sfx + 0x39c) != 0)
				{
					if (!(*(BYTE*)((BYTE*)this + 0x3a0) & 0x40))        // not ADS / first-person flag
					{
						// Set up emitter colour/life parameters
						DWORD u = *(DWORD*)(sfx + 0xa0) ^ 0x100;
						*(DWORD*)(sfx + 0xa0) = (u & 0xfffff7ff) | 0x200;
						*(BYTE*)(sfx + 0x36)  = (BYTE)(u >> 8) & 1;
						*(DWORD*)(sfx + 0x104) = 0x43400000;            // 192.0f
						*(BYTE*)(sfx + 0x38)  = 0xc0;
						*(BYTE*)(sfx + 0x39)  = 0xc0;
						*(DWORD*)(sfx + 0x108) = 0x41200000;            // 10.0f
					}

					INT arrBase = *(INT*)(sfx + 0x398);                 // emitter array base ptr

					// emitter[0]: always trigger
					INT e0 = *(INT*)arrBase;
					if (e0 != 0)
					{
						PFNTRIGGER fn = *(PFNTRIGGER*)((BYTE*)(*(INT*)e0) + 0x88);
						fn((void*)e0, 1);
					}

					// emitter[1]
					if (*(INT*)(sfx + 0x39c) > 1)
					{
						INT* e1 = *(INT**)(arrBase + 4);
						if (e1 != NULL)
						{
							PFNTRIGGER fn = *(PFNTRIGGER*)((BYTE*)(*e1) + 0x88);
							fn(e1, 1);
						}
					}

					// emitters [2] and [3]: suppressed when local player is ADS (bit 6 set)
					if (!(*(BYTE*)((BYTE*)this + 0x3a0) & 0x40)
						&& (param_2 != pAVar3 || (*(BYTE*)((BYTE*)param_2 + 0x524) & 0x20)))
					{
						if (*(INT*)(sfx + 0x39c) > 2)
						{
							INT* e2 = *(INT**)(arrBase + 8);
							if (e2 != NULL)
							{
								PFNTRIGGER fn = *(PFNTRIGGER*)((BYTE*)(*e2) + 0x88);
								fn(e2, 1);
							}
						}
						if (*(INT*)(sfx + 0x39c) > 3)
						{
							INT* e3 = *(INT**)(arrBase + 0xc);
							if (e3 != NULL)
							{
								PFNTRIGGER fn = *(PFNTRIGGER*)((BYTE*)(*e3) + 0x88);
								fn(e3, 1);
							}
						}
					}

					// emitter[4]: thermal/NV effect — local, non-ADS, non-bipod only
					if (!(*(BYTE*)((BYTE*)this + 0x3a0) & 0x40)
						&& param_2 == pAVar3
						&& !(*(BYTE*)((BYTE*)param_2 + 0x524) & 0x20)
						&& !(*(BYTE*)((BYTE*)param_2 + 0x838) & 4)
						&& *(INT*)(sfx + 0x39c) > 4)
					{
						INT* e4 = *(INT**)(arrBase + 0x10);
						if (e4 != NULL)
						{
							PFNTRIGGER fn = *(PFNTRIGGER*)((BYTE*)(*e4) + 0x88);
							fn(e4, 1);
						}
					}
				}

				// Second SFX (e.g., ejected-shell emitter at this+0x59c).
				// Ghidra has an early return here; it is equivalent to fall-through since
				// there is no code between this block and the function end.
				INT sfx2 = *(INT*)((BYTE*)this + 0x59c);
				if (sfx2 != 0 && *(INT*)(sfx2 + 0x39c) != 0)
				{
					INT e0_2 = *(INT*)(*(INT*)(sfx2 + 0x398));          // sfx2 emitter[0]
					if ((INT*)e0_2 != NULL)
					{
						PFNTRIGGER fn = *(PFNTRIGGER*)((BYTE*)(*(INT*)e0_2) + 0x88);
						fn((void*)e0_2, 1);
					}
				}
			}
		}
	}

	unguard;
}

IMPL_MATCH("R6Weapons.dll", 0x10004aa0)
FLOAT AR6Weapons::ComputeEffectiveAccuracy(FLOAT DeltaTime, FLOAT DeltaFrame)
{
	// Sync old worst accuracy when it drifts from current worst
	if (m_fWorstAccuracy != m_fOldWorstAccuracy)
	{
		if (m_fEffectiveAccuracy < m_fWorstAccuracy)
			m_fEffectiveAccuracy = m_fWorstAccuracy;
		m_fOldWorstAccuracy = m_fWorstAccuracy;
	}

	// Drive effective accuracy toward desired accuracy
	if (m_fDesiredAccuracy != m_fEffectiveAccuracy)
	{
		// Virtual at vtable+0x194: checks local-player ownership flag (always true in SP)
		// DIVERGENCE: hardcoded true; original calls an unknown virtual that would
		// return false for non-owning network clients.
		bool bCanUpdate = true;
		if (bCanUpdate)
		{
			if (m_fEffectiveAccuracy <= m_fDesiredAccuracy)
			{
				m_fEffectiveAccuracy = m_fDesiredAccuracy;
			}
			else
			{
				// Skill modulates recovery speed (higher skill = faster recovery)
				// Byte at this+0x394 encodes weapon "type index" for skill lookup
				// (in AActor's SimAnim region -- unknown field, used as skill category)
				BYTE weaponTypeIdx = *(BYTE*)((BYTE*)this + 0x394);
				INT  skillIdx = (weaponTypeIdx != 4) ? 0 : 3;
				FLOAT fSkill = ((AR6AbstractPawn*)Owner)->eventGetSkill(skillIdx);
				FLOAT fFactor = 5.5f - fSkill * 5.0f;
				if (fFactor < 0.0f) fFactor = 0.0f;
				FLOAT fNew = m_fEffectiveAccuracy -
					((m_stAccuracyValues.fRunningAccuracy - m_stAccuracyValues.fBaseAccuracy) /
					 ((m_stAccuracyValues.fReticuleTime * 0.25f * fFactor) / DeltaFrame)) * DeltaTime;
				if (fNew < m_fDesiredAccuracy)
					fNew = m_fDesiredAccuracy;
				m_fEffectiveAccuracy = fNew;
			}
		}
	}
	return m_fEffectiveAccuracy;
}

IMPL_MATCH("R6Weapons.dll", 0x10004600)
FLOAT AR6Weapons::GetMovingModifier(FLOAT DeltaTime, FLOAT DeltaFrame)
{
	AR6AbstractPawn* pPawn = (AR6AbstractPawn*)Owner;
	if (!pPawn)
		return m_fWorstAccuracy;

	// Fetch view rotation from pawn (virtual at vtable+0xD4 on pawn = GetViewRotation)
	FRotator curRot = pPawn->GetViewRotation();
	INT curPitch = curRot.Pitch;
	INT curYaw   = curRot.Yaw;
	INT curRoll  = curRot.Roll;

	// Raw pawn field accesses (parent-class offsets from Ghidra; not in reconstructed header)
	// piVar1[0x96..0x97] = Velocity.X,Y at pawn+0x258,0x25C
	FLOAT velX = *(FLOAT*)((BYTE*)pPawn + 0x258);
	FLOAT velY = *(FLOAT*)((BYTE*)pPawn + 0x25C);
	// piVar1[0xf8] and piVar1[0xfa] = bitmask flags at pawn+0x3E0 and 0x3E8
	DWORD flags0 = *(DWORD*)((BYTE*)pPawn + 0x3E0);
	DWORD flags1 = *(DWORD*)((BYTE*)pPawn + 0x3E8);
	// char flags at pawn+0x39E (prone/crawl) and 0x3A2 (highstance)
	BYTE crawlFlag  = *(BYTE*)((BYTE*)pPawn + 0x39E);
	BYTE stanceFlag = *(BYTE*)((BYTE*)pPawn + 0x3A2);

	// Determine base accuracy from stance / movement
	if ((Abs(velX) + Abs(velY) <= 0.0f) || (flags0 & 0x4) || (flags0 & 0x200))
	{
		if (Abs(velX) + Abs(velY) <= 0.0f)
			m_fWorstAccuracy = m_stAccuracyValues.fBaseAccuracy;         // standing
		else
			m_fWorstAccuracy = m_stAccuracyValues.fWalkingAccuracy;      // crouched+moving
	}
	else if (crawlFlag == 1)
	{
		m_fWorstAccuracy = m_stAccuracyValues.fWalkingFastAccuracy;      // prone/crawling
	}
	else
	{
		m_fWorstAccuracy = m_stAccuracyValues.fRunningAccuracy;          // running
	}

	// Prone high-stance modifier
	if (stanceFlag == 1)
		m_fWorstAccuracy *= 1.2f;

	// Lean/ADS modifiers
	if (!(flags0 & 0x20))
	{
		if (flags0 & 0x200)
		{
			m_fWorstAccuracy *= (m_bFireOn ? 0.7f : 0.8f);
		}
	}
	else
	{
		m_fWorstAccuracy *= 0.9f;
	}

	// Compute view rotation delta and store in 5-frame ring buffer
	// piVar1[0x13b] = some actor pointer (Ghidra 0x4EC in pawn) -- optional weapon-mount pivot
	INT mountActorPtr = *(INT*)((BYTE*)pPawn + 0x4EC);
	INT pitchDelta, yawDelta;
	if (mountActorPtr == 0)
	{
		yawDelta   = Abs(*(INT*)((BYTE*)this + 0x5D4) - curYaw);
		pitchDelta = Abs(*(INT*)((BYTE*)this + 0x5D0) - curPitch);
	}
	else
	{
		// Check if mount actor is of this weapon class; if so use its location delta
		bool bIsWeapon = false;
		for (INT* classPtr = *(INT**)(mountActorPtr + 0x24); classPtr; classPtr = *(INT**)(classPtr + 0x2C))
		{
			if (classPtr == (INT*)&PrivateStaticClass) { bIsWeapon = true; break; }
		}
		if (!bIsWeapon || mountActorPtr == 0)
		{
			yawDelta   = Abs(*(INT*)((BYTE*)this + 0x5D4) - curYaw);
			pitchDelta = Abs(*(INT*)((BYTE*)this + 0x5D0) - curPitch);
		}
		else
		{
			yawDelta   = Abs((*(INT*)((BYTE*)this + 0x5D4) - *(INT*)(mountActorPtr + 0x940)) - curYaw);
			pitchDelta = Abs((*(INT*)((BYTE*)this + 0x5D0) - *(INT*)(mountActorPtr + 0x93C)) - curPitch);
		}
	}

	// Convert Unreal rotation units to degrees (360/65536) and wrap to [0,180]
	FLOAT degDelta = (FLOAT)Max(yawDelta, pitchDelta) * 0.005493164f;
	if (degDelta > 180.0f) degDelta = 360.0f - degDelta;

	// Scale by DeltaFrame/DeltaTime ratio and store in ring buffer
	m_fAverageDegTable[m_iCurrentAverage] = (degDelta * DeltaFrame) / DeltaTime;
	FLOAT avg = (m_fAverageDegTable[0] + m_fAverageDegTable[1] + m_fAverageDegTable[2] +
	             m_fAverageDegTable[3] + m_fAverageDegTable[4]) * 0.2f;
	m_iCurrentAverage = (m_iCurrentAverage + 1) % 5;
	m_fAverageDegChanges = avg;

	// External constant: turn-rate threshold (in degrees/frame) for accuracy classification.
	// DIVERGENCE: Ghidra shows DAT_1000c0ac -- value unknown (retail .data not available).
	// Using 2.0 degrees/frame as a reasonable estimate; will be wrong vs. original byte output.
	static const FLOAT GR6W_TurnRateThreshold = 2.0f;

	// Classify turn speed into 5 accuracy levels and clamp worst accuracy
	INT level = 0;
	if (avg >= GR6W_TurnRateThreshold)        level = 1;
	if (avg >= GR6W_TurnRateThreshold * 2.0f) level = 2;
	if (avg >= GR6W_TurnRateThreshold * 4.0f) level = 3;
	if (avg >= GR6W_TurnRateThreshold * 6.0f) level = 4;

	// Raise m_fWorstAccuracy based on turn level if current is below threshold
	if (m_fWorstAccuracy < m_stAccuracyValues.fBaseAccuracy)
	{
		const FLOAT* accuracyLevels[5] = {
			&m_stAccuracyValues.fBaseAccuracy, &m_stAccuracyValues.fShuffleAccuracy,
			&m_stAccuracyValues.fWalkingAccuracy, &m_stAccuracyValues.fWalkingFastAccuracy,
			&m_stAccuracyValues.fRunningAccuracy
		};
		m_fWorstAccuracy = *accuracyLevels[level];
	}
	else
	{
		// Shift up if current level's threshold exceeds current worst
		if (m_fWorstAccuracy < m_stAccuracyValues.fShuffleAccuracy && level >= 1)
			m_fWorstAccuracy = (level == 1) ? m_stAccuracyValues.fWalkingFastAccuracy :
			                   (level == 2) ? m_stAccuracyValues.fRunningAccuracy : m_stAccuracyValues.fRunningAccuracy;
		else if (m_fWorstAccuracy < m_stAccuracyValues.fWalkingAccuracy && level >= 2)
			m_fWorstAccuracy = (level == 2) ? m_stAccuracyValues.fWalkingFastAccuracy : m_stAccuracyValues.fRunningAccuracy;
		else if (m_fWorstAccuracy < m_stAccuracyValues.fWalkingFastAccuracy && level >= 3)
			m_fWorstAccuracy = (level == 3) ? m_stAccuracyValues.fWalkingFastAccuracy : m_stAccuracyValues.fRunningAccuracy;
	}

	// Save current rotation for next frame delta
	m_rLastRotation.Pitch = curPitch;
	m_rLastRotation.Yaw   = curYaw;
	m_rLastRotation.Roll  = curRoll;

	// Crawling blend: smooth toward base accuracy
	if (!(flags1 & 0x10) && crawlFlag == 1)
		m_fWorstAccuracy = (m_fWorstAccuracy - m_stAccuracyValues.fBaseAccuracy) * 0.2f + m_stAccuracyValues.fBaseAccuracy;

	return m_fWorstAccuracy;
}

IMPL_MATCH("R6Weapons.dll", 0x100039e0)
bool AR6Weapons::WeaponIsNotFiring()
{
	return true;
}

IMPL_MATCH("R6Weapons.dll", 0x100011c0)
void AR6Weapons::eventHideAttachment()
{
	ProcessEvent(FindFunctionChecked(R6WEAPONS_HideAttachment), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
