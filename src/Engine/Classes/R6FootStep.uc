//============================================================================//
// Class            R6Footstep.uc 
// Created By       Cyrille Lauzon
// Date             2002/02/07
// Description      R6 base class for footstep decals.
//----------------------------------------------------------------------------//
// Modification History
//                  2002/10/09 - Rewritten by Jean-Francois Dube
//============================================================================//
class R6FootStep extends Actor
    native
    abstract;

// --- Variables ---
var Texture m_DecalLeftFootTexture;
// ^ NEW IN 1.60
var Texture m_DecalRightFootTexture;
// ^ NEW IN 1.60
var Texture m_DecalLeftFootTextureDirty;
// ^ NEW IN 1.60
var Texture m_DecalRightFootTextureDirty;
// ^ NEW IN 1.60
var float m_fDuration;
// ^ NEW IN 1.60
var float m_fDurationDirty;
// ^ NEW IN 1.60
var float m_fDirtyTime;
// ^ NEW IN 1.60
var float m_fFootStepDuration;
var float m_fFootStepCurrentTime;
var Texture m_DecalFootTexture;

defaultproperties
{
}
