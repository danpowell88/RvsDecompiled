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
    native;

// --- Variables ---
var bool m_bActive;
// ^ NEW IN 1.60
var array<array> m_Decals;
// ^ NEW IN 1.60
var eDecalType m_Type;
// ^ NEW IN 1.60
//Position of the current element to remove/add
var int m_iDecalPos;
var int m_MaxSize;
// ^ NEW IN 1.60

// --- Functions ---
final native function AddDecal(Vector Position, Rotator Rotation, Texture decalTexture, int iFov, float fDuration, float fStartTime, float fMaxTraceDistance, optional float fCullDistance) {}
final native function DeActivateGroup() {}
final native function ActivateGroup() {}
final native function KillDecal() {}

defaultproperties
{
}
