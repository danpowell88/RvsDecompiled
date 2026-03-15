//=============================================================================
// R6MenuLaptopWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuLaptopWidget.uc : Class to be derived in order to get the laptop borders
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/12 * Created by Alexandre Dionne
//=============================================================================
class R6MenuLaptopWidget extends R6MenuWidget;

var float m_fLaptopPadding;
var R6MenuNavigationBar m_NavBar;
var R6MenuHelpTextFrameBar m_HelpTextBar;
var R6MenuSimpleWindow m_EmptyBox1;
var R6MenuSimpleWindow m_EmptyBox2;
var UWindowWindow m_Right;
var UWindowWindow m_Left;
var UWindowWindow m_Bottom;
var UWindowWindow m_Top;
var Texture m_TBackGround;
var Region m_RBackGround;

function Created()
{
	local R6MenuRSLookAndFeel LAF;
	local Region R;

	LAF = R6MenuRSLookAndFeel(OwnerWindow.LookAndFeel);
	m_Left = CreateWindow(Class'UWindow.UWindowWindow', 0.0000000, float(LAF.m_stLapTopFrame.t.H), float(LAF.m_stLapTopFrame.L.W), float((((LAF.m_stLapTopFrame.L.H + LAF.m_stLapTopFrame.L2.H) + LAF.m_stLapTopFrame.L3.H) + LAF.m_stLapTopFrame.L4.H)), self);
	m_Right = CreateWindow(Class'UWindow.UWindowWindow', float((((LAF.m_stLapTopFrame.BL.W + LAF.m_stLapTopFrame.B.W) + LAF.m_stLapTopFrame.BR.W) - LAF.m_stLapTopFrame.R.W)), float(LAF.m_stLapTopFrame.t.H), float(LAF.m_stLapTopFrame.R.W), float((((LAF.m_stLapTopFrame.R.H + LAF.m_stLapTopFrame.R2.H) + LAF.m_stLapTopFrame.R3.H) + LAF.m_stLapTopFrame.R4.H)), self);
	m_Bottom = CreateWindow(Class'UWindow.UWindowWindow', 0.0000000, float(((((LAF.m_stLapTopFrame.t.H + LAF.m_stLapTopFrame.L.H) + LAF.m_stLapTopFrame.L2.H) + LAF.m_stLapTopFrame.L3.H) + LAF.m_stLapTopFrame.L4.H)), float(((LAF.m_stLapTopFrame.BL.W + LAF.m_stLapTopFrame.B.W) + LAF.m_stLapTopFrame.BR.W)), float(LAF.m_stLapTopFrame.B.H), self);
	m_Top = CreateWindow(Class'UWindow.UWindowWindow', 0.0000000, 0.0000000, float(((LAF.m_stLapTopFrame.BL.W + LAF.m_stLapTopFrame.B.W) + LAF.m_stLapTopFrame.BR.W)), float(LAF.m_stLapTopFrame.t.H), self);
	m_Left.HideWindow();
	m_Right.HideWindow();
	m_Bottom.HideWindow();
	m_Top.HideWindow();
	R.H = 33;
	R.X = (LAF.m_stLapTopFrame.L.W + 2);
	R.Y = int(((m_Bottom.WinTop - float(R.H)) - m_fLaptopPadding));
	R.W = (640 - (2 * R.X));
	m_NavBar = R6MenuNavigationBar(CreateWindow(Class'R6Menu.R6MenuNavigationBar', float(R.X), float(R.Y), float(R.W), float(R.H), self));
	R.H = 16;
	R.Y = int(((m_NavBar.WinTop - float(R.H)) - m_fLaptopPadding));
	R.X = int(m_NavBar.WinLeft);
	R.W = 35;
	m_EmptyBox1 = R6MenuSimpleWindow(CreateWindow(Class'R6Menu.R6MenuSimpleWindow', float(R.X), float(R.Y), float(R.W), float(R.H), self));
	m_EmptyBox1.m_BorderColor = Root.Colors.BlueLight;
	R.X = int(((m_NavBar.WinLeft + m_NavBar.WinWidth) - float(R.W)));
	m_EmptyBox2 = R6MenuSimpleWindow(CreateWindow(Class'R6Menu.R6MenuSimpleWindow', float(R.X), float(R.Y), float(R.W), float(R.H), self));
	m_EmptyBox2.m_BorderColor = Root.Colors.BlueLight;
	R.H = 16;
	R.Y = int(((m_NavBar.WinTop - float(R.H)) - m_fLaptopPadding));
	R.X = int(((m_NavBar.WinLeft + float(R.W)) + float(2)));
	R.W = int(((m_NavBar.WinWidth - float((2 * R.W))) - float(4)));
	m_HelpTextBar = R6MenuHelpTextFrameBar(CreateWindow(Class'R6Menu.R6MenuHelpTextFrameBar', float(R.X), float(R.Y), float(R.W), float(R.H), self));
	m_fRightMouseXClipping = m_Right.WinLeft;
	m_fRightMouseYClipping = m_Bottom.WinTop;
	return;
}

//-----------------------------------------------------------//
//                      Mouse functions                      //
//-----------------------------------------------------------//
function SetMousePos(float X, float Y)
{
	local float fMouseX, fMouseY;

	fMouseX = X;
	fMouseY = Y;
	// End:0x45
	if((fMouseX < m_Left.WinWidth))
	{
		fMouseX = m_Left.WinWidth;		
	}
	else
	{
		// End:0x71
		if((fMouseX > m_Right.WinLeft))
		{
			fMouseX = m_Right.WinLeft;
		}
	}
	// End:0xA0
	if((fMouseY < m_Top.WinHeight))
	{
		fMouseY = m_Top.WinHeight;		
	}
	else
	{
		// End:0xCC
		if((fMouseY > m_Bottom.WinTop))
		{
			fMouseY = m_Bottom.WinTop;
		}
	}
	Root.Console.MouseX = fMouseX;
	Root.Console.MouseY = fMouseY;
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.Style = 1;
	DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, WinHeight, 0.0000000, 0.0000000, WinWidth, WinHeight, m_TBackGround);
	DrawLaptopFrame(C);
	return;
}

function DrawLaptopFrame(Canvas C)
{
	C.Style = 5;
	DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, 256.0000000, 480.0000000, 0.0000000, 0.0000000, 256.0000000, 480.0000000, Texture'R6MenuTextures.Gui_00L');
	DrawStretchedTextureSegment(C, 256.0000000, 0.0000000, 128.0000000, 480.0000000, 0.0000000, 0.0000000, 128.0000000, 480.0000000, Texture'R6MenuTextures.GUI_00C_a00');
	DrawStretchedTextureSegment(C, 384.0000000, 0.0000000, 256.0000000, 480.0000000, 0.0000000, 0.0000000, 256.0000000, 480.0000000, Texture'R6MenuTextures.Gui_00R');
	return;
}

defaultproperties
{
	m_fLaptopPadding=2.0000000
	m_TBackGround=Texture'R6MenuTextures.LaptopTileBG'
	m_RBackGround=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=59426,ZoneNumber=0)
}
