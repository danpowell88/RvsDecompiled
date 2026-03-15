//=============================================================================
// R6FootStep - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
// Class            R6Footstep.uc 
// Created By       Cyrille Lauzon
// Date             2002/02/07
// Description      R6 base class for footstep decals.
//----------------------------------------------------------------------------//
// Modification History
//                  2002/10/09 - Rewritten by Jean-Francois Dube
//============================================================================//
class R6FootStep extends Actor
    abstract
    native
    notplaceable;

var(Rainbow) float m_fDuration;
// Dirty footsteps
var(Rainbow) float m_fDurationDirty;
var(Rainbow) float m_fDirtyTime;
var float m_fFootStepDuration;
var float m_fFootStepCurrentTime;
// Normal footsteps
var(Rainbow) Texture m_DecalLeftFootTexture;
var(Rainbow) Texture m_DecalRightFootTexture;
var(Rainbow) Texture m_DecalLeftFootTextureDirty;
var(Rainbow) Texture m_DecalRightFootTextureDirty;
var Texture m_DecalFootTexture;

defaultproperties
{
	m_fDurationDirty=10.0000000
	RemoteRole=0
	DrawType=0
	bHidden=true
	m_fSoundRadiusSaturation=150.0000000
	Texture=none
}
