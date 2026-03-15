//=============================================================================
// R6MenuDynTeamListsControl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuDynTeamListsControl.uc : Control that will allow
//                                  Dynamic Selections of Team Rosters
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/21 * Created by Alexandre Dionne
//=============================================================================

///////////////////////////////////////////////////////////////////////////////
// Please take note that this control can not display right 
// If not initalized with th right size
///////////////////////////////////////////////////////////////////////////////
class R6MenuDynTeamListsControl extends UWindowDialogClientWindow;

var int m_SubListTopHeight;  // For size calculations == Top label and offset
var int m_iMaxOperativeCount;
//Debug
var bool bShowLog;
var float m_fButtonTabWidth;
// NEW IN 1.60
var float m_fButtonTabHeight;
var float m_MinSubListHeight;
// NEW IN 1.60
var float m_SubListByItemHeight;
// NEW IN 1.60
var float TotalSublistsHeight;
var float m_fVPadding;  // Vertical Padding Between Controls
var float m_fFirsButtonOffset;
// NEW IN 1.60
var float m_fHButtonPadding;
// NEW IN 1.60
var float m_fHButtonOffset;
var R6WindowListBoxAnchorButton m_ASSAULTButton;
var R6WindowListBoxAnchorButton m_ReconButton;
var R6WindowListBoxAnchorButton m_SNIPERButton;
var R6WindowListBoxAnchorButton m_DemolitionButton;
var R6WindowListBoxAnchorButton m_ElectronicButton;
var Texture m_TButtonTexture;
var R6WindowTextIconsListBox m_listBox;
var R6WindowTextIconsSubListBox m_RedListBox;
// NEW IN 1.60
var R6WindowTextIconsSubListBox m_GreenListBox;
// NEW IN 1.60
var R6WindowTextIconsSubListBox m_GoldListBox;
var Texture m_BorderTexture;
var Region m_RASSAULTUp;
// NEW IN 1.60
var Region m_RASSAULTOver;
// NEW IN 1.60
var Region m_RASSAULTDown;
// NEW IN 1.60
var Region m_RAssaultDisabled;
// NEW IN 1.60
var Region m_RReconUp;
// NEW IN 1.60
var Region m_RReconOver;
// NEW IN 1.60
var Region m_RReconDown;
// NEW IN 1.60
var Region m_RReconDisabled;
// NEW IN 1.60
var Region m_RSNIPERUp;
// NEW IN 1.60
var Region m_RSNIPEROver;
// NEW IN 1.60
var Region m_RSNIPERDown;
// NEW IN 1.60
var Region m_RSniperDisabled;
// NEW IN 1.60
var Region m_RDemolitionUp;
// NEW IN 1.60
var Region m_RDemolitionOver;
// NEW IN 1.60
var Region m_RDemolitionDown;
// NEW IN 1.60
var Region m_RDemolitionDisabled;
// NEW IN 1.60
var Region m_RElectronicUp;
// NEW IN 1.60
var Region m_RElectronicOver;
// NEW IN 1.60
var Region m_RElectronicDown;
// NEW IN 1.60
var Region m_RElectronicDisabled;
//Small icons in the list
var Region RAssault;
// NEW IN 1.60
var Region RRecon;
// NEW IN 1.60
var Region RSniper;
// NEW IN 1.60
var Region RDemo;
// NEW IN 1.60
var Region RElectro;
var Region RSAssault;
// NEW IN 1.60
var Region RSRecon;
// NEW IN 1.60
var Region RSSniper;
// NEW IN 1.60
var Region RSDemo;
// NEW IN 1.60
var Region RSElectro;
var Region m_BorderRegion;

function Created()
{
	m_BorderTexture = Texture(DynamicLoadObject("R6MenuTextures.Gui_BoxScroll", Class'Engine.Texture'));
	CreateAnchoredButtons();
	CreateRosterListBox();
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local int itemPos;
	local R6WindowListBoxItem SelectedItem, ListItem;
	local UWindowList UListItem;
	local R6MenuGearWidget gearWidget;
	local R6Operative selectedOperative;
	local R6WindowTextIconsSubListBox tmpSubListBox;

	gearWidget = R6MenuGearWidget(OwnerWindow);
	// End:0x1FF
	if((int(E) == 11))
	{
		switch(C)
		{
			// End:0x36
			case m_RedListBox.m_listBox:
			// End:0x47
			case m_GreenListBox.m_listBox:
			// End:0x153
			case m_GoldListBox.m_listBox:
				tmpSubListBox = R6WindowTextIconsSubListBox(C.OwnerWindow);
				SelectedItem = R6WindowListBoxItem(tmpSubListBox.m_listBox.m_SelectedItem);
				// End:0x150
				if((SelectedItem != none))
				{
					// End:0xCE
					if((SelectedItem.Next != none))
					{
						ListItem = R6WindowListBoxItem(SelectedItem.Next);						
					}
					else
					{
						// End:0x111
						if((SelectedItem.Prev != tmpSubListBox.m_listBox.Items))
						{
							ListItem = R6WindowListBoxItem(SelectedItem.Prev);
						}
					}
					RemoveOperativeInSubList(tmpSubListBox);
					// End:0x144
					if((ListItem != none))
					{
						tmpSubListBox.m_listBox.SetSelectedItem(ListItem);
					}
					RefreshButtons();
					ResizeSubLists();
				}
				// End:0x1FC
				break;
			// End:0x1F9
			case m_listBox:
				// End:0x19D
				if((m_RedListBox.m_listBox.Items.Count() < m_RedListBox.m_maxItemsCount))
				{
					AddOperativeToSubList(m_RedListBox);					
				}
				else
				{
					// End:0x1DF
					if((m_GreenListBox.m_listBox.Items.Count() < m_GreenListBox.m_maxItemsCount))
					{
						AddOperativeToSubList(m_GreenListBox);						
					}
					else
					{
						AddOperativeToSubList(m_GoldListBox);
					}
				}
				RefreshButtons();
				ResizeSubLists();
				// End:0x1FC
				break;
			// End:0xFFFF
			default:
				break;
		}		
	}
	else
	{
		// End:0x8F4
		if((int(E) == 2))
		{
			// End:0x243
			if(bShowLog)
			{
				Log("R6MenuDynTeamListsControl Notify DE_Click");
			}
			switch(C)
			{
				// End:0x252
				case m_ASSAULTButton:
				// End:0x25A
				case m_ReconButton:
				// End:0x262
				case m_SNIPERButton:
				// End:0x26A
				case m_DemolitionButton:
				// End:0x32B
				case m_ElectronicButton:
					itemPos = R6WindowListBoxItem(m_listBox.Items).FindItemIndex(R6WindowListBoxAnchorButton(C).AnchoredElement);
					// End:0x328
					if((itemPos >= 0))
					{
						m_listBox.m_VertSB.pos = 0.0000000;
						m_listBox.m_VertSB.Scroll(float(itemPos));
						m_listBox.SetSelectedItem(UWindowListBoxItem(R6WindowListBoxItem(m_listBox.Items).FindEntry((itemPos + 1))));
					}
					// End:0x8F4
					break;
				// End:0x3F0
				case m_RedListBox.m_listBox:
					selectedOperative = R6Operative(R6WindowListBoxItem(m_RedListBox.m_listBox.m_SelectedItem).m_Object);
					// End:0x3A8
					if(((gearWidget != none) && (selectedOperative != none)))
					{
						gearWidget.OperativeSelected(selectedOperative, 0, m_RedListBox.m_listBox);
					}
					m_GreenListBox.m_listBox.DropSelection();
					m_GoldListBox.m_listBox.DropSelection();
					m_listBox.DropSelection();
					RefreshButtons();
					// End:0x8F4
					break;
				// End:0x4B5
				case m_GreenListBox.m_listBox:
					selectedOperative = R6Operative(R6WindowListBoxItem(m_GreenListBox.m_listBox.m_SelectedItem).m_Object);
					// End:0x46D
					if(((gearWidget != none) && (selectedOperative != none)))
					{
						gearWidget.OperativeSelected(selectedOperative, 1, m_GreenListBox.m_listBox);
					}
					m_RedListBox.m_listBox.DropSelection();
					m_GoldListBox.m_listBox.DropSelection();
					m_listBox.DropSelection();
					RefreshButtons();
					// End:0x8F4
					break;
				// End:0x57A
				case m_GoldListBox.m_listBox:
					selectedOperative = R6Operative(R6WindowListBoxItem(m_GoldListBox.m_listBox.m_SelectedItem).m_Object);
					// End:0x532
					if(((gearWidget != none) && (selectedOperative != none)))
					{
						gearWidget.OperativeSelected(selectedOperative, 2, m_GoldListBox.m_listBox);
					}
					m_GreenListBox.m_listBox.DropSelection();
					m_RedListBox.m_listBox.DropSelection();
					m_listBox.DropSelection();
					RefreshButtons();
					// End:0x8F4
					break;
				// End:0x62D
				case m_listBox:
					selectedOperative = R6Operative(R6WindowListBoxItem(m_listBox.m_SelectedItem).m_Object);
					// End:0x5DC
					if(((gearWidget != none) && (selectedOperative != none)))
					{
						gearWidget.OperativeSelected(selectedOperative, 3, m_listBox);
					}
					m_RedListBox.m_listBox.DropSelection();
					m_GreenListBox.m_listBox.DropSelection();
					m_GoldListBox.m_listBox.DropSelection();
					RefreshButtons();
					// End:0x8F4
					break;
				// End:0x63E
				case m_RedListBox.m_AddButton:
				// End:0x64F
				case m_GreenListBox.m_AddButton:
				// End:0x688
				case m_GoldListBox.m_AddButton:
					AddOperativeToSubList(R6WindowTextIconsSubListBox(C.OwnerWindow));
					RefreshButtons();
					ResizeSubLists();
					// End:0x8F4
					break;
				// End:0x699
				case m_RedListBox.m_RemoveButton:
				// End:0x6AA
				case m_GreenListBox.m_RemoveButton:
				// End:0x7AB
				case m_GoldListBox.m_RemoveButton:
					tmpSubListBox = R6WindowTextIconsSubListBox(C.OwnerWindow);
					SelectedItem = R6WindowListBoxItem(tmpSubListBox.m_listBox.m_SelectedItem);
					// End:0x726
					if((SelectedItem.Next != none))
					{
						ListItem = R6WindowListBoxItem(SelectedItem.Next);						
					}
					else
					{
						// End:0x769
						if((SelectedItem.Prev != tmpSubListBox.m_listBox.Items))
						{
							ListItem = R6WindowListBoxItem(SelectedItem.Prev);
						}
					}
					RemoveOperativeInSubList(tmpSubListBox);
					// End:0x79C
					if((ListItem != none))
					{
						tmpSubListBox.m_listBox.SetSelectedItem(ListItem);
					}
					RefreshButtons();
					ResizeSubLists();
					// End:0x8F4
					break;
				// End:0x7BC
				case m_RedListBox.m_UpButton:
				// End:0x7CD
				case m_GreenListBox.m_UpButton:
				// End:0x84E
				case m_GoldListBox.m_UpButton:
					SelectedItem = R6WindowListBoxItem(R6WindowTextIconsSubListBox(C.OwnerWindow).m_listBox.m_SelectedItem);
					UListItem = SelectedItem.Prev;
					SelectedItem.Remove();
					UListItem.InsertItemBefore(SelectedItem);
					RefreshButtons();
					// End:0x8F4
					break;
				// End:0x85F
				case m_RedListBox.m_DownButton:
				// End:0x870
				case m_GreenListBox.m_DownButton:
				// End:0x8F1
				case m_GoldListBox.m_DownButton:
					SelectedItem = R6WindowListBoxItem(R6WindowTextIconsSubListBox(C.OwnerWindow).m_listBox.m_SelectedItem);
					UListItem = SelectedItem.Next;
					SelectedItem.Remove();
					UListItem.InsertItemAfter(SelectedItem);
					RefreshButtons();
					// End:0x8F4
					break;
				// End:0xFFFF
				default:
					break;
			}
		}
		else
		{
		}
		return;
	}
}

//Remove an Item from a SubList
function RemoveOperativeInSubList(R6WindowTextIconsSubListBox _SubListBox)
{
	local R6WindowListBoxItem SelectedItem;
	local R6Operative selectedOperative;
	local R6MenuGearWidget gearWidget;

	gearWidget = R6MenuGearWidget(OwnerWindow);
	SelectedItem = R6WindowListBoxItem(_SubListBox.m_listBox.m_SelectedItem);
	// End:0xE0
	if(((SelectedItem != none) && (SelectedItem.m_ParentListItem != none)))
	{
		_SubListBox.m_listBox.DropSelection();
		SelectedItem.m_ParentListItem.m_addedToSubList = false;
		SelectedItem.Remove();
		m_listBox.SetSelectedItem(SelectedItem.m_ParentListItem);
		selectedOperative = R6Operative(SelectedItem.m_Object);
		gearWidget.OperativeSelected(selectedOperative, 3);
	}
	return;
}

//Adding an item to a sub list
function AddOperativeToSubList(R6WindowTextIconsSubListBox _SubListBox)
{
	local int totalCount;
	local R6WindowListBoxItem TempItem, SelectedItem;
	local R6Operative selectedOperative;
	local R6MenuGearWidget gearWidget;
	local bool bFound;

	gearWidget = R6MenuGearWidget(OwnerWindow);
	// End:0x37
	if((int(gearWidget.m_currentOperativeTeam) == int(0)))
	{
		RemoveOperativeInSubList(m_RedListBox);		
	}
	else
	{
		// End:0x5E
		if((int(gearWidget.m_currentOperativeTeam) == int(1)))
		{
			RemoveOperativeInSubList(m_GreenListBox);			
		}
		else
		{
			// End:0x82
			if((int(gearWidget.m_currentOperativeTeam) == int(2)))
			{
				RemoveOperativeInSubList(m_GoldListBox);
			}
		}
	}
	totalCount = ((m_RedListBox.m_listBox.Items.Count() + m_GreenListBox.m_listBox.Items.Count()) + m_GoldListBox.m_listBox.Items.Count());
	// End:0x245
	if(bShowLog)
	{
		Log(("m_RedListBox count :" @ string(m_RedListBox.m_listBox.Items.Count())));
		Log(("m_GreenListBox count :" @ string(m_GreenListBox.m_listBox.Items.Count())));
		Log(("m_GoldListBox count :" @ string(m_GoldListBox.m_listBox.Items.Count())));
		// End:0x1E2
		if((_SubListBox == m_RedListBox))
		{
			Log("m_RedListBox Adding operative");
		}
		// End:0x214
		if((_SubListBox == m_GreenListBox))
		{
			Log("m_GreenListBox Adding operative");
		}
		// End:0x245
		if((_SubListBox == m_GoldListBox))
		{
			Log("m_GoldListBox Adding Operative");
		}
	}
	SelectedItem = R6WindowListBoxItem(m_listBox.m_SelectedItem);
	// End:0x467
	if(((((totalCount < m_iMaxOperativeCount) && (SelectedItem != none)) && (SelectedItem.m_addedToSubList == false)) && (_SubListBox.m_listBox.Items.Count() < _SubListBox.m_maxItemsCount)))
	{
		TempItem = R6WindowListBoxItem(_SubListBox.m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
		// End:0x464
		if((TempItem != none))
		{
			TempItem.m_Icon = SelectedItem.m_Icon;
			TempItem.m_IconRegion = SelectedItem.m_IconRegion;
			TempItem.m_IconSelectedRegion = SelectedItem.m_IconSelectedRegion;
			TempItem.HelpText = SelectedItem.HelpText;
			TempItem.m_ParentListItem = SelectedItem;
			TempItem.m_Object = SelectedItem.m_Object;
			SelectedItem.m_addedToSubList = true;
			m_listBox.DropSelection();
			_SubListBox.m_listBox.SetSelectedItem(TempItem);
			selectedOperative = R6Operative(SelectedItem.m_Object);
			// End:0x426
			if((_SubListBox == m_RedListBox))
			{
				gearWidget.OperativeSelected(selectedOperative, 0);				
			}
			else
			{
				// End:0x44E
				if((_SubListBox == m_GreenListBox))
				{
					gearWidget.OperativeSelected(selectedOperative, 1);					
				}
				else
				{
					gearWidget.OperativeSelected(selectedOperative, 2);
				}
			}
		}		
	}
	else
	{
		// End:0x487
		if(bShowLog)
		{
			Log(((string(totalCount) @ "<") @ string(m_iMaxOperativeCount)));
		}
	}
	TempItem = SelectedItem;
	J0x492:

	// End:0x521 [Loop If]
	if(((TempItem != none) && (bFound == false)))
	{
		// End:0x505
		if(((TempItem.m_IsSeparator == false) && (TempItem.m_addedToSubList == false)))
		{
			m_listBox.SetSelectedItem(TempItem);
			m_listBox.MakeSelectedVisible();
			bFound = true;			
		}
		else
		{
			TempItem = R6WindowListBoxItem(TempItem.Next);
		}
		// [Loop Continue]
		goto J0x492;
	}
	return;
}

function RefreshButtons()
{
	local int iShowAdd, totalCount;
	local R6WindowListBoxItem SelectedItem;
	local R6MenuGearWidget gearWidget;

	gearWidget = R6MenuGearWidget(OwnerWindow);
	totalCount = ((m_RedListBox.m_listBox.Items.Count() + m_GreenListBox.m_listBox.Items.Count()) + m_GoldListBox.m_listBox.Items.Count());
	switch(gearWidget.m_currentOperativeTeam)
	{
		// End:0xF1
		case 3:
			// End:0xAB
			if((totalCount < m_iMaxOperativeCount))
			{
				iShowAdd = 1;				
			}
			else
			{
				iShowAdd = 0;
			}
			m_RedListBox.UpdateButtons(iShowAdd);
			m_GreenListBox.UpdateButtons(iShowAdd);
			m_GoldListBox.UpdateButtons(iShowAdd);
			// End:0x19C
			break;
		// End:0x129
		case 0:
			m_RedListBox.UpdateButtons(0);
			m_GreenListBox.UpdateButtons(1);
			m_GoldListBox.UpdateButtons(1);
			// End:0x19C
			break;
		// End:0x161
		case 1:
			m_RedListBox.UpdateButtons(1);
			m_GreenListBox.UpdateButtons(0);
			m_GoldListBox.UpdateButtons(1);
			// End:0x19C
			break;
		// End:0x199
		case 2:
			m_RedListBox.UpdateButtons(1);
			m_GreenListBox.UpdateButtons(1);
			m_GoldListBox.UpdateButtons(0);
			// End:0x19C
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function CreateRosterListBox()
{
	local Color co;
	local Font listBoxTitleFont;

	listBoxTitleFont = Root.Fonts[11];
	m_listBox = R6WindowTextIconsListBox(CreateControl(Class'R6Window.R6WindowTextIconsListBox', 0.0000000, (m_ElectronicButton.WinTop + m_ElectronicButton.WinHeight), WinWidth, 143.0000000, self));
	m_listBox.ToolTipString = Localize("Tip", "GearRoomOpListBox", "R6Menu");
	m_listBox.m_SeparatorTextColor = Root.Colors.BlueLight;
	m_listBox.m_BorderColor = Root.Colors.GrayLight;
	m_listBox.m_IgnoreAllreadySelected = false;
	m_listBox.m_VertSB.SetEffect(true);
	m_RedListBox = R6WindowTextIconsSubListBox(CreateControl(Class'R6Window.R6WindowTextIconsSubListBox', 0.0000000, ((m_listBox.WinTop + m_listBox.WinHeight) + m_fVPadding), WinWidth, 47.0000000, self));
	m_GreenListBox = R6WindowTextIconsSubListBox(CreateControl(Class'R6Window.R6WindowTextIconsSubListBox', 0.0000000, ((m_RedListBox.WinTop + m_RedListBox.WinHeight) + m_fVPadding), WinWidth, 47.0000000, self));
	m_GoldListBox = R6WindowTextIconsSubListBox(CreateControl(Class'R6Window.R6WindowTextIconsSubListBox', 0.0000000, ((m_GreenListBox.WinTop + m_GreenListBox.WinHeight) + m_fVPadding), WinWidth, 73.0000000, self));
	m_RedListBox.m_listBox.SetScrollable(false);
	m_GreenListBox.m_listBox.SetScrollable(false);
	m_GoldListBox.m_listBox.SetScrollable(false);
	m_RedListBox.SetColor(Root.Colors.TeamColor[0]);
	m_GreenListBox.SetColor(Root.Colors.TeamColor[1]);
	m_GoldListBox.SetColor(Root.Colors.TeamColor[2]);
	co = Root.Colors.White;
	m_RedListBox.m_Title.Align = 2;
	m_RedListBox.m_Title.m_Font = listBoxTitleFont;
	m_RedListBox.m_Title.TextColor = co;
	m_RedListBox.m_Title.SetNewText(Localize("GearRoom", "team1", "R6Menu"), true);
	m_GreenListBox.m_Title.Align = 2;
	m_GreenListBox.m_Title.m_Font = listBoxTitleFont;
	m_GreenListBox.m_Title.TextColor = co;
	m_GreenListBox.m_Title.SetNewText(Localize("GearRoom", "team2", "R6Menu"), true);
	m_GoldListBox.m_Title.Align = 2;
	m_GoldListBox.m_Title.m_Font = listBoxTitleFont;
	m_GoldListBox.m_Title.TextColor = co;
	m_GoldListBox.m_Title.SetNewText(Localize("GearRoom", "team3", "R6Menu"), true);
	m_RedListBox.SetTip(Localize("Tip", "GearRoomRedListBox", "R6Menu"));
	m_GreenListBox.SetTip(Localize("Tip", "GearRoomGreenListBox", "R6Menu"));
	m_GoldListBox.SetTip(Localize("Tip", "GearRoomGoldListBox", "R6Menu"));
	return;
}

function CreateAnchoredButtons()
{
	m_ASSAULTButton = R6WindowListBoxAnchorButton(CreateControl(Class'R6Window.R6WindowListBoxAnchorButton', m_fFirsButtonOffset, m_fHButtonOffset, m_fButtonTabWidth, m_fButtonTabHeight));
	m_ASSAULTButton.ToolTipString = Localize("Tip", "GearRoomButAssault", "R6Menu");
	m_ASSAULTButton.UpRegion = m_RASSAULTUp;
	m_ASSAULTButton.OverRegion = m_RASSAULTOver;
	m_ASSAULTButton.DownRegion = m_RASSAULTDown;
	m_ASSAULTButton.DisabledRegion = m_RAssaultDisabled;
	m_ASSAULTButton.m_iDrawStyle = 5;
	m_ReconButton = R6WindowListBoxAnchorButton(CreateControl(Class'R6Window.R6WindowListBoxAnchorButton', ((m_ASSAULTButton.WinLeft + m_ASSAULTButton.WinWidth) + m_fHButtonPadding), m_ASSAULTButton.WinTop, m_ASSAULTButton.WinWidth, m_ASSAULTButton.WinHeight));
	m_ReconButton.ToolTipString = Localize("Tip", "GearRoomButRecon", "R6Menu");
	m_ReconButton.UpRegion = m_RReconUp;
	m_ReconButton.OverRegion = m_RReconOver;
	m_ReconButton.DownRegion = m_RReconDown;
	m_ReconButton.DisabledRegion = m_RReconDisabled;
	m_ReconButton.m_iDrawStyle = 5;
	m_SNIPERButton = R6WindowListBoxAnchorButton(CreateControl(Class'R6Window.R6WindowListBoxAnchorButton', ((m_ReconButton.WinLeft + m_ReconButton.WinWidth) + m_fHButtonPadding), m_ASSAULTButton.WinTop, m_ASSAULTButton.WinWidth, m_ASSAULTButton.WinHeight));
	m_SNIPERButton.ToolTipString = Localize("Tip", "GearRoomButSniper", "R6Menu");
	m_SNIPERButton.UpRegion = m_RSNIPERUp;
	m_SNIPERButton.OverRegion = m_RSNIPEROver;
	m_SNIPERButton.DownRegion = m_RSNIPERDown;
	m_SNIPERButton.DisabledRegion = m_RSniperDisabled;
	m_SNIPERButton.m_iDrawStyle = 5;
	m_DemolitionButton = R6WindowListBoxAnchorButton(CreateControl(Class'R6Window.R6WindowListBoxAnchorButton', ((m_SNIPERButton.WinLeft + m_SNIPERButton.WinWidth) + m_fHButtonPadding), m_ASSAULTButton.WinTop, m_ASSAULTButton.WinWidth, m_ASSAULTButton.WinHeight));
	m_DemolitionButton.ToolTipString = Localize("Tip", "GearRoomButDemol", "R6Menu");
	m_DemolitionButton.UpRegion = m_RDemolitionUp;
	m_DemolitionButton.OverRegion = m_RDemolitionOver;
	m_DemolitionButton.DownRegion = m_RDemolitionDown;
	m_DemolitionButton.DisabledRegion = m_RDemolitionDisabled;
	m_DemolitionButton.m_iDrawStyle = 5;
	m_ElectronicButton = R6WindowListBoxAnchorButton(CreateControl(Class'R6Window.R6WindowListBoxAnchorButton', ((m_DemolitionButton.WinLeft + m_DemolitionButton.WinWidth) + m_fHButtonPadding), m_ASSAULTButton.WinTop, m_ASSAULTButton.WinWidth, m_ASSAULTButton.WinHeight));
	m_ElectronicButton.ToolTipString = Localize("Tip", "GearRoomButElec", "R6Menu");
	m_ElectronicButton.UpRegion = m_RElectronicUp;
	m_ElectronicButton.OverRegion = m_RElectronicOver;
	m_ElectronicButton.DownRegion = m_RElectronicDown;
	m_ElectronicButton.DisabledRegion = m_RElectronicDisabled;
	m_ElectronicButton.m_iDrawStyle = 5;
	return;
}

function FillRosterList()
{
	local R6WindowListBoxItem TempItem;
	local Texture ButtonTexture;
	local Region R, RS;
	local int i, SeparatorID, iUniqueID;
	local R6MenuRootWindow r6Root;
	local R6Operative tmpOperative;
	local R6MenuGearWidget gearWidget;
	local bool Found;

	ButtonTexture = Texture(DynamicLoadObject("R6MenuTextures.Tab_Icon00", Class'Engine.Texture'));
	r6Root = R6MenuRootWindow(Root);
	gearWidget = R6MenuGearWidget(OwnerWindow);
	m_iMaxOperativeCount = R6GameInfo(GetLevel().Game).m_iMaxOperatives;
	EmptyRosterList();
	TempItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	TempItem.HelpText = Localize("GearRoom", "ButtonAssault", "R6Menu");
	TempItem.m_IsSeparator = true;
	TempItem.m_iSeparatorID = 1;
	m_ASSAULTButton.AnchoredElement = TempItem;
	TempItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	TempItem.HelpText = Localize("GearRoom", "ButtonSniper", "R6Menu");
	TempItem.m_IsSeparator = true;
	TempItem.m_iSeparatorID = 2;
	m_SNIPERButton.AnchoredElement = TempItem;
	TempItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	TempItem.HelpText = Localize("GearRoom", "ButtonDemolition", "R6Menu");
	TempItem.m_IsSeparator = true;
	TempItem.m_iSeparatorID = 3;
	m_DemolitionButton.AnchoredElement = TempItem;
	TempItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	TempItem.HelpText = Localize("GearRoom", "ButtonElectronic", "R6Menu");
	TempItem.m_IsSeparator = true;
	TempItem.m_iSeparatorID = 4;
	m_ElectronicButton.AnchoredElement = TempItem;
	TempItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	TempItem.HelpText = Localize("GearRoom", "ButtonRecon", "R6Menu");
	TempItem.m_IsSeparator = true;
	TempItem.m_iSeparatorID = 5;
	m_ReconButton.AnchoredElement = TempItem;
	// End:0x404
	if(bShowLog)
	{
		Log("R6MenuDynTeamListsControl:FillRosterListBox");
		Log(("m_ListBox.Items.Count()" @ string(m_listBox.Items.Count())));
		Log(("R6Root.m_GameOperatives.Length" @ string(r6Root.m_GameOperatives.Length)));
	}
	iUniqueID = -1;
	i = 0;
	J0x416:

	// End:0x6D4 [Loop If]
	if((i < r6Root.m_GameOperatives.Length))
	{
		tmpOperative = r6Root.m_GameOperatives[i];
		// End:0x46B
		if(bShowLog)
		{
			Log(("tmpOperative" @ string(tmpOperative)));
		}
		// End:0x6CA
		if((tmpOperative != none))
		{
			(iUniqueID += 1);
			// End:0x4AA
			if((tmpOperative.m_iUniqueID == -1))
			{
				tmpOperative.m_iUniqueID = iUniqueID;
			}
			// End:0x4E9
			if((tmpOperative.m_szSpecialityID == "ID_ASSAULT"))
			{
				R = RAssault;
				RS = RSAssault;
				SeparatorID = 1;				
			}
			else
			{
				// End:0x528
				if((tmpOperative.m_szSpecialityID == "ID_SNIPER"))
				{
					R = RSniper;
					RS = RSSniper;
					SeparatorID = 2;					
				}
				else
				{
					// End:0x56C
					if((tmpOperative.m_szSpecialityID == "ID_DEMOLITIONS"))
					{
						R = RDemo;
						RS = RSDemo;
						SeparatorID = 3;						
					}
					else
					{
						// End:0x5B0
						if((tmpOperative.m_szSpecialityID == "ID_ELECTRONICS"))
						{
							R = RElectro;
							RS = RSElectro;
							SeparatorID = 4;							
						}
						else
						{
							// End:0x5EB
							if((tmpOperative.m_szSpecialityID == "ID_RECON"))
							{
								R = RRecon;
								RS = RSRecon;
								SeparatorID = 5;
							}
						}
					}
				}
			}
			TempItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', SeparatorID);
			// End:0x6CA
			if((TempItem != none))
			{
				TempItem.m_Icon = ButtonTexture;
				TempItem.m_IconRegion = R;
				TempItem.m_IconSelectedRegion = RS;
				TempItem.HelpText = tmpOperative.GetName();
				// End:0x6A2
				if((tmpOperative.m_iHealth > 1))
				{
					TempItem.m_addedToSubList = true;
				}
				TempItem.m_Object = tmpOperative;
				gearWidget.SetupOperative(tmpOperative);
			}
		}
		(i++);
		// [Loop Continue]
		goto J0x416;
	}
	TempItem = R6WindowListBoxItem(m_listBox.Items.Next);
	J0x6F6:

	// End:0x76E [Loop If]
	if(((TempItem != none) && (Found == false)))
	{
		// End:0x752
		if((TempItem.m_IsSeparator == false))
		{
			m_listBox.SetSelectedItem(TempItem);
			m_listBox.MakeSelectedVisible();
			Found = true;			
		}
		else
		{
			TempItem = R6WindowListBoxItem(TempItem.Next);
		}
		// [Loop Continue]
		goto J0x6F6;
	}
	return;
}

function EmptyRosterList()
{
	m_listBox.Items.Clear();
	m_RedListBox.m_listBox.Items.Clear();
	m_GreenListBox.m_listBox.Items.Clear();
	m_GoldListBox.m_listBox.Items.Clear();
	return;
}

function Paint(Canvas C, float X, float Y)
{
	R6WindowLookAndFeel(LookAndFeel).DrawBGShading(self, C, m_listBox.WinLeft, m_listBox.WinTop, m_listBox.WinWidth, m_listBox.WinHeight);
	C.Style = 5;
	C.SetDrawColor(Root.Colors.GrayLight.R, Root.Colors.GrayLight.G, Root.Colors.GrayLight.B);
	DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, float(m_BorderRegion.H), float(m_BorderRegion.X), float(m_BorderRegion.Y), float(m_BorderRegion.W), float(m_BorderRegion.H), m_BorderTexture);
	DrawStretchedTextureSegment(C, 0.0000000, (m_ASSAULTButton.WinHeight + m_ASSAULTButton.WinTop), WinWidth, float(m_BorderRegion.H), float(m_BorderRegion.X), float(m_BorderRegion.Y), float(m_BorderRegion.W), float(m_BorderRegion.H), m_BorderTexture);
	DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, float(m_BorderRegion.W), (m_ASSAULTButton.WinHeight + m_fHButtonOffset), float(m_BorderRegion.X), float(m_BorderRegion.Y), float(m_BorderRegion.W), float(m_BorderRegion.H), m_BorderTexture);
	DrawStretchedTextureSegment(C, (WinWidth - float(m_BorderRegion.W)), 0.0000000, float(m_BorderRegion.W), (m_ASSAULTButton.WinHeight + m_fHButtonOffset), float(m_BorderRegion.X), float(m_BorderRegion.Y), float(m_BorderRegion.W), float(m_BorderRegion.H), m_BorderTexture);
	return;
}

function ResizeSubLists()
{
	local int iRedListBoxH, iGreenListBoxH, iGoldListBoxH, iAddSpace, iMaxListHeigth, iAvailableSpace;

	iMaxListHeigth = (int((float(4) * m_SubListByItemHeight)) + m_SubListTopHeight);
	iRedListBoxH = (int((float(m_RedListBox.m_listBox.Items.Count()) * m_SubListByItemHeight)) + m_SubListTopHeight);
	iGreenListBoxH = (int((float(m_GreenListBox.m_listBox.Items.Count()) * m_SubListByItemHeight)) + m_SubListTopHeight);
	iGoldListBoxH = (int((float(m_GoldListBox.m_listBox.Items.Count()) * m_SubListByItemHeight)) + m_SubListTopHeight);
	iAvailableSpace = int((TotalSublistsHeight - float(Min(((iRedListBoxH + iGreenListBoxH) + iGoldListBoxH), int(TotalSublistsHeight)))));
	J0xF2:

	// End:0x1EA [Loop If]
	if((iAvailableSpace != 0))
	{
		iAddSpace = (iAvailableSpace / 3);
		iAvailableSpace = (iAvailableSpace - (3 * iAddSpace));
		// End:0x193
		if((iAddSpace == 0))
		{
			iAddSpace = iAvailableSpace;
			iAvailableSpace = 0;
			iAddSpace = DistributeSpaces(iAddSpace, iRedListBoxH, iMaxListHeigth);
			iAddSpace = DistributeSpaces(iAddSpace, iGreenListBoxH, iMaxListHeigth);
			iAddSpace = DistributeSpaces(iAddSpace, iGoldListBoxH, iMaxListHeigth);			
		}
		else
		{
			(iAvailableSpace += DistributeSpaces(iAddSpace, iRedListBoxH, iMaxListHeigth));
			(iAvailableSpace += DistributeSpaces(iAddSpace, iGreenListBoxH, iMaxListHeigth));
			(iAvailableSpace += DistributeSpaces(iAddSpace, iGoldListBoxH, iMaxListHeigth));
		}
		// [Loop Continue]
		goto J0xF2;
	}
	m_RedListBox.SetSize(m_RedListBox.WinWidth, float(iRedListBoxH));
	m_GreenListBox.WinTop = ((m_RedListBox.WinTop + m_RedListBox.WinHeight) + m_fVPadding);
	m_GreenListBox.SetSize(m_GreenListBox.WinWidth, float(iGreenListBoxH));
	m_GoldListBox.WinTop = ((m_GreenListBox.WinTop + m_GreenListBox.WinHeight) + m_fVPadding);
	m_GoldListBox.SetSize(m_GoldListBox.WinWidth, float(iGoldListBoxH));
	// End:0x439
	if(bShowLog)
	{
		Log("//////////////////////////////////////////////////////");
		Log("// R6MenuDynTeamListsControl.ResizeSubLists()");
		Log(("//m_RedListBox.WinHeight" @ string(m_RedListBox.WinHeight)));
		Log(("//m_GoldListBox.WinHeight" @ string(m_GoldListBox.WinHeight)));
		Log(("//m_GreenListBox.WinHeight" @ string(m_GreenListBox.WinHeight)));
		Log(("//yo " @ string(((((WinHeight - TotalSublistsHeight) - m_ASSAULTButton.WinHeight) + m_fHButtonOffset) - m_listBox.WinHeight))));
		Log("//////////////////////////////////////////////////////");
	}
	return;
}

function int DistributeSpaces(int _iSpaceToAdd, out int _iHList, int _iMaxListHeigth)
{
	local int iSpaceLeft;

	// End:0x3D
	if(((_iHList + _iSpaceToAdd) > _iMaxListHeigth))
	{
		iSpaceLeft = (_iSpaceToAdd - (_iMaxListHeigth - _iHList));
		_iHList = _iMaxListHeigth;		
	}
	else
	{
		(_iHList += _iSpaceToAdd);
	}
	return iSpaceLeft;
	return;
}

defaultproperties
{
	m_SubListTopHeight=20
	m_iMaxOperativeCount=8
	m_fButtonTabWidth=37.0000000
	m_fButtonTabHeight=20.0000000
	m_MinSubListHeight=47.0000000
	m_SubListByItemHeight=13.0000000
	TotalSublistsHeight=167.0000000
	m_fVPadding=2.0000000
	m_fFirsButtonOffset=3.0000000
	m_fHButtonPadding=2.0000000
	m_fHButtonOffset=3.0000000
	m_RASSAULTUp=(Zone=Class'R6Menu.R6MenuRootWindow',iLeaf=9506,ZoneNumber=0)
	m_RASSAULTOver=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=5410,ZoneNumber=0)
	m_RASSAULTDown=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=10786,ZoneNumber=0)
	m_RAssaultDisabled=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=10786,ZoneNumber=0)
	m_RReconUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29218,ZoneNumber=0)
	m_RReconOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29218,ZoneNumber=0)
	m_RReconDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29218,ZoneNumber=0)
	m_RReconDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29218,ZoneNumber=0)
	m_RSNIPERUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=38946,ZoneNumber=0)
	m_RSNIPEROver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=38946,ZoneNumber=0)
	m_RSNIPERDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=38946,ZoneNumber=0)
	m_RSniperDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=38946,ZoneNumber=0)
	m_RDemolitionUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=9762,ZoneNumber=0)
	m_RDemolitionOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=9762,ZoneNumber=0)
	m_RDemolitionDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=9762,ZoneNumber=0)
	m_RDemolitionDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=9762,ZoneNumber=0)
	m_RElectronicUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19490,ZoneNumber=0)
	m_RElectronicOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19490,ZoneNumber=0)
	m_RElectronicDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19490,ZoneNumber=0)
	m_RElectronicDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19490,ZoneNumber=0)
	RAssault=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=58658,ZoneNumber=0)
	RRecon=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=61218,ZoneNumber=0)
	RSniper=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=58658,ZoneNumber=0)
	RDemo=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=61218,ZoneNumber=0)
	RElectro=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=58658,ZoneNumber=0)
	RSAssault=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=58658,ZoneNumber=0)
	RSRecon=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=61218,ZoneNumber=0)
	RSSniper=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=58658,ZoneNumber=0)
	RSDemo=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=61218,ZoneNumber=0)
	RSElectro=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=58658,ZoneNumber=0)
	m_BorderRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=16418,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var r
// REMOVED IN 1.60: var o
// REMOVED IN 1.60: var x
// REMOVED IN 1.60: var g
