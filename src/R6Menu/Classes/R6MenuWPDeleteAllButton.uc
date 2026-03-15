//=============================================================================
// R6MenuWPDeleteAllButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuWPDeleteAllButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuWPDeleteAllButton extends R6WindowButton;

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
	// End:0xD5
	if((R6PlanningCtrl(GetPlayerOwner()).m_pTeamInfo[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam].GetNbActionPoint() != 0))
	{
		R6MenuRootWindow(Root).m_PlanningWidget.Hide3DAndLegend();
		R6MenuRootWindow(Root).SimplePopUp(Localize("PlanningMenu", "WAYPOINTS", "R6Menu"), Localize("PlanningMenu", "DeleteAll", "R6Menu"), 44);
	}
	return;
}

simulated function Click(float X, float Y)
{
	super(UWindowButton).Click(X, Y);
	GetPlayerOwner().PlaySound(R6PlanningCtrl(GetPlayerOwner()).m_PlanningBadClickSnd, 9);
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
	UpRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=7202,ZoneNumber=0)
	DownRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=7202,ZoneNumber=0)
	DisabledRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=7202,ZoneNumber=0)
	OverRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=7202,ZoneNumber=0)
}
