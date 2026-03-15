//=============================================================================
// R6MenuInGameWritableMapWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuInGameWritableMapWidget.uc : Game Main Menu
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2002/04/05 * Created by Hugo Allaire
//=============================================================================
class R6MenuInGameWritableMapWidget extends R6MenuWidget;

var const int c_iNbOfIcons;
var bool m_bIsDrawing;
var R6ColorPicker m_cColorPicker;
var R6WindowRadioButton m_Icons[16];
var R6WindowRadioButton m_CurrentSelectedIcon;

function Created()
{
	local int iIconsCount, iPosX;
	local Region ButtonRegion;

	m_cColorPicker = R6ColorPicker(CreateWindow(Class'R6Menu.R6ColorPicker', 10.0000000, 190.0000000, 40.0000000, 100.0000000, self));
	iIconsCount = 0;
	J0x32:

	// End:0x28F [Loop If]
	if((iIconsCount < c_iNbOfIcons))
	{
		// End:0x70
		if((iIconsCount < 8))
		{
			ButtonRegion.X = (iIconsCount * 64);
			ButtonRegion.Y = 0;			
		}
		else
		{
			ButtonRegion.X = ((iIconsCount - 8) * 64);
			ButtonRegion.Y = 192;
		}
		ButtonRegion.W = 64;
		ButtonRegion.H = 64;
		iPosX = (34 + (iIconsCount * (32 + 4)));
		m_Icons[iIconsCount] = R6WindowRadioButton(CreateControl(Class'R6Window.R6WindowRadioButton', float(iPosX), (WinHeight - float(48)), 32.0000000, 32.0000000, self));
		m_Icons[iIconsCount].RegionScale = 0.5000000;
		m_Icons[iIconsCount].bUseRegion = true;
		m_Icons[iIconsCount].UpRegion = ButtonRegion;
		m_Icons[iIconsCount].UpTexture = Texture'R6WritableMapIcons.R6WritableMapIcons';
		m_Icons[iIconsCount].bCenter = false;
		m_Icons[iIconsCount].m_iDrawStyle = int(5);
		m_Icons[iIconsCount].m_bDrawBorders = false;
		// End:0x1C7
		if((iIconsCount < 8))
		{
			ButtonRegion.Y = 64;			
		}
		else
		{
			ButtonRegion.Y = 256;
		}
		m_Icons[iIconsCount].OverRegion = ButtonRegion;
		m_Icons[iIconsCount].OverTexture = Texture'R6WritableMapIcons.R6WritableMapIcons';
		// End:0x227
		if((iIconsCount < 8))
		{
			ButtonRegion.Y = 128;			
		}
		else
		{
			ButtonRegion.Y = 320;
		}
		m_Icons[iIconsCount].DownRegion = ButtonRegion;
		m_Icons[iIconsCount].DownTexture = Texture'R6WritableMapIcons.R6WritableMapIcons';
		m_Icons[iIconsCount].m_iButtonID = iIconsCount;
		(iIconsCount++);
		// [Loop Continue]
		goto J0x32;
	}
	m_CurrentSelectedIcon = m_Icons[0];
	m_CurrentSelectedIcon.m_bSelected = true;
	Class'Engine.Actor'.static.GetCanvas().m_pWritableMapIconsTexture = Texture'R6WritableMapIcons.R6WritableMapIcons';
	return;
}

function SendLineToTeam()
{
	local string Msg;
	local int i;
	local float X, Y;
	local Color C;
	local LevelInfo pLevel;

	C = m_cColorPicker.GetSelectedColor();
	i = 0;
	// End:0x38
	if((int(C.R) == 255))
	{
		(i += 2);
	}
	// End:0x54
	if((int(C.G) == 255))
	{
		(i += 4);
	}
	// End:0x70
	if((int(C.B) == 255))
	{
		(i += 8);
	}
	Msg = Chr(i);
	pLevel = GetLevel();
	// End:0x152
	if((pLevel.m_aCurrentStrip.Length > 2))
	{
		i = 0;
		J0xA6:

		// End:0x11C [Loop If]
		if((i < pLevel.m_aCurrentStrip.Length))
		{
			Msg = ((Msg $ Chr(int(pLevel.m_aCurrentStrip[i].Position.X))) $ Chr(int(pLevel.m_aCurrentStrip[i].Position.Y)));
			(i++);
			// [Loop Continue]
			goto J0xA6;
		}
		pLevel.AddEncodedWritableMapStrip(Msg);
		R6PlayerController(GetPlayerOwner()).ServerBroadcast(GetPlayerOwner(), Msg, 'Line');
	}
	pLevel.m_aCurrentStrip.Remove(0, pLevel.m_aCurrentStrip.Length);
	return;
}

function MouseLeave()
{
	super(UWindowWindow).MouseLeave();
	m_bIsDrawing = false;
	SendLineToTeam();
	return;
}

function RMouseDown(float X, float Y)
{
	local string szMsg;
	local Color C;
	local int iColorIndex;

	// End:0x45
	if(((((X < float(60)) || (X > float(640))) || (Y < float(0))) || (Y > float(416))))
	{
		return;
	}
	C = m_cColorPicker.GetSelectedColor();
	iColorIndex = 0;
	// End:0x7D
	if((int(C.R) == 255))
	{
		(iColorIndex += 2);
	}
	// End:0x99
	if((int(C.G) == 255))
	{
		(iColorIndex += 4);
	}
	// End:0xB5
	if((int(C.B) == 255))
	{
		(iColorIndex += 8);
	}
	super(UWindowWindow).RMouseDown(X, Y);
	szMsg = ((((((string(X) $ " ") $ string(Y)) $ " ") $ string(m_CurrentSelectedIcon.m_iButtonID)) $ " ") $ string(iColorIndex));
	Log(szMsg);
	R6PlayerController(GetPlayerOwner()).ServerBroadcast(GetPlayerOwner(), szMsg, 'Icon');
	return;
}

function LMouseDown(float X, float Y)
{
	super(UWindowWindow).LMouseDown(X, Y);
	// End:0x5B
	if(((((X >= float(60)) && (X < float(640))) && (Y >= float(0))) && (Y < float(480))))
	{
		m_bIsDrawing = true;
	}
	return;
}

function LMouseUp(float X, float Y)
{
	super(UWindowWindow).LMouseUp(X, Y);
	// End:0x27
	if(m_bIsDrawing)
	{
		m_bIsDrawing = false;
		SendLineToTeam();
	}
	return;
}

function MouseMove(float X, float Y)
{
	local float tX, tY;
	local Vector V;

	super(UWindowWindow).MouseMove(X, Y);
	// End:0x9F
	if(m_bIsDrawing)
	{
		ParentWindow.GetMouseXY(tX, tY);
		V.X = ((tX - 60.0000000) / (640.0000000 - 60.0000000));
		V.Y = (tY / 480.0000000);
		V.Z = 0.0000000;
		GetLevel().AddWritableMapPoint(V, m_cColorPicker.GetSelectedColor());
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local int USize, VSize;
	local Texture mapTexture;

	super(UWindowWindow).Paint(C, X, Y);
	C.SetPos(0.0000000, 0.0000000);
	C.DrawRect(Texture'Color.Color.Black', 640.0000000, 480.0000000);
	mapTexture = GetLevel().m_tWritableMapTexture;
	// End:0xA3
	if((mapTexture != none))
	{
		C.SetPos(60.0000000, 0.0000000);
		C.DrawRect(mapTexture, (640.0000000 - float(60)), 480.0000000);
	}
	C.DrawWritableMap(GetLevel());
	return;
}

function Notify(UWindowDialogControl Button, byte Msg)
{
	switch(Msg)
	{
		// End:0x51
		case 2:
			// End:0x4E
			if((R6WindowRadioButton(Button) != none))
			{
				m_CurrentSelectedIcon.m_bSelected = false;
				m_CurrentSelectedIcon = R6WindowRadioButton(Button);
				m_CurrentSelectedIcon.m_bSelected = true;
			}
			// End:0x54
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function ShowWindow()
{
	super(UWindowWindow).ShowWindow();
	Root.m_bScaleWindowToRoot = true;
	return;
}

function HideWindow()
{
	super(UWindowWindow).HideWindow();
	Root.m_bScaleWindowToRoot = false;
	return;
}

defaultproperties
{
	c_iNbOfIcons=16
}
