//=============================================================================
// R6MenuSinglePlayerCampaignCreate - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuSinglePlayerCampaignCreate.uc : Small group of control to create a
//											campaign		
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/17 * Created by Alexandre Dionne
//=============================================================================
class R6MenuSinglePlayerCampaignCreate extends UWindowDialogClientWindow;

var bool bShowLog;
var R6WindowTextLabel m_CampaignName;
// NEW IN 1.60
var R6WindowTextLabel m_Difficulty;
var R6WindowTextLabel m_Difficulty1;
// NEW IN 1.60
var R6WindowTextLabel m_Difficulty2;
// NEW IN 1.60
var R6WindowTextLabel m_Difficulty3;
var R6MenuDiffCustomMissionSelect m_pDiffSelection;
var R6WindowEditControl m_CampaignNameEdit;

function Created()
{
	local Color LabelTextColor;

	LabelTextColor = Root.Colors.White;
	m_CampaignName = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 5.0000000, 0.0000000, (WinWidth - float(5)), 25.0000000, self));
	m_CampaignName.Text = Localize("SinglePlayer", "CampaignName", "R6Menu");
	m_CampaignName.Align = 0;
	m_CampaignName.m_Font = Root.Fonts[5];
	m_CampaignName.TextColor = LabelTextColor;
	m_CampaignName.m_BGTexture = none;
	m_CampaignName.m_bDrawBorders = false;
	m_CampaignNameEdit = R6WindowEditControl(CreateControl(Class'R6Window.R6WindowEditControl', 3.0000000, 24.0000000, (WinWidth - float(6)), 15.0000000, self));
	m_CampaignNameEdit.SetValue(Localize("SinglePlayer", "DefaultCampaignName", "R6Menu"));
	m_CampaignNameEdit.EditBox.Font = 5;
	m_CampaignNameEdit.ForceCaps(true);
	m_CampaignNameEdit.SetEditBoxTip(Localize("Tip", "CampaignDefaultName", "R6Menu"));
	m_CampaignNameEdit.EditBox.SelectAll();
	m_CampaignNameEdit.SetMaxLength(30);
	m_Difficulty = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 59.0000000, WinWidth, 30.0000000, self));
	m_Difficulty.Text = Localize("SinglePlayer", "Difficulty", "R6Menu");
	m_Difficulty.Align = 2;
	m_Difficulty.m_Font = Root.Fonts[8];
	m_Difficulty.TextColor = LabelTextColor;
	m_Difficulty.m_bDrawBorders = false;
	m_pDiffSelection = R6MenuDiffCustomMissionSelect(CreateWindow(Class'R6Menu.R6MenuDiffCustomMissionSelect', 0.0000000, (m_Difficulty.WinTop + m_Difficulty.WinHeight), WinWidth, (WinHeight - (m_Difficulty.WinTop + m_Difficulty.WinHeight)), self));
	m_pDiffSelection.m_pButLevel1.WinTop = (m_pDiffSelection.m_pButLevel1.WinTop + float(1));
	m_pDiffSelection.m_pButLevel2.WinTop = (m_pDiffSelection.m_pButLevel2.WinTop + float(12));
	m_pDiffSelection.m_pButLevel3.WinTop = (m_pDiffSelection.m_pButLevel3.WinTop + float(23));
	bAlwaysAcceptsFocus = true;
	return;
}

function KeyDown(int Key, float X, float Y)
{
	super(UWindowWindow).KeyDown(Key, X, Y);
	// End:0x73
	if(((Key == int(Root.Console.13)) && (m_CampaignNameEdit.GetValue() != "")))
	{
		R6MenuSinglePlayerWidget(OwnerWindow).ButtonClicked(int(R6MenuSinglePlayerWidget(OwnerWindow).3));
	}
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0x5D
	if((((C == m_CampaignNameEdit) && (int(E) == 7)) && (m_CampaignNameEdit.GetValue() != "")))
	{
		R6MenuSinglePlayerWidget(OwnerWindow).ButtonClicked(int(R6MenuSinglePlayerWidget(OwnerWindow).3));
	}
	return;
}

function Reset()
{
	m_CampaignNameEdit.SetValue(Localize("SinglePlayer", "DefaultCampaignName", "R6Menu"));
	m_CampaignNameEdit.EditBox.SelectAll();
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.Style = 4;
	DrawStretchedTextureSegment(C, m_Difficulty.WinLeft, m_Difficulty.WinTop, m_Difficulty.WinWidth, m_Difficulty.WinHeight, 77.0000000, 0.0000000, 4.0000000, 29.0000000, Texture'R6MenuTextures.Gui_BoxScroll');
	C.Style = 5;
	C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	DrawStretchedTexture(C, 0.0000000, m_Difficulty.WinTop, WinWidth, 1.0000000, Texture'UWindow.WhiteTexture');
	DrawStretchedTexture(C, 0.0000000, (m_Difficulty.WinTop + m_Difficulty.WinHeight), WinWidth, 1.0000000, Texture'UWindow.WhiteTexture');
	return;
}

function bool CreateCampaign()
{
	local R6MenuRootWindow r6Root;
	local int iNbArrayElements, iNbTotalOperatives, i;
	local R6Operative tmpOperative;
	local Class<R6Operative> tmpOperativeClass;
	local R6PlayerCampaign PlayerCampaign;
	local R6ModMgr pModManager;

	pModManager = Class'Engine.Actor'.static.GetModMgr();
	r6Root = R6MenuRootWindow(Root);
	iNbArrayElements = 0;
	// End:0x3D4
	if((((m_CampaignNameEdit.GetValue() != "") && (r6Root != none)) && (R6MenuSinglePlayerWidget(OwnerWindow).m_pFileManager != none)))
	{
		PlayerCampaign = R6Console(r6Root.Console).m_PlayerCampaign;
		PlayerCampaign.m_FileName = m_CampaignNameEdit.GetValue();
		ReplaceText(PlayerCampaign.m_FileName, " ", "_");
		PlayerCampaign.m_iDifficultyLevel = m_pDiffSelection.GetDifficulty();
		PlayerCampaign.m_CampaignFileName = Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod.m_szCampaignIniFile;
		PlayerCampaign.m_iNoMission = 0;
		PlayerCampaign.m_OperativesMissionDetails = none;
		PlayerCampaign.m_OperativesMissionDetails = new (none) Class'R6Game.R6MissionRoster';
		iNbArrayElements = R6Console(r6Root.Console).m_CurrentCampaign.m_OperativeClassName.Length;
		i = 0;
		J0x177:

		// End:0x239 [Loop If]
		if((i < iNbArrayElements))
		{
			tmpOperative = new (none) Class<R6Operative>(DynamicLoadObject(R6Console(r6Root.Console).m_CurrentCampaign.m_OperativeClassName[i], Class'Core.Class'));
			PlayerCampaign.m_OperativesMissionDetails.m_MissionOperatives[i] = tmpOperative;
			// End:0x22F
			if(bShowLog)
			{
				Log((("adding" @ string(tmpOperative)) @ "to default player campaign roster"));
			}
			(i++);
			// [Loop Continue]
			goto J0x177;
		}
		iNbTotalOperatives = i;
		// End:0x33A
		if((pModManager.m_pCurrentMod.m_bUseCustomOperatives == true))
		{
			i = 0;
			J0x269:

			// End:0x33A [Loop If]
			if((i < pModManager.GetPackageMgr().GetNbPackage()))
			{
				tmpOperativeClass = Class<R6Operative>(pModManager.GetPackageMgr().GetFirstClassFromPackage(i, Class'R6Game.R6Operative'));
				J0x2BA:

				// End:0x330 [Loop If]
				if((tmpOperativeClass != none))
				{
					tmpOperative = new (none) tmpOperativeClass;
					// End:0x309
					if((tmpOperative != none))
					{
						PlayerCampaign.m_OperativesMissionDetails.m_MissionOperatives[iNbTotalOperatives] = tmpOperative;
						(iNbTotalOperatives++);
					}
					tmpOperativeClass = Class<R6Operative>(pModManager.GetPackageMgr().GetNextClassFromPackage());
					// [Loop Continue]
					goto J0x2BA;
				}
				(i++);
				// [Loop Continue]
				goto J0x269;
			}
		}
		// End:0x3D2
		if((R6MenuSinglePlayerWidget(OwnerWindow).m_pFileManager.SaveCampaign(PlayerCampaign) == false))
		{
			r6Root.SimplePopUp(Localize("POPUP", "FILEERROR", "R6Menu"), ((PlayerCampaign.m_FileName @ ":") @ Localize("POPUP", "FILEERRORPROBLEM", "R6Menu")), 2, 1);
			return false;			
		}
		else
		{
			return true;
		}
	}
	return false;
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var y
