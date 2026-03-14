//=============================================================================
//  R6MenuOptionsTab.uc : Manage the options window. Not a real tab... plus a page system
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/11  * Create by Yannick Joly
//=============================================================================
class R6MenuOptionsTab extends UWindowDialogClientWindow;

enum ePageOptions
{
	ePO_Game,
	ePO_Sound,
	ePO_Graphics,
	ePO_Hud,
	ePO_MP,
	ePO_Controls,
// MPF - Yannick
	ePO_MODS,
	ePO_PatchService
};

enum eGeneralButUse
{
	eGBU_ResetToDefault,
	eGBU_Activate,
	eGBU_StartPatch
};

const C_fSCROLLBAR_WIDTH				= 140;							// the size of the scroll bar in option menus
const C_fSCROLLBAR_HEIGHT				= 14;							// the height of the scroll bar in option menus
const C_fXPOS_SCROLLBAR					= 250;
const C_fXPOS_COMBOCONTROL				= 250;
const C_ICOMBOCONTROL_WIDTH             = 140;

const C_szEGameOptionsGraphicLevel		= "EGameOptionsGraphicLevel";	// come fron R6GameOptions
const C_szEGameOptionsEffectLevel		= "EGameOptionsEffectLevel";	// come fron R6GameOptions

const C_iITEM_NONE						= 0x01;
const C_iITEM_LOW						= 0x02;
const C_iITEM_MEDIUM					= 0x04;
const C_iITEM_HIGH						= 0x08;
const C_iGORE_ITEMS						= 0x0A;
const C_iSHADOW_ITEMS					= 0x0B;							// NONE, LOW, HIGH
const C_iALL_ITEMS						= 0x0F;

// GENERAL
var string								m_pComboLevel[4];
var string								m_pSndLocEnum[3];
var string								m_pConnectionSpeed[5];
var Region								SimpleBorderRegion;
var R6WindowButton						m_pGeneralButUse;				// the button under the line, use for reset default button, activate mods...
var ePageOptions						m_ePageOptID;
var bool								m_bDrawLineOverButton;
var BOOL								m_bInitComplete;

// OPTION GAME
//var R6WindowButtonBox                   m_pOptionUnlimitedP;
var R6WindowButtonBox                   m_pOptionAlwaysRun;
var R6WindowButtonBox                   m_pOptionInvertMouse;
#ifndefMPDEMO
var R6WindowButtonBox                   m_pPopUpLoadPlan;
var R6WindowButtonBox                   m_pPopUpQuickPlay;
var R6WindowTextureBrowser              m_pAutoAim;
#endif
var Texture                             m_pAutoAimTexture;
var Region                              m_pAutoAimTextReg[4];
var R6WindowHScrollBar					m_pOptionMouseSens;
var INT									m_iRefMouseSens;

// OPTION SOUND
var R6WindowHScrollBar					m_pAmbientVolume;
var R6WindowHScrollBar					m_pVoicesVolume;
var R6WindowHScrollBar					m_pMusicVolume;

var R6WindowComboControl				m_pSndQuality;
var R6WindowComboControl				m_pAudioVirtual;

var R6WindowButtonBox                   m_pSndHardware;
var R6WindowButtonBox                   m_pEAX;
var R6WindowBitMap                      m_EaxLogo;
var Texture                             m_EaxTexture;
var Region                              m_EaxTextureReg;
var BOOL								m_bEAXNotSupported; // if EAX is not supported
var INT									m_iRefAmbientVolume;
var INT									m_iRefVoicesVolume;
var INT									m_iRefMusicVolume;

// OPTION GRAPHIC
var R6WindowComboControl				m_pVideoRes;
var R6WindowComboControl				m_pTextureDetail;
var R6WindowComboControl				m_pLightmapDetail;
var R6WindowComboControl				m_pRainbowsDetail;
var R6WindowComboControl				m_pHostagesDetail;
var R6WindowComboControl				m_pTerrosDetail;
var R6WindowComboControl				m_pRainbowsShadowLevel;
var R6WindowComboControl				m_pHostagesShadowLevel;
var R6WindowComboControl				m_pTerrosShadowLevel;
var R6WindowComboControl				m_pGoreLevel;
var R6WindowComboControl				m_pDecalsDetail;

var R6WindowButtonBox                   m_pAnimGeometry;
var R6WindowButtonBox                   m_pHideDeadBodies;
var R6WindowButtonBox                   m_pLowDetailSmoke;

// OPTION HUD FILTERS
var R6WindowButtonBox                   m_pHudWeaponName;
var R6WindowButtonBox                   m_pHudShowFPWeapon;
var R6WindowButtonBox                   m_pHudOtherTInfo;
var R6WindowButtonBox                   m_pHudCurTInfo;
var R6WindowButtonBox                   m_pHudCircumIcon;
var R6WindowButtonBox                   m_pHudWpInfo;
var R6WindowButtonBox                   m_pHudReticule;
var R6WindowButtonBox                   m_pHudShowTNames;
var R6WindowButtonBox                   m_pHudCharInfo;
var R6WindowButtonBox                   m_pHudShowRadar;

var R6WindowBitMap						m_pHudBGTex;
var R6WindowBitMap						m_pHudWeaponNameTex;
var R6WindowBitMap						m_pHudShowFPWeaponTex;
var R6WindowBitMap						m_pHudOtherTInfoTex;
var R6WindowBitMap						m_pHudCurTInfoTex;
var R6WindowBitMap						m_pHudCircumIconTex;
var R6WindowBitMap						m_pHudWpInfoTex;
var R6WindowBitMap						m_pHudReticuleTex;
var R6WindowBitMap						m_pHudCharInfoTex;	
var R6WindowBitMap						m_pHudShowTNamesTex;
var R6WindowBitMap						m_pHudShowRadarTex;

// OPTION MULTIPLAYER
var R6WindowEditControl                 m_pOptionPlayerName;

var R6WindowComboControl				m_pSpeedConnection;

var R6WindowButtonExt					m_pOptionGender;

var R6MenuArmpatchSelect                m_pArmpatchChooser;

// OPTION PATCH SERVICE
var R6WindowButtonBox					m_pOptionAutoPatchDownload;
var R6WindowButton						m_pStartDownloadButton;
var R6WindowTextLabel					m_pPatchStatus;

var Region                              m_RArmpatchBitmapPos;
var Region                              m_RArmpatchListPos;
var R6WindowButtonBox                   m_bTriggerLagWanted;

//#ifdefR6PUNKBUSTER
var R6WindowButtonBox					m_pPunkBusterOpt;
var BOOL								m_bPBNotInstalled; // if PunkBuster is not installed
//#endif

// OPTION CONTROLS
var	R6WindowListControls				m_pListControls;
var UWindowListBoxItem					m_pCurItem;
var R6MenuOptionsControls				m_pOptControls;
var	R6WindowPopUpBox					m_pPopUpKeyBG;
var R6WindowPopUpBox				    m_pKeyMenuReAssignPopUp;
var string							    m_szOldActionKey;
var INT								    m_iKeyToAssign;

// OPTION MODS
// MPF - Yannick
var R6WindowListMODS					m_pListOfMODS;				// the list of MODS
var UWindowInfo							m_pInfo;					// official informations for mission pack/mods

//===================================================================================
//===================================================================================
//===================================================================================
//===================================================================================
//===================================================================================
function Created()
{
	m_pComboLevel[0] = Localize("Options","Level_None","R6Menu");
	m_pComboLevel[1] = Localize("Options","Level_Low","R6Menu");
	m_pComboLevel[2] = Localize("Options","Level_Medium","R6Menu");
	m_pComboLevel[3] = Localize("Options","Level_Hi","R6Menu");	

	m_pSndLocEnum[0] = Localize("Options","Opt_SndVirtualHigh","R6Menu");
	m_pSndLocEnum[1] = Localize("Options","Opt_SndVirtualLow","R6Menu");
	m_pSndLocEnum[2] = Localize("Options","Opt_SndVirtualOff","R6Menu");

	m_pConnectionSpeed[0] = Localize("Options","Opt_NetSpeedT1","R6Menu");
	m_pConnectionSpeed[1] = Localize("Options","Opt_NetSpeedT3","R6Menu");
	m_pConnectionSpeed[2] = Localize("Options","Opt_NetSpeedCable","R6Menu");
	m_pConnectionSpeed[3] = Localize("Options","Opt_NetSpeedADSL","R6Menu");
	m_pConnectionSpeed[4] = Localize("Options","Opt_NetSpeedModem","R6Menu");
}

function Paint( Canvas C, FLOAT X, FLOAT Y)
{
	// draw the line over the reset defaut button
	if (m_bDrawLineOverButton)
	{
		C.SetDrawColor( 255, 255, 255);
	    DrawStretchedTextureSegment(C, 0, WinHeight - 15, WinWidth, SimpleBorderRegion.H , 
                                    SimpleBorderRegion.X, SimpleBorderRegion.Y, SimpleBorderRegion.W, SimpleBorderRegion.H, 
									R6MenuRSLookAndFeel(LookAndFeel).m_R6ScrollTexture);		
	}
}




// GENERAL
function InitResetButton()
{
	m_bDrawLineOverButton = true;

	m_pGeneralButUse = R6WindowButton(CreateControl(class'R6WindowButton', 0, WinHeight - 15, WinWidth, 15, self));
	m_pGeneralButUse.Text		   = Localize("Options","ResetToDefault","R6Menu"); 
	m_pGeneralButUse.ToolTipString = Localize("Tip","ResetToDefault","R6Menu");
	m_pGeneralButUse.Align		   = TA_Center;
	m_pGeneralButUse.m_iButtonID   = eGeneralButUse.eGBU_ResetToDefault;
}

function InitActivateButton()
{
	m_bDrawLineOverButton = true;

	m_pGeneralButUse = R6WindowButton(CreateControl(class'R6WindowButton', 0, WinHeight - 15, WinWidth, 15, self));
	m_pGeneralButUse.Text			= Localize("Options","ActivateModButton","R6Menu"); 
	m_pGeneralButUse.ToolTipString  = Localize("Tip","ActivateModButton","R6Menu");
	m_pGeneralButUse.Align			= TA_Center;
	m_pGeneralButUse.m_iButtonID	= eGeneralButUse.eGBU_Activate;
}

//*******************************************************************************************
// OPTION GAME
//*******************************************************************************************
function InitOptionGame()
{
    local FLOAT fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp, fSizeOfCounter, fXRightOffset;
    local Font ButtonFont;

    local INT  iAutoAimBitmapHeight, iAutoAimVPadding, iSBButtonWidth;

    //create buttons -- check text label offset for concordance 
    ButtonFont = Root.Fonts[F_SmallTitle]; 

	m_ePageOptID = ePO_Game;

    fXOffset = 5;
    fXRightOffset = 26;
    fYOffset = 5;
    fWidth = WinWidth - fXOffset - 40; // 40 distance to the end of the window
    fHeight = 15;
    fYStep = 27;
    iSBButtonWidth = 14;
    
    iAutoAimBitmapHeight = 73;
    iAutoAimVPadding     = 5; //Padding Between the bitmap and the scrollBar

	/*
    // UNLIMITED PRATICE
    m_pOptionUnlimitedP = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pOptionUnlimitedP.SetButtonBox( false);
    m_pOptionUnlimitedP.CreateTextAndBox( Localize("Options","Opt_GameUnlimited","R6Menu"), 
                                          Localize("Tip","Opt_GameUnlimited","R6Menu"), 0, 
                                          0);
	*/
	
//    fYOffset += fYStep;
    // ALWAYS RUN
    m_pOptionAlwaysRun = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pOptionAlwaysRun.SetButtonBox( false);
    m_pOptionAlwaysRun.CreateTextAndBox( Localize("Options","Opt_GameAlways","R6Menu"), 
                                         Localize("Tip","Opt_GameAlways","R6Menu"), 0, 
                                         2);

    fYOffset += fYStep;
    // INVERT MOUSE
    m_pOptionInvertMouse = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pOptionInvertMouse.SetButtonBox( false);
    m_pOptionInvertMouse.CreateTextAndBox( Localize("Options","Opt_GameInvertM","R6Menu"), 
                                           Localize("Tip","Opt_GameInvertM","R6Menu"), 0, 
                                           3);

	fYOffset += fYStep;
	// MOUSE SENSITIVITY
	m_pOptionMouseSens = R6WindowHScrollBar(CreateControl(class'R6WindowHScrollBar', fXOffset, fYOffset, WinWidth - fXOffset - fXRightOffset, C_fSCROLLBAR_HEIGHT, self));
	m_pOptionMouseSens.CreateSB( 0, C_fXPOS_SCROLLBAR, 0, C_fSCROLLBAR_WIDTH, C_fSCROLLBAR_HEIGHT, self); //180 is the size of the scrollbar
	m_pOptionMouseSens.CreateSBTextLabel( Localize("Options","Opt_GameMouseSens","R6Menu"), 
									      Localize("Tip","Opt_GameMouseSens","R6Menu"));	
	m_pOptionMouseSens.SetScrollBarRange( 0, 120, 20);

#ifndefMPDEMO
	fYOffset += fYStep;
	// POP UP LOAD PLAN
    m_pPopUpLoadPlan = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pPopUpLoadPlan.SetButtonBox( false);
    m_pPopUpLoadPlan.CreateTextAndBox( Localize("Options","Opt_GamePopUpLoadPlan","R6Menu"), 
                                       Localize("Tip","Opt_GamePopUpLoadPlan","R6Menu"),
                                       0, 5);
    

    fYOffset += fYStep;
	// POP UP LOAD PLAN
    m_pPopUpQuickPlay = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pPopUpQuickPlay.SetButtonBox( false);
    m_pPopUpQuickPlay.CreateTextAndBox( Localize("Options","Opt_GamePopUpQuickPlay","R6Menu"), 
                                       Localize("Tip","Opt_GamePopUpQuickPlay","R6Menu"),
                                       0, 5);


    fYOffset += fYStep;
    // AUTO AIM       
    m_pAutoAim = R6WindowTextureBrowser(CreateWindow(class'R6WindowTextureBrowser', fXOffset , fYOffset, WinWidth - fXOffset, C_fSCROLLBAR_HEIGHT + iAutoAimBitmapHeight + iAutoAimVPadding, self));
    m_pAutoAim.CreateSB( C_fXPOS_SCROLLBAR, m_pAutoAim.WinHeight - C_fSCROLLBAR_HEIGHT, C_fSCROLLBAR_WIDTH, C_fSCROLLBAR_HEIGHT); //180 is the size of the scrollbar
    m_pAutoAim.CreateBitmap(C_fXPOS_SCROLLBAR + iSBButtonWidth,
                            0,
                            C_fSCROLLBAR_WIDTH - (2 * iSBButtonWidth),
                            iAutoAimBitmapHeight);
    m_pAutoAim.SetBitmapProperties(false, true, 5, false);
    m_pAutoAim.SetBitmapBorder(true, Root.Colors.White);
    m_pAutoAim.CreateTextLabel( 0,0, m_pAutoAim.WinWidth - m_pAutoAim.m_CurrentSelection.WinLeft, m_pAutoAim.WinHeight,
                                Localize("Options","Opt_AutoTarget","R6Menu"), 
								Localize("Tip","Opt_AutoTarget","R6Menu"));	

    m_pAutoAim.AddTexture(m_pAutoAimTexture, m_pAutoAimTextReg[0]); 
    m_pAutoAim.AddTexture(m_pAutoAimTexture, m_pAutoAimTextReg[1]); 
    m_pAutoAim.AddTexture(m_pAutoAimTexture, m_pAutoAimTextReg[2]); 
    m_pAutoAim.AddTexture(m_pAutoAimTexture, m_pAutoAimTextReg[3]);
#endif

	InitResetButton();
	SetMenuGameValues();

	m_bInitComplete = true;
}

//=============================================================================================
// SetGameValue: Set the R6GameOptions values
//=============================================================================================
function SetGameValues()
{
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

//	pGameOptions.UnlimitedPractice = m_pOptionUnlimitedP.m_bSelected;
	pGameOptions.AlwaysRun		   = m_pOptionAlwaysRun.m_bSelected;
	pGameOptions.InvertMouse	   = m_pOptionInvertMouse.m_bSelected;
#ifndefMPDEMO
	pGameOptions.PopUpLoadPlan	   = m_pPopUpLoadPlan.m_bSelected;
    pGameOptions.PopUpQuickPlay	   = m_pPopUpQuickPlay.m_bSelected;    

    pGameOptions.AutoTargetSlider  = m_pAutoAim.GetCurrentTextureIndex();
#endif
	pGameOptions.MouseSensitivity  = m_pOptionMouseSens.GetScrollBarValue();
}

//=============================================================================================
// SetMenuGameValue: Set the menu game values according the value store in uw.ini by R6GameOptions
//=============================================================================================
function SetMenuGameValues()
{
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

//	m_pOptionUnlimitedP.SetButtonBox( pGameOptions.UnlimitedPractice);
	m_pOptionAlwaysRun.SetButtonBox( pGameOptions.AlwaysRun);
	m_pOptionInvertMouse.SetButtonBox( pGameOptions.InvertMouse);
#ifndefMPDEMO
	m_pPopUpLoadPlan.SetButtonBox( pGameOptions.PopUpLoadPlan);
    m_pPopUpQuickPlay.SetButtonBox( pGameOptions.PopUpQuickPlay);
    m_pAutoAim.SetCurrentTextureFromIndex(pGameOptions.AutoTargetSlider);
#endif	
	m_pOptionMouseSens.SetScrollBarValue( pGameOptions.MouseSensitivity);
}

//*******************************************************************************************
// OPTION SOUND
//*******************************************************************************************
function InitOptionSound(BOOL _bInGameOptions)
{
	local Region rRegionW;
    local FLOAT fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp, fSizeOfCounter, fXRightOffset;
    local Font ButtonFont;

    //create buttons -- check text label offset for concordance 
    ButtonFont = Root.Fonts[F_SmallTitle]; 

	m_ePageOptID = ePO_Sound;

    fXOffset = 5;
    fXRightOffset = 26;
    fYOffset = 5;
    fWidth = WinWidth - fXOffset - 40; // 40 distance to the end of the window
    fHeight = 14;
    fYStep = 27;

	// AMBIENT VOLUME
	m_pAmbientVolume = R6WindowHScrollBar(CreateControl(class'R6WindowHScrollBar', fXOffset, fYOffset, WinWidth - fXOffset - fXRightOffset, C_fSCROLLBAR_HEIGHT, self));
	m_pAmbientVolume.CreateSB( GetPlayerOwner().ESoundSlot.SLOT_Ambient,
							   C_fXPOS_SCROLLBAR, 0, C_fSCROLLBAR_WIDTH, C_fSCROLLBAR_HEIGHT, self); //180 is the size of the scrollbar
	m_pAmbientVolume.CreateSBTextLabel( Localize("Options","Opt_SndAmbient","R6Menu"), 
									    Localize("Tip","Opt_SndAmbient","R6Menu"));
	m_pAmbientVolume.SetScrollBarRange( 0, 100, 20);

	fYOffset += fYStep;
	// VOICES VOLUME
	m_pVoicesVolume = R6WindowHScrollBar(CreateControl(class'R6WindowHScrollBar', fXOffset, fYOffset, WinWidth - fXOffset - fXRightOffset, C_fSCROLLBAR_HEIGHT, self));
	m_pVoicesVolume.CreateSB( GetPlayerOwner().ESoundSlot.SLOT_Talk,
							  C_fXPOS_SCROLLBAR, 0, C_fSCROLLBAR_WIDTH, C_fSCROLLBAR_HEIGHT, self); //180 is the size of the scrollbar
	m_pVoicesVolume.CreateSBTextLabel( Localize("Options","Opt_SndVoices","R6Menu"), 
							  	       Localize("Tip","Opt_SndVoices","R6Menu"));
	m_pVoicesVolume.SetScrollBarRange( 0, 100, 20);

	fYOffset += fYStep;	
	// MUSIC VOLUME
	m_pMusicVolume = R6WindowHScrollBar(CreateControl(class'R6WindowHScrollBar', fXOffset, fYOffset, WinWidth - fXOffset - fXRightOffset, C_fSCROLLBAR_HEIGHT, self));
	m_pMusicVolume.CreateSB( GetPlayerOwner().ESoundSlot.SLOT_Music,
							 C_fXPOS_SCROLLBAR, 0, C_fSCROLLBAR_WIDTH, C_fSCROLLBAR_HEIGHT, self); //180 is the size of the scrollbar
	m_pMusicVolume.CreateSBTextLabel( Localize("Options","Opt_SndMusic","R6Menu"), 
							   	      Localize("Tip","Opt_SndMusic","R6Menu"));
	m_pMusicVolume.SetScrollBarRange( 0, 100, 20);
	
	fYOffset += fYStep;	
	rRegionW.X = fXOffset;
	rRegionW.Y = fYOffset;
	rRegionW.W = fWidth + 20; 
	rRegionW.H = fHeight;
	// SOUND QUALITY
	m_pSndQuality = SetComboControlButton( rRegionW, Localize("Options","Opt_SndQuality","R6Menu"), 
												     Localize("Tip","Opt_SndQuality","R6Menu"));
	m_pSndQuality.AddItem( m_pComboLevel[1], "");
	m_pSndQuality.AddItem( m_pComboLevel[3], "");
	m_pSndQuality.SetDisableButton(_bInGameOptions);

	fYOffset += fYStep;	
	rRegionW.Y = fYOffset;
	// AUDIO VIRTUALIZATION
	m_pAudioVirtual = SetComboControlButton( rRegionW, Localize("Options","Opt_SndVirtual","R6Menu"), 
												       Localize("Tip","Opt_SndVirtual","R6Menu"));
	m_pAudioVirtual.AddItem( m_pSndLocEnum[2], "");
	m_pAudioVirtual.AddItem( m_pSndLocEnum[1], "");
	m_pAudioVirtual.AddItem( m_pSndLocEnum[0], "");

	fYOffset += fYStep;	
	// 3D AUDIO HARDWARE ACCELERATION
    m_pSndHardware = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pSndHardware.SetButtonBox( false);
    m_pSndHardware.CreateTextAndBox( Localize("Options","Opt_SndHardware","R6Menu"), 
                                     Localize("Tip","Opt_SndHardware","R6Menu"), 0, 
                                     0);
	fYOffset += fYStep;	
	// EAX
    m_pEAX = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pEAX.SetButtonBox( false);
    m_pEAX.CreateTextAndBox( Localize("Options","Opt_SndEAX","R6Menu"), 
                             Localize("Tip","Opt_SndEAX","R6Menu"), 0, 
                             1);

    fYOffset += fYStep;	
	// EAX LOGO
    m_EaxLogo = R6WindowBitMap(CreateWindow(class'R6WindowBitMap', 0, fYOffset, WinWidth, m_EaxTextureReg.H, Self));
    m_EaxLogo.bCenter = true;
    m_EaxLogo.m_iDrawStyle = 5;
    m_EaxLogo.T = m_EaxTexture;
    m_EaxLogo.R = m_EaxTextureReg;
    m_EaxLogo.m_bUseColor = true;
    m_EaxLogo.m_TextureColor= Root.Colors.GrayLight;
    


	InitResetButton();	
	SetMenuSoundValues();

	m_bInitComplete = true;
}

//=============================================================================================
// SetSoundValues: Set the R6GameOptions values
//=============================================================================================
function SetSoundValues()
{
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

	pGameOptions.AmbientVolume		= m_pAmbientVolume.GetScrollBarValue();
	pGameOptions.VoicesVolume		= m_pVoicesVolume.GetScrollBarValue();
	pGameOptions.MusicVolume		= m_pMusicVolume.GetScrollBarValue();

	pGameOptions.SndHardware		= m_pSndHardware.m_bSelected;
	pGameOptions.EAX				= m_pEAX.m_bSelected;

	pGameOptions.SndQuality			= ConvertToSndQuality( m_pSndQuality.GetValue());
	pGameOptions.AudioVirtual		= ConvertToAVEnum(m_pAudioVirtual.GetValue());
}

//=============================================================================================
// SetMenuSoundValues: Set the sound values according the value store in uw.ini by R6GameOptions
//=============================================================================================
function SetMenuSoundValues()
{
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

	m_pAmbientVolume.SetScrollBarValue( pGameOptions.AmbientVolume);
	m_pVoicesVolume.SetScrollBarValue( pGameOptions.VoicesVolume);
	m_pMusicVolume.SetScrollBarValue( pGameOptions.MusicVolume);

	m_iRefAmbientVolume = m_pAmbientVolume.GetScrollBarValue();
	m_iRefVoicesVolume = m_pVoicesVolume.GetScrollBarValue();
	m_iRefMusicVolume = m_pMusicVolume.GetScrollBarValue();

	m_pSndHardware.SetButtonBox( pGameOptions.SndHardware);

#ifdefDEBUG
	log("EAX COMPATIBLE: "$pGameOptions.EAXCompatible);
#endif

	if (pGameOptions.EAXCompatible)	// EAXCompatible
	{
		m_pEAX.SetButtonBox( pGameOptions.EAX);
        
	}
	else // disabled the button
	{
		m_bEAXNotSupported = true;
		m_pEAX.bDisabled = true;
		m_pEAX.SetButtonBox( False);    
	}

	ManageNotifyForSound( m_pSndHardware, DE_Change);
	ManageNotifyForSound( m_pEAX, DE_Change); //Gray the logo if eax is not activated

	m_pAudioVirtual.SetValue( ConvertToAudioString(pGameOptions.AudioVirtual));
	m_pSndQuality.SetValue( ConvertToSndQualityString(pGameOptions.SndQuality));
}

//=============================================================================
// ConvertSndQuality: Convert the sound quality to a bin value or the inverse
//=============================================================================
function INT ConvertToSndQuality( string _szValue)
{
	if (_szValue == m_pComboLevel[3])
		return 1;
	else
		return 0;
}

//=============================================================================
// ConvertSndQuality: Convert the sound quality to a bin value or the inverse
//=============================================================================
function string ConvertToSndQualityString( INT _iValue)
{
	if ( _iValue == 1)
		return m_pComboLevel[3];
	else
		return m_pComboLevel[1];
}

//=============================================================================================
// ConvertToAVEnum: Convert string to EGameOptionsAudioVirtual enum
//=============================================================================================
function R6GameOptions.EGameOptionsAudioVirtual ConvertToAVEnum( string _szValueToConvert)
{
	local R6GameOptions.EGameOptionsAudioVirtual eAVResult;

	switch(_szValueToConvert)
	{
		case m_pSndLocEnum[0]:
			eAVResult = eAV_High;
			break;
		case m_pSndLocEnum[1]:
			eAVResult = eAV_Low;
			break;
		case m_pSndLocEnum[2]:
			eAVResult = eAV_None;
			break;
		default:
			break;
	}

	return eAVResult;
}

//=============================================================================================
// ConvertToAudioString: This function convert sounds enum -- define in r6gameoptions to a value to display
//=============================================================================================
function string ConvertToAudioString( INT _iValueToConvert)
{
	local string szResult;

	switch(_iValueToConvert)
	{
		case 0:
			szResult = m_pSndLocEnum[0];
			break;
		case 1:
			szResult = m_pSndLocEnum[1];
			break;
		case 2:
			szResult = m_pSndLocEnum[2];
			break;
		default:
			break;
	}

	return szResult;
}

//*******************************************************************************************
// OPTION GRAPHIC
//*******************************************************************************************
function InitOptionGraphic( BOOL _bInGameOptions)
{
	local Region rRegionW;
    local FLOAT fYStep;
    local Font ButtonFont;
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

    //create buttons -- check text label offset for concordance 
    ButtonFont = Root.Fonts[F_SmallTitle]; 

	m_ePageOptID = ePO_Graphics;

	rRegionW.X = 5;
	rRegionW.Y = 5;
	rRegionW.W = WinWidth - rRegionW.X - 20; // 40 distance to the end of the window
	rRegionW.H = 14;
    fYStep = 19;

	// VIDEO RESOLUTION
	m_pVideoRes = SetComboControlButton( rRegionW, Localize("Options","Opt_GrapVideoRes","R6Menu"), 
												   Localize("Tip","Opt_GrapVideoRes","R6Menu"));
	AddVideoResolution( m_pVideoRes);

    if (_bInGameOptions)
        m_pVideoRes.SetDisableButton(!pGameOptions.AllowChangeResInGame);

	rRegionW.Y += fYStep;
	// TEXTURE DETAIL
	m_pTextureDetail = SetComboControlButton( rRegionW, Localize("Options","Opt_GrapTexDetail","R6Menu"), 
														Localize("Tip","Opt_GrapTexDetail","R6Menu"));
	AddGraphComboControlItem( C_iALL_ITEMS, m_pTextureDetail, C_szEGameOptionsGraphicLevel);

	rRegionW.Y += fYStep;
	// LIGHTMAP DETAIL
	m_pLightmapDetail = SetComboControlButton( rRegionW, Localize("Options","Opt_GrapLightMap","R6Menu"), 
														 Localize("Tip","Opt_GrapLightMap","R6Menu"));
	AddGraphComboControlItem( C_iALL_ITEMS, m_pLightmapDetail, C_szEGameOptionsGraphicLevel, true);

	rRegionW.Y += fYStep;
	// RAINBOWS DETAIL
	m_pRainbowsDetail = SetComboControlButton( rRegionW, Localize("Options","Opt_GrapRainbowDetail","R6Menu"), 
														 Localize("Tip","Opt_GrapRainbowDetail","R6Menu"));
	AddGraphComboControlItem( C_iALL_ITEMS, m_pRainbowsDetail, C_szEGameOptionsGraphicLevel);

#ifndefMPDEMO
	rRegionW.Y += fYStep;
	// HOSTAGES DETAIL
	m_pHostagesDetail = SetComboControlButton( rRegionW, Localize("Options","Opt_GrapHostDetail","R6Menu"), 
														 Localize("Tip","Opt_GrapHostDetail","R6Menu"));
	AddGraphComboControlItem( C_iALL_ITEMS, m_pHostagesDetail, C_szEGameOptionsGraphicLevel);

	rRegionW.Y += fYStep;
	// TERROS DETAIL
	m_pTerrosDetail = SetComboControlButton( rRegionW, Localize("Options","Opt_GrapTerroDetail","R6Menu"), 
													   Localize("Tip","Opt_GrapTerroDetail","R6Menu"));
	AddGraphComboControlItem( C_iALL_ITEMS, m_pTerrosDetail, C_szEGameOptionsGraphicLevel);
#endif

	rRegionW.Y += fYStep;
	// RAINBOWS SHADOW LEVEL
	m_pRainbowsShadowLevel = SetComboControlButton( rRegionW, Localize("Options","Opt_GrapRainbowShadow","R6Menu"), 
															  Localize("Tip","Opt_GrapRainbowShadow","R6Menu"));
	AddGraphComboControlItem( C_iSHADOW_ITEMS, m_pRainbowsShadowLevel, C_szEGameOptionsEffectLevel, true);
	m_pRainbowsShadowLevel.SetDisableButton(_bInGameOptions);
	
#ifndefMPDEMO
	rRegionW.Y += fYStep;
	// HOSTAGES SHADOW LEVEL
	m_pHostagesShadowLevel = SetComboControlButton( rRegionW, Localize("Options","Opt_GrapHostShadow","R6Menu"), 
															  Localize("Tip","Opt_GrapHostShadow","R6Menu"));
	AddGraphComboControlItem( C_iSHADOW_ITEMS, m_pHostagesShadowLevel, C_szEGameOptionsEffectLevel, true);
	m_pHostagesShadowLevel.SetDisableButton(_bInGameOptions);

	rRegionW.Y += fYStep;
	// TERROS SHADOW LEVEL
	m_pTerrosShadowLevel = SetComboControlButton( rRegionW, Localize("Options","Opt_GrapTerroShadow","R6Menu"), 
															Localize("Tip","Opt_GrapTerroShadow","R6Menu"));
	AddGraphComboControlItem( C_iSHADOW_ITEMS, m_pTerrosShadowLevel, C_szEGameOptionsEffectLevel, true);
	m_pTerrosShadowLevel.SetDisableButton(_bInGameOptions);
#endif

	if (!pGameOptions.SplashScreen) // german version
	{
	rRegionW.Y += fYStep;
	// GORE LEVEL
	m_pGoreLevel = SetComboControlButton( rRegionW, Localize("Options","Opt_GrapGoreLevel","R6Menu"), 
													Localize("Tip","Opt_GrapGoreLevel","R6Menu"));
	AddGraphComboControlItem( C_iGORE_ITEMS, m_pGoreLevel, C_szEGameOptionsGraphicLevel);
	m_pGoreLevel.SetDisableButton(_bInGameOptions);
	}

	rRegionW.Y += fYStep;
	// DECALS DETAIL
	m_pDecalsDetail = SetComboControlButton( rRegionW, Localize("Options","Opt_GrapDecalsDetail","R6Menu"), 
													   Localize("Tip","Opt_GrapDecalsDetail","R6Menu"));
	AddGraphComboControlItem( C_iALL_ITEMS, m_pDecalsDetail, C_szEGameOptionsEffectLevel);
	m_pDecalsDetail.SetDisableButton(_bInGameOptions);

	rRegionW.Y += fYStep;
	rRegionW.W -= 20;
	// ANIMATED GEOMETRY
    m_pAnimGeometry = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', rRegionW.X, rRegionW.Y, rRegionW.W, rRegionW.H, self));
    m_pAnimGeometry.SetButtonBox( true);
    m_pAnimGeometry.CreateTextAndBox( Localize("Options","Opt_GrapAnimGeometry","R6Menu"), 
                                      Localize("Tip","Opt_GrapAnimGeometry","R6Menu"), 0, 
                                      0);

	if (!pGameOptions.SplashScreen) // german version
	{
	rRegionW.Y += fYStep;
	// HIDE DEAD BODIES
    m_pHideDeadBodies = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', rRegionW.X, rRegionW.Y, rRegionW.W, rRegionW.H, self));
    m_pHideDeadBodies.SetButtonBox( true);
    m_pHideDeadBodies.CreateTextAndBox( Localize("Options","Opt_GrapHideDeadBodies","R6Menu"), 
                                        Localize("Tip","Opt_GrapHideDeadBodies","R6Menu"), 0, 
                                        0);
	}

	rRegionW.Y += fYStep;
	// GRENADE QUALITY
    m_pLowDetailSmoke = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', rRegionW.X, rRegionW.Y, rRegionW.W, rRegionW.H, self));
    m_pLowDetailSmoke.SetButtonBox( false);
    m_pLowDetailSmoke.CreateTextAndBox( Localize("Options","Opt_GrapLowDetailSmoke","R6Menu"), 
                                        Localize("Tip","Opt_GrapLowDetailSmoke","R6Menu"), 0, 
                                        0);

	InitResetButton();
	SetMenuGraphicValues();

	m_bInitComplete = true;
}

//=============================================================================================
// SetGraphicValues: Set the R6GameOptions values
//=============================================================================================
function SetGraphicValues( optional BOOL _bUpdateFileOnly)
{
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

    GetResolutionXY(pGameOptions.R6ScreenSizeX, pGameOptions.R6ScreenSizeY, pGameOptions.R6ScreenRefreshRate);

	pGameOptions.TextureDetail			= ConvertToGLEnum( m_pTextureDetail.GetValue()); 
	pGameOptions.LightmapDetail			= ConvertToGLEnum( m_pLightmapDetail.GetValue());
	pGameOptions.RainbowsDetail			= ConvertToGLEnum( m_pRainbowsDetail.GetValue());
	pGameOptions.RainbowsShadowLevel	= ConvertToELEnum( m_pRainbowsShadowLevel.GetValue());

#ifndefMPDEMO
	pGameOptions.HostagesDetail			= ConvertToGLEnum( m_pHostagesDetail.GetValue());
	pGameOptions.TerrosDetail			= ConvertToGLEnum( m_pTerrosDetail.GetValue());
	pGameOptions.HostagesShadowLevel	= ConvertToELEnum( m_pHostagesShadowLevel.GetValue());
	pGameOptions.TerrosShadowLevel		= ConvertToELEnum( m_pTerrosShadowLevel.GetValue());
#endif


	if (pGameOptions.SplashScreen) // german version
		pGameOptions.GoreLevel			= pGameOptions.EGameOptionsEffectLevel.eEL_None;
	else
		pGameOptions.GoreLevel			= ConvertToELEnum( m_pGoreLevel.GetValue());

	pGameOptions.DecalsDetail			= ConvertToELEnum( m_pDecalsDetail.GetValue());
	pGameOptions.AnimatedGeometry		= m_pAnimGeometry.m_bSelected;

	if (pGameOptions.SplashScreen) // german version
		pGameOptions.HideDeadBodies		= true;
	else
		pGameOptions.HideDeadBodies		= m_pHideDeadBodies.m_bSelected;
    
	pGameOptions.LowDetailSmoke			= m_pLowDetailSmoke.m_bSelected;

	// design change, SetGraphicValues can be called when you change 1 graphic option, so be sure that your are in-game to apply change
	if ((R6MenuOptionsWidget(OwnerWindow).m_bInGame) && (!_bUpdateFileOnly))
	    class'Actor'.static.UpdateGraphicOptions();
}

//=============================================================================================
// SetMenuGraphicValues: Set the graphics values according the value store in uw.ini by R6GameOptions
//=============================================================================================
function SetMenuGraphicValues()
{
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

    if(pGameOptions.ShowRefreshRates && pGameOptions.R6ScreenRefreshRate != -1)
        m_pVideoRes.SetValue( pGameOptions.R6ScreenSizeX $ "x" $ pGameOptions.R6ScreenSizeY $ "@" $ pGameOptions.R6ScreenRefreshRate); 
    else
        m_pVideoRes.SetValue( pGameOptions.R6ScreenSizeX $ "x" $ pGameOptions.R6ScreenSizeY); 

	m_pTextureDetail.SetValue( ConvertToGraphicString( C_iALL_ITEMS, pGameOptions.TextureDetail, C_szEGameOptionsGraphicLevel));
	m_pLightmapDetail.SetValue( ConvertToGraphicString( C_iALL_ITEMS, pGameOptions.LightmapDetail, C_szEGameOptionsGraphicLevel, true));
	m_pRainbowsDetail.SetValue( ConvertToGraphicString( C_iALL_ITEMS, pGameOptions.RainbowsDetail, C_szEGameOptionsGraphicLevel));
	m_pRainbowsShadowLevel.SetValue( ConvertToGraphicString( C_iSHADOW_ITEMS, pGameOptions.RainbowsShadowLevel, C_szEGameOptionsEffectLevel, true));

#ifndefMPDEMO
    m_pHostagesDetail.SetValue( ConvertToGraphicString( C_iALL_ITEMS, pGameOptions.HostagesDetail, C_szEGameOptionsGraphicLevel));
	m_pTerrosDetail.SetValue( ConvertToGraphicString( C_iALL_ITEMS, pGameOptions.TerrosDetail, C_szEGameOptionsGraphicLevel));
	m_pHostagesShadowLevel.SetValue( ConvertToGraphicString( C_iSHADOW_ITEMS, pGameOptions.HostagesShadowLevel, C_szEGameOptionsEffectLevel, true));
	m_pTerrosShadowLevel.SetValue( ConvertToGraphicString( C_iSHADOW_ITEMS, pGameOptions.TerrosShadowLevel, C_szEGameOptionsEffectLevel, true));
#endif

	if (!pGameOptions.SplashScreen) // german version
		m_pGoreLevel.SetValue( ConvertToGraphicString( C_iGORE_ITEMS, pGameOptions.GoreLevel, C_szEGameOptionsEffectLevel));

	m_pDecalsDetail.SetValue( ConvertToGraphicString( C_iALL_ITEMS, pGameOptions.DecalsDetail, C_szEGameOptionsEffectLevel));
	m_pAnimGeometry.SetButtonBox( pGameOptions.AnimatedGeometry);

	if (!pGameOptions.SplashScreen) // german version
		m_pHideDeadBodies.SetButtonBox( pGameOptions.HideDeadBodies);

	m_pLowDetailSmoke.SetButtonBox( pGameOptions.LowDetailSmoke);
}

//=============================================================================================
// ConvertToGLEnum: Convert string to EGameOptionsGraphicLevel enum
//=============================================================================================
function R6GameOptions.EGameOptionsGraphicLevel ConvertToGLEnum( string _szValueToConvert)
{
	local R6GameOptions.EGameOptionsGraphicLevel eGLResult;

	switch(_szValueToConvert)
	{
		case m_pComboLevel[1]:
			eGLResult = eGL_Low;
			break;
		case m_pComboLevel[2]:
			eGLResult = eGL_Medium;
			break;
		case m_pComboLevel[3]:
			eGLResult = eGL_High;
			break;
		default:
			break;
	}

	return eGLResult;
}

//=============================================================================================
// ConvertToGLEnum: Convert string to EGameOptionsGraphicLevel enum
//=============================================================================================
function R6GameOptions.EGameOptionsEffectLevel ConvertToELEnum( string _szValueToConvert)
{
	local R6GameOptions.EGameOptionsEffectLevel eELResult;

	switch(_szValueToConvert)
	{
		case m_pComboLevel[0]:
			eELResult = eEL_None;
			break;
		case m_pComboLevel[1]:
			eELResult = eEL_Low;
			break;
		case m_pComboLevel[2]:
			eELResult = eEL_Medium;
			break;
		case m_pComboLevel[3]:
			eELResult = eEL_High;
			break;
		default:
			break;
	}

	return eELResult;
}

//=============================================================================================
// ConvertToGraphicString: This function convert graphics enum -- define in r6gameoptions to a value to display
//=============================================================================================
function string ConvertToGraphicString( INT _iAddItemMask, INT _iValueToConvert, string _szGraphicsEnumName, optional BOOL _bCheckFor32MegVideoCard)
{
	local string szResult;

	if (_szGraphicsEnumName == C_szEGameOptionsGraphicLevel)
	{
		switch(_iValueToConvert)
		{
			case 0:
				if ((_iAddItemMask & C_iITEM_LOW) > 0)
					szResult = m_pComboLevel[1]; // LOW
#ifdefDEBUG
				else
					log("Assign at least one valid item for your combo list");
#endif
				break;
			case 1:
				if ((_iAddItemMask & C_iITEM_MEDIUM) > 0)
					szResult = m_pComboLevel[2]; // MEDIUM
				else // try with a lowest item level
					szResult = ConvertToGraphicString( _iAddItemMask, 0, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				break;
			case 2: // try with a lowest item level
				if ((_iAddItemMask & C_iITEM_HIGH) > 0)
					szResult = m_pComboLevel[3]; // HIGH
				else
					szResult = ConvertToGraphicString( _iAddItemMask, 1, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				break;
			default:
				szResult = m_pComboLevel[1]; // ini file was modify with a bad value, put to LOW
				break;
		}
	}
	else // C_szEGameOptionsEffectLevel
	{
		switch(_iValueToConvert)
		{
			case 0:
				if ((_iAddItemMask & C_iITEM_NONE) > 0)
					szResult = m_pComboLevel[0]; // NONE
#ifdefDEBUG
				else
					log("Assign at least one valid item for your combo list");
#endif
				break;
			case 1:
				if ((_iAddItemMask & C_iITEM_LOW) > 0)
					szResult = m_pComboLevel[1]; // LOW
				else // try with a lowest item level
					szResult = ConvertToGraphicString( _iAddItemMask, 0, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				break;
			case 2: 
				if ((_iAddItemMask & C_iITEM_MEDIUM) > 0)
					szResult = m_pComboLevel[2]; // MEDIUM
				else // try with a lowest item level
					szResult = ConvertToGraphicString( _iAddItemMask, 1, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				break;
			case 3: // try with a lowest item level
				if ((_iAddItemMask & C_iITEM_HIGH) > 0)
					szResult = m_pComboLevel[3]; // HIGH
				else
					szResult = ConvertToGraphicString( _iAddItemMask, 2, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				break;
			default:
				szResult = m_pComboLevel[0]; // ini file was modify with a bad value, put to NONE
				break;
		}
	}

	if (_bCheckFor32MegVideoCard)
	{
		if (!class'Actor'.static.IsVideoHardwareAtLeast64M())
		{
			if (_szGraphicsEnumName == C_szEGameOptionsGraphicLevel) // high
			{
                if (szResult == m_pComboLevel[3])
    				szResult = ConvertToGraphicString( _iAddItemMask, 1, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
			}
			else // C_szEGameOptionsEffectLevel -- High
			{
                if (szResult == m_pComboLevel[3])
    				szResult = ConvertToGraphicString( _iAddItemMask, 2, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
			}
		}
	}

	return szResult;
}

function AddGraphComboControlItem( INT _iAddItemMask, R6WindowComboControl _pR6WindowComboControl, string _szGraphicsEnumName, optional BOOL _bCheckFor32MegVideoCard)
{
	local BOOL bAddHiItem;

	bAddHiItem = true;

	if (_szGraphicsEnumName == C_szEGameOptionsEffectLevel)
	{
		if ((_iAddItemMask & C_iITEM_NONE) > 0)
		_pR6WindowComboControl.AddItem( m_pComboLevel[0], "");
	}

	if ((_iAddItemMask & C_iITEM_LOW) > 0)
		_pR6WindowComboControl.AddItem( m_pComboLevel[1], "");
	if ((_iAddItemMask & C_iITEM_MEDIUM) > 0)
		_pR6WindowComboControl.AddItem( m_pComboLevel[2], "");

	if(_bCheckFor32MegVideoCard)
	{
		if (!class'Actor'.static.IsVideoHardwareAtLeast64M())
		{
			bAddHiItem = false;
		}
	}

	if ((bAddHiItem) && ( (_iAddItemMask & C_iITEM_HIGH) > 0))
		_pR6WindowComboControl.AddItem( m_pComboLevel[3], "");
}

//=============================================================================================
// AddVideoResolution: Add video resolution in the combo list
//=============================================================================================
function AddVideoResolution( R6WindowComboControl _pR6WindowComboControl)
{
	local INT i,j,iWidth, iHeight, iRefreshRate;
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

	i = class'Actor'.static.GetNbAvailableResolutions();

	for(j=0; j < i; j++)
	{
	    class'Actor'.static.GetAvailableResolution(j, iWidth, iHeight, iRefreshRate);
        
        if(pGameOptions.ShowRefreshRates)
            _pR6WindowComboControl.AddItem( iWidth $ "x" $ iHeight $ "@" $ iRefreshRate, "");
        else
            _pR6WindowComboControl.AddItem( iWidth $ "x" $ iHeight, "");
	}
}

function GetResolutionXY(OUT INT iSX, OUT INT iSY, OUT INT iRR)
{
	local INT	 iX;
	local string szTemp;
    local string szTemp2;
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

	szTemp  = m_pVideoRes.GetValue();
	iX		= InStr(szTemp, "x");
    szTemp2 = Left(szTemp, iX);
    iSX     = INT(szTemp2);
    szTemp  = Right(szTemp, Len(szTemp) - iX - 1); // -1 to remove the "x" char

    if(pGameOptions.ShowRefreshRates)
    {
	    iX		= InStr(szTemp, "@");
        szTemp2 = Left(szTemp, iX);
        iSY     = INT(szTemp2);
        szTemp  = Right(szTemp, Len(szTemp) - iX - 1); // -1 to remove the "x" char
        iRR     = INT(szTemp);
    }
    else
    {
        iSY     = INT(szTemp);
        iRR     = -1;
    }
}

//*******************************************************************************************
// OPTION HUD FILTERS
//*******************************************************************************************
function InitOptionHud()
{
    local FLOAT fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp, fSizeOfCounter;
    local Font ButtonFont;

    //create buttons -- check text label offset for concordance 
    ButtonFont = Root.Fonts[F_SmallTitle]; 

	m_ePageOptID = ePO_Hud;

    fXOffset = 5;
    fYOffset = 5;
    fWidth = (WinWidth * 0.5) - (2*fXOffset); 
    fHeight = 15;
    fYStep = 17;

    // WEAPON NAME
    m_pHudWeaponName = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudWeaponName.SetButtonBox( true);
    m_pHudWeaponName.CreateTextAndBox( Localize("Options","Opt_HudWeapon","R6Menu"), 
                                       Localize("Tip","Opt_HudWeapon","R6Menu"), 0, 
                                       0);
    fYOffset += fYStep;
	// SHOWFPWEAPON
    m_pHudShowFPWeapon = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudShowFPWeapon.SetButtonBox( false);
    m_pHudShowFPWeapon.CreateTextAndBox( Localize("Options","Opt_HudShowFPWeapon","R6Menu"), 
										 Localize("Tip","Opt_HudShowFPWeapon","R6Menu"), 0,
										 1);
    fYOffset += fYStep;
    // OTHER TEAM INFO
    m_pHudOtherTInfo = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudOtherTInfo.SetButtonBox( true);
    m_pHudOtherTInfo.CreateTextAndBox( Localize("Options","Opt_HudOtherTInfo","R6Menu"), 
                                       Localize("Tip","Opt_HudOtherTInfo","R6Menu"), 0, 
                                       2);
    fYOffset += fYStep;
    // CURRENT TEAM INFO
    m_pHudCurTInfo = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudCurTInfo.SetButtonBox( true);
    m_pHudCurTInfo.CreateTextAndBox( Localize("Options","Opt_HudCurTInfo","R6Menu"), 
                                     Localize("Tip","Opt_HudCurTInfo","R6Menu"), 0, 
                                     3);
    fYOffset += fYStep;
    // CIRCUMSTANCIAL ICON
    m_pHudCircumIcon = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudCircumIcon.SetButtonBox( true);
    m_pHudCircumIcon.CreateTextAndBox( Localize("Options","Opt_HudCircumIcon","R6Menu"), 
                                       Localize("Tip","Opt_HudCircumIcon","R6Menu"), 0, 
                                       4);

    fXOffset = (WinWidth * 0.5) + fXOffset;
    fYOffset = 5;
    // WAYPOINT INFO
    m_pHudWpInfo = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudWpInfo.SetButtonBox( true);
    m_pHudWpInfo.CreateTextAndBox( Localize("Options","Opt_HudWPInfo","R6Menu"), 
                                   Localize("Tip","Opt_HudWPInfo","R6Menu"), 0, 
                                   5);
    fYOffset += fYStep;
    // CROSS HAIR
    m_pHudReticule = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudReticule.SetButtonBox( true);
    m_pHudReticule.CreateTextAndBox( Localize("Options","Opt_HudCrossHair","R6Menu"), 
                                     Localize("Tip","Opt_HudCrossHair","R6Menu"), 0, 
                                     6);
    fYOffset += fYStep;
    // SHOW TEAMMATES NAMES
    m_pHudShowTNames = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudShowTNames.SetButtonBox( true);
    m_pHudShowTNames.CreateTextAndBox( Localize("Options","Opt_HudShowTNames","R6Menu"), 
									   Localize("Tip","Opt_HudShowTNames","R6Menu"), 0, 
                                       7);
    fYOffset += fYStep;
    // CHARACTER INFO
    m_pHudCharInfo = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudCharInfo.SetButtonBox( true);
    m_pHudCharInfo.CreateTextAndBox( Localize("Options","Opt_HudCharInfo","R6Menu"), 
                                     Localize("Tip","Opt_HudCharInfo","R6Menu"), 0, 
                                     8);
    fYOffset += fYStep;
    // SHOW RADAR
    m_pHudShowRadar = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pHudShowRadar.SetButtonBox( true);
    m_pHudShowRadar.CreateTextAndBox( Localize("Options","Opt_HudShowRadar","R6Menu"), 
                                      Localize("Tip","Opt_HudShowRadar","R6Menu"), 0, 
                                      9);

	CreateHudOptionsTex();

	InitResetButton();
	SetMenuHudValues();

	m_bInitComplete = true;
}

//=============================================================================================
// SetGameValue: Set the R6GameOptions values
//=============================================================================================
function SetHudValues()
{
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

	pGameOptions.HUDShowWeaponInfo		= m_pHudWeaponName.m_bSelected;
	pGameOptions.HUDShowFPWeapon		= m_pHudShowFPWeapon.m_bSelected;
	pGameOptions.HUDShowOtherTeamInfo   = m_pHudOtherTInfo.m_bSelected;
	pGameOptions.HUDShowCurrentTeamInfo = m_pHudCurTInfo.m_bSelected;
	pGameOptions.HUDShowActionIcon		= m_pHudCircumIcon.m_bSelected;
	pGameOptions.HUDShowWaypointInfo    = m_pHudWpInfo.m_bSelected;
	pGameOptions.HUDShowReticule		= m_pHudReticule.m_bSelected;
	pGameOptions.HUDShowCharacterInfo   = m_pHudCharInfo.m_bSelected;
	pGameOptions.HUDShowPlayersName		= m_pHudShowTNames.m_bSelected;
	pGameOptions.ShowRadar				= m_pHudShowRadar.m_bSelected;

	UpdateHudOptionsTex();
}

//=============================================================================================
// SetMenuGameValue: Set the menu game values according the value store in uw.ini by R6GameOptions
//=============================================================================================
function SetMenuHudValues()
{
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

	m_pHudWeaponName.SetButtonBox( pGameOptions.HUDShowWeaponInfo);
	m_pHudShowFPWeapon.SetButtonBox( pGameOptions.HUDShowFPWeapon);
	m_pHudOtherTInfo.SetButtonBox( pGameOptions.HUDShowOtherTeamInfo);
	m_pHudCurTInfo.SetButtonBox( pGameOptions.HUDShowCurrentTeamInfo);
	m_pHudCircumIcon.SetButtonBox( pGameOptions.HUDShowActionIcon);
	m_pHudWpInfo.SetButtonBox( pGameOptions.HUDShowWaypointInfo);
	m_pHudReticule.SetButtonBox( pGameOptions.HUDShowReticule);
	m_pHudCharInfo.SetButtonBox( pGameOptions.HUDShowCharacterInfo);
	m_pHudShowTNames.SetButtonBox( pGameOptions.HUDShowPlayersName);
	m_pHudShowRadar.SetButtonBox( pGameOptions.ShowRadar);

	UpdateHudOptionsTex();
}

function CreateHudOptionsTex()
{
	m_pHudBGTex				= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayBackground', true);
	m_pHudBGTex.bAlwaysBehind  = true;
	m_pHudBGTex.m_BorderColor  = Root.Colors.White;

	m_pHudWeaponNameTex		= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayWeaponInfo');
	m_pHudShowFPWeaponTex	= CreateHudBitmapWindow( Texture'R6MenuTextures.Display1stPersonWeapon');
	m_pHudOtherTInfoTex		= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayOtherTeamInfo');
	m_pHudCurTInfoTex		= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayCurrentTeamInfo');
	m_pHudCircumIconTex		= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayActionIcon');
	m_pHudWpInfoTex			= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayWaypointInfo');
	m_pHudReticuleTex		= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayReticule');
	m_pHudCharInfoTex		= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayCharacterInfo');
	m_pHudShowTNamesTex		= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayTeammateNames');
	m_pHudShowRadarTex		= CreateHudBitmapWindow( Texture'R6MenuTextures.DisplayMPRadar');
}

function R6WindowBitMap CreateHudBitmapWindow( Texture _Tex, optional BOOL _bDrawSimpleBorder)
{
	local R6WindowBitMap _NewR6WindowBitMap;

	_NewR6WindowBitMap   = R6WindowBitMap(CreateWindow(class'R6WindowBitMap', 77, 96, 262, 198, self));
	_NewR6WindowBitMap.T = _Tex;
	_NewR6WindowBitMap.R = NewRegion( 0, 0, 260, 196);
	_NewR6WindowBitMap.m_iDrawStyle  = ERenderStyle.STY_Alpha;
	_NewR6WindowBitMap.m_bDrawBorder = _bDrawSimpleBorder;
	_NewR6WindowBitMap.m_ImageX = 1;
	_NewR6WindowBitMap.m_ImageY = 1;

	return _NewR6WindowBitMap;
}

function UpdateHudOptionsTex()
{
	m_pHudWeaponNameTex.HideWindow();
	m_pHudShowFPWeaponTex.HideWindow(); 
	m_pHudOtherTInfoTex.HideWindow();	
	m_pHudCurTInfoTex.HideWindow();	
	m_pHudCircumIconTex.HideWindow();	
	m_pHudWpInfoTex.HideWindow();		
	m_pHudReticuleTex.HideWindow();	
	m_pHudCharInfoTex.HideWindow();	
	m_pHudShowTNamesTex.HideWindow();	
	m_pHudShowRadarTex.HideWindow();

	if (m_pHudWeaponName.m_bSelected)
		m_pHudWeaponNameTex.ShowWindow();

	if (m_pHudShowTNames.m_bSelected)
		m_pHudShowTNamesTex.ShowWindow();

	if (m_pHudShowFPWeapon.m_bSelected)
		m_pHudShowFPWeaponTex.ShowWindow();

	if (m_pHudOtherTInfo.m_bSelected)
		m_pHudOtherTInfoTex.ShowWindow();

	if (m_pHudCurTInfo.m_bSelected)
		m_pHudCurTInfoTex.ShowWindow();

	if (m_pHudCircumIcon.m_bSelected)
		m_pHudCircumIconTex.ShowWindow();

	if (m_pHudWpInfo.m_bSelected)
		m_pHudWpInfoTex.ShowWindow();

	if (m_pHudReticule.m_bSelected)
		m_pHudReticuleTex.ShowWindow();

	if (m_pHudCharInfo.m_bSelected)
		m_pHudCharInfoTex.ShowWindow();

	if (m_pHudShowRadar.m_bSelected)
		m_pHudShowRadarTex.ShowWindow();

}

//*******************************************************************************************
// OPTION MULTIPLAYER
//*******************************************************************************************
function InitOptionMulti(BOOL _bInGameOptions)
{
	local Region rRegionW;
    local FLOAT fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp, fSizeOfCounter;
    local Font ButtonFont;

    //create buttons -- check text label offset for concordance 
    ButtonFont = Root.Fonts[F_SmallTitle]; 

	m_ePageOptID = ePO_MP;

    fXOffset = 5;
    fYOffset = 5;
    fWidth = WinWidth - fXOffset - 20; // 40 distance to the end of the window
    fHeight = 15;
    fYStep = 27;

    // PLAYER NAME
	m_pOptionPlayerName = R6WindowEditControl(CreateWindow(class'R6WindowEditControl', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pOptionPlayerName.SetValue( "");
//    m_pOptionPlayerName.ForceCaps(true);	
	m_pOptionPlayerName.CreateTextLabel( Localize("Options","Opt_NetPlayerName","R6Menu"),
										 0, 0, fWidth * 0.5, fHeight);
	m_pOptionPlayerName.SetEditBoxTip( Localize("Tip","Opt_NetPlayerName","R6Menu"));
	m_pOptionPlayerName.ModifyEditBoxW( C_fXPOS_COMBOCONTROL, 0, 135, fHeight);//fXOffset + (fWidth * 0.5), 0, fWidth * 0.5, fHeight);
	m_pOptionPlayerName.EditBox.MaxLength = 15; // Max of 15 caracters

	fYOffset += fYStep;	
	rRegionW.X = fXOffset;
	rRegionW.Y = fYOffset;
	rRegionW.W = fWidth; 
	rRegionW.H = fHeight;
	// CONNECTION SPEED
	m_pSpeedConnection = SetComboControlButton( rRegionW, Localize("Options","Opt_NetConnecSpeed","R6Menu"), 
														  Localize("Tip","Opt_NetConnecSpeed","R6Menu"));
	
	m_pSpeedConnection.AddItem( m_pConnectionSpeed[0], "");
	m_pSpeedConnection.AddItem( m_pConnectionSpeed[1], "");
	m_pSpeedConnection.AddItem( m_pConnectionSpeed[2], "");
	m_pSpeedConnection.AddItem( m_pConnectionSpeed[3], "");
	m_pSpeedConnection.AddItem( m_pConnectionSpeed[4], "");

    fYOffset += fYStep;
	fWidth -=20;
	// GENDER
	m_pOptionGender = R6WindowButtonExt(CreateControl(class'R6WindowButtonExt', fXOffset, fYOffset, WinWidth - fXOffset, fHeight, self));
	m_pOptionGender.CreateTextAndBox( Localize("Options","Opt_NetGender","R6Menu"), 
									  Localize("Tip","Opt_NetGender","R6Menu"), 0, 0, 2);
	m_pOptionGender.SetCheckBox( Localize("Options","Opt_NetGenderMale","R6Menu"), 250, true, 0);
	m_pOptionGender.SetCheckBox( Localize("Options","Opt_NetGenderFemale","R6Menu"), 356, false, 1);

    fYOffset += fYStep;	
	// USE ARM PATCH
    m_pArmpatchChooser = R6MenuArmpatchSelect(CreateWindow(class'R6MenuArmpatchSelect',fXOffset, fYOffset, WinWidth - fXOffset, m_RArmpatchListPos.H, self));
    m_pArmpatchChooser.CreateTextLabel(0,0, m_RArmpatchListPos.X, m_pArmpatchChooser.WinHeight,
                                       Localize("Options","Opt_NetUArmP","R6Menu"), 
                                       Localize("Tip","Opt_NetUArmP","R6Menu"));
    m_pArmpatchChooser.CreateListBox(m_RArmpatchListPos.X ,m_RArmpatchListPos.Y,m_RArmpatchListPos.W,m_RArmpatchListPos.H);
    m_pArmpatchChooser.CreateArmPatchBitmap(m_RArmpatchBitmapPos.X, m_RArmpatchBitmapPos.Y, m_RArmpatchBitmapPos.W, m_RArmpatchBitmapPos.H);
    m_pArmpatchChooser.RefreshListBox();
    m_pArmpatchChooser.SetToolTip(Localize("Tip","Opt_NetUArmP","R6Menu"));

//#ifdefR6PUNKBUSTER
    fYOffset = m_pArmpatchChooser.WinTop + m_pArmpatchChooser.WinHeight + 15;
	// PUNKBUSTER
    m_pPunkBusterOpt = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pPunkBusterOpt.SetButtonBox( false);
    m_pPunkBusterOpt.CreateTextAndBox( Localize("Options","Opt_NetPunkBuster","R6Menu"), 
                                       Localize("Tip","Opt_NetPunkBuster","R6Menu"), 0, 
                                       0);
	m_pPunkBusterOpt.m_szToolTipWhenDisable = Localize("Tip","Opt_NetPunkBuster","R6Menu");
//#endif

    fYOffset += fYStep;	

	m_bTriggerLagWanted = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_bTriggerLagWanted.SetButtonBox(false);
    m_bTriggerLagWanted.CreateTextAndBox( Localize("Options","Opt_TriggerLag","R6Menu"), 
                                          Localize("Tip","Opt_TriggerLag","R6Menu"), 0, 2);
 
	InitResetButton();
	SetMenuMultiValues();

	m_bInitComplete = true;
}

//=============================================================================================
// SetMultiValue: Set the R6GameOptions values
//=============================================================================================
function SetMultiValues()
{
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

	if (m_pOptionPlayerName.GetValue() != m_pOptionPlayerName.GetValue2())
	{
		GetPlayerOwner().Name(m_pOptionPlayerName.GetValue()); // update game options and URL value
		m_pOptionPlayerName.SetValue( m_pOptionPlayerName.GetValue(), m_pOptionPlayerName.GetValue());
	}

	pGameOptions.NetSpeed = ConvertToNSEnum( m_pSpeedConnection.GetValue());
    switch(pGameOptions.NetSpeed)
    {
    case eNS_T1:    Root.Console.ConsoleCommand("NETSPEED 20000"); break;
    case eNS_T3:    Root.Console.ConsoleCommand("NETSPEED 20000"); break;
    case eNS_Cable: Root.Console.ConsoleCommand("NETSPEED 4000"); break;    //  ~400K download,   ~16K upload
    case eNS_ADSL:  Root.Console.ConsoleCommand("NETSPEED 5000"); break;    // ~1024K download, ~1024K upload
    case eNS_Modem: Root.Console.ConsoleCommand("NETSPEED 1500"); break;    //    ~5K download,    ~5K upload
    default:        Root.Console.ConsoleCommand("NETSPEED 5000"); break;
    }

	pGameOptions.Gender		   = m_pOptionGender.GetCheckBoxStatus();
    pGameOptions.ArmPatchTexture = m_pArmpatchChooser.GetSelectedArmpatch();

//#ifdefR6PUNKBUSTER
	pGameOptions.ActivePunkBuster = m_pPunkBusterOpt.m_bSelected;
//#endif
    pGameOptions.WantTriggerLag = !m_bTriggerLagWanted.m_bSelected;
}

//=============================================================================================
// SetMultiValue: Set the multi values according the value store in uw.ini by R6GameOptions
//=============================================================================================
function SetMenuMultiValues()
{
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

	if (!m_bInitComplete)
		m_pOptionPlayerName.SetValue( pGameOptions.CharacterName, pGameOptions.CharacterName);
	else
		m_pOptionPlayerName.SetValue( pGameOptions.CharacterName, m_pOptionPlayerName.GetValue2());

	m_pOptionPlayerName.EditBox.MoveHome();
	m_pSpeedConnection.SetValue( ConvertToNetSpeedString(pGameOptions.NetSpeed));
	m_pOptionGender.SetCheckBoxStatus(pGameOptions.Gender);

    m_pArmpatchChooser.SetDesiredSelectedArmpatch(pGameOptions.ArmPatchTexture);

//#ifdefR6PUNKBUSTER
	if (m_bInitComplete)
    {
        if ((pGameOptions.ActivePunkBuster != class'Actor'.static.IsPBClientEnabled()))
            pGameOptions.ActivePunkBuster = !pGameOptions.ActivePunkBuster;
            
        m_pPunkBusterOpt.SetButtonBox( pGameOptions.ActivePunkBuster );
    }
//#endif

    m_bTriggerLagWanted.SetButtonBox( !pGameOptions.WantTriggerLag );
}

//#ifdefR6PUNKBUSTER
function SetPBOptValue()
{
	local R6GameOptions pGameOptions;

#ifdefDEBUG
	local BOOL bShowLog;
	bShowLog = true;

	if (bShowLog) log("R6MenuOptionsTab GetPBOptValue");
#endif

	pGameOptions = class'Actor'.static.GetGameOptions();

	if (pGameOptions.m_bPBInstalled)	// PUNKBUSTER installed?
	{
#ifdefDEBUG
		if (bShowLog) log("PunkBuster is installed");
#endif
		// do verification before according the state define in .ini
		if (pGameOptions.ActivePunkBuster)
		{
#ifdefDEBUG
		if (bShowLog) log("User.ini define ActivePunkBuster to be active");
#endif
			if (!class'Actor'.static.IsPBClientEnabled())
			{
#ifdefDEBUG
				if (bShowLog) log("PunkBuster is disable, try to enable it");
#endif
				// try to set PBClientEnable
				class'Actor'.static.SetPBStatus( false, false);

				if (!class'Actor'.static.IsPBClientEnabled())
				{
#ifdefDEBUG
					if (bShowLog) log("CAN'T ACTIVATE PunkBuster, WHAT'S WRONG???");
#endif
					SetPBOptDisable();
					pGameOptions.ActivePunkBuster = false;
				}
			}
		}
		else
		{
#ifdefDEBUG
			if (bShowLog) log("User.ini define ActivePunkBuster to be inactive");
#endif
			if (class'Actor'.static.IsPBClientEnabled())
			{
#ifdefDEBUG
				if (bShowLog) log("PunkBuster is enable, you have to disable it!!!");
#endif
				// user modify .ini, try to disable PB -- this should happen only the next time user will load
				class'Actor'.static.SetPBStatus( true, false);
			}
		}
	}
	else // disabled the button
	{
#ifdefDEBUG
		if (bShowLog) log("PunkBuster is not installed");
#endif
		SetPBOptDisable();
		pGameOptions.ActivePunkBuster = false;
	}

	m_pPunkBusterOpt.SetButtonBox( pGameOptions.ActivePunkBuster);
}

function SetPBOptDisable()
{
	m_bPBNotInstalled = true;
	m_pPunkBusterOpt.bDisabled = true;
//	m_pPunkBusterOpt.SetButtonBox( False);    
}
//#endif

//=============================================================================================
// ConvertToGLEnum: Convert string to EGameOptionsGraphicLevel enum
//=============================================================================================
function R6GameOptions.EGameOptionsNetSpeed ConvertToNSEnum( string _szValueToConvert)
{
	local R6GameOptions.EGameOptionsNetSpeed eNSResult;

	switch(_szValueToConvert)
	{
		case m_pConnectionSpeed[0]:
			eNSResult = eNS_T1;
			break;
		case m_pConnectionSpeed[1]:
			eNSResult = eNS_T3;
			break;
		case m_pConnectionSpeed[2]:
			eNSResult = eNS_Cable;
			break;
		case m_pConnectionSpeed[3]:
			eNSResult = eNS_ADSL;
			break;
		case m_pConnectionSpeed[4]:
			eNSResult = eNS_Modem;
			break;
		default:
			eNSResult = eNS_T1; // in case the file was modified
			break;
	}

	return eNSResult;
}

//=============================================================================================
// ConvertToGraphicString: This function convert graphics enum -- define in r6gameoptions to a value to display
//=============================================================================================
function string ConvertToNetSpeedString( INT _iValueToConvert)
{
	local string szResult;

	switch(_iValueToConvert)
	{
		case 0:
			szResult = m_pConnectionSpeed[0];
			break;
		case 1:
			szResult = m_pConnectionSpeed[1];
			break;
		case 2:
			szResult = m_pConnectionSpeed[2];
			break;
		case 3:
			szResult = m_pConnectionSpeed[3];
			break;
		case 4:
			szResult = m_pConnectionSpeed[4];
			break;
		default:
			szResult = m_pConnectionSpeed[0]; // in case the file was modified
			break;
	}

	return szResult;
}

//*******************************************************************************************
// OPTION CONTROLS
//*******************************************************************************************
function InitOptionControls()
{
	local FLOAT fXOffset, fYOffset;

	m_ePageOptID = ePO_Controls;

	fXOffset = 0;
	fYOffset = 0;

    // create the two lists box
    m_pListControls = R6WindowListControls(CreateControl( class'R6WindowListControls', fXOffset, fYOffset, WinWidth - fXOffset, WinHeight - 14 - fYOffset, self));
	m_pListControls.m_fItemHeight = 15;
	m_pListControls.m_fXOffset	 = 5;

	CreateKeyPopUp();

	// MOVEMENT
	// add items in order
    AddTitleItem( "", m_pListControls);     //Spacing
	AddTitleItem( Localize("Keys","Title_Move","R6Menu"), m_pListControls);

	AddKeyItem( Localize("Keys","K_MoveForward","R6Menu"), Localize("Keys","K_MoveForward","R6Menu"), "MoveForward", m_pListControls);
	AddKeyItem( Localize("Keys","K_MoveBackward","R6Menu"), Localize("Keys","K_MoveBackward","R6Menu"), "MoveBackward", m_pListControls);

	AddKeyItem( Localize("Keys","K_StrafeLeft","R6Menu"), Localize("Keys","K_StrafeLeft","R6Menu"), "StrafeLeft", m_pListControls);
	AddKeyItem( Localize("Keys","K_StrafeRight","R6Menu"), Localize("Keys","K_StrafeRight","R6Menu"), "StrafeRight", m_pListControls);

	AddKeyItem( Localize("Keys","K_PeekLeft","R6Menu"), Localize("Keys","K_PeekLeft","R6Menu"), "PeekLeft", m_pListControls);
	AddKeyItem( Localize("Keys","K_PeekRight","R6Menu"), Localize("Keys","K_PeekRight","R6Menu"), "PeekRight", m_pListControls);

	AddKeyItem( Localize("Keys","K_RaisePosture","R6Menu"), Localize("Keys","K_RaisePosture","R6Menu"), "RaisePosture", m_pListControls);
	AddKeyItem( Localize("Keys","K_LowerPosture","R6Menu"), Localize("Keys","K_LowerPosture","R6Menu"), "LowerPosture", m_pListControls);

	AddKeyItem( Localize("Keys","K_Run","R6Menu"), Localize("Keys","K_Run","R6Menu"), "Run", m_pListControls);

	AddKeyItem( Localize("Keys","K_FluidPosture","R6Menu"), Localize("Keys","K_FluidPosture","R6Menu"), "FluidPosture", m_pListControls);

	AddLineItem( m_pListControls);

	// WEAPON
	AddTitleItem( Localize("Keys","Title_Weapon","R6Menu"), m_pListControls);

	AddKeyItem( Localize("Keys","K_Reload","R6Menu"), Localize("Keys","K_Reload","R6Menu"), "Reload", m_pListControls);

	AddKeyItem( Localize("Keys","K_PrimaryWeapon","R6Menu"), Localize("Keys","K_PrimaryWeapon","R6Menu"), "PrimaryWeapon", m_pListControls);
	AddKeyItem( Localize("Keys","K_SecondaryWeapon","R6Menu"), Localize("Keys","K_SecondaryWeapon","R6Menu"), "SecondaryWeapon", m_pListControls);

	AddKeyItem( Localize("Keys","K_GadgetOne","R6Menu"), Localize("Keys","K_GadgetOne","R6Menu"), "GadgetOne", m_pListControls);
	AddKeyItem( Localize("Keys","K_GadgetTwo","R6Menu"), Localize("Keys","K_GadgetTwo","R6Menu"), "GadgetTwo", m_pListControls);

	AddKeyItem( Localize("Keys","K_ChangeRateOfFire","R6Menu"), Localize("Keys","K_ChangeRateOfFire","R6Menu"), "ChangeRateOfFire", m_pListControls);

	AddKeyItem( Localize("Keys","K_PrimaryFire","R6Menu"), Localize("Keys","K_PrimaryFire","R6Menu"), "PrimaryFire", m_pListControls);
	AddKeyItem( Localize("Keys","K_SecondaryFire","R6Menu"), Localize("Keys","K_SecondaryFire","R6Menu"), "SecondaryFire", m_pListControls);

	AddKeyItem( Localize("Keys","K_Zoom","R6Menu"), Localize("Keys","K_Zoom","R6Menu"), "Zoom", m_pListControls);

	AddKeyItem( Localize("Keys","K_InventoryMenu","R6Menu"), Localize("Keys","K_InventoryMenu","R6Menu"), "InventoryMenu", m_pListControls);

	AddLineItem( m_pListControls);

	// ORDERS
	AddTitleItem( Localize("Keys","Title_Orders","R6Menu"), m_pListControls);

	AddKeyItem( Localize("Keys","K_GoCodeAlpha","R6Menu"), Localize("Keys","K_GoCodeAlpha","R6Menu"), "GoCodeAlpha", m_pListControls);
	AddKeyItem( Localize("Keys","K_GoCodeBravo","R6Menu"), Localize("Keys","K_GoCodeBravo","R6Menu"), "GoCodeBravo", m_pListControls);
	AddKeyItem( Localize("Keys","K_GoCodeCharlie","R6Menu"), Localize("Keys","K_GoCodeCharlie","R6Menu"), "GoCodeCharlie", m_pListControls);
	AddKeyItem( Localize("Keys","K_GoCodeZulu","R6Menu"), Localize("Keys","K_GoCodeZulu","R6Menu"), "GoCodeZulu", m_pListControls);

	AddKeyItem( Localize("Keys","K_RulesOfEngagement","R6Menu"), Localize("Keys","K_RulesOfEngagement","R6Menu"), "RulesOfEngagement", m_pListControls);
	AddKeyItem( Localize("Keys","K_SkipDestination","R6Menu"), Localize("Keys","K_SkipDestination","R6Menu"), "SkipDestination", m_pListControls);

	AddKeyItem( Localize("Keys","K_ToggleAllTeamsHold","R6Menu"), Localize("Keys","K_ToggleAllTeamsHold","R6Menu"), "ToggleAllTeamsHold", m_pListControls);
	AddKeyItem( Localize("Keys","K_ToggleTeamHold","R6Menu"), Localize("Keys","K_ToggleTeamHold","R6Menu"), "ToggleTeamHold", m_pListControls);
	AddKeyItem( Localize("Keys","K_ToggleSniperControl","R6Menu"), Localize("Keys","K_ToggleSniperControl","R6Menu"), "ToggleSniperControl", m_pListControls);

	AddLineItem( m_pListControls);

	// ACTIONS
	AddTitleItem( Localize("Keys","Title_Actions","R6Menu"), m_pListControls);

	AddKeyItem( Localize("Keys","K_GraduallyOpenDoor","R6Menu"), Localize("Keys","K_GraduallyOpenDoor","R6Menu"), "GraduallyOpenDoor", m_pListControls);
	AddKeyItem( Localize("Keys","K_GraduallyCloseDoor","R6Menu"), Localize("Keys","K_GraduallyCloseDoor","R6Menu"), "GraduallyCloseDoor", m_pListControls);
	AddKeyItem( Localize("Keys","K_SpeedUpDoor","R6Menu"), Localize("Keys","K_SpeedUpDoor","R6Menu"), "SpeedUpDoor", m_pListControls);

	AddKeyItem( Localize("Keys","K_Action","R6Menu"), Localize("Keys","K_Action","R6Menu"), "Action", m_pListControls);

	AddKeyItem( Localize("Keys","K_ToggleNightVision","R6Menu"), Localize("Keys","K_ToggleNightVision","R6Menu"), "ToggleNightVision", m_pListControls);

	AddKeyItem( Localize("Keys","K_NextTeam","R6Menu"), Localize("Keys","K_NextTeam","R6Menu"), "NextTeam", m_pListControls);
	AddKeyItem( Localize("Keys","K_PreviousTeam","R6Menu"), Localize("Keys","K_PreviousTeam","R6Menu"), "PreviousTeam", m_pListControls);

	AddKeyItem( Localize("Keys","K_NextMember","R6Menu"), Localize("Keys","K_NextMember","R6Menu"), "NextMember", m_pListControls);
	AddKeyItem( Localize("Keys","K_PreviousMember","R6Menu"), Localize("Keys","K_PreviousMember","R6Menu"), "PreviousMember", m_pListControls);

	AddKeyItem( Localize("Keys","K_ToggleMap","R6Menu"), Localize("Keys","K_ToggleMap","R6Menu"), "ToggleMap", m_pListControls);
	AddKeyItem( Localize("Keys","K_MapZoomIn","R6Menu"), Localize("Keys","K_MapZoomIn","R6Menu"), "MapZoomIn", m_pListControls);
	AddKeyItem( Localize("Keys","K_MapZoomOut","R6Menu"), Localize("Keys","K_MapZoomOut","R6Menu"), "MapZoomOut", m_pListControls);

	AddKeyItem( Localize("Keys","K_OperativeSelector","R6Menu"), Localize("Keys","K_OperativeSelector","R6Menu"), "OperativeSelector", m_pListControls);

	AddLineItem( m_pListControls);

#ifndefSPDEMO
	// MULTIPLAYER
	AddTitleItem( Localize("Keys","Title_MP","R6Menu"), m_pListControls);

	AddKeyItem( Localize("Keys","K_ToggleGameStats","R6Menu"), Localize("Keys","K_ToggleGameStats","R6Menu"), "ToggleGameStats", m_pListControls);

	AddKeyItem( Localize("Keys","K_Talk","R6Menu"), Localize("Keys","K_Talk","R6Menu"), "Talk", m_pListControls);
	AddKeyItem( Localize("Keys","K_TeamTalk","R6Menu"), Localize("Keys","K_TeamTalk","R6Menu"), "TeamTalk", m_pListControls);

	AddKeyItem( Localize("Keys","K_DrawingTool","R6Menu"), Localize("Keys","K_DrawingTool","R6Menu"), "DrawingTool", m_pListControls);

	AddKeyItem( Localize("Keys","K_PreRecMessages","R6Menu"), Localize("Keys","K_PreRecMessages","R6Menu"), "PreRecMessages", m_pListControls);
	AddKeyItem( Localize("Keys","K_VotingMenu","R6Menu"), Localize("Keys","K_VotingMenu","R6Menu"), "VotingMenu", m_pListControls);

	AddLineItem( m_pListControls);
#endif

	// OTHERS
	AddTitleItem( Localize("Keys","Title_Others","R6Menu"), m_pListControls);

	AddKeyItem( Localize("Keys","K_Console","R6Menu"), Localize("Keys","K_Console","R6Menu"), "Console", m_pListControls);
	
	AddKeyItem( Localize("Keys","K_ToggleAutoAim","R6Menu"), Localize("Keys","K_ToggleAutoAim","R6Menu"), "ToggleAutoAim", m_pListControls);

	AddKeyItem( Localize("Keys","K_Shot","R6Menu"), Localize("Keys","K_Shot","R6Menu"), "Shot", m_pListControls);

	AddKeyItem( Localize("Keys","K_ShowCompleteHud","R6Menu"), Localize("Keys","K_ShowCompleteHud","R6Menu"), "ShowCompleteHud", m_pListControls);

#ifndefMPDEMO
	AddLineItem( m_pListControls);
	// PLANNING
	AddTitleItem( Localize("Keys","Title_Planning","R6Menu"), m_pListControls);

	AddKeyItem( Localize("Keys","K_MoveUp","R6Menu"), Localize("Keys","K_MoveUp","R6Menu"), "MoveUp", m_pListControls, True);
	AddKeyItem( Localize("Keys","K_MoveDown","R6Menu"), Localize("Keys","K_MoveDown","R6Menu"), "MoveDown", m_pListControls, True);
	AddKeyItem( Localize("Keys","K_MoveLeft","R6Menu"), Localize("Keys","K_MoveLeft","R6Menu"), "MoveLeft", m_pListControls, True);
	AddKeyItem( Localize("Keys","K_MoveRight","R6Menu"), Localize("Keys","K_MoveRight","R6Menu"), "MoveRight", m_pListControls, True);

	AddKeyItem( Localize("Keys","K_ZoomIn","R6Menu"), Localize("Keys","K_ZoomIn","R6Menu"), "ZoomIn", m_pListControls, True);
	AddKeyItem( Localize("Keys","K_ZoomOut","R6Menu"), Localize("Keys","K_ZoomOut","R6Menu"), "ZoomOut", m_pListControls, True);

	AddKeyItem( Localize("Keys","K_LevelUp","R6Menu"), Localize("Keys","K_LevelUp","R6Menu"), "LevelUp", m_pListControls, True);
	AddKeyItem( Localize("Keys","K_LevelDown","R6Menu"), Localize("Keys","K_LevelDown","R6Menu"), "LevelDown", m_pListControls, True);

	AddKeyItem( Localize("Keys","K_RotateClockWise","R6Menu"), Localize("Keys","K_RotateClockWise","R6Menu"), "RotateClockWise", m_pListControls, True);
	AddKeyItem( Localize("Keys","K_RotateCounterClockWise","R6Menu"), Localize("Keys","K_RotateCounterClockWise","R6Menu"), "RotateCounterClockWise", m_pListControls, True);

	AddKeyItem( Localize("Keys","K_DeleteWaypoint","R6Menu"), Localize("Keys","K_DeleteWaypoint","R6Menu"), "DeleteWaypoint", m_pListControls, True);
	AddKeyItem( Localize("Keys","K_NextWaypoint","R6Menu"), Localize("Keys","K_NextWaypoint","R6Menu"), "NextWaypoint", m_pListControls, True);
	AddKeyItem( Localize("Keys","K_PrevWaypoint","R6Menu"), Localize("Keys","K_PrevWaypoint","R6Menu"), "PrevWaypoint", m_pListControls, True);
	AddKeyItem( Localize("Keys","K_FirstWaypoint","R6Menu"), Localize("Keys","K_FirstWaypoint","R6Menu"), "FirstWaypoint", m_pListControls, True);
	AddKeyItem( Localize("Keys","K_LastWaypoint","R6Menu"), Localize("Keys","K_LastWaypoint","R6Menu"), "LastWaypoint", m_pListControls, True);

	AddKeyItem( Localize("Keys","K_AngleUp","R6Menu"), Localize("Keys","K_AngleUp","R6Menu"), "AngleUp", m_pListControls, True);
	AddKeyItem( Localize("Keys","K_AngleDown","R6Menu"), Localize("Keys","K_AngleDown","R6Menu"), "AngleDown", m_pListControls, True);
    
	AddKeyItem( Localize("Keys","K_RedTeam","R6Menu"), Localize("Keys","K_RedTeam","R6Menu"), "SwitchToRedTeam", m_pListControls, True);
	AddKeyItem( Localize("Keys","K_GreenTeam","R6Menu"), Localize("Keys","K_GreenTeam","R6Menu"), "SwitchToGreenTeam", m_pListControls, True);
	AddKeyItem( Localize("Keys","K_GoldTeam","R6Menu"), Localize("Keys","K_GoldTeam","R6Menu"), "SwitchToGoldTeam", m_pListControls, True);
    
    AddKeyItem( Localize("Keys","K_ViewRed","R6Menu"), Localize("Keys","K_ViewRed","R6Menu"), "ViewRedTeam", m_pListControls, True);
	AddKeyItem( Localize("Keys","K_ViewGreen","R6Menu"), Localize("Keys","K_ViewGreen","R6Menu"), "ViewGreenTeam", m_pListControls, True);
	AddKeyItem( Localize("Keys","K_ViewGold","R6Menu"), Localize("Keys","K_ViewGold","R6Menu"), "ViewGoldTeam", m_pListControls, True);
#endif

	InitResetButton();

	m_bInitComplete = true;
}

//===============================================================================
// AddLineItem: add a line item in the list
//===============================================================================
function AddLineItem( R6WindowListControls _pR6WindowListControls)
{
	local UWindowListBoxItem NewItem;

    NewItem = UWindowListBoxItem(_pR6WindowListControls.Items.Append(_pR6WindowListControls.ListClass));
    NewItem.HelpText				= "";
	NewItem.m_bImALine				= true;
	NewItem.m_vItemColor			= Root.Colors.White;
	NewItem.m_bNotAffectByNotify	= true;
}

//===============================================================================
// AddTitleItem: Add a title item only
//===============================================================================
function AddTitleItem( string _szTitle, R6WindowListControls _pR6WindowListControls)
{
	local UWindowListBoxItem NewItem;

    NewItem = UWindowListBoxItem(_pR6WindowListControls.Items.Append(_pR6WindowListControls.ListClass));
    NewItem.HelpText				= _szTitle;
	NewItem.m_vItemColor			= Root.Colors.White;
	NewItem.m_bNotAffectByNotify	= true;
}

//===============================================================================
// AddKeyItem: Add a key item
//===============================================================================
function AddKeyItem( string _szTitle, string _szToolTip, string _szActionKey, R6WindowListControls _pR6WindowListControls, optional BOOL _bPlanningInput)
{
	local UWindowListBoxItem NewItem;

    NewItem = UWindowListBoxItem(_pR6WindowListControls.Items.Append(_pR6WindowListControls.ListClass));
    NewItem.HelpText				= _szTitle;
	NewItem.m_szToolTip				= _szToolTip;
	NewItem.m_vItemColor			= Root.Colors.White;
	NewItem.m_szActionKey			= _szActionKey;

	NewItem.m_szFakeEditBoxValue	= GetLocKeyNameByActionKey( _szActionKey, _bPlanningInput); // value to display "the key name"
	
	NewItem.m_fXFakeEditBox			= 220;
	NewItem.m_fWFakeEditBox			= WinWidth - NewItem.m_fXFakeEditBox - 40; // 40 is the space between the end of the fake edit box and the scroll bar

	if (_bPlanningInput)
		NewItem.m_iItemID			= 1; // PLANNING INPUT
	else
		NewItem.m_iItemID			= 0; // GAME INPUT
}

//===============================================================================
// RefreshKeyList: Refresh the list of key with the new value in user.ini
//===============================================================================
function RefreshKeyList()
{
	local UWindowList ListItem;
	local string szTemp;

	for ( ListItem = m_pListControls.Items.Next; ListItem != None ; ListItem = ListItem.Next)
	{
		if (!UWindowListBoxItem(ListItem).m_bNotAffectByNotify)
		{
			if (UWindowListBoxItem(ListItem).m_iItemID == 0)
				UWindowListBoxItem(ListItem).m_szFakeEditBoxValue = GetLocKeyNameByActionKey(UWindowListBoxItem(ListItem).m_szActionKey, false);
			else
				UWindowListBoxItem(ListItem).m_szFakeEditBoxValue = GetLocKeyNameByActionKey(UWindowListBoxItem(ListItem).m_szActionKey, true);
		}
	}
}

//===============================================================================
// GetLocKeyNameByActionKey: Get the localization name of the key to display
//===============================================================================
function string GetLocKeyNameByActionKey( string _szActionKey, optional BOOL _bPlanningInput)
{
	local string szTemp;
	local BYTE Key;

	Key = GetPlayerOwner().GetKey(_szActionKey, _bPlanningInput);
	szTemp = GetPlayerOwner().GetEnumName( Key, _bPlanningInput);
	szTemp = GetPlayerOwner().Player.Console.ConvertKeyToLocalisation( Key, szTemp);

	return szTemp;
}

function CreateKeyPopUp()
{
    local R6WindowTextLabelExt pR6TextLabelExt;
	local FLOAT fPopUpWidth;

	fPopUpWidth = 380;

	// Create Map Key PopUp
	m_pPopUpKeyBG = R6WindowPopUpBox( OwnerWindow.CreateWindow( class'R6WindowPopUpBox', 0, 0, OwnerWindow.WinWidth, OwnerWindow.WinHeight, self));
	m_pPopUpKeyBG.CreatePopUpFrameWindow( Localize("Options", "Opt_ControlsMapKey", "R6Menu"), 30, 130, 150, fPopUpWidth, 70);
	m_pPopUpKeyBG.CreateClientWindow( class'R6WindowTextLabelExt');
	m_pPopUpKeyBG.m_bForceButtonLine = true;
	pR6TextLabelExt = R6WindowTextLabelExt(m_pPopUpKeyBG.m_ClientArea);
	pR6TextLabelExt.SetNoBorder();
	// text part
	pR6TextLabelExt.m_Font = Root.Fonts[F_SmallTitle]; 
	pR6TextLabelExt.m_vTextColor = Root.Colors.White;
	pR6TextLabelExt.AddTextLabel( "", 0, 3, fPopUpWidth, TA_Center, false);
	pR6TextLabelExt.AddTextLabel( "", 0, 15, fPopUpWidth, TA_Center, false);
	pR6TextLabelExt.AddTextLabel( Localize("Options", "Key_Map", "R6Menu"), 0, 27, fPopUpWidth, TA_Center, false);

	m_pPopUpKeyBG.Close();

    // Create Reassign PopUp
    m_pKeyMenuReAssignPopUp = R6WindowPopUpBox( OwnerWindow.CreateWindow( class'R6WindowPopUpBox', 0, 0, OwnerWindow.WinWidth, OwnerWindow.WinHeight, self));
    m_pKeyMenuReAssignPopUp.CreatePopUpFrameWindow( Localize("Options", "Opt_ControlsReMapKey", "R6Menu"), 30, 140, 150, fPopUpWidth, 70);
    m_pKeyMenuReAssignPopUp.CreateClientWindow( class'R6WindowTextLabelExt');
	m_pKeyMenuReAssignPopUp.m_bForceButtonLine = true;
    pR6TextLabelExt = R6WindowTextLabelExt(m_pKeyMenuReAssignPopUp.m_ClientArea);
	pR6TextLabelExt.SetNoBorder();
	// text part
	pR6TextLabelExt.m_Font = Root.Fonts[F_SmallTitle]; 
	pR6TextLabelExt.m_vTextColor = Root.Colors.White;
	pR6TextLabelExt.AddTextLabel( "", 0, 3, fPopUpWidth, TA_Center, false);
	pR6TextLabelExt.AddTextLabel( Localize("Options", "Key_Press", "R6Menu"), 0, 27, fPopUpWidth, TA_Center, false);

	m_pKeyMenuReAssignPopUp.Close();
}

//===============================================================================
// ManagePopUpKey: manage controls
//===============================================================================
function ManagePopUpKey( UWindowDialogControl C)
{
    local R6WindowTextLabelExt pR6TextLabelExt;

	m_pCurItem = R6WindowListControls(C).GetSelectedItem();

	// if it's a fake edit box ( the others kind of item are title and line -- no interaction but notify it sent)
	if ( !m_pCurItem.m_bNotAffectByNotify)
	{
		pR6TextLabelExt = R6WindowTextLabelExt(m_pPopUpKeyBG.m_ClientArea);

		if (GetCurKeyName() == "") // the key is mapped to nothing?
		{
			pR6TextLabelExt.ChangeTextLabel( m_pCurItem.HelpText $ " " $ Localize("Options", "Key_Advice", "R6Menu") $ " " $ Localize("Options", "Key_Nothing", "R6Menu"), 0); 
			pR6TextLabelExt.ChangeTextLabel( " ", 1);
		}
		else
		{
			pR6TextLabelExt.ChangeTextLabel( m_pCurItem.HelpText $ " " $ Localize("Options", "Key_Advice", "R6Menu"), 0);
			pR6TextLabelExt.ChangeTextLabel( GetCurKeyName(), 1);
		}

		m_pPopUpKeyBG.ShowWindow();

		m_pOptControls = R6MenuOptionsControls( OwnerWindow.CreateWindow( class'R6MenuOptionsControls', 0, 0, OwnerWindow.WinWidth, OwnerWindow.WinHeight, self, true));
		m_pOptControls.Register(self);
//		m_pOptControls = R6MenuOptionsControls( CreateControl( class'R6MenuOptionsControls', 0, 0, WinWidth, WinHeight, self, true));
	}
}

function CloseAllKeyPopUp( optional BOOL _bCloseKeyControlTo)
{
	if (m_pPopUpKeyBG.bWindowVisible)
	{
		m_pPopUpKeyBG.Close();
	}
	else if (m_pKeyMenuReAssignPopUp.bWindowVisible)
	{
		m_pKeyMenuReAssignPopUp.Close();
	}

	if (_bCloseKeyControlTo)
	{
		m_pOptControls.HideWindow();
	}
}





function UWindowListBoxItem GetCurrentKeyItem()
{
	return m_pCurItem;
}

function string GetCurActionKey()
{
	return GetCurrentKeyItem().m_szActionKey;
}

function string GetCurKeyName()
{
	return GetCurrentKeyItem().m_szFakeEditBoxValue;
}

function INT GetCurKeyInputClass()
{
	return GetCurrentKeyItem().m_iItemID;
}

function RefreshKeyItem( string _szNewKeyValue)
{
	local UWindowListBoxItem pItem;
	pItem = m_pListControls.GetSelectedItem();

	if ( pItem != None)
	{
		pItem.m_szFakeEditBoxValue = _szNewKeyValue;
	}
}

//==============================================================================
// KeyPressed -  Set the new key pressed  
//==============================================================================
function KeyPressed( int Key)
{
	local R6WindowTextLabelExt pR6TextLabelExt;
	local string szTemp, szKeyName;
	local BOOL bUpdate, bPlanningInput;

	if (GetCurKeyInputClass() == 1)
		bPlanningInput = true;

	// we already have a key to map ?
	if (m_iKeyToAssign != -1)
	{
		bUpdate = true;
	}
	else
	{
		// it`s a valid key to assign?
		if ( !IsKeyValid( Key))
		{
			CloseAllKeyPopUp(true); // close current pop-up
			// simple pop-up to advice the player
			R6MenuOptionsWidget(OwnerWindow).SimplePopUp(Localize("Options","Key_Invalid_Title","R6Menu"), 
														 Localize("Options","Key_Invalid","R6Menu"),
														 EPopUpID_None, MessageBoxButtons.MB_OK);
			return;
		}

		// check if the key is already assign to another things
		m_szOldActionKey = GetPlayerOwner().GetActionKey( Key, bPlanningInput);

		// check if the old action key is valid, if not the old action key not exist for the game
		szTemp = Localize("Keys","K_"$m_szOldActionKey,"R6Menu", true);

		m_iKeyToAssign = Key;

		if ( (m_szOldActionKey != "") && (szTemp != ""))
		{
			// already assign to szOldActionKey
			szKeyName = GetPlayerOwner().Player.Console.ConvertKeyToLocalisation( m_iKeyToAssign, GetPlayerOwner().GetEnumName(m_iKeyToAssign, bPlanningInput));
			
			pR6TextLabelExt = R6WindowTextLabelExt(m_pKeyMenuReAssignPopUp.m_ClientArea);
			pR6TextLabelExt.ChangeTextLabel( szKeyName $ " " $ Localize("Options", "Key_Assign", "R6Menu") $ " " $Localize("Keys","K_"$m_szOldActionKey,"R6Menu"), 0);

			// new pop-up to confirm the choice of re-assign
			m_pKeyMenuReAssignPopUp.ShowWindow(); 
			m_pOptControls.ShowWindow(); // to be sure that the button is over the pop-up
		}
		else
		{
			bUpdate = true; 
		}
	}

	if (bUpdate) // update the key, action, etc modify user.ini too
	{
		//we have to find the input class
		szTemp = "INPUT";	
		if (bPlanningInput)
		{
			szTemp = "INPUTPLANNING";
		}

//		log("m_szOldActionKey "$m_szOldActionKey);

//		if (m_szOldActionKey != "") // we have to clear the last assignement of the key
//		{
//			GetPlayerOwner().SetKey( szTemp@"None"@m_szOldActionKey);
//		}

		// set the key and refresh the list
		szKeyName = GetPlayerOwner().GetEnumName(m_iKeyToAssign, bPlanningInput);
//		log("szKeyName "$szKeyName);
		GetPlayerOwner().SetKey( szTemp@szKeyName@GetCurActionKey());

		RefreshKeyList();

		m_szOldActionKey = "";
		m_iKeyToAssign = -1;
	}
}

//=======================================================================================
// IsKeyValid: Check is the key is valid -- ex windows key, pop-up key are not valid for mapping controls
//=======================================================================================
function BOOL IsKeyValid( INT _Key)
{
	local BOOL bValidKey;

	bValidKey = true;

	switch( _Key)
	{
		case Root.Console.EInputKey.IK_Unknown5B: // LEFT WINDOW KEY
		case Root.Console.EInputKey.IK_Unknown5C: // RIGHT WINDOW KEY
		case Root.Console.EInputKey.IK_Unknown5D: // POP-UP WINDOW KEY
			bValidKey = false;
			break;
		case Root.Console.EInputKey.IK_LeftMouse:
			// check if you're mapping the console
			if (GetCurKeyInputClass() != 1) // we're are not in planning
			{
				if (GetCurActionKey() == "Console") // it's the console?
				{
					bValidKey = false;
				}
			}
			break;
		// IK_MouseWheelDown and IK_MouseWheelUp have some problem with Aliases buttons. A press and a release
		// are send in the same frame and the state of the button never change (always erase by the release)
		case Root.Console.EInputKey.IK_MouseWheelDown:
		case Root.Console.EInputKey.IK_MouseWheelUp:
			if (GetCurKeyInputClass() == 1)
			{
				switch(GetCurActionKey())
				{
					case "MoveUp":
					case "MoveDown":
					case "MoveLeft":
					case "MoveRight":
					case "ZoomIn":
					case "ZoomOut":
					case "LevelUp":
					case "LevelDown":
					case "RotateClockWise":
					case "RotateCounterClockWise":
					case "AngleUp":
					case "AngleDown":
						bValidKey = false;
						break;
				}
			}
			else
			{
				switch(GetCurActionKey())
				{
					case "PrimaryFire":
					case "SecondaryFire":
					case "Reload":
					case "Run":
					case "SpeedUpDoor":
					case "FluidPosture":
					case "PeekLeft":
					case "PeekRight":
					case "MoveForward":
					case "RunForward":
					case "MoveBackward":
					case "StrafeLeft":
					case "StrafeRight":
					case "TurningX":
					case "TurningY":
						bValidKey = false;
						break;
				}
			}
			break;
		default:
			bValidKey = true;
			break;
	}

	return bValidKey;
}

//*******************************************************************************************
// OPTION MODS
//*******************************************************************************************
function InitOptionMODS()
{
	local FLOAT fXOffset, fYOffset;

	m_ePageOptID = ePO_MODS;

	m_pInfo = new(None) class'UWindowInfo';
	m_pInfo.LoadConfig();

    m_pListOfMODS = R6WindowListMODS(CreateWindow(class'R6WindowListMODS', 0, 0, WinWidth, WinHeight - 14));
    m_pListOfMODS.ListClass=class'R6WindowListBoxItem';
    m_pListOfMODS.m_font = Root.Fonts[F_VerySmallTitle];    
	m_pListOfMODS.Register(  self );
	m_pListOfMODS.m_DoubleClickClient = OwnerWindow;
    m_pListOfMODS.m_bSkipDrawBorders = true;
    m_pListOfMODS.m_fItemHeight = 14;

	InitActivateButton();
	SetMenuMODS();

	m_bInitComplete = true;
}

//=============================================================================================
// SetMenuMODS: Set the MODS values according the values store in the MOD manager
//=============================================================================================
function SetMenuMODS()
{
	local R6WindowListBoxItem   NewItem;
	local INT                   i;
	local R6ModMgr				pModManager;
	local R6Mod                 pTempMod;
	local String				szInstallStatus;

	pModManager = class'Actor'.static.GetModMgr();

    m_pListOfMODS.Items.Clear();
    
	//=========================================================================
	// TODO GetMODS from the MOD manager
	// TEMPLATE
	//	for (i=0; i < NOMBRE DE MODS DISPONIBLE; i++)
	//	{
	//		// create item
	//		NewItem = R6WindowListBoxItem(m_pListOfMODS.Items.Append(m_pListOfMODS.ListClass));
	//
	//		// SetItemParameters( INT _Index, string _szText, Font _TextFont, FLOAT _fX, FLOAT _fY, FLOAT _fW, FLOAT _fH, INT _iLineNumber, align)
	//		NewItem.SetItemParameters( 0, "TEXT1", Root.Fonts[F_SmallTitle], 5, 2, WinWidth, 15, 0);
	//		NewItem.SetItemParameters( 1, "TEXT2", Root.Fonts[F_SmallTitle], WinWidth*0.5, 2, WinWidth*0.5, 15, 0);
	//		NewItem.SetItemParameters( 2, "TEXT3", Root.Fonts[F_SmallTitle], 5, 0, WinWidth, 15, 1);
	//		//etc...
	//
	//		NewItem.HelpText = ""; // set background extension -- ex. for MP1, "MP1", comme ça, quand on clique sur ce mods, 
	//							// le background associe va etre dans "background//options//MP1"	
	//
	//		// by default
	//		m_pListOfMODS.SetItemState( NewItem, m_pListOfMODS.eItemState.eIS_Normal);
	//
	//		// if this item is the current selection...
	//		m_pListOfMODS.SetItemState( NewItem, m_pListOfMODS.eItemState.eIS_Selected);		
	//
	//		// if this item is disable
	//		m_pListOfMODS.SetItemState( NewItem, m_pListOfMODS.eItemState.eIS_Disable);
	//
	//		// if this item is the current mod
	//		m_pListOfMODS.SetItemState( NewItem, m_pListOfMODS.eItemState.eIS_CurrentChoice); // put to true if it is the selection too
	//	}
	// END OF TODO
	//=========================================================================

	// fill all the list with Ravenshield info
	for (i = 0; i < m_pInfo.m_AModsInfo.Length; i++)
	{
		NewItem = R6WindowListBoxItem(m_pListOfMODS.Items.Append(m_pListOfMODS.ListClass));
		NewItem.SetItemParameters( 0, Localize( m_pInfo.m_AModsInfo[i], "ModName", "R6Mod", true ), Root.Fonts[F_SmallTitle], 5, 2, WinWidth, 15, 0, TA_LEFT);

		// not installed
		szInstallStatus = Localize("MISC", "NotInstalled", "R6Mod");
		m_pListOfMODS.SetItemState( NewItem, m_pListOfMODS.eItemState.eIS_Disable, true);

		// Compute Size of the Installed status
		NewItem.SetItemParameters( 1, szInstallStatus , Root.Fonts[F_SmallTitle], WinWidth - 5, 2, WinWidth, 15, 0, TA_RIGHT);
		NewItem.SetItemParameters( 2, Localize( m_pInfo.m_AModsInfo[i], "ModInfo", "R6Mod", true ), Root.Fonts[F_SmallTitle], 5, 0, WinWidth, 15, 1, TA_LEFT);
		NewItem.HelpText = m_pInfo.m_AModsInfo[i];
	}

//	pCurrentMod = pModManager.m_pCurrentMod;

	for (i = 0; i < pModManager.GetNbMods(); i++)
	{
		pTempMod = pModManager.m_aMods[i];

		// find in the list if this mod is already add
		NewItem = R6WindowListBoxItem(m_pListOfMODS.FindItemWithName( pTempMod.m_szKeyword));

		if (NewItem == None)
		{
		    NewItem = R6WindowListBoxItem(m_pListOfMODS.Items.Append(m_pListOfMODS.ListClass));
		}

		NewItem.SetItemParameters( 0, pTempMod.m_szName, Root.Fonts[F_SmallTitle], 5, 2, WinWidth, 15, 0, TA_LEFT);
		if (pTempMod.m_bInstalled == true)
		{
			szInstallStatus = Localize("MISC", "Installed", "R6Mod");

			if (pTempMod == pModManager.m_pCurrentMod) // Current Active Mod
			{
				m_pListOfMODS.SetItemState( NewItem, m_pListOfMODS.eItemState.eIS_CurrentChoice, true);
			}
			else
			{
				m_pListOfMODS.SetItemState( NewItem, m_pListOfMODS.eItemState.eIS_Normal, true);
			}
		}
		else
		{
			szInstallStatus = Localize("MISC", "NotInstalled", "R6Mod");
			m_pListOfMODS.SetItemState( NewItem, m_pListOfMODS.eItemState.eIS_Disable, true);
		}

		// Compute Size of the Installed status
		NewItem.SetItemParameters( 1, szInstallStatus , Root.Fonts[F_SmallTitle], WinWidth - 5, 2, WinWidth, 15, 0, TA_RIGHT);
		NewItem.SetItemParameters( 2, pTempMod.m_szModInfo, Root.Fonts[F_SmallTitle], 5, 0, WinWidth, 15, 1, TA_LEFT);
		NewItem.HelpText = pTempMod.m_szKeyword;
	}
}



//*******************************************************************************************
// OPTION PATCH SYSTEM
//*******************************************************************************************
function InitOptionPatchService()
{
    local FLOAT fXOffset, fYOffset, fYStep, fWidth, fHeight;

	m_ePageOptID = ePO_PatchService;

    fXOffset = 5;
    fYOffset = 5;
    fWidth = WinWidth - fXOffset - 40; // 40 distance to the end of the window
    fHeight = 15;
    fYStep = 27;
	
    // ENABLE AUTO PATCH DOWNLOAD
    m_pOptionAutoPatchDownload = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pOptionAutoPatchDownload.SetButtonBox( false);
    m_pOptionAutoPatchDownload.CreateTextAndBox( Localize("Options","Opt_PatchServiceAutoDownload","R6Menu"), 
                                         Localize("Tip","Opt_PatchServiceAutoDownload","R6Menu"), 0, 
                                         2);

    fYOffset += fYStep;
	m_pStartDownloadButton = R6WindowButton(CreateControl(class'R6WindowButton', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pStartDownloadButton.Text			= Localize("Options","ButtonStartPatchDownload","R6Menu"); 
	m_pStartDownloadButton.ToolTipString  = Localize("Tip","ButtonStartPatchDownload","R6Menu");
	m_pStartDownloadButton.Align			= TA_Left;

    fYOffset += fYStep;
    m_pPatchStatus = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pPatchStatus.Text = Localize("Options","PatchStatus_Unknown", "R6Menu");
    m_pPatchStatus.Align = TA_LEFT;
    m_pPatchStatus.m_Font = Root.Fonts[F_SmallTitle];
    //m_pPatchStatus.TextColor = LabelTextColor;
    //m_pPatchStatus.m_BGTexture         = None;
    m_pPatchStatus.m_bDrawBorders      =False;

	InitResetButton();
	SetMenuPatchServiceValues();

	m_bInitComplete = true;
}

//=============================================================================================
// SetGameValue: Set the R6GameOptions values
//=============================================================================================
function SetPatchServiceValues()
{
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

	pGameOptions.AutoPatchDownload = m_pOptionAutoPatchDownload.m_bSelected;
}

//=============================================================================================
// SetMenuGameValue: Set the menu game values according the value store in uw.ini by R6GameOptions
//=============================================================================================
function SetMenuPatchServiceValues()
{
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();
	
	m_pOptionAutoPatchDownload.SetButtonBox( pGameOptions.AutoPatchDownload );
}

function GetDownloadMetric(FLOAT totalBytes, out string metric, out FLOAT divider)
{
	if(totalBytes > 10 * 1024*1024){
		metric = Localize("Options","PatchStatus_MegaBytes", "R6Menu");
		divider = 1024*1024;
	}else if(totalBytes > 10 * 1024){
		metric = Localize("Options","PatchStatus_KiloBytes", "R6Menu");
		divider = 1024;
	}else{
		metric = Localize("Options","PatchStatus_Bytes", "R6Menu");
		divider = 1;
	}
}

function GetDownloadPercentageStringValues(FLOAT totalBytes, FLOAT recvdBytes, out string bytesProgress, out string percentProgress)
{
	local string strTotal;
	local string strRecvd;
	local string metric;
	local FLOAT  divider;

	GetDownloadMetric(totalBytes, metric, divider);
	
	strTotal = string(totalBytes / divider);
	strTotal = Left(strTotal, InStr(strTotal, "."));

	strRecvd = string(recvdBytes / divider);
	strRecvd = Left(strRecvd, InStr(strRecvd, "."));
	
 	percentProgress = string(100.0 * recvdBytes / totalBytes);
    percentProgress = Left(percentProgress, InStr(percentProgress, ".")) $ "%";

	bytesProgress = strRecvd $ "/" $ strTotal $ metric;
}

function GetDownloadString(FLOAT totalBytes, FLOAT recvdBytes, out string str)
{
	local string bytesProgress;
	local string percentProgress;

	if(totalBytes > 0 && recvdBytes > 0){
		GetDownloadPercentageStringValues(totalBytes, recvdBytes, bytesProgress, percentProgress);

		str = bytesProgress $ " (" $ percentProgress $ ")";
	}
}

function UpdatePatchStatus()
{
	local eviLPatchService.PatchState patchState;
	local eviLPatchService.ExitCause  exitCause;
	local FLOAT totalBytes;
	local FLOAT recvdBytes;
	local string progress;
	
	patchState = class'eviLPatchService'.static.GetState();

	switch(PatchState){
	case PS_Initializing:
		m_pPatchStatus.Text = Localize("Options","PatchStatus_Initializing", "R6Menu");
		break;
	case PS_DownloadVersionFile:
		class'eviLPatchService'.static.GetDownloadProgress(totalBytes, recvdBytes);
		GetDownloadString(totalBytes, recvdBytes, progress);
		m_pPatchStatus.Text = Localize("Options","PatchStatus_DownloadVersionFile", "R6Menu") $ progress;
		break;
	case PS_SelectPatch:
		m_pPatchStatus.Text = Localize("Options","PatchStatus_SelectPatch", "R6Menu");
		break;
	case PS_DownloadPatch:
		class'eviLPatchService'.static.GetDownloadProgress(totalBytes, recvdBytes);
		GetDownloadString(totalBytes, recvdBytes, progress);
		m_pPatchStatus.Text = Localize("Options","PatchStatus_DownloadPatch", "R6Menu") $ progress;
		break;
	case PS_Terminate:
		exitCause = class'eviLPatchService'.static.GetExitCause();
		switch(exitCause)
		{
		case EC_PatchStarted:
			m_pPatchStatus.Text = Localize("Options","PatchStatus_PatchStarted", "R6Menu");
			break;
		case EC_NoPatchNeeded:
			m_pPatchStatus.Text = Localize("Options","PatchStatus_NoPatchNeeded", "R6Menu");
			break;
		case EC_FatalDownloadError:
			m_pPatchStatus.Text = Localize("Options","PatchStatus_FatalDownloadError", "R6Menu");
			break;
		case EC_PartialDownloadError:
			m_pPatchStatus.Text = Localize("Options","PatchStatus_PartialDownloadError", "R6Menu");
			break;
		case EC_UserAborted:
			m_pPatchStatus.Text = Localize("Options","PatchStatus_UserAborted", "R6Menu");
			break;
		case EC_Unknown:
			m_pPatchStatus.Text = Localize("Options","PatchStatus_ExitUnknown", "R6Menu");
			break;
		case EC_UserQuit:
			m_pPatchStatus.Text = Localize("Options","PatchStatus_UserQuit", "R6Menu");
			break;
		default:
			m_pPatchStatus.Text = Localize("Options","PatchStatus_ExitError", "R6Menu");
			break;
		};
		break;
	case PS_RunPatch:
		m_pPatchStatus.Text = Localize("Options","PatchStatus_RunPatch", "R6Menu");
		break;
	case PS_Unknown:
	default:
		m_pPatchStatus.Text = Localize("Options","PatchStatus_Unknown", "R6Menu");
		break;
	};
}



//=============================================================================================
// RestoreDefaultValue: Restore the default value of the current window
//=============================================================================================
function RestoreDefaultValue( BOOL _bInGame)
{
	local R6GameOptions pGameOptions;
    local R6MenuOptionsWidget OptionsWidget;

	pGameOptions = class'Actor'.static.GetGameOptions();

    OptionsWidget = R6MenuOptionsWidget(OwnerWindow);

	// depending the option window visible
    // OPTION GAME
	if ( OptionsWidget.m_pOptionsGame.bWindowVisible)
	{
		// restore
		pGameOptions.ResetGameToDefault();
		// update options visually only, not save in .ini
		SetMenuGameValues();
	}
    // OPTION SOUND
	else if ( OptionsWidget.m_pOptionsSound.bWindowVisible)
	{
		// restore
		pGameOptions.ResetSoundToDefault( _bInGame);
		// update options visually only, not save in .ini
		SetMenuSoundValues();
	}
	// OPTION GRAPHIC
	else if ( OptionsWidget.m_pOptionsGraphic.bWindowVisible)
	{
		// restore
		pGameOptions.ResetGraphicsToDefault( _bInGame);
		// update options visually only, not save in .ini
		SetMenuGraphicValues();
	}
	// OPTION HUD FILTERS
	else if ( OptionsWidget.m_pOptionsHud.bWindowVisible)
	{
		// restore
		pGameOptions.ResetHudToDefault();
		// update options visually only, not save in .ini
		SetMenuHudValues();
	}
#ifndefSPDEMO
    // OPTION MULTIPLAYER
	else if ( OptionsWidget.m_pOptionsMulti.bWindowVisible)
	{
		// restore
		pGameOptions.ResetMultiToDefault();
		// update options visually only, not save in .ini
		SetMenuMultiValues();
	}
#endif
    // OPTION CONTROLS
	else if ( OptionsWidget.m_pOptionsControls.bWindowVisible)
	{
		GetPlayerOwner().ResetKeyboard();
		RefreshKeyList();
	}
	// OPTION PATCH SERVICE
	else if ( OptionsWidget.m_pOptionsPatchService.bWindowVisible)
	{
		// restore
		pGameOptions.ResetPatchServiceToDefault();
		// update options visually only, not save in .ini
		SetMenuPatchServiceValues();
	}
}



/////////////////////////////////////////////////////////////////
// notify the parent window by using the appropriate parent function
/////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	local R6MenuOptionsWidget OptionsWidget;
	local BOOL bUpdateGameOptions;
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

	OptionsWidget = R6MenuOptionsWidget(OwnerWindow);

//    log("Notify from class: "$C);
//    log("Notify msg: "$E);

	if (E == DE_Click)
	{
        // Change Current Selected Button
        if ( C.IsA('R6WindowButtonBox'))
        {
            if (R6WindowButtonBox(C).GetSelectStatus())
            {
                R6WindowButtonBox(C).m_bSelected = !R6WindowButtonBox(C).m_bSelected; // change the boolean state
				bUpdateGameOptions = true;
            }

			if ( (OptionsWidget.m_pOptionsSound != None) && (OptionsWidget.m_pOptionsSound.bWindowVisible))
				{
					ManageNotifyForSound( C, E);
				}
//#ifdefR6PUNKBUSTER
			else if ((OptionsWidget.m_pOptionsMulti != None) && ( OptionsWidget.m_pOptionsMulti.bWindowVisible))
			{
				ManageNotifyForNetwork( C, E);
			}
//#endif
        }
		else if ( C.IsA('R6WindowButtonExt'))
		{
			if ( R6WindowButtonExt(C).GetSelectStatus())
			{
				R6WindowButtonExt(C).ChangeCheckBoxStatus();
				bUpdateGameOptions = true;
			}
		}
		else if ( C.IsA('R6WindowButton'))
		{
			if (C == m_pGeneralButUse)
			{
				if (m_pGeneralButUse.m_iButtonID == eGeneralButUse.eGBU_ResetToDefault){
	                OptionsWidget.SimplePopUp(Localize("Options","ResetToDefault","R6Menu"), Localize("Options","ResetToDefaultConfirm","R6Menu"),EPopUpID_OptionsResetDefault);									
				}else if (m_pGeneralButUse.m_iButtonID == eGeneralButUse.eGBU_Activate){
					m_pListOfMODS.ActivateMOD();				
				}
			}
			else if( C == m_pStartDownloadButton )
			{
				class'eviLPatchService'.static.StartPatch();	
			}
			else // controls if ( C == m_pOptControls)
			{
				m_iKeyToAssign = -1;
				CloseAllKeyPopUp( true);
			}
		}
		else if ( C.IsA('R6WindowListControls'))
		{
			ManagePopUpKey(C);
		}
		else if ( C.IsA('R6MenuOptionsControls'))
		{
			CloseAllKeyPopUp( true);

			if ( m_pOptControls.m_iLastKeyPressed == GetPlayerOwner().Player.Console.EInputKey.IK_Escape)
			{
				m_iKeyToAssign = -1;
			}
			else
			{
				KeyPressed( m_pOptControls.m_iLastKeyPressed);
			}
		}
    }
	else if ( C.IsA('UWindowHScrollBar'))
	{
		if (m_ePageOptID == ePO_Sound)
		{
			switch( UWindowHScrollBar(C).m_iScrollBarID )
			{
				case GetPlayerOwner().ESoundSlot.SLOT_Ambient:
					if (E == DE_MouseLeave)
					{
						if (m_iRefAmbientVolume != m_pAmbientVolume.GetScrollBarValue())
						{
							m_iRefAmbientVolume = m_pAmbientVolume.GetScrollBarValue();
							bUpdateGameOptions = true;
						}
					}
					else if ( (E == DE_Change) && (m_bInitComplete) )
					{
						GetPlayerOwner().ChangeVolumeTypeLinear(GetPlayerOwner().ESoundSlot.SLOT_Ambient, m_pAmbientVolume.GetScrollBarValue());
					}
					break;
				case GetPlayerOwner().ESoundSlot.SLOT_Music:
					if (E == DE_MouseLeave)
					{
						if (m_iRefMusicVolume != m_pMusicVolume.GetScrollBarValue())
						{
							m_iRefMusicVolume = m_pMusicVolume.GetScrollBarValue();
							bUpdateGameOptions = true;
						}
					}
					else if ( (E == DE_Change) && (m_bInitComplete) )
					{
						GetPlayerOwner().ChangeVolumeTypeLinear(GetPlayerOwner().ESoundSlot.SLOT_Music, m_pMusicVolume.GetScrollBarValue());
					}
					break;
				case GetPlayerOwner().ESoundSlot.SLOT_Talk:
					if (E == DE_MouseLeave)
					{
						if (m_iRefVoicesVolume != m_pVoicesVolume.GetScrollBarValue())
						{
							m_iRefVoicesVolume = m_pVoicesVolume.GetScrollBarValue();
							bUpdateGameOptions = true;
						}
					}
					else if ( (E == DE_Change) && (m_bInitComplete) )
					{
						GetPlayerOwner().ChangeVolumeTypeLinear(GetPlayerOwner().ESoundSlot.SLOT_Talk, m_pVoicesVolume.GetScrollBarValue());
					}
					break;
				default:
					bUpdateGameOptions = false;
					break;
			}
		}
		else if (m_ePageOptID == ePO_Game)
		{
			if (E == DE_MouseLeave)
			{
				if (m_iRefMouseSens != m_pOptionMouseSens.GetScrollBarValue())
				{
					m_iRefMouseSens = m_pOptionMouseSens.GetScrollBarValue();
					bUpdateGameOptions = true;
				}
			}
			else if ( (E == DE_Change) && (m_bInitComplete) )
			{
	            pGameOptions.MouseSensitivity  = m_pOptionMouseSens.GetScrollBarValue();
			}
		}
	}
	else if (C.IsA('R6WindowComboControl'))
	{
		if (E == DE_Change)
		{
			if ((m_bInitComplete) && (R6WindowComboControl(C).m_bSelectedByUser))
			{
				bUpdateGameOptions = true;
			}
		}
	}
	else if (E == DE_DoubleClick)
	{
		if (C == m_pListOfMODS)
		{
			// simulate activate button
			m_pListOfMODS.ActivateMOD();
		}
	}

	if (bUpdateGameOptions) // update gameoptions
	{
		switch( m_ePageOptID)
		{
			case ePO_Game:
				SetGameValues();
				break;
			case ePO_Sound:
				SetSoundValues();
				break;
			case ePO_Graphics:
				SetGraphicValues( true);
				break;
			case ePO_Hud:
				SetHudValues();
				break;
			case ePO_MP:
				SetMultiValues();
				break;
			case ePO_PatchService:
				SetPatchServiceValues();
				break;
			case ePO_Controls:
				break;
			default:
				bUpdateGameOptions = false;
				break;
		}

		if (bUpdateGameOptions)
			pGameOptions.SaveConfig();
	}
}


function ManageNotifyForSound(UWindowDialogControl C, byte E)
{
	if (C == m_pSndHardware)
	{
		if (!m_bEAXNotSupported)
		{
			// if snd hardware is activate, remove disable to eax
			if (R6WindowButtonBox(C).m_bSelected)
			{
				m_pEAX.bDisabled   = false;
			}
			else // if you desactivate the SndHardware, EAX is desactivate too
			{
				m_pEAX.bDisabled   = true;
				m_pEAX.m_bSelected = false;
			}

			m_EaxLogo.m_bUseColor = !m_pEAX.m_bSelected;
		}
	}
	else if(C == m_pEAX)
	{
		m_EaxLogo.m_bUseColor = !m_pEAX.m_bSelected;
	}
}

//#ifdefR6PUNKBUSTER
function ManageNotifyForNetwork(UWindowDialogControl C, byte E)
{
	if (C == m_pPunkBusterOpt)
	{
		// are you able to activate PunkBuster on client?
		if (R6WindowButtonBox(C).m_bSelected)		
		{
			class'Actor'.static.SetPBStatus( false, false);

			if (!class'Actor'.static.IsPBClientEnabled())
			{
				R6WindowButtonBox(C).m_bSelected = false;
			}
		}
		else
		{
			class'Actor'.static.SetPBStatus( true, false);
		}
	}
}
//#endif

function R6WindowComboControl SetComboControlButton( Region _RDefaultW, string _szTitle, string _szTip)
{
	local R6WindowComboControl _pR6WindowComboControl;

	_pR6WindowComboControl = R6WindowComboControl(CreateControl(class'R6WindowComboControl', _RDefaultW.X, _RDefaultW.Y, _RDefaultW.W, LookAndFeel.Size_ComboHeight, self));
	_pR6WindowComboControl.AdjustTextW( _szTitle, 0, 0, _RDefaultW.W * 0.5 , LookAndFeel.Size_ComboHeight);
	_pR6WindowComboControl.AdjustEditBoxW( 0, C_ICOMBOCONTROL_WIDTH, LookAndFeel.Size_ComboHeight);
	_pR6WindowComboControl.SetEditBoxTip( _szTip);
//	_pR6WindowComboControl.SetValue( "", "");

	return 	_pR6WindowComboControl;
}

defaultproperties
{
     m_iKeyToAssign=-1
     m_pAutoAimTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_EaxTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     SimpleBorderRegion=(X=64,Y=56,W=1,H=1)
     m_pAutoAimTextReg(0)=(Y=104,W=111,H=73)
     m_pAutoAimTextReg(1)=(Y=177,W=111,H=73)
     m_pAutoAimTextReg(2)=(Y=250,W=111,H=73)
     m_pAutoAimTextReg(3)=(Y=323,W=111,H=73)
     m_EaxTextureReg=(Y=396,W=188,H=84)
     m_RArmpatchBitmapPos=(X=55,Y=38,W=64,H=64)
     m_RArmpatchListPos=(X=230,W=156,H=150)
}
