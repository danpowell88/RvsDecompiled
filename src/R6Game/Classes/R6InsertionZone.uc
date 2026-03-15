//=============================================================================
// R6InsertionZone - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6InsertionZone.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/12 * Created by Chaouky Garram
//=============================================================================
class R6InsertionZone extends R6
    AbstractInsertionZone
    hidecategories(Lighting,LightColor,Karma,Force);

defaultproperties
{
	bHidden=false
	m_bUseR6Availability=true
	bUnlit=true
	Texture=Texture'R6Planning.Icons.PlanIcon_ZoneDefault'
	m_PlanningColor=(R=24,G=134,B=181,A=255)
}
