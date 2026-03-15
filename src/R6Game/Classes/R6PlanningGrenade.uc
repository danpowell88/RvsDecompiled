//=============================================================================
// R6PlanningGrenade - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6PlanningGrenade.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/16 * Created by Chaouky Garram
//=============================================================================
class R6PlanningGrenade extends R6ReferenceIcons;

var Texture m_pIconTex[4];  // List of the grenade icon texture

function SetGrenadeType(Object.EPlanAction eGrenade)
{
	Texture = m_pIconTex[(int(eGrenade) - 1)];
	return;
}

defaultproperties
{
	m_pIconTex[0]=Texture'R6Planning.Icons.PlanIcon_Frag'
	m_pIconTex[1]=Texture'R6Planning.Icons.PlanIcon_Flash'
	m_pIconTex[2]=Texture'R6Planning.Icons.PlanIcon_Gas'
	m_pIconTex[3]=Texture'R6Planning.Icons.PlanIcon_Smoke'
	m_bSkipHitDetection=false
	DrawScale=1.2500000
}
