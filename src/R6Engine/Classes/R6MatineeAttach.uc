//=============================================================================
// R6MatineeAttach - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
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
    native;

var bool m_bInitialized;
var Actor m_AttachActor;
var R6Pawn m_AttachPawn;
var name m_PawnTag;
var name m_BoneName;
//The <docking> position
var Vector m_InteractionPos;
var Rotator m_InteractionRot;
//The <offset> position
var Vector m_OffsetPos;
var Rotator m_OffsetRot;
var string m_StaticMeshTag;

// Export UR6MatineeAttach::execGetBoneInformation(FFrame&, void* const)
native(2907) final function GetBoneInformation();

// Export UR6MatineeAttach::execTestLocation(FFrame&, void* const)
native(2908) final function TestLocation();

function InitAttach()
{
	local Vector MeshPos;
	local Rotator MeshRot;

	// End:0x7C
	if(((m_PawnTag != 'None') && (m_AttachActor != none)))
	{
		GetBoneInformation();
		m_AttachActor.GetTagInformations(m_StaticMeshTag, MeshPos, MeshRot);
		m_InteractionPos = (m_AttachActor.Location + MeshPos);
		m_InteractionRot = (m_AttachActor.Rotation + MeshRot);
		m_bInitialized = true;		
	}
	else
	{
		m_bInitialized = false;
	}
	return;
}

function MatineeAttach()
{
	// End:0x4D
	if((m_bInitialized == true))
	{
		m_AttachPawn.AttachToBone(m_AttachActor, m_BoneName);
		m_AttachActor.SetRelativeLocation(m_OffsetPos);
		m_AttachActor.SetRelativeRotation(m_OffsetRot);
	}
	return;
}

function MatineeDetach()
{
	local Vector Location;
	local Rotator Rotation;

	// End:0x20
	if((m_bInitialized == true))
	{
		m_AttachPawn.DetachFromBone(m_AttachActor);
	}
	return;
}

