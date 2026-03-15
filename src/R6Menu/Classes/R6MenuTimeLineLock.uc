//=============================================================================
// R6MenuTimeLineLock - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuTimeLineLock.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/03 * Created by Chaouky Garram
//=============================================================================
class R6MenuTimeLineLock extends R6WindowButton;

var bool m_bLocked;
var Region m_ButtonRegions[8];

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
	m_bLocked = (!m_bLocked);
	R6PlanningCtrl(GetPlayerOwner()).m_bLockCamera = m_bLocked;
	// End:0x8B
	if((m_bLocked == true))
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
	R6MenuRootWindow(Root).m_PlanningWidget.CloseAllPopup();
	return;
}

function ResetCameraLock()
{
	m_bLocked = false;
	UpRegion = m_ButtonRegions[4];
	OverRegion = m_ButtonRegions[5];
	DownRegion = m_ButtonRegions[6];
	DisabledRegion = m_ButtonRegions[7];
	return;
}

defaultproperties
{
	m_ButtonRegions[0]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=41762,ZoneNumber=0)
	m_ButtonRegions[1]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=41762,ZoneNumber=0)
	m_ButtonRegions[2]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=41762,ZoneNumber=0)
	m_ButtonRegions[3]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=41762,ZoneNumber=0)
	m_ButtonRegions[4]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29986,ZoneNumber=0)
	m_ButtonRegions[5]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29986,ZoneNumber=0)
	m_ButtonRegions[6]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29986,ZoneNumber=0)
	m_ButtonRegions[7]=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29986,ZoneNumber=0)
	m_iDrawStyle=5
	bUseRegion=true
	UpTexture=Texture'R6MenuTextures.Gui_03'
	DownTexture=Texture'R6MenuTextures.Gui_03'
	DisabledTexture=Texture'R6MenuTextures.Gui_03'
	OverTexture=Texture'R6MenuTextures.Gui_03'
	UpRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29986,ZoneNumber=0)
	DownRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29986,ZoneNumber=0)
	DisabledRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29986,ZoneNumber=0)
	OverRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29986,ZoneNumber=0)
}
