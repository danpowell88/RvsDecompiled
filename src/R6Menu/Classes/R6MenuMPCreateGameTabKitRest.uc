//=============================================================================
// R6MenuMPCreateGameTabKitRest - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMPCreateGameTabKitRest.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/07/11  * Create by Yannick Joly
//=============================================================================
class R6MenuMPCreateGameTabKitRest extends R6MenuMPCreateGameTab;

// RESTRICTION KIT
var R6MenuMPRestKitMain m_pMainRestriction;

//*******************************************************************************************
// INIT
//*******************************************************************************************
function Created()
{
	super.Created();
	return;
}

function InitKitTab()
{
	m_pMainRestriction = R6MenuMPRestKitMain(CreateWindow(Class'R6Menu.R6MenuMPRestKitMain', 0.0000000, 0.0000000, WinWidth, WinHeight, self));
	m_pMainRestriction.bAlwaysBehind = true;
	m_pMainRestriction.CreateKitRestriction();
	return;
}

//*******************************************************************************************
// SERVER OPTIONS FUNCTIONS
//*******************************************************************************************
function SetServerOptions()
{
	local int iCounter, jCounter;
	local R6ServerInfo _ServerSettings;

	_ServerSettings = Class'Engine.Actor'.static.GetServerOptions();
	_ServerSettings.ClearSettings();
	jCounter = 0;
	iCounter = 0;
	J0x2F:

	// End:0xBE [Loop If]
	if((iCounter < m_pMainRestriction.m_pSubMachinesGunsTab.m_ASubMachineGuns.Length))
	{
		// End:0xB4
		if(m_pMainRestriction.m_pSubMachinesGunsTab.m_pSubMachineGuns[iCounter].m_bSelected)
		{
			_ServerSettings.RestrictedSubMachineGuns[jCounter] = m_pMainRestriction.m_pSubMachinesGunsTab.m_ASubMachineGuns[iCounter];
			(jCounter++);
		}
		(iCounter++);
		// [Loop Continue]
		goto J0x2F;
	}
	jCounter = 0;
	iCounter = 0;
	J0xCC:

	// End:0x15B [Loop If]
	if((iCounter < m_pMainRestriction.m_pShotgunsTab.m_AShotguns.Length))
	{
		// End:0x151
		if(m_pMainRestriction.m_pShotgunsTab.m_pShotguns[iCounter].m_bSelected)
		{
			_ServerSettings.RestrictedShotGuns[jCounter] = m_pMainRestriction.m_pShotgunsTab.m_AShotguns[iCounter];
			(jCounter++);
		}
		(iCounter++);
		// [Loop Continue]
		goto J0xCC;
	}
	jCounter = 0;
	iCounter = 0;
	J0x169:

	// End:0x1F8 [Loop If]
	if((iCounter < m_pMainRestriction.m_pAssaultRifleTab.m_AAssaultRifle.Length))
	{
		// End:0x1EE
		if(m_pMainRestriction.m_pAssaultRifleTab.m_pAssaultRifle[iCounter].m_bSelected)
		{
			_ServerSettings.RestrictedAssultRifles[jCounter] = m_pMainRestriction.m_pAssaultRifleTab.m_AAssaultRifle[iCounter];
			(jCounter++);
		}
		(iCounter++);
		// [Loop Continue]
		goto J0x169;
	}
	jCounter = 0;
	iCounter = 0;
	J0x206:

	// End:0x295 [Loop If]
	if((iCounter < m_pMainRestriction.m_pMachineGunsTab.m_AMachineGuns.Length))
	{
		// End:0x28B
		if(m_pMainRestriction.m_pMachineGunsTab.m_pMachineGuns[iCounter].m_bSelected)
		{
			_ServerSettings.RestrictedMachineGuns[jCounter] = m_pMainRestriction.m_pMachineGunsTab.m_AMachineGuns[iCounter];
			(jCounter++);
		}
		(iCounter++);
		// [Loop Continue]
		goto J0x206;
	}
	jCounter = 0;
	iCounter = 0;
	J0x2A3:

	// End:0x332 [Loop If]
	if((iCounter < m_pMainRestriction.m_pSniperRifleTab.m_ASniperRifle.Length))
	{
		// End:0x328
		if(m_pMainRestriction.m_pSniperRifleTab.m_pSniperRifle[iCounter].m_bSelected)
		{
			_ServerSettings.RestrictedSniperRifles[jCounter] = m_pMainRestriction.m_pSniperRifleTab.m_ASniperRifle[iCounter];
			(jCounter++);
		}
		(iCounter++);
		// [Loop Continue]
		goto J0x2A3;
	}
	jCounter = 0;
	iCounter = 0;
	J0x340:

	// End:0x3CF [Loop If]
	if((iCounter < m_pMainRestriction.m_pPistolTab.m_APistol.Length))
	{
		// End:0x3C5
		if(m_pMainRestriction.m_pPistolTab.m_pPistol[iCounter].m_bSelected)
		{
			_ServerSettings.RestrictedPistols[jCounter] = m_pMainRestriction.m_pPistolTab.m_APistol[iCounter];
			(jCounter++);
		}
		(iCounter++);
		// [Loop Continue]
		goto J0x340;
	}
	jCounter = 0;
	iCounter = 0;
	J0x3DD:

	// End:0x46C [Loop If]
	if((iCounter < m_pMainRestriction.m_pMachinePistolTab.m_AMachinePistol.Length))
	{
		// End:0x462
		if(m_pMainRestriction.m_pMachinePistolTab.m_pMachinePistol[iCounter].m_bSelected)
		{
			_ServerSettings.RestrictedMachinePistols[jCounter] = m_pMainRestriction.m_pMachinePistolTab.m_AMachinePistol[iCounter];
			(jCounter++);
		}
		(iCounter++);
		// [Loop Continue]
		goto J0x3DD;
	}
	jCounter = 0;
	iCounter = 0;
	J0x47A:

	// End:0x512 [Loop If]
	if((iCounter < m_pMainRestriction.m_pPriWpnGadgetTab.m_APriWpnGadget.Length))
	{
		// End:0x508
		if(m_pMainRestriction.m_pPriWpnGadgetTab.m_pPriWpnGadget[iCounter].m_bSelected)
		{
			_ServerSettings.RestrictedPrimary[jCounter] = m_pMainRestriction.m_pPriWpnGadgetTab.m_pPriWpnGadget[iCounter].m_szMiscText;
			(jCounter++);
		}
		(iCounter++);
		// [Loop Continue]
		goto J0x47A;
	}
	jCounter = 0;
	iCounter = 0;
	J0x520:

	// End:0x5B8 [Loop If]
	if((iCounter < m_pMainRestriction.m_pSecWpnGadgetTab.m_ASecWpnGadget.Length))
	{
		// End:0x5AE
		if(m_pMainRestriction.m_pSecWpnGadgetTab.m_pSecWpnGadget[iCounter].m_bSelected)
		{
			_ServerSettings.RestrictedSecondary[jCounter] = m_pMainRestriction.m_pSecWpnGadgetTab.m_pSecWpnGadget[iCounter].m_szMiscText;
			(jCounter++);
		}
		(iCounter++);
		// [Loop Continue]
		goto J0x520;
	}
	jCounter = 0;
	iCounter = 0;
	J0x5C6:

	// End:0x65E [Loop If]
	if((iCounter < m_pMainRestriction.m_pMiscGadgetTab.m_AMiscGadget.Length))
	{
		// End:0x654
		if(m_pMainRestriction.m_pMiscGadgetTab.m_pMiscGadget[iCounter].m_bSelected)
		{
			_ServerSettings.RestrictedMiscGadgets[jCounter] = m_pMainRestriction.m_pMiscGadgetTab.m_pMiscGadget[iCounter].m_szMiscText;
			(jCounter++);
		}
		(iCounter++);
		// [Loop Continue]
		goto J0x5C6;
	}
	return;
}

