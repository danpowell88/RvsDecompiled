//=============================================================================
// R6ExtractionZone - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6ExtractionZone.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/12 * Created by Chaouky Garram
//=============================================================================
class R6ExtractionZone extends R6
    AbstractExtractionZone
    hidecategories(Lighting,LightColor,Karma,Force);

function Touch(Actor Other)
{
	// End:0x5D
	if(__NFUN_130__(__NFUN_119__(R6Pawn(Other), none), __NFUN_119__(Level.Game, none)))
	{
		R6Pawn(Other).EnteredExtractionZone(self);
		R6AbstractGameInfo(Level.Game).EnteredExtractionZone(Other);
	}
	return;
}

function UnTouch(Actor Other)
{
	// End:0x5D
	if(__NFUN_130__(__NFUN_119__(R6Pawn(Other), none), __NFUN_119__(Level.Game, none)))
	{
		R6AbstractGameInfo(Level.Game).LeftExtractionZone(Other);
		R6Pawn(Other).LeftExtractionZone(self);
	}
	return;
}

defaultproperties
{
	bHidden=false
	m_bUseR6Availability=true
	m_bSkipHitDetection=true
	bCollideActors=true
	bCollideWorld=true
	DrawScale=12.0000000
	CollisionRadius=128.0000000
	CollisionHeight=20.0000000
	Texture=Texture'R6Planning.Icons.PlanIcon_ZoneDefault'
	m_PlanningColor=(R=24,G=134,B=181,A=255)
}
