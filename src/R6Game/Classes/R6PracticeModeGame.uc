//=============================================================================
// R6PracticeModeGame - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6PracticeModeGame.uc : Same as terrorist hunt mode, for now
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/12 * Created by Sebastien Lussier (from R6TerroristHuntGame.uc)
//=============================================================================
class R6PracticeModeGame extends R6StoryModeGame
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

defaultproperties
{
	m_bUsingPlayerCampaign=false
	m_szGameTypeFlag="RGM_PracticeMode"
}
