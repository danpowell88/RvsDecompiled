//=============================================================================
// R6SoundVolume - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6SoundVolume.uc : This class allow to have sound when the player enter 
//					   and leave a Volume.  All other volume should derive this
//                     class in order to allow sound designer to reuse other 
//                     volume already placed by a level designer
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/01/13 * Created by Eric Begin
//============================================================================//
class R6SoundVolume extends Volume
    native;

var(R6Sound) Actor.ESoundSlot m_eSoundSlot;
var(R6Sound) array<Sound> m_EntrySound;
var(R6Sound) array<Sound> m_ExitSound;

simulated event Touch(Actor Other)
{
	local int iSoundIndex;
	local Controller C;
	local bool bMissionPack;

	super(Actor).Touch(Other);
	// End:0x3B
	if(Other.IsA('R6Pawn'))
	{
		C = Pawn(Other).Controller;		
	}
	else
	{
		// End:0x5F
		if(Other.IsA('R6PlayerController'))
		{
			C = Controller(Other);
		}
	}
	// End:0x190
	if((C != none))
	{
		C.m_CurrentAmbianceObject = self;
		C.m_CurrentVolumeSound = self;
		C.m_bUseExitSounds = false;
		// End:0x190
		if(((PlayerController(C) != none) && (Viewport(PlayerController(C).Player) != none)))
		{
			bMissionPack = Class'Engine.Actor'.static.GetModMgr().IsMissionPack();
			// End:0x12A
			if((!bMissionPack))
			{
				iSoundIndex = 0;
				J0xFA:

				// End:0x127 [Loop If]
				if((iSoundIndex < m_EntrySound.Length))
				{
					PlaySound(m_EntrySound[iSoundIndex], m_eSoundSlot);
					(iSoundIndex++);
					// [Loop Continue]
					goto J0xFA;
				}				
			}
			else
			{
				iSoundIndex = 0;
				J0x131:

				// End:0x190 [Loop If]
				if((iSoundIndex < m_EntrySound.Length))
				{
					// End:0x173
					if(m_bPlayOnlyOnce)
					{
						// End:0x170
						if((!m_bSoundWasPlayed))
						{
							PlaySound(m_EntrySound[iSoundIndex], m_eSoundSlot);
							m_bSoundWasPlayed = true;
						}
						// [Explicit Continue]
						goto J0x186;
					}
					PlaySound(m_EntrySound[iSoundIndex], m_eSoundSlot);
					J0x186:

					(iSoundIndex++);
					// [Loop Continue]
					goto J0x131;
				}
			}
		}
	}
	return;
}

simulated event UnTouch(Actor Other)
{
	local int iSoundIndex;
	local Controller C;

	super(Actor).UnTouch(Other);
	// End:0x3B
	if(Other.IsA('R6Pawn'))
	{
		C = Pawn(Other).Controller;		
	}
	else
	{
		// End:0x5F
		if(Other.IsA('R6PlayerController'))
		{
			C = Controller(Other);
		}
	}
	// End:0xFF
	if((C != none))
	{
		C.m_CurrentAmbianceObject = self;
		C.m_CurrentVolumeSound = self;
		C.m_bUseExitSounds = true;
		// End:0xFF
		if(((PlayerController(C) != none) && (Viewport(PlayerController(C).Player) != none)))
		{
			iSoundIndex = 0;
			J0xD2:

			// End:0xFF [Loop If]
			if((iSoundIndex < m_ExitSound.Length))
			{
				PlaySound(m_ExitSound[iSoundIndex], m_eSoundSlot);
				(iSoundIndex++);
				// [Loop Continue]
				goto J0xD2;
			}
		}
	}
	return;
}

defaultproperties
{
	m_eSoundSlot=1
	m_b3DSound=false
	m_bSeeThrough=true
}
