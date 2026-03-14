//=============================================================================
// R6ReconCoopGame - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6ReconCoopGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/14 * Created by Aristomenis Kolokathis
//=============================================================================
class R6ReconCoopGame extends R6CoOpMode
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

defaultproperties
{
	m_szGameTypeFlag="RGM_ReconCoopMode"
}
