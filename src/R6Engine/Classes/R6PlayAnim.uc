//============================================================================//
// Class            R6PlayAnim.uc 
// Created By       Cyrille Lauzon
// Date             
// Description      Describes an animation for R6SubActionAnimSequence
//----------------------------------------------------------------------------//
//Revision history:
// 2002/02/19	    Cyrille Lauzon: Creation
//============================================================================//
class R6PlayAnim extends Object
    native;

// --- Variables ---
var name m_PawnTag;
// ^ NEW IN 1.60
var string m_StaticMeshTag;
// ^ NEW IN 1.60
var Actor m_AttachActor;
// ^ NEW IN 1.60
var name m_Sequence;
// ^ NEW IN 1.60
var float m_Rate;
// ^ NEW IN 1.60
var float m_TweenTime;
// ^ NEW IN 1.60
var bool m_bLoopAnim;
// ^ NEW IN 1.60
var int m_MaxPlayTime;
// ^ NEW IN 1.60
//Private variables------
var int m_PlayedTime;
var bool m_bStarted;
//true if we are about to start the anim
var bool m_bFirstTime;
//Relative Position in Scene:
var float m_fBeginPct;
var float m_fEndPct;
//Animation Info:
var int m_iFrameNumber;

// --- Functions ---
//Events:
event AnimFinished() {}

defaultproperties
{
}
