//=============================================================================
// R6Reticule - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6Reticule.uc : Base class of R6 reticules
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/02 * Aristomenis Kolokathis	- Creation
//    2001/08/26 * Eric Begin				- New reticule system
//=============================================================================
class R6Reticule extends Actor
    abstract
    native
    config(User)
    notplaceable;

// Those variables are use to place the non-functionnal (Fixed) part of the reticule
var() int m_iNonFunctionnalX;
var() int m_iNonFunctionnalY;
var bool m_bIdentifyCharacter;
var bool m_bAimingAtFriendly;
var bool m_bShowNames;
var float m_fAccuracy;  // accuracy adjustement: only used for to modifie the view
var float m_fZoomScale;  // the scale to apply when zooming (helmet camera)
var float m_fReticuleOffsetX;
var float m_fReticuleOffsetY;
var Font m_SmallFont_14pt;
var config Color m_color;
var string m_CharacterName;

// Speed gives us the current speed.
simulated function PostRender(Canvas C)
{
	m_iNonFunctionnalX = int(C.HalfClipX);
	m_iNonFunctionnalY = int(C.HalfClipY);
	C.SetDrawColor(m_color.R, m_color.G, m_color.B);
	C.SetPos(float(m_iNonFunctionnalX), float(m_iNonFunctionnalY));
	C.DrawText("(NO RETICULE)");
	return;
}

simulated function SetReticuleInfo(Canvas C)
{
	local Color aColor;
	local R6GameOptions GameOptions;

	C.SetDrawColor(m_color.R, m_color.G, m_color.B);
	GameOptions = GetGameOptions();
	// End:0x7A
	if(m_bAimingAtFriendly)
	{
		aColor = GameOptions.m_reticuleFriendColour;
		C.SetDrawColor(aColor.R, aColor.G, aColor.B);
	}
	return;
}

simulated function SetIdentificationReticule(Canvas C)
{
	local float fStrSizeX, fStrSizeY;
	local int X, Y;

	// End:0xC2
	if((m_bIdentifyCharacter && m_bShowNames))
	{
		C.UseVirtualSize(true, 640.0000000, 480.0000000);
		X = int(C.HalfClipX);
		Y = int(C.HalfClipY);
		C.Font = m_SmallFont_14pt;
		C.StrLen(m_CharacterName, fStrSizeX, fStrSizeY);
		C.SetPos((float(X) - (fStrSizeX / float(2))), float((Y + 24)));
		C.DrawText(m_CharacterName);
	}
	return;
}

defaultproperties
{
	m_fZoomScale=1.0000000
	m_SmallFont_14pt=Font'R6Font.Rainbow6_14pt'
	m_color=(R=255,G=0,B=0,A=0)
	RemoteRole=0
	bHidden=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function UpdateReticule
