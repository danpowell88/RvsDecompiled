//=============================================================================
//  R6MuzzleGadget.uc : This is the base Class for all Silencer.
//                        this class uses the Subgun silencer.  
//                        For other meshes overload this one
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/3/20 * Created by Serge Dore
//=============================================================================
class R6MuzzleGadget extends R6AbstractGadget;

// --- Variables ---
var /* replicated */ Actor m_FPMuzzelModel;
var class<Actor> m_pFPMuzzleClass;

// --- Functions ---
simulated function UpdateAttachment(R6EngineWeapon weapOwner) {}
simulated function DestroyFPGadget() {}
simulated event Destroyed() {}
simulated function AttachFPGadget() {}

defaultproperties
{
}
