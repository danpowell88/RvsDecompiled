//============================================================================//
// Class            R6SubActionLookAt.uc 
// Created By       Cyrille Lauzon
// Date             
// Description      Makes the head of the Actor look at an other actor
//----------------------------------------------------------------------------//
//Revision history:
// 2002/02/19	    Cyrille Lauzon: Creation
//============================================================================//
class R6SubActionLookAt extends MatSubAction
    native;

#exec Texture Import File=Textures\R6SubActionLookAt.pcx Name=R6SubActionLookAtIcon Mips=Off

// --- Variables ---
var R6Pawn m_AffectedPawn;
var Actor m_TargetActor;
var bool m_bAim;
var bool m_bNoBlend;

defaultproperties
{
}
