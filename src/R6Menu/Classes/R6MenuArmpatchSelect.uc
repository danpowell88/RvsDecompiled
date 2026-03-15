//=============================================================================
// R6MenuArmpatchSelect - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuArmpatchSelect.uc : Armpatch chooser for option menu
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/10 * Created by Alexandre Dionne
//=============================================================================
class R6MenuArmpatchSelect extends UWindowDialogClientWindow;

var R6WindowTextListBox m_ArmPatchListBox;
var R6WindowTextLabelExt m_pTextLabel;
var UWindowBitmap m_ArmpatchBitmap;
var Texture m_TDefaultTexture;
var Texture m_TBlankTexture;
var Texture m_TInvalidTexture;
var R6WindowListBoxItem m_DefaultItem;
var R6FileManager m_pFileManager;
var Region m_RBlankTexture;
var string m_path;
// NEW IN 1.60
var string m_Ext;

function CreateListBox(int X, int Y, int W, int H)
{
	// End:0x0D
	if((m_ArmPatchListBox != none))
	{
		return;
	}
	m_pFileManager = new Class'Engine.R6FileManager';
	m_ArmPatchListBox = R6WindowTextListBox(CreateControl(Class'R6Window.R6WindowTextListBox', float(X), float(Y), float(W), float(H), self));
	m_ArmPatchListBox.ListClass = Class'R6Window.R6WindowListBoxItem';
	m_ArmPatchListBox.SetCornerType(0);
	return;
}

function CreateTextLabel(int X, int Y, int W, int H, string _szText, string _szToolTip)
{
	// End:0x0D
	if((m_pTextLabel != none))
	{
		return;
	}
	m_pTextLabel = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', float(X), float(Y), float(W), float(H), self));
	m_pTextLabel.bAlwaysBehind = true;
	m_pTextLabel.SetNoBorder();
	m_pTextLabel.m_Font = Root.Fonts[5];
	m_pTextLabel.m_vTextColor = Root.Colors.White;
	m_pTextLabel.AddTextLabel(_szText, 0.0000000, 0.0000000, 150.0000000, 0, false);
	ToolTipString = _szToolTip;
	return;
}

function CreateArmPatchBitmap(int X, int Y, int W, int H)
{
	// End:0x0D
	if((m_ArmpatchBitmap != none))
	{
		return;
	}
	m_ArmpatchBitmap = UWindowBitmap(CreateWindow(Class'UWindow.UWindowBitmap', float(X), float(Y), float(W), float(H), self));
	m_ArmpatchBitmap.m_iDrawStyle = 1;
	m_ArmpatchBitmap.t = m_TBlankTexture;
	m_ArmpatchBitmap.R = m_RBlankTexture;
	return;
}

function RefreshListBox()
{
	local int iFiles, i;
	local string szFileName;
	local R6WindowListBoxItem NewItem;

	// End:0x0D
	if((m_ArmPatchListBox == none))
	{
		return;
	}
	m_ArmPatchListBox.Items.Clear();
	// End:0x54
	if((m_pFileManager == none))
	{
		Log("m_pFileManager == NONE");
		iFiles = 0;		
	}
	else
	{
		iFiles = m_pFileManager.GetNbFile(m_path, m_Ext);
	}
	m_DefaultItem = R6WindowListBoxItem(m_ArmPatchListBox.Items.Append(m_ArmPatchListBox.ListClass));
	m_DefaultItem.HelpText = Localize("Options", "DEFAULT", "R6Menu");
	m_DefaultItem.m_szToolTip = "";
	i = 0;
	J0xE8:

	// End:0x18B [Loop If]
	if((i < iFiles))
	{
		m_pFileManager.GetFileName(i, szFileName);
		// End:0x181
		if((szFileName != ""))
		{
			NewItem = R6WindowListBoxItem(m_ArmPatchListBox.Items.Append(m_ArmPatchListBox.ListClass));
			NewItem.HelpText = Left(szFileName, (Len(szFileName) - 4));
			NewItem.m_szToolTip = Caps(szFileName);
		}
		(i++);
		// [Loop Continue]
		goto J0xE8;
	}
	// End:0x1E3
	if((m_ArmPatchListBox.Items.Count() > 0))
	{
		m_ArmPatchListBox.SetSelectedItem(R6WindowListBoxItem(m_ArmPatchListBox.Items.Next));
		m_ArmPatchListBox.MakeSelectedVisible();
	}
	return;
}

function SetDesiredSelectedArmpatch(string _ArmPatchName)
{
	local int i;
	local bool Found;
	local R6WindowListBoxItem CurItem;
	local string inString;

	// End:0x16
	if((m_ArmPatchListBox.Items == none))
	{
		return;
	}
	inString = Caps(_ArmPatchName);
	CurItem = R6WindowListBoxItem(m_ArmPatchListBox.Items.Next);
	i = 0;
	J0x4C:

	// End:0xC2 [Loop If]
	if(((i < m_ArmPatchListBox.Items.Count()) && (Found == false)))
	{
		// End:0x9F
		if((CurItem.m_szToolTip == inString))
		{
			Found = true;
			// [Explicit Continue]
			goto J0xB8;
		}
		CurItem = R6WindowListBoxItem(CurItem.Next);
		J0xB8:

		(i++);
		// [Loop Continue]
		goto J0x4C;
	}
	// End:0xDF
	if(Found)
	{
		m_ArmPatchListBox.SetSelectedItem(CurItem);
	}
	return;
}

function string GetSelectedArmpatch()
{
	// End:0x73
	if((m_ArmPatchListBox.m_SelectedItem != none))
	{
		// End:0x6D
		if((Class'Engine.Actor'.static.ReplaceTexture((m_path $ m_ArmPatchListBox.m_SelectedItem.m_szToolTip), m_ArmpatchBitmap.t) == true))
		{
			return m_ArmPatchListBox.m_SelectedItem.m_szToolTip;			
		}
		else
		{
			return "";
		}		
	}
	else
	{
		return "";
	}
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	switch(E)
	{
		// End:0x48
		case 12:
			// End:0x45
			if((C == m_ArmPatchListBox))
			{
				m_pTextLabel.ChangeColorLabel(Root.Colors.ButtonTextColor[2], 0);
			}
			// End:0x14E
			break;
		// End:0x86
		case 9:
			// End:0x83
			if((C == m_ArmPatchListBox))
			{
				m_pTextLabel.ChangeColorLabel(Root.Colors.White, 0);
			}
			// End:0x14E
			break;
		// End:0x14B
		case 2:
			// End:0x148
			if((C == m_ArmPatchListBox))
			{
				// End:0x148
				if((m_ArmPatchListBox.m_SelectedItem != none))
				{
					// End:0xE2
					if((R6WindowListBoxItem(m_ArmPatchListBox.m_SelectedItem) == m_DefaultItem))
					{
						m_ArmpatchBitmap.t = m_TDefaultTexture;						
					}
					else
					{
						m_ArmpatchBitmap.t = m_TBlankTexture;
						// End:0x148
						if((Class'Engine.Actor'.static.ReplaceTexture((m_path $ m_ArmPatchListBox.m_SelectedItem.m_szToolTip), m_ArmpatchBitmap.t) == false))
						{
							m_ArmpatchBitmap.t = m_TInvalidTexture;
						}
					}
				}
			}
			// End:0x14E
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function SetToolTip(string _InString)
{
	m_ArmPatchListBox.ToolTipString = _InString;
	return;
}

defaultproperties
{
	m_TDefaultTexture=Texture'R6Characters_T.Rainbow.R6armpatch'
	m_TBlankTexture=Texture'R6MenuTextures.R6armpatchblank'
	m_TInvalidTexture=Texture'R6MenuTextures.NotValid'
	m_RBlankTexture=(Zone=Class'R6Menu.R6MenuRootWindow',iLeaf=16418,ZoneNumber=0)
	m_path="..\\ArmPatches\\"
	m_Ext="TGA"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: function Paint
