//=============================================================================
// R6IOAlarmSystem - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6IODevice : This should allow action moves on a Recon type device
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6IOAlarmSystem extends R6IODevice
    placeable;

var(R6ActionObject) Material m_DisarmedTexture;
var(R6ActionObject) Sound m_DisarmingSound;

simulated function string R6GetCircumstantialActionString(int iAction)
{
	switch(iAction)
	{
		// End:0x3B
		case int(1):
			return Localize("RDVOrder", "Order_DisarmSystem", "R6Menu");
		// End:0xFFFF
		default:
			return "";
			break;
	}
	return;
}

simulated function ToggleDevice(R6Pawn aPawn)
{
	local int iAlarmCount;

	// End:0x0E
	if((CanToggle() == false))
	{
		return;
	}
	// End:0x66
	if(bShowLog)
	{
		Log(((((("Set Device" @ string(self)) @ "by pawn") @ string(aPawn)) @ "and his controller") @ string(aPawn.Controller)));
	}
	m_bIsActivated = false;
	// End:0x85
	if((m_DisarmedTexture != none))
	{
		SetSkin(m_DisarmedTexture, 0);
	}
	__NFUN_264__(m_DisarmingSound, 3) /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/;
	m_bToggleType = false;
	R6AbstractGameInfo(Level.Game).IObjectInteract(aPawn, self);
	return;
}

