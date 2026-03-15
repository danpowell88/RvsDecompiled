//=============================================================================
// R6WindowOperativePlanningSummary - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowOperativePlanningSummary.uc : Small window summerizing an operative
//                                        planning result for the execute screen
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/13 * Created by Alexandre Dionne
//=============================================================================
class R6WindowOperativePlanningSummary extends UWindowWindow;

var byte m_BAlphaOpNameBg;
var byte m_BSelectedAlphaOpNameBg;
var byte m_BCurrentAlpha;
var byte m_BAlphaBg;
var int m_IXSpecialityOffset;
// NEW IN 1.60
var int m_IXHealthOffset;
// NEW IN 1.60
var int m_IYIconPos;
// NEW IN 1.60
var int m_IHealthWidth;
// NEW IN 1.60
var int m_IHealthHeight;
// NEW IN 1.60
var int m_ISpecialityWidth;
// NEW IN 1.60
var int m_ISpecialityHeight;
var bool m_bIsSelected;
var float m_fFaceWidth;
// NEW IN 1.60
var float m_FaceHeight;
// NEW IN 1.60
var float m_fNameLabelHeight;
var R6WindowBitMap m_OperativeFace;
var R6WindowBitMap m_BMPSpeciality;
var R6WindowBitMap m_BMPHealth;
var R6WindowTextLabel m_PrimaryWeapon;
// NEW IN 1.60
var R6WindowTextLabel m_Armor;
// NEW IN 1.60
var R6WindowTextLabel m_OperativeName;
var Texture m_TBottomLabelBG;
var Region m_RBottomLabelBG;
var Color m_LabelColor;
var Color m_CDarkColor;

function Created()
{
	local float fLabelHeight;

	m_OperativeFace = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.W), m_fFaceWidth, m_FaceHeight, self));
	m_BMPSpeciality = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', (m_FaceHeight + float(m_IXSpecialityOffset)), float(m_IYIconPos), float(m_ISpecialityWidth), float(m_ISpecialityHeight), self));
	m_BMPSpeciality.m_iDrawStyle = int(5);
	m_BMPHealth = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', ((m_BMPSpeciality.WinLeft + m_BMPSpeciality.WinWidth) + float(m_IXHealthOffset)), float(m_IYIconPos), float(m_IHealthWidth), float(m_IHealthHeight), self));
	m_BMPHealth.m_iDrawStyle = int(5);
	m_OperativeName = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', (m_BMPHealth.WinLeft + m_BMPHealth.WinWidth), 0.0000000, ((WinWidth - m_BMPHealth.WinLeft) - m_BMPHealth.WinWidth), m_fNameLabelHeight, self));
	m_OperativeName.m_bDrawBorders = false;
	m_OperativeName.Align = 2;
	m_OperativeName.TextColor = Root.Colors.White;
	m_OperativeName.m_Font = Root.Fonts[5];
	m_OperativeName.m_BGTexture = none;
	fLabelHeight = ((WinHeight - m_OperativeName.WinHeight) / float(2));
	m_PrimaryWeapon = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', (m_OperativeFace.WinLeft + m_fFaceWidth), (m_OperativeName.WinTop + m_OperativeName.WinHeight), m_OperativeName.WinWidth, fLabelHeight, self));
	m_PrimaryWeapon.m_bDrawBorders = false;
	m_PrimaryWeapon.Align = 0;
	m_PrimaryWeapon.TextColor = Root.Colors.White;
	m_PrimaryWeapon.m_Font = Root.Fonts[6];
	m_PrimaryWeapon.m_BGTexture = none;
	m_PrimaryWeapon.m_fLMarge = 4.0000000;
	m_PrimaryWeapon.m_bFixedYPos = true;
	m_PrimaryWeapon.TextY = 1.0000000;
	m_Armor = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_PrimaryWeapon.WinLeft, (m_PrimaryWeapon.WinTop + m_PrimaryWeapon.WinHeight), m_OperativeName.WinWidth, fLabelHeight, self));
	m_Armor.m_bDrawBorders = false;
	m_Armor.Align = 0;
	m_Armor.TextColor = Root.Colors.White;
	m_Armor.m_Font = Root.Fonts[6];
	m_Armor.m_BGTexture = none;
	m_Armor.m_fLMarge = m_PrimaryWeapon.m_fLMarge;
	m_Armor.m_bFixedYPos = true;
	m_BCurrentAlpha = m_BAlphaOpNameBg;
	return;
}

function setHealth(TexRegion _T)
{
	m_BMPHealth.t = _T.t;
	m_BMPHealth.R.X = _T.X;
	m_BMPHealth.R.Y = _T.Y;
	m_BMPHealth.R.W = _T.H;
	m_BMPHealth.R.H = _T.W;
	return;
}

function setSpeciality(TexRegion _T)
{
	m_BMPSpeciality.t = _T.t;
	m_BMPSpeciality.R.X = _T.X;
	m_BMPSpeciality.R.Y = _T.Y;
	m_BMPSpeciality.R.W = _T.H;
	m_BMPSpeciality.R.H = _T.W;
	return;
}

function setFace(Texture _T, Region _R)
{
	m_OperativeFace.t = _T;
	m_OperativeFace.R = _R;
	return;
}

function setLabels(string szPrimaryWeapon, string szArmor, string szOperativeName)
{
	m_PrimaryWeapon.SetNewText(szPrimaryWeapon, true);
	m_Armor.SetNewText(szArmor, true);
	m_OperativeName.SetNewText(szOperativeName, true);
	return;
}

function SetColor(Color _LabelColor, Color _DarkColor)
{
	m_BorderColor = _LabelColor;
	m_LabelColor = _LabelColor;
	m_CDarkColor = _DarkColor;
	m_BMPSpeciality.m_TextureColor = _LabelColor;
	m_BMPHealth.m_TextureColor = _LabelColor;
	SetSelected(m_bIsSelected);
	return;
}

function SetSelected(bool _IsSelected)
{
	// End:0x89
	if(_IsSelected)
	{
		m_OperativeName.TextColor = Root.Colors.White;
		m_PrimaryWeapon.TextColor = Root.Colors.White;
		m_Armor.TextColor = Root.Colors.White;
		m_BCurrentAlpha = m_BSelectedAlphaOpNameBg;		
	}
	else
	{
		m_OperativeName.TextColor = m_LabelColor;
		m_PrimaryWeapon.TextColor = m_LabelColor;
		m_Armor.TextColor = m_LabelColor;
		m_BCurrentAlpha = m_BAlphaOpNameBg;
	}
	m_BMPSpeciality.m_bUseColor = (!_IsSelected);
	m_BMPHealth.m_bUseColor = (!_IsSelected);
	m_bIsSelected = _IsSelected;
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.Style = 5;
	C.SetDrawColor(m_LabelColor.R, m_LabelColor.G, m_LabelColor.B, m_BCurrentAlpha);
	DrawStretchedTexture(C, (m_OperativeFace.WinLeft + m_fFaceWidth), 0.0000000, ((WinWidth - m_fFaceWidth) - m_OperativeFace.WinLeft), m_OperativeName.WinHeight, m_TBottomLabelBG);
	C.SetDrawColor(m_CDarkColor.R, m_CDarkColor.G, m_CDarkColor.B, m_BAlphaBg);
	DrawStretchedTexture(C, (m_OperativeFace.WinLeft + m_fFaceWidth), m_OperativeName.WinHeight, ((WinWidth - m_fFaceWidth) - m_OperativeFace.WinLeft), (WinHeight - m_OperativeName.WinHeight), m_TBottomLabelBG);
	return;
}

function AfterPaint(Canvas C, float X, float Y)
{
	C.Style = 1;
	C.SetDrawColor(m_LabelColor.R, m_LabelColor.G, m_LabelColor.B, m_LabelColor.A);
	DrawStretchedTexture(C, (m_OperativeFace.WinLeft + m_fFaceWidth), 0.0000000, 1.0000000, WinHeight, m_TBottomLabelBG);
	DrawStretchedTexture(C, (m_OperativeFace.WinLeft + m_fFaceWidth), m_fNameLabelHeight, ((WinWidth - m_fFaceWidth) - m_OperativeFace.WinLeft), 1.0000000, m_TBottomLabelBG);
	DrawSimpleBorder(C);
	return;
}

defaultproperties
{
	m_BAlphaOpNameBg=77
	m_BSelectedAlphaOpNameBg=128
	m_BAlphaBg=128
	m_IXSpecialityOffset=1
	m_IXHealthOffset=3
	m_IYIconPos=4
	m_IHealthWidth=10
	m_IHealthHeight=10
	m_ISpecialityWidth=9
	m_ISpecialityHeight=9
	m_fFaceWidth=38.0000000
	m_FaceHeight=42.0000000
	m_fNameLabelHeight=17.0000000
	m_TBottomLabelBG=Texture'UWindow.WhiteTexture'
	m_RBottomLabelBG=(Zone=StructProperty'R6Window.R6WindowSimpleFramedWindow.m_topLeftCornerR',iLeaf=2594,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var r
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var h
