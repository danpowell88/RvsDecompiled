//=============================================================================
// R6WindowComboControl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowComboControl.uc : A combo box with or without a text left of the combo box
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//    2002/07/23 * Modifications by Yannick Joly
//=============================================================================
class R6WindowComboControl extends UWindowComboControl;

var int m_iButtonID;
var R6WindowTextLabel m_pComboTextLabel;  // the text of the combo

function Created()
{
	m_pComboTextLabel = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 0.0000000, WinWidth, LookAndFeel.Size_ComboHeight, self));
	m_pComboTextLabel.SetProperties("", 0, Root.Fonts[5], Root.Colors.White, false);
	EditBox = UWindowEditBox(CreateWindow(Class'UWindow.UWindowEditBox', 0.0000000, 0.0000000, ((WinWidth - LookAndFeel.Size_ComboButtonWidth) + float(1)), LookAndFeel.Size_ComboHeight, self));
	EditBox.NotifyOwner = self;
	EditBox.bTransient = true;
	EditBox.bCanEdit = false;
	EditBox.m_bDrawEditBorders = true;
	EditBox.m_BorderColor = Root.Colors.White;
	EditBox.Align = 2;
	EditBox.m_bUseNewPaint = true;
	Button = UWindowComboButton(CreateWindow(Class'UWindow.UWindowComboButton', (WinWidth - LookAndFeel.Size_ComboButtonWidth), 0.0000000, LookAndFeel.Size_ComboButtonWidth, LookAndFeel.Size_ComboHeight, self));
	Button.Owner = self;
	Button.bAlwaysOnTop = true;
	Button.m_bDrawButtonBorders = true;
	Button.m_BorderColor = Root.Colors.White;
	Button.RegionScale = 1.0000000;
	List = UWindowComboList(Root.CreateWindow(ListClass, 0.0000000, 0.0000000, ((Button.WinLeft + Button.WinWidth) - EditBox.WinLeft), 100.0000000, self));
	List.LookAndFeel = LookAndFeel;
	List.Owner = self;
	List.Setup();
	List.HBorder = 1;
	List.VBorder = 1;
	List.HideWindow();
	bListVisible = false;
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	List.bLeaveOnscreen = (bListVisible && bLeaveOnscreen);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0x1A6
	if((!m_bDisabled))
	{
		// End:0xC7
		if(EditBox.m_bMouseOn)
		{
			m_pComboTextLabel.TextColor = Root.Colors.BlueLight;
			EditBox.m_BorderColor = Root.Colors.BlueLight;
			Button.m_BorderColor = Root.Colors.BlueLight;
			List.SetBorderColor(Root.Colors.BlueLight);
			ParentWindow.MouseEnter();			
		}
		else
		{
			// End:0x1A6
			if((!bListVisible))
			{
				// End:0x1A6
				if(m_pComboTextLabel.TextColor != Root.Colors.White)
				{
					m_pComboTextLabel.TextColor = Root.Colors.White;
					EditBox.m_BorderColor = Root.Colors.White;
					Button.m_BorderColor = Root.Colors.White;
					List.SetBorderColor(Root.Colors.White);
					ParentWindow.MouseLeave();
				}
			}
		}
	}
	return;
}

//===========================================================================================
// AdjustEditBoxW: Adjust the edit box window in the combocontrol -- the edit box is place at the end of the combo control
//===========================================================================================
function AdjustEditBoxW(float _fY, float _fWidth, float _fHeight)
{
	Button.WinTop = _fY;
	EditBox.WinLeft = ((Button.WinLeft + float(1)) - _fWidth);
	EditBox.WinTop = Button.WinTop;
	EditBox.WinWidth = _fWidth;
	EditBox.WinHeight = _fHeight;
	EditBox.Font = 5;
	EditBoxWidth = EditBox.WinWidth;
	List.WinWidth = ((Button.WinLeft + Button.WinWidth) - EditBox.WinLeft);
	return;
}

//===========================================================================================
// AdjustTextW: Adjust the text window in the combocontrol
//===========================================================================================
function AdjustTextW(string _szTitle, float _fX, float _fY, float _fWidth, float _fHeight)
{
	m_pComboTextLabel.WinLeft = _fX;
	m_pComboTextLabel.WinTop = _fY;
	m_pComboTextLabel.WinWidth = _fWidth;
	m_pComboTextLabel.WinHeight = _fHeight;
	m_pComboTextLabel.SetNewText(_szTitle, true);
	return;
}

//====================================================================
// SetEditBoxTip: set the tooltipstring, this string is return to the parent window when the mouse is over the edit box
//====================================================================
function SetEditBoxTip(string _szToolTip)
{
	EditBox.ToolTipString = _szToolTip;
	return;
}

//====================================================================
// SetDisableButton: if the button is disable, set all the classes to disable -- ex. menu options in/out game
//====================================================================
function SetDisableButton(bool _bDisable)
{
	// End:0x9A
	if(_bDisable)
	{
		EditBox.m_BorderColor = Root.Colors.ButtonTextColor[1];
		Button.m_BorderColor = Root.Colors.ButtonTextColor[1];
		Button.bDisabled = true;
		m_pComboTextLabel.TextColor = Root.Colors.ButtonTextColor[1];
		m_bDisabled = true;
	}
	return;
}

defaultproperties
{
	ListClass=Class'R6Window.R6WindowComboList'
}
