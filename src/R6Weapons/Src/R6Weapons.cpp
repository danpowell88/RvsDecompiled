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
	FName event/callback tokens.
-----------------------------------------------------------------------------*/

#define NAMES_ONLY
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

void AR6Weapons::ProcessState(FLOAT DeltaTime)
{
	Super::ProcessState(DeltaTime);
}

INT AR6Weapons::IsBlockedBy(AActor const* Other) const
{
	return Super::IsBlockedBy(Other);
}

void AR6Weapons::PreNetReceive()
{
	Super::PreNetReceive();
}

void AR6Weapons::PostNetReceive()
{
	Super::PostNetReceive();
}

void AR6Weapons::TickAuthoritative(FLOAT DeltaTime)
{
	Super::TickAuthoritative(DeltaTime);
}

INT AR6Weapons::GetHeartBeatStatus()
{
	return 0;
}

void AR6Weapons::ShowWeaponParticles(AR6Pawn*, AR6PlayerController*)
{
}

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

bool AR6Weapons::WeaponIsNotFiring()
{
	return true;
}

void AR6Weapons::eventHideAttachment()
{
	ProcessEvent(FindFunctionChecked(R6WEAPONS_HideAttachment), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
