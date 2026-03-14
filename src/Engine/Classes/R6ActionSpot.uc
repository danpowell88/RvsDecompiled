//=============================================================================
// R6ActionSpot - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6ActionSpot.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/13 * Created by Guillaume Borgia
//=============================================================================
class R6ActionSpot extends Actor
    native
    placeable;

var() Actor.EStance m_eCover;
var() Actor.EStance m_eFire;
var int m_iLastInvestigateID;
var bool m_bValidTarget;
var() bool m_bInvestigate;
var NavigationPoint m_Anchor;
var Pawn m_pCurrentUser;
var R6ActionSpot m_NextSpot;

simulated function FirstPassReset()
{
	m_pCurrentUser = none;
	return;
}

defaultproperties
{
	m_bInvestigate=true
	bStatic=true
	bHidden=true
	bCollideWhenPlacing=true
	bDirectional=true
	CollisionRadius=80.0000000
	CollisionHeight=135.0000000
	Texture=Texture'Engine.ASBase'
}
