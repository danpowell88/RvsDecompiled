//=============================================================================
// R6SubActionLookAt - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
// Class            R6SubActionLookAt.uc 
// Created By       Cyrille Lauzon
// Date             
// Description      Makes the head of the Actor look at an other actor
//----------------------------------------------------------------------------//
//Revision history:
// 2002/02/19	    Cyrille Lauzon: Creation
//============================================================================//

#exec Texture Import File=Textures\R6SubActionLookAt.pcx Name=R6SubActionLookAtIcon Mips=Off
class R6SubActionLookAt extends MatSubAction
	native
	editinlinenew;

var(R6LookAt) bool m_bAim;
var(R6LookAt) bool m_bNoBlend;
var(R6LookAt) R6Pawn m_AffectedPawn;
var(R6LookAt) Actor m_TargetActor;

defaultproperties
{
	Icon=Texture'R6Engine.R6SubActionLookAtIcon'
	Desc="LookAtActor"
}
