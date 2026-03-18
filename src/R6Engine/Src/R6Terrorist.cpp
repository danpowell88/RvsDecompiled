/*=============================================================================
	R6Terrorist.cpp
	AR6Terrorist — terrorist pawn with net replication and special animations.
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6Terrorist)

// Statics used by AR6Terrorist PreNetReceive/PostNetReceive.
static BYTE GR6Terrorist_OldSpecialAnimValid;
static BYTE GR6Terrorist_OldHealth;
static BYTE GR6Terrorist_OldDefCon;

// --- AR6Terrorist ---

IMPL_MATCH("R6Engine.dll", 0x1003d0b0)
void AR6Terrorist::PostNetReceive()
{
	guard(AR6Terrorist::PostNetReceive);

	BYTE CurSpecialAnim = m_eSpecialAnimValid;
	if (GR6Terrorist_OldSpecialAnimValid != CurSpecialAnim)
	{
		if (CurSpecialAnim == 0)
			eventStopSpecialAnim();
		else if (CurSpecialAnim == 1)
			eventPlaySpecialAnim();
		else if (CurSpecialAnim == 2)
			eventLoopSpecialAnim();
	}

	if (GR6Terrorist_OldHealth != m_eHealth || GR6Terrorist_OldDefCon != m_eDefCon)
		eventChangeAnimation();

	AR6Pawn::PostNetReceive();

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1003cbf0)
void AR6Terrorist::PreNetReceive()
{
	guard(AR6Terrorist::PreNetReceive);
	GR6Terrorist_OldSpecialAnimValid = m_eSpecialAnimValid;
	GR6Terrorist_OldHealth = m_eHealth;
	GR6Terrorist_OldDefCon = m_eDefCon;
	AR6Pawn::PreNetReceive();
	unguard;
}

// Ghidra 0x10029590; 1272 bytes. Smooth aiming animation: interpolates target yaw/pitch
// toward current values and distributes rotations across 7 skeleton bones based on
// stance and weapon attachment state.
//
// DIVERGENCE: FUN_10042934 = __ftol2_sse (x87 float-to-int), called with an unknown
//   DeltaTime*rate float in ST0. Approximated as appRound(DeltaTime * 8192.f) which
//   represents ~45 degree/sec turning rate in Unreal rotation units.
// DIVERGENCE: division-by-3 via Ghidra's multiply-shift pattern (0x55555555) is
//   correctly reproduced as iVar/3.
// DIVERGENCE: stance/weapon split ratios reproduced from Ghidra arithmetic chains.
IMPL_TODO("Ghidra 0x10029590; 1272b: UpdateAiming — implemented; FUN_10042934 rate approx'd as DeltaTime*8192")
void AR6Terrorist::UpdateAiming(FLOAT DeltaTime)
{
	guard(AR6Terrorist::UpdateAiming);

	// ── Yaw smoothing ─────────────────────────────────────────────────────────
	INT targetYaw = (INT)((BYTE*)this)[0xa30] * 0x100;
	if (targetYaw > 0x7fff) targetYaw -= 0x10000;  // sign-extend 16-bit
	INT curYaw = *(INT*)((BYTE*)this + 0xa3c);

	INT neckYaw = 0, spineYaw = 0, neckRoll = 0;
	INT bNeckYaw = 0;

	if (curYaw != targetYaw)
	{
		INT step = appRound(DeltaTime * 8192.f);   // approximated rate
		if (targetYaw < curYaw)
		{
			curYaw -= step;
			if (targetYaw > curYaw) curYaw = targetYaw;
		}
		else
		{
			curYaw += step;
			if (curYaw > targetYaw) curYaw = targetYaw;
		}
		*(INT*)((BYTE*)this + 0xa3c) = curYaw;

		// Distribute yaw based on stance and weapon
		BYTE stance = ((BYTE*)this)[0xa28];
		if (stance < 4)
		{
			INT* weapon = (INT*)*(INT*)((BYTE*)this + 0x4fc);
			if (!weapon || *(char*)((BYTE*)weapon + 0x394) != '\0')
			{
				// No weapon or weapon flag: split yaw 50/50 between neck and spine
				if (curYaw < 0)
				{
					neckYaw = curYaw / 2;
					spineYaw = -(curYaw / 2);
				}
				else
				{
					// Divide by 3 using Ghidra's multiply-shift pattern
					INT div3 = (INT)(((__int64)curYaw * 0x55555555LL) >> 32) - curYaw;
					spineYaw = (div3 >> 1) - (div3 >> 31);
				}
			}
			// else: weapon present → no yaw distribution to spine (only neck)
		}
		bNeckYaw = 1;
		neckYaw = curYaw;
	}

	// ── Pitch smoothing ────────────────────────────────────────────────────────
	INT targetPitch = (INT)((BYTE*)this)[0xa2f] * 0x100;
	if (targetPitch > 0x7fff) targetPitch -= 0x10000;
	INT curPitch = *(INT*)((BYTE*)this + 0xa38);

	if (curPitch != targetPitch)
	{
		INT step = appRound(DeltaTime * 8192.f);
		if (targetPitch < curPitch)
		{
			curPitch -= step;
			if (targetPitch > curPitch) curPitch = targetPitch;
		}
		else
		{
			curPitch += step;
			if (curPitch > targetPitch) curPitch = targetPitch;
		}
		// Clamp pitch to [-10000, 10000]
		if (curPitch < -10000) curPitch = -10000;
		else if (curPitch > 9999) curPitch = 10000;
		*(INT*)((BYTE*)this + 0xa38) = curPitch;
	}

	// ── Bone rotation distribution ─────────────────────────────────────────────
	// Get USkeletalMeshInstance via Mesh->MeshGetInstance(this)
	// this+0x16c = Mesh (USkeletalMesh field on APawn layout)
	void* pMesh = *(void**)((BYTE*)this + 0x16c);
	USkeletalMeshInstance* inst = NULL;
	if (pMesh)
	{
		typedef UMeshInstance* (__thiscall* FGetInstFn)(void*, AActor const*);
		inst = (USkeletalMeshInstance*)((FGetInstFn)(*(void***)pMesh)[0x88/4])(pMesh, this);
	}

	if (inst && curPitch != 0)
	{
		// Distribute pitch across bones based on stance/weapon state
		INT spinePitch    = 0, spine1Pitch = 0, spine2Pitch = 0;
		INT lForearmPitch = 0, lHandPitch  = 0;
		INT spine2Yaw     = 0, lHandYaw    = 0;
		INT rHandPitch    = 0;

		BYTE stance = ((BYTE*)this)[0xa28];
		DWORD flags = *(DWORD*)((BYTE*)this + 0x3e4);
		INT* weapon = (INT*)*(INT*)((BYTE*)this + 0x4fc);

		if (stance < 3 && (flags & 0x40000) != 0)
		{
			if (!weapon || (*(char*)((BYTE*)weapon + 0x394) != '\0' &&
				(*(BYTE*)((BYTE*)weapon + 0x3a1) & 1) == 0))
			{
				DWORD e0flags = *(DWORD*)((BYTE*)this + 0x3e0);
				if ((e0flags & 0x20) == 0)
				{
					// Simple standing: split pitch evenly
					if (curPitch < 1)
					{
						// Downward pitch
						spinePitch  = appRound(DeltaTime * 8192.f);
						lForearmPitch = -(spinePitch);
						spine1Pitch = curPitch / 2;
						spine2Pitch = -(curPitch / 2);
					}
					else
					{
						// Upward pitch: 20% to neck, 40% each to two spine bones
						INT twentyPct = (INT)(((__int64)curPitch * -0x66666667LL) >> 32);
						spinePitch = (twentyPct >> 2) - (twentyPct >> 31);
						spine1Pitch = (twentyPct >> 2) - (twentyPct >> 31);
						INT half = curPitch / 2;
						spine2Pitch = -(half);
						lHandPitch  = -(half);
					}
				}
				else
				{
					// Crouched: three-way split
					if (curPitch < 1)
					{
						INT qtr = (curPitch + ((-(DWORD)(curPitch)) >> 30 & 3)) >> 2;
						INT fifth = (INT)(((__int64)curPitch * -0x66666667LL) >> 32);
						INT d = (fifth >> 2) - (fifth >> 31);
						spinePitch  = d;
						lForearmPitch = d;
						lHandPitch  = -qtr;
						spine2Yaw = -qtr;
						lHandYaw  = -qtr;
					}
					else
					{
						INT fifth = (INT)(((__int64)curPitch * -0x66666667LL) >> 32);
						INT d = (fifth >> 2) - (fifth >> 31);
						INT qtr = (curPitch + ((-(DWORD)(curPitch)) >> 30 & 3)) >> 2;
						spinePitch = d;
						spine2Yaw  = qtr;
						lHandYaw   = qtr;
					}
				}
			}
			else
			{
				// Weapon with bi-pod or specific attachment
				INT div3_5 = (INT)(((__int64)curPitch * -0x66666667LL) >> 32);
				INT fifth = (div3_5 >> 1) - (div3_5 >> 31);
				spinePitch = -(curPitch / 2);
				if (curPitch < 1)
					lHandYaw = fifth;
				else
				{
					spine2Yaw += (curPitch + 3) >> 2;
					lHandYaw = fifth;
				}
			}
		}
		else
		{
			// Prone or specialist stance: drive neck only
			bNeckYaw = 1;
			spineYaw = appRound(DeltaTime * 8192.f);
		}

		// Apply bone rotations (Roll=iVar8, Pitch=Pitch_comp, Yaw=Yaw_comp, flags=0, alpha=1.0, scale=0.1)
		inst->SetBoneRotation(FName(TEXT("R6 Neck"), FNAME_Find),
			FRotator(spine2Pitch, neckYaw, lForearmPitch), 0, 1.0f, 0.1f);
		inst->SetBoneRotation(FName(TEXT("R6 Spine"), FNAME_Find),
			FRotator(lForearmPitch, spinePitch, lHandPitch), 0, 1.0f, 0.1f);
		inst->SetBoneRotation(FName(TEXT("R6 Spine1"), FNAME_Find),
			FRotator(0, spine1Pitch, 0), 0, 1.0f, 0.1f);
		inst->SetBoneRotation(FName(TEXT("R6 Spine2"), FNAME_Find),
			FRotator(spine2Pitch, spine2Yaw, 0), 0, 1.0f, 0.1f);
		inst->SetBoneRotation(FName(TEXT("R6 L Forearm"), FNAME_Find),
			FRotator(0, lForearmPitch, 0), 0, 1.0f, 0.1f);
		inst->SetBoneRotation(FName(TEXT("R6 L Hand"), FNAME_Find),
			FRotator(0, lHandPitch, lHandYaw), 0, 1.0f, 0.1f);
		inst->SetBoneRotation(FName(TEXT("R6 R Hand"), FNAME_Find),
			FRotator(rHandPitch, 0, 0), 0, 1.0f, 0.1f);
	}

	// ── Yaw-only path neck update (when only yaw changed) ─────────────────────
	if (bNeckYaw && inst)
	{
		inst->SetBoneRotation(FName(TEXT("R6 Neck"), FNAME_Find),
			FRotator(spineYaw, neckYaw, neckRoll), 0, 1.0f, 0.1f);
	}

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10004c60)
void AR6Terrorist::eventFinishInitialization()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_FinishInitialization), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x100063e0)
void AR6Terrorist::eventLoopSpecialAnim()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_LoopSpecialAnim), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x10006410)
void AR6Terrorist::eventPlaySpecialAnim()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlaySpecialAnim), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x100063b0)
void AR6Terrorist::eventStopSpecialAnim()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_StopSpecialAnim), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
