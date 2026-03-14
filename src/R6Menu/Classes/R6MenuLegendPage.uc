//=============================================================================
//  R6MenuLegendPage.uc : Base class for a page within the in-game legend overlay; renders a titled list of icon-and-text entries for one category.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/29 * Created by Joel Tremblay
//=============================================================================
class R6MenuLegendPage extends R6MenuPopupListButton;

// --- Variables ---
var localized string m_szPageTitle;
//Texture will be displayed as 32x32
var int m_iTextureSize;
var float m_fTitleWidth;
var int m_iSpaceBetweenTextureNText;
//little space at the end of the text
var int m_iSpaceEnd;

// --- Functions ---
function Created() {}
function BeforePaint(Canvas C, float MouseY, float MouseX) {}
function Paint(Canvas C, float MouseY, float MouseX) {}
function DrawItem(UWindowList Item, float X, float Y, Canvas C, float H, float W) {}

defaultproperties
{
}
