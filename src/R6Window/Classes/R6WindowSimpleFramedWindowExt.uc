//=============================================================================
//  R6WindowSimpleFramedWindow.uc : This provides a simple frame for a window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/04 * Created by Yannick Joly
//=============================================================================
class R6WindowSimpleFramedWindowExt extends UWindowWindow;

// --- Enums ---
enum eCornerType // To draw some corners
{
	No_Corners,
    Top_Corners,
	Bottom_Corners,       
	All_Corners
} m_eCornerType;

struct stBorderForm
{
    var color   vColor;
    var FLOAT   fXPos;
    var FLOAT   fYPos;
    var FLOAT   fWidth;
    var bool    bActive;
//    var bool    bBorderSet;
};
enum eBorderType     // the type of the border you want 
{
    Border_Top,
    Border_Bottom,
    Border_Left,
    Border_Right 
};

// --- Structs ---
struct stBorderForm
{
    var color   vColor;
    var FLOAT   fXPos;
    var FLOAT   fYPos;
    var FLOAT   fWidth;
    var bool    bActive;
//    var bool    bBorderSet;
};

// --- Variables ---
// var ? bActive; // REMOVED IN 1.60
// var ? fWidth; // REMOVED IN 1.60
// var ? fXPos; // REMOVED IN 1.60
// var ? fYPos; // REMOVED IN 1.60
// var ? vColor; // REMOVED IN 1.60
// 0 = top ; 1 = down ; 2 = Left ; 3 = Right
var stBorderForm m_sBorderForm[4];
var Region m_topLeftCornerR;
var Region m_VBorderTextureRegion;
// ^ NEW IN 1.60
var Color m_eCornerColor[4];
var Region m_HBorderTextureRegion;
// ^ NEW IN 1.60
var Texture m_topLeftCornerT;
var eCornerType m_eCornerType;
// ^ NEW IN 1.60
// the background texture region
var Region m_BGTextureRegion;
var bool m_bNoBorderToDraw;
// the back ground color, default black
var Color m_vBGColor;
var Texture m_VBorderTexture;
//This is to create the window that needs the frame
var class<UWindowWindow> m_ClientClass;
var bool m_bDrawBackGround;
var int m_DrawStyle;
var Texture m_HBorderTexture;
// ^ NEW IN 1.60
// Put = None when no background is needed
var Texture m_BGTexture;
// Border size
var float m_fVBorderWidth;
var UWindowWindow m_ClientArea;
var float m_fHBorderHeight;
// ^ NEW IN 1.60
var float m_fHBorderPadding;
// ^ NEW IN 1.60
//////////////////////////////
//Please make sure you set the Padding correctly if you use the offsets values
//////////////////////////////
// Allow the borders not to start in corners
var float m_fVBorderPadding;
var float m_fHBorderOffset;
// ^ NEW IN 1.60
// Border offset if you want the borders to
var float m_fVBorderOffset;

// --- Functions ---
// default initialisation
// we have to set after the create window the parameters you want
function Created() {}
function Paint(Canvas C, float X, float Y) {}
function ActiveBackGround(Color _vBGColor, bool _bActivate) {}
//Just Pass any Control to this function to get it to show in the frame
function CreateClientWindow(class<UWindowWindow> ClientClass) {}
function AfterPaint(Canvas C, float X, float Y) {}
// set the corner color
function SetCornerColor(Color _Color, int _iCornerType) {}
function SetBorderParam(int _iBorderType, float _X, float _Y, float _fWidth, Color _vColor) {}
// active border or not
function ActiveBorder(bool _Active, int _iBorderType) {}
function SetNoBorder() {}
// verify if you at least one border to draw
function bool GetActivateBorder() {}
// ^ NEW IN 1.60

defaultproperties
{
}
