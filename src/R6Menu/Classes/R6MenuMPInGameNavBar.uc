// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Menu.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6MenuMPInGameNavBar extends UWindowDialogClientWindow;

// --- Constants ---
const C_fHEIGHT_HELPTEXTBAR =  20;

// --- Variables ---
var R6WindowButtonBox m_pPlayerReady;
var R6WindowButton m_KitRestrictionButton;
// ^ NEW IN 1.60
var R6WindowButton m_SelectTeamButton;
// ^ NEW IN 1.60
var R6WindowButton m_GearButton;
var R6WindowButton m_ServerOptButton;
// ^ NEW IN 1.60
// X pos of each nav bar icon
var int m_iXNavBarLoc[4];
// Y pos of each nav bar icon
var int m_iYNavBarLoc[4];
var Region m_RGearButtonUp;
// ^ NEW IN 1.60
var Texture m_TGearButton;
var Texture m_TKitRestrictionButton;
// ^ NEW IN 1.60
var Texture m_TServerOptButton;
// ^ NEW IN 1.60
var Texture m_TSelectTeamButton;
// ^ NEW IN 1.60
var R6MenuMPInGameHelpBar m_HelpTextBar;
var Region m_RSelectTeamButtonUp;
// ^ NEW IN 1.60
var Region m_RServerOptButtonUp;
// ^ NEW IN 1.60
var Region m_RKitRestrictionButtonUp;
// ^ NEW IN 1.60
// the width of the player button
var float m_fPlayerButWidth;
var Region m_RSelectTeamButtonDown;
// ^ NEW IN 1.60
var Region m_RSelectTeamButtonDisabled;
// ^ NEW IN 1.60
var Region m_RSelectTeamButtonOver;
var Region m_RServerOptButtonDown;
// ^ NEW IN 1.60
var Region m_RServerOptButtonDisabled;
// ^ NEW IN 1.60
var Region m_RServerOptButtonOver;
var Region m_RKitRestrictionButtonDown;
// ^ NEW IN 1.60
var Region m_RKitRestrictionButtonDisabled;
// ^ NEW IN 1.60
var Region m_RKitRestrictionButtonOver;
var Region m_RGearButtonDown;
// ^ NEW IN 1.60
var Region m_RGearButtonDisabled;
// ^ NEW IN 1.60
var Region m_RGearButtonOver;

// --- Functions ---
function Created() {}
function CheckForNavBarState() {}
function ToolTip(string strTip) {}
function SetNavBarButtonsStatus(bool _bDisplay) {}
function Notify(UWindowDialogControl C, byte E) {}
function AlignButtons() {}
function SetNavBarState(bool _bDisable, optional bool _bDisableAllExceptReadyBut) {}
function BeforePaint(float Y, float X, Canvas C) {}

defaultproperties
{
}
