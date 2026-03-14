//=============================================================================
//  R6TacticalLightGadget.uc : This is the base Class for all gadgets avalaible for weapons.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/02 * Created by Joel Tremblay
//=============================================================================
class R6TacticalLightGadget extends R6AbstractGadget;

// --- Variables ---
//var Actor m_TacticalBeam;         // Pointer to the tactical beam when the tactical light is activated;
//var (R6Attachment) class<Actor> m_pTacticalBeamClass;
var R6TacticalGlowLight m_GlowLight;

// --- Functions ---
simulated function UpdateAttachment(R6EngineWeapon weapOwner) {}
function ActivateGadget(optional bool bControllerInBehindView, bool bActivate) {}
simulated event Destroyed() {}

defaultproperties
{
}
