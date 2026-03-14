//=============================================================================
// R6DecalGroup - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
// Class            R6DecalGroup.uc 
// Created By       Cyrille Lauzon
// Date             2001/01/18
// Description      Defines a group of Decals for the manager
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6DecalGroup extends Actor
	native
 notplaceable;

var() R6DecalManager.eDecalType m_Type;  // Decal type it can contain
var() int m_MaxSize;  // The maximum number of elements the group can contain
var int m_iDecalPos;  // Position of the current element to remove/add
var() bool m_bActive;
//Should not be manipulated directly!-------
var() array<R6Decal> m_Decals;

// Export UR6DecalGroup::execAddDecal(FFrame&, void* const)
 native(2902) final function AddDecal(Vector Position, Rotator Rotation, Texture decalTexture, int iFov, float fDuration, float fStartTime, float fMaxTraceDistance, optional float fCullDistance);

// Export UR6DecalGroup::execKillDecal(FFrame&, void* const)
 native(2903) final function KillDecal();

// Export UR6DecalGroup::execActivateGroup(FFrame&, void* const)
 native(2904) final function ActivateGroup();

// Export UR6DecalGroup::execDeActivateGroup(FFrame&, void* const)
 native(2905) final function DeActivateGroup();

defaultproperties
{
	m_MaxSize=150
	bHidden=true
}
