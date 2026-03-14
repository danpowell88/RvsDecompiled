//============================================================================//
// Class            R6SubActionAnimSequence.uc 
// Created By       Cyrille Lauzon
// Date             
// Description      Launches a sequence of animations.
//----------------------------------------------------------------------------//
//Revision history:
// 2002/02/19	    Cyrille Lauzon: Creation
//============================================================================//
class R6SubActionAnimSequence extends MatSubAction
    native;

#exec Texture Import File=Textures\R6SubActionAnimSequence.pcx Name=R6SubActionAnimSequenceIcon Mips=Off

// --- Variables ---
var Actor m_AffectedActor;
// ^ NEW IN 1.60
var R6PlayAnim m_CurSequence;
var R6Pawn m_AffectedPawn;
// ^ NEW IN 1.60
var bool m_bUseRootMotion;
// ^ NEW IN 1.60
var bool m_bFirstTime;
var array<array> m_Sequences;
// ^ NEW IN 1.60
//Private variables:
var int m_CurIndex;
var bool m_bResetAnimation;

// --- Functions ---
//Events:
event Initialize() {}
//Called at each time we change the animation sequence:
event SequenceChanged() {}
event SequenceFinished() {}

defaultproperties
{
}
