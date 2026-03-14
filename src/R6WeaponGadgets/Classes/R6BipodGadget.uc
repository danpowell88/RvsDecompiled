//============================================================================//
//  R6BipodGadget.uc
//
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/29/04 * Created by Joel Tremblay
//=============================================================================
class R6BipodGadget extends R6AbstractGadget;

// --- Variables ---
var StaticMesh CloseSM;
var StaticMesh OpenSM;

// --- Functions ---
simulated function UpdateAttachment(R6EngineWeapon weapOwner) {}
simulated function Toggle3rdBipod(bool bBipodOpen) {}

defaultproperties
{
}
