//=============================================================================
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
    notplaceable;

#exec Texture Import File=Textures\S_DoorNavP.bmp Name=S_DoorNavP Mips=Off MASKED=1

// --- Enums ---
enum eRoomLayout
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var R6IORotatingDoor m_RotatingDoor;   // The interactive rotating door object attached to this door actor
// ^ NEW IN 1.60
var R6Door m_CorrespondingDoor;      // The paired door actor on the other side of a double door
// ^ NEW IN 1.60
var eRoomLayout m_eRoomLayout;       // Room layout hint used by AI pathfinding around this door
// ^ NEW IN 1.60
var Vector m_vLookDir;
var bool m_bCloseOnUntouch;

// --- Functions ---
function UnTouch(Actor Other) {}
function Touch(Actor Other) {}
function PostBeginPlay() {}

defaultproperties
{
}
