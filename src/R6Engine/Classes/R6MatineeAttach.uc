//============================================================================//
// Class            R6MatineeAttach.uc 
// Created By       Cyrille Lauzon
// Date             
// Description      Information on Attachement for R6PlayAnimSequence
//----------------------------------------------------------------------------//
//Revision history:
// 2002/02/21	    Cyrille Lauzon: Creation
//============================================================================//
class R6MatineeAttach extends Object
    native
    notplaceable;

// --- Variables ---
var Actor m_AttachActor;
var R6Pawn m_AttachPawn;
var string m_StaticMeshTag;
var name m_PawnTag;
var bool m_bInitialized;
var Rotator m_OffsetRot;
//The <offset> position
var Vector m_OffsetPos;
var Rotator m_InteractionRot;
//The <docking> position
var Vector m_InteractionPos;
var name m_BoneName;

// --- Functions ---
function InitAttach() {}
final native function GetBoneInformation() {}
// ^ NEW IN 1.60
final native function TestLocation() {}
// ^ NEW IN 1.60
function MatineeAttach() {}
function MatineeDetach() {}

defaultproperties
{
}
