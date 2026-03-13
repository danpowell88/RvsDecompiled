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
	return 0;
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

INT UR6SubActionAnimSequence::Update(FLOAT, ASceneManager *)
{
	return 0;
}

INT UR6SubActionAnimSequence::UpdateGame(FLOAT, ASceneManager *)
{
	return 0;
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
