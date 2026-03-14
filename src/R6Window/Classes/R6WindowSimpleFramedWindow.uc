//=============================================================================
//  R6WindowSimpleFramedWindow.uc : This provides a simple frame for a window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/19 * Created by Alexandre Dionne
//=============================================================================
class R6WindowSimpleFramedWindow extends UWindowWindow;

// --- Enums ---
enum eCornerType
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var Region m_topLeftCornerR;
var Region m_VBorderTextureRegion;
var Region m_HBorderTextureRegion;
// ^ NEW IN 1.60
var float m_fHBorderHeight;
// ^ NEW IN 1.60
//Border offset if you want the borders to
var float m_fVBorderOffset;
//Border size
var float m_fVBorderWidth;
//Allow the borders not to start in corners
var float m_fVBorderPadding;
var float m_fHBorderOffset;
// ^ NEW IN 1.60
var float m_fHBorderPadding;
// ^ NEW IN 1.60
var Texture m_topLeftCornerT;
var Texture m_VBorderTexture;
var Texture m_HBorderTexture;
// ^ NEW IN 1.60
//This is to create the window that needs the frame
var class<UWindowWindow> m_ClientClass;
var eCornerType m_eCornerType;
// ^ NEW IN 1.60
var UWindowWindow m_ClientArea;
var int m_DrawStyle;
var bool bShowLog;

// --- Functions ---
function SetCornerType(eCornerType _eCornerType) {}
function AfterPaint(Canvas C, float X, float Y) {}
//Just Pass any Control to this function to get it to show in the frame
function CreateClientWindow(class<UWindowWindow> ClientClass) {}

defaultproperties
{
}
