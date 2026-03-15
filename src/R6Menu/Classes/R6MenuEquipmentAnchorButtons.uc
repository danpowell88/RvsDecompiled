//=============================================================================
// R6MenuEquipmentAnchorButtons - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuEquipmentAnchorButtons.uc : The top buttons needed for quick find a equipment category
//                                    in the list box        
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/09/21 * Created by Alexandre Dionne
//=============================================================================
class R6MenuEquipmentAnchorButtons extends UWindowDialogControl;

enum eAnchorEquipmentType
{
	AET_Primary,                    // 0
	AET_Secondary,                  // 1
	AET_Gadget,                     // 2
	AET_None                        // 3
};

var bool m_bDrawBorders;
var float m_fButtonTabWidth;
// NEW IN 1.60
var float m_fButtonTabHeight;
var float m_fPrimarWTabOffset;
// NEW IN 1.60
var float m_fPistolOffset;
// NEW IN 1.60
var float m_fGrenadesOffset;
var float m_fPrimaryBetweenButtonOffset;
// NEW IN 1.60
var float m_fSecondaryBetweenButtonOffset;
// NEW IN 1.60
var float m_fGadgetsBetweenButtonOffset;
var float m_fYTopOffset;  // Offset from the top of the control
////////////////////////////////////////////////////////////////////////////////////
//          Quick equipment find tab buttons 1 by separator
////////////////////////////////////////////////////////////////////////////////////
// Primary Weapons
var R6WindowListBoxAnchorButton m_ASSAULTButton;
var R6WindowListBoxAnchorButton m_LMGButton;
var R6WindowListBoxAnchorButton m_SHOTGUNButton;
var R6WindowListBoxAnchorButton m_SNIPERButton;
var R6WindowListBoxAnchorButton m_SUBGUNButton;
var R6WindowListBoxAnchorButton m_PISTOLSButton;
var R6WindowListBoxAnchorButton m_MACHINEPISTOLSButton;
// Gadgets
var R6WindowListBoxAnchorButton m_GRENADESButton;
var R6WindowListBoxAnchorButton m_EXPLOSIVESButton;
var R6WindowListBoxAnchorButton m_HBDEVICEButton;
var R6WindowListBoxAnchorButton m_KITSButton;
var R6WindowListBoxAnchorButton m_GENERALButton;
//Button Texture Regions
var Region m_RASSAULTUp;
// NEW IN 1.60
var Region m_RASSAULTOver;
// NEW IN 1.60
var Region m_RASSAULTDown;
// NEW IN 1.60
var Region m_RLMGUp;
// NEW IN 1.60
var Region m_RLMGOver;
// NEW IN 1.60
var Region m_RLMGDown;
// NEW IN 1.60
var Region m_RSHOTGUNUp;
// NEW IN 1.60
var Region m_RSHOTGUNOver;
// NEW IN 1.60
var Region m_RSHOTGUNDown;
// NEW IN 1.60
var Region m_RSNIPERUp;
// NEW IN 1.60
var Region m_RSNIPEROver;
// NEW IN 1.60
var Region m_RSNIPERDown;
// NEW IN 1.60
var Region m_RSUBGUNUp;
// NEW IN 1.60
var Region m_RSUBGUNOver;
// NEW IN 1.60
var Region m_RSUBGUNDown;
// NEW IN 1.60
var Region m_RPISTOLSUp;
// NEW IN 1.60
var Region m_RPISTOLSOver;
// NEW IN 1.60
var Region m_RPISTOLSDown;
// NEW IN 1.60
var Region m_RMACHINEPISTOLSUp;
// NEW IN 1.60
var Region m_RMACHINEPISTOLSOver;
// NEW IN 1.60
var Region m_RMACHINEPISTOLSDown;
// NEW IN 1.60
var Region m_RGRENADESUp;
// NEW IN 1.60
var Region m_RGRENADESOver;
// NEW IN 1.60
var Region m_RGRENADESDown;
// NEW IN 1.60
var Region m_REXPLOSIVESUp;
// NEW IN 1.60
var Region m_REXPLOSIVESOver;
// NEW IN 1.60
var Region m_REXPLOSIVESDown;
// NEW IN 1.60
var Region m_RHBDEVICEUp;
// NEW IN 1.60
var Region m_RHBDEVICEOver;
// NEW IN 1.60
var Region m_RHBDEVICEDown;
// NEW IN 1.60
var Region m_RKITSUp;
// NEW IN 1.60
var Region m_RKITSOver;
// NEW IN 1.60
var Region m_RKITSDown;
// NEW IN 1.60
var Region m_GENERALUp;
// NEW IN 1.60
var Region m_GENERALOver;
// NEW IN 1.60
var Region m_GENERALDown;

function Created()
{
	m_fYTopOffset = (WinHeight - m_fButtonTabHeight);
	m_SUBGUNButton = R6WindowListBoxAnchorButton(CreateWindow(Class'R6Window.R6WindowListBoxAnchorButton', m_fPrimarWTabOffset, m_fYTopOffset, m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_ASSAULTButton = R6WindowListBoxAnchorButton(CreateWindow(Class'R6Window.R6WindowListBoxAnchorButton', ((m_SUBGUNButton.WinLeft + m_SUBGUNButton.WinWidth) + m_fPrimaryBetweenButtonOffset), m_fYTopOffset, m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_SHOTGUNButton = R6WindowListBoxAnchorButton(CreateWindow(Class'R6Window.R6WindowListBoxAnchorButton', ((m_ASSAULTButton.WinLeft + m_ASSAULTButton.WinWidth) + m_fPrimaryBetweenButtonOffset), m_fYTopOffset, m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_SNIPERButton = R6WindowListBoxAnchorButton(CreateWindow(Class'R6Window.R6WindowListBoxAnchorButton', ((m_SHOTGUNButton.WinLeft + m_SHOTGUNButton.WinWidth) + m_fPrimaryBetweenButtonOffset), m_fYTopOffset, m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_LMGButton = R6WindowListBoxAnchorButton(CreateWindow(Class'R6Window.R6WindowListBoxAnchorButton', ((m_SNIPERButton.WinLeft + m_SNIPERButton.WinWidth) + m_fPrimaryBetweenButtonOffset), m_fYTopOffset, m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_PISTOLSButton = R6WindowListBoxAnchorButton(CreateWindow(Class'R6Window.R6WindowListBoxAnchorButton', m_fPistolOffset, m_fYTopOffset, m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_MACHINEPISTOLSButton = R6WindowListBoxAnchorButton(CreateWindow(Class'R6Window.R6WindowListBoxAnchorButton', ((m_PISTOLSButton.WinLeft + m_PISTOLSButton.WinWidth) + m_fSecondaryBetweenButtonOffset), m_fYTopOffset, m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_GRENADESButton = R6WindowListBoxAnchorButton(CreateWindow(Class'R6Window.R6WindowListBoxAnchorButton', m_fGrenadesOffset, m_fYTopOffset, m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_EXPLOSIVESButton = R6WindowListBoxAnchorButton(CreateWindow(Class'R6Window.R6WindowListBoxAnchorButton', ((m_GRENADESButton.WinLeft + m_GRENADESButton.WinWidth) + m_fGadgetsBetweenButtonOffset), m_fYTopOffset, m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_HBDEVICEButton = R6WindowListBoxAnchorButton(CreateWindow(Class'R6Window.R6WindowListBoxAnchorButton', ((m_EXPLOSIVESButton.WinLeft + m_EXPLOSIVESButton.WinWidth) + m_fGadgetsBetweenButtonOffset), m_fYTopOffset, m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_KITSButton = R6WindowListBoxAnchorButton(CreateWindow(Class'R6Window.R6WindowListBoxAnchorButton', ((m_HBDEVICEButton.WinLeft + m_HBDEVICEButton.WinWidth) + m_fGadgetsBetweenButtonOffset), m_fYTopOffset, m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_GENERALButton = R6WindowListBoxAnchorButton(CreateWindow(Class'R6Window.R6WindowListBoxAnchorButton', ((m_KITSButton.WinLeft + m_KITSButton.WinWidth) + m_fGadgetsBetweenButtonOffset), m_fYTopOffset, m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_ASSAULTButton.ToolTipString = Localize("Tip", "GearRoomButAssaultRif", "R6Menu");
	m_LMGButton.ToolTipString = Localize("Tip", "GearRoomButLightMach", "R6Menu");
	m_SHOTGUNButton.ToolTipString = Localize("Tip", "GearRoomButShotGun", "R6Menu");
	m_SNIPERButton.ToolTipString = Localize("Tip", "GearRoomButSniperRif", "R6Menu");
	m_SUBGUNButton.ToolTipString = Localize("Tip", "GearRoomButSubMach", "R6Menu");
	m_PISTOLSButton.ToolTipString = Localize("Tip", "GearRoomButPistols", "R6Menu");
	m_MACHINEPISTOLSButton.ToolTipString = Localize("Tip", "GearRoomButMPistols", "R6Menu");
	m_GRENADESButton.ToolTipString = Localize("Tip", "GearRoomButGrenade", "R6Menu");
	m_EXPLOSIVESButton.ToolTipString = Localize("Tip", "GearRoomButExplosive", "R6Menu");
	m_HBDEVICEButton.ToolTipString = Localize("Tip", "GearRoomButHeartB", "R6Menu");
	m_KITSButton.ToolTipString = Localize("Tip", "GearRoomButKits", "R6Menu");
	m_GENERALButton.ToolTipString = Localize("Tip", "GearRoomButOthers", "R6Menu");
	m_ASSAULTButton.UpRegion = m_RASSAULTUp;
	m_ASSAULTButton.OverRegion = m_RASSAULTOver;
	m_ASSAULTButton.DownRegion = m_RASSAULTDown;
	m_LMGButton.UpRegion = m_RLMGUp;
	m_LMGButton.OverRegion = m_RLMGOver;
	m_LMGButton.DownRegion = m_RLMGDown;
	m_SHOTGUNButton.UpRegion = m_RSHOTGUNUp;
	m_SHOTGUNButton.OverRegion = m_RSHOTGUNOver;
	m_SHOTGUNButton.DownRegion = m_RSHOTGUNDown;
	m_SNIPERButton.UpRegion = m_RSNIPERUp;
	m_SNIPERButton.OverRegion = m_RSNIPEROver;
	m_SNIPERButton.DownRegion = m_RSNIPERDown;
	m_SUBGUNButton.UpRegion = m_RSUBGUNUp;
	m_SUBGUNButton.OverRegion = m_RSUBGUNOver;
	m_SUBGUNButton.DownRegion = m_RSUBGUNDown;
	m_PISTOLSButton.UpRegion = m_RPISTOLSUp;
	m_PISTOLSButton.OverRegion = m_RPISTOLSOver;
	m_PISTOLSButton.DownRegion = m_RPISTOLSDown;
	m_MACHINEPISTOLSButton.UpRegion = m_RMACHINEPISTOLSUp;
	m_MACHINEPISTOLSButton.OverRegion = m_RMACHINEPISTOLSOver;
	m_MACHINEPISTOLSButton.DownRegion = m_RMACHINEPISTOLSDown;
	m_GRENADESButton.UpRegion = m_RGRENADESUp;
	m_GRENADESButton.OverRegion = m_RGRENADESOver;
	m_GRENADESButton.DownRegion = m_RGRENADESDown;
	m_EXPLOSIVESButton.UpRegion = m_REXPLOSIVESUp;
	m_EXPLOSIVESButton.OverRegion = m_REXPLOSIVESOver;
	m_EXPLOSIVESButton.DownRegion = m_REXPLOSIVESDown;
	m_HBDEVICEButton.UpRegion = m_RHBDEVICEUp;
	m_HBDEVICEButton.OverRegion = m_RHBDEVICEOver;
	m_HBDEVICEButton.DownRegion = m_RHBDEVICEDown;
	m_KITSButton.UpRegion = m_RKITSUp;
	m_KITSButton.OverRegion = m_RKITSOver;
	m_KITSButton.DownRegion = m_RKITSDown;
	m_GENERALButton.UpRegion = m_GENERALUp;
	m_GENERALButton.OverRegion = m_GENERALOver;
	m_GENERALButton.DownRegion = m_GENERALDown;
	m_ASSAULTButton.m_iDrawStyle = 5;
	m_LMGButton.m_iDrawStyle = 5;
	m_SHOTGUNButton.m_iDrawStyle = 5;
	m_SNIPERButton.m_iDrawStyle = 5;
	m_SUBGUNButton.m_iDrawStyle = 5;
	m_PISTOLSButton.m_iDrawStyle = 5;
	m_MACHINEPISTOLSButton.m_iDrawStyle = 5;
	m_GRENADESButton.m_iDrawStyle = 5;
	m_EXPLOSIVESButton.m_iDrawStyle = 5;
	m_HBDEVICEButton.m_iDrawStyle = 5;
	m_KITSButton.m_iDrawStyle = 5;
	m_GENERALButton.m_iDrawStyle = 5;
	DisplayButtons(0);
	m_BorderColor = Root.Colors.White;
	return;
}

function DisplayButtons(R6MenuEquipmentAnchorButtons.eAnchorEquipmentType _Equipment)
{
	switch(_Equipment)
	{
		// End:0xC3
		case 0:
			m_ASSAULTButton.ShowWindow();
			m_LMGButton.ShowWindow();
			m_SHOTGUNButton.ShowWindow();
			m_SNIPERButton.ShowWindow();
			m_SUBGUNButton.ShowWindow();
			m_PISTOLSButton.HideWindow();
			m_MACHINEPISTOLSButton.HideWindow();
			m_GRENADESButton.HideWindow();
			m_EXPLOSIVESButton.HideWindow();
			m_HBDEVICEButton.HideWindow();
			m_KITSButton.HideWindow();
			m_GENERALButton.HideWindow();
			// End:0x23E
			break;
		// End:0x17F
		case 1:
			m_ASSAULTButton.HideWindow();
			m_LMGButton.HideWindow();
			m_SHOTGUNButton.HideWindow();
			m_SNIPERButton.HideWindow();
			m_SUBGUNButton.HideWindow();
			m_PISTOLSButton.ShowWindow();
			m_MACHINEPISTOLSButton.ShowWindow();
			m_GRENADESButton.HideWindow();
			m_EXPLOSIVESButton.HideWindow();
			m_HBDEVICEButton.HideWindow();
			m_KITSButton.HideWindow();
			m_GENERALButton.HideWindow();
			// End:0x23E
			break;
		// End:0x23B
		case 2:
			m_ASSAULTButton.HideWindow();
			m_LMGButton.HideWindow();
			m_SHOTGUNButton.HideWindow();
			m_SNIPERButton.HideWindow();
			m_SUBGUNButton.HideWindow();
			m_PISTOLSButton.HideWindow();
			m_MACHINEPISTOLSButton.HideWindow();
			m_GRENADESButton.ShowWindow();
			m_EXPLOSIVESButton.ShowWindow();
			m_HBDEVICEButton.ShowWindow();
			m_KITSButton.ShowWindow();
			m_GENERALButton.ShowWindow();
			// End:0x23E
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function Register(UWindowDialogClientWindow W)
{
	super.Register(W);
	m_ASSAULTButton.Register(W);
	m_LMGButton.Register(W);
	m_SHOTGUNButton.Register(W);
	m_SNIPERButton.Register(W);
	m_SUBGUNButton.Register(W);
	m_PISTOLSButton.Register(W);
	m_MACHINEPISTOLSButton.Register(W);
	m_GRENADESButton.Register(W);
	m_EXPLOSIVESButton.Register(W);
	m_HBDEVICEButton.Register(W);
	m_KITSButton.Register(W);
	m_GENERALButton.Register(W);
	return;
}

function Resize()
{
	m_fYTopOffset = (WinHeight - m_fButtonTabHeight);
	m_SUBGUNButton.WinLeft = m_fPrimarWTabOffset;
	m_SUBGUNButton.WinTop = m_fYTopOffset;
	m_SUBGUNButton.WinWidth = m_fButtonTabWidth;
	m_SUBGUNButton.WinHeight = m_fButtonTabHeight;
	m_ASSAULTButton.WinLeft = ((m_SUBGUNButton.WinLeft + m_SUBGUNButton.WinWidth) + m_fPrimaryBetweenButtonOffset);
	m_ASSAULTButton.WinTop = m_fYTopOffset;
	m_ASSAULTButton.WinWidth = m_fButtonTabWidth;
	m_ASSAULTButton.WinHeight = m_fButtonTabHeight;
	m_SHOTGUNButton.WinLeft = ((m_ASSAULTButton.WinLeft + m_ASSAULTButton.WinWidth) + m_fPrimaryBetweenButtonOffset);
	m_SHOTGUNButton.WinTop = m_fYTopOffset;
	m_SHOTGUNButton.WinWidth = m_fButtonTabWidth;
	m_SHOTGUNButton.WinHeight = m_fButtonTabHeight;
	m_SNIPERButton.WinLeft = ((m_SHOTGUNButton.WinLeft + m_SHOTGUNButton.WinWidth) + m_fPrimaryBetweenButtonOffset);
	m_SNIPERButton.WinTop = m_fYTopOffset;
	m_SNIPERButton.WinWidth = m_fButtonTabWidth;
	m_SNIPERButton.WinHeight = m_fButtonTabHeight;
	m_LMGButton.WinLeft = ((m_SNIPERButton.WinLeft + m_SNIPERButton.WinWidth) + m_fPrimaryBetweenButtonOffset);
	m_LMGButton.WinTop = m_fYTopOffset;
	m_LMGButton.WinWidth = m_fButtonTabWidth;
	m_LMGButton.WinHeight = m_fButtonTabHeight;
	m_PISTOLSButton.WinLeft = m_fPistolOffset;
	m_PISTOLSButton.WinTop = m_fYTopOffset;
	m_PISTOLSButton.WinWidth = m_fButtonTabWidth;
	m_PISTOLSButton.WinHeight = m_fButtonTabHeight;
	m_MACHINEPISTOLSButton.WinLeft = ((m_PISTOLSButton.WinLeft + m_PISTOLSButton.WinWidth) + m_fSecondaryBetweenButtonOffset);
	m_MACHINEPISTOLSButton.WinTop = m_fYTopOffset;
	m_MACHINEPISTOLSButton.WinWidth = m_fButtonTabWidth;
	m_MACHINEPISTOLSButton.WinHeight = m_fButtonTabHeight;
	m_GRENADESButton.WinLeft = m_fGrenadesOffset;
	m_GRENADESButton.WinTop = m_fYTopOffset;
	m_GRENADESButton.WinWidth = m_fButtonTabWidth;
	m_GRENADESButton.WinHeight = m_fButtonTabHeight;
	m_EXPLOSIVESButton.WinLeft = ((m_GRENADESButton.WinLeft + m_GRENADESButton.WinWidth) + m_fGadgetsBetweenButtonOffset);
	m_EXPLOSIVESButton.WinTop = m_fYTopOffset;
	m_EXPLOSIVESButton.WinWidth = m_fButtonTabWidth;
	m_EXPLOSIVESButton.WinHeight = m_fButtonTabHeight;
	m_HBDEVICEButton.WinLeft = ((m_EXPLOSIVESButton.WinLeft + m_EXPLOSIVESButton.WinWidth) + m_fGadgetsBetweenButtonOffset);
	m_HBDEVICEButton.WinTop = m_fYTopOffset;
	m_HBDEVICEButton.WinWidth = m_fButtonTabWidth;
	m_HBDEVICEButton.WinHeight = m_fButtonTabHeight;
	m_KITSButton.WinLeft = ((m_HBDEVICEButton.WinLeft + m_HBDEVICEButton.WinWidth) + m_fGadgetsBetweenButtonOffset);
	m_KITSButton.WinTop = m_fYTopOffset;
	m_KITSButton.WinWidth = m_fButtonTabWidth;
	m_KITSButton.WinHeight = m_fButtonTabHeight;
	m_GENERALButton.WinLeft = ((m_KITSButton.WinLeft + m_KITSButton.WinWidth) + m_fGadgetsBetweenButtonOffset);
	m_GENERALButton.WinTop = m_fYTopOffset;
	m_GENERALButton.WinWidth = m_fButtonTabWidth;
	m_GENERALButton.WinHeight = m_fButtonTabHeight;
	return;
}

function AfterPaint(Canvas C, float X, float Y)
{
	// End:0x14
	if(m_bDrawBorders)
	{
		DrawSimpleBorder(C);
	}
	return;
}

defaultproperties
{
	m_bDrawBorders=true
	m_fButtonTabWidth=37.0000000
	m_fButtonTabHeight=20.0000000
	m_fPrimarWTabOffset=2.0000000
	m_fPistolOffset=2.0000000
	m_fGrenadesOffset=2.0000000
	m_RASSAULTUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29218,ZoneNumber=0)
	m_RASSAULTOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29218,ZoneNumber=0)
	m_RASSAULTDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29218,ZoneNumber=0)
	m_RLMGUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=38946,ZoneNumber=0)
	m_RLMGOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=38946,ZoneNumber=0)
	m_RLMGDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=38946,ZoneNumber=0)
	m_RSHOTGUNUp=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=32290,ZoneNumber=0)
	m_RSHOTGUNOver=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=37666,ZoneNumber=0)
	m_RSHOTGUNDown=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=43042,ZoneNumber=0)
	m_RSNIPERUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=9762,ZoneNumber=0)
	m_RSNIPEROver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=9762,ZoneNumber=0)
	m_RSNIPERDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=9762,ZoneNumber=0)
	m_RSUBGUNUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19490,ZoneNumber=0)
	m_RSUBGUNOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19490,ZoneNumber=0)
	m_RSUBGUNDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19490,ZoneNumber=0)
	m_RPISTOLSUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=48674,ZoneNumber=0)
	m_RPISTOLSOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=48674,ZoneNumber=0)
	m_RPISTOLSDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=48674,ZoneNumber=0)
	m_RMACHINEPISTOLSUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29218,ZoneNumber=0)
	m_RMACHINEPISTOLSOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29218,ZoneNumber=0)
	m_RMACHINEPISTOLSDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29218,ZoneNumber=0)
	m_RGRENADESUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=38946,ZoneNumber=0)
	m_RGRENADESOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=38946,ZoneNumber=0)
	m_RGRENADESDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=38946,ZoneNumber=0)
	m_REXPLOSIVESUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=48674,ZoneNumber=0)
	m_REXPLOSIVESOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=48674,ZoneNumber=0)
	m_REXPLOSIVESDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=48674,ZoneNumber=0)
	m_RHBDEVICEUp=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=48418,ZoneNumber=0)
	m_RHBDEVICEOver=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=53794,ZoneNumber=0)
	m_RHBDEVICEDown=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=59170,ZoneNumber=0)
	m_RKITSUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=9762,ZoneNumber=0)
	m_RKITSOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=9762,ZoneNumber=0)
	m_RKITSDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=9762,ZoneNumber=0)
	m_GENERALUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19490,ZoneNumber=0)
	m_GENERALOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19490,ZoneNumber=0)
	m_GENERALDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19490,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
