//=============================================================================
//  R6ArrowUpIcon.uc : Up arrow for planning only.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Joel Tremblay
//=============================================================================
class R6ArrowIcon extends R6ReferenceIcons
    notplaceable;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

// --- Variables ---
var Vector m_vPointToReach;
var Vector m_vStartLocation;

state FollowPath
{
    function Tick(float DeltaTime) {}
// ^ NEW IN 1.60
    function EndState() {}
    function BeginState() {}
}

defaultproperties
{
}
