//=============================================================================
// R6MenuInGameInstructionWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuInGameInstructionWidget.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6MenuInGameInstructionWidget extends R6MenuWidget;

var int m_iArrayHudStep[3];
var bool bIsChangingText;
var float m_fYInstructionTextPos;
var R6WindowSimpleFramedWindow m_InstructionText;
var R6InstructionSoundVolume m_pLastIntructionVolume;
var Region m_RMsgSize;
var string m_szText;

function Created()
{
	local R6WindowWrappedTextArea TextArea;

	m_InstructionText = R6WindowSimpleFramedWindow(CreateWindow(Class'R6Window.R6WindowSimpleFramedWindow', 100.0000000, m_fYInstructionTextPos, 440.0000000, 100.0000000, self));
	m_InstructionText.CreateClientWindow(Class'R6Window.R6WindowWrappedTextArea');
	TextArea = R6WindowWrappedTextArea(m_InstructionText.m_ClientArea);
	TextArea.m_HBorderTexture = none;
	TextArea.m_VBorderTexture = none;
	TextArea.SetAbsoluteFont(Root.Fonts[16]);
	TextArea.m_bUseBGTexture = true;
	TextArea.m_bUseBGColor = true;
	m_InstructionText.m_eCornerType = 3;
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float fHeight, fWidth;
	local int iNbLines;
	local R6WindowWrappedTextArea TextArea;

	// End:0x13B
	if(bIsChangingText)
	{
		bIsChangingText = false;
		TextArea = R6WindowWrappedTextArea(m_InstructionText.m_ClientArea);
		TextArea.BeforePaint(C, X, Y);
		C.Font = Root.Fonts[16];
		TextSize(C, "TEST", fWidth, fHeight);
		iNbLines = int(__NFUN_172__(TextArea.m_fYOffSet, fHeight));
		__NFUN_161__(iNbLines, 1);
		__NFUN_161__(iNbLines, TextArea.Lines);
		m_RMsgSize.H = int(__NFUN_171__(fHeight, float(iNbLines)));
		m_InstructionText.WinHeight = __NFUN_174__(__NFUN_174__(float(m_RMsgSize.H), __NFUN_171__(float(2), m_InstructionText.m_fHBorderHeight)), __NFUN_171__(float(2), m_InstructionText.m_fHBorderOffset));
		TextArea.WinHeight = float(m_RMsgSize.H);
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.Style = 5;
	C.__NFUN_2626__(Root.Colors.Black.R, Root.Colors.Black.G, Root.Colors.Black.B, 128);
	DrawStretchedTextureSegment(C, m_InstructionText.WinLeft, m_InstructionText.WinTop, m_InstructionText.WinWidth, m_InstructionText.WinHeight, 0.0000000, 0.0000000, 10.0000000, 10.0000000, Texture'UWindow.WhiteTexture');
	return;
}

function ChangeText(R6InstructionSoundVolume pISV, int iBox, int iParagraph)
{
	local string szParagraphID, szSectionID;
	local R6WindowWrappedTextArea TextArea;

	// End:0x2B
	if(__NFUN_130__(__NFUN_119__(m_pLastIntructionVolume, none), __NFUN_119__(m_pLastIntructionVolume, pISV)))
	{
		m_pLastIntructionVolume.StopInstruction();
	}
	m_pLastIntructionVolume = pISV;
	switch(iParagraph)
	{
		// End:0x51
		case 0:
			szParagraphID = "TextA";
			// End:0x92
			break;
		// End:0x65
		case 1:
			szParagraphID = "TextB";
			// End:0x92
			break;
		// End:0x7A
		case 2:
			szParagraphID = "TextC";
			// End:0x92
			break;
		// End:0x8F
		case 3:
			szParagraphID = "TextD";
			// End:0x92
			break;
		// End:0xFFFF
		default:
			break;
	}
	switch(iBox)
	{
		// End:0xB5
		case 1:
			szSectionID = "BasicAreaBox1";
			// End:0x40A
			break;
		// End:0xD2
		case 2:
			szSectionID = "BasicAreaBox2";
			// End:0x40A
			break;
		// End:0xEF
		case 3:
			szSectionID = "BasicAreaBox3";
			// End:0x40A
			break;
		// End:0x10C
		case 4:
			szSectionID = "BasicAreaBox4";
			// End:0x40A
			break;
		// End:0x129
		case 5:
			szSectionID = "BasicAreaBox5";
			// End:0x40A
			break;
		// End:0x146
		case 6:
			szSectionID = "BasicAreaBox6";
			// End:0x40A
			break;
		// End:0x163
		case 7:
			szSectionID = "BasicAreaBox7";
			// End:0x40A
			break;
		// End:0x183
		case 8:
			szSectionID = "ShootingAreaBox1";
			// End:0x40A
			break;
		// End:0x1A3
		case 9:
			szSectionID = "ShootingAreaBox2";
			// End:0x40A
			break;
		// End:0x1C3
		case 10:
			szSectionID = "ShootingAreaBox3";
			// End:0x40A
			break;
		// End:0x1E3
		case 11:
			szSectionID = "ShootingAreaBox4";
			// End:0x40A
			break;
		// End:0x203
		case 12:
			szSectionID = "ShootingAreaBox5";
			// End:0x40A
			break;
		// End:0x223
		case 13:
			szSectionID = "ShootingAreaBox6";
			// End:0x40A
			break;
		// End:0x243
		case 14:
			szSectionID = "ShootingAreaBox7";
			// End:0x40A
			break;
		// End:0x263
		case 15:
			szSectionID = "ShootingAreaBox8";
			// End:0x40A
			break;
		// End:0x284
		case 16:
			szSectionID = "ExplodingAreaBox1";
			// End:0x40A
			break;
		// End:0x2A5
		case 17:
			szSectionID = "ExplodingAreaBox2";
			// End:0x40A
			break;
		// End:0x2C6
		case 18:
			szSectionID = "ExplodingAreaBox3";
			// End:0x40A
			break;
		// End:0x2E7
		case 19:
			szSectionID = "ExplodingAreaBox4";
			// End:0x40A
			break;
		// End:0x308
		case 20:
			szSectionID = "ExplodingAreaBox5";
			// End:0x40A
			break;
		// End:0x329
		case 21:
			szSectionID = "RoomClearing1Box1";
			// End:0x40A
			break;
		// End:0x34A
		case 22:
			szSectionID = "RoomClearing1Box2";
			// End:0x40A
			break;
		// End:0x36B
		case 23:
			szSectionID = "RoomClearing1Box3";
			// End:0x40A
			break;
		// End:0x38C
		case 24:
			szSectionID = "RoomClearing2Box1";
			// End:0x40A
			break;
		// End:0x3AD
		case 25:
			szSectionID = "RoomClearing3Box1";
			// End:0x40A
			break;
		// End:0x3CB
		case 26:
			szSectionID = "HostageRescue1";
			// End:0x40A
			break;
		// End:0x3E9
		case 27:
			szSectionID = "HostageRescue2";
			// End:0x40A
			break;
		// End:0x407
		case 28:
			szSectionID = "HostageRescue3";
			// End:0x40A
			break;
		// End:0xFFFF
		default:
			break;
	}
	m_szText = R6PlayerController(GetPlayerOwner()).__NFUN_2724__(szSectionID, szParagraphID, "R6Training", iBox, iParagraph);
	TextArea = R6WindowWrappedTextArea(m_InstructionText.m_ClientArea);
	TextArea.Clear();
	TextArea.m_fYOffSet = 10.0000000;
	TextArea.m_fXOffSet = 15.0000000;
	TextArea.AddText(m_szText, Root.Colors.White, Root.Fonts[16]);
	TextArea.SetScrollable(false);
	bIsChangingText = true;
	return;
}

function WindowEvent(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	local float fBkpOrgY;

	// End:0x42
	if(__NFUN_130__(__NFUN_154__(int(Msg), int(8)), __NFUN_154__(Key, int(GetPlayerOwner().__NFUN_2706__("Action")))))
	{
		m_pLastIntructionVolume.SkipToNextInstruction();
	}
	// End:0xDF
	if(__NFUN_154__(int(Msg), int(11)))
	{
		fBkpOrgY = C.OrgY;
		C.OrgY = 0.0000000;
		m_InstructionText.WinTop = __NFUN_171__(__NFUN_172__(float(C.SizeY), float(480)), m_fYInstructionTextPos);
		super(UWindowWindow).WindowEvent(Msg, C, X, Y, Key);
		C.OrgY = fBkpOrgY;		
	}
	else
	{
		super(UWindowWindow).WindowEvent(Msg, C, X, Y, Key);
	}
	return;
}

function ResolutionChanged(float W, float H)
{
	WinWidth = W;
	WinHeight = H;
	super(UWindowWindow).ResolutionChanged(W, H);
	return;
}

defaultproperties
{
	m_fYInstructionTextPos=35.0000000
	m_RMsgSize=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=2594,ZoneNumber=0)
}
