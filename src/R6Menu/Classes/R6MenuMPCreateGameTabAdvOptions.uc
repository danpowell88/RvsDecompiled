//=============================================================================
//  R6MenuMPCreateGameTabAdvOptions.uc : class for advanced options
//
//  Copyright 2003 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/07/10  * Create by Yannick Joly
//=============================================================================
class R6MenuMPCreateGameTabAdvOptions extends R6MenuMPCreateGameTab;

var R6WindowTextLabelExt                m_pAdvOptionsLineW;				// a window to draw a line in the middle -- avoid the use of paint here

//*******************************************************************************************
// INIT
//*******************************************************************************************
function Created()
{
	Super.Created();
}

function InitAdvOptionsTab( optional BOOL _bInGame)
{
    local FLOAT fXOffset, fYOffset, fWidth, fHeight;
	local INT i;

    // it's a text label ext because you want to draw the line in the middle (small hack)
    m_pAdvOptionsLineW = R6WindowTextLabelExt( CreateWindow(class'R6WindowTextLabelExt', 0, 0, 2*K_HALFWINDOWWIDTH, WinHeight, self));
    m_pAdvOptionsLineW.bAlwaysBehind = true;
    // draw middle line
    m_pAdvOptionsLineW.ActiveBorder( 0, false);                                         // Top border
    m_pAdvOptionsLineW.ActiveBorder( 1, false);                                         // Bottom border
    m_pAdvOptionsLineW.SetBorderParam( 2, K_HALFWINDOWWIDTH, 1, 1, Root.Colors.White);  // Left border
    m_pAdvOptionsLineW.ActiveBorder( 3, false);                                         // Rigth border

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

	// LEFT PART
    fXOffset = 5;
	fYOffset = 5;
    fWidth	 = K_HALFWINDOWWIDTH - fXOffset - 10; //10 substract small value to distance the check box from middle line
    fHeight  = WinHeight - fYOffset;

	for (i =0; i < m_ANbOfGameMode.Length; i++)
	{
		CreateListOfButtons( fXOffset, fYOffset, fWidth, fHeight, m_ANbOfGameMode[i], eCGW_LeftAdvOpt);
	}

	// RIGHT PART is not use right now
//    fXOffset = 5 + K_HALFWINDOWWIDTH;

//	for (i =0; i < m_ANbOfGameMode.Length; i++)
//	{
//		CreateListOfButtons( fXOffset, fYOffset, fWidth, fHeight, m_ANbOfGameMode[i], , eCGW_RightAdvOpt); // modify to use a list with a scroll bar?
//	}

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

//	RefreshServerOpt();

	m_bInitComplete = true;
}

//===============================================================
// UpdateButtons: do the init of the buttons you need
//===============================================================
function UpdateButtons( Actor.EGameModeInfo _eGameMode, eCreateGameWindow_ID _eCGWindowID, optional BOOL _bUpdateValue)
{
	local R6WindowListGeneral pTempList; 
	local R6ServerInfo pServerInfo;

	pTempList = R6WindowListGeneral(GetList( _eGameMode, _eCGWindowID));

#ifdefDEBUG
	if (m_bShowLog)
		log("UpdateButtons pTempList"@pTempList@"for _eCGWindowID"@_eCGWindowID);
#endif

	if (pTempList == None)
		return;

	if (_bUpdateValue)
		pServerInfo = class'Actor'.static.GetServerOptions();

	switch(_eGameMode)
	{
		case GetPlayerOwner().EGameModeInfo.GMI_Adversarial:
			switch(_eCGWindowID)
			{
				case eCGW_LeftAdvOpt:
					if (_bUpdateValue)
					{
//#ifdefR6PUNKBUSTER
						if (class'Actor'.static.GetGameOptions().m_bPBInstalled)
							m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_PunkBuster,  (GetLevel().iPBEnabled>0),		 pTempList);
						else
							m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_PunkBuster,   false,						 pTempList, true);
//#endif
					}
					else
					{
//#ifdefR6PUNKBUSTER
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_PunkBuster,      false, pTempList, self);
//#endif
					}
					break;
				default:
					break;
			}
			break;
		case GetPlayerOwner().EGameModeInfo.GMI_Cooperative:
			switch(_eCGWindowID)
			{
				case eCGW_LeftAdvOpt:
					if (_bUpdateValue)
					{
//#ifdefR6PUNKBUSTER
						if (class'Actor'.static.GetGameOptions().m_bPBInstalled)
							m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_PunkBuster,		 (GetLevel().iPBEnabled>0),		pTempList, false);
						else
							m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_PunkBuster,		 false,							pTempList, true);
//#endif
					}
					else
					{
//#ifdefR6PUNKBUSTER
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_PunkBuster,      false, pTempList, self);
//#endif
					}
					break;
				default:
					break;
			}
			break;
		default:
			log("UpdateButtons not a valid game mode");
			break;
	}
}

//*******************************************************************************************
// UTILITIES FUNCTIONS
//*******************************************************************************************


//*******************************************************************************************
// SERVER OPTIONS FUNCTIONS
//*******************************************************************************************
function SetServerOptions()
{
    local R6ServerInfo _ServerSettings;
	local R6WindowListGeneral pListGen;
	local BOOL bPBButtonValue;

#ifdefDEBUG
	local BOOL bShowLog;
	bShowLog = true;
	if (bShowLog)
	{
		log("R6MenuMPCreateGameTabAdvOptions SetServerOptions");
	}
#endif    

    _ServerSettings = class'Actor'.static.GetServerOptions();
	pListGen = R6WindowListGeneral(GetList(GetCurrentGameMode(), eCGW_LeftAdvOpt));

	if (pListGen == None)
		return;
		
//#ifdefR6PUNKBUSTER
	bPBButtonValue = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_PunkBuster, pListGen);
    class'Actor'.static.SetPBStatus(!bPBButtonValue,true);
	if (bPBButtonValue == true)
	    class'Actor'.static.SetPBStatus(false,false);
	
	
//#endif    	
}

defaultproperties
{
}
