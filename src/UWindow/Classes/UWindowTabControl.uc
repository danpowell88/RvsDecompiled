//=============================================================================
// UWindowTabControl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowTabControl extends UWindowListControl;

var bool bMultiLine;
var bool bSelectNearestTabOnRemove;
var bool m_bTabButton;  // tab button or not
var UWindowTabControlLeftButton LeftButton;
var UWindowTabControlRightButton RightButton;
var UWindowTabControlTabArea TabArea;
var UWindowTabControlItem SelectedTab;

function Created()
{
	super.Created();
	SelectedTab = none;
	TabArea = UWindowTabControlTabArea(CreateWindow(Class'UWindow.UWindowTabControlTabArea', 0.0000000, 0.0000000, WinWidth, __NFUN_174__(LookAndFeel.Size_TabAreaHeight, LookAndFeel.Size_TabAreaOverhangHeight)));
	TabArea.bAlwaysOnTop = true;
	// End:0xCA
	if(m_bTabButton)
	{
		LeftButton = UWindowTabControlLeftButton(CreateWindow(Class'UWindow.UWindowTabControlLeftButton', __NFUN_175__(WinWidth, float(20)), 0.0000000, 10.0000000, 12.0000000));
		RightButton = UWindowTabControlRightButton(CreateWindow(Class'UWindow.UWindowTabControlRightButton', __NFUN_175__(WinWidth, float(10)), 0.0000000, 10.0000000, 12.0000000));
	}
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	TabArea.WinTop = 0.0000000;
	TabArea.WinLeft = 0.0000000;
	// End:0x45
	if(bMultiLine)
	{
		TabArea.WinWidth = WinWidth;
	}
	TabArea.LayoutTabs(C);
	WinHeight = __NFUN_174__(__NFUN_171__(LookAndFeel.Size_TabAreaHeight, float(TabArea.TabRows)), LookAndFeel.Size_TabAreaOverhangHeight);
	TabArea.WinHeight = WinHeight;
	super(UWindowDialogControl).BeforePaint(C, X, Y);
	return;
}

function SetMultiLine(bool InMultiLine)
{
	bMultiLine = InMultiLine;
	// End:0x37
	if(bMultiLine)
	{
		LeftButton.HideWindow();
		RightButton.HideWindow();		
	}
	else
	{
		LeftButton.ShowWindow();
		RightButton.ShowWindow();
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local Region R;
	local Texture t;

	// End:0x9A
	if(__NFUN_129__(m_bNotDisplayBkg))
	{
		t = GetLookAndFeelTexture();
		R = LookAndFeel.TabBackground;
		DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, __NFUN_171__(LookAndFeel.Size_TabAreaHeight, float(TabArea.TabRows)), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	}
	return;
}

function UWindowTabControlItem AddTab(string Caption, optional int _iItemID)
{
	local UWindowTabControlItem i;

	i = UWindowTabControlItem(Items.Append(ListClass));
	i.Owner = self;
	i.SetCaption(Caption);
	i.m_iItemID = _iItemID;
	// End:0x6D
	if(__NFUN_114__(SelectedTab, none))
	{
		SelectedTab = i;
	}
	return i;
	return;
}

function UWindowTabControlItem InsertTab(UWindowTabControlItem BeforeTab, string Caption, optional int _iItemID)
{
	local UWindowTabControlItem i;

	i = UWindowTabControlItem(BeforeTab.InsertBefore(ListClass));
	i.Owner = self;
	i.SetCaption(Caption);
	i.m_iItemID = _iItemID;
	// End:0x6D
	if(__NFUN_114__(SelectedTab, none))
	{
		SelectedTab = i;
	}
	return i;
	return;
}

function GotoTab(UWindowTabControlItem NewSelected, optional bool bByUser)
{
	// End:0x2C
	if(__NFUN_130__(__NFUN_119__(SelectedTab, NewSelected), bByUser))
	{
		LookAndFeel.PlayMenuSound(self, 5);
	}
	SelectedTab = NewSelected;
	TabArea.bShowSelected = true;
	return;
}

function UWindowTabControlItem GetTab(string Caption)
{
	local UWindowTabControlItem i;

	i = UWindowTabControlItem(Items.Next);
	J0x19:

	// End:0x5E [Loop If]
	if(__NFUN_119__(i, none))
	{
		// End:0x42
		if(__NFUN_122__(i.Caption, Caption))
		{
			return i;
		}
		i = UWindowTabControlItem(i.Next);
		// [Loop Continue]
		goto J0x19;
	}
	return none;
	return;
}

function DeleteTab(UWindowTabControlItem Tab)
{
	local UWindowTabControlItem NextTab, PrevTab;

	NextTab = UWindowTabControlItem(Tab.Next);
	PrevTab = UWindowTabControlItem(Tab.Prev);
	Tab.Remove();
	// End:0xA1
	if(__NFUN_114__(SelectedTab, Tab))
	{
		// End:0x88
		if(bSelectNearestTabOnRemove)
		{
			Tab = NextTab;
			// End:0x7A
			if(__NFUN_114__(Tab, none))
			{
				Tab = PrevTab;
			}
			GotoTab(Tab);			
		}
		else
		{
			GotoTab(UWindowTabControlItem(Items.Next));
		}
	}
	return;
}

defaultproperties
{
	ListClass=Class'UWindow.UWindowTabControlItem'
}
