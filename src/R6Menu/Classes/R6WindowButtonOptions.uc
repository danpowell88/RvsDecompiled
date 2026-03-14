//=============================================================================
// R6WindowButtonOptions - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowButtonOptions.uc : This is button for options menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/11 * Created by Yannick Joly
//=============================================================================
class R6WindowButtonOptions extends R6WindowButton;

enum eButtonActionType
{
	Button_Game,                    // 0
	Button_Sound,                   // 1
	Button_Graphic,                 // 2
	Button_Hud,                     // 3
	Button_Multiplayer,             // 4
	Button_Controls,                // 5
	Button_MODS,                    // 6
	Button_PatchService,            // 7
	Button_Return                   // 8
};

// NEW IN 1.60
var R6WindowButtonOptions.eButtonActionType m_eButton_Action;
var Texture m_TOverButton;
var Region m_ROverButtonFade;
var Region m_ROverButton;

simulated function Click(float X, float Y)
{
	local R6MenuRootWindow r6Root;

	// End:0x0B
	if(bDisabled)
	{
		return;
	}
	super(UWindowButton).Click(X, Y);
	r6Root = R6MenuRootWindow(Root);
	switch(m_eButton_Action)
	{
		// End:0x60
		case 0:
			R6MenuOptionsWidget(OwnerWindow).ManageOptionsSelection(int(R6MenuOptionsWidget(OwnerWindow).0));
			// End:0x1ED
			break;
		// End:0x8E
		case 1:
			R6MenuOptionsWidget(OwnerWindow).ManageOptionsSelection(int(R6MenuOptionsWidget(OwnerWindow).1));
			// End:0x1ED
			break;
		// End:0xBC
		case 2:
			R6MenuOptionsWidget(OwnerWindow).ManageOptionsSelection(int(R6MenuOptionsWidget(OwnerWindow).2));
			// End:0x1ED
			break;
		// End:0xEA
		case 3:
			R6MenuOptionsWidget(OwnerWindow).ManageOptionsSelection(int(R6MenuOptionsWidget(OwnerWindow).3));
			// End:0x1ED
			break;
		// End:0x118
		case 4:
			R6MenuOptionsWidget(OwnerWindow).ManageOptionsSelection(int(R6MenuOptionsWidget(OwnerWindow).4));
			// End:0x1ED
			break;
		// End:0x146
		case 5:
			R6MenuOptionsWidget(OwnerWindow).ManageOptionsSelection(int(R6MenuOptionsWidget(OwnerWindow).5));
			// End:0x1ED
			break;
		// End:0x174
		case 6:
			R6MenuOptionsWidget(OwnerWindow).ManageOptionsSelection(int(R6MenuOptionsWidget(OwnerWindow).6));
			// End:0x1ED
			break;
		// End:0x1A2
		case 7:
			R6MenuOptionsWidget(OwnerWindow).ManageOptionsSelection(int(R6MenuOptionsWidget(OwnerWindow).7));
			// End:0x1ED
			break;
		// End:0x1CF
		case 8:
			R6MenuOptionsWidget(OwnerWindow).UpdateOptions();
			Root.ChangeCurrentWidget(17);
			// End:0x1ED
			break;
		// End:0xFFFF
		default:
			__NFUN_231__("Button not supported");
			// End:0x1ED
			break;
			break;
	}
	return;
}

defaultproperties
{
	m_TOverButton=Texture'R6MenuTextures.Gui_BoxScroll'
	m_ROverButtonFade=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=63522,ZoneNumber=0)
	m_ROverButton=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=64802,ZoneNumber=0)
	m_fFontSpacing=1.0000000
	bStretched=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var eButtonActionType
