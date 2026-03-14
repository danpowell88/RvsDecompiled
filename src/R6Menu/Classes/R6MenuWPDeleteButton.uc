//=============================================================================
// R6MenuWPDeleteButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuWPDeleteButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuWPDeleteButton extends R6WindowButton;

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
	return;
}

simulated function Click(float X, float Y)
{
	super(UWindowButton).Click(X, Y);
	R6PlanningCtrl(GetPlayerOwner()).DeleteOneNode();
	R6MenuRootWindow(Root).m_PlanningWidget.CloseAllPopup();
	return;
}

defaultproperties
{
	m_iDrawStyle=5
	bUseRegion=true
	m_bPlayButtonSnd=false
	UpTexture=Texture'R6MenuTextures.Gui_03'
	DownTexture=Texture'R6MenuTextures.Gui_03'
	DisabledTexture=Texture'R6MenuTextures.Gui_03'
	OverTexture=Texture'R6MenuTextures.Gui_03'
	UpRegion=(Zone=Class'R6Menu.R6MenuRootWindow',iLeaf=7202,ZoneNumber=0)
	DownRegion=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=11810,ZoneNumber=0)
	DisabledRegion=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=17698,ZoneNumber=0)
	OverRegion=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=5922,ZoneNumber=0)
}
