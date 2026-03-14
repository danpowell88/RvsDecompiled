//=============================================================================
//  R6WindowOperativePlanningSummary.uc : Small window summerizing an operative
//                                        planning result for the execute screen
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/13 * Created by Alexandre Dionne
//=============================================================================
class R6WindowOperativePlanningSummary extends UWindowWindow;

// --- Variables ---
var R6WindowTextLabel m_OperativeName;
var R6WindowTextLabel m_PrimaryWeapon;
// ^ NEW IN 1.60
var R6WindowBitMap m_BMPHealth;
var R6WindowBitMap m_BMPSpeciality;
var Color m_LabelColor;
var R6WindowBitMap m_OperativeFace;
var R6WindowTextLabel m_Armor;
// ^ NEW IN 1.60
var float m_fFaceWidth;
// ^ NEW IN 1.60
var Texture m_TBottomLabelBG;
var byte m_BCurrentAlpha;
var Color m_CDarkColor;
var float m_FaceHeight;
// ^ NEW IN 1.60
var float m_fNameLabelHeight;
var int m_IYIconPos;
// ^ NEW IN 1.60
var byte m_BAlphaOpNameBg;
var bool m_bIsSelected;
var byte m_BAlphaBg;
var byte m_BSelectedAlphaOpNameBg;
var int m_ISpecialityHeight;
var int m_ISpecialityWidth;
// ^ NEW IN 1.60
var int m_IHealthHeight;
// ^ NEW IN 1.60
var int m_IHealthWidth;
// ^ NEW IN 1.60
var int m_IXHealthOffset;
// ^ NEW IN 1.60
var int m_IXSpecialityOffset;
// ^ NEW IN 1.60
var Region m_RBottomLabelBG;

// --- Functions ---
function setLabels(string szOperativeName, string szArmor, string szPrimaryWeapon) {}
function setFace(Region _R, Texture _T) {}
function Created() {}
function setHealth(TexRegion _T) {}
function setSpeciality(TexRegion _T) {}
function AfterPaint(Canvas C, float X, float Y) {}
function Paint(Canvas C, float X, float Y) {}
function SetSelected(bool _IsSelected) {}
function SetColor(Color _LabelColor, Color _DarkColor) {}

defaultproperties
{
}
