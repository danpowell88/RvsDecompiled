//=============================================================================
// R6WindowLookAndFeel - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowLookAndFeel.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowLookAndFeel extends UWindowLookAndFeel;

var int m_iCloseBoxOffsetX;
var int m_iCloseBoxOffsetY;
var int m_iListHPadding;
// NEW IN 1.60
var int m_iListVPadding;
var int m_iSize_ScrollBarFrameW;
var int m_iVScrollerWidth;
// NEW IN 1.60
var int m_iScrollerOffset;
var Texture m_R6ScrollTexture;
//CheckBox and Radio Buttons
var Texture m_TButtonBackGround;
var RegionButton m_SBUp;
var RegionButton m_SBDown;
var RegionButton m_SBRight;
var RegionButton m_SBLeft;
var Region m_SBBackground;
var Region m_SBVBorder;
var Region m_SBHBorder;
var Region m_SBScroller;
var Region m_CloseBoxUp;
var Region m_CloseBoxDown;
var Region m_RButtonBackGround;
var Color m_CBorder;

function List_DrawBackground(UWindowListControl W, Canvas C)
{
	return;
}

function R6List_DrawBackground(R6WindowListBox W, Canvas C)
{
	return;
}

function DrawWinTop(R6WindowHSplitter W, Canvas C)
{
	return;
}

function DrawHSplitterT(R6WindowHSplitter W, Canvas C)
{
	return;
}

function DrawHSplitterB(R6WindowHSplitter W, Canvas C)
{
	return;
}

function Texture R6GetTexture(R6WindowFramedWindow W)
{
	return;
}

function R6FW_DrawWindowFrame(R6WindowFramedWindow W, Canvas C)
{
	return;
}

function R6FW_SetupFrameButtons(R6WindowFramedWindow W, Canvas C)
{
	return;
}

function Region R6FW_GetClientArea(R6WindowFramedWindow W)
{
	return;
}

function DrawSpecialButtonBorder(R6WindowButton B, Canvas C, float X, float Y)
{
	return;
}

function DrawButtonBorder(UWindowWindow W, Canvas C, optional bool _bDefineBorderColor)
{
	return;
}

function UWindowBase.FrameHitTest R6FW_HitTest(R6WindowFramedWindow W, float X, float Y)
{
	return;
}

function DrawPopUpFrameWindow(R6WindowPopUpBox W, Canvas C)
{
	return;
}

function Button_SetupEnumSignChoice(UWindowButton W, int eRegionId)
{
	return;
}

function DrawBox(UWindowWindow W, Canvas C, float X, float Y, float Width, float Height)
{
	return;
}

function DrawBGShading(UWindowWindow W, Canvas C, float X, float Y, float Width, float Height)
{
	return;
}

function DrawInGamePlayerStats(UWindowWindow W, Canvas C, int _iPlayerStats, float _fX, float _fY, float _fHeight, float _fWidth)
{
	return;
}

function DrawMPFavoriteIcon(UWindowWindow W, Canvas C, float _fX, float _fY, float _fHeight)
{
	return;
}

function DrawMPLockedIcon(UWindowWindow W, Canvas C, float _fX, float _fY, float _fHeight)
{
	return;
}

function DrawMPDedicatedIcon(UWindowWindow W, Canvas C, float _fX, float _fY, float _fHeight)
{
	return;
}

function DrawMPSpectatorIcon(UWindowWindow W, Canvas C, float _fX, float _fY, float _fHeight)
{
	return;
}

function DrawPopUpTextBackGround(UWindowWindow W, Canvas C, float _fHeight)
{
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var g
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: function R6FW_HitTest
