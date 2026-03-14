//=============================================================================
//  R6MenuCarreerOperative.uc : In debriefing room the little control bottom right with face
//                              of the operative and his carreer stats
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/02 * Created by Alexandre Dionne
//=============================================================================
class R6MenuCarreerOperative extends UWindowWindow;

// --- Variables ---
var Region RTopLeft;
// ^ NEW IN 1.60
var Region RTopRight;
// ^ NEW IN 1.60
//Borders Region
var Region RMidLeft;
var float m_fXPos;
// ^ NEW IN 1.60
var Region RMidRight;
// ^ NEW IN 1.60
var R6WindowBitMap m_OperativeFace;
var float m_fTileHeight;
var float m_fXFacePos;
// ^ NEW IN 1.60
var float m_fYFacePos;
// ^ NEW IN 1.60

// --- Functions ---
// function ? SetFace(...); // REMOVED IN 1.60
function setFace(Region _FaceRegion, Texture _OperativeFace) {}
// ^ NEW IN 1.60
function SetTeam(int _Team) {}
function AfterPaint(Canvas C, float X, float Y) {}
function Created() {}

defaultproperties
{
}
