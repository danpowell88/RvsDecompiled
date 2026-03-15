//=============================================================================
// R6LimitedSFX - extracted from retail RavenShield 1.60
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
class R6LimitedSFX extends R6SFX
    abstract
    placeable;

simulated function PostBeginPlay()
{
	// End:0x4A
	if((Level.m_aLimitedSFX[Level.m_iLimitedSFXCount] != none))
	{
		Level.m_aLimitedSFX[Level.m_iLimitedSFXCount].Kill();
	}
	Level.m_aLimitedSFX[Level.m_iLimitedSFXCount] = self;
	(Level.m_iLimitedSFXCount++);
	// End:0x9E
	if((Level.m_iLimitedSFXCount == 6))
	{
		Level.m_iLimitedSFXCount = 0;
	}
	return;
}

