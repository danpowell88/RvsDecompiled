//=============================================================================
// R6SFX - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
// Class            R6SFX 
// Created By       Carl Lavoie
// Date             09/08/2001
// Description      R6SFX is for all SFX in the game.
//		    This is a built-in Unreal class and it shouldn't be modified.
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6SFX extends Emitter
	abstract
 placeable;

defaultproperties
{
	bNoDelete=false
	m_bDeleteOnReset=true
}
