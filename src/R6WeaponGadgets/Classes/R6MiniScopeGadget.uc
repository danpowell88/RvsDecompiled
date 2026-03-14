//=============================================================================
//  R6MiniScopeGadget.uc : This is the base Class for all gadgets avalaible for weapons.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/02 * Created by Joel Tremblay
//=============================================================================
class R6MiniScopeGadget extends R6AbstractGadget;

// --- Variables ---
var Actor m_FPMiniScopeModel;
var class<Actor> m_pFPMiniScopeClass;
var Texture m_ScopeAdd;
var Texture m_ScopeTexure;

// --- Functions ---
simulated function DestroyFPGadget() {}
simulated function UpdateAttachment(R6EngineWeapon weapOwner) {}
function InitGadget(R6EngineWeapon OwnerWeapon, Pawn OwnerCharacter) {}
simulated event Destroyed() {}
function ActivateGadget(bool bActivate, optional bool bControllerInBehindView) {}
simulated function AttachFPGadget() {}

defaultproperties
{
}
