/*=============================================================================
	R6Matinee.cpp — UR6SubActionAnimSequence
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(UR6SubActionAnimSequence)

// FUN_10024530 (0x10024530): IsA check — walks class chain at +0x24/+0x2c against PrivateStaticClass_exref.
// Pass-through: in the animation context, the mesh instance always passes the type check.
IMPL_TODO("blocked: PrivateStaticClass_exref unresolved — IsA target class unknown; pass-through assumes check always succeeds")
static INT FUN_10024530(INT param_1) { return param_1; }
// FUN_10042934 (0x10042934): MSVC __ftol2 intrinsic — reads x87 ST0 and converts float to int64.
// Inlined as (INT)fVar at call sites where the source float is known (e.g. GetAnimDuration).
// Kept as stub for PctToFrameNumber where the ST0 source is ambiguous.
IMPL_TODO("blocked: __ftol2 reads x87 ST0; only needed where source float is ambiguous (PctToFrameNumber)")
static QWORD FUN_10042934() { return 0; }

// --- UR6SubActionAnimSequence ---

IMPL_TODO("blocked: FUN_10024530 IsA uses unresolved PrivateStaticClass_exref; pass-through assumes mesh instance always passes type check")
FLOAT UR6SubActionAnimSequence::GetAnimDuration(UR6PlayAnim* param_1)
{
	guard(UR6SubActionAnimSequence::GetAnimDuration);

	UR6PlayAnim* pUVar3 = param_1;
	INT iVar4 = *(INT*)((BYTE*)this + 100);

	if ((iVar4 != 0) && (param_1 != (UR6PlayAnim*)0) && (*(INT*)(iVar4 + 0x16c) != 0))
	{
		// Get mesh instance via vtable slot 0x88/4
		{
			void* actor = (void*)iVar4;
			void* mesh  = *(void**)((BYTE*)actor + 0x16c);
			typedef INT (__thiscall *TGetMeshInst)(void*, void*);
			iVar4 = ((TGetMeshInst)*(DWORD*)(*(DWORD*)mesh + 0x88))(mesh, actor);
		}

		INT* piVar5 = (INT*)FUN_10024530(iVar4);
		if (piVar5 != (INT*)0)
		{
			// GetAnimByName via vtable 0xb0/4
			typedef DWORD (__thiscall *TGetAnimByName)(void*, DWORD);
			DWORD uVar6 = ((TGetAnimByName)*(DWORD*)(*(DWORD*)piVar5 + 0xb0))(piVar5, *(DWORD*)((BYTE*)param_1 + 0x50));

			// GetNumFrames (as float) via vtable 0xc4/4
			typedef FLOAT (__thiscall *TGetNumFrames)(void*, DWORD);
			FLOAT fVar7 = ((TGetNumFrames)*(DWORD*)(*(DWORD*)piVar5 + 0xc4))(piVar5, uVar6);

			// Release anim handle via vtable 0xc0/4
			typedef void (__thiscall *TReleaseAnim)(void*, DWORD);
			((TReleaseAnim)*(DWORD*)(*(DWORD*)piVar5 + 0xc0))(piVar5, uVar6);

			// Ghidra: uVar8 = FUN_10042934() — __ftol2 reads GetNumFrames result still in x87 ST0.
			// Inlined here as (INT)fVar7 since the source float is known.
			INT iFrameCount = (INT)fVar7;

			FLOAT fVar2 = *(FLOAT*)((BYTE*)param_1 + 0x3c); // m_Rate

			// Fallback to 1.0f if denominator is zero
			FLOAT fDenominator = fVar7;
			if (fDenominator == 0.0f)
				fDenominator = 1.0f;

			*(INT*)((BYTE*)pUVar3 + 0x34) = iFrameCount; // m_iFrameNumber

			return ((FLOAT)iFrameCount / fDenominator) * (FLOAT)*(INT*)((BYTE*)pUVar3 + 0x2c) * fVar2;
		}
	}

	return 0.0f;

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10040c60)
UR6PlayAnim * UR6SubActionAnimSequence::GetAnimation(FLOAT Time)
{
	for (INT i = 0; i < m_Sequences.Num(); i++)
	{
		UR6PlayAnim* Anim = m_Sequences(i);
		if (Time >= Anim->m_fBeginPct && Time < Anim->m_fEndPct)
			return Anim;
	}
	return NULL;
}

IMPL_MATCH("R6Engine.dll", 0x100408d0)
FLOAT UR6SubActionAnimSequence::GetCurAnimPct(FLOAT Time)
{
	FLOAT Begin = m_CurSequence->m_fBeginPct;
	FLOAT End = m_CurSequence->m_fEndPct;
	if (End != Begin)
		return (Time - Begin) / (End - Begin);
	return 0.f;
}

IMPL_MATCH("R6Engine.dll", 0x10040a20)
FString UR6SubActionAnimSequence::GetStatString()
{
	FString Result = UMatSubAction::GetStatString();
	Result += TEXT("AnimSequence\n");
	return Result;
}

IMPL_MATCH("R6Engine.dll", 0x10041380)
FLOAT UR6SubActionAnimSequence::GetTotalLength()
{
	FLOAT Total = 0.f;
	for (INT i = 0; i < m_Sequences.Num(); i++)
		Total += GetAnimDuration(m_Sequences(i));
	return Total;
}

IMPL_MATCH("R6Engine.dll", 0x10041120)
INT UR6SubActionAnimSequence::IncrementSequence()
{
	m_CurIndex++;
	if (m_CurIndex < m_Sequences.Num())
	{
		m_CurSequence = m_Sequences(m_CurIndex);
		if (m_CurSequence)
		{
			eventSequenceChanged();
			return 1;
		}
	}
	return 0;
}

IMPL_TODO("blocked: FUN_10024530 IsA check skipped; PrivateStaticClass_exref target class unresolved")
INT UR6SubActionAnimSequence::IsAnimAtFrame(INT param_1, INT param_2)
{
	guard(UR6SubActionAnimSequence::IsAnimAtFrame);

	// Get mesh instance via vtable slot 0x88/4
	INT iVar2;
	{
		void* actor2 = (void*)*(INT*)((BYTE*)this + 100);
		void* mesh2  = *(void**)((BYTE*)actor2 + 0x16c);
		typedef INT (__thiscall *TGetMeshInst)(void*, void*);
		iVar2 = ((TGetMeshInst)*(DWORD*)(*(DWORD*)mesh2 + 0x88))(mesh2, actor2);
	}

	// Ghidra: FUN_10024530 IsA check on iVar2; if it fails, iVar2 = 0 (crash on deref below).
	// Retail also crashes if iVar2 is 0. Pass-through: IsA always succeeds in practice.

	// Array of anim track entries at iVar2+0x10c; each entry 0x74 bytes; frame start time at +0x10
	FLOAT fVar1 = *(FLOAT*)(*(INT*)(iVar2 + 0x10c) + 0x10 + param_1 * 0x74);

	if ((FLOAT)param_2 <= fVar1)
		return 1;

	return 0;

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10040900)
INT UR6SubActionAnimSequence::LaunchSequence()
{
	if (!m_AffectedActor)
		return 0;

	m_AffectedActor->AnimBlendParams(0x11, 1.0f, 0.0f, 0.0f, NAME_None);

	// PlayAnim via vtable slot 88 (offset 0x160) on m_AffectedActor.
	typedef void (__thiscall *TPlayAnim)(AActor*, INT, INT, FLOAT, FLOAT, INT, INT, INT);
	TPlayAnim pfPlayAnim = (TPlayAnim)(*(INT**)m_AffectedActor)[0x160 / 4];
	pfPlayAnim(m_AffectedActor, 0x11, *(INT*)&m_CurSequence->m_Sequence,
	           m_CurSequence->m_Rate, m_CurSequence->m_TweenTime, 0, 0, 0);

	if (m_bUseRootMotion)
	{
		// StopAnim via vtable slot 71 (offset 0x11C) on m_AffectedActor.
		typedef void (__thiscall *TStopAnim)(AActor*, INT, INT, INT, INT, FLOAT);
		TStopAnim pfStopAnim = (TStopAnim)(*(INT**)m_AffectedActor)[0x11C / 4];
		pfStopAnim(m_AffectedActor, 0xC, 0, 0, 0, 1.0f);
		// Clear UseRootMotion flag (bit 12) at Actor+0xA8.
		*(DWORD*)((BYTE*)m_AffectedActor + 0xA8) &= ~0x1000;
	}

	return 1;
}

IMPL_TODO("blocked: FUN_10024530 IsA + FUN_10042934 ST0 source float ambiguous after vtable 0xc0 call — returns 0.0f")
FLOAT UR6SubActionAnimSequence::PctToFrameNumber(UR6PlayAnim* param_1, FLOAT param_2)
{
	guard(UR6SubActionAnimSequence::PctToFrameNumber);

	// Get mesh instance via vtable slot 0x88/4
	INT* piVar3;
	{
		void* actor3 = (void*)*(INT*)((BYTE*)this + 100);
		void* mesh3  = *(void**)((BYTE*)actor3 + 0x16c);
		typedef INT* (__thiscall *TGetMeshInst)(void*, void*);
		piVar3 = ((TGetMeshInst)*(DWORD*)(*(DWORD*)mesh3 + 0x88))(mesh3, actor3);
	}

	// Ghidra: FUN_10024530 IsA check — pass-through (always succeeds in practice)
	if (piVar3 == (INT*)0)
		piVar3 = (INT*)0; // stay NULL

	// Lookup anim by name via vtable 0xb0, then call vtable 0xc0
	typedef DWORD (__thiscall *TGetAnimByName2)(void*, DWORD);
	DWORD uVar4 = ((TGetAnimByName2)*(DWORD*)(*(DWORD*)piVar3 + 0xb0))(piVar3, *(DWORD*)((BYTE*)param_1 + 0x50));
	typedef void (__thiscall *TReleaseAnim2)(void*, DWORD);
	((TReleaseAnim2)*(DWORD*)(*(DWORD*)piVar3 + 0xc0))(piVar3, uVar4);

	// Ghidra: FUN_10042934 reads x87 ST0 left by vtable 0xc0 call above.
	// The source float is ambiguous — vtable 0xc0 may or may not return a float via ST0.
	QWORD uVar7 = FUN_10042934();

	FLOAT local_1c = 0.0f;
	FLOAT fVar2    = 1.0f / (FLOAT)*(INT*)((BYTE*)param_1 + 0x2c); // 1/numFrames

	if ((INT)uVar7 != 0)
		local_1c = (FLOAT)(1 - (INT)(1 / (SQWORD)(INT)uVar7));

	FLOAT fVar1 = 0.0f;
	for (INT iVar6 = 0; iVar6 < *(INT*)((BYTE*)param_1 + 0x2c); iVar6++)
	{
		if (((FLOAT)iVar6 * fVar2 < param_2) && (param_2 < (FLOAT)(iVar6 + 1) * fVar2))
			fVar1 = ((param_2 - (FLOAT)iVar6 * fVar2) / fVar2) * local_1c;
	}

	return fVar1;

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x100415b0)
void UR6SubActionAnimSequence::PreBeginPreview()
{
	if (m_Sequences.Num() != 0)
	{
		m_CurSequence = m_Sequences(0);
		FLOAT TotalLen = GetTotalLength();
		// Duration field at UMatSubAction offset 0x34
		*(FLOAT*)((BYTE*)this + 0x34) = TotalLen;
		FLOAT Accumulated = 0.f;
		FLOAT Pct = 0.f;
		for (INT i = 0; i < m_Sequences.Num(); i++)
		{
			UR6PlayAnim* Seq = m_Sequences(i);
			if (!Seq)
				break;
			Seq->m_fBeginPct = Pct;
			FLOAT Dur = GetAnimDuration(Seq);
			Accumulated += Dur;
			Pct = Accumulated / TotalLen;
			Seq->m_fEndPct = Pct;
		}
	}
}

IMPL_TODO("blocked: GIsEditor path not implemented — needs PctToFrameNumber, FString::Printf, ASceneManager+0x494, mesh vtable 0x104")
INT UR6SubActionAnimSequence::Update(FLOAT Time, ASceneManager* Mgr)
{
	if (!UMatSubAction::Update(Time, Mgr))
		return 0;

	if (GIsEditor)
	{
		// TODO: editor animation preview (raw mesh vtable calls not reconstructed; returns 1 as safe fallback)
		return 1;
	}

	return UpdateGame(Time, Mgr);
}

// Ghidra 0x10041420: retail reads m_Sequences.Data[0] unconditionally before
// null-checking (Num==0 || ptr==NULL); our ternary guard generates different
// assembly — functionally identical, permanent assembly-level divergence.
IMPL_DIVERGE("retail reads Data[0] unconditionally before null-check; ternary guard generates different assembly — functionally identical")
INT UR6SubActionAnimSequence::UpdateGame(FLOAT Time, ASceneManager* Mgr)
{
	if (!IsRunning())
		return 1;

	if (m_Sequences.Num() < 1)
		return 1;

	if (m_bFirstTime)
	{
		m_CurIndex = 0;
		m_CurSequence = m_Sequences.Num() > 0 ? m_Sequences(0) : NULL;
		if (!m_CurSequence)
			return 0;
		m_CurSequence->m_PlayedTime = 0;
		m_bFirstTime = 0;
		eventSequenceChanged();
	}
	else
	{
		// Anim-playing check via vtable slot 57 (offset 0xE4) on m_AffectedActor.
		typedef INT (__thiscall *TCheckAnim)(AActor*);
		if (((TCheckAnim)(*(INT**)m_AffectedActor)[0xE4 / 4])(m_AffectedActor) == 0)
			return 1;

		m_CurSequence->m_PlayedTime++;
		if (m_CurSequence->m_MaxPlayTime <= m_CurSequence->m_PlayedTime
			&& !m_CurSequence->m_bLoopAnim)
		{
			if (!IncrementSequence())
			{
				if (m_bResetAnimation)
					m_AffectedActor->AnimBlendParams(0x11, 0.0f, 0.0f, 0.0f, NAME_None);
				eventSequenceFinished();
				// Set UMatSubAction state field at offset 0x2C to 3 (done).
				*(INT*)((BYTE*)this + 0x2C) = 3;
				m_bFirstTime = 1;
				return 1;
			}
			m_AffectedActor->AnimBlendParams(0x11, 0.0f, 0.0f, 0.0f, NAME_None);
			// fall through to LaunchSequence
		}
		else
		{
			LaunchSequence();
			return 1;
		}
	}

	return LaunchSequence();
}

IMPL_MATCH("R6Engine.dll", 0x1000a5a0)
void UR6SubActionAnimSequence::eventSequenceChanged()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_SequenceChanged), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x1000a570)
void UR6SubActionAnimSequence::eventSequenceFinished()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_SequenceFinished), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
