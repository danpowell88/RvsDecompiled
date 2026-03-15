//=============================================================================
// UWindowWin95LookAndFeel - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowWin95LookAndFeel extends UWindowLookAndFeel;

const SIZEBORDER = 3;
const BRSIZEBORDER = 15;

var() int CloseBoxOffsetX;
var() int CloseBoxOffsetY;
var() Region SBUpUp;
var() Region SBUpDown;
var() Region SBUpDisabled;
var() Region SBDownUp;
var() Region SBDownDown;
var() Region SBDownDisabled;
var() Region SBLeftUp;
var() Region SBLeftDown;
var() Region SBLeftDisabled;
var() Region SBRightUp;
var() Region SBRightDown;
var() Region SBRightDisabled;
var() Region SBBackground;
var() Region FrameSBL;
var() Region FrameSB;
var() Region FrameSBR;
var() Region CloseBoxUp;
var() Region CloseBoxDown;

function FW_DrawWindowFrame(UWindowFramedWindow W, Canvas C)
{
	local Texture t;
	local Region R, temp;

	C.DrawColor.R = byte(255);
	C.DrawColor.G = byte(255);
	C.DrawColor.B = byte(255);
	t = W.GetLookAndFeelTexture();
	R = FrameTL;
	W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = FrameT;
	W.DrawStretchedTextureSegment(C, float(FrameTL.W), 0.0000000, ((W.WinWidth - float(FrameTL.W)) - float(FrameTR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = FrameTR;
	W.DrawStretchedTextureSegment(C, (W.WinWidth - float(R.W)), 0.0000000, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	// End:0x21B
	if(W.bStatusBar)
	{
		temp = FrameSBL;		
	}
	else
	{
		temp = FrameBL;
	}
	R = FrameL;
	W.DrawStretchedTextureSegment(C, 0.0000000, float(FrameTL.H), float(R.W), ((W.WinHeight - float(FrameTL.H)) - float(temp.H)), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	R = FrameR;
	W.DrawStretchedTextureSegment(C, (W.WinWidth - float(R.W)), float(FrameTL.H), float(R.W), ((W.WinHeight - float(FrameTL.H)) - float(temp.H)), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	// End:0x393
	if(W.bStatusBar)
	{
		R = FrameSBL;		
	}
	else
	{
		R = FrameBL;
	}
	W.DrawStretchedTextureSegment(C, 0.0000000, (W.WinHeight - float(R.H)), float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	// End:0x4E7
	if(W.bStatusBar)
	{
		R = FrameSB;
		W.DrawStretchedTextureSegment(C, float(FrameBL.W), (W.WinHeight - float(R.H)), ((W.WinWidth - float(FrameSBL.W)) - float(FrameSBR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);		
	}
	else
	{
		R = FrameB;
		W.DrawStretchedTextureSegment(C, float(FrameBL.W), (W.WinHeight - float(R.H)), ((W.WinWidth - float(FrameBL.W)) - float(FrameBR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	}
	// End:0x5B9
	if(W.bStatusBar)
	{
		R = FrameSBR;		
	}
	else
	{
		R = FrameBR;
	}
	W.DrawStretchedTextureSegment(C, (W.WinWidth - float(R.W)), (W.WinHeight - float(R.H)), float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
	C.Font = W.Root.Fonts[W.0];
	// End:0x6C6
	if((W.ParentWindow.ActiveWindow == W))
	{
		C.DrawColor = FrameActiveTitleColor;		
	}
	else
	{
		C.DrawColor = FrameInactiveTitleColor;
	}
	W.ClipTextWidth(C, float(FrameTitleX), float(FrameTitleY), W.WindowTitle, (W.WinWidth - float(22)));
	// End:0x809
	if(W.bStatusBar)
	{
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
		W.ClipTextWidth(C, 6.0000000, (W.WinHeight - float(13)), W.StatusBarText, (W.WinWidth - float(22)));
		C.DrawColor.R = byte(255);
		C.DrawColor.G = byte(255);
		C.DrawColor.B = byte(255);
	}
	return;
}

function FW_SetupFrameButtons(UWindowFramedWindow W, Canvas C)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.CloseBox.WinLeft = ((W.WinWidth - float(CloseBoxOffsetX)) - float(CloseBoxUp.W));
	W.CloseBox.WinTop = float(CloseBoxOffsetY);
	W.CloseBox.SetSize(float(CloseBoxUp.W), float(CloseBoxUp.H));
	W.CloseBox.bUseRegion = true;
	W.CloseBox.UpTexture = t;
	W.CloseBox.DownTexture = t;
	W.CloseBox.OverTexture = t;
	W.CloseBox.DisabledTexture = t;
	W.CloseBox.UpRegion = CloseBoxUp;
	W.CloseBox.DownRegion = CloseBoxDown;
	W.CloseBox.OverRegion = CloseBoxUp;
	W.CloseBox.DisabledRegion = CloseBoxUp;
	return;
}

function Region FW_GetClientArea(UWindowFramedWindow W)
{
	local Region R;

	R.X = FrameL.W;
	R.Y = FrameT.H;
	R.W = int((W.WinWidth - float((FrameL.W + FrameR.W))));
	// End:0xA9
	if(W.bStatusBar)
	{
		R.H = int((W.WinHeight - float((FrameT.H + FrameSB.H))));		
	}
	else
	{
		R.H = int((W.WinHeight - float((FrameT.H + FrameB.H))));
	}
	return R;
	return;
}

function UWindowBase.FrameHitTest FW_HitTest(UWindowFramedWindow W, float X, float Y)
{
	// End:0x51
	if(((((X >= float(3)) && (X <= (W.WinWidth - float(3)))) && (Y >= float(3))) && (Y <= float(14))))
	{
		return 8;
	}
	// End:0x92
	if((((X < float(15)) && (Y < float(3))) || ((X < float(3)) && (Y < float(15)))))
	{
		return 0;
	}
	// End:0xF3
	if((((X > (W.WinWidth - float(3))) && (Y < float(15))) || ((X > (W.WinWidth - float(15))) && (Y < float(3)))))
	{
		return 2;
	}
	// End:0x154
	if((((X < float(15)) && (Y > (W.WinHeight - float(3)))) || ((X < float(3)) && (Y > (W.WinHeight - float(15))))))
	{
		return 5;
	}
	// End:0x195
	if(((X > (W.WinWidth - float(15))) && (Y > (W.WinHeight - float(15)))))
	{
		return 7;
	}
	// End:0x1A6
	if((Y < float(3)))
	{
		return 1;
	}
	// End:0x1C7
	if((Y > (W.WinHeight - float(3))))
	{
		return 6;
	}
	// End:0x1D8
	if((X < float(3)))
	{
		return 3;
	}
	// End:0x1F9
	if((X > (W.WinWidth - float(3))))
	{
		return 4;
	}
	return 10;
	return;
}

function DrawClientArea(UWindowClientWindow W, Canvas C)
{
	W.DrawStretchedTexture(C, 0.0000000, 0.0000000, W.WinWidth, W.WinHeight, Texture'UWindow.BlackTexture');
	return;
}

function Combo_SetupSizes(UWindowComboControl W, Canvas C)
{
	local float tW, tH;

	C.Font = W.Root.Fonts[W.Font];
	W.TextSize(C, W.Text, tW, tH);
	W.WinHeight = ((12.0000000 + float(MiscBevelT[2].H)) + float(MiscBevelB[2].H));
	switch(W.Align)
	{
		// End:0xF1
		case 0:
			W.EditAreaDrawX = (W.WinWidth - W.EditBoxWidth);
			W.TextX = 0.0000000;
			// End:0x199
			break;
		// End:0x131
		case 1:
			W.EditAreaDrawX = 0.0000000;
			W.TextX = (W.WinWidth - tW);
			// End:0x199
			break;
		// End:0x196
		case 2:
			W.EditAreaDrawX = ((W.WinWidth - W.EditBoxWidth) / float(2));
			W.TextX = ((W.WinWidth - tW) / float(2));
			// End:0x199
			break;
		// End:0xFFFF
		default:
			break;
	}
	W.EditAreaDrawY = ((W.WinHeight - float(2)) / float(2));
	W.TextY = ((W.WinHeight - tH) / float(2));
	W.EditBox.WinLeft = (W.EditAreaDrawX + float(MiscBevelL[2].W));
	W.EditBox.WinTop = float(MiscBevelT[2].H);
	W.Button.WinWidth = float(ComboBtnUp.W);
	// End:0x553
	if(W.bButtons)
	{
		W.EditBox.WinWidth = (((((W.EditBoxWidth - float(MiscBevelL[2].W)) - float(MiscBevelR[2].W)) - float(ComboBtnUp.W)) - float(SBLeftUp.W)) - float(SBRightUp.W));
		W.EditBox.WinHeight = ((W.WinHeight - float(MiscBevelT[2].H)) - float(MiscBevelB[2].H));
		W.Button.WinLeft = ((((W.WinWidth - float(ComboBtnUp.W)) - float(MiscBevelR[2].W)) - float(SBLeftUp.W)) - float(SBRightUp.W));
		W.Button.WinTop = W.EditBox.WinTop;
		W.LeftButton.WinLeft = (((W.WinWidth - float(MiscBevelR[2].W)) - float(SBLeftUp.W)) - float(SBRightUp.W));
		W.LeftButton.WinTop = W.EditBox.WinTop;
		W.RightButton.WinLeft = ((W.WinWidth - float(MiscBevelR[2].W)) - float(SBRightUp.W));
		W.RightButton.WinTop = W.EditBox.WinTop;
		W.LeftButton.WinWidth = float(SBLeftUp.W);
		W.LeftButton.WinHeight = float(SBLeftUp.H);
		W.RightButton.WinWidth = float(SBRightUp.W);
		W.RightButton.WinHeight = float(SBRightUp.H);		
	}
	else
	{
		W.EditBox.WinWidth = (((W.EditBoxWidth - float(MiscBevelL[2].W)) - float(MiscBevelR[2].W)) - float(ComboBtnUp.W));
		W.EditBox.WinHeight = ((W.WinHeight - float(MiscBevelT[2].H)) - float(MiscBevelB[2].H));
		W.Button.WinLeft = ((W.WinWidth - float(ComboBtnUp.W)) - float(MiscBevelR[2].W));
		W.Button.WinTop = W.EditBox.WinTop;
	}
	W.Button.WinHeight = W.EditBox.WinHeight;
	return;
}

function Combo_Draw(UWindowComboControl W, Canvas C)
{
	W.DrawMiscBevel(C, W.EditAreaDrawX, 0.0000000, W.EditBoxWidth, W.WinHeight, Misc, 2);
	// End:0x102
	if((W.Text != ""))
	{
		C.DrawColor = W.TextColor;
		W.ClipText(C, W.TextX, W.TextY, W.Text);
		C.DrawColor.R = byte(255);
		C.DrawColor.G = byte(255);
		C.DrawColor.B = byte(255);
	}
	return;
}

function ComboList_DrawBackground(UWindowComboList W, Canvas C)
{
	W.DrawClippedTexture(C, 0.0000000, 0.0000000, Texture'UWindow.Icons.MenuTL');
	W.DrawStretchedTexture(C, 4.0000000, 0.0000000, (W.WinWidth - float(8)), 4.0000000, Texture'UWindow.Icons.MenuT');
	W.DrawClippedTexture(C, (W.WinWidth - float(4)), 0.0000000, Texture'UWindow.Icons.MenuTR');
	W.DrawClippedTexture(C, 0.0000000, (W.WinHeight - float(4)), Texture'UWindow.Icons.MenuBL');
	W.DrawStretchedTexture(C, 4.0000000, (W.WinHeight - float(4)), __NFUN_175__(W.WinWidth, float(8)), 4.0000000, Texture'UWindow.Icons.MenuB');
	W.DrawClippedTexture(C, __NFUN_175__(W.WinWidth, float(4)), __NFUN_175__(W.WinHeight, float(4)), Texture'UWindow.Icons.MenuBR');
	W.DrawStretchedTexture(C, 0.0000000, 4.0000000, 4.0000000, __NFUN_175__(W.WinHeight, float(8)), Texture'UWindow.Icons.MenuL');
	W.DrawStretchedTexture(C, __NFUN_175__(W.WinWidth, float(4)), 4.0000000, 4.0000000, __NFUN_175__(W.WinHeight, float(8)), Texture'UWindow.Icons.MenuR');
	W.DrawStretchedTexture(C, 4.0000000, 4.0000000, __NFUN_175__(W.WinWidth, float(8)), __NFUN_175__(W.WinHeight, float(8)), Texture'UWindow.Icons.MenuArea');
	return;
}

function ComboList_DrawItem(UWindowComboList Combo, Canvas C, float X, float Y, float W, float H, string Text, bool bSelected)
{
	C.DrawColor.R = byte(255);
	C.DrawColor.G = byte(255);
	C.DrawColor.B = byte(255);
	// End:0xC3
	if(bSelected)
	{
		Combo.DrawStretchedTexture(C, X, Y, W, H, Texture'UWindow.Icons.MenuHighlight');
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;		
	}
	else
	{
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
	}
	Combo.ClipText(C, __NFUN_174__(__NFUN_174__(X, float(Combo.TextBorder)), float(2)), __NFUN_174__(Y, float(3)), Text);
	return;
}

function Combo_SetupButton(UWindowComboButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = ComboBtnUp;
	W.DownRegion = ComboBtnDown;
	W.OverRegion = ComboBtnUp;
	W.DisabledRegion = ComboBtnDisabled;
	return;
}

function Editbox_SetupSizes(UWindowEditControl W, Canvas C)
{
	local float tW, tH;
	local int B;

	B = EditBoxBevel;
	C.Font = W.Root.Fonts[W.Font];
	W.TextSize(C, W.Text, tW, tH);
	W.WinHeight = __NFUN_174__(__NFUN_174__(12.0000000, float(MiscBevelT[B].H)), float(MiscBevelB[B].H));
	switch(W.Align)
	{
		// End:0x102
		case 0:
			W.EditAreaDrawX = __NFUN_175__(W.WinWidth, W.EditBoxWidth);
			W.TextX = 0.0000000;
			// End:0x1AA
			break;
		// End:0x142
		case 1:
			W.EditAreaDrawX = 0.0000000;
			W.TextX = __NFUN_175__(W.WinWidth, tW);
			// End:0x1AA
			break;
		// End:0x1A7
		case 2:
			W.EditAreaDrawX = __NFUN_172__(__NFUN_175__(W.WinWidth, W.EditBoxWidth), float(2));
			W.TextX = __NFUN_172__(__NFUN_175__(W.WinWidth, tW), float(2));
			// End:0x1AA
			break;
		// End:0xFFFF
		default:
			break;
	}
	W.EditAreaDrawY = __NFUN_172__(__NFUN_175__(W.WinHeight, float(2)), float(2));
	W.TextY = __NFUN_172__(__NFUN_175__(W.WinHeight, tH), float(2));
	W.EditBox.WinLeft = __NFUN_174__(W.EditAreaDrawX, float(MiscBevelL[B].W));
	W.EditBox.WinTop = float(MiscBevelT[B].H);
	W.EditBox.WinWidth = __NFUN_175__(__NFUN_175__(W.EditBoxWidth, float(MiscBevelL[B].W)), float(MiscBevelR[B].W));
	W.EditBox.WinHeight = __NFUN_175__(__NFUN_175__(W.WinHeight, float(MiscBevelT[B].H)), float(MiscBevelB[B].H));
	return;
}

function Editbox_Draw(UWindowEditControl W, Canvas C)
{
	W.DrawMiscBevel(C, W.EditAreaDrawX, 0.0000000, W.EditBoxWidth, W.WinHeight, Misc, EditBoxBevel);
	// End:0x105
	if(__NFUN_123__(W.Text, ""))
	{
		C.DrawColor = W.TextColor;
		W.ClipText(C, W.TextX, W.TextY, W.Text);
		C.DrawColor.R = byte(255);
		C.DrawColor.G = byte(255);
		C.DrawColor.B = byte(255);
	}
	return;
}

function Tab_DrawTab(UWindowTabControlTabArea Tab, Canvas C, bool bActiveTab, bool bLeftmostTab, float X, float Y, float W, float H, string Text, bool bShowText)
{
	local Region R;
	local Texture t;
	local float tW, tH;

	C.DrawColor.R = byte(255);
	C.DrawColor.G = byte(255);
	C.DrawColor.B = byte(255);
	t = Tab.GetLookAndFeelTexture();
	// End:0x2E1
	if(bActiveTab)
	{
		R = TabSelectedL;
		Tab.DrawStretchedTextureSegment(C, X, Y, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
		R = TabSelectedM;
		Tab.DrawStretchedTextureSegment(C, __NFUN_174__(X, float(TabSelectedL.W)), Y, __NFUN_175__(__NFUN_175__(W, float(TabSelectedL.W)), float(TabSelectedR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
		R = TabSelectedR;
		Tab.DrawStretchedTextureSegment(C, __NFUN_175__(__NFUN_174__(X, W), float(R.W)), Y, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
		C.Font = Tab.Root.Fonts[Tab.1];
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
		// End:0x2DE
		if(bShowText)
		{
			Tab.TextSize(C, Text, tW, tH);
			Tab.ClipText(C, __NFUN_174__(X, __NFUN_172__(__NFUN_175__(W, tW), float(2))), __NFUN_174__(Y, float(3)), Text, true);
		}		
	}
	else
	{
		R = TabUnselectedL;
		Tab.DrawStretchedTextureSegment(C, X, Y, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
		R = TabUnselectedM;
		Tab.DrawStretchedTextureSegment(C, __NFUN_174__(X, float(TabUnselectedL.W)), Y, __NFUN_175__(__NFUN_175__(W, float(TabUnselectedL.W)), float(TabUnselectedR.W)), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
		R = TabUnselectedR;
		Tab.DrawStretchedTextureSegment(C, __NFUN_175__(__NFUN_174__(X, W), float(R.W)), Y, float(R.W), float(R.H), float(R.X), float(R.Y), float(R.W), float(R.H), t);
		C.Font = Tab.Root.Fonts[Tab.0];
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
		// End:0x559
		if(bShowText)
		{
			Tab.TextSize(C, Text, tW, tH);
			Tab.ClipText(C, __NFUN_174__(X, __NFUN_172__(__NFUN_175__(W, tW), float(2))), __NFUN_174__(Y, float(4)), Text, true);
		}
	}
	return;
}

function SB_SetupUpButton(UWindowSBUpButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = SBUpUp;
	W.DownRegion = SBUpDown;
	W.OverRegion = SBUpUp;
	W.DisabledRegion = SBUpDisabled;
	return;
}

function SB_SetupDownButton(UWindowSBDownButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = SBDownUp;
	W.DownRegion = SBDownDown;
	W.OverRegion = SBDownUp;
	W.DisabledRegion = SBDownDisabled;
	return;
}

function SB_SetupLeftButton(UWindowSBLeftButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = SBLeftUp;
	W.DownRegion = SBLeftDown;
	W.OverRegion = SBLeftUp;
	W.DisabledRegion = SBLeftDisabled;
	return;
}

function SB_SetupRightButton(UWindowSBRightButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = SBRightUp;
	W.DownRegion = SBRightDown;
	W.OverRegion = SBRightUp;
	W.DisabledRegion = SBRightDisabled;
	return;
}

function SB_VDraw(UWindowVScrollbar W, Canvas C)
{
	local Region R;
	local Texture t;

	t = W.GetLookAndFeelTexture();
	R = SBBackground;
	W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, W.WinWidth, W.WinHeight, float(R.X), float(R.Y), float(R.W), float(R.H), t);
	// End:0xE2
	if(__NFUN_129__(W.bDisabled))
	{
		W.DrawUpBevel(C, 0.0000000, W.ThumbStart, Size_ScrollbarWidth, W.ThumbHeight, t);
	}
	return;
}

function SB_HDraw(UWindowHScrollbar W, Canvas C)
{
	local Region R;
	local Texture t;

	t = W.GetLookAndFeelTexture();
	R = SBBackground;
	W.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, W.WinWidth, W.WinHeight, float(R.X), float(R.Y), float(R.W), float(R.H), t);
	// End:0xE2
	if(__NFUN_129__(W.bDisabled))
	{
		W.DrawUpBevel(C, W.ThumbStart, 0.0000000, W.ThumbWidth, Size_ScrollbarWidth, t);
	}
	return;
}

function Tab_SetupLeftButton(UWindowTabControlLeftButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.WinWidth = Size_ScrollbarButtonHeight;
	W.WinHeight = Size_ScrollbarWidth;
	W.WinTop = __NFUN_175__(Size_TabAreaHeight, W.WinHeight);
	W.WinLeft = __NFUN_175__(W.ParentWindow.WinWidth, __NFUN_171__(float(2), W.WinWidth));
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = SBLeftUp;
	W.DownRegion = SBLeftDown;
	W.OverRegion = SBLeftUp;
	W.DisabledRegion = SBLeftDisabled;
	return;
}

function Tab_SetupRightButton(UWindowTabControlRightButton W)
{
	local Texture t;

	t = W.GetLookAndFeelTexture();
	W.WinWidth = Size_ScrollbarButtonHeight;
	W.WinHeight = Size_ScrollbarWidth;
	W.WinTop = __NFUN_175__(Size_TabAreaHeight, W.WinHeight);
	W.WinLeft = __NFUN_175__(W.ParentWindow.WinWidth, W.WinWidth);
	W.bUseRegion = true;
	W.UpTexture = t;
	W.DownTexture = t;
	W.OverTexture = t;
	W.DisabledTexture = t;
	W.UpRegion = SBRightUp;
	W.DownRegion = SBRightDown;
	W.OverRegion = SBRightUp;
	W.DisabledRegion = SBRightDisabled;
	return;
}

function Tab_SetTabPageSize(UWindowPageControl W, UWindowPageWindow P)
{
	P.WinLeft = 2.0000000;
	P.WinTop = __NFUN_174__(__NFUN_175__(W.TabArea.WinHeight, float(__NFUN_147__(TabSelectedM.H, TabUnselectedM.H))), float(3));
	P.SetSize(__NFUN_175__(W.WinWidth, float(4)), __NFUN_175__(__NFUN_175__(W.WinHeight, __NFUN_175__(W.TabArea.WinHeight, float(__NFUN_147__(TabSelectedM.H, TabUnselectedM.H)))), float(6)));
	return;
}

function Tab_DrawTabPageArea(UWindowPageControl W, Canvas C, UWindowPageWindow P)
{
	W.DrawUpBevel(C, 0.0000000, Size_TabAreaHeight, W.WinWidth, __NFUN_175__(W.WinHeight, Size_TabAreaHeight), W.GetLookAndFeelTexture());
	return;
}

function Tab_GetTabSize(UWindowTabControlTabArea Tab, Canvas C, string Text, out float W, out float H)
{
	local float tW, tH;

	C.Font = Tab.Root.Fonts[Tab.0];
	Tab.TextSize(C, Text, tW, tH);
	W = __NFUN_174__(tW, Size_TabSpacing);
	H = tH;
	return;
}

function Menu_DrawMenuBar(UWindowMenuBar W, Canvas C)
{
	W.DrawStretchedTexture(C, 16.0000000, 0.0000000, __NFUN_175__(W.WinWidth, float(32)), 16.0000000, Texture'UWindow.Icons.MenuBar');
	return;
}

function Menu_DrawMenuBarItem(UWindowMenuBar B, UWindowMenuBarItem i, float X, float Y, float W, float H, Canvas C)
{
	// End:0xA2
	if(__NFUN_114__(B.Selected, i))
	{
		B.DrawClippedTexture(C, X, 1.0000000, Texture'UWindow.Icons.MenuHighlightL');
		B.DrawClippedTexture(C, __NFUN_175__(__NFUN_174__(X, W), float(1)), 1.0000000, Texture'UWindow.Icons.MenuHighlightR');
		B.DrawStretchedTexture(C, __NFUN_174__(X, float(1)), 1.0000000, __NFUN_175__(W, float(2)), 16.0000000, Texture'UWindow.Icons.MenuHighlightM');
	}
	C.Font = B.Root.Fonts[0];
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	B.ClipText(C, __NFUN_174__(X, float(__NFUN_145__(B.Spacing, 2))), 2.0000000, i.Caption, true);
	return;
}

function Menu_DrawPulldownMenuBackground(UWindowPulldownMenu W, Canvas C)
{
	W.DrawClippedTexture(C, 0.0000000, 0.0000000, Texture'UWindow.Icons.MenuTL');
	W.DrawStretchedTexture(C, 2.0000000, 0.0000000, __NFUN_175__(W.WinWidth, float(4)), 2.0000000, Texture'UWindow.Icons.MenuT');
	W.DrawClippedTexture(C, __NFUN_175__(W.WinWidth, float(2)), 0.0000000, Texture'UWindow.Icons.MenuTR');
	W.DrawClippedTexture(C, 0.0000000, __NFUN_175__(W.WinHeight, float(2)), Texture'UWindow.Icons.MenuBL');
	W.DrawStretchedTexture(C, 2.0000000, __NFUN_175__(W.WinHeight, float(2)), __NFUN_175__(W.WinWidth, float(4)), 2.0000000, Texture'UWindow.Icons.MenuB');
	W.DrawClippedTexture(C, __NFUN_175__(W.WinWidth, float(2)), __NFUN_175__(W.WinHeight, float(2)), Texture'UWindow.Icons.MenuBR');
	W.DrawStretchedTexture(C, 0.0000000, 2.0000000, 2.0000000, __NFUN_175__(W.WinHeight, float(4)), Texture'UWindow.Icons.MenuL');
	W.DrawStretchedTexture(C, __NFUN_175__(W.WinWidth, float(2)), 2.0000000, 2.0000000, __NFUN_175__(W.WinHeight, float(4)), Texture'UWindow.Icons.MenuR');
	W.DrawStretchedTexture(C, 2.0000000, 2.0000000, __NFUN_175__(W.WinWidth, float(4)), __NFUN_175__(W.WinHeight, float(4)), Texture'UWindow.Icons.MenuArea');
	return;
}

function Menu_DrawPulldownMenuItem(UWindowPulldownMenu M, UWindowPulldownMenuItem Item, Canvas C, float X, float Y, float W, float H, bool bSelected)
{
	C.DrawColor.R = byte(255);
	C.DrawColor.G = byte(255);
	C.DrawColor.B = byte(255);
	Item.ItemTop = __NFUN_174__(Y, M.WinTop);
	// End:0xFF
	if(__NFUN_122__(Item.Caption, "-"))
	{
		C.DrawColor.R = byte(255);
		C.DrawColor.G = byte(255);
		C.DrawColor.B = byte(255);
		M.DrawStretchedTexture(C, X, __NFUN_174__(Y, float(5)), W, 2.0000000, Texture'UWindow.Icons.MenuDivider');
		return;
	}
	C.Font = M.Root.Fonts[0];
	// End:0x15D
	if(bSelected)
	{
		M.DrawStretchedTexture(C, X, Y, W, H, Texture'UWindow.Icons.MenuHighlight');
	}
	// End:0x1B4
	if(Item.bDisabled)
	{
		C.DrawColor.R = 96;
		C.DrawColor.G = 96;
		C.DrawColor.B = 96;		
	}
	else
	{
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
	}
	// End:0x236
	if(Item.bChecked)
	{
		M.DrawClippedTexture(C, __NFUN_174__(X, float(1)), __NFUN_174__(Y, float(3)), Texture'UWindow.Icons.MenuTick');
	}
	// End:0x280
	if(__NFUN_119__(Item.SubMenu, none))
	{
		M.DrawClippedTexture(C, __NFUN_175__(__NFUN_174__(X, W), float(9)), __NFUN_174__(Y, float(3)), Texture'UWindow.Icons.MenuSubArrow');
	}
	M.ClipText(C, __NFUN_174__(__NFUN_174__(X, float(M.TextBorder)), float(2)), __NFUN_174__(Y, float(3)), Item.Caption, true);
	return;
}

defaultproperties
{
	CloseBoxOffsetX=3
	CloseBoxOffsetY=5
	SBUpUp=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=5154,ZoneNumber=0)
	SBUpDown=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=8226,ZoneNumber=0)
	SBUpDisabled=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=11298,ZoneNumber=0)
	SBDownUp=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=5154,ZoneNumber=0)
	SBDownDown=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=8226,ZoneNumber=0)
	SBDownDisabled=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=11298,ZoneNumber=0)
	SBLeftUp=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=5154,ZoneNumber=0)
	SBLeftDown=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=7714,ZoneNumber=0)
	SBLeftDisabled=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=10274,ZoneNumber=0)
	SBRightUp=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=5154,ZoneNumber=0)
	SBRightDown=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=7714,ZoneNumber=0)
	SBRightDisabled=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=10274,ZoneNumber=0)
	SBBackground=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1058,ZoneNumber=0)
	FrameSBL=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=28706,ZoneNumber=0)
	FrameSB=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=8226,ZoneNumber=0)
	FrameSBR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=28706,ZoneNumber=0)
	CloseBoxUp=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1058,ZoneNumber=0)
	CloseBoxDown=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1058,ZoneNumber=0)
	FrameTitleX=6
	FrameTitleY=4
	ColumnHeadingHeight=13
	EditBoxBevel=2
	Size_ScrollbarWidth=12.0000000
	Size_ScrollbarButtonHeight=10.0000000
	Size_MinScrollbarHeight=6.0000000
	Size_TabAreaHeight=15.0000000
	Size_TabAreaOverhangHeight=2.0000000
	Size_TabSpacing=20.0000000
	Size_TabXOffset=1.0000000
	Pulldown_ItemHeight=15.0000000
	Pulldown_VBorder=3.0000000
	Pulldown_HBorder=3.0000000
	Pulldown_TextBorder=9.0000000
	Active=Texture'UWindow.Icons.ActiveFrame'
	Inactive=Texture'UWindow.Icons.InactiveFrame'
	ActiveS=Texture'UWindow.Icons.ActiveFrameS'
	InactiveS=Texture'UWindow.Icons.InactiveFrameS'
	Misc=Texture'UWindow.Icons.Misc'
	FrameTL=(Zone=FloatProperty'UWindow.UWindowWindow.WinWidth',iLeaf=546,ZoneNumber=0)
	FrameT=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=8226,ZoneNumber=0)
	FrameTR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=32290,ZoneNumber=0)
	FrameL=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=8226,ZoneNumber=0)
	FrameR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=32290,ZoneNumber=0)
	FrameBL=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=32034,ZoneNumber=0)
	FrameB=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=8226,ZoneNumber=0)
	FrameBR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=32290,ZoneNumber=0)
	FrameActiveTitleColor=(R=255,G=255,B=255,A=0)
	FrameInactiveTitleColor=(R=255,G=255,B=255,A=0)
	BevelUpTL=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1058,ZoneNumber=0)
	BevelUpT=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=2594,ZoneNumber=0)
	BevelUpTR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=4642,ZoneNumber=0)
	BevelUpL=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1058,ZoneNumber=0)
	BevelUpR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=4642,ZoneNumber=0)
	BevelUpBL=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1058,ZoneNumber=0)
	BevelUpB=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=2594,ZoneNumber=0)
	BevelUpBR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=4642,ZoneNumber=0)
	BevelUpArea=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=2082,ZoneNumber=0)
	MiscBevelTL[0]=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=4386,ZoneNumber=0)
	MiscBevelTL[1]=(Zone=FloatProperty'UWindow.UWindowWindow.WinWidth',iLeaf=802,ZoneNumber=0)
	MiscBevelTL[2]=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=8482,ZoneNumber=0)
	MiscBevelT[0]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=802,ZoneNumber=0)
	MiscBevelT[1]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=802,ZoneNumber=0)
	MiscBevelT[2]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=546,ZoneNumber=0)
	MiscBevelTR[0]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=30498,ZoneNumber=0)
	MiscBevelTR[1]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=30498,ZoneNumber=0)
	MiscBevelTR[2]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=2850,ZoneNumber=0)
	MiscBevelL[0]=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=5154,ZoneNumber=0)
	MiscBevelL[1]=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=802,ZoneNumber=0)
	MiscBevelL[2]=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=9250,ZoneNumber=0)
	MiscBevelR[0]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=30498,ZoneNumber=0)
	MiscBevelR[1]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=30498,ZoneNumber=0)
	MiscBevelR[2]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=2850,ZoneNumber=0)
	MiscBevelBL[0]=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=7714,ZoneNumber=0)
	MiscBevelBL[1]=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=3618,ZoneNumber=0)
	MiscBevelBL[2]=(Zone=ObjectProperty'UWindow.UWindowList.Next',iLeaf=11298,ZoneNumber=0)
	MiscBevelB[0]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=802,ZoneNumber=0)
	MiscBevelB[1]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=802,ZoneNumber=0)
	MiscBevelB[2]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=546,ZoneNumber=0)
	MiscBevelBR[0]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=30498,ZoneNumber=0)
	MiscBevelBR[1]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=30498,ZoneNumber=0)
	MiscBevelBR[2]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=2850,ZoneNumber=0)
	MiscBevelArea[0]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=802,ZoneNumber=0)
	MiscBevelArea[1]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=802,ZoneNumber=0)
	MiscBevelArea[2]=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=546,ZoneNumber=0)
	ComboBtnUp=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=5154,ZoneNumber=0)
	ComboBtnDown=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=8226,ZoneNumber=0)
	ComboBtnDisabled=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=11298,ZoneNumber=0)
	HLine=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1314,ZoneNumber=0)
	TabSelectedL=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1058,ZoneNumber=0)
	TabSelectedM=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1826,ZoneNumber=0)
	TabSelectedR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=14114,ZoneNumber=0)
	TabUnselectedL=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=14626,ZoneNumber=0)
	TabUnselectedM=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=15394,ZoneNumber=0)
	TabUnselectedR=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=27938,ZoneNumber=0)
	TabBackground=(Zone=ObjectProperty'UWindow.UWindowWindow.LookAndFeel',iLeaf=1058,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function FW_HitTest
