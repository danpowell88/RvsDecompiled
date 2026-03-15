//=============================================================================
// R6Door - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6Door.uc : One of these actors should be placed on either side of each door
//              used for detection of pawns and for maintaining info about the 
//              surroundings.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/31 * Created by Rima Brek
//=============================================================================
class R6Door extends NavigationPoint
    native
    hidecategories(Lighting,LightColor,Karma,Force);

enum eRoomLayout
{
	ROOM_OpensCenter,               // 0
	ROOM_OpensLeft,                 // 1
	ROOM_OpensRight,                // 2
	ROOM_None                       // 3
};

// NEW IN 1.60
var() R6Door.eRoomLayout m_eRoomLayout;
var bool m_bCloseOnUntouch;
var() R6Door m_CorrespondingDoor;
var() R6IORotatingDoor m_RotatingDoor;
var Vector m_vLookDir;

function PostBeginPlay()
{
	super(Actor).PostBeginPlay();
	m_vLookDir = Vector(Rotation);
	m_vLookDir = Normal(m_vLookDir);
	return;
}

function Touch(Actor Other)
{
	local R6Pawn Pawn;
	local Rotator rPawnRot;

	Pawn = R6Pawn(Other);
	// End:0x1D
	if((Pawn == none))
	{
		return;
	}
	// End:0x53
	if(((int(Pawn.m_ePawnType) == int(3)) || (int(Pawn.m_ePawnType) == int(2))))
	{
		return;
	}
	rPawnRot = Pawn.Rotation;
	rPawnRot.Pitch = 0;
	Pawn.PotentialOpenDoor(self);
	super(Actor).Touch(Other);
	return;
}

function UnTouch(Actor Other)
{
	local R6Pawn Pawn;

	Pawn = R6Pawn(Other);
	// End:0x1D
	if((Pawn == none))
	{
		return;
	}
	Pawn.RemovePotentialOpenDoor(self);
	super(Actor).UnTouch(Other);
	return;
}

defaultproperties
{
	ExtraCost=300
	m_bExactMove=true
	bCollideWhenPlacing=false
	bCollideActors=true
	bDirectional=true
	CollisionRadius=96.0000000
	CollisionHeight=90.0000000
	Texture=Texture'R6Engine.S_DoorNavP'
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var eRoomLayout
