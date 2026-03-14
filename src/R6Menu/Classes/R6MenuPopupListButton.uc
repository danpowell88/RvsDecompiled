//=============================================================================
// R6MenuPopupListButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6MenuPopupListButton extends R6WindowListRadioButton;

var const int m_iNbButton;
var bool bInitialized;
var R6WindowListButtonItem m_ButtonItem[10];
var Texture m_SeperatorLineTexture;
var Font m_FontForButtons;
var Region m_SeperatorLineRegion;

//Call once
function BeforePaint(Canvas C, float MouseX, float MouseY)
{
	local int i, iCurrentNbButton;
	local float fWidth, fHeight, fMaxWidth, fMaxHeight;
	local bool bNeedRisize;

	// End:0x20D
	if(__NFUN_242__(bInitialized, false))
	{
		bInitialized = true;
		C.Font = Root.Fonts[0];
		i = 0;
		J0x3A:

		// End:0x11B [Loop If]
		if(__NFUN_150__(i, m_iNbButton))
		{
			// End:0x111
			if(__NFUN_130__(__NFUN_119__(m_ButtonItem[i], none), __NFUN_119__(m_ButtonItem[i].m_Button, none)))
			{
				TextSize(C, m_ButtonItem[i].m_Button.Text, fWidth, fHeight);
				// End:0xDD
				if(__NFUN_242__(R6MenuPopUpStayDownButton(m_ButtonItem[i].m_Button).m_bSubMenu, true))
				{
					__NFUN_184__(fWidth, float(6));
				}
				// End:0xF7
				if(__NFUN_177__(fWidth, fMaxWidth))
				{
					fMaxWidth = fWidth;
				}
				// End:0x111
				if(__NFUN_177__(fHeight, fMaxHeight))
				{
					fMaxHeight = fHeight;
				}
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x3A;
		}
		WinWidth = __NFUN_174__(fMaxWidth, float(12));
		m_fItemHeight = __NFUN_174__(fMaxHeight, float(6));
		iCurrentNbButton = 0;
		i = 0;
		J0x14B:

		// End:0x1DE [Loop If]
		if(__NFUN_150__(i, m_iNbButton))
		{
			// End:0x1D4
			if(__NFUN_130__(__NFUN_119__(m_ButtonItem[i], none), __NFUN_119__(m_ButtonItem[i].m_Button, none)))
			{
				m_ButtonItem[i].m_Button.WinWidth = WinWidth;
				m_ButtonItem[i].m_Button.WinHeight = m_fItemHeight;
				__NFUN_165__(iCurrentNbButton);
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x14B;
		}
		WinHeight = __NFUN_174__(__NFUN_171__(m_fItemHeight, float(iCurrentNbButton)), float(__NFUN_147__(iCurrentNbButton, 1)));
		ParentWindow.Resized();
	}
	return;
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	local float X, Y;
	local UWindowList CurItem;
	local Color lcolor;

	lcolor = Root.Colors.TeamColor[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam];
	C.__NFUN_2626__(lcolor.R, lcolor.G, lcolor.B, byte(Root.Colors.PopUpAlphaFactor));
	// End:0x8D
	if(__NFUN_180__(m_fItemWidth, float(0)))
	{
		m_fItemWidth = WinWidth;
	}
	X = __NFUN_172__(__NFUN_175__(WinWidth, m_fItemWidth), float(2));
	CurItem = Items.Next;
	J0xB9:

	// End:0x208 [Loop If]
	if(__NFUN_119__(CurItem, none))
	{
		R6WindowListButtonItem(CurItem).m_Button.ShowWindow();
		DrawItem(C, CurItem, X, Y, m_fItemWidth, m_fItemHeight);
		__NFUN_184__(Y, m_fItemHeight);
		// End:0x1CB
		if(__NFUN_176__(Y, WinHeight))
		{
			C.Style = GetPlayerOwner().5;
			DrawStretchedTextureSegment(C, X, Y, float(m_SeperatorLineRegion.W), float(m_SeperatorLineRegion.H), float(m_SeperatorLineRegion.X), float(m_SeperatorLineRegion.Y), float(m_SeperatorLineRegion.W), float(m_SeperatorLineRegion.H), m_SeperatorLineTexture);
			C.Style = GetPlayerOwner().1;
			__NFUN_184__(Y, float(m_SeperatorLineRegion.H));
		}
		// End:0x1F1
		if(__NFUN_179__(Y, WinHeight))
		{
			Y = 0.0000000;
			__NFUN_184__(X, WinWidth);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0xB9;
	}
	C.__NFUN_2626__(byte(255), byte(255), byte(255));
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local R6WindowListButtonItem pListButtonItem;

	pListButtonItem = R6WindowListButtonItem(Item);
	// End:0x7B
	if(__NFUN_119__(pListButtonItem.m_Button, none))
	{
		pListButtonItem.m_Button.WinLeft = X;
		pListButtonItem.m_Button.WinTop = Y;
		pListButtonItem.m_Button.WinHeight = H;
	}
	return;
}

function ChangeItemsSize(float fNewWidth)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x70 [Loop If]
	if(__NFUN_150__(i, m_iNbButton))
	{
		// End:0x66
		if(__NFUN_130__(__NFUN_119__(m_ButtonItem[i], none), __NFUN_119__(m_ButtonItem[i].m_Button, none)))
		{
			m_ButtonItem[i].m_Button.WinWidth = fNewWidth;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

defaultproperties
{
	m_SeperatorLineTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_SeperatorLineRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=20514,ZoneNumber=0)
}
