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
var class<R6Rainbow> m_RainbowTemplate;
// ^ NEW IN 1.60
var R6RainbowAI m_controller;
// ^ NEW IN 1.60
var bool m_bUseRainbowTemplate;
// ^ NEW IN 1.60
var bool m_bActivateGadget;
// ^ NEW IN 1.60
var class<R6AbstractGadget> m_SecondaryGadget;
// ^ NEW IN 1.60
var class<R6AbstractGadget> m_PrimaryGadget;
// ^ NEW IN 1.60
var class<R6AbstractWeapon> m_SecondaryWeapon;
// ^ NEW IN 1.60
var class<R6AbstractWeapon> m_PrimaryWeapon;
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
