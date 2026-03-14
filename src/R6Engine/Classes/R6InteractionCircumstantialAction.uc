//=============================================================================
// R6InteractionCircumstantialAction - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6InteractionCircumstantialAction.uc : Interaction associated with the inventory.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/21 * Created by S�bastien Lussier
//=============================================================================
class R6InteractionCircumstantialAction extends R6InteractionRoseDesVents;

enum eCircumstantialActionPerformer
{
	CACTION_Player,                 // 0
	CACTION_Team,                   // 1
	CACTION_TeamFromList,           // 2
	CACTION_TeamFromListZulu        // 3
};

var Texture m_TexProgressCircle;
var Texture m_TexProgressItem;
var Texture m_TexFakeReticule;
var Font m_SmallFont_14pt;

event Initialized()
{
	super.Initialized();
	return;
}

function ActionKeyPressed()
{
	// End:0x31
	if(__NFUN_155__(int(m_Player.Level.NetMode), int(NM_Standalone)))
	{
		m_Player.ServerActionKeyPressed();
	}
	m_Player.SetRequestedCircumstantialAction();
	// End:0xA8
	if(__NFUN_154__(int(m_Player.m_RequestedCircumstantialAction.iHasAction), 1))
	{
		m_Player.m_RequestedCircumstantialAction.m_bNeedsTick = true;
		m_Player.m_RequestedCircumstantialAction.m_fPressedTime = m_Player.Level.TimeSeconds;
	}
	return;
}

// Action button was released
function ActionKeyReleased()
{
	m_Player.ServerActionKeyReleased();
	m_Player.SetRequestedCircumstantialAction();
	m_Player.m_RequestedCircumstantialAction.m_bNeedsTick = false;
	m_Player.m_RequestedCircumstantialAction.m_fPressedTime = 0.0000000;
	// End:0xAE
	if(m_Player.PlayerCanSwitchToAIBackup())
	{
		// End:0xAB
		if(__NFUN_130__(__NFUN_119__(m_Player.Pawn, none), __NFUN_129__(m_Player.Pawn.IsAlive())))
		{
			m_Player.RegroupOnMe();
			return;
		}		
	}
	else
	{
		// End:0xD1
		if(m_Player.m_bReadyToEnterSpectatorMode)
		{
			m_Player.EnterSpectatorMode();
			return;
		}
	}
	// End:0xF9
	if(__NFUN_155__(int(m_Player.m_RequestedCircumstantialAction.iHasAction), 1))
	{
		DisplayMenu(false);
		return;
	}
	// End:0x135
	if(__NFUN_155__(int(m_Player.m_RequestedCircumstantialAction.iInRange), 1))
	{
		m_Player.m_InteractionCA.PerformCircumstantialAction(1);		
	}
	else
	{
		// End:0x1E0
		if(__NFUN_130__(__NFUN_130__(m_Player.m_pawn.CanInteractWithObjects(), __NFUN_154__(int(m_Player.m_RequestedCircumstantialAction.iInRange), 1)), __NFUN_129__(m_Player.m_RequestedCircumstantialAction.bCanBeInterrupted)))
		{
			// End:0x1C3
			if(__NFUN_114__(m_Player.m_RequestedCircumstantialAction.aQueryTarget, m_Player))
			{
				m_Player.RegroupOnMe();				
			}
			else
			{
				m_Player.m_InteractionCA.PerformCircumstantialAction(0);
			}			
		}
		else
		{
			// End:0x26A
			if(m_Player.m_RequestedCircumstantialAction.aQueryTarget.__NFUN_303__('R6IORotatingDoor'))
			{
				// End:0x26A
				if(R6IORotatingDoor(m_Player.m_RequestedCircumstantialAction.aQueryTarget).m_bIsDoorLocked)
				{
					R6Pawn(m_Player.Pawn).ServerPerformDoorAction(R6IORotatingDoor(m_Player.m_RequestedCircumstantialAction.aQueryTarget), 14);
				}
			}
		}
	}
	DisplayMenu(false);
	return;
}

simulated function bool MenuItemEnabled(int iItem)
{
	local bool bActionCanBeExecuted;
	local int iSubMenuChoice;

	iSubMenuChoice = __NFUN_146__(__NFUN_144__(m_iCurrentSubMnuChoice, 4), iItem);
	// End:0x31
	if(__NFUN_132__(__NFUN_150__(iItem, 0), __NFUN_151__(iItem, 3)))
	{
		return false;
	}
	// End:0x8F
	if(__NFUN_155__(m_iCurrentSubMnuChoice, -1))
	{
		bActionCanBeExecuted = m_Player.m_CurrentCircumstantialAction.aQueryTarget.R6ActionCanBeExecuted(int(m_Player.m_CurrentCircumstantialAction.iTeamSubActionsIDList[iSubMenuChoice]), m_Player);		
	}
	else
	{
		// End:0x103
		if(__NFUN_155__(int(m_Player.m_CurrentCircumstantialAction.iTeamActionIDList[iItem]), 0))
		{
			bActionCanBeExecuted = m_Player.m_CurrentCircumstantialAction.aQueryTarget.R6ActionCanBeExecuted(int(m_Player.m_CurrentCircumstantialAction.iTeamActionIDList[iItem]), m_Player);			
		}
		else
		{
			bActionCanBeExecuted = false;
		}
	}
	return bActionCanBeExecuted;
	return;
}

function bool CurrentItemHasSubMenu()
{
	local int i;

	// End:0x11
	if(__NFUN_155__(m_iCurrentSubMnuChoice, -1))
	{
		return false;
	}
	i = __NFUN_144__(m_iCurrentMnuChoice, 4);
	J0x20:

	// End:0x67 [Loop If]
	if(__NFUN_150__(i, __NFUN_144__(__NFUN_146__(m_iCurrentMnuChoice, 1), 4)))
	{
		// End:0x5D
		if(__NFUN_155__(int(m_Player.m_CurrentCircumstantialAction.iTeamSubActionsIDList[i]), 0))
		{
			return true;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x20;
	}
	return false;
	return;
}

function bool ItemHasSubMenu(int iItem)
{
	local int i;

	// End:0x11
	if(__NFUN_155__(m_iCurrentSubMnuChoice, -1))
	{
		return false;
	}
	i = __NFUN_144__(iItem, 4);
	J0x20:

	// End:0x67 [Loop If]
	if(__NFUN_150__(i, __NFUN_144__(__NFUN_146__(iItem, 1), 4)))
	{
		// End:0x5D
		if(__NFUN_155__(int(m_Player.m_CurrentCircumstantialAction.iTeamSubActionsIDList[i]), 0))
		{
			return true;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x20;
	}
	return false;
	return;
}

function GotoSubMenu()
{
	m_Player.m_RequestedCircumstantialAction.iMenuChoice = int(m_Player.m_RequestedCircumstantialAction.iTeamActionIDList[m_iCurrentMnuChoice]);
	m_iCurrentSubMnuChoice = m_iCurrentMnuChoice;
	m_iCurrentMnuChoice = 0;
	return;
}

function bool IsValidMenuChoice(int iChoice)
{
	local int iSubMenuChoice;

	iSubMenuChoice = __NFUN_146__(__NFUN_144__(m_iCurrentSubMnuChoice, 4), iChoice);
	// End:0x31
	if(__NFUN_132__(__NFUN_150__(iChoice, 0), __NFUN_151__(iChoice, 3)))
	{
		return false;
	}
	// End:0xDA
	if(__NFUN_132__(__NFUN_130__(__NFUN_130__(__NFUN_155__(m_iCurrentSubMnuChoice, -1), __NFUN_155__(int(m_Player.m_CurrentCircumstantialAction.iTeamSubActionsIDList[iSubMenuChoice]), 0)), m_Player.m_CurrentCircumstantialAction.aQueryTarget.R6ActionCanBeExecuted(int(m_Player.m_CurrentCircumstantialAction.iTeamSubActionsIDList[iSubMenuChoice]), m_Player)), __NFUN_155__(int(m_Player.m_CurrentCircumstantialAction.iTeamActionIDList[iChoice]), 0)))
	{
		return true;
	}
	return false;
	return;
}

function SetMenuChoice(int iChoice)
{
	// End:0x27
	if(__NFUN_132__(__NFUN_150__(iChoice, 0), __NFUN_151__(iChoice, 3)))
	{
		m_iCurrentMnuChoice = -1;		
	}
	else
	{
		// End:0x43
		if(IsValidMenuChoice(iChoice))
		{
			m_iCurrentMnuChoice = iChoice;			
		}
		else
		{
			SetMenuChoice(__NFUN_147__(iChoice, 1));
		}
	}
	return;
}

function NoItemSelected()
{
	m_Player.SetRequestedCircumstantialAction();
	return;
}

function ItemClicked(int iItem)
{
	PerformCircumstantialAction(2);
	return;
}

function ItemRightClicked(int iItem)
{
	PerformCircumstantialAction(3);
	return;
}

function PerformCircumstantialAction(R6InteractionCircumstantialAction.eCircumstantialActionPerformer ePerformer)
{
	// End:0x16
	if(__NFUN_114__(m_Player.m_RequestedCircumstantialAction, none))
	{
		return;
	}
	// End:0xA1
	if(__NFUN_155__(m_iCurrentSubMnuChoice, -1))
	{
		m_Player.m_RequestedCircumstantialAction.iMenuChoice = int(m_Player.m_RequestedCircumstantialAction.iTeamActionIDList[m_iCurrentSubMnuChoice]);
		m_Player.m_RequestedCircumstantialAction.iSubMenuChoice = int(m_Player.m_RequestedCircumstantialAction.iTeamSubActionsIDList[__NFUN_146__(__NFUN_144__(m_iCurrentSubMnuChoice, 4), m_iCurrentMnuChoice)]);		
	}
	else
	{
		// End:0x104
		if(__NFUN_155__(m_iCurrentMnuChoice, -1))
		{
			m_Player.m_RequestedCircumstantialAction.iMenuChoice = int(m_Player.m_RequestedCircumstantialAction.iTeamActionIDList[m_iCurrentMnuChoice]);
			m_Player.m_RequestedCircumstantialAction.iSubMenuChoice = -1;
		}
	}
	switch(ePerformer)
	{
		// End:0x15D
		case 0:
			// End:0x134
			if(m_Player.m_RequestedCircumstantialAction.bCanBeInterrupted)
			{
				ActionProgressStart();				
			}
			else
			{
				m_Player.m_pawn.ActionRequest(m_Player.m_RequestedCircumstantialAction);
			}
			// End:0x246
			break;
		// End:0x18B
		case 1:
			m_Player.m_TeamManager.TeamActionRequest(m_Player.m_RequestedCircumstantialAction);
			// End:0x246
			break;
		// End:0x1E7
		case 2:
			m_Player.m_TeamManager.TeamActionRequestFromRoseDesVents(m_Player.m_RequestedCircumstantialAction, m_Player.m_RequestedCircumstantialAction.iMenuChoice, m_Player.m_RequestedCircumstantialAction.iSubMenuChoice);
			// End:0x246
			break;
		// End:0x243
		case 3:
			m_Player.m_TeamManager.TeamActionRequestWaitForZuluGoCode(m_Player.m_RequestedCircumstantialAction, m_Player.m_RequestedCircumstantialAction.iMenuChoice, m_Player.m_RequestedCircumstantialAction.iSubMenuChoice);
			// End:0x246
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

///////////////////////////////////////////////////////////////////////////////
// ActionProgressStart()                                                     
///////////////////////////////////////////////////////////////////////////////
function ActionProgressStart()
{
	// End:0x24
	if(__NFUN_129__(R6Pawn(m_Player.Pawn).CanInteractWithObjects()))
	{
		return;
	}
	m_Player.m_PlayerCurrentCA = m_Player.m_RequestedCircumstantialAction;
	__NFUN_113__('ActionProgress');
	m_Player.ServerPlayerActionProgress();
	// End:0x90
	if(m_Player.m_PlayerCurrentCA.aQueryTarget.__NFUN_303__('R6Terrorist'))
	{
		m_Player.__NFUN_113__('PlayerSecureTerrorist');		
	}
	else
	{
		// End:0xE4
		if(__NFUN_130__(Class'Engine.Actor'.static.__NFUN_1524__().IsMissionPack(), m_Player.m_PlayerCurrentCA.aQueryTarget.__NFUN_303__('R6Rainbow')))
		{
			m_Player.__NFUN_113__('PlayerSecureRainbow');			
		}
		else
		{
			m_Player.__NFUN_113__('PlayerActionProgress');
		}
	}
	return;
}

///////////////////////////////////////////////////////////////////////////////
// ActionProgressStop()                                                      
///////////////////////////////////////////////////////////////////////////////
function ActionProgressStop()
{
	DisplayMenu(false);
	// End:0x6D
	if(Class'Engine.Actor'.static.__NFUN_1524__().IsMissionPack())
	{
		// End:0x6A
		if(__NFUN_130__(m_Player.Pawn.IsAlive(), __NFUN_129__(m_Player.m_pawn.m_bIsSurrended)))
		{
			m_Player.__NFUN_113__('PlayerWalking');
		}		
	}
	else
	{
		// End:0x98
		if(m_Player.Pawn.IsAlive())
		{
			m_Player.__NFUN_113__('PlayerWalking');
		}
	}
	m_Player.m_PlayerCurrentCA = none;
	return;
}

///////////////////////////////////////////////////////////////////////////////
// ActionProgressDone()                                                      
///////////////////////////////////////////////////////////////////////////////
function ActionProgressDone()
{
	m_Player.m_pawn.ActionRequest(m_Player.m_PlayerCurrentCA);
	DisplayMenu(false);
	m_bIgnoreNextActionKeyRelease = true;
	m_Player.__NFUN_113__('PlayerWalking');
	m_Player.m_PlayerCurrentCA = none;
	return;
}

function PostRender(Canvas C)
{
	local R6GameOptions GameOptions;

	GameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	// End:0x1F
	if(__NFUN_114__(m_Player, none))
	{
		return;
	}
	C.__NFUN_1606__(true);
	// End:0x11A
	if(__NFUN_132__(GameOptions.HUDShowActionIcon, m_Player.m_bShowCompleteHUD))
	{
		// End:0x11A
		if(__NFUN_130__(__NFUN_119__(m_Player.Pawn, none), __NFUN_129__(m_Player.Pawn.IsAlive())))
		{
			// End:0xB4
			if(m_Player.PlayerCanSwitchToAIBackup())
			{
				DrawDeadCircumstantialIcon(C);
				C.__NFUN_1606__(false);
				return;				
			}
			else
			{
				// End:0x11A
				if(__NFUN_130__(__NFUN_130__(__NFUN_155__(int(m_Player.Level.NetMode), int(NM_Standalone)), m_Player.m_bReadyToEnterSpectatorMode), __NFUN_129__(m_Player.bOnlySpectator)))
				{
					DrawGotoSpectatorModeIcon(C);
					C.__NFUN_1606__(false);
					return;
				}
			}
		}
	}
	super(Interaction).PostRender(C);
	DrawCircumstantialActionInfo(C);
	C.__NFUN_1606__(false);
	return;
}

function DrawGotoSpectatorModeIcon(Canvas C)
{
	C.Style = 5;
	C.__NFUN_2626__(m_Player.m_SpectatorColor.R, m_Player.m_SpectatorColor.G, m_Player.m_SpectatorColor.B, m_Player.m_SpectatorColor.A);
	C.__NFUN_2623__(__NFUN_175__(C.HalfClipX, float(16)), __NFUN_175__(C.ClipY, float(74)));
	C.__NFUN_466__(Texture'R6ActionIcons.GoToSpectator', 32.0000000, 32.0000000, 0.0000000, 0.0000000, 32.0000000, 32.0000000);
	return;
}

function DrawDeadCircumstantialIcon(Canvas C)
{
	local string szNextTeamMate;
	local float W, H;

	// End:0x200
	if(__NFUN_119__(m_Player.m_TeamManager, none))
	{
		C.Style = 5;
		C.__NFUN_2626__(m_Player.m_TeamManager.Colors.HUDWhite.R, m_Player.m_TeamManager.Colors.HUDWhite.G, m_Player.m_TeamManager.Colors.HUDWhite.B, m_Player.m_TeamManager.Colors.HUDWhite.A);
		C.__NFUN_2623__(__NFUN_175__(C.HalfClipX, float(16)), __NFUN_175__(C.ClipY, float(74)));
		C.__NFUN_466__(Texture'R6ActionIcons.NextTeamMate', 32.0000000, 32.0000000, 0.0000000, 0.0000000, 32.0000000, 32.0000000);
		// End:0x200
		if(__NFUN_154__(R6GameReplicationInfo(m_Player.GameReplicationInfo).m_iDiffLevel, 1))
		{
			szNextTeamMate = Localize("Order", "NextTeamMate", "R6Menu");
			szNextTeamMate = m_Player.__NFUN_1521__(szNextTeamMate, "Action");
			C.__NFUN_470__(szNextTeamMate, W, H);
			C.__NFUN_2623__(__NFUN_175__(__NFUN_175__(C.HalfClipX, float(16)), __NFUN_172__(W, float(2))), __NFUN_175__(C.ClipY, float(20)));
			C.__NFUN_465__(szNextTeamMate);
		}
	}
	return;
}

function DrawSpectatorReticule(Canvas C)
{
	local int X, Y;
	local float fScale, fStrSizeX, fStrSizeY;
	local R6Pawn OtherPawn;
	local string characterName;

	X = int(C.HalfClipX);
	Y = int(C.HalfClipY);
	C.__NFUN_2626__(byte(255), 0, 0);
	C.Style = 5;
	fScale = __NFUN_172__(16.0000000, float(m_TexFakeReticule.VSize));
	C.__NFUN_2623__(__NFUN_174__(__NFUN_175__(float(X), __NFUN_172__(__NFUN_171__(float(m_TexFakeReticule.USize), fScale), float(2))), float(1)), __NFUN_174__(__NFUN_175__(float(Y), __NFUN_172__(__NFUN_171__(float(m_TexFakeReticule.VSize), fScale), float(2))), float(1)));
	C.DrawIcon(m_TexFakeReticule, fScale);
	// End:0x148
	if(__NFUN_130__(m_Player.bOnlySpectator, __NFUN_132__(__NFUN_129__(m_Player.bBehindView), m_Player.bCheatFlying)))
	{
		m_Player.__NFUN_2213__();
		characterName = m_Player.m_CharacterName;		
	}
	else
	{
		m_Player.m_CharacterName = "";
		characterName = "";
	}
	C.Font = m_SmallFont_14pt;
	C.__NFUN_464__(characterName, fStrSizeX, fStrSizeY);
	C.__NFUN_2623__(__NFUN_175__(float(X), __NFUN_172__(fStrSizeX, float(2))), float(__NFUN_146__(Y, 20)));
	C.__NFUN_465__(characterName);
	return;
}

//===========================================================================//
// DrawCircumstantialActionInfo()                                            //
//  Draw circumstantial action stuff, like the rose des vents and the action //
//  icon if there is one.                                                    //
//===========================================================================//
function DrawCircumstantialActionInfo(Canvas C)
{
	local R6CircumstantialActionQuery Query;
	local int iMnuChoice, iSubMenu;
	local bool bHasAction;
	local Color TeamColor;
	local R6GameOptions GameOptions;

	// End:0x0D
	if(__NFUN_114__(m_Player, none))
	{
		return;
	}
	// End:0x23
	if(__NFUN_114__(m_Player.m_CurrentCircumstantialAction, none))
	{
		return;
	}
	GameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	bHasAction = __NFUN_154__(int(m_Player.m_CurrentCircumstantialAction.iHasAction), 1);
	Query = m_Player.m_CurrentCircumstantialAction;
	C.Style = 5;
	// End:0x1DB
	if(__NFUN_130__(m_Player.m_bDisplayMessage, GameOptions.HUDShowActionIcon))
	{
		C.__NFUN_2626__(m_Player.m_TeamManager.Colors.HUDWhite.R, m_Player.m_TeamManager.Colors.HUDWhite.G, m_Player.m_TeamManager.Colors.HUDWhite.B, m_Player.m_TeamManager.Colors.HUDWhite.A);
		C.__NFUN_2623__(__NFUN_175__(C.HalfClipX, float(24)), __NFUN_175__(C.ClipY, float(82)));
		C.__NFUN_466__(Texture'R6ActionIcons.SkipText', 48.0000000, 48.0000000, 0.0000000, 0.0000000, 32.0000000, 32.0000000);
		// End:0x1D9
		if(__NFUN_132__(__NFUN_151__(m_Player.m_iPlayerCAProgress, 0), m_Player.m_bDisplayActionProgress))
		{
			SetPosAndDrawActionProgress(C);
		}
		return;
	}
	// End:0x255
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(m_Player.bOnlySpectator, __NFUN_129__(m_Player.bBehindView)), __NFUN_129__(m_Player.Level.m_bInGamePlanningActive)), __NFUN_132__(GameOptions.HUDShowReticule, m_Player.m_bShowCompleteHUD)))
	{
		DrawSpectatorReticule(C);
	}
	// End:0x379
	if(__NFUN_130__(m_Player.bOnlySpectator, __NFUN_132__(GameOptions.HUDShowActionIcon, m_Player.m_bShowCompleteHUD)))
	{
		// End:0x2CC
		if(__NFUN_119__(m_Player.m_TeamManager, none))
		{
			TeamColor = m_Player.m_TeamManager.Colors.HUDWhite;			
		}
		else
		{
			TeamColor = m_Player.m_SpectatorColor;
		}
		C.__NFUN_2626__(TeamColor.R, TeamColor.G, TeamColor.B, TeamColor.A);
		C.__NFUN_2623__(__NFUN_175__(C.HalfClipX, float(16)), __NFUN_175__(C.ClipY, float(74)));
		C.__NFUN_466__(Texture'R6ActionIcons.Spectator', 32.0000000, 32.0000000, 0.0000000, 0.0000000, 32.0000000, 32.0000000);
		return;
	}
	// End:0x38F
	if(__NFUN_114__(m_Player.m_TeamManager, none))
	{
		return;
	}
	// End:0x3C5
	if(__NFUN_132__(__NFUN_151__(m_Player.m_iPlayerCAProgress, 0), m_Player.m_bDisplayActionProgress))
	{
		SetPosAndDrawActionProgress(C);		
	}
	else
	{
		// End:0x66C
		if(__NFUN_130__(bHasAction, __NFUN_129__(m_Player.m_bAMenuIsDisplayed)))
		{
			// End:0x4D1
			if(__NFUN_154__(int(Query.iInRange), 0))
			{
				// End:0x410
				if(__NFUN_129__(m_Player.CanIssueTeamOrder()))
				{
					return;
				}
				TeamColor = m_Player.m_TeamManager.GetTeamColor();
				C.__NFUN_2626__(m_Player.m_TeamManager.Colors.HUDGrey.R, m_Player.m_TeamManager.Colors.HUDGrey.G, m_Player.m_TeamManager.Colors.HUDGrey.B, m_Player.m_TeamManager.Colors.HUDGrey.A);				
			}
			else
			{
				// End:0x5D7
				if(__NFUN_119__(m_Player.Pawn, none))
				{
					// End:0x509
					if(__NFUN_129__(R6Pawn(m_Player.Pawn).CanInteractWithObjects()))
					{
						return;
					}
					C.__NFUN_2626__(m_Player.m_TeamManager.Colors.HUDWhite.R, m_Player.m_TeamManager.Colors.HUDWhite.G, m_Player.m_TeamManager.Colors.HUDWhite.B, m_Player.m_TeamManager.Colors.HUDWhite.A);
					// End:0x5D7
					if(__NFUN_114__(Query.aQueryTarget, m_Player))
					{
						// End:0x5D7
						if(__NFUN_129__(m_Player.CanIssueTeamOrder()))
						{
							return;
						}
					}
				}
			}
			// End:0x669
			if(__NFUN_132__(GameOptions.HUDShowActionIcon, m_Player.m_bShowCompleteHUD))
			{
				C.__NFUN_2623__(__NFUN_175__(C.HalfClipX, float(16)), __NFUN_175__(C.ClipY, float(74)));
				C.__NFUN_466__(Query.textureIcon, 32.0000000, 32.0000000, 0.0000000, 0.0000000, 32.0000000, 32.0000000);
			}			
		}
		else
		{
			// End:0x6BE
			if(__NFUN_130__(__NFUN_130__(bHasAction, bVisible), __NFUN_154__(int(Query.iInRange), 0)))
			{
				// End:0x6AE
				if(__NFUN_129__(m_Player.CanIssueTeamOrder()))
				{
					return;
				}
				DrawTeamActionMnu(C, Query);
			}
		}
	}
	return;
}

//===========================================================================//
// SetPosAndDrawActionProgress()                                                       //
//===========================================================================//
function SetPosAndDrawActionProgress(Canvas C)
{
	local Color TeamColor;
	local R6GameOptions GameOptions;

	GameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	// End:0x242
	if(__NFUN_129__(m_Player.Level.m_bInGamePlanningActive))
	{
		TeamColor = m_Player.m_TeamManager.GetTeamColor();
		C.__NFUN_2626__(m_Player.m_TeamManager.Colors.HUDWhite.R, m_Player.m_TeamManager.Colors.HUDWhite.G, m_Player.m_TeamManager.Colors.HUDWhite.B, m_Player.m_TeamManager.Colors.HUDWhite.A);
		// End:0x12E
		if(__NFUN_132__(GameOptions.HUDShowReticule, m_Player.m_bShowCompleteHUD))
		{
			DrawActionProgress(C, float(m_Player.m_iPlayerCAProgress));
		}
		// End:0x242
		if(__NFUN_130__(__NFUN_132__(GameOptions.HUDShowActionIcon, m_Player.m_bShowCompleteHUD), __NFUN_119__(m_Player.m_PlayerCurrentCA, none)))
		{
			C.__NFUN_2623__(__NFUN_175__(C.HalfClipX, float(16)), __NFUN_175__(C.ClipY, float(74)));
			C.__NFUN_466__(m_Player.m_PlayerCurrentCA.textureIcon, 32.0000000, 32.0000000, 0.0000000, 0.0000000, 32.0000000, 32.0000000);
			C.__NFUN_2623__(__NFUN_175__(C.HalfClipX, float(24)), __NFUN_175__(C.ClipY, float(82)));
			C.__NFUN_466__(Texture'R6ActionIcons.CancelAction', 48.0000000, 48.0000000, 0.0000000, 0.0000000, 32.0000000, 32.0000000);
		}
	}
	return;
}

//===========================================================================//
// DrawTeamActionMnu()                                                       //
//===========================================================================//
function DrawTeamActionMnu(Canvas C, R6CircumstantialActionQuery Query)
{
	local string strAction;
	local int iAction;
	local float fPosX, fPosY;
	local Color TeamColor;
	local float fTextSizeX, fTextSizeY, fScaleX, fScaleY;

	DrawRoseDesVents(C, m_iCurrentMnuChoice);
	C.OrgX = 0.0000000;
	C.OrgY = 0.0000000;
	C.__NFUN_1606__(false);
	fScaleX = __NFUN_172__(float(C.SizeX), 800.0000000);
	fScaleY = __NFUN_172__(float(C.SizeY), 600.0000000);
	TeamColor = m_Player.m_TeamManager.GetTeamColor();
	fPosX = __NFUN_174__(__NFUN_172__(float(C.SizeX), 2.0000000), fScaleX);
	fPosY = __NFUN_174__(__NFUN_172__(float(C.SizeY), 2.0000000), fScaleY);
	fTextSizeX = 75.0000000;
	fTextSizeY = 32.0000000;
	iAction = 0;
	J0x102:

	// End:0x535 [Loop If]
	if(__NFUN_150__(iAction, 4))
	{
		// End:0x271
		if(MenuItemEnabled(iAction))
		{
			// End:0x1CE
			if(__NFUN_155__(m_iCurrentMnuChoice, iAction))
			{
				C.__NFUN_2626__(m_Player.m_TeamManager.Colors.HUDGrey.R, m_Player.m_TeamManager.Colors.HUDGrey.G, m_Player.m_TeamManager.Colors.HUDGrey.B, m_Player.m_TeamManager.Colors.HUDGrey.A);				
			}
			else
			{
				C.__NFUN_2626__(m_Player.m_TeamManager.Colors.HUDWhite.R, m_Player.m_TeamManager.Colors.HUDWhite.G, m_Player.m_TeamManager.Colors.HUDWhite.B, m_Player.m_TeamManager.Colors.HUDWhite.A);
			}			
		}
		else
		{
			C.__NFUN_2626__(m_Player.m_TeamManager.Colors.HUDGrey.R, m_Player.m_TeamManager.Colors.HUDGrey.G, m_Player.m_TeamManager.Colors.HUDGrey.B, m_Player.m_TeamManager.Colors.HUDGrey.A);
		}
		// End:0x357
		if(__NFUN_154__(m_iCurrentSubMnuChoice, -1))
		{
			strAction = Query.aQueryTarget.R6GetCircumstantialActionString(int(Query.iTeamActionIDList[iAction]));			
		}
		else
		{
			strAction = Query.aQueryTarget.R6GetCircumstantialActionString(int(Query.iTeamSubActionsIDList[__NFUN_146__(__NFUN_144__(m_iCurrentSubMnuChoice, 4), iAction)]));
		}
		C.Style = 3;
		switch(iAction)
		{
			// End:0x410
			case 0:
				DrawTextCenteredInBox(C, strAction, __NFUN_175__(fPosX, __NFUN_172__(__NFUN_171__(fTextSizeX, fScaleX), 2.0000000)), __NFUN_175__(fPosY, __NFUN_171__(__NFUN_174__(float(50), fTextSizeY), fScaleY)), __NFUN_171__(fTextSizeX, fScaleX), __NFUN_171__(fTextSizeY, fScaleY));
				// End:0x52B
				break;
			// End:0x46A
			case 1:
				DrawTextCenteredInBox(C, strAction, __NFUN_174__(fPosX, __NFUN_171__(float(35), fScaleX)), __NFUN_175__(fPosY, __NFUN_171__(__NFUN_172__(fTextSizeY, float(2)), fScaleY)), __NFUN_171__(fTextSizeX, fScaleX), __NFUN_171__(fTextSizeY, fScaleY));
				// End:0x52B
				break;
			// End:0x4C6
			case 2:
				DrawTextCenteredInBox(C, strAction, __NFUN_175__(fPosX, __NFUN_172__(__NFUN_171__(fTextSizeX, fScaleX), 2.0000000)), __NFUN_174__(fPosY, __NFUN_171__(float(50), fScaleY)), __NFUN_171__(fTextSizeX, fScaleX), __NFUN_171__(fTextSizeY, fScaleY));
				// End:0x52B
				break;
			// End:0x528
			case 3:
				DrawTextCenteredInBox(C, strAction, __NFUN_175__(fPosX, __NFUN_171__(__NFUN_174__(float(35), fTextSizeX), fScaleX)), __NFUN_175__(fPosY, __NFUN_171__(__NFUN_172__(fTextSizeY, float(2)), fScaleY)), __NFUN_171__(fTextSizeX, fScaleX), __NFUN_171__(fTextSizeY, fScaleY));
				// End:0x52B
				break;
			// End:0xFFFF
			default:
				break;
		}
		__NFUN_165__(iAction);
		// [Loop Continue]
		goto J0x102;
	}
	C.OrgX = 0.0000000;
	C.OrgY = 0.0000000;
	C.__NFUN_2626__(TeamColor.R, TeamColor.R, TeamColor.R, TeamColor.A);
	return;
}

//===========================================================================//
// DrawActionProgress()                                                      //
//===========================================================================//
function DrawActionProgress(Canvas C, float fProgress)
{
	local int iItem, fDegreeProgress;

	iItem = 0;
	J0x07:

	// End:0xF3 [Loop If]
	if(__NFUN_176__(float(__NFUN_144__(iItem, 30)), 360.0000000))
	{
		C.__NFUN_2623__(__NFUN_171__(__NFUN_175__(C.ClipX, float(m_TexProgressCircle.USize)), 0.5000000), __NFUN_171__(__NFUN_175__(C.ClipY, float(m_TexProgressCircle.VSize)), 0.5000000));
		C.__NFUN_466__(m_TexProgressCircle, float(m_TexProgressCircle.USize), float(m_TexProgressCircle.VSize), 0.0000000, 0.0000000, float(m_TexProgressCircle.USize), float(m_TexProgressCircle.VSize), __NFUN_172__(__NFUN_171__(float(__NFUN_144__(iItem, 30)), 3.1415930), float(180)));
		__NFUN_165__(iItem);
		// [Loop Continue]
		goto J0x07;
	}
	fDegreeProgress = int(__NFUN_171__(fProgress, 3.6000000));
	iItem = 1;
	J0x10E:

	// End:0x1FD [Loop If]
	if(__NFUN_150__(__NFUN_144__(iItem, 30), fDegreeProgress))
	{
		C.__NFUN_2623__(__NFUN_171__(__NFUN_175__(C.ClipX, float(m_TexProgressItem.USize)), 0.5000000), __NFUN_171__(__NFUN_175__(C.ClipY, float(m_TexProgressItem.VSize)), 0.5000000));
		C.__NFUN_466__(m_TexProgressItem, float(m_TexProgressItem.USize), float(m_TexProgressItem.VSize), 0.0000000, 0.0000000, float(m_TexProgressItem.USize), float(m_TexProgressItem.VSize), __NFUN_172__(__NFUN_171__(__NFUN_171__(float(__NFUN_147__(iItem, 1)), float(30)), 3.1415930), float(180)));
		__NFUN_165__(iItem);
		// [Loop Continue]
		goto J0x10E;
	}
	return;
}

state ActionProgress
{
	function bool KeyEvent(Interactions.EInputKey eKey, Interactions.EInputAction eAction, float fDelta)
	{
		// End:0xE0
		if(__NFUN_154__(int(eKey), int(m_Player.__NFUN_2706__(m_ActionKey))))
		{
			// End:0xE0
			if(__NFUN_154__(int(eAction), int(3)))
			{
				m_Player.ServerActionProgressStop();
				// End:0xA4
				if(Class'Engine.Actor'.static.__NFUN_1524__().IsMissionPack())
				{
					// End:0xA1
					if(__NFUN_130__(m_Player.Pawn.IsAlive(), __NFUN_129__(m_Player.m_pawn.m_bIsSurrended)))
					{
						m_Player.__NFUN_113__('PlayerWalking');
					}					
				}
				else
				{
					// End:0xCF
					if(m_Player.Pawn.IsAlive())
					{
						m_Player.__NFUN_113__('PlayerWalking');
					}
				}
				DisplayMenu(false);
				m_bActionKeyDown = false;
				return true;
			}
		}
		return true;
		return;
	}
	stop;
}

defaultproperties
{
	m_TexProgressCircle=Texture'R6HUD.ProgressCircle'
	m_TexProgressItem=Texture'R6HUD.ProgressItem'
	m_TexFakeReticule=Texture'R6TexturesReticule.Dot'
	m_SmallFont_14pt=Font'R6Font.Rainbow6_14pt'
	m_ActionKey="Action"
}
