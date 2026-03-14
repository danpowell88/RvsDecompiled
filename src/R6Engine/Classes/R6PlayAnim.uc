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
var name m_PawnTag;              // Tag of the pawn actor to animate
// ^ NEW IN 1.60
var string m_StaticMeshTag;       // Tag of the static mesh actor to animate
// ^ NEW IN 1.60
var Actor m_AttachActor;          // Actor the animating object is attached to
// ^ NEW IN 1.60
var name m_Sequence;              // Name of the animation sequence to play
// ^ NEW IN 1.60
var float m_Rate;                 // Playback rate multiplier for the animation (1.0 = normal speed)
// ^ NEW IN 1.60
var float m_TweenTime;            // Blend time in seconds to tween into this animation
// ^ NEW IN 1.60
var bool m_bLoopAnim;             // If true, animation loops continuously
// ^ NEW IN 1.60
var int m_MaxPlayTime;            // Maximum play duration in seconds (0 = play once to completion)
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
