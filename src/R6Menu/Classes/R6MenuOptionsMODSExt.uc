//=============================================================================
// R6MenuOptionsMODSExt - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6MenuOptionsMODSExt extends R6MenuOptionsMODS;

function Created()
{
	return;
}

function InitPageOptions()
{
	local float fXOffset, fYOffset;

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

	// End:0x223 [Loop If]
	if((i < pModManager.GetNbMods()))
	{
		pTempMod = pModManager.m_aMods[i];
		NewItem = R6WindowListBoxItem(m_pListOfMods.FindItemWithName(pTempMod.m_szKeyWord));
		// End:0xAC
		if(pModManager.IsOfficialMod(pTempMod.m_szKeyWord))
		{
			// [Explicit Continue]
			goto J0x219;
		}
		// End:0xE8
		if((NewItem == none))
		{
			NewItem = R6WindowListBoxItem(m_pListOfMods.Items.Append(m_pListOfMods.ListClass));
		}
		NewItem.SetItemParameters(0, pTempMod.m_szName, Root.Fonts[5], 5.0000000, 2.0000000, WinWidth, 15.0000000, 0, 0);
		szInstallStatus = Localize("MISC", "Installed", "R6Mod");
		m_pListOfMods.SetItemState(NewItem, m_pListOfMods.0, true);
		NewItem.SetItemParameters(1, szInstallStatus, Root.Fonts[5], (WinWidth - float(5)), 2.0000000, WinWidth, 15.0000000, 0, 1);
		NewItem.SetItemParameters(2, pTempMod.m_szModInfo, Root.Fonts[5], 5.0000000, 0.0000000, WinWidth, 15.0000000, 1, 0);
		NewItem.HelpText = pTempMod.m_szKeyWord;
		J0x219:

		(i++);
		// [Loop Continue]
		goto J0x31;
	}
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0x46
	if((int(E) == 2))
	{
		// End:0x43
		if(C.IsA('R6WindowButton'))
		{
			// End:0x43
			if((C == m_pGeneralButUse))
			{
				Log("DE_Click");
				ActiveMod();
			}
		}		
	}
	else
	{
		// End:0x7B
		if((int(E) == 11))
		{
			// End:0x7B
			if((C == m_pListOfMods))
			{
				Log("DE_DoubleClick");
				ActiveMod();
			}
		}
	}
	return;
}

function ActiveMod()
{
	local array<UWindowRootWindow.eGameWidgetID> AWIDList;

	// End:0xB3
	if(((m_pListOfMods != none) && (m_pListOfMods.m_SelectedItem != none)))
	{
		Class'Engine.Actor'.static.GetModMgr().m_szPendingModName = m_pListOfMods.m_SelectedItem.HelpText;
		Class'Engine.Actor'.static.GetModMgr().SetCurrentMod(m_pListOfMods.m_SelectedItem.HelpText, GetLevel(), true);
		AWIDList[AWIDList.Length] = 20;
		R6Console(Root.Console).CleanAndChangeMod(AWIDList);
	}
	return;
}
