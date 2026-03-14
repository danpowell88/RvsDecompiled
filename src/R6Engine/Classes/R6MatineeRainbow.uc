//=============================================================================
//  R6MatineeRainbow.uc : A placeable Rainbow Class for Matinee. 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Cyrille Lauzon
//=============================================================================
class R6MatineeRainbow extends R6Rainbow
    native;

// --- Variables ---
// var ? m_Controller; // REMOVED IN 1.60
var R6MatineeAttach m_MatineeAttach;
var class<R6Rainbow> m_RainbowTemplate;  // Rainbow operator class to use when UseRainbowTemplate is enabled
// ^ NEW IN 1.60
var R6RainbowAI m_controller;    // The AI controller driving this matinee Rainbow actor
// ^ NEW IN 1.60
var bool m_bUseRainbowTemplate;  // Override the level-placed Rainbow with the template class
// ^ NEW IN 1.60
var bool m_bActivateGadget;      // Activate the operator's gadget at the start of this matinee sequence
// ^ NEW IN 1.60
var class<R6AbstractGadget> m_SecondaryGadget;  // Secondary gadget class assigned to this matinee operator
// ^ NEW IN 1.60
var class<R6AbstractGadget> m_PrimaryGadget;   // Primary gadget class assigned to this matinee operator
// ^ NEW IN 1.60
var class<R6AbstractWeapon> m_SecondaryWeapon;  // Secondary weapon class assigned to this matinee operator
// ^ NEW IN 1.60
var class<R6AbstractWeapon> m_PrimaryWeapon;   // Primary weapon class assigned to this matinee operator
// ^ NEW IN 1.60

// --- Functions ---
function SetAttachVar(name PawnTag, string StaticMeshTag, Actor AttachActor) {}
function MatineeDetach() {}
function MatineeAttach() {}
function SetMovementPhysics() {}
//--------------------------------------
//PostBeginPlay
//Desc: Initialize the Rainbow
//--------------------------------------
event PostBeginPlay() {}

defaultproperties
{
}
