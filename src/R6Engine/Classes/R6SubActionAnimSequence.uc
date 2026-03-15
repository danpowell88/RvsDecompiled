//=============================================================================
// R6SubActionAnimSequence - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
// Class            R6SubActionAnimSequence.uc 
// Created By       Cyrille Lauzon
// Date             
// Description      Launches a sequence of animations.
//----------------------------------------------------------------------------//
//Revision history:
// 2002/02/19	    Cyrille Lauzon: Creation
//============================================================================//

#exec Texture Import File=Textures\R6SubActionAnimSequence.pcx Name=R6SubActionAnimSequenceIcon Mips=Off
class R6SubActionAnimSequence extends MatSubAction
    native
	editinlinenew;

//Private variables:
var int m_CurIndex;
var(R6Animation) bool m_bUseRootMotion;
var bool m_bFirstTime;
var bool m_bResetAnimation;
var(R6Animation) R6Pawn m_AffectedPawn;
var(R6Animation) Actor m_AffectedActor;
var R6PlayAnim m_CurSequence;
var(R6Animation) export editinline array<export editinline R6PlayAnim> m_Sequences;

//Events:
event Initialize()
{
	m_bFirstTime = true;
	// End:0x2B
	if(((m_AffectedPawn != none) && (m_AffectedActor == none)))
	{
		m_AffectedActor = m_AffectedPawn;
	}
	return;
}

//Called at each time we change the animation sequence:
event SequenceChanged()
{
	m_AffectedActor.SetAttachVar(m_CurSequence.m_AttachActor, m_CurSequence.m_StaticMeshTag, m_CurSequence.m_PawnTag);
	return;
}

event SequenceFinished()
{
	// End:0x28
	if(m_bUseRootMotion)
	{
		m_AffectedActor.bCollideWorld = true;
		m_AffectedActor.SetPhysics(1);
	}
	return;
}

defaultproperties
{
	m_bUseRootMotion=true
	m_bFirstTime=true
	Icon=Texture'R6Engine.R6SubActionAnimSequenceIcon'
	Desc="PlayAnimation"
}
