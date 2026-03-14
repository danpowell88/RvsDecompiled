//=============================================================================
// R6MatineePawn - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MatineePawn.uc : This is a dumb actor class to add new object in a matinee scene
//			    without having to create a new class for each of them.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//  2002/03/18	    Cyrille Lauzon: Creation
//=============================================================================
class R6MatineePawn extends R6Pawn;

function PostBeginPlay()
{
	bPhysicsAnimUpdate = true;
	StopAnimating();
	return;
}

function Tick(float DeltaTime)
{
	return;
}

defaultproperties
{
	DrawType=1
	m_bAllowLOD=false
	bActorShadows=true
	bObsolete=true
	KParams=KarmaParamsSkel'R6Engine.KarmaParamsSkel25'
}
