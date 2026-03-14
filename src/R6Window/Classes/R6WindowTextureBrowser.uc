//=============================================================================
//  R6WindowTextureBrowser.uc : Small widget allowing user to select a texture 
//                              from a texture collection
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/04 * Created by Alexandre Dionne
//=============================================================================
class R6WindowTextureBrowser extends UWindowDialogClientWindow;

// --- Variables ---
var UWindowHScrollbar m_HSB;
var array<array> m_TextureCollection;
var R6WindowBitMap m_CurrentSelection;
var R6WindowTextLabelExt m_pTextLabel;
var bool bShowLog;
var array<array> m_TextureRegionCollection;
//1 for now
var int m_iNbDisplayedElement;
var bool m_bBitMapInitialized;
var bool m_bSBInitialized;

// --- Functions ---
//================================================================
//
//================================================================
function int AddTexture(Texture _Texture, Region _Region) {}
// ^ NEW IN 1.60
//================================================================
//	Sets current selectd texture if possible
//================================================================
function SetCurrentTextureFromIndex(int _index) {}
//================================================================
//	CreateBitmap : Create the Bitmap where you want it make sure you leave enough room for the scroll bar
//================================================================
function CreateBitmap(int H, int W, int Y, int X) {}
function SetBitmapProperties(optional Color _TextureColor, bool _bUseColor, int _iDrawStyle, bool _bCenter, bool _bStretch) {}
function SetBitmapBorder(Color _borderColor, bool _bDrawBorder) {}
//================================================================
//	Created: Creates the Horizontal scroll bar
//================================================================
function CreateSB(int W, int Y, int X, int H) {}
function CreateTextLabel(int X, int Y, int W, int H, string _szText, string _szToolTip) {}
//================================================================
//
//================================================================
function RemoveTextureFromIndex(int _index) {}
function Notify(UWindowDialogControl C, byte E) {}
//================================================================
//
//================================================================
function Clear() {}
//================================================================
//
//================================================================
function GetCurrentSelectedTexture() {}
//================================================================
//
//================================================================
function Texture GetTextureAtIndex(int _index) {}
// ^ NEW IN 1.60
//================================================================
//	Returns current selected texture index
//================================================================
function int GetCurrentTextureIndex() {}
// ^ NEW IN 1.60
//================================================================
//
//================================================================
function int GetTextureIndex(Texture _Texture) {}
// ^ NEW IN 1.60
//================================================================
//
//================================================================
function RemoveTexture(Texture _Texture) {}

defaultproperties
{
}
