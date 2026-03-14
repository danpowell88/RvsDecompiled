//=============================================================================
//  R6ActionSpot.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/13 * Created by Guillaume Borgia
//=============================================================================
class R6ActionSpot extends Actor
    native;

#exec Texture Import File=Textures\ASInvest.pcx Name=ASInvest Mips=Off MASKED=1
#exec Texture Import File=Textures\ASCover.pcx Name=ASCover Mips=Off MASKED=1
#exec Texture Import File=Textures\ASFire.pcx Name=ASFire Mips=Off MASKED=1
#exec Texture Import File=Textures\ASBase.pcx Name=ASBase Mips=Off MASKED=1

// --- Variables ---
var Pawn m_pCurrentUser;
var bool m_bValidTarget;
var bool m_bInvestigate;
// ^ NEW IN 1.60
var EStance m_eCover;
// ^ NEW IN 1.60
var EStance m_eFire;
// ^ NEW IN 1.60
var int m_iLastInvestigateID;
var NavigationPoint m_Anchor;
var R6ActionSpot m_NextSpot;

// --- Functions ---
simulated function FirstPassReset() {}

defaultproperties
{
}
