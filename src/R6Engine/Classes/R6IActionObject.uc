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
    native
    abstract;

// --- Variables ---
//The pawn doing the action
var Actor m_ActionInstigator;
//Max mouse value we take from the input
var float m_fMaxMouseMove;
//Min mouse value we take from the input
var float m_fMinMouseMove;

// --- Functions ---
function bool updateAction(float deltaMouse, Actor actionInstigator) {}
// ^ NEW IN 1.60
function bool startAction(float deltaMouse, Actor actionInstigator) {}
// ^ NEW IN 1.60
function endAction() {}

defaultproperties
{
}
