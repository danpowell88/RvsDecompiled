//=============================================================================
// R6MenuOptionsMODS - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6MenuOptionsMODS extends R6MenuOptionsTab;

var R6WindowListMODS m_pListOfMods;
var UWindowInfo m_pInfo;

function InitPageOptions()
{
	local float fXOffset, fYOffset;

	m_pInfo = new (none) Class'UWindow.UWindowInfo';
	m_pInfo.LoadConfig();
	m_pListOfMods = R6WindowListMODS(CreateWindow(Class'R6Window.R6WindowListMODS', 0.0000000, 0.0000000, WinWidth, (WinHeight - float(14))));
	m_pListOfMods.ListClass = Class'R6Window.R6WindowListBoxItem';
	m_pListOfMods.m_Font = Root.Fonts[6];
	m_pListOfMods.Register(self);
	m_pListOfMods.m_DoubleClickClient = OwnerWindow;
	m_pListOfMods.m_bSkipDrawBorders = true;
	m_pListOfMods.m_fItemHeight = 14.0000000;
	m_szGeneralButLoc = Localize("Options", "ActivateModButton", "R6Menu");
	m_szGeneralButTip = Localize("Tip", "ActivateModButton", "R6Menu");
	InitResetButton();
	SetMenuMODS();
	m_bInitComplete = true;
	return;
}

function SetMenuMODS()
{
	local R6WindowListBoxItem NewItem;
	local int i;
	local R6ModMgr pModManager;
	local R6Mod pTempMod;
	local string szInstallStatus;

	pModManager = Class'Engine.Actor'.static.GetModMgr();
	m_pListOfMods.Items.Clear();
	i = 0;
	J0x31:

	// End:0x1F9 [Loop If]
	if((i < m_pInfo.m_AModsInfo.Length))
	{
		NewItem = R6WindowListBoxItem(m_pListOfMods.Items.Append(m_pListOfMods.ListClass));
		NewItem.SetItemParameters(0, Localize(m_pInfo.m_AModsInfo[i], "ModName", "R6Mod", true), Root.Fonts[5], 5.0000000, 2.0000000, WinWidth, 15.0000000, 0, 0);
		szInstallStatus = Localize("MISC", "NotInstalled", "R6Mod");
		m_pListOfMods.SetItemState(NewItem, m_pListOfMods.1, true);
		NewItem.SetItemParameters(1, szInstallStatus, Root.Fonts[5], (WinWidth - float(5)), 2.0000000, WinWidth, 15.0000000, 0, 1);
		NewItem.SetItemParameters(2, Localize(m_pInfo.m_AModsInfo[i], "ModInfo", "R6Mod", true), Root.Fonts[5], 5.0000000, 0.0000000, WinWidth, 15.0000000, 1, 0);
		NewItem.HelpText = m_pInfo.m_AModsInfo[i];
		(i++);
		// [Loop Continue]
		goto J0x31;
	}
	i = 0;
	J0x200:

	// End:0x48B [Loop If]
	if((i < pModManager.GetNbMods()))
	{
		pTempMod = pModManager.m_aMods[i];
		NewItem = R6WindowListBoxItem(m_pListOfMods.FindItemWithName(pTempMod.m_szKeyWord));
		// End:0x297
		if((NewItem == none))
		{
			NewItem = R6WindowListBoxItem(m_pListOfMods.Items.Append(m_pListOfMods.ListClass));
		}
		NewItem.SetItemParameters(0, pTempMod.m_szName, Root.Fonts[5], 5.0000000, 2.0000000, WinWidth, 15.0000000, 0, 0);
		// End:0x396
		if(pModManager.CheckValidModVersion(pTempMod))
		{
			szInstallStatus = Localize("MISC", "Installed", "R6Mod");
			m_pListOfMods.SetItemState(NewItem, m_pListOfMods.1, false);
			// End:0x373
			if((pTempMod == pModManager.m_pCurrentMod))
			{
				m_pListOfMods.SetItemState(NewItem, m_pListOfMods.3, true);				
			}
			else
			{
				m_pListOfMods.SetItemState(NewItem, m_pListOfMods.0, true);
			}			
		}
		else
		{
			szInstallStatus = Localize("MISC", "VersionMM", "R6Mod");
			m_pListOfMods.SetItemState(NewItem, m_pListOfMods.1, true);
		}
		NewItem.SetItemParameters(1, szInstallStatus, Root.Fonts[5], (WinWidth - float(5)), 2.0000000, WinWidth, 15.0000000, 0, 1);
		NewItem.SetItemParameters(2, pTempMod.m_szModInfo, Root.Fonts[5], 5.0000000, 0.0000000, WinWidth, 15.0000000, 1, 0);
		NewItem.HelpText = pTempMod.m_szKeyWord;
		(i++);
		// [Loop Continue]
		goto J0x200;
	}
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0x43
	if((int(E) == 2))
	{
		// End:0x40
		if(C.IsA('R6WindowButton'))
		{
			// End:0x40
			if((C == m_pGeneralButUse))
			{
				m_pListOfMods.ActivateMOD();
			}
		}		
	}
	else
	{
		// End:0x6F
		if((int(E) == 11))
		{
			// End:0x6F
			if((C == m_pListOfMods))
			{
				m_pListOfMods.ActivateMOD();
			}
		}
	}
	return;
}
