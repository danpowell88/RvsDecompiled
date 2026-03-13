/*=============================================================================
	R6Matinee.cpp — UR6SubActionAnimSequence
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(UR6SubActionAnimSequence)

// --- UR6SubActionAnimSequence ---

FLOAT UR6SubActionAnimSequence::GetAnimDuration(UR6PlayAnim *)
{
	return 0.f;
}

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

FLOAT UR6SubActionAnimSequence::GetCurAnimPct(FLOAT Time)
{
	FLOAT Begin = m_CurSequence->m_fBeginPct;
	FLOAT End = m_CurSequence->m_fEndPct;
	if (End != Begin)
		return (Time - Begin) / (End - Begin);
	return 0.f;
}

FString UR6SubActionAnimSequence::GetStatString()
{
	FString Result = UMatSubAction::GetStatString();
	Result += TEXT("AnimSequence\n");
	return Result;
}

FLOAT UR6SubActionAnimSequence::GetTotalLength()
{
	FLOAT Total = 0.f;
	for (INT i = 0; i < m_Sequences.Num(); i++)
		Total += GetAnimDuration(m_Sequences(i));
	return Total;
}

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

INT UR6SubActionAnimSequence::IsAnimAtFrame(INT, INT)
{
	return 0;
}

INT UR6SubActionAnimSequence::LaunchSequence()
{
	if (!m_AffectedActor)
		return 0;

	m_AffectedActor->AnimBlendParams(0x11, 1.0f, 0.0f, 0.0f, NAME_None);

	// DIVERGENCE: PlayAnim called via raw vtable slot 88 (offset 0x160) on m_AffectedActor.
	typedef void (__thiscall *TPlayAnim)(AActor*, INT, INT, FLOAT, FLOAT, INT, INT, INT);
	TPlayAnim pfPlayAnim = (TPlayAnim)(*(INT**)m_AffectedActor)[0x160 / 4];
	pfPlayAnim(m_AffectedActor, 0x11, *(INT*)&m_CurSequence->m_Sequence,
	           m_CurSequence->m_Rate, m_CurSequence->m_TweenTime, 0, 0, 0);

	if (m_bUseRootMotion)
	{
		// DIVERGENCE: StopAnim called via raw vtable slot 71 (offset 0x11C) on m_AffectedActor.
		typedef void (__thiscall *TStopAnim)(AActor*, INT, INT, INT, INT, FLOAT);
		TStopAnim pfStopAnim = (TStopAnim)(*(INT**)m_AffectedActor)[0x11C / 4];
		pfStopAnim(m_AffectedActor, 0xC, 0, 0, 0, 1.0f);
		// DIVERGENCE: clear UseRootMotion flag (bit 12) at Actor+0xA8.
		*(DWORD*)((BYTE*)m_AffectedActor + 0xA8) &= ~0x1000;
	}

	return 1;
}

FLOAT UR6SubActionAnimSequence::PctToFrameNumber(UR6PlayAnim *, FLOAT)
{
	return 0.f;
}

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

INT UR6SubActionAnimSequence::Update(FLOAT Time, ASceneManager* Mgr)
{
	if (!UMatSubAction::Update(Time, Mgr))
		return 0;

	if (GIsEditor)
	{
		// DIVERGENCE: editor animation preview uses raw mesh vtable calls — not implemented.
		return 1;
	}

	return UpdateGame(Time, Mgr);
}

INT UR6SubActionAnimSequence::UpdateGame(FLOAT Time, ASceneManager* Mgr)
{
	// DIVERGENCE: IsRunning check via raw vtable slot 27 (offset 0x6C) on this.
	typedef INT (__thiscall *TIsRunning)(UR6SubActionAnimSequence*);
	if (((TIsRunning)(*(INT**)this)[0x6C / 4])(this) == 0)
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
		// DIVERGENCE: anim-playing check via raw vtable slot 57 (offset 0xE4) on m_AffectedActor.
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
				// DIVERGENCE: set UMatSubAction state field at raw offset 0x2C to 3 (done).
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

void UR6SubActionAnimSequence::eventSequenceChanged()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_SequenceChanged), NULL);
}

void UR6SubActionAnimSequence::eventSequenceFinished()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_SequenceFinished), NULL);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
