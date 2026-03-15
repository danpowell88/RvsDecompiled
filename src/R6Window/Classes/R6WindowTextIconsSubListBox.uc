//=============================================================================
// R6WindowTextIconsSubListBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowTextIconsSubListBox.uc : This list is designed to be used
//                                      with th R6WindowDynTeamList
//                                   Instanciate this with the createControl
//                                         
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/28 * Created by Alexandre Dionne
//=============================================================================
class R6WindowTextIconsSubListBox extends UWindowDialogControl;

var int m_LabelDrawStyle;
var int m_IAddRemoveXPos;
// NEW IN 1.60
var int m_IAddRemoveYPos;
// NEW IN 1.60
var int m_IAddRemoveBgXPos;
// NEW IN 1.60
var int m_IAddRemoveBgYPos;
var int m_IUpDownXPos;  // X pos from right side
// NEW IN 1.60
var int m_IUpDownBgXPos;
var int m_IUpDownYPos;
// NEW IN 1.60
var int m_IUpDownBgYPos;
var int m_IUpDownBetweenPadding;
var int m_maxItemsCount;
var R6WindowTextIconsListBox m_listBox;
//Top Label
var R6WindowButton m_RemoveButton;
// NEW IN 1.60
var R6WindowButton m_AddButton;
var R6WindowButton m_UpButton;
var R6WindowButton m_DownButton;
var R6WindowTextLabel m_Title;
var R6WindowBitMap m_UpDownBg;
var R6WindowBitMap m_AddRemoveBg;
var Texture m_LabelTexture;
var Region m_UpDownBgReg;
var Region m_AddRemoveBgReg;
var Color m_LabelColor;
var Region m_LabelRegionTop;
var Region m_LabelRegionTile;
var Region m_LabelRegionBottom;
var RegionButton m_UpReg;
// NEW IN 1.60
var RegionButton m_DownReg;

function Created()
{
	local Region normalReg, overReg, disabledReg, downReg;
	local float ButtonBorderWidth, ButtonBorderHeight, UpDownButtonWidth, UpDownButtonHeight, fLabelWidth;

	local Texture ButtonTexture;

	super.Created();
	m_listBox = R6WindowTextIconsListBox(CreateWindow(Class'R6Window.R6WindowTextIconsListBox', 0.0000000, float(m_LabelRegionTop.H), WinWidth, (WinHeight - float(m_LabelRegionTop.H)), self));
	m_listBox.SetCornerType(1);
	m_listBox.m_IgnoreAllreadySelected = false;
	ButtonTexture = R6WindowLookAndFeel(LookAndFeel).m_R6ScrollTexture;
	normalReg.X = 204;
	normalReg.Y = 0;
	normalReg.W = 18;
	normalReg.H = 12;
	overReg.X = 204;
	overReg.Y = 12;
	overReg.W = 18;
	overReg.H = 12;
	disabledReg.X = 204;
	disabledReg.Y = 24;
	disabledReg.W = 18;
	disabledReg.H = 12;
	ButtonBorderWidth = float(normalReg.W);
	ButtonBorderHeight = float(normalReg.H);
	UpDownButtonWidth = float(m_UpReg.Up.W);
	UpDownButtonHeight = float(m_UpReg.Up.H);
	m_RemoveButton = R6WindowButton(CreateWindow(Class'R6Window.R6WindowButton', float(m_IAddRemoveXPos), float(m_IAddRemoveYPos), ButtonBorderWidth, ButtonBorderHeight, self));
	m_RemoveButton.ToolTipString = Localize("Tip", "GearRoomButRemove", "R6Menu");
	m_RemoveButton.m_bDrawBorders = false;
	m_RemoveButton.bUseRegion = true;
	m_RemoveButton.DisabledTexture = ButtonTexture;
	m_RemoveButton.DisabledRegion = disabledReg;
	m_RemoveButton.DownTexture = ButtonTexture;
	m_RemoveButton.DownRegion = disabledReg;
	m_RemoveButton.OverTexture = ButtonTexture;
	m_RemoveButton.OverRegion = overReg;
	m_RemoveButton.UpTexture = ButtonTexture;
	m_RemoveButton.UpRegion = normalReg;
	m_RemoveButton.m_iDrawStyle = 5;
	m_RemoveButton.HideWindow();
	normalReg.X = 222;
	overReg.X = 222;
	disabledReg.X = 222;
	m_AddButton = R6WindowButton(CreateWindow(Class'R6Window.R6WindowButton', float(m_IAddRemoveXPos), float(m_IAddRemoveYPos), ButtonBorderWidth, ButtonBorderHeight, self));
	m_AddButton.ToolTipString = Localize("Tip", "GearRoomButAdd", "R6Menu");
	m_AddButton.m_bDrawBorders = false;
	m_AddButton.bUseRegion = true;
	m_AddButton.DisabledTexture = ButtonTexture;
	m_AddButton.DisabledRegion = disabledReg;
	m_AddButton.DownTexture = ButtonTexture;
	m_AddButton.DownRegion = disabledReg;
	m_AddButton.OverTexture = ButtonTexture;
	m_AddButton.OverRegion = overReg;
	m_AddButton.UpTexture = ButtonTexture;
	m_AddButton.UpRegion = normalReg;
	m_AddButton.m_iDrawStyle = 5;
	m_AddRemoveBg = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', float(m_IAddRemoveBgXPos), float(m_IAddRemoveBgYPos), float(m_AddRemoveBgReg.W), float(m_AddRemoveBgReg.H), self));
	m_AddRemoveBg.bAlwaysBehind = true;
	m_AddRemoveBg.m_bUseColor = true;
	m_AddRemoveBg.m_iDrawStyle = 5;
	m_AddRemoveBg.t = ButtonTexture;
	m_AddRemoveBg.R = m_AddRemoveBgReg;
	m_AddRemoveBg.SendToBack();
	m_UpButton = R6WindowButton(CreateWindow(Class'R6Window.R6WindowButton', (WinWidth - float(m_IUpDownXPos)), float(m_IUpDownYPos), UpDownButtonWidth, UpDownButtonHeight, self));
	m_UpButton.ToolTipString = Localize("Tip", "GearRoomButUp", "R6Menu");
	m_UpButton.m_bDrawBorders = false;
	m_UpButton.bUseRegion = true;
	m_UpButton.DisabledTexture = ButtonTexture;
	m_UpButton.DisabledRegion = m_UpReg.Disabled;
	m_UpButton.DownTexture = ButtonTexture;
	m_UpButton.DownRegion = m_UpReg.Down;
	m_UpButton.OverTexture = ButtonTexture;
	m_UpButton.OverRegion = m_UpReg.Over;
	m_UpButton.UpTexture = ButtonTexture;
	m_UpButton.UpRegion = m_UpReg.Up;
	m_UpButton.m_iDrawStyle = 5;
	m_DownButton = R6WindowButton(CreateWindow(Class'R6Window.R6WindowButton', ((m_UpButton.WinLeft + m_UpButton.WinWidth) + float(m_IUpDownBetweenPadding)), float(m_IUpDownYPos), UpDownButtonWidth, UpDownButtonHeight, self));
	m_DownButton.ToolTipString = Localize("Tip", "GearRoomButDown", "R6Menu");
	m_DownButton.m_bDrawBorders = false;
	m_DownButton.bUseRegion = true;
	m_DownButton.DisabledTexture = ButtonTexture;
	m_DownButton.DisabledRegion = m_DownReg.Disabled;
	m_DownButton.DownTexture = ButtonTexture;
	m_DownButton.DownRegion = m_DownReg.Down;
	m_DownButton.OverTexture = ButtonTexture;
	m_DownButton.OverRegion = m_DownReg.Over;
	m_DownButton.UpTexture = ButtonTexture;
	m_DownButton.UpRegion = m_DownReg.Up;
	m_DownButton.m_iDrawStyle = 5;
	m_UpDownBg = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', (WinWidth - float(m_IUpDownBgXPos)), float(m_IUpDownBgYPos), float(m_UpDownBgReg.W), float(m_UpDownBgReg.H), self));
	m_UpDownBg.bAlwaysBehind = true;
	m_UpDownBg.m_bUseColor = true;
	m_UpDownBg.m_iDrawStyle = 5;
	m_UpDownBg.t = ButtonTexture;
	m_UpDownBg.R = m_UpDownBgReg;
	m_UpDownBg.SendToBack();
	fLabelWidth = (((m_UpButton.WinLeft - m_AddButton.WinLeft) - m_AddButton.WinWidth) - float(1));
	m_Title = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 0.0000000, WinWidth, float(m_LabelRegionTop.H), self));
	m_Title.bAlwaysBehind = true;
	m_Title.m_BGTexture = none;
	m_Title.m_bDrawBorders = false;
	m_Title.m_bFixedYPos = true;
	m_Title.TextY = 4.0000000;
	m_Title.SendToBack();
	return;
}

function Resized()
{
	m_listBox.SetSize(m_listBox.WinWidth, (WinHeight - float(m_LabelRegionTop.H)));
	return;
}

function Register(UWindowDialogClientWindow W)
{
	NotifyWindow = W;
	Notify(0);
	m_listBox.Register(W);
	m_AddButton.Register(W);
	m_RemoveButton.Register(W);
	m_UpButton.Register(W);
	m_DownButton.Register(W);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.Style = byte(m_LabelDrawStyle);
	C.SetDrawColor(m_LabelColor.R, m_LabelColor.G, m_LabelColor.B);
	DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, float(m_LabelRegionTop.W), float(m_LabelRegionTop.H), float(m_LabelRegionTop.X), float(m_LabelRegionTop.Y), float(m_LabelRegionTop.W), float(m_LabelRegionTop.H), m_LabelTexture);
	DrawStretchedTextureSegment(C, 0.0000000, float(m_LabelRegionTop.H), float(m_LabelRegionTile.W), ((WinHeight - float(m_LabelRegionTop.H)) - float(m_LabelRegionBottom.H)), float(m_LabelRegionTile.X), float(m_LabelRegionTile.Y), float(m_LabelRegionTile.W), float(m_LabelRegionTile.H), m_LabelTexture);
	DrawStretchedTextureSegment(C, 0.0000000, (WinHeight - float(m_LabelRegionBottom.H)), float(m_LabelRegionBottom.W), float(m_LabelRegionBottom.H), float(m_LabelRegionBottom.X), float(m_LabelRegionBottom.Y), float(m_LabelRegionBottom.W), float(m_LabelRegionBottom.H), m_LabelTexture);
	return;
}

function SetColor(Color NewColor)
{
	m_LabelColor = NewColor;
	m_UpDownBg.m_TextureColor = NewColor;
	m_AddRemoveBg.m_TextureColor = NewColor;
	return;
}

function UpdateButtons(optional int addButton)
{
	local bool bDrawingAddOrRemove;

	// End:0xA2
	if((m_listBox.m_SelectedItem != none))
	{
		m_UpButton.bDisabled = false;
		m_DownButton.bDisabled = false;
		// End:0x64
		if((m_listBox.m_SelectedItem.Next == none))
		{
			m_DownButton.bDisabled = true;
		}
		// End:0x9F
		if((m_listBox.m_SelectedItem.Prev == m_listBox.Items))
		{
			m_UpButton.bDisabled = true;
		}		
	}
	else
	{
		m_UpButton.bDisabled = true;
		m_DownButton.bDisabled = true;
	}
	// End:0xF2
	if((m_listBox.m_SelectedItem != none))
	{
		m_RemoveButton.ShowWindow();
		bDrawingAddOrRemove = true;		
	}
	else
	{
		m_RemoveButton.HideWindow();
	}
	// End:0x14A
	if(((addButton == 1) && (m_listBox.Items.Count() < m_maxItemsCount)))
	{
		m_AddButton.ShowWindow();
		bDrawingAddOrRemove = true;		
	}
	else
	{
		m_AddButton.HideWindow();
	}
	// End:0x186
	if((bDrawingAddOrRemove == true))
	{
		m_AddRemoveBg.ShowWindow();
		m_AddRemoveBg.SendToBack();		
	}
	else
	{
		m_AddRemoveBg.HideWindow();
	}
	// End:0x1C7
	if(bAcceptsFocus)
	{
		// End:0x1C7
		if((Root.FocusedWindow == m_listBox))
		{
			m_listBox.ActivateWindow(0, false);
		}
	}
	return;
}

//===================================================
// SetTip : set the tip string for thoses window
//===================================================
function SetTip(string _szTip)
{
	ToolTipString = _szTip;
	m_listBox.ToolTipString = _szTip;
	m_Title.ToolTipString = _szTip;
	return;
}

defaultproperties
{
	m_LabelDrawStyle=5
	m_IAddRemoveXPos=6
	m_IAddRemoveYPos=5
	m_IAddRemoveBgXPos=4
	m_IAddRemoveBgYPos=3
	m_IUpDownXPos=41
	m_IUpDownBgXPos=43
	m_IUpDownYPos=5
	m_IUpDownBgYPos=3
	m_IUpDownBetweenPadding=1
	m_maxItemsCount=4
	m_LabelTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_UpDownBgReg=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=33826,ZoneNumber=0)
	m_AddRemoveBgReg=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=55330,ZoneNumber=0)
	m_LabelColor=(R=255,G=255,B=255,A=0)
	m_LabelRegionTop=(Zone=Class'R6Window.R6WindowListBoxItem',iLeaf=123170,ZoneNumber=0)
	m_LabelRegionTile=(Zone=Class'R6Window.R6WindowListBoxItem',iLeaf=129058,ZoneNumber=0)
	m_LabelRegionBottom=(Zone=Class'R6Window.R6WindowListBoxItem',iLeaf=129826,ZoneNumber=0)
	m_UpReg=(Up=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=33826,ZoneNumber=0),W=17,H=12)
	m_DownReg=(Up=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=38434,ZoneNumber=0),W=17,H=12)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var g
