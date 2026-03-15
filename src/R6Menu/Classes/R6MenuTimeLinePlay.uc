//=============================================================================
// R6MenuTimeLinePlay - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuTimeLinePlay.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/03 * Created by Chaouky Garram
//=============================================================================
class R6MenuTimeLinePlay extends R6WindowButton;

var bool m_bPlaying;
var Region m_ButtonRegions[8];

function Created()
{
	bNoKeyboard = true;
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	// End:0x42
	if(m_bPlaying)
	{
		UpRegion = m_ButtonRegions[0];
		OverRegion = m_ButtonRegions[1];
		DownRegion = m_ButtonRegions[2];
		DisabledRegion = m_ButtonRegions[3];		
	}
	else
	{
		UpRegion = m_ButtonRegions[4];
		OverRegion = m_ButtonRegions[5];
		DownRegion = m_ButtonRegions[6];
		DisabledRegion = m_ButtonRegions[7];
	}
	return;
}

function LMouseDown(float X, float Y)
{
	local R6PlanningCtrl OwnerCtrl;

	OwnerCtrl = R6PlanningCtrl(GetPlayerOwner());
	super(UWindowWindow).LMouseDown(X, Y);
	// End:0x5B
	if((bDisabled || (OwnerCtrl.m_pTeamInfo[OwnerCtrl.m_iCurrentTeam].GetNbActionPoint() <= 1)))
	{
		return;
	}
	// End:0xDC
	if((m_bPlaying == false))
	{
		// End:0xCB
		if(((OwnerCtrl.m_pTeamInfo[OwnerCtrl.m_iCurrentTeam].GetNbActionPoint() - 1) == OwnerCtrl.m_pTeamInfo[OwnerCtrl.m_iCurrentTeam].m_iCurrentNode))
		{
			OwnerCtrl.GotoFirstNode();
		}
		m_bPlaying = true;
		StartPlaying();		
	}
	else
	{
		m_bPlaying = false;
		StopPlaying();
	}
	R6MenuRootWindow(Root).m_PlanningWidget.CloseAllPopup();
	return;
}

function StartPlaying()
{
	R6PlanningCtrl(GetPlayerOwner()).StartPlayingPlanning();
	R6MenuTimeLineBar(OwnerWindow).ActivatePlayMode();
	return;
}

function StopPlaying()
{
	R6PlanningCtrl(GetPlayerOwner()).StopPlayingPlanning();
	R6MenuTimeLineBar(OwnerWindow).StopPlayMode();
	return;
}

defaultproperties
{
	m_ButtonRegions[0]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=12066,ZoneNumber=0)
	m_ButtonRegions[1]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=12066,ZoneNumber=0)
	m_ButtonRegions[2]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=12066,ZoneNumber=0)
	m_ButtonRegions[3]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=12066,ZoneNumber=0)
	m_ButtonRegions[4]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=36642,ZoneNumber=0)
	m_ButtonRegions[5]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=36642,ZoneNumber=0)
	m_ButtonRegions[6]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=36642,ZoneNumber=0)
	m_ButtonRegions[7]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=36642,ZoneNumber=0)
	m_iDrawStyle=5
	bUseRegion=true
	UpTexture=Texture'R6MenuTextures.Gui_03'
	DownTexture=Texture'R6MenuTextures.Gui_03'
	DisabledTexture=Texture'R6MenuTextures.Gui_03'
	OverTexture=Texture'R6MenuTextures.Gui_03'
	UpRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=12066,ZoneNumber=0)
	DownRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=12066,ZoneNumber=0)
	DisabledRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=12066,ZoneNumber=0)
	OverRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=12066,ZoneNumber=0)
}
