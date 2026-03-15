//=============================================================================
// R6SniperRifle - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  R6SniperRifle.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6SniperRifle extends R6Weapons
    abstract;

defaultproperties
{
	m_eWeaponType=4
	m_eGripType=3
	m_bBipod=true
	m_fMaxZoom=10.0000000
	m_ScopeTexture=Texture'Inventory_t.Scope.ScopeBlurTex'
	m_ShellSingleFireSnd=Sound'CommonSniper.Play_Sniper_SingleShells'
	m_ShellEndFullAutoSnd=Sound'CommonSniper.Play_Sniper_EndShells'
	m_SniperZoomFirstSnd=Sound'CommonSniper.Play_Sniper_Zoom1rst'
	m_SniperZoomSecondSnd=Sound'CommonSniper.Play_Sniper_Zoom2nd'
	m_BipodSnd=Sound'Gadget_Bipod.Play_Bipod_Extraction'
	m_AttachPoint="TagRightHand"
	m_HoldAttachPoint="TagBack"
}
