//=============================================================================
// R6MatineeActor - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MatineePawn.uc : This is a dumb actor class to add new object in a matinee scene
//			    without having to create a new class for each of them.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//  2002/03/18	    Cyrille Lauzon: Creation
//=============================================================================
class R6MatineeActor extends R6Pawn;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	// End:0x51
	if(bActorShadows)
	{
		Shadow = Spawn(Class'Engine.ShadowProjector', self, 'None', Location);
		ShadowProjector(Shadow).ShadowActor = self;
		ShadowProjector(Shadow).UpdateShadow();
	}
	return;
}

defaultproperties
{
	DrawType=1
	m_bAllowLOD=false
	bActorShadows=true
	KParams=KarmaParamsSkel'R6Engine.KarmaParamsSkel24'
}
