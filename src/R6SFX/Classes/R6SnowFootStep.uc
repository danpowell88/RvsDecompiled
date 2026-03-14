//=============================================================================
// R6SnowFootStep - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
// Class            R6SnowFootStep 
// Description      Effects spawned when a pawn walk on snow
//============================================================================//
class R6SnowFootStep extends R6FootStep;

defaultproperties
{
	m_fDurationDirty=30.0000000
	m_fDirtyTime=10.0000000
	m_DecalLeftFootTexture=Texture'R6SFX_T.FootStep.snow_footsteps_l'
	m_DecalRightFootTexture=Texture'R6SFX_T.FootStep.snow_footsteps_r'
	m_DecalLeftFootTextureDirty=Texture'R6SFX_T.FootStep.FootPrint_Left'
	m_DecalRightFootTextureDirty=Texture'R6SFX_T.FootStep.FootPrint_Right'
}
