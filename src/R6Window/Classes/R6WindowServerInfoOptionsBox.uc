//=============================================================================
// R6WindowServerInfoOptionsBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowServerInfoBox.uc : Class used to manage the "list box" of 
//  server information.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/03 * Created by John Bennett
//=============================================================================
class R6WindowServerInfoOptionsBox extends R6WindowListBox;

var bool m_bDrawBorderAndBkg;  // draw the border and the background
var Font m_Font;
//var color   TextColor;          // color for text            N.B. var already define in class UWindowDialogControl
var Color m_SelTextColor;  // color for selected text

function Created()
{
	super.Created();
	m_VertSB.SetHideWhenDisable(false);
	TextColor = Root.Colors.m_LisBoxNormalTextColor;
	m_SelTextColor = Root.Colors.m_LisBoxSelectedTextColor;
	return;
}

function BeforePaint(Canvas C, float fMouseX, float fMouseY)
{
	local float tW, tH;

	C.Font = m_Font;
	TextSize(C, "TEST", tW, tH);
	m_fItemHeight = (tH + float(2));
	m_VertSB.SetBorderColor(m_BorderColor);
	super(UWindowDialogControl).BeforePaint(C, fMouseX, fMouseY);
	return;
}

function Paint(Canvas C, float fMouseX, float fMouseY)
{
	// End:0x23
	if(m_bDrawBorderAndBkg)
	{
		R6WindowLookAndFeel(LookAndFeel).R6List_DrawBackground(self, C);
	}
	super.Paint(C, fMouseX, fMouseY);
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local float TextY, tW, tH;
	local string szText;
	local R6WindowListInfoOptionsItem pListInfoOptItem;

	pListInfoOptItem = R6WindowListInfoOptionsItem(Item);
	C.Style = 5;
	C.Font = m_Font;
	szText = TextSize(C, pListInfoOptItem.szOptions, tW, tH, int((W - pListInfoOptItem.fOptionsXOff)));
	TextY = ((H - tH) / float(2));
	TextY = float(int((TextY + 0.5000000)));
	(X += pListInfoOptItem.fOptionsXOff);
	C.SetPos(X, (Y + TextY));
	C.DrawText(szText);
	return;
}

defaultproperties
{
	m_SelTextColor=(R=255,G=255,B=255,A=0)
	m_fItemHeight=16.0000000
	ListClass=Class'R6Window.R6WindowListInfoOptionsItem'
}
