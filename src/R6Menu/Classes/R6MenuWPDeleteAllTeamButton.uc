//=============================================================================
// R6MenuWPDeleteAllTeamButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuWPDeleteAllTeamButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuWPDeleteAllTeamButton extends R6WindowButton;

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
	local R6PlanningCtrl OwnerCtrl;

	OwnerCtrl = R6PlanningCtrl(GetPlayerOwner());
	super(UWindowWindow).LMouseDown(X, Y);
	// End:0x2C
	if(bDisabled)
	{
		return;
	}
	// End:0x116
	if((((OwnerCtrl.m_pTeamInfo[0].GetNbActionPoint() != 0) || (OwnerCtrl.m_pTeamInfo[1].GetNbActionPoint() != 0)) || (OwnerCtrl.m_pTeamInfo[2].GetNbActionPoint() != 0)))
	{
		R6MenuRootWindow(Root).m_PlanningWidget.Hide3DAndLegend();
		R6MenuRootWindow(Root).SimplePopUp(Localize("PlanningMenu", "WAYPOINTS", "R6Menu"), Localize("PlanningMenu", "DeleteAllTeam", "R6Menu"), 45);
	}
	return;
}

simulated function Click(float X, float Y)
{
	super(UWindowButton).Click(X, Y);
	GetPlayerOwner().__NFUN_264__(R6PlanningCtrl(GetPlayerOwner()).m_PlanningBadClickSnd, 9) /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/;
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
	UpRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=14370,ZoneNumber=0)
	DownRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=14370,ZoneNumber=0)
	DisabledRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=14370,ZoneNumber=0)
	OverRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=14370,ZoneNumber=0)
}
