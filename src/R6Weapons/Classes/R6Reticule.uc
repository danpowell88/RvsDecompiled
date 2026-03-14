//=============================================================================
//  R6Reticule.uc : Base class of R6 reticules
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/02 * Aristomenis Kolokathis	- Creation
//    2001/08/26 * Eric Begin				- New reticule system
//=============================================================================
class R6Reticule extends Actor
    native
    abstract
    config(user);

// --- Variables ---
// var ? m_Color; // REMOVED IN 1.60
var float m_fReticuleOffsetY;
var float m_fReticuleOffsetX;
var bool m_bShowNames;
// the scale to apply when zooming (helmet camera)
var float m_fZoomScale;
var config Color m_color;
// ^ NEW IN 1.60
// accuracy adjustement: only used for to modifie the view
var float m_fAccuracy;
var string m_CharacterName;
// Those variables are use to place the non-functionnal (Fixed) part of the reticule
var int m_iNonFunctionnalX;
var int m_iNonFunctionnalY;
var bool m_bIdentifyCharacter;
var bool m_bAimingAtFriendly;
var Font m_SmallFont_14pt;

// --- Functions ---
// function ? UpdateReticule(...); // REMOVED IN 1.60
// Speed gives us the current speed.
simulated function PostRender(Canvas C) {}
simulated function SetReticuleInfo(Canvas C) {}
simulated function SetIdentificationReticule(Canvas C) {}

defaultproperties
{
}
