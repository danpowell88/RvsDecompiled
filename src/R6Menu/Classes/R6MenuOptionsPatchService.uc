//=============================================================================
// R6MenuOptionsPatchService - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6MenuOptionsPatchService extends R6MenuOptionsTab;

var float m_lastUpdateServiceClick;
var R6WindowButtonBox m_pOptionAutoPatchDownload;
var R6WindowButton m_pStartDownloadButton;
var R6WindowWrappedTextArea m_pPatchStatus;

function InitPageOptions()
{
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight;

	local bool bUpdateAllowed;

	bUpdateAllowed = Class'R6GameService.eviLPatchService'.static.__NFUN_3109__();
	m_lastUpdateServiceClick = 0.0000000;
	fXOffset = 5.0000000;
	fYOffset = 5.0000000;
	fWidth = __NFUN_175__(__NFUN_175__(WinWidth, fXOffset), float(40));
	fHeight = 15.0000000;
	fYStep = 27.0000000;
	m_pOptionAutoPatchDownload = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pOptionAutoPatchDownload.SetButtonBox(false);
	m_pOptionAutoPatchDownload.CreateTextAndBox(Localize("Options", "Opt_PatchServiceAutoDownload", "R6Menu"), Localize("Tip", "Opt_PatchServiceAutoDownload", "R6Menu"), 0.0000000, 2, false, true);
	m_pOptionAutoPatchDownload.bDisabled = __NFUN_129__(bUpdateAllowed);
	__NFUN_184__(fYOffset, fYStep);
	m_pStartDownloadButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pStartDownloadButton.Text = Localize("Options", "ButtonStartPatchDownload", "R6Menu");
	m_pStartDownloadButton.ToolTipString = Localize("Tip", "ButtonStartPatchDownload", "R6Menu");
	m_pStartDownloadButton.Align = 0;
	m_pStartDownloadButton.m_iButtonID = 0;
	m_pStartDownloadButton.bDisabled = __NFUN_129__(bUpdateAllowed);
	__NFUN_184__(fYOffset, fYStep);
	m_pPatchStatus = R6WindowWrappedTextArea(CreateWindow(Class'R6Window.R6WindowWrappedTextArea', fXOffset, fYOffset, fWidth, 248.0000000, self));
	m_pPatchStatus.SetScrollable(false);
	m_pPatchStatus.m_fXOffSet = 2.0000000;
	m_pPatchStatus.m_fYOffSet = 0.0000000;
	m_pPatchStatus.m_bDrawBorders = false;
	m_pPatchStatus.AddText(Localize("Options", "PatchStatus_Unknown", "R6Menu"), Root.Colors.BlueLight, Root.Fonts[6]);
	// End:0x317
	if(bUpdateAllowed)
	{
		InitResetButton();
		UpdateOptionsInPage();
	}
	m_bInitComplete = true;
	return;
}

function UpdateOptionsInEngine()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	pGameOptions.AutoPatchDownload = m_pOptionAutoPatchDownload.m_bSelected;
	return;
}

function UpdateOptionsInPage()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	m_pOptionAutoPatchDownload.SetButtonBox(pGameOptions.AutoPatchDownload);
	return;
}

function GetDownloadMetric(float totalBytes, out string metric, out float divider)
{
	// End:0x67
	if(__NFUN_177__(totalBytes, float(__NFUN_144__(__NFUN_144__(10, 1024), 1024))))
	{
		metric = Localize("Options", "PatchStatus_MegaBytes", "R6Menu");
		divider = __NFUN_171__(1024.0000000, float(1024));		
	}
	else
	{
		// End:0xBE
		if(__NFUN_177__(totalBytes, float(__NFUN_144__(10, 1024))))
		{
			metric = Localize("Options", "PatchStatus_KiloBytes", "R6Menu");
			divider = 1024.0000000;			
		}
		else
		{
			metric = Localize("Options", "PatchStatus_Bytes", "R6Menu");
			divider = 1.0000000;
		}
	}
	return;
}

function GetDownloadPercentageStringValues(float totalBytes, float recvdBytes, out string bytesProgress, out string percentProgress)
{
	local string strTotal, strRecvd, metric;
	local float divider;

	GetDownloadMetric(totalBytes, metric, divider);
	strTotal = string(__NFUN_172__(totalBytes, divider));
	strTotal = __NFUN_128__(strTotal, __NFUN_126__(strTotal, "."));
	strRecvd = string(__NFUN_172__(recvdBytes, divider));
	strRecvd = __NFUN_128__(strRecvd, __NFUN_126__(strRecvd, "."));
	percentProgress = string(__NFUN_172__(__NFUN_171__(100.0000000, recvdBytes), totalBytes));
	percentProgress = __NFUN_112__(__NFUN_128__(percentProgress, __NFUN_126__(percentProgress, ".")), "%");
	bytesProgress = __NFUN_112__(__NFUN_112__(__NFUN_112__(strRecvd, "/"), strTotal), metric);
	return;
}

function GetDownloadString(float totalBytes, float recvdBytes, out string Str)
{
	local string bytesProgress, percentProgress;

	// End:0x53
	if(__NFUN_130__(__NFUN_177__(totalBytes, float(0)), __NFUN_177__(recvdBytes, float(0))))
	{
		GetDownloadPercentageStringValues(totalBytes, recvdBytes, bytesProgress, percentProgress);
		Str = __NFUN_112__(__NFUN_112__(__NFUN_112__(bytesProgress, " ("), percentProgress), ")");
	}
	return;
}

function UpdatePatchStatus()
{
	local R6AbstractEviLPatchService.PatchState PatchState;
	local eviLPatchService.ExitCause ExitCause;
	local float totalBytes, fCurrentFileBytes, recvdBytes, fCurrentFileRecvdBytes;
	local string Progress, NewText;

	PatchState = Class'R6GameService.eviLPatchService'.static.GetState();
	switch(PatchState)
	{
		// End:0x62
		case 1:
			SetUpdateStatusOn(false);
			NewText = Localize("Options", "PatchStatus_Initializing", "R6Menu");
			// End:0x48B
			break;
		// End:0xEB
		case 2:
			SetUpdateStatusOn(false);
			Class'R6GameService.eviLPatchService'.static.__NFUN_3105__(totalBytes, recvdBytes, fCurrentFileBytes, fCurrentFileRecvdBytes);
			GetDownloadString(totalBytes, recvdBytes, Progress);
			NewText = __NFUN_112__(Localize("Options", "PatchStatus_DownloadVersionFile", "R6Menu"), Progress);
			// End:0x48B
			break;
		// End:0x130
		case 3:
			SetUpdateStatusOn(false);
			NewText = Localize("Options", "PatchStatus_SelectPatch", "R6Menu");
			// End:0x48B
			break;
		// End:0x1B3
		case 4:
			SetUpdateStatusOn(false);
			Class'R6GameService.eviLPatchService'.static.__NFUN_3105__(totalBytes, recvdBytes, fCurrentFileBytes, fCurrentFileRecvdBytes);
			GetDownloadString(totalBytes, recvdBytes, Progress);
			NewText = __NFUN_112__(Localize("Options", "PatchStatus_DownloadPatch", "R6Menu"), Progress);
			// End:0x48B
			break;
		// End:0x3D7
		case 5:
			SetUpdateStatusOff(true);
			ExitCause = Class'R6GameService.eviLPatchService'.static.__NFUN_3107__();
			switch(ExitCause)
			{
				// End:0x217
				case 1:
					NewText = Localize("Options", "PatchStatus_PatchStarted", "R6Menu");
					// End:0x3D4
					break;
				// End:0x257
				case 2:
					NewText = Localize("Options", "PatchStatus_NoPatchNeeded", "R6Menu");
					// End:0x3D4
					break;
				// End:0x29C
				case 3:
					NewText = Localize("Options", "PatchStatus_FatalDownloadError", "R6Menu");
					// End:0x3D4
					break;
				// End:0x2E3
				case 4:
					NewText = Localize("Options", "PatchStatus_PartialDownloadError", "R6Menu");
					// End:0x3D4
					break;
				// End:0x321
				case 5:
					NewText = Localize("Options", "PatchStatus_UserAborted", "R6Menu");
					// End:0x3D4
					break;
				// End:0x35F
				case 0:
					NewText = Localize("Options", "PatchStatus_ExitUnknown", "R6Menu");
					// End:0x3D4
					break;
				// End:0x39A
				case 6:
					NewText = Localize("Options", "PatchStatus_UserQuit", "R6Menu");
					// End:0x3D4
					break;
				// End:0xFFFF
				default:
					NewText = Localize("Options", "PatchStatus_ExitError", "R6Menu");
					// End:0x3D4
					break;
					break;
			}
			// End:0x48B
			break;
		// End:0x419
		case 6:
			SetUpdateStatusOn(false);
			NewText = Localize("Options", "PatchStatus_RunPatch", "R6Menu");
			// End:0x48B
			break;
		// End:0x453
		case 0:
			NewText = Localize("Options", "PatchStatus_Unknown", "R6Menu");
			// End:0x48B
			break;
		// End:0xFFFF
		default:
			NewText = Localize("Options", "PatchStatus_Unknown", "R6Menu");
			// End:0x48B
			break;
			break;
	}
	m_pPatchStatus.Clear(true, true);
	m_pPatchStatus.AddText(NewText, Root.Colors.BlueLight, Root.Fonts[6]);
	return;
}

function Tick(float DeltaTime)
{
	UpdatePatchStatus();
	return;
}

function SetUpdateStatusOn(bool _bPerformPSAction)
{
	// End:0x15
	if(_bPerformPSAction)
	{
		Class'R6GameService.eviLPatchService'.static.__NFUN_3102__();
	}
	m_pStartDownloadButton.Text = Localize("Options", "ButtonAbortPatchDownload", "R6Menu");
	m_pStartDownloadButton.ToolTipString = Localize("Tip", "ButtonAbortPatchDownload", "R6Menu");
	m_pStartDownloadButton.m_iButtonID = 1;
	m_pStartDownloadButton.MouseEnter();
	return;
}

function SetUpdateStatusOff(bool _bPerformPSAction)
{
	// End:0x15
	if(_bPerformPSAction)
	{
		Class'R6GameService.eviLPatchService'.static.__NFUN_3106__();
	}
	m_pStartDownloadButton.Text = Localize("Options", "ButtonStartPatchDownload", "R6Menu");
	m_pStartDownloadButton.ToolTipString = Localize("Tip", "ButtonStartPatchDownload", "R6Menu");
	m_pStartDownloadButton.m_iButtonID = 0;
	m_pStartDownloadButton.MouseEnter();
	return;
}

function ToggleUpdateStatus(bool _bPerformPSAction)
{
	// End:0x23
	if(__NFUN_154__(m_pStartDownloadButton.m_iButtonID, 0))
	{
		SetUpdateStatusOn(_bPerformPSAction);		
	}
	else
	{
		// End:0x43
		if(__NFUN_154__(m_pStartDownloadButton.m_iButtonID, 1))
		{
			SetUpdateStatusOff(_bPerformPSAction);
		}
	}
	return;
}

function RestoreDefaultValue()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	pGameOptions.ResetPatchServiceToDefault();
	UpdateOptionsInPage();
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local R6MenuOptionsWidget OptionsWidget;
	local bool bUpdateGameOptions;
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	OptionsWidget = R6MenuOptionsWidget(OwnerWindow);
	// End:0x1B4
	if(__NFUN_154__(int(E), 2))
	{
		// End:0x91
		if(C.__NFUN_303__('R6WindowButtonBox'))
		{
			// End:0x8E
			if(R6WindowButtonBox(C).GetSelectStatus())
			{
				R6WindowButtonBox(C).m_bSelected = __NFUN_129__(R6WindowButtonBox(C).m_bSelected);
				bUpdateGameOptions = true;
			}			
		}
		else
		{
			// End:0xDB
			if(C.__NFUN_303__('R6WindowButtonExt'))
			{
				// End:0xD8
				if(R6WindowButtonExt(C).GetSelectStatus())
				{
					R6WindowButtonExt(C).ChangeCheckBoxStatus();
					bUpdateGameOptions = true;
				}				
			}
			else
			{
				// End:0x1B1
				if(C.__NFUN_303__('R6WindowButton'))
				{
					// End:0x179
					if(__NFUN_114__(C, m_pGeneralButUse))
					{
						// End:0x176
						if(__NFUN_114__(C, m_pGeneralButUse))
						{
							Root.SimplePopUp(Localize("Options", "ResetToDefault", "R6Menu"), Localize("Options", "ResetToDefaultConfirm", "R6Menu"), 55, 0, false, self);
						}						
					}
					else
					{
						// End:0x1B1
						if(__NFUN_114__(C, m_pStartDownloadButton))
						{
							// End:0x1B1
							if(__NFUN_179__(__NFUN_175__(GetTime(), m_lastUpdateServiceClick), float(2)))
							{
								ToggleUpdateStatus(true);
								m_lastUpdateServiceClick = GetTime();
							}
						}
					}
				}
			}
		}		
	}
	else
	{
		// End:0x1FF
		if(C.__NFUN_303__('R6WindowComboControl'))
		{
			// End:0x1FF
			if(__NFUN_154__(int(E), 1))
			{
				// End:0x1FF
				if(__NFUN_130__(m_bInitComplete, R6WindowComboControl(C).m_bSelectedByUser))
				{
					bUpdateGameOptions = true;
				}
			}
		}
	}
	// End:0x21A
	if(bUpdateGameOptions)
	{
		UpdateOptionsInEngine();
		pGameOptions.__NFUN_536__();
	}
	return;
}
