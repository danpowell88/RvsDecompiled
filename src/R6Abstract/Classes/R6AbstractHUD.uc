//=============================================================================
// R6AbstractHUD - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6AstractHUD.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/16 * Created by Guillaume Borgia
//=============================================================================
class R6AbstractHUD extends HUD
    abstract
    native;

var int m_iCycleHUDLayer;
var bool m_bToggleHelmet;
var bool m_bGetRes;
// HUD resolution
var float m_fNewHUDResX;
var float m_fNewHUDResY;
var string m_szStatusDetail;  // this string is displayed 5 sec.

function PostRender(Canvas C)
{
	// End:0x48
	if(((m_fNewHUDResX > float(0)) && (m_fNewHUDResY > float(0))))
	{
		C.SetVirtualSize(m_fNewHUDResX, m_fNewHUDResY);
		m_fNewHUDResX = 0.0000000;
		m_fNewHUDResY = 0.0000000;
	}
	// End:0x94
	if(m_bGetRes)
	{
		PlayerController(Owner).ClientMessage(((string(C.SizeX) @ "x") @ string(C.SizeY)));
		m_bGetRes = false;
	}
	super.PostRender(C);
	return;
}

//===========================================================================//
// DrawTextCenteredInBox()                                                   //
//===========================================================================//
function DrawTextCenteredInBox(Canvas C, string strText, float fPosX, float fPosY, float fWidth, float fHeight)
{
	local float fTextWidth, fTextHeight;
	local bool bBackCenter;
	local float fBackOrgX, fBackOrgY, fBackClipX, fBackClipY;

	bBackCenter = C.bCenter;
	fBackOrgX = C.OrgX;
	fBackOrgY = C.OrgY;
	fBackClipX = C.ClipX;
	fBackClipY = C.ClipY;
	C.bCenter = true;
	C.OrgX = fPosX;
	C.OrgY = fPosY;
	C.ClipX = fWidth;
	C.ClipY = fHeight;
	C.StrLen(strText, fTextWidth, fTextHeight);
	C.SetPos(0.0000000, ((fHeight - fTextHeight) / 2.0000000));
	C.DrawText(strText);
	C.bCenter = bBackCenter;
	C.OrgX = fBackOrgX;
	C.OrgY = fBackOrgY;
	C.ClipX = fBackClipX;
	C.ClipY = fBackClipY;
	return;
}

//===========================================================================//
// DrawTexturePart()                                                         //
//===========================================================================//
function DrawTexturePart(Canvas C, Texture Tex, float fUStart, float fVStart, float fSizeX, float fSizeY)
{
	C.DrawTile(Tex, fSizeX, fSizeY, fUStart, fVStart, fSizeX, fSizeY);
	return;
}

//===========================================================================//
// HUDRes()                                                                  //
//  Change HUD resolution to make it appear bigger or smaller on screen.     //
//===========================================================================//
exec function HUDRes(string strRes)
{
	local int iPos, X, Y;

	iPos = InStr(strRes, "x");
	X = int(Left(strRes, iPos));
	Y = int(Mid(strRes, (iPos + 1)));
	// End:0x6D
	if(((X > 0) && (Y > 0)))
	{
		m_fNewHUDResX = float(X);
		m_fNewHUDResY = float(Y);
	}
	return;
}

//===========================================================================//
// GetRes()                                                                  //
//  Display current resolution.                                              //
//===========================================================================//
exec function GetRes()
{
	m_bGetRes = true;
	return;
}

//===========================================================================//
// GetGoCodeStr()                                                            //
//===========================================================================//
function string GetGoCodeStr(Object.EGoCode goCode)
{
	switch(goCode)
	{
		// End:0x10
		case 0:
			return "A";
		// End:0x19
		case 1:
			return "B";
		// End:0x22
		case 2:
			return "C";
		// End:0x2B
		case 3:
			return "D";
		// End:0xFFFF
		default:
			return "";
			break;
	}
	return;
}

exec function ToggleHelmet()
{
	m_bToggleHelmet = (!m_bToggleHelmet);
	return;
}

exec function CycleHUDLayer()
{
	(m_iCycleHUDLayer++);
	// End:0x1A
	if((m_iCycleHUDLayer == 4))
	{
		m_iCycleHUDLayer = 0;
	}
	return;
}

function StartFadeToBlack(int iSec, int iPercentageOfBlack)
{
	return;
}

function StopFadeToBlack()
{
	return;
}

function UpdateHudFilter()
{
	return;
}

function ActivateNoDeathCameraMsg(bool bToggleOn)
{
	return;
}

