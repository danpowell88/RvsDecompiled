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
	if((int(m_Player.Level.NetMode) != int(NM_Standalone)))
	{
		m_Player.ServerActionKeyPressed();
	}
	m_Player.SetRequestedCircumstantialAction();
	// End:0xA8
	if((int(m_Player.m_RequestedCircumstantialAction.iHasAction) == 1))
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
		if(((m_Player.Pawn != none) && (!m_Player.Pawn.IsAlive())))
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
	if((int(m_Player.m_RequestedCircumstantialAction.iHasAction) != 1))
	{
		DisplayMenu(false);
		return;
	}
	// End:0x135
	if((int(m_Player.m_RequestedCircumstantialAction.iInRange) != 1))
	{
		m_Player.m_InteractionCA.PerformCircumstantialAction(1);		
	}
	else
	{
		// End:0x1E0
		if(((m_Player.m_pawn.CanInteractWithObjects() && (int(m_Player.m_RequestedCircumstantialAction.iInRange) == 1)) && (!m_Player.m_RequestedCircumstantialAction.bCanBeInterrupted)))
		{
			// End:0x1C3
			if((m_Player.m_RequestedCircumstantialAction.aQueryTarget == m_Player))
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
			if(m_Player.m_RequestedCircumstantialAction.aQueryTarget.IsA('R6IORotatingDoor'))
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

	iSubMenuChoice = ((m_iCurrentSubMnuChoice * 4) + iItem);
	// End:0x31
	if(((iItem < 0) || (iItem > 3)))
	{
		return false;
	}
	// End:0x8F
	if((m_iCurrentSubMnuChoice != -1))
	{
		bActionCanBeExecuted = m_Player.m_CurrentCircumstantialAction.aQueryTarget.R6ActionCanBeExecuted(int(m_Player.m_CurrentCircumstantialAction.iTeamSubActionsIDList[iSubMenuChoice]), m_Player);		
	}
	else
	{
		// End:0x103
		if((int(m_Player.m_CurrentCircumstantialAction.iTeamActionIDList[iItem]) != 0))
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
	if((m_iCurrentSubMnuChoice != -1))
	{
		return false;
	}
	i = (m_iCurrentMnuChoice * 4);
	J0x20:

	// End:0x67 [Loop If]
	if((i < ((m_iCurrentMnuChoice + 1) * 4)))
	{
		// End:0x5D
		if((int(m_Player.m_CurrentCircumstantialAction.iTeamSubActionsIDList[i]) != 0))
		{
			return true;
		}
		(i++);
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
	if((m_iCurrentSubMnuChoice != -1))
	{
		return false;
	}
	i = (iItem * 4);
	J0x20:

	// End:0x67 [Loop If]
	if((i < ((iItem + 1) * 4)))
	{
		// End:0x5D
		if((int(m_Player.m_CurrentCircumstantialAction.iTeamSubActionsIDList[i]) != 0))
		{
			return true;
		}
		(i++);
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

	iSubMenuChoice = ((m_iCurrentSubMnuChoice * 4) + iChoice);
	// End:0x31
	if(((iChoice < 0) || (iChoice > 3)))
	{
		return false;
	}
	// End:0xDA
	if(((((m_iCurrentSubMnuChoice != -1) && (int(m_Player.m_CurrentCircumstantialAction.iTeamSubActionsIDList[iSubMenuChoice]) != 0)) && m_Player.m_CurrentCircumstantialAction.aQueryTarget.R6ActionCanBeExecuted(int(m_Player.m_CurrentCircumstantialAction.iTeamSubActionsIDList[iSubMenuChoice]), m_Player)) || (int(m_Player.m_CurrentCircumstantialAction.iTeamActionIDList[iChoice]) != 0)))
	{
		return true;
	}
	return false;
	return;
}

function SetMenuChoice(int iChoice)
{
	// End:0x27
	if(((iChoice < 0) || (iChoice > 3)))
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
			SetMenuChoice((iChoice - 1));
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
	if((m_Player.m_RequestedCircumstantialAction == none))
	{
		return;
	}
	// End:0xA1
	if((m_iCurrentSubMnuChoice != -1))
	{
		m_Player.m_RequestedCircumstantialAction.iMenuChoice = int(m_Player.m_RequestedCircumstantialAction.iTeamActionIDList[m_iCurrentSubMnuChoice]);
		m_Player.m_RequestedCircumstantialAction.iSubMenuChoice = int(m_Player.m_RequestedCircumstantialAction.iTeamSubActionsIDList[((m_iCurrentSubMnuChoice * 4) + m_iCurrentMnuChoice)]);		
	}
	else
	{
		// End:0x104
		if((m_iCurrentMnuChoice != -1))
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
	if((!R6Pawn(m_Player.Pawn).CanInteractWithObjects()))
	{
		return;
	}
	m_Player.m_PlayerCurrentCA = m_Player.m_RequestedCircumstantialAction;
	GotoState('ActionProgress');
	m_Player.ServerPlayerActionProgress();
	// End:0x90
	if(m_Player.m_PlayerCurrentCA.aQueryTarget.IsA('R6Terrorist'))
	{
		m_Player.GotoState('PlayerSecureTerrorist');		
	}
	else
	{
		// End:0xE4
		if((Class'Engine.Actor'.static.GetModMgr().IsMissionPack() && m_Player.m_PlayerCurrentCA.aQueryTarget.IsA('R6Rainbow')))
		{
			m_Player.GotoState('PlayerSecureRainbow');			
		}
		else
		{
			m_Player.GotoState('PlayerActionProgress');
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
	if(Class'Engine.Actor'.static.GetModMgr().IsMissionPack())
	{
		// End:0x6A
		if((m_Player.Pawn.IsAlive() && (!m_Player.m_pawn.m_bIsSurrended)))
		{
			m_Player.GotoState('PlayerWalking');
		}		
	}
	else
	{
		// End:0x98
		if(m_Player.Pawn.IsAlive())
		{
			m_Player.GotoState('PlayerWalking');
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
	m_Player.GotoState('PlayerWalking');
	m_Player.m_PlayerCurrentCA = none;
	return;
}

function PostRender(Canvas C)
{
	local R6GameOptions GameOptions;

	GameOptions = Class'Engine.Actor'.static.GetGameOptions();
	// End:0x1F
	if((m_Player == none))
	{
		return;
	}
	C.UseVirtualSize(true);
	// End:0x11A
	if((GameOptions.HUDShowActionIcon || m_Player.m_bShowCompleteHUD))
	{
		// End:0x11A
		if(((m_Player.Pawn != none) && (!m_Player.Pawn.IsAlive())))
		{
			// End:0xB4
			if(m_Player.PlayerCanSwitchToAIBackup())
			{
				DrawDeadCircumstantialIcon(C);
				C.UseVirtualSize(false);
				return;				
			}
			else
			{
				// End:0x11A
				if((((int(m_Player.Level.NetMode) != int(NM_Standalone)) && m_Player.m_bReadyToEnterSpectatorMode) && (!m_Player.bOnlySpectator)))
				{
					DrawGotoSpectatorModeIcon(C);
					C.UseVirtualSize(false);
					return;
				}
			}
		}
	}
	super(Interaction).PostRender(C);
	DrawCircumstantialActionInfo(C);
	C.UseVirtualSize(false);
	return;
}

function DrawGotoSpectatorModeIcon(Canvas C)
{
	C.Style = 5;
	C.SetDrawColor(m_Player.m_SpectatorColor.R, m_Player.m_SpectatorColor.G, m_Player.m_SpectatorColor.B, m_Player.m_SpectatorColor.A);
	C.SetPos((C.HalfClipX - float(16)), (C.ClipY - float(74)));
	C.DrawTile(Texture'R6ActionIcons.GoToSpectator', 32.0000000, 32.0000000, 0.0000000, 0.0000000, 32.0000000, 32.0000000);
	return;
}

function DrawDeadCircumstantialIcon(Canvas C)
{
	local string szNextTeamMate;
	local float W, H;

	// End:0x200
	if((m_Player.m_TeamManager != none))
	{
		C.Style = 5;
		C.SetDrawColor(m_Player.m_TeamManager.Colors.HUDWhite.R, m_Player.m_TeamManager.Colors.HUDWhite.G, m_Player.m_TeamManager.Colors.HUDWhite.B, m_Player.m_TeamManager.Colors.HUDWhite.A);
		C.SetPos((C.HalfClipX - float(16)), (C.ClipY - float(74)));
		C.DrawTile(Texture'R6ActionIcons.NextTeamMate', 32.0000000, 32.0000000, 0.0000000, 0.0000000, 32.0000000, 32.0000000);
		// End:0x200
		if((R6GameReplicationInfo(m_Player.GameReplicationInfo).m_iDiffLevel == 1))
		{
			szNextTeamMate = Localize("Order", "NextTeamMate", "R6Menu");
			szNextTeamMate = m_Player.GetLocStringWithActionKey(szNextTeamMate, "Action");
			C.TextSize(szNextTeamMate, W, H);
			C.SetPos(((C.HalfClipX - float(16)) - (W / float(2))), (C.ClipY - float(20)));
			C.DrawText(szNextTeamMate);
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
	C.SetDrawColor(byte(255), 0, 0);
	C.Style = 5;
	fScale = (16.0000000 / float(m_TexFakeReticule.VSize));
	C.SetPos(((float(X) - ((float(m_TexFakeReticule.USize) * fScale) / float(2))) + float(1)), ((float(Y) - ((float(m_TexFakeReticule.VSize) * fScale) / float(2))) + float(1)));
	C.DrawIcon(m_TexFakeReticule, fScale);
	// End:0x148
	if((m_Player.bOnlySpectator && ((!m_Player.bBehindView) || m_Player.bCheatFlying)))
	{
		m_Player.UpdateSpectatorReticule();
		characterName = m_Player.m_CharacterName;		
	}
	else
	{
		m_Player.m_CharacterName = "";
		characterName = "";
	}
	C.Font = m_SmallFont_14pt;
	C.StrLen(characterName, fStrSizeX, fStrSizeY);
	C.SetPos((float(X) - (fStrSizeX / float(2))), float((Y + 20)));
	C.DrawText(characterName);
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
	if((m_Player == none))
	{
		return;
	}
	// End:0x23
	if((m_Player.m_CurrentCircumstantialAction == none))
	{
		return;
	}
	GameOptions = Class'Engine.Actor'.static.GetGameOptions();
	bHasAction = (int(m_Player.m_CurrentCircumstantialAction.iHasAction) == 1);
	Query = m_Player.m_CurrentCircumstantialAction;
	C.Style = 5;
	// End:0x1DB
	if((m_Player.m_bDisplayMessage && GameOptions.HUDShowActionIcon))
	{
		C.SetDrawColor(m_Player.m_TeamManager.Colors.HUDWhite.R, m_Player.m_TeamManager.Colors.HUDWhite.G, m_Player.m_TeamManager.Colors.HUDWhite.B, m_Player.m_TeamManager.Colors.HUDWhite.A);
		C.SetPos((C.HalfClipX - float(24)), (C.ClipY - float(82)));
		C.DrawTile(Texture'R6ActionIcons.SkipText', 48.0000000, 48.0000000, 0.0000000, 0.0000000, 32.0000000, 32.0000000);
		// End:0x1D9
		if(((m_Player.m_iPlayerCAProgress > 0) || m_Player.m_bDisplayActionProgress))
		{
			SetPosAndDrawActionProgress(C);
		}
		return;
	}
	// End:0x255
	if((((m_Player.bOnlySpectator && (!m_Player.bBehindView)) && (!m_Player.Level.m_bInGamePlanningActive)) && (GameOptions.HUDShowReticule || m_Player.m_bShowCompleteHUD)))
	{
		DrawSpectatorReticule(C);
	}
	// End:0x379
	if((m_Player.bOnlySpectator && (GameOptions.HUDShowActionIcon || m_Player.m_bShowCompleteHUD)))
	{
		// End:0x2CC
		if((m_Player.m_TeamManager != none))
		{
			TeamColor = m_Player.m_TeamManager.Colors.HUDWhite;			
		}
		else
		{
			TeamColor = m_Player.m_SpectatorColor;
		}
		C.SetDrawColor(TeamColor.R, TeamColor.G, TeamColor.B, TeamColor.A);
		C.SetPos((C.HalfClipX - float(16)), (C.ClipY - float(74)));
		C.DrawTile(Texture'R6ActionIcons.Spectator', 32.0000000, 32.0000000, 0.0000000, 0.0000000, 32.0000000, 32.0000000);
		return;
	}
	// End:0x38F
	if((m_Player.m_TeamManager == none))
	{
		return;
	}
	// End:0x3C5
	if(((m_Player.m_iPlayerCAProgress > 0) || m_Player.m_bDisplayActionProgress))
	{
		SetPosAndDrawActionProgress(C);		
	}
	else
	{
		// End:0x66C
		if((bHasAction && (!m_Player.m_bAMenuIsDisplayed)))
		{
			// End:0x4D1
			if((int(Query.iInRange) == 0))
			{
				// End:0x410
				if((!m_Player.CanIssueTeamOrder()))
				{
					return;
				}
				TeamColor = m_Player.m_TeamManager.GetTeamColor();
				C.SetDrawColor(m_Player.m_TeamManager.Colors.HUDGrey.R, m_Player.m_TeamManager.Colors.HUDGrey.G, m_Player.m_TeamManager.Colors.HUDGrey.B, m_Player.m_TeamManager.Colors.HUDGrey.A);				
			}
			else
			{
				// End:0x5D7
				if((m_Player.Pawn != none))
				{
					// End:0x509
					if((!R6Pawn(m_Player.Pawn).CanInteractWithObjects()))
					{
						return;
					}
					C.SetDrawColor(m_Player.m_TeamManager.Colors.HUDWhite.R, m_Player.m_TeamManager.Colors.HUDWhite.G, m_Player.m_TeamManager.Colors.HUDWhite.B, m_Player.m_TeamManager.Colors.HUDWhite.A);
					// End:0x5D7
					if((Query.aQueryTarget == m_Player))
					{
						// End:0x5D7
						if((!m_Player.CanIssueTeamOrder()))
						{
							return;
						}
					}
				}
			}
			// End:0x669
			if((GameOptions.HUDShowActionIcon || m_Player.m_bShowCompleteHUD))
			{
				C.SetPos((C.HalfClipX - float(16)), (C.ClipY - float(74)));
				C.DrawTile(Query.textureIcon, 32.0000000, 32.0000000, 0.0000000, 0.0000000, 32.0000000, 32.0000000);
			}			
		}
		else
		{
			// End:0x6BE
			if(((bHasAction && bVisible) && (int(Query.iInRange) == 0)))
			{
				// End:0x6AE
				if((!m_Player.CanIssueTeamOrder()))
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

	GameOptions = Class'Engine.Actor'.static.GetGameOptions();
	// End:0x242
	if((!m_Player.Level.m_bInGamePlanningActive))
	{
		TeamColor = m_Player.m_TeamManager.GetTeamColor();
		C.SetDrawColor(m_Player.m_TeamManager.Colors.HUDWhite.R, m_Player.m_TeamManager.Colors.HUDWhite.G, m_Player.m_TeamManager.Colors.HUDWhite.B, m_Player.m_TeamManager.Colors.HUDWhite.A);
		// End:0x12E
		if((GameOptions.HUDShowReticule || m_Player.m_bShowCompleteHUD))
		{
			DrawActionProgress(C, float(m_Player.m_iPlayerCAProgress));
		}
		// End:0x242
		if(((GameOptions.HUDShowActionIcon || m_Player.m_bShowCompleteHUD) && (m_Player.m_PlayerCurrentCA != none)))
		{
			C.SetPos((C.HalfClipX - float(16)), (C.ClipY - float(74)));
			C.DrawTile(m_Player.m_PlayerCurrentCA.textureIcon, 32.0000000, 32.0000000, 0.0000000, 0.0000000, 32.0000000, 32.0000000);
			C.SetPos((C.HalfClipX - float(24)), (C.ClipY - float(82)));
			C.DrawTile(Texture'R6ActionIcons.CancelAction', 48.0000000, 48.0000000, 0.0000000, 0.0000000, 32.0000000, 32.0000000);
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
	C.UseVirtualSize(false);
	fScaleX = (float(C.SizeX) / 800.0000000);
	fScaleY = (float(C.SizeY) / 600.0000000);
	TeamColor = m_Player.m_TeamManager.GetTeamColor();
	fPosX = ((float(C.SizeX) / 2.0000000) + fScaleX);
	fPosY = ((float(C.SizeY) / 2.0000000) + fScaleY);
	fTextSizeX = 75.0000000;
	fTextSizeY = 32.0000000;
	iAction = 0;
	J0x102:

	// End:0x535 [Loop If]
	if((iAction < 4))
	{
		// End:0x271
		if(MenuItemEnabled(iAction))
		{
			// End:0x1CE
			if((m_iCurrentMnuChoice != iAction))
			{
				C.SetDrawColor(m_Player.m_TeamManager.Colors.HUDGrey.R, m_Player.m_TeamManager.Colors.HUDGrey.G, m_Player.m_TeamManager.Colors.HUDGrey.B, m_Player.m_TeamManager.Colors.HUDGrey.A);				
			}
			else
			{
				C.SetDrawColor(m_Player.m_TeamManager.Colors.HUDWhite.R, m_Player.m_TeamManager.Colors.HUDWhite.G, m_Player.m_TeamManager.Colors.HUDWhite.B, m_Player.m_TeamManager.Colors.HUDWhite.A);
			}			
		}
		else
		{
			C.SetDrawColor(m_Player.m_TeamManager.Colors.HUDGrey.R, m_Player.m_TeamManager.Colors.HUDGrey.G, m_Player.m_TeamManager.Colors.HUDGrey.B, m_Player.m_TeamManager.Colors.HUDGrey.A);
		}
		// End:0x357
		if((m_iCurrentSubMnuChoice == -1))
		{
			strAction = Query.aQueryTarget.R6GetCircumstantialActionString(int(Query.iTeamActionIDList[iAction]));			
		}
		else
		{
			strAction = Query.aQueryTarget.R6GetCircumstantialActionString(int(Query.iTeamSubActionsIDList[((m_iCurrentSubMnuChoice * 4) + iAction)]));
		}
		C.Style = 3;
		switch(iAction)
		{
			// End:0x410
			case 0:
				DrawTextCenteredInBox(C, strAction, (fPosX - ((fTextSizeX * fScaleX) / 2.0000000)), (fPosY - ((float(50) + fTextSizeY) * fScaleY)), (fTextSizeX * fScaleX), (fTextSizeY * fScaleY));
				// End:0x52B
				break;
			// End:0x46A
			case 1:
				DrawTextCenteredInBox(C, strAction, (fPosX + (float(35) * fScaleX)), (fPosY - ((fTextSizeY / float(2)) * fScaleY)), (fTextSizeX * fScaleX), (fTextSizeY * fScaleY));
				// End:0x52B
				break;
			// End:0x4C6
			case 2:
				DrawTextCenteredInBox(C, strAction, (fPosX - ((fTextSizeX * fScaleX) / 2.0000000)), (fPosY + (float(50) * fScaleY)), (fTextSizeX * fScaleX), (fTextSizeY * fScaleY));
				// End:0x52B
				break;
			// End:0x528
			case 3:
				DrawTextCenteredInBox(C, strAction, (fPosX - ((float(35) + fTextSizeX) * fScaleX)), (fPosY - ((fTextSizeY / float(2)) * fScaleY)), (fTextSizeX * fScaleX), (fTextSizeY * fScaleY));
				// End:0x52B
				break;
			// End:0xFFFF
			default:
				break;
		}
		(iAction++);
		// [Loop Continue]
		goto J0x102;
	}
	C.OrgX = 0.0000000;
	C.OrgY = 0.0000000;
	C.SetDrawColor(TeamColor.R, TeamColor.R, TeamColor.R, TeamColor.A);
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
	if((float((iItem * 30)) < 360.0000000))
	{
		C.SetPos(((C.ClipX - float(m_TexProgressCircle.USize)) * 0.5000000), ((C.ClipY - float(m_TexProgressCircle.VSize)) * 0.5000000));
		C.DrawTile(m_TexProgressCircle, float(m_TexProgressCircle.USize), float(m_TexProgressCircle.VSize), 0.0000000, 0.0000000, float(m_TexProgressCircle.USize), float(m_TexProgressCircle.VSize), ((float((iItem * 30)) * 3.1415930) / float(180)));
		(iItem++);
		// [Loop Continue]
		goto J0x07;
	}
	fDegreeProgress = int((fProgress * 3.6000000));
	iItem = 1;
	J0x10E:

	// End:0x1FD [Loop If]
	if(((iItem * 30) < fDegreeProgress))
	{
		C.SetPos(((C.ClipX - float(m_TexProgressItem.USize)) * 0.5000000), ((C.ClipY - float(m_TexProgressItem.VSize)) * 0.5000000));
		C.DrawTile(m_TexProgressItem, float(m_TexProgressItem.USize), float(m_TexProgressItem.VSize), 0.0000000, 0.0000000, float(m_TexProgressItem.USize), float(m_TexProgressItem.VSize), (((float((iItem - 1)) * float(30)) * 3.1415930) / float(180)));
		(iItem++);
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
		if((int(eKey) == int(m_Player.GetKey(m_ActionKey))))
		{
			// End:0xE0
			if((int(eAction) == int(3)))
			{
				m_Player.ServerActionProgressStop();
				// End:0xA4
				if(Class'Engine.Actor'.static.GetModMgr().IsMissionPack())
				{
					// End:0xA1
					if((m_Player.Pawn.IsAlive() && (!m_Player.m_pawn.m_bIsSurrended)))
					{
						m_Player.GotoState('PlayerWalking');
					}					
				}
				else
				{
					// End:0xCF
					if(m_Player.Pawn.IsAlive())
					{
						m_Player.GotoState('PlayerWalking');
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
