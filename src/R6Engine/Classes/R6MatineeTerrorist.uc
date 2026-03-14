//=============================================================================
//  R6MatineeTerrorist.uc : A placeable Terrorist Class for Matinee. 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Cyrille Lauzon
//=============================================================================
class R6MatineeTerrorist extends R6Terrorist
    native;

// --- Variables ---
var R6MatineeAttach m_MatineeAttach;
var class<R6Terrorist> m_TerroristTemplate;
// ^ NEW IN 1.60
var bool m_bUseTerroristTemplate;
// ^ NEW IN 1.60
var class<R6AbstractWeapon> m_PrimaryWeapon;
// ^ NEW IN 1.60

// --- Functions ---
function SetAttachVar(name PawnTag, string StaticMeshTag, Actor AttachActor) {}
function MatineeDetach() {}
function MatineeAttach() {}
//--------------------------------------
//PostBeginPlay
//Desc: Initialize the Terrorist, taken from
//		R6Terrorist.PostInitialize() The function is not directly
//		called because it may change. We only want to have a
//		pawn that works, no other initializations.
//--------------------------------------
event PostBeginPlay() {}

defaultproperties
{
}
