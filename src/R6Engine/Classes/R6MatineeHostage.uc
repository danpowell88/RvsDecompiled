//=============================================================================
//  R6MatineeHostage.uc : A placeable Hostage Class for Matinee. 
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Cyrille Lauzon
//=============================================================================
class R6MatineeHostage extends R6Hostage
    native;

#exec OBJ LOAD FILE=..\Animations\R6Hostage_UKX.ukx PACKAGE=R6Hostage_UKX

// --- Variables ---
//Private Variables:
var R6MatineeAttach m_MatineeAttach;
var class<R6Hostage> m_HostageTemplate;
// ^ NEW IN 1.60
var bool m_bUseHostageTemplate;
// ^ NEW IN 1.60

// --- Functions ---
function SetAttachVar(name PawnTag, string StaticMeshTag, Actor AttachActor) {}
function MatineeDetach() {}
function MatineeAttach() {}
event PostBeginPlay() {}

defaultproperties
{
}
