//=============================================================================
//  R6ThermalScopeGadget.uc : This is the base Class scopes
//
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6ThermalScopeGadget extends R6AbstractGadget;

// --- Variables ---
var Actor m_FPThermalScopeModel;

// --- Functions ---
simulated function UpdateAttachment(R6EngineWeapon weapOwner) {}
simulated function DestroyFPGadget() {}
simulated event Destroyed() {}
function ActivateGadget(bool bActivate, optional bool bControllerInBehindView) {}
simulated function AttachFPGadget() {}

defaultproperties
{
}
