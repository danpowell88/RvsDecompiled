//=============================================================================
//  R6MenuOptionsWidget.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOptionsWidget extends R6MenuWidget;

enum eOptionsWindow
{
	OW_Game,
    OW_Sound,
    OW_Graphic,
    OW_Hud,
    OW_Multiplayer,
    OW_Controls,
	OW_MOD,
	OW_PatchService
};


// Parameters for option window (where you can change options)
const C_fXSTARTPOS                     = 198;                   // the x start pos of option window
const C_fYSTARTPOS                     = 101;                   // the y start pos of option window
const C_fWINDOWWIDTH                   = 422;                   // the size of option window 
const C_fWINDOWHEIGHT                  = 321;                   // the height of option window 
const C_fHEIGHT_OF_LABELW              = 30;                    // the height of the label window over option window  
const C_iARBITRARY_COUNTER			   = 10;					// this is an arbitary const for popup counter

var R6WindowTextLabelCurved           m_pOptionsTextLabel;      // the text label of the window option   
var R6WindowTextLabel			      m_LMenuTitle;             // the title

var R6WindowSimpleFramedWindowExt     m_pOptionsBorder;         // the border of the option window

var R6MenuHelpWindow                  m_pHelpWindow;            // the help window (tooltip)

var R6WindowButtonOptions	          m_ButtonReturn;

var R6WindowButtonOptions             m_ButtonGame;
var R6WindowButtonOptions             m_ButtonSound;
var R6WindowButtonOptions             m_ButtonGraphic;
var R6WindowButtonOptions             m_ButtonHudFilter;
var R6WindowButtonOptions             m_ButtonMultiPlayer;
var R6WindowButtonOptions             m_ButtonControls;
var	R6WindowButtonOptions			  m_ButtonMODS;
var	R6WindowButtonOptions			  m_ButtonPatchService;

var R6MenuOptionsTab                  m_pOptionsGame;
var R6MenuOptionsTab                  m_pOptionsSound;
var R6MenuOptionsTab                  m_pOptionsGraphic;
var R6MenuOptionsTab                  m_pOptionsHud;
#ifndefSPDEMO
var R6MenuOptionsTab                  m_pOptionsMulti;
#endif
var R6MenuOptionsTab                  m_pOptionsControls;
var R6MenuOptionsTab                  m_pOptionsMODS;
var R6MenuOptionsTab				  m_pOptionsPatchService;
var R6MenuOptionsTab                  m_pOptionCurrent;

var		R6WindowPopUpBox				m_pSimplePopUp;				 // a real simple pop-up

var BOOL							  m_bInGame;

//#ifdefR6PUNKBUSTER
var BOOL							  m_bPBWaitForInit;
//#endif

var String							  m_sDisplayLOGO;
var Font							  m_SmallButtonFont;

function Created()
{
#ifndefSPDEMO
    if (R6MenuInGameMultiPlayerRootWindow(Root) != None ||
        R6MenuInGameRootWindow(Root) != None) 
#endif
#ifdefSPDEMO
    if (R6MenuInGameRootWindow(Root) != None) 
#endif
	{
		m_bInGame = true;
	}

	GetRegistryKey("SOFTWARE\\Red Storm Entertainment\\RAVENSHIELD", "DisplayLOGO", m_sDisplayLOGO);

    InitTitle();
    InitOptionsWindow();
    InitOptionsButtons();

    // create the help window
    m_pHelpWindow = R6MenuHelpWindow(CreateWindow(class'R6MenuHelpWindow', 150, 429, 340, 42, self)); //std param is set in help window    
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	Root.PaintBackground( C, self);

	if (m_ButtonGraphic.m_bSelected)
	{
		C.Style = ERenderStyle.STY_Alpha;
		if (m_sDisplayLOGO ~= "New")
		// Draw New LOGO
		DrawStretchedTextureSegment( C, 544, 436, 64, 64,
									0, 0, 64, 64, Texture'R6MenuTextures.R6armpatch');
		else if (m_sDisplayLOGO ~= "None");
			// Draw Nothing
		else
			// Draw ATI LOGO
			DrawStretchedTextureSegment( C, 544, 436, 64, 64,
			0, 0, 64, 64, Texture'R6MenuTextures.ATI_Menus');
	}
}

function ShowWindow()
{
	// randomly update the background texture
	Root.SetLoadRandomBackgroundImage("Option");

	if (!m_bInGame)
	{
		m_ButtonMODS.bDisabled = (R6MenuRootWindow(Root).IsInsidePlanning() || (R6Console(Root.console).m_bStartedByGSClient)); // inside Intel/gear/planning/ menu
		if ((m_ButtonMODS.bDisabled) && (m_pOptionCurrent == m_pOptionsMODS))
			ManageOptionsSelection(eOptionsWindow.OW_Game); // go on game options, m_pOptionsMODS was desactivate
	}

	Super.ShowWindow();
}

function HideWindow()
{
	Super.HideWindow();

	// CLOSE THE R6WINDOWCOMBO CONTROL ON THE SCREEN, the focus is not loose when the window is hide
	// because the ListBox of the R6WindowComboControl is create from the root. Need to find a better solution
	Root.ActivateWindow(0, False); 
}

//#ifdefR6PUNKBUSTER
function Tick(float deltaTime)
{
	if (!m_bPBWaitForInit) // wait for PB initialization, this occurs when engine start tick
	{
		m_bPBWaitForInit = true;

		m_pOptionsMulti.SetPBOptValue();
	}
	
	// Check for PB status
	if ((m_pOptionCurrent == m_pOptionsMulti) && (m_pOptionsMulti.m_pPunkBusterOpt.m_bSelected != class'Actor'.static.IsPBClientEnabled()))
	{
        m_pOptionsMulti.SetMenuMultiValues();
	}

	// Check for patch status updates.
	if (m_pOptionCurrent == m_pOptionsPatchService && m_pOptionsPatchService.bWindowVisible )
	{
        m_pOptionsPatchService.UpdatePatchStatus();
	}
}
//#endif

function SimplePopUp( string _szTitle, string _szText, ePopUpID _ePopUpID, optional INT _iButtonsType)
{
    local R6WindowWrappedTextArea pTextZone;

    if (m_pSimplePopUp == None)
    {
        // Create PopUp frame
        m_pSimplePopUp = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
        m_pSimplePopUp.bAlwaysOnTop = true;
        m_pSimplePopUp.CreateStdPopUpWindow( _szTitle, 25, 170, 100, 300, 80, _iButtonsType);
        m_pSimplePopUp.CreateClientWindow( class'R6WindowWrappedTextArea');
        m_pSimplePopUp.m_ePopUpID = _ePopUpID;
		pTextZone = R6WindowWrappedTextArea(m_pSimplePopUp.m_ClientArea);
		pTextZone.SetScrollable(true);			
		pTextZone.m_fXOffset = 5;
		pTextZone.m_fYOffset = 5;
		pTextZone.AddText(_szText, Root.Colors.White, Root.Fonts[F_HelpWindow]);
        pTextZone.m_bDrawBorders = false;
        
    }
    else
    {        
        pTextZone = R6WindowWrappedTextArea(m_pSimplePopUp.m_ClientArea);
        pTextZone.Clear(true, true);		
        pTextZone.AddText(_szText, Root.Colors.White, Root.Fonts[F_HelpWindow]);
        m_pSimplePopUp.ModifyPopUpFrameWindow( _szTitle, 25, 170, 100, 300, 80, _iButtonsType);
        m_pSimplePopUp.m_ePopUpID = _ePopUpID;
        m_pSimplePopUp.ShowWindow(); 
    }
     

}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone( MessageBoxResult Result, ePopUpID _ePopUpID)
{    
    if ( Result == MR_OK )
    {
        switch ( _ePopUpID )
        {              
        case EPopUpID_OptionsResetDefault :
                m_pOptionCurrent.RestoreDefaultValue( m_bInGame);
                break;
                
        }
    }
}

/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
function ToolTip(string strTip) 
{
    m_pHelpWindow.ToolTip(strTip);
}

function ManageOptionsSelection( INT _OptionsChoice)
{
    // hide previous window
    if (m_pOptionCurrent != None)
    {
        m_pOptionCurrent.HideWindow();
    }

    // set new title
    SetOptionsTitle(_OptionsChoice);

    m_ButtonGame.m_bSelected          = false;
    m_ButtonSound.m_bSelected         = false;
    m_ButtonGraphic.m_bSelected       = false;
    m_ButtonHudFilter.m_bSelected     = false;
    m_ButtonMultiPlayer.m_bSelected   = false;
    m_ButtonControls.m_bSelected      = false;
	m_ButtonMODS.m_bSelected		  = false;
	m_ButtonPatchService.m_bSelected  = false;

    switch( _OptionsChoice)
    {
        case eOptionsWindow.OW_Game:
            m_pOptionCurrent = m_pOptionsGame;
            m_ButtonGame.m_bSelected    = true;
            break;
        case eOptionsWindow.OW_Sound:
            m_pOptionCurrent = m_pOptionsSound;
            m_ButtonSound.m_bSelected    = true;
            break;
        case eOptionsWindow.OW_Graphic:
            m_pOptionCurrent = m_pOptionsGraphic;
            m_ButtonGraphic.m_bSelected    = true;
            break;
        case eOptionsWindow.OW_Hud:
            m_pOptionCurrent = m_pOptionsHud;
            m_ButtonHudFilter.m_bSelected    = true;
            break;
#ifndefSPDEMO
        case eOptionsWindow.OW_Multiplayer:
            m_pOptionCurrent = m_pOptionsMulti;
            m_ButtonMultiPlayer.m_bSelected    = true;
            break;
#endif
        case eOptionsWindow.OW_Controls:
            m_pOptionCurrent = m_pOptionsControls;
            m_ButtonControls.m_bSelected    = true;
            break;

		case eOptionsWindow.OW_MOD:
			m_pOptionCurrent = m_pOptionsMODS;
            m_ButtonMODS.m_bSelected    = true;
			break;

		case eOptionsWindow.OW_PatchService:
			m_pOptionCurrent = m_pOptionsPatchService;
            m_ButtonPatchService.m_bSelected   = true;
			break;
        default:
            m_pOptionCurrent = None;
            log("No options window supported");
            break;
    }

    //display next window
    if (m_pOptionCurrent != None)
    {
        m_pOptionCurrent.ShowWindow(); 
    }
}


//=============================================================================================
// SetOptionsTitle: set the option title text
//=============================================================================================
function SetOptionsTitle( INT _OptionsChoice)
{
    local string szTitle;

    switch( _OptionsChoice)
    {
        case eOptionsWindow.OW_Game:
            szTitle = Localize("Options","ButtonGame","R6Menu");
            break;
        case eOptionsWindow.OW_Sound:
            szTitle = Localize("Options","ButtonSound","R6Menu");
            break;
        case eOptionsWindow.OW_Graphic:
            szTitle = Localize("Options","ButtonGraphic","R6Menu");
            break;
        case eOptionsWindow.OW_Hud:
            szTitle = Localize("Options","ButtonHud","R6Menu");
            break;
        case eOptionsWindow.OW_Multiplayer:
            szTitle = Localize("Options","ButtonMultiPlayer","R6Menu");
            break;
        case eOptionsWindow.OW_Controls:
            szTitle = Localize("Options","ButtonControls","R6Menu");
            break;
		case eOptionsWindow.OW_MOD:
			szTitle = Localize("Options","ButtonCustomGame","R6Menu");
			break;
		case eOptionsWindow.OW_PatchService:
			szTitle = Localize("Options","ButtonPatchService","R6Menu");
			break;
        default:
            szTitle = "";
            break;
    }

    if (m_pOptionsTextLabel != None)
    {
        m_pOptionsTextLabel.SetNewText( szTitle, true);
    }
}


//=============================================================================================
// UpdateOptions: Update the options that's are not change directly in R6MenuOptionsTab
//=============================================================================================
function UpdateOptions()
{
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

    // OPTION GAME
	m_pOptionsGame.SetGameValues();

    // OPTION SOUND
    m_pOptionsSound.SetSoundValues();

    // OPTION GRAPHIC
    pGameOptions.m_bChangeResolution = (m_bInGame && !Root.m_bWidgetResolutionFix);
    m_pOptionsGraphic.SetGraphicValues();

    // OPTION HUD FILTERS
    m_pOptionsHud.SetHudValues();

    // OPTION PATCH SERVICE
    m_pOptionsPatchService.SetPatchServiceValues();

    // OPTION MULTIPLAYER
#ifndefSPDEMO
	m_pOptionsMulti.SetMultiValues();
#endif

    // OPTION CONTROLS
//    m_pOptionsControls

	pGameOptions.SaveConfig();

	GetPlayerOwner().SetSoundOptions();    // set the sound options
	GetPlayerOwner().UpdateOptions(); // set the game-mouse options

    if(m_bInGame)
    {
        R6HUD(GetPlayerOwner().myHUD).UpdateHudFilter();
		R6PlayerController(GetPlayerOwner()).UpdateTriggerLagInfo();

		if (!Root.m_bWidgetResolutionFix)
			Root.SetResolution( pGameOptions.R6ScreenSizeX, pGameOptions.R6ScreenSizeY);
    }
}

//=============================================================================================
// RefreshOptions: Refresh the options only when this window is activated
//=============================================================================================
function RefreshOptions()
{
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

    // OPTION GAME
	m_pOptionsGame.SetMenuGameValues();

    // OPTION SOUND
    m_pOptionsSound.SetMenuSoundValues();

    // OPTION GRAPHIC
    m_pOptionsGraphic.SetMenuGraphicValues();

    // OPTION HUD FILTERS
    m_pOptionsHud.SetMenuHudValues();

    // OPTION MULTIPLAYER
#ifndefSPDEMO
	m_pOptionsMulti.SetMenuMultiValues();
#endif

    // OPTION PATCH SERVICE
    m_pOptionsPatchService.SetMenuPatchServiceValues();

    // OPTION CONTROLS
    m_pOptionsControls.RefreshKeyList();
}


//===========================================================================================
// MenuLoadProfile: A new profiles is load, refresh the options
//===========================================================================================
function MenuOptionsLoadProfile()
{
	RefreshOptions();
	UpdateOptions();
}








//*********************************
//      INIT CREATE FUNCTION
//*********************************
function InitTitle()
{
	m_LMenuTitle = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, 18, WinWidth - 8, 25, self));
	m_LMenuTitle.Text           = Localize("Options","Title","R6Menu");
	m_LMenuTitle.Align          = TA_Right;
	m_LMenuTitle.m_Font         = Root.Fonts[F_MenuMainTitle];	
	m_LMenuTitle.m_BGTexture    = None;
    m_LMenuTitle.m_bDrawBorders = False;
}

function InitOptionsWindow()
{
	class'Actor'.static.GetGameOptions().m_bChangeResolution = m_bInGame; // reset changeresolution

	m_pOptionsTextLabel = R6WindowTextLabelCurved(CreateWindow(class'R6WindowTextLabelCurved', C_fXSTARTPOS, C_fYSTARTPOS - C_fHEIGHT_OF_LABELW +1, C_fWINDOWWIDTH, C_fHEIGHT_OF_LABELW, self)); //+1 because we want the windows to overlap
    m_pOptionsTextLabel.bAlwaysBehind = true;
    m_pOptionsTextLabel.Align         = TA_Center;
    m_pOptionsTextLabel.m_Font        = Root.Fonts[F_SmallTitle];        
    //m_pOptionsTextLabel.m_BGTexture   = None; // no background
    SetOptionsTitle(eOptionsWindow.OW_Game);

    m_pOptionsBorder = R6WindowSimpleFramedWindowExt(CreateWindow(class'R6WindowSimpleFramedWindowExt', C_fXSTARTPOS, C_fYSTARTPOS, C_fWINDOWWIDTH, C_fWINDOWHEIGHT, self));
    m_pOptionsBorder.bAlwaysBehind = true;
    m_pOptionsBorder.ActiveBorder( 0, false);                    // Top border
    m_pOptionsBorder.SetBorderParam( 1, 7, 0, 1, Root.Colors.White);         // Bottom border
    m_pOptionsBorder.SetBorderParam( 2, 1, 1, 1, Root.Colors.White);     // Left border
    m_pOptionsBorder.SetBorderParam( 3, 1, 1, 1, Root.Colors.White);     // Rigth border
    
    m_pOptionsBorder.m_eCornerType = Bottom_Corners;
    m_pOptionsBorder.SetCornerColor( 2, Root.Colors.White);

	m_pOptionsBorder.ActiveBackGround( true, Root.Colors.Black);         // draw background

    // create all the window options and hide it except the first one
	// this is create the same instance for each options... for optimization, maybe we will need to use specific class
    // OPTION GAME
	m_pOptionsGame = R6MenuOptionsTab(CreateWindow(class'R6MenuOptionsTab', C_fXSTARTPOS + m_pOptionsBorder.m_fVBorderOffset, C_fYSTARTPOS, C_fWINDOWWIDTH - (2*m_pOptionsBorder.m_fVBorderOffset), C_fWINDOWHEIGHT, self));
    m_pOptionsGame.InitOptionGame();

    // OPTION SOUND
	m_pOptionsSound = R6MenuOptionsTab(CreateWindow(class'R6MenuOptionsTab', C_fXSTARTPOS + m_pOptionsBorder.m_fVBorderOffset, C_fYSTARTPOS, C_fWINDOWWIDTH - (2*m_pOptionsBorder.m_fVBorderOffset), C_fWINDOWHEIGHT, self));
    m_pOptionsSound.InitOptionSound( m_bInGame);
    m_pOptionsSound.HideWindow();

    // OPTION GRAPHIC
	m_pOptionsGraphic = R6MenuOptionsTab(CreateWindow(class'R6MenuOptionsTab', C_fXSTARTPOS + m_pOptionsBorder.m_fVBorderOffset, C_fYSTARTPOS, C_fWINDOWWIDTH - (2*m_pOptionsBorder.m_fVBorderOffset), C_fWINDOWHEIGHT, self));
    m_pOptionsGraphic.InitOptionGraphic( m_bInGame);
    m_pOptionsGraphic.HideWindow();

    // OPTION HUD FILTERS
	m_pOptionsHud = R6MenuOptionsTab(CreateWindow(class'R6MenuOptionsTab', C_fXSTARTPOS + m_pOptionsBorder.m_fVBorderOffset, C_fYSTARTPOS, C_fWINDOWWIDTH - (2*m_pOptionsBorder.m_fVBorderOffset), C_fWINDOWHEIGHT, self));
    m_pOptionsHud.InitOptionHud();
    m_pOptionsHud.HideWindow();

    // OPTION MULTIPLAYER
#ifndefSPDEMO
	m_pOptionsMulti = R6MenuOptionsTab(CreateWindow(class'R6MenuOptionsTab', C_fXSTARTPOS + m_pOptionsBorder.m_fVBorderOffset, C_fYSTARTPOS, C_fWINDOWWIDTH - (2*m_pOptionsBorder.m_fVBorderOffset), C_fWINDOWHEIGHT, self));
    m_pOptionsMulti.InitOptionMulti( m_bInGame);
    m_pOptionsMulti.HideWindow();
#endif

    // OPTION CONTROLS
	m_pOptionsControls = R6MenuOptionsTab(CreateWindow(class'R6MenuOptionsTab', C_fXSTARTPOS + m_pOptionsBorder.m_fVBorderOffset, C_fYSTARTPOS, C_fWINDOWWIDTH - (2*m_pOptionsBorder.m_fVBorderOffset), C_fWINDOWHEIGHT, self));
    m_pOptionsControls.InitOptionControls();
    m_pOptionsControls.HideWindow();

	// OPTION MODS
	m_pOptionsMODS = R6MenuOptionsTab(CreateWindow(class'R6MenuOptionsTab', C_fXSTARTPOS + m_pOptionsBorder.m_fVBorderOffset, C_fYSTARTPOS, C_fWINDOWWIDTH - (2*m_pOptionsBorder.m_fVBorderOffset), C_fWINDOWHEIGHT, self));
    m_pOptionsMODS.InitOptionMods();
    m_pOptionsMODS.HideWindow();

	// OPTION PATCH SYSTEM
	 m_pOptionsPatchService = R6MenuOptionsTab(CreateWindow(class'R6MenuOptionsTab', C_fXSTARTPOS + m_pOptionsBorder.m_fVBorderOffset, C_fYSTARTPOS, C_fWINDOWWIDTH - (2*m_pOptionsBorder.m_fVBorderOffset), C_fWINDOWHEIGHT, self));
     m_pOptionsPatchService.InitOptionPatchService();
     m_pOptionsPatchService.HideWindow();




    m_pOptionCurrent = m_pOptionsGame;
}


function InitOptionsButtons()
{
	local Font buttonFont;
    local FLOAT fXOffset, fYOffset, fWidth, fHeight, fYPos;

	buttonFont		  = Root.Fonts[F_PrincipalButton];
	m_SmallButtonFont = Root.Fonts[F_SmallTitle];

    // define Return Button
	m_ButtonReturn = R6WindowButtonOptions(CreateWindow( class'R6WindowButtonOptions', 10, 425, 250, 25, self));
    m_ButtonReturn.ToolTipString = Localize("Tip","ButtonReturn","R6Menu");
    m_ButtonReturn.Text = Localize("Options","ButtonReturn","R6Menu");
    m_ButtonReturn.m_eButton_Action = Button_Return;
	m_ButtonReturn.Align = TA_Left;	
	m_ButtonReturn.m_buttonFont = buttonFont;
	m_ButtonReturn.CheckToDownSizeFont(Root.Fonts[F_VerySmallTitle],0);
	m_ButtonReturn.ResizeToText();	
    

    fXOffset = 10;
    fYPos    = 64;
    fYOffset = 26;

    fWidth   = 189;
    fHeight  = 25;
    

    // define GAME button
	m_ButtonGame = R6WindowButtonOptions(CreateWindow( class'R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
    m_ButtonGame.ToolTipString = Localize("Tip","ButtonGame","R6Menu");
    m_ButtonGame.Text = Localize("Options","ButtonGame","R6Menu");
	m_ButtonGame.m_eButton_Action = Button_Game;
	m_ButtonGame.Align = TA_Left;	
	m_ButtonGame.m_buttonFont = buttonFont;
	m_ButtonGame.CheckToDownSizeFont( m_SmallButtonFont, 0);
	m_ButtonGame.ResizeToText();
    m_ButtonGame.m_bSelected = true;
	
    fYPos += fYOffset;
    // define SOUND button
	m_ButtonSound = R6WindowButtonOptions(CreateWindow( class'R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
    m_ButtonSound.ToolTipString = Localize("Tip","ButtonSound","R6Menu");
    m_ButtonSound.Text = Localize("Options","ButtonSound","R6Menu");
	m_ButtonSound.m_eButton_Action = Button_Sound;
	m_ButtonSound.Align = TA_Left;	
	m_ButtonSound.m_buttonFont = buttonFont;
	m_ButtonSound.CheckToDownSizeFont( m_SmallButtonFont, 0);
	m_ButtonSound.ResizeToText();
	
    fYPos += fYOffset;
    // define GRAPHIC button
   	m_ButtonGraphic = R6WindowButtonOptions(CreateWindow( class'R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
    m_ButtonGraphic.ToolTipString = Localize("Tip","ButtonGraphic","R6Menu");
    m_ButtonGraphic.Text = Localize("Options","ButtonGraphic","R6Menu");
	m_ButtonGraphic.m_eButton_Action = Button_Graphic;
	m_ButtonGraphic.Align = TA_Left;	
	m_ButtonGraphic.m_buttonFont = buttonFont;
	m_ButtonGraphic.CheckToDownSizeFont( m_SmallButtonFont, 0);
	m_ButtonGraphic.ResizeToText();
	
    fYPos += fYOffset;
    // define HUD FILTERS button
   	m_ButtonHudFilter = R6WindowButtonOptions(CreateWindow( class'R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
    m_ButtonHudFilter.ToolTipString = Localize("Tip","ButtonHud","R6Menu");
    m_ButtonHudFilter.Text = Localize("Options","ButtonHud","R6Menu");
	m_ButtonHudFilter.m_eButton_Action = Button_Hud;
	m_ButtonHudFilter.Align = TA_Left;	
	m_ButtonHudFilter.m_buttonFont = buttonFont;
	m_ButtonHudFilter.CheckToDownSizeFont( m_SmallButtonFont, 0);
	m_ButtonHudFilter.ResizeToText();

#ifndefSPDEMO    
    fYPos += fYOffset;
    // define MULTIPLAYER button
   	m_ButtonMultiPlayer = R6WindowButtonOptions(CreateWindow( class'R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
    m_ButtonMultiPlayer.ToolTipString = Localize("Tip","ButtonMultiPlayer","R6Menu");
    m_ButtonMultiPlayer.Text = Localize("Options","ButtonMultiPlayer","R6Menu");
	m_ButtonMultiPlayer.m_eButton_Action = Button_Multiplayer;
	m_ButtonMultiPlayer.Align = TA_Left;	
	m_ButtonMultiPlayer.m_buttonFont = buttonFont;
	m_ButtonMultiPlayer.CheckToDownSizeFont( m_SmallButtonFont, 0);
	m_ButtonMultiPlayer.ResizeToText();
#endif
	
    fYPos += fYOffset;
    // define CONTROLS button
   	m_ButtonControls = R6WindowButtonOptions(CreateWindow( class'R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
    m_ButtonControls.ToolTipString = Localize("Tip","ButtonControls","R6Menu");
    m_ButtonControls.Text = Localize("Options","ButtonControls","R6Menu");
	m_ButtonControls.m_eButton_Action = Button_Controls;
	m_ButtonControls.Align = TA_Left;
	m_ButtonControls.m_buttonFont = buttonFont;
	m_ButtonControls.CheckToDownSizeFont( m_SmallButtonFont, 0);
	m_ButtonControls.ResizeToText();
	
    fYPos += fYOffset;
    // define Custom Game MOD button
   	m_ButtonMODS = R6WindowButtonOptions(CreateWindow( class'R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
    m_ButtonMODS.ToolTipString = Localize("Tip","ButtonCustomGame","R6Menu");
    m_ButtonMODS.Text = Localize("Options","ButtonCustomGame","R6Menu");
	m_ButtonMODS.m_eButton_Action = Button_MODS;
	m_ButtonMODS.Align = TA_Left;
	m_ButtonMODS.m_buttonFont = buttonFont;
	m_ButtonMODS.CheckToDownSizeFont( m_SmallButtonFont, 0);
	m_ButtonMODS.ResizeToText();
	m_ButtonMODS.bDisabled = m_bInGame;
	//m_ButtonMODS.HideWindow();


    fYPos += fYOffset;
	// define PATCH SYSTEM button
   	//m_ButtonPatchService = R6WindowButtonOptions(CreateWindow( class'R6WindowButtonOptions', fXOffset, fYPos, fWidth, fHeight, self));
    //m_ButtonPatchService.ToolTipString = Localize("Tip","ButtonPatchService","R6Menu");
    //m_ButtonPatchService.Text = Localize("Options","ButtonPatchService","R6Menu");
	//m_ButtonPatchService.m_eButton_Action = Button_PatchService;
	//m_ButtonPatchService.Align = TA_Left;	
	//m_ButtonPatchService.m_buttonFont = buttonFont;
	//m_ButtonPatchService.CheckToDownSizeFont( m_SmallButtonFont, 0);
	//m_ButtonPatchService.ResizeToText();
	//m_ButtonPatchService.HideWindow();
	// TODO Add m_ButtonPatchService.IsFontDownSizingNeeded() in ResizeAllOptionsButtons() when we uncommented thoses lines
	// TODO and remove // for all m_ButtonPatchService in the same fct

	ResizeAllOptionsButtons();
}

function ResizeAllOptionsButtons()
{
	if( m_ButtonGame.IsFontDownSizingNeeded()			||
		m_ButtonSound.IsFontDownSizingNeeded()			||
		m_ButtonGraphic.IsFontDownSizingNeeded()		||
		m_ButtonHudFilter.IsFontDownSizingNeeded()      ||
		m_ButtonMultiPlayer.IsFontDownSizingNeeded()	||
		m_ButtonControls.IsFontDownSizingNeeded()		||
		m_ButtonMODS.IsFontDownSizingNeeded() ) //			||
//		m_ButtonPatchService.IsFontDownSizingNeeded() )
	{
		m_ButtonGame.m_buttonFont = m_SmallButtonFont;
		m_ButtonSound.m_buttonFont = m_SmallButtonFont;
		m_ButtonGraphic.m_buttonFont = m_SmallButtonFont;
		m_ButtonHudFilter.m_buttonFont = m_SmallButtonFont;
		m_ButtonMultiPlayer.m_buttonFont = m_SmallButtonFont;
		m_ButtonControls.m_buttonFont = m_SmallButtonFont;
		m_ButtonMODS.m_buttonFont = m_SmallButtonFont;
//		m_ButtonPatchService.m_buttonFont = m_SmallButtonFont;

		m_ButtonGame.ResizeToText();
		m_ButtonSound.ResizeToText();
		m_ButtonGraphic.ResizeToText();
		m_ButtonHudFilter.ResizeToText();
		m_ButtonMultiPlayer.ResizeToText();
		m_ButtonControls.ResizeToText();
		m_ButtonMODS.ResizeToText();
//		m_ButtonPatchService.ResizeToText();
	}
}

defaultproperties
{
}
