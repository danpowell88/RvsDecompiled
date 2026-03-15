//=============================================================================
// R6MenuCamTurnCounterClockwiseButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuCamTurnCounterClockwiseButton.uc : Button to turn the 2d map Counterclockwise
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/13 * Created by Joel Tremblay
//=============================================================================
class R6MenuCamTurnCounterClockwiseButton extends R6WindowButton;

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
	// End:0x64
	if(GetPlayerOwner().IsA('R6PlanningCtrl'))
	{
		R6PlanningCtrl(GetPlayerOwner()).m_bRotateCW = 1;
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
	// End:0x47
	if(GetPlayerOwner().IsA('R6PlanningCtrl'))
	{
		R6PlanningCtrl(GetPlayerOwner()).m_bRotateCW = 0;
	}
	return;
}

function MouseLeave()
{
	super(UWindowDialogControl).MouseLeave();
	// End:0x11
	if(bDisabled)
	{
		return;
	}
	// End:0x3D
	if(GetPlayerOwner().IsA('R6PlanningCtrl'))
	{
		R6PlanningCtrl(GetPlayerOwner()).m_bRotateCW = 0;
	}
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
	UpRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=21538,ZoneNumber=0)
	DownRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=21538,ZoneNumber=0)
	DisabledRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=21538,ZoneNumber=0)
	OverRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=21538,ZoneNumber=0)
}
