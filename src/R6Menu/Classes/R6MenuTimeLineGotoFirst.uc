//=============================================================================
// R6MenuTimeLineGotoFirst - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuTimeLineGotoFirst.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/03 * Created by Chaouky Garram
//=============================================================================
class R6MenuTimeLineGotoFirst extends R6WindowButton;

function Created()
{
	bNoKeyboard = true;
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	return;
}

function Tick(float fDeltaTime)
{
	return;
}

function LMouseDown(float X, float Y)
{
	super(UWindowWindow).LMouseDown(X, Y);
	// End:0x1B
	if(bDisabled)
	{
		return;
	}
	R6PlanningCtrl(GetPlayerOwner()).GotoFirstNode();
	R6MenuRootWindow(Root).m_PlanningWidget.CloseAllPopup();
	return;
}

defaultproperties
{
	m_iDrawStyle=5
	bUseRegion=true
	UpTexture=Texture'R6MenuTextures.Gui_03'
	DownTexture=Texture'R6MenuTextures.Gui_03'
	DisabledTexture=Texture'R6MenuTextures.Gui_03'
	OverTexture=Texture'R6MenuTextures.Gui_03'
	UpRegion=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=23586,ZoneNumber=0)
	DownRegion=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=35362,ZoneNumber=0)
	DisabledRegion=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=41250,ZoneNumber=0)
	OverRegion=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=29474,ZoneNumber=0)
}
