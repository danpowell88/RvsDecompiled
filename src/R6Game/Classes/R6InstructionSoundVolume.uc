//=============================================================================
// R6InstructionSoundVolume - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6SoundInstructionVolume.uc : Use for the player in the map training.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/06/20 * Created by Serge Dore
//============================================================================//
class R6InstructionSoundVolume extends R6SoundVolume
    native;

const TimeBetweenStep = 15;

var(R6Sound) int m_iBoxNumber;
var int m_iSoundIndex;
var int m_iHudStep;  // Current Step hud for internal use only
var int m_IDHudStep;  // ID for display many thing on the HUD.
var int m_fTimerStep;  // When no sound use the timer
var bool m_bSoundIsPlaying;
var float m_fTime;  // use for wait 1 sec to not call IsSoundPlaying at each trame
var float m_fTimerSound;  // Currently time for the sound
var float m_fTimeHud;  // Time get in the INT file.
var(R6Sound) Sound m_sndIntructionSoundStop;
var R6TrainingMgr m_TrainingMgr;

// Export UR6InstructionSoundVolume::execUseSound(FFrame&, void* const)
native(2732) final function bool UseSound();

simulated function ResetOriginalData()
{
	m_bSoundIsPlaying = false;
	m_iSoundIndex = 0;
	m_fTime = 0.0000000;
	m_fTimerStep = 0;
	return;
}

simulated event Touch(Actor Other)
{
	local Controller C;

	// End:0x40
	if(Other.__NFUN_303__('R6Pawn'))
	{
		Other.m_CurrentVolumeSound = self;
		C = Pawn(Other).Controller;		
	}
	else
	{
		// End:0x64
		if(Other.__NFUN_303__('R6PlayerController'))
		{
			C = Controller(Other);
		}
	}
	// End:0x175
	if(__NFUN_119__(C, none))
	{
		C.m_CurrentAmbianceObject = self;
		C.m_CurrentVolumeSound = self;
		// End:0x175
		if(__NFUN_130__(__NFUN_130__(__NFUN_129__(m_bSoundIsPlaying), __NFUN_119__(PlayerController(C), none)), __NFUN_119__(Viewport(PlayerController(C).Player), none)))
		{
			m_iSoundIndex = 0;
			m_TrainingMgr = R6GameInfo(C.Level.Game).GetTrainingMgr(R6Pawn(C.Pawn));
			// End:0x175
			if(__NFUN_129__(R6Console(m_TrainingMgr.m_Player.Player.Console).m_bStartR6GameInProgress))
			{
				R6HUD(m_TrainingMgr.m_Player.myHUD).__NFUN_1609__(m_iBoxNumber, 0);
				ChangeTextAndSound();
			}
		}
	}
	return;
}

simulated event UnTouch(Actor Other)
{
	local Controller C;

	// End:0x30
	if(Other.__NFUN_303__('R6Pawn'))
	{
		C = Pawn(Other).Controller;		
	}
	else
	{
		// End:0x54
		if(Other.__NFUN_303__('R6PlayerController'))
		{
			C = Controller(Other);
		}
	}
	// End:0x6F
	if(__NFUN_119__(C, none))
	{
		C.m_CurrentAmbianceObject = self;
	}
	return;
}

function SkipToNextInstruction()
{
	__NFUN_264__(m_sndIntructionSoundStop, 10);
	m_iHudStep = 0;
	J0x11:

	// End:0x66 [Loop If]
	if(__NFUN_150__(m_iHudStep, 4))
	{
		SetHudStep();
		// End:0x5C
		if(__NFUN_155__(m_IDHudStep, 0))
		{
			R6HUD(m_TrainingMgr.m_Player.myHUD).__NFUN_1609__(m_iBoxNumber, m_IDHudStep, false);
		}
		__NFUN_165__(m_iHudStep);
		// [Loop Continue]
		goto J0x11;
	}
	__NFUN_165__(m_iSoundIndex);
	ChangeTextAndSound();
	return;
}

function StopInstruction()
{
	__NFUN_264__(m_sndIntructionSoundStop, 10);
	R6Console(m_TrainingMgr.m_Player.Player.Console).LaunchInstructionMenu(self, false, 0, 0);
	m_iSoundIndex = m_EntrySound.Length;
	m_bSoundIsPlaying = false;
	return;
}

function ChangeTextAndSound()
{
	// End:0x1B
	if(__NFUN_129__(m_TrainingMgr.CanChangeText(m_iBoxNumber)))
	{
		return;
	}
	// End:0x59
	if(__NFUN_151__(m_ExitSound.Length, m_iSoundIndex))
	{
		m_sndIntructionSoundStop = m_ExitSound[m_iSoundIndex];
		// End:0x59
		if(__NFUN_119__(m_sndIntructionSoundStop, none))
		{
			m_bUseExitSounds = true;
			__NFUN_264__(m_sndIntructionSoundStop, 10);
		}
	}
	// End:0x117
	if(__NFUN_151__(m_EntrySound.Length, m_iSoundIndex))
	{
		m_bUseExitSounds = false;
		m_bSoundIsPlaying = true;
		m_fTimerSound = 0.0000000;
		m_iHudStep = 0;
		SetHudStep();
		R6PlayerController(m_TrainingMgr.m_Player).m_bDisplayMessage = true;
		__NFUN_264__(m_EntrySound[m_iSoundIndex], 10);
		R6Console(m_TrainingMgr.m_Player.Player.Console).LaunchInstructionMenu(self, true, m_iBoxNumber, m_iSoundIndex);
		m_TrainingMgr.LaunchAction(m_iBoxNumber, m_iSoundIndex);		
	}
	else
	{
		R6PlayerController(m_TrainingMgr.m_Player).m_bDisplayMessage = false;
		R6Console(m_TrainingMgr.m_Player.Player.Console).LaunchInstructionMenu(self, false, 0, 0);
	}
	return;
}

function Tick(float DeltaTime)
{
	super(Actor).Tick(DeltaTime);
	// End:0x118
	if(m_bSoundIsPlaying)
	{
		// End:0x76
		if(__NFUN_177__(m_fTimeHud, float(0)))
		{
			__NFUN_184__(m_fTimerSound, DeltaTime);
			// End:0x76
			if(__NFUN_177__(m_fTimerSound, m_fTimeHud))
			{
				R6HUD(m_TrainingMgr.m_Player.myHUD).__NFUN_1609__(m_iBoxNumber, m_IDHudStep);
				__NFUN_165__(m_iHudStep);
				SetHudStep();
			}
		}
		__NFUN_184__(m_fTime, DeltaTime);
		// End:0x118
		if(__NFUN_177__(m_fTime, 1.0000000))
		{
			// End:0x100
			if(__NFUN_150__(m_iSoundIndex, m_EntrySound.Length))
			{
				// End:0xE3
				if(__NFUN_132__(__NFUN_129__(__NFUN_2732__()), __NFUN_114__(m_EntrySound[m_iSoundIndex], none)))
				{
					// End:0xD3
					if(__NFUN_150__(m_fTimerStep, 15))
					{
						__NFUN_161__(m_fTimerStep, 1);						
					}
					else
					{
						m_fTimerStep = 0;
						ReadyToChangeText();
					}					
				}
				else
				{
					// End:0xFD
					if(__NFUN_129__(__NFUN_2703__(self, m_EntrySound[m_iSoundIndex])))
					{
						ReadyToChangeText();
					}
				}				
			}
			else
			{
				ReadyToChangeText();
			}
			m_fTime = __NFUN_175__(m_fTime, 1.0000000);
		}
	}
	return;
}

function ReadyToChangeText()
{
	m_bSoundIsPlaying = false;
	// End:0x32
	if(__NFUN_114__(m_TrainingMgr.m_Player.m_CurrentVolumeSound, self))
	{
		__NFUN_165__(m_iSoundIndex);
		ChangeTextAndSound();
	}
	return;
}

function SetHudStep()
{
	m_fTimeHud = 0.0000000;
	m_IDHudStep = 0;
	switch(m_iBoxNumber)
	{
		// End:0x72
		case 1:
			// End:0x6F
			if(__NFUN_130__(__NFUN_154__(m_iSoundIndex, 0), __NFUN_154__(m_iHudStep, 0)))
			{
				m_fTimeHud = float(Localize("BasicAreaBox1", "HUDStep0", "R6Training"));
				m_IDHudStep = 1;
			}
			// End:0x511
			break;
		// End:0xCD
		case 2:
			// End:0xCA
			if(__NFUN_130__(__NFUN_154__(m_iSoundIndex, 0), __NFUN_154__(m_iHudStep, 0)))
			{
				m_fTimeHud = float(Localize("BasicAreaBox2", "HUDStep0", "R6Training"));
				m_IDHudStep = 2;
			}
			// End:0x511
			break;
		// End:0x128
		case 3:
			// End:0x125
			if(__NFUN_130__(__NFUN_154__(m_iSoundIndex, 0), __NFUN_154__(m_iHudStep, 0)))
			{
				m_fTimeHud = float(Localize("BasicAreaBox3", "HUDStep0", "R6Training"));
				m_IDHudStep = 3;
			}
			// End:0x511
			break;
		// End:0x2B6
		case 8:
			switch(m_iSoundIndex)
			{
				// End:0x1CF
				case 0:
					switch(m_iHudStep)
					{
						// End:0x184
						case 0:
							m_fTimeHud = float(Localize("ShootingAreaBox1", "HUDStep0", "R6Training"));
							m_IDHudStep = 4;
							// End:0x1CC
							break;
						// End:0x1C9
						case 1:
							m_fTimeHud = float(Localize("ShootingAreaBox1", "HUDStep1", "R6Training"));
							m_IDHudStep = 5;
							// End:0x1CC
							break;
						// End:0xFFFF
						default:
							break;
					}
					// End:0x2B3
					break;
				// End:0x2B0
				case 1:
					switch(m_iHudStep)
					{
						// End:0x21F
						case 0:
							m_fTimeHud = float(Localize("ShootingAreaBox1", "HUDStep2", "R6Training"));
							m_IDHudStep = 6;
							// End:0x2AD
							break;
						// End:0x264
						case 1:
							m_fTimeHud = float(Localize("ShootingAreaBox1", "HUDStep3", "R6Training"));
							m_IDHudStep = 7;
							// End:0x2AD
							break;
						// End:0x2AA
						case 2:
							m_fTimeHud = float(Localize("ShootingAreaBox1", "HUDStep4", "R6Training"));
							m_IDHudStep = 8;
							// End:0x2AD
							break;
						// End:0xFFFF
						default:
							break;
					}
					// End:0x2B3
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0x511
			break;
		// End:0x35F
		case 21:
			// End:0x35C
			if(__NFUN_154__(m_iSoundIndex, 0))
			{
				switch(m_iHudStep)
				{
					// End:0x313
					case 0:
						m_fTimeHud = float(Localize("RoomClearing1Box1", "HUDStep0", "R6Training"));
						m_IDHudStep = 9;
						// End:0x35C
						break;
					// End:0x359
					case 1:
						m_fTimeHud = float(Localize("RoomClearing1Box1", "HUDStep1", "R6Training"));
						m_IDHudStep = 10;
						// End:0x35C
						break;
					// End:0xFFFF
					default:
						break;
				}
			}
			else
			{
				// End:0x511
				break;/* !MISMATCHING REMOVE, tried Case got Type:Else Position:0x35C! */
			// End:0x4AC
			case 22:
				switch(m_iSoundIndex)
				{
					// End:0x3C2
					case 0:
						switch(m_iHudStep)
						{
							// End:0x3BC
							case 0:
								m_fTimeHud = float(Localize("RoomClearing1Box2", "HUDStep0", "R6Training"));
								m_IDHudStep = 11;
								// End:0x3BF
								break;
							// End:0xFFFF
							default:
								break;
						}
						// End:0x4A9
						break;
					// End:0x4A6
					case 1:
						switch(m_iHudStep)
						{
							// End:0x413
							case 0:
								m_fTimeHud = float(Localize("RoomClearing1Box2", "HUDStep1", "R6Training"));
								m_IDHudStep = 12;
								// End:0x4A3
								break;
							// End:0x459
							case 1:
								m_fTimeHud = float(Localize("RoomClearing1Box2", "HUDStep2", "R6Training"));
								m_IDHudStep = 13;
								// End:0x4A3
								break;
							// End:0x4A0
							case 2:
								m_fTimeHud = float(Localize("RoomClearing1Box2", "HUDStep3", "R6Training"));
								m_IDHudStep = 14;
								// End:0x4A3
								break;
							// End:0xFFFF
							default:
								break;
						}
						// End:0x4A9
						break;
					// End:0xFFFF
					default:
						break;
				}
				// End:0x511
				break;
			// End:0x50B
			case 24:
				// End:0x508
				if(__NFUN_130__(__NFUN_154__(m_iSoundIndex, 0), __NFUN_154__(m_iHudStep, 0)))
				{
					m_fTimeHud = float(Localize("RoomClearing2Box1", "HUDStep0", "R6Training"));
					m_IDHudStep = 15;
				}
				// End:0x511
				break;
			// End:0xFFFF
			default:
				// End:0x511
				break;
				break;
		}/* !MISMATCHING REMOVE, tried Switch got Type:Case Position:0x2B6! */
		return;
	}/* !MISMATCHING REMOVE, tried Else got Type:Switch Position:0x012! */
}

defaultproperties
{
	m_eSoundSlot=10
	bStatic=false
	bNoDelete=false
}
