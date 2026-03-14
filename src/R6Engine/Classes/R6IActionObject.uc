//=============================================================================
// R6IActionObject - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6IActionObject : This class should be subclassed in order to create object
//					  that can be manipulated with the action mode
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/10 * Created by Alexandre Dionne
//    2001/11/26 * Merged with interactive objects - Jean-Francois Dube
//=============================================================================
class R6IActionObject extends R6InteractiveObject
	abstract
	native
 placeable;

var float m_fMinMouseMove;  // Min mouse value we take from the input
var float m_fMaxMouseMove;  // Max mouse value we take from the input
var Actor m_ActionInstigator;  // The pawn doing the action

function bool startAction(float deltaMouse, Actor actionInstigator)
{
	return;
}

function bool updateAction(float deltaMouse, Actor actionInstigator)
{
	return;
}

function endAction()
{
	return;
}

defaultproperties
{
	m_fMinMouseMove=1.0000000
	m_fMaxMouseMove=250.0000000
	m_bBlockCoronas=true
	Physics=5
	m_bHandleRelativeProjectors=true
	bSkipActorPropertyReplication=false
}
