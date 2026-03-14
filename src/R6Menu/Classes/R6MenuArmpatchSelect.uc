//=============================================================================
//  R6MenuArmpatchSelect.uc : Armpatch chooser for option menu
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/10 * Created by Alexandre Dionne
//=============================================================================
class R6MenuArmpatchSelect extends UWindowDialogClientWindow;

// --- Variables ---
var R6WindowTextListBox m_ArmPatchListBox;
var UWindowBitmap m_ArmpatchBitmap;
var R6WindowTextLabelExt m_pTextLabel;
var R6WindowListBoxItem m_DefaultItem;
var R6FileManager m_pFileManager;
var string m_path;
// ^ NEW IN 1.60
var Texture m_TBlankTexture;
var string m_Ext;
var Region m_RBlankTexture;
var Texture m_TInvalidTexture;
var Texture m_TDefaultTexture;

// --- Functions ---
// function ? Paint(...); // REMOVED IN 1.60
function Notify(UWindowDialogControl C, byte E) {}
function SetToolTip(string _InString) {}
function CreateArmPatchBitmap(int H, int W, int Y, int X) {}
function CreateTextLabel(string _szToolTip, string _szText, int H, int W, int Y, int X) {}
function CreateListBox(int H, int W, int Y, int X) {}
function SetDesiredSelectedArmpatch(string _ArmPatchName) {}
function RefreshListBox() {}
function string GetSelectedArmpatch() {}
// ^ NEW IN 1.60

defaultproperties
{
}
