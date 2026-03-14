//=============================================================================
// R6MenuDiffCustomMissionSelect - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuDiffCustomMissionSelect.uc : Little Area where you select
//										the custom mission difficulty level
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/01/29 * Created by Alexandre Dionne
//=============================================================================
class R6MenuDiffCustomMissionSelect extends UWindowDialogClientWindow
    config(User);

var config int CustomMissionDifficultyLevel;
var bool m_bAutoSave;  // this can be used to skip auto save
var R6WindowButtonBox m_pButLevel1;
var R6WindowButtonBox m_pButLevel2;
var R6WindowButtonBox m_pButLevel3;
var R6WindowButtonBox m_pButLastSel;

function Created()
{
	local R6MenuButtonsDefines pButtonsDef;
	local float fXOffset, fYOffset, fWidth, fHeight, fYStep;

	pButtonsDef = R6MenuButtonsDefines(GetButtonsDefinesUnique(Root.MenuClassDefines.ClassButtonsDefines));
	fXOffset = 5.0000000;
	fYOffset = 5.0000000;
	fWidth = __NFUN_175__(WinWidth, float(20));
	fHeight = 15.0000000;
	fYStep = __NFUN_174__(fHeight, float(16));
	m_pButLevel1 = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pButLevel1.SetButtonBox(false);
	m_pButLevel1.CreateTextAndBox(pButtonsDef.GetButtonLoc(int(19)), pButtonsDef.GetButtonLoc(int(19), true), 0.0000000, int(19));
	__NFUN_184__(fYOffset, fYStep);
	m_pButLevel2 = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pButLevel2.SetButtonBox(false);
	m_pButLevel2.CreateTextAndBox(pButtonsDef.GetButtonLoc(int(20)), pButtonsDef.GetButtonLoc(int(20), true), 0.0000000, int(20));
	__NFUN_184__(fYOffset, fYStep);
	m_pButLevel3 = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pButLevel3.SetButtonBox(false);
	m_pButLevel3.CreateTextAndBox(pButtonsDef.GetButtonLoc(int(21)), pButtonsDef.GetButtonLoc(int(21), true), 0.0000000, int(21));
	switch(__NFUN_146__(__NFUN_147__(int(19), 1), CustomMissionDifficultyLevel))
	{
		// End:0x220
		case m_pButLevel1.m_iButtonID:
			m_pButLastSel = m_pButLevel1;
			// End:0x26F
			break;
		// End:0x23F
		case m_pButLevel2.m_iButtonID:
			m_pButLastSel = m_pButLevel2;
			// End:0x26F
			break;
		// End:0x25E
		case m_pButLevel3.m_iButtonID:
			m_pButLastSel = m_pButLevel3;
			// End:0x26F
			break;
		// End:0xFFFF
		default:
			m_pButLastSel = m_pButLevel2;
			// End:0x26F
			break;
			break;
	}
	m_pButLastSel.SetButtonBox(true);
	return;
}

//We should receive 1, 2 or 3
function SetDifficulty(int iDifficulty_)
{
	switch(__NFUN_146__(__NFUN_147__(int(19), 1), iDifficulty_))
	{
		// End:0x4F
		case m_pButLevel1.m_iButtonID:
			m_pButLastSel.SetButtonBox(false);
			m_pButLevel1.SetButtonBox(true);
			m_pButLastSel = m_pButLevel1;
			// End:0xD0
			break;
		// End:0x8E
		case m_pButLevel2.m_iButtonID:
			m_pButLastSel.SetButtonBox(false);
			m_pButLevel2.SetButtonBox(true);
			m_pButLastSel = m_pButLevel2;
			// End:0xD0
			break;
		// End:0xCD
		case m_pButLevel3.m_iButtonID:
			m_pButLastSel.SetButtonBox(false);
			m_pButLevel3.SetButtonBox(true);
			m_pButLastSel = m_pButLevel3;
			// End:0xD0
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function int GetDifficulty()
{
	CustomMissionDifficultyLevel = __NFUN_146__(__NFUN_147__(m_pButLastSel.m_iButtonID, int(19)), 1);
	// End:0x29
	if(m_bAutoSave)
	{
		__NFUN_536__();
	}
	return CustomMissionDifficultyLevel;
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0x5A
	if(__NFUN_154__(int(E), 2))
	{
		// End:0x5A
		if(R6WindowButtonBox(C).GetSelectStatus())
		{
			m_pButLastSel.SetButtonBox(false);
			R6WindowButtonBox(C).SetButtonBox(true);
			m_pButLastSel = R6WindowButtonBox(C);
		}
	}
	return;
}

defaultproperties
{
	CustomMissionDifficultyLevel=2
	m_bAutoSave=true
}
