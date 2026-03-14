//=============================================================================
//  R6SilencerGadget.uc : This is the base Class for all Silencer.
//                        this class uses the Subgun silencer.  
//                        For other meshes overload this one
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/1/31 * Created by Joel Tremblay
//=============================================================================
class R6SilencerGadget extends R6AbstractGadget;

// --- Variables ---
var Actor m_FPSilencerModel;
var class<Actor> m_pFPSilencerClass;

// --- Functions ---
simulated function Vector GetGadgetMuzzleOffset() {}
// ^ NEW IN 1.60
simulated function AttachFPGadget() {}
simulated function UpdateAttachment(R6EngineWeapon weapOwner) {}
simulated function DestroyFPGadget() {}
simulated event Destroyed() {}

defaultproperties
{
}
