//=============================================================================
//  R6EnvironmentNode.uc : nodes that contain information about the environment,
//                          location of walls, corners, etc...
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/20 * Created by Rima Brek
//=============================================================================
class R6EnvironmentNode extends Actor
    native;

// --- Variables ---
var Vector m_vLookDir;

// --- Functions ---
function PostBeginPlay() {}
function Touch(Actor Other) {}
function UnTouch(Actor Other) {}

defaultproperties
{
}
