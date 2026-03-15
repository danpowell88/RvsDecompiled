//=============================================================================
// R6MenuCamFloorUpButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuCamFloorUpButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuCamFloorUpButton extends R6WindowButton;

function Created()
{
	bNoKeyboard = true;
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	return;
}

function Tick(float fDelta)
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
	// End:0x7B
	if(GetPlayerOwner().IsA('R6PlanningCtrl'))
	{
		R6PlanningCtrl(GetPlayerOwner()).m_bLevelUp = 1;
		R6PlanningCtrl(GetPlayerOwner()).m_bGoLevelUp = 1;
		R6MenuRootWindow(Root).m_PlanningWidget.CloseAllPopup();
	}
	return;
}

function LMouseUp(float X, float Y)
{
	super(UWindowWindow).LMouseUp(X, Y);
	// End:0x1B
	if(bDisabled)
	{
		return;
	}
	// End:0x5E
	if(GetPlayerOwner().IsA('R6PlanningCtrl'))
	{
		R6PlanningCtrl(GetPlayerOwner()).m_bLevelUp = 0;
		R6PlanningCtrl(GetPlayerOwner()).m_bGoLevelUp = 1;
	}
	return;
}

defaultproperties
{
	m_iDrawStyle=5
	bUseRegion=true
	ImageX=3.0000000
	UpTexture=Texture'R6MenuTextures.Gui_03'
	DownTexture=Texture'R6MenuTextures.Gui_03'
	DisabledTexture=Texture'R6MenuTextures.Gui_03'
	OverTexture=Texture'R6MenuTextures.Gui_03'
	UpRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=52770,ZoneNumber=0)
	DownRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=52770,ZoneNumber=0)
	DisabledRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=52770,ZoneNumber=0)
	OverRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=52770,ZoneNumber=0)
}
