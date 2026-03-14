//=============================================================================
// R6InteractionRoseDesVents - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6InteractionRoseDesVents.uc : Basic interaction for the rose des vents
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/21 * Created by S�bastien Lussier
//=============================================================================
class R6InteractionRoseDesVents extends Interaction
 abstract;

const C_RoseDesVentSize = 150;

var int m_iCurrentMnuChoice;
var int m_iCurrentSubMnuChoice;
var const int C_iMouseDelta;
var bool m_bActionKeyDown;
var bool m_bIgnoreNextActionKeyRelease;
var bool bShowLog;
var float m_iTextureWidth;
var float m_iTextureHeight;
var R6PlayerController m_Player;
var Texture m_TexMNU;
var Texture m_TexMNUItemNormalTop;
var Texture m_TexMNUItemNormalLeft;
var Texture m_TexMNUItemNormalSubTop;
var Texture m_TexMNUItemNormalSubLeft;
var Texture m_TexMNUItemSelectedSubTop;
var Texture m_TexMNUItemSelectedSubLeft;
var Texture m_TexMNUItemSelectedTop;
var Texture m_TexMNUItemSelectedLeft;
var Font m_Font;
var Sound m_RoseOpenSnd;
var Sound m_RoseSelectSnd;
var Color m_color;
var string m_ActionKey;

//===========================================================================//
// Initialized()                                                             //
//===========================================================================//
event Initialized()
{
	super.Initialized();
	m_Player = R6PlayerController(ViewportOwner.Actor);
	return;
}

//===========================================================================//
// Override these
function GotoSubMenu()
{
	return;
}

function bool IsValidMenuChoice(int iChoice)
{
	return;
}

function SetMenuChoice(int iChoice)
{
	return;
}

function NoItemSelected()
{
	return;
}

function ItemRightClicked(int iItem)
{
	return;
}

function ItemClicked(int iItem)
{
	return;
}

function ActionKeyPressed()
{
	return;
}

function ActionKeyReleased()
{
	return;
}

function bool ItemHasSubMenu(int iItem)
{
	return;
}

//===========================================================================//
// MenuItemEnabled()                                                         //
//===========================================================================//
function bool MenuItemEnabled(int iItem)
{
	return true;
	return;
}

//===========================================================================//
// CurrentItemHasSubMenu()                                                   //
//===========================================================================//
function bool CurrentItemHasSubMenu()
{
	return false;
	return;
}

//===========================================================================//
// GetCurrentMenuChoice()                                                    //
//===========================================================================//
function int GetCurrentMenuChoice()
{
	return m_iCurrentMnuChoice;
	return;
}

//===========================================================================//
// GetCurrentSubMenuChoice()                                                 //
//===========================================================================//
function int GetCurrentSubMenuChoice()
{
	return m_iCurrentSubMnuChoice;
	return;
}

//===========================================================================//
// DisplayMenu()                                                             //
//===========================================================================//
function DisplayMenu(bool bDisplay, optional bool bOpen)
{
	bVisible = bDisplay;
	m_iCurrentMnuChoice = -1;
	m_iCurrentSubMnuChoice = -1;
	m_Player.m_bAMenuIsDisplayed = bDisplay;
	// End:0x4E
	if(__NFUN_129__(bVisible))
	{
		__NFUN_113__('None');		
	}
	else
	{
		m_Player.__NFUN_264__(m_RoseOpenSnd, 9);
		__NFUN_113__('MenuDisplayed');
		SetMenuChoice(0);
	}
	return;
}

//===========================================================================//
// KeyEvent()                                                                //
//===========================================================================//
function bool KeyEvent(Interactions.EInputKey eKey, Interactions.EInputAction eAction, float fDelta)
{
	// End:0x8D
	if(__NFUN_154__(int(eKey), int(m_Player.__NFUN_2706__(m_ActionKey))))
	{
		// End:0x4C
		if(__NFUN_130__(__NFUN_154__(int(eAction), int(1)), __NFUN_129__(m_bActionKeyDown)))
		{
			m_bActionKeyDown = true;
			ActionKeyPressed();
			return true;
		}
		// End:0x8D
		if(__NFUN_130__(__NFUN_154__(int(eAction), int(3)), m_bActionKeyDown))
		{
			// End:0x7B
			if(__NFUN_129__(m_bIgnoreNextActionKeyRelease))
			{
				ActionKeyReleased();				
			}
			else
			{
				m_bIgnoreNextActionKeyRelease = false;
			}
			m_bActionKeyDown = false;
			return true;
		}
	}
	return super.KeyEvent(eKey, eAction, fDelta);
	return;
}

//===========================================================================//
// DrawRoseDesVents                                                          //
//===========================================================================//
function DrawRoseDesVents(Canvas C, int iMnuChoice)
{
	local int iItem, iUStart, iUEnd;
	local float fPosX, fPosY, fCenterX, fCenterY;
	local Color TeamColor;
	local float fScaleX, fScaleY;
	local Texture CurrentTexture;
	local bool bFlip, bHasSubMenu, bIsCurrent;

	TeamColor = m_color;
	C.__NFUN_1606__(false);
	fScaleX = __NFUN_172__(float(C.SizeX), 800.0000000);
	fScaleY = __NFUN_172__(float(C.SizeY), 600.0000000);
	fCenterX = __NFUN_174__(__NFUN_172__(float(C.SizeX), 2.0000000), fScaleX);
	fCenterY = __NFUN_174__(__NFUN_172__(float(C.SizeY), 2.0000000), fScaleY);
	C.Font = m_Font;
	C.__NFUN_2626__(TeamColor.R, TeamColor.G, TeamColor.B, byte(255));
	C.Style = 5;
	C.__NFUN_2623__(__NFUN_175__(fCenterX, __NFUN_171__(float(__NFUN_146__(150, 5)), fScaleX)), __NFUN_175__(fCenterY, __NFUN_171__(float(__NFUN_146__(150, 5)), fScaleY)));
	C.__NFUN_466__(m_TexMNU, __NFUN_171__(__NFUN_174__(__NFUN_171__(150.0000000, float(2)), float(10)), fScaleX), __NFUN_171__(__NFUN_174__(__NFUN_171__(150.0000000, float(2)), float(10)), fScaleY), 0.0000000, 0.0000000, 512.0000000, 512.0000000);
	iItem = 0;
	J0x181:

	// End:0x511 [Loop If]
	if(__NFUN_150__(iItem, 4))
	{
		// End:0x1A7
		if(__NFUN_154__(iItem, iMnuChoice))
		{
			bIsCurrent = true;			
		}
		else
		{
			bIsCurrent = false;
		}
		bHasSubMenu = ItemHasSubMenu(iItem);
		switch(iItem)
		{
			// End:0x271
			case 0:
				fPosX = __NFUN_175__(fCenterX, __NFUN_171__(float(__NFUN_145__(150, 2)), fScaleX));
				fPosY = __NFUN_175__(fCenterY, __NFUN_171__(float(150), fScaleY));
				// End:0x263
				if(MenuItemEnabled(iItem))
				{
					// End:0x23E
					if(__NFUN_129__(bHasSubMenu))
					{
						// End:0x230
						if(bIsCurrent)
						{
							CurrentTexture = m_TexMNUItemSelectedTop;							
						}
						else
						{
							CurrentTexture = m_TexMNUItemNormalTop;
						}						
					}
					else
					{
						// End:0x255
						if(bIsCurrent)
						{
							CurrentTexture = m_TexMNUItemSelectedSubTop;							
						}
						else
						{
							CurrentTexture = m_TexMNUItemNormalSubTop;
						}
					}					
				}
				else
				{
					CurrentTexture = m_TexMNUItemNormalTop;
				}
				// End:0x467
				break;
			// End:0x30D
			case 1:
				fPosX = fCenterX;
				fPosY = __NFUN_175__(fCenterY, __NFUN_171__(float(__NFUN_145__(150, 2)), fScaleY));
				// End:0x2FF
				if(MenuItemEnabled(iItem))
				{
					// End:0x2DA
					if(__NFUN_129__(bHasSubMenu))
					{
						// End:0x2CC
						if(bIsCurrent)
						{
							CurrentTexture = m_TexMNUItemSelectedLeft;							
						}
						else
						{
							CurrentTexture = m_TexMNUItemNormalLeft;
						}						
					}
					else
					{
						// End:0x2F1
						if(bIsCurrent)
						{
							CurrentTexture = m_TexMNUItemSelectedSubLeft;							
						}
						else
						{
							CurrentTexture = m_TexMNUItemNormalSubLeft;
						}
					}					
				}
				else
				{
					CurrentTexture = m_TexMNUItemNormalLeft;
				}
				// End:0x467
				break;
			// End:0x3B2
			case 2:
				fPosX = __NFUN_175__(fCenterX, __NFUN_171__(float(__NFUN_145__(150, 2)), fScaleX));
				fPosY = fCenterY;
				bFlip = true;
				// End:0x3A4
				if(MenuItemEnabled(iItem))
				{
					// End:0x37F
					if(__NFUN_129__(bHasSubMenu))
					{
						// End:0x371
						if(bIsCurrent)
						{
							CurrentTexture = m_TexMNUItemSelectedTop;							
						}
						else
						{
							CurrentTexture = m_TexMNUItemNormalTop;
						}						
					}
					else
					{
						// End:0x396
						if(bIsCurrent)
						{
							CurrentTexture = m_TexMNUItemSelectedSubTop;							
						}
						else
						{
							CurrentTexture = m_TexMNUItemNormalSubTop;
						}
					}					
				}
				else
				{
					CurrentTexture = m_TexMNUItemNormalTop;
				}
				// End:0x467
				break;
			// End:0x464
			case 3:
				fPosX = __NFUN_175__(fCenterX, __NFUN_171__(float(150), fScaleX));
				fPosY = __NFUN_175__(fCenterY, __NFUN_171__(float(__NFUN_145__(150, 2)), fScaleY));
				bFlip = true;
				// End:0x456
				if(MenuItemEnabled(iItem))
				{
					// End:0x431
					if(__NFUN_129__(bHasSubMenu))
					{
						// End:0x423
						if(bIsCurrent)
						{
							CurrentTexture = m_TexMNUItemSelectedLeft;							
						}
						else
						{
							CurrentTexture = m_TexMNUItemNormalLeft;
						}						
					}
					else
					{
						// End:0x448
						if(bIsCurrent)
						{
							CurrentTexture = m_TexMNUItemSelectedSubLeft;							
						}
						else
						{
							CurrentTexture = m_TexMNUItemNormalSubLeft;
						}
					}					
				}
				else
				{
					CurrentTexture = m_TexMNUItemNormalLeft;
				}
				// End:0x467
				break;
			// End:0xFFFF
			default:
				break;
		}
		C.__NFUN_2623__(fPosX, fPosY);
		// End:0x4CA
		if(bFlip)
		{
			C.__NFUN_466__(CurrentTexture, __NFUN_171__(150.0000000, fScaleX), __NFUN_171__(150.0000000, fScaleY), m_iTextureWidth, m_iTextureHeight, __NFUN_169__(m_iTextureWidth), __NFUN_169__(m_iTextureHeight));
			// [Explicit Continue]
			goto J0x507;
		}
		C.__NFUN_466__(CurrentTexture, __NFUN_171__(150.0000000, fScaleX), __NFUN_171__(150.0000000, fScaleY), 0.0000000, 0.0000000, m_iTextureWidth, m_iTextureHeight);
		J0x507:

		__NFUN_165__(iItem);
		// [Loop Continue]
		goto J0x181;
	}
	return;
}

//===========================================================================//
// DrawTextCenteredInBox()                                                   //
//===========================================================================//
function DrawTextCenteredInBox(Canvas C, string strText, float fPosX, float fPosY, float fWidth, float fHeight)
{
	local float fTextWidth, fTextHeight;
	local bool bBackCenter;
	local float fBackOrgX, fBackOrgY, fBackClipX, fBackClipY;

	bBackCenter = C.bCenter;
	fBackOrgX = C.OrgX;
	fBackOrgY = C.OrgY;
	fBackClipX = C.ClipX;
	fBackClipY = C.ClipY;
	C.bCenter = true;
	C.OrgX = fPosX;
	C.OrgY = fPosY;
	C.ClipX = fWidth;
	C.ClipY = fHeight;
	C.__NFUN_464__(strText, fTextWidth, fTextHeight);
	C.__NFUN_2623__(0.0000000, __NFUN_172__(__NFUN_175__(fHeight, fTextHeight), 2.0000000));
	C.__NFUN_465__(strText);
	C.bCenter = bBackCenter;
	C.OrgX = fBackOrgX;
	C.OrgY = fBackOrgY;
	C.ClipX = fBackClipX;
	C.ClipY = fBackClipY;
	return;
}

state MenuDisplayed
{
//===========================================================================//
// KeyEvent()                                                                //
//===========================================================================//
	function bool KeyEvent(Interactions.EInputKey eKey, Interactions.EInputAction eAction, float fDelta)
	{
		local int iCurrentMnuChoice;

		// End:0x50
		if(__NFUN_130__(__NFUN_154__(int(eKey), int(m_Player.__NFUN_2706__(m_ActionKey))), __NFUN_154__(int(eAction), int(3))))
		{
			NoItemSelected();
			DisplayMenu(false);
			m_bActionKeyDown = false;
			m_bIgnoreNextActionKeyRelease = false;
			return true;
		}
		// End:0x111
		if(__NFUN_130__(__NFUN_154__(int(eKey), int(1)), __NFUN_154__(int(eAction), int(1))))
		{
			// End:0x87
			if(__NFUN_129__(MenuItemEnabled(m_iCurrentMnuChoice)))
			{
				return true;				
			}
			else
			{
				// End:0xE2
				if(CurrentItemHasSubMenu())
				{
					m_Player.__NFUN_264__(m_RoseSelectSnd, 9);
					GotoSubMenu();
					// End:0xDF
					if(bShowLog)
					{
						__NFUN_231__("**** LeftMouse -> Move to sub menu ! ****");
					}					
				}
				else
				{
					m_Player.__NFUN_264__(m_RoseSelectSnd, 9);
					ItemClicked(m_iCurrentMnuChoice);
					DisplayMenu(false);
					m_bIgnoreNextActionKeyRelease = true;
				}
			}
			return true;
		}
		// End:0x19C
		if(__NFUN_130__(__NFUN_154__(int(eKey), int(2)), __NFUN_154__(int(eAction), int(1))))
		{
			// End:0x148
			if(__NFUN_129__(MenuItemEnabled(m_iCurrentMnuChoice)))
			{
				return true;				
			}
			else
			{
				// End:0x16D
				if(CurrentItemHasSubMenu())
				{
					m_Player.__NFUN_264__(m_RoseSelectSnd, 9);
					GotoSubMenu();					
				}
				else
				{
					m_Player.__NFUN_264__(m_RoseSelectSnd, 9);
					ItemRightClicked(m_iCurrentMnuChoice);
					DisplayMenu(false);
					m_bIgnoreNextActionKeyRelease = true;
				}
			}
			return true;
		}
		// End:0x22E
		if(__NFUN_154__(int(eAction), int(4)))
		{
			switch(eKey)
			{
				// End:0x1EF
				case 228:
					// End:0x1EA
					if(__NFUN_177__(__NFUN_186__(fDelta), float(C_iMouseDelta)))
					{
						// End:0x1E2
						if(__NFUN_177__(fDelta, float(0)))
						{
							SetMenuChoice(1);							
						}
						else
						{
							SetMenuChoice(3);
						}
					}
					return true;
					// End:0x22E
					break;
				// End:0x22B
				case 229:
					// End:0x226
					if(__NFUN_177__(__NFUN_186__(fDelta), float(C_iMouseDelta)))
					{
						// End:0x21E
						if(__NFUN_177__(fDelta, float(0)))
						{
							SetMenuChoice(0);							
						}
						else
						{
							SetMenuChoice(2);
						}
					}
					return true;
					// End:0x22E
					break;
				// End:0xFFFF
				default:
					break;
			}
		}
		else
		{
			// End:0x276
			if(__NFUN_130__(__NFUN_154__(int(eKey), int(236)), __NFUN_154__(int(eAction), int(1))))
			{
				SetMenuChoice(__NFUN_146__(m_iCurrentMnuChoice, 1));
				// End:0x274
				if(__NFUN_154__(m_iCurrentMnuChoice, -1))
				{
					SetMenuChoice(0);
				}
				return true;
			}
			// End:0x2BF
			if(__NFUN_130__(__NFUN_154__(int(eKey), int(237)), __NFUN_154__(int(eAction), int(1))))
			{
				SetMenuChoice(__NFUN_147__(m_iCurrentMnuChoice, 1));
				// End:0x2BD
				if(__NFUN_154__(m_iCurrentMnuChoice, -1))
				{
					SetMenuChoice(3);
				}
				return true;
			}
			return super(Interaction).KeyEvent(eKey, eAction, fDelta);
			return;
		}
	}
	stop;
}

defaultproperties
{
	m_iCurrentMnuChoice=-1
	m_iCurrentSubMnuChoice=-1
	C_iMouseDelta=5
	m_iTextureWidth=256.0000000
	m_iTextureHeight=256.0000000
	m_TexMNU=Texture'R6HUD.QuadDisplay_back'
	m_TexMNUItemNormalTop=Texture'R6HUD.QuadDisplay_01_Ver'
	m_TexMNUItemNormalLeft=Texture'R6HUD.QuadDisplay_01_Hori'
	m_TexMNUItemNormalSubTop=Texture'R6HUD.QuadDisplay_02_Ver'
	m_TexMNUItemNormalSubLeft=Texture'R6HUD.QuadDisplay_02_Hori'
	m_TexMNUItemSelectedSubTop=Texture'R6HUD.QuadDisplay_03_Ver'
	m_TexMNUItemSelectedSubLeft=Texture'R6HUD.QuadDisplay_03_Hori'
	m_TexMNUItemSelectedTop=Texture'R6HUD.QuadDisplay_04_Ver'
	m_TexMNUItemSelectedLeft=Texture'R6HUD.QuadDisplay_04_Hori'
	m_Font=Font'R6Font.Rainbow6_14pt'
	m_RoseOpenSnd=Sound'SFX_Menus.Play_Rose_Open'
	m_RoseSelectSnd=Sound'SFX_Menus.Play_Rose_Select'
}
