//=============================================================================
// R6TacticalGlowLight - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6TacticalGlowLight.uc : Fading light depending on the view angle.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Jean-Francois Dube
//    2001/11/02 * Added net support (Aristo Kolokathis)
//=============================================================================
class R6TacticalGlowLight extends R6GlowLight;

defaultproperties
{
	RemoteRole=2
	LightEffect=12
	LightHue=255
	LightCone=20
	bNoDelete=false
	bDynamicLight=true
	bCanTeleport=true
	bAlwaysRelevant=true
	m_bDrawFromBase=true
	bMovable=true
	LightBrightness=255.0000000
	LightRadius=96.0000000
	bCoronaMUL2XFactor=1.0000000
	Texture=none
	Skins=/* Array type was not detected. */
}
