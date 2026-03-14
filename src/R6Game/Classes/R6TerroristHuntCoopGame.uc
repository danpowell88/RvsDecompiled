//=============================================================================
// R6TerroristHuntCoopGame - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6TerroristHuntCoopGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/19 * Created by Aristomenis Kolokathis Co-Op version
//=============================================================================
class R6TerroristHuntCoopGame extends R6TerroristHuntGame
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

defaultproperties
{
	m_szGameTypeFlag="RGM_TerroristHuntCoopMode"
}
