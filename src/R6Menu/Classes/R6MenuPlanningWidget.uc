//=============================================================================
// R6MenuPlanningWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuPlanningWidget.uc : Planning phase Menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/12 * Created by Alexandre Dionne
//=============================================================================
class R6MenuPlanningWidget extends R6MenuLaptopWidget;

const R6InputKey_ActionPopup = 1024;
const R6InputKey_NewNode = 1025;
const R6InputKey_PathFlagPopup = 1026;

var bool m_bPopUpMenuPoint;  // Action PopUp menu is beeing displayed
var bool m_bPopUpMenuSpeed;  // Speed PopUp Menu is beeing displayed
var bool m_bMoveUDByLaptop;
var bool m_bMoveRLByLaptop;
var bool m_bClosePopup;
var bool bShowLog;
var float m_fLabelHeight;
var float m_fLMouseDownX;
var float m_fLMouseDownY;
var R6MenuPlanningBar m_PlanningBar;
var R6Menu3DViewOnOffButton m_3DButton;
var R6MenuLegendButton m_LegendButton;
var R6Window3DButton m_3DWindow;
var R6WindowLegend m_LegendWindow;
var R6WindowTextLabel m_CodeName;
// NEW IN 1.60
var R6WindowTextLabel m_DateTime;
// NEW IN 1.60
var R6WindowTextLabel m_Location;
var Font m_labelFont;
var R6MenuActionPointMenu m_PopUpMenuPoint;
var R6MenuModeMenu m_PopUpMenuMode;
// Debug vars
var UWindowWindow DEB_FocusedWindow;

function Created()
{
	local int i;
	local R6MenuRSLookAndFeel LAF;
	local Region TheRegion;
	local float fLaptopPadding;
	local int labelWidth;
	local R6WindowWrappedTextArea WrapTextArea;

	LAF = R6MenuRSLookAndFeel(OwnerWindow.LookAndFeel);
	super.Created();
	fLaptopPadding = 2.0000000;
	TheRegion.Y = (((480 - LAF.m_stLapTopFrame.B.H) - 4) - LAF.m_NavBarBack[0].H);
	TheRegion.H = 16;
	TheRegion.Y = int(((m_NavBar.WinTop - float(TheRegion.H)) - fLaptopPadding));
	TheRegion.X = int(m_NavBar.WinLeft);
	TheRegion.W = 35;
	m_3DButton = R6Menu3DViewOnOffButton(CreateWindow(Class'R6Menu.R6Menu3DViewOnOffButton', float(TheRegion.X), float(TheRegion.Y), float(TheRegion.W), float(TheRegion.H), self));
	TheRegion.H = 16;
	TheRegion.Y = int(((m_NavBar.WinTop - float(TheRegion.H)) - fLaptopPadding));
	TheRegion.X = int(((m_NavBar.WinLeft + m_NavBar.WinWidth) - float(35)));
	TheRegion.W = 35;
	m_LegendButton = R6MenuLegendButton(CreateWindow(Class'R6Menu.R6MenuLegendButton', float(TheRegion.X), float(TheRegion.Y), float(TheRegion.W), float(TheRegion.H), self));
	TheRegion.X = (LAF.m_stLapTopFrame.L.W + 1);
	TheRegion.H = (2 + 23);
	(TheRegion.Y -= (2 + TheRegion.H));
	TheRegion.W = int((float(640) - m_Right.WinWidth));
	m_PlanningBar = R6MenuPlanningBar(CreateWindow(Class'R6Menu.R6MenuPlanningBar', float(TheRegion.X), float(TheRegion.Y), float(TheRegion.W), float(TheRegion.H), self));
	TheRegion.W = ((int((m_Right.WinLeft - m_Left.WinWidth)) / 3) + 2);
	TheRegion.H = ((int((m_Bottom.WinTop - m_Top.WinHeight)) / 3) + 2);
	TheRegion.X = int((m_Left.WinWidth + float(2)));
	TheRegion.Y = int(((m_Top.WinHeight + m_fLabelHeight) + float(1)));
	m_3DWindow = R6Window3DButton(CreateWindow(Class'R6Menu.R6Window3DButton', float(TheRegion.X), float(TheRegion.Y), float(TheRegion.W), float(TheRegion.H), self));
	m_3DWindow.HideWindow();
	m_LegendWindow = R6WindowLegend(CreateWindow(Class'R6Menu.R6WindowLegend', (m_Right.WinLeft - float(103)), ((m_Top.WinHeight + m_fLabelHeight) + float(1)), 100.0000000, 100.0000000, self));
	m_LegendWindow.HideWindow();
	m_labelFont = Root.Fonts[9];
	labelWidth = (int((m_Right.WinLeft - m_Left.WinWidth)) / 3);
	m_CodeName = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_Left.WinWidth, m_Top.WinHeight, float(labelWidth), m_fLabelHeight, self));
	m_DateTime = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', (m_CodeName.WinLeft + m_CodeName.WinWidth), m_Top.WinHeight, float(labelWidth), m_fLabelHeight, self));
	m_Location = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', (m_DateTime.WinLeft + m_DateTime.WinWidth), m_Top.WinHeight, m_DateTime.WinWidth, m_fLabelHeight, self));
	m_NavBar.m_PlanningButton.bDisabled = true;
	return;
}

function Reset()
{
	m_PlanningBar.Reset();
	return;
}

function ResetTeams(int iWhatToReset)
{
	CloseAllPopup();
	m_PlanningBar.ResetTeams(iWhatToReset);
	return;
}

function HideWindow()
{
	local LevelInfo li;

	Hide3DAndLegend();
	R6MenuRootWindow(Root).StopPlayMode();
	super(UWindowWindow).HideWindow();
	li = GetLevel();
	li.m_bAllow3DRendering = false;
	return;
}

function Hide3DAndLegend()
{
	// End:0x26
	if((R6PlanningCtrl(GetPlayerOwner()) != none))
	{
		R6PlanningCtrl(GetPlayerOwner()).TurnOff3DView();
	}
	m_3DWindow.Close3DWindow();
	m_LegendWindow.CloseLegendWindow();
	m_3DButton.m_bSelected = false;
	m_LegendButton.m_bSelected = false;
	CloseAllPopup();
	return;
}

function ShowWindow()
{
	local LevelInfo li;
	local R6MissionDescription CurrentMission;
	local R6GameOptions pGameOptions;
	local R6MenuRootWindow r6Root;

	r6Root = R6MenuRootWindow(Root);
	// End:0x70
	if((r6Root.m_bPlayerPlanInitialized && (!r6Root.m_bPlayerDoNotWant3DView)))
	{
		m_3DButton.m_bSelected = true;
		m_3DWindow.Toggle3DWindow();
		R6PlanningCtrl(GetPlayerOwner()).Toggle3DView();		
	}
	else
	{
		R6PlanningCtrl(GetPlayerOwner()).TurnOff3DView();
		m_3DWindow.Close3DWindow();
		m_3DButton.m_bSelected = false;
	}
	// End:0xEE
	if((r6Root.m_bPlayerPlanInitialized && r6Root.m_bPlayerWantLegend))
	{
		m_LegendButton.m_bSelected = true;
		m_LegendWindow.ToggleLegend();		
	}
	else
	{
		m_LegendButton.m_bSelected = false;
	}
	super(UWindowWindow).ShowWindow();
	li = GetLevel();
	li.m_bAllow3DRendering = true;
	CurrentMission = R6MissionDescription(R6Console(Root.Console).Master.m_StartGameInfo.m_CurrentMission);
	m_CodeName.SetProperties(Localize(CurrentMission.m_MapName, "ID_CODENAME", CurrentMission.LocalizationFile), 2, m_labelFont, Root.Colors.White, false);
	m_DateTime.SetProperties(Localize(CurrentMission.m_MapName, "ID_DATETIME", CurrentMission.LocalizationFile), 2, m_labelFont, Root.Colors.White, false);
	m_Location.SetProperties(Localize(CurrentMission.m_MapName, "ID_LOCATION", CurrentMission.LocalizationFile), 2, m_labelFont, Root.Colors.White, false);
	// End:0x2CF
	if((r6Root.m_bPlayerPlanInitialized == false))
	{
		pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
		// End:0x2CF
		if((pGameOptions.PopUpLoadPlan == true))
		{
			r6Root.m_ePopUpID = 48;
			r6Root.PopUpMenu(true);
		}
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.Style = 1;
	C.SetDrawColor(Root.Colors.GrayLight.R, Root.Colors.GrayLight.G, Root.Colors.GrayLight.B);
	DrawStretchedTextureSegment(C, (m_Left.WinWidth + float(1)), (m_Top.WinHeight + m_fLabelHeight), ((WinWidth - m_Right.WinWidth) - float(2)), 1.0000000, 18.0000000, 56.0000000, 1.0000000, 1.0000000, Texture'R6MenuTextures.Gui_BoxScroll');
	DrawStretchedTextureSegment(C, (m_Left.WinWidth + float(1)), (m_Top.WinHeight + m_fLabelHeight), 1.0000000, ((364.0000000 - m_Top.WinHeight) - m_fLabelHeight), 18.0000000, 56.0000000, 1.0000000, 1.0000000, Texture'R6MenuTextures.Gui_BoxScroll');
	DrawStretchedTextureSegment(C, ((WinWidth - m_Right.WinWidth) - float(2)), (m_Top.WinHeight + m_fLabelHeight), 1.0000000, ((364.0000000 - m_Top.WinHeight) - m_fLabelHeight), 18.0000000, 56.0000000, 1.0000000, 1.0000000, Texture'R6MenuTextures.Gui_BoxScroll');
	C.SetDrawColor(Root.Colors.GrayDark.R, Root.Colors.GrayDark.G, Root.Colors.GrayDark.B);
	DrawStretchedTextureSegment(C, 0.0000000, 364.0000000, m_PlanningBar.WinWidth, m_PlanningBar.WinHeight, 0.0000000, 364.0000000, m_PlanningBar.WinWidth, m_PlanningBar.WinHeight, m_TBackGround);
	C.SetDrawColor(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
	DrawStretchedTextureSegment(C, 0.0000000, m_Top.WinHeight, WinWidth, m_fLabelHeight, 0.0000000, m_Top.WinHeight, WinWidth, m_fLabelHeight, m_TBackGround);
	DrawStretchedTextureSegment(C, m_Left.WinWidth, (m_Top.WinHeight + m_fLabelHeight), 1.0000000, 364.0000000, m_Left.WinWidth, (m_Top.WinHeight + m_fLabelHeight), 1.0000000, 364.0000000, m_TBackGround);
	DrawStretchedTextureSegment(C, ((WinWidth - m_Right.WinWidth) - float(1)), (m_Top.WinHeight + m_fLabelHeight), 1.0000000, 364.0000000, ((WinWidth - m_Right.WinWidth) - float(1)), (m_Top.WinHeight + m_fLabelHeight), 1.0000000, 364.0000000, m_TBackGround);
	DrawStretchedTextureSegment(C, 0.0000000, (364.0000000 + m_PlanningBar.WinHeight), WinWidth, 96.0000000, 0.0000000, (364.0000000 + m_PlanningBar.WinHeight), WinWidth, 96.0000000, m_TBackGround);
	m_HelpTextBar.m_HelpTextBar.m_szDefaultText = Localize("PlanningMenu", "LevelText", "R6Menu");
	m_HelpTextBar.m_HelpTextBar.m_szDefaultText = (m_HelpTextBar.m_HelpTextBar.m_szDefaultText @ string((R6PlanningCtrl(GetPlayerOwner()).m_iLevelDisplay - 100)));
	// End:0x550
	if(bShowLog)
	{
		// End:0x550
		if((DEB_FocusedWindow != Root.FocusedWindow))
		{
			Log(("-->FocusedWindow: " $ string(Root.FocusedWindow)));
			DEB_FocusedWindow = Root.FocusedWindow;
		}
	}
	DrawLaptopFrame(C);
	return;
}

function Tick(float fDelta)
{
	local R6PlanningCtrl PlanningCtrl;
	local Region TheRegion;

	super(UWindowWindow).Tick(fDelta);
	// End:0x44F
	if(GetPlayerOwner().IsA('R6PlanningCtrl'))
	{
		PlanningCtrl = R6PlanningCtrl(GetPlayerOwner());
		// End:0x1E5
		if((Root.m_bUseDragIcon == false))
		{
			// End:0x90
			if((Root.MouseX < (m_Left.WinWidth + float(1))))
			{
				PlanningCtrl.m_bMoveLeft = 1;
				m_bMoveRLByLaptop = true;
				m_bClosePopup = true;				
			}
			else
			{
				// End:0xD2
				if((Root.MouseX > (m_Right.WinLeft - float(1))))
				{
					PlanningCtrl.m_bMoveRight = 1;
					m_bMoveRLByLaptop = true;					
				}
				else
				{
					// End:0x110
					if((m_bMoveRLByLaptop == true))
					{
						m_bMoveRLByLaptop = false;
						PlanningCtrl.m_bMoveLeft = 0;
						PlanningCtrl.m_bMoveRight = 0;
						m_bClosePopup = true;
					}
				}
			}
			// End:0x15A
			if((Root.MouseY < (m_Top.WinHeight + float(1))))
			{
				PlanningCtrl.m_bMoveUp = 1;
				m_bMoveUDByLaptop = true;
				m_bClosePopup = true;				
			}
			else
			{
				// End:0x1A4
				if((Root.MouseY > (m_Bottom.WinTop - float(1))))
				{
					PlanningCtrl.m_bMoveDown = 1;
					m_bMoveUDByLaptop = true;
					m_bClosePopup = true;					
				}
				else
				{
					// End:0x1E2
					if((m_bMoveUDByLaptop == true))
					{
						m_bMoveUDByLaptop = false;
						PlanningCtrl.m_bMoveDown = 0;
						PlanningCtrl.m_bMoveUp = 0;
						m_bClosePopup = true;
					}
				}
			}			
		}
		else
		{
			// End:0x220
			if((Root.MouseX < float(23)))
			{
				PlanningCtrl.m_bMoveLeft = 1;
				m_bMoveRLByLaptop = true;
				m_bClosePopup = true;				
			}
			else
			{
				// End:0x256
				if((Root.MouseX > float(616)))
				{
					PlanningCtrl.m_bMoveRight = 1;
					m_bMoveRLByLaptop = true;					
				}
				else
				{
					// End:0x294
					if((m_bMoveRLByLaptop == true))
					{
						m_bMoveRLByLaptop = false;
						PlanningCtrl.m_bMoveLeft = 0;
						PlanningCtrl.m_bMoveRight = 0;
						m_bClosePopup = true;
					}
				}
			}
			// End:0x2CF
			if((Root.MouseY < float(52)))
			{
				PlanningCtrl.m_bMoveUp = 1;
				m_bMoveUDByLaptop = true;
				m_bClosePopup = true;				
			}
			else
			{
				// End:0x30D
				if((Root.MouseY > float(362)))
				{
					PlanningCtrl.m_bMoveDown = 1;
					m_bMoveUDByLaptop = true;
					m_bClosePopup = true;					
				}
				else
				{
					// End:0x34B
					if((m_bMoveUDByLaptop == true))
					{
						m_bMoveUDByLaptop = false;
						PlanningCtrl.m_bMoveDown = 0;
						PlanningCtrl.m_bMoveUp = 0;
						m_bClosePopup = true;
					}
				}
			}
		}
		// End:0x44F
		if((PlanningCtrl.m_bFirstTick == true))
		{
			PlanningCtrl.m_bFirstTick = false;
			TheRegion.W = (int((m_Right.WinLeft - m_Left.WinWidth)) / 3);
			TheRegion.H = (int((m_Bottom.WinTop - m_Top.WinHeight)) / 3);
			TheRegion.X = int((m_Left.WinWidth + float(3)));
			TheRegion.Y = int(((m_Top.WinHeight + m_fLabelHeight) + float(2)));
			PlanningCtrl.Set3DViewPosition(TheRegion.X, TheRegion.Y, TheRegion.H, TheRegion.W);
		}
	}
	// End:0x466
	if(m_bClosePopup)
	{
		CloseAllPopup();
		m_bClosePopup = false;
	}
	return;
}

function LMouseDown(float fMouseX, float fMouseY)
{
	local R6PlanningCtrl PlanningCtrl;

	super(UWindowWindow).LMouseDown(fMouseX, fMouseY);
	// End:0x2D
	if((m_bPopUpMenuPoint || m_bPopUpMenuSpeed))
	{
		CloseAllPopup();		
	}
	else
	{
		PlanningCtrl = R6PlanningCtrl(GetPlayerOwner());
		// End:0x82
		if((PlanningCtrl != none))
		{
			PlanningCtrl.LMouseDown((fMouseX * Root.GUIScale), (fMouseY * Root.GUIScale));
		}
	}
	return;
}

function LMouseUp(float fMouseX, float fMouseY)
{
	local R6PlanningCtrl PlanningCtrl;

	super(UWindowWindow).LMouseUp(fMouseX, fMouseY);
	PlanningCtrl = R6PlanningCtrl(GetPlayerOwner());
	// End:0x65
	if((PlanningCtrl != none))
	{
		PlanningCtrl.LMouseUp((fMouseX * Root.GUIScale), (fMouseY * Root.GUIScale));
	}
	return;
}

function RMouseDown(float fMouseX, float fMouseY)
{
	local R6PlanningCtrl PlanningCtrl;

	super(UWindowWindow).RMouseDown(fMouseX, fMouseY);
	// End:0x2D
	if((m_bPopUpMenuPoint || m_bPopUpMenuSpeed))
	{
		CloseAllPopup();		
	}
	else
	{
		PlanningCtrl = R6PlanningCtrl(GetPlayerOwner());
		// End:0x82
		if((PlanningCtrl != none))
		{
			PlanningCtrl.RMouseDown((fMouseX * Root.GUIScale), (fMouseY * Root.GUIScale));
		}
	}
	return;
}

function RMouseUp(float fMouseX, float fMouseY)
{
	local R6PlanningCtrl PlanningCtrl;

	super(UWindowWindow).RMouseUp(fMouseX, fMouseY);
	PlanningCtrl = R6PlanningCtrl(GetPlayerOwner());
	// End:0x65
	if((PlanningCtrl != none))
	{
		PlanningCtrl.RMouseUp((fMouseX * Root.GUIScale), (fMouseY * Root.GUIScale));
	}
	return;
}

function MouseMove(float fMouseX, float fMouseY)
{
	local R6PlanningCtrl PlanningCtrl;

	super(UWindowWindow).MouseMove(fMouseX, fMouseY);
	PlanningCtrl = R6PlanningCtrl(GetPlayerOwner());
	// End:0x65
	if((PlanningCtrl != none))
	{
		PlanningCtrl.MouseMove((fMouseX * Root.GUIScale), (fMouseY * Root.GUIScale));
	}
	return;
}

//-----------------------------------------------------------//
//                      Mouse functions                      //
//-----------------------------------------------------------//
function SetMousePos(float X, float Y)
{
	local float fMouseX, fMouseY;

	// End:0xD8
	if((Root.m_bUseDragIcon == true))
	{
		fMouseX = X;
		fMouseY = Y;
		// End:0x47
		if((fMouseX < float(22)))
		{
			fMouseX = 22.0000000;			
		}
		else
		{
			// End:0x63
			if((fMouseX > float(617)))
			{
				fMouseX = 617.0000000;
			}
		}
		// End:0x7F
		if((fMouseY < float(51)))
		{
			fMouseY = 51.0000000;			
		}
		else
		{
			// End:0x9B
			if((fMouseY > float(363)))
			{
				fMouseY = 363.0000000;
			}
		}
		Root.Console.MouseX = fMouseX;
		Root.Console.MouseY = fMouseY;		
	}
	else
	{
		super.SetMousePos(X, Y);
	}
	return;
}

//-----------------------------------------------------------//
//                      External commands                    //
//-----------------------------------------------------------//
function KeyType(int iInputKey, float X, float Y)
{
	switch(iInputKey)
	{
		// End:0x21
		case 1024:
			DisplayActionTypePopUp(X, Y);
			return;
		// End:0x3B
		case 1026:
			DisplayPathFlagPopUp(X, Y);
			return;
		// End:0xFFFF
		default:
			return;
			break;
	}
}

function DisplayActionTypePopUp(float X, float Y)
{
	local bool bDisplayUp, bDisplayLeft;

	// End:0x37
	if(((X / (m_Right.WinLeft - m_Left.WinWidth)) > 0.5000000))
	{
		bDisplayLeft = true;
	}
	// End:0x6E
	if(((Y / (m_Bottom.WinTop - m_Top.WinHeight)) > 0.5000000))
	{
		bDisplayUp = true;
	}
	// End:0x96
	if((m_3DButton.m_bSelected == true))
	{
		Y = 200.0000000;
		bDisplayUp = false;
	}
	// End:0xE1
	if((m_PopUpMenuPoint == none))
	{
		m_PopUpMenuPoint = R6MenuActionPointMenu(CreateWindow(Root.MenuClassDefines.ClassActionPointPupUpMenu, X, Y, 100.0000000, 100.0000000, self));		
	}
	else
	{
		m_PopUpMenuPoint.WinLeft = X;
		m_PopUpMenuPoint.WinTop = Y;
	}
	m_PopUpMenuPoint.AjustPosition(bDisplayUp, bDisplayLeft);
	R6MenuListActionTypeButton(m_PopUpMenuPoint.m_ButtonList).DisplayMilestoneButton();
	m_PopUpMenuPoint.ShowWindow();
	m_bPopUpMenuPoint = true;
	return;
}

function DisplayPathFlagPopUp(float X, float Y)
{
	local bool bDisplayUp, bDisplayLeft;

	// End:0x37
	if(((X / (m_Right.WinLeft - m_Left.WinWidth)) > 0.5000000))
	{
		bDisplayLeft = true;
	}
	// End:0x6E
	if(((Y / (m_Bottom.WinTop - m_Top.WinHeight)) > 0.5000000))
	{
		bDisplayUp = true;
	}
	// End:0x96
	if((m_3DButton.m_bSelected == true))
	{
		Y = 200.0000000;
		bDisplayUp = false;
	}
	// End:0xFC
	if((m_PopUpMenuMode == none))
	{
		m_PopUpMenuMode = R6MenuModeMenu(CreateWindow(Root.MenuClassDefines.ClassMovementModePupUpMenu, X, Y, 100.0000000, 100.0000000, self));
		m_PopUpMenuMode.AjustPosition(bDisplayUp, bDisplayLeft);		
	}
	else
	{
		m_PopUpMenuMode.WinLeft = X;
		m_PopUpMenuMode.WinTop = Y;
		m_PopUpMenuMode.AjustPosition(bDisplayUp, bDisplayLeft);
		m_PopUpMenuMode.ShowWindow();
	}
	m_bPopUpMenuSpeed = true;
	return;
}

function CloseAllPopup()
{
	// End:0x20
	if(bShowLog)
	{
		Log("Closing all Popups!");
	}
	// End:0x56
	if(((m_PopUpMenuPoint != none) && m_PopUpMenuPoint.bWindowVisible))
	{
		m_PopUpMenuPoint.HideWindow();
		m_bPopUpMenuPoint = false;
	}
	// End:0x8C
	if(((m_PopUpMenuMode != none) && m_PopUpMenuMode.bWindowVisible))
	{
		m_PopUpMenuMode.HideWindow();
		m_bPopUpMenuSpeed = false;
	}
	return;
}

// Ideally Key would be a EInputKey but I can't see that class here.
function WindowEvent(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	local R6PlanningCtrl PlanningCtrl;

	// End:0x3F
	if((int(R6MenuRootWindow(Root).m_ePopUpID) != int(0)))
	{
		super(UWindowWindow).WindowEvent(Msg, C, X, Y, Key);
		return;
	}
	switch(Msg)
	{
		// End:0x7A
		case 9:
			// End:0x77
			if(GetPlayerOwner().IsA('R6PlanningCtrl'))
			{
				PlanningCtrl = R6PlanningCtrl(GetPlayerOwner());
				CloseAllPopup();
			}
			// End:0xD3
			break;
		// End:0xAE
		case 8:
			// End:0xAB
			if(GetPlayerOwner().IsA('R6PlanningCtrl'))
			{
				PlanningCtrl = R6PlanningCtrl(GetPlayerOwner());
				CloseAllPopup();
			}
			// End:0xD3
			break;
		// End:0xFFFF
		default:
			super(UWindowWindow).WindowEvent(Msg, C, X, Y, Key);
			// End:0xD3
			break;
			break;
	}
	return;
}

defaultproperties
{
	m_fLabelHeight=18.0000000
}
