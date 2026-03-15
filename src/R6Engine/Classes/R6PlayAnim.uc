//=============================================================================
// R6PlayAnim - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
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
    native
	editinlinenew;

var() int m_MaxPlayTime;
//Private variables------
var int m_PlayedTime;
//Animation Info:
var int m_iFrameNumber;
var() bool m_bLoopAnim;
var bool m_bStarted;
var bool m_bFirstTime;  // true if we are about to start the anim
var() float m_Rate;
var() float m_TweenTime;
//Relative Position in Scene:
var float m_fBeginPct;
var float m_fEndPct;
//Matinee Attach/Detach
var(R6Attach) Actor m_AttachActor;
var() name m_Sequence;
var(R6Attach) name m_PawnTag;
var(R6Attach) string m_StaticMeshTag;

//Events:
event AnimFinished()
{
	return;
}

defaultproperties
{
	m_MaxPlayTime=1
	m_bLoopAnim=true
	m_bFirstTime=true
	m_Rate=1.0000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_iStage
// REMOVED IN 1.60: var m_fAlpha
// REMOVED IN 1.60: var m_fInTime
// REMOVED IN 1.60: var m_fOutTime
// REMOVED IN 1.60: var m_BoneName
