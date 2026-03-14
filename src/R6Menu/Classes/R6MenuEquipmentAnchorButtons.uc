//=============================================================================
//  R6MenuEquipmentAnchorButtons.uc : The top buttons needed for quick find a equipment category
//                                    in the list box        
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/09/21 * Created by Alexandre Dionne
//=============================================================================
class R6MenuEquipmentAnchorButtons extends UWindowDialogControl;

// --- Enums ---
enum eAnchorEquipmentType
{
    AET_Primary,
    AET_Secondary,
    AET_Gadget,
    AET_None
};

// --- Variables ---
var float m_fButtonTabHeight;
//Offset from the top of the control
var float m_fYTopOffset;
var float m_fButtonTabWidth;
// ^ NEW IN 1.60
var R6WindowListBoxAnchorButton m_HBDEVICEButton;
var R6WindowListBoxAnchorButton m_KITSButton;
var R6WindowListBoxAnchorButton m_EXPLOSIVESButton;
var R6WindowListBoxAnchorButton m_SUBGUNButton;
var R6WindowListBoxAnchorButton m_SNIPERButton;
// Gadgets
var R6WindowListBoxAnchorButton m_GRENADESButton;
var R6WindowListBoxAnchorButton m_SHOTGUNButton;
////////////////////////////////////////////////////////////////////////////////////
//          Quick equipment find tab buttons 1 by separator
////////////////////////////////////////////////////////////////////////////////////
// Primary Weapons
var R6WindowListBoxAnchorButton m_ASSAULTButton;
var R6WindowListBoxAnchorButton m_PISTOLSButton;
var R6WindowListBoxAnchorButton m_MACHINEPISTOLSButton;
var R6WindowListBoxAnchorButton m_LMGButton;
var R6WindowListBoxAnchorButton m_GENERALButton;
var float m_fGadgetsBetweenButtonOffset;
var float m_fPrimaryBetweenButtonOffset;
// ^ NEW IN 1.60
var float m_fPrimarWTabOffset;
// ^ NEW IN 1.60
var float m_fPistolOffset;
// ^ NEW IN 1.60
var float m_fGrenadesOffset;
var bool m_bDrawBorders;
var float m_fSecondaryBetweenButtonOffset;
// ^ NEW IN 1.60
var Region m_RASSAULTUp;
// ^ NEW IN 1.60
var Region m_RASSAULTOver;
// ^ NEW IN 1.60
var Region m_RASSAULTDown;
// ^ NEW IN 1.60
var Region m_RLMGUp;
// ^ NEW IN 1.60
var Region m_RLMGOver;
// ^ NEW IN 1.60
var Region m_RLMGDown;
// ^ NEW IN 1.60
var Region m_RSHOTGUNUp;
// ^ NEW IN 1.60
var Region m_RSHOTGUNOver;
// ^ NEW IN 1.60
var Region m_RSHOTGUNDown;
// ^ NEW IN 1.60
var Region m_RSNIPERUp;
// ^ NEW IN 1.60
var Region m_RSNIPEROver;
// ^ NEW IN 1.60
var Region m_RSNIPERDown;
// ^ NEW IN 1.60
var Region m_RSUBGUNUp;
// ^ NEW IN 1.60
var Region m_RSUBGUNOver;
// ^ NEW IN 1.60
var Region m_RSUBGUNDown;
// ^ NEW IN 1.60
var Region m_RPISTOLSUp;
// ^ NEW IN 1.60
var Region m_RPISTOLSOver;
// ^ NEW IN 1.60
var Region m_RPISTOLSDown;
// ^ NEW IN 1.60
var Region m_RMACHINEPISTOLSUp;
// ^ NEW IN 1.60
var Region m_RMACHINEPISTOLSOver;
// ^ NEW IN 1.60
var Region m_RMACHINEPISTOLSDown;
// ^ NEW IN 1.60
var Region m_RGRENADESUp;
// ^ NEW IN 1.60
var Region m_RGRENADESOver;
// ^ NEW IN 1.60
var Region m_RGRENADESDown;
// ^ NEW IN 1.60
var Region m_REXPLOSIVESUp;
// ^ NEW IN 1.60
var Region m_REXPLOSIVESOver;
// ^ NEW IN 1.60
var Region m_REXPLOSIVESDown;
// ^ NEW IN 1.60
var Region m_RHBDEVICEUp;
// ^ NEW IN 1.60
var Region m_RHBDEVICEOver;
// ^ NEW IN 1.60
var Region m_RHBDEVICEDown;
// ^ NEW IN 1.60
var Region m_RKITSUp;
// ^ NEW IN 1.60
var Region m_RKITSOver;
// ^ NEW IN 1.60
var Region m_RKITSDown;
// ^ NEW IN 1.60
var Region m_GENERALUp;
// ^ NEW IN 1.60
var Region m_GENERALOver;
// ^ NEW IN 1.60
var Region m_GENERALDown;
// ^ NEW IN 1.60

// --- Functions ---
function Register(UWindowDialogClientWindow W) {}
function DisplayButtons(eAnchorEquipmentType _Equipment) {}
function AfterPaint(Canvas C, float Y, float X) {}
function Resize() {}
function Created() {}

defaultproperties
{
}
