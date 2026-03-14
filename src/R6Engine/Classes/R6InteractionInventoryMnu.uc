//=============================================================================
// R6InteractionInventoryMnu - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6InteractionInventoryMnu.uc : Interaction associated with the inventory.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/21 * Created by S�bastien Lussier
//=============================================================================
class R6InteractionInventoryMnu extends R6InteractionRoseDesVents;

function ActionKeyPressed()
{
	// End:0x14
	if(m_Player.bOnlySpectator)
	{
		return;
	}
	DisplayMenu(true);
	return;
}

function bool IsValidMenuChoice(int iChoice)
{
	// End:0x6E
	if(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_150__(iChoice, 0), __NFUN_151__(iChoice, 3)), __NFUN_114__(m_Player.m_pawn.m_WeaponsCarried[iChoice], none)), __NFUN_129__(m_Player.m_pawn.m_WeaponsCarried[iChoice].HasAmmo())))
	{
		return false;
	}
	return true;
	return;
}

function SetMenuChoice(int iChoice)
{
	// End:0x27
	if(__NFUN_132__(__NFUN_150__(iChoice, 0), __NFUN_151__(iChoice, 3)))
	{
		m_iCurrentMnuChoice = -1;		
	}
	else
	{
		// End:0x84
		if(__NFUN_130__(__NFUN_119__(m_Player.m_pawn.m_WeaponsCarried[iChoice], none), m_Player.m_pawn.m_WeaponsCarried[iChoice].HasAmmo()))
		{
			m_iCurrentMnuChoice = iChoice;			
		}
		else
		{
			SetMenuChoice(__NFUN_147__(iChoice, 1));
		}
	}
	return;
}

function ItemClicked(int iItem)
{
	// End:0x33
	if(bShowLog)
	{
		__NFUN_231__("**** LeftMouse -> Change weapon ! ****");
	}
	// End:0x5B
	if(__NFUN_155__(iItem, -1))
	{
		m_Player.SwitchWeapon(byte(__NFUN_146__(iItem, 1)));
	}
	return;
}

function PostRender(Canvas C)
{
	C.__NFUN_1606__(true);
	DrawInventoryMenu(C);
	C.__NFUN_1606__(false);
	return;
}

//===========================================================================//
// DrawInventoryMenu()                                                       //
//===========================================================================//
function DrawInventoryMenu(Canvas C)
{
	local string strWeapon[4];
	local Color TextColor[4];
	local int iWeapon;
	local R6Rainbow PlayerPawn;
	local Texture weaponIcon;
	local float fPosX, fPosY, fTextSizeX, fTextSizeY, fScaleX, fScaleY;

	local bool bPrimaryGadgetSet, bSecondaryGadgetSet;
	local R6EngineWeapon pWeapon;

	// End:0x0D
	if(__NFUN_114__(m_Player, none))
	{
		return;
	}
	// End:0x35
	if(__NFUN_132__(m_Player.bOnlySpectator, m_Player.bCheatFlying))
	{
		return;
	}
	PlayerPawn = m_Player.m_pawn;
	// End:0x63
	if(__NFUN_132__(__NFUN_114__(PlayerPawn, none), __NFUN_129__(bVisible)))
	{
		return;
	}
	DrawRoseDesVents(C, m_iCurrentMnuChoice);
	fScaleX = __NFUN_172__(float(C.SizeX), 800.0000000);
	fScaleY = __NFUN_172__(float(C.SizeY), 600.0000000);
	fPosX = __NFUN_174__(__NFUN_172__(float(C.SizeX), 2.0000000), fScaleX);
	fPosY = __NFUN_174__(__NFUN_172__(float(C.SizeY), 2.0000000), fScaleY);
	iWeapon = 0;
	J0xFC:

	// End:0x22C [Loop If]
	if(__NFUN_150__(iWeapon, 2))
	{
		// End:0x1CA
		if(__NFUN_119__(PlayerPawn.m_WeaponsCarried[iWeapon], none))
		{
			strWeapon[iWeapon] = PlayerPawn.m_WeaponsCarried[iWeapon].m_WeaponShortName;
			// End:0x19B
			if(PlayerPawn.m_WeaponsCarried[iWeapon].HasAmmo())
			{
				TextColor[iWeapon] = m_Player.m_TeamManager.Colors.HUDWhite;				
			}
			else
			{
				TextColor[iWeapon] = m_Player.m_TeamManager.Colors.HUDGrey;
			}
			// [Explicit Continue]
			goto J0x222;
		}
		strWeapon[iWeapon] = Localize("MISC", "ID_EMPTY", "R6Common");
		TextColor[iWeapon] = m_Player.m_TeamManager.Colors.HUDGrey;
		J0x222:

		__NFUN_165__(iWeapon);
		// [Loop Continue]
		goto J0xFC;
	}
	pWeapon = PlayerPawn.m_WeaponsCarried[2];
	// End:0x2C4
	if(__NFUN_130__(__NFUN_119__(pWeapon, none), pWeapon.HasAmmo()))
	{
		strWeapon[2] = Localize(pWeapon.m_NameID, "ID_NAME", "R6Gadgets");
		bPrimaryGadgetSet = true;
		TextColor[2] = m_Player.m_TeamManager.Colors.HUDWhite;
	}
	pWeapon = PlayerPawn.m_WeaponsCarried[3];
	// End:0x35C
	if(__NFUN_130__(__NFUN_119__(pWeapon, none), pWeapon.HasAmmo()))
	{
		strWeapon[3] = Localize(pWeapon.m_NameID, "ID_NAME", "R6Gadgets");
		bSecondaryGadgetSet = true;
		TextColor[3] = m_Player.m_TeamManager.Colors.HUDWhite;
	}
	// End:0x449
	if(PlayerPawn.m_bHasLockPickKit)
	{
		// End:0x3DD
		if(__NFUN_129__(bPrimaryGadgetSet))
		{
			strWeapon[2] = Localize("LOCKPICKKIT", "ID_NAME", "R6Gadgets");
			bPrimaryGadgetSet = true;
			TextColor[2] = m_Player.m_TeamManager.Colors.HUDGrey;			
		}
		else
		{
			// End:0x449
			if(__NFUN_129__(bSecondaryGadgetSet))
			{
				strWeapon[3] = Localize("LOCKPICKKIT", "ID_NAME", "R6Gadgets");
				bSecondaryGadgetSet = true;
				TextColor[3] = m_Player.m_TeamManager.Colors.HUDGrey;
			}
		}
	}
	// End:0x534
	if(PlayerPawn.m_bHasDiffuseKit)
	{
		// End:0x4C9
		if(__NFUN_129__(bPrimaryGadgetSet))
		{
			strWeapon[2] = Localize("DIFFUSEKIT", "ID_NAME", "R6Gadgets");
			bPrimaryGadgetSet = true;
			TextColor[2] = m_Player.m_TeamManager.Colors.HUDGrey;			
		}
		else
		{
			// End:0x534
			if(__NFUN_129__(bSecondaryGadgetSet))
			{
				strWeapon[3] = Localize("DIFFUSEKIT", "ID_NAME", "R6Gadgets");
				bSecondaryGadgetSet = true;
				TextColor[3] = m_Player.m_TeamManager.Colors.HUDGrey;
			}
		}
	}
	// End:0x625
	if(PlayerPawn.m_bHasElectronicsKit)
	{
		// End:0x5B7
		if(__NFUN_129__(bPrimaryGadgetSet))
		{
			strWeapon[2] = Localize("ELECTRONICKIT", "ID_NAME", "R6Gadgets");
			bPrimaryGadgetSet = true;
			TextColor[2] = m_Player.m_TeamManager.Colors.HUDGrey;			
		}
		else
		{
			// End:0x625
			if(__NFUN_129__(bSecondaryGadgetSet))
			{
				strWeapon[3] = Localize("ELECTRONICKIT", "ID_NAME", "R6Gadgets");
				bSecondaryGadgetSet = true;
				TextColor[3] = m_Player.m_TeamManager.Colors.HUDGrey;
			}
		}
	}
	// End:0x70A
	if(PlayerPawn.m_bHaveGasMask)
	{
		// End:0x6A2
		if(__NFUN_129__(bPrimaryGadgetSet))
		{
			strWeapon[2] = Localize("GASMASK", "ID_NAME", "R6Gadgets");
			bPrimaryGadgetSet = true;
			TextColor[2] = m_Player.m_TeamManager.Colors.HUDGrey;			
		}
		else
		{
			// End:0x70A
			if(__NFUN_129__(bSecondaryGadgetSet))
			{
				strWeapon[3] = Localize("GASMASK", "ID_NAME", "R6Gadgets");
				bSecondaryGadgetSet = true;
				TextColor[3] = m_Player.m_TeamManager.Colors.HUDGrey;
			}
		}
	}
	// End:0x76F
	if(__NFUN_129__(bPrimaryGadgetSet))
	{
		strWeapon[2] = Localize("MISC", "ID_EMPTY", "R6Common");
		bPrimaryGadgetSet = true;
		TextColor[2] = m_Player.m_TeamManager.Colors.HUDGrey;
	}
	// End:0x7D4
	if(__NFUN_129__(bSecondaryGadgetSet))
	{
		strWeapon[3] = Localize("MISC", "ID_EMPTY", "R6Common");
		bSecondaryGadgetSet = true;
		TextColor[3] = m_Player.m_TeamManager.Colors.HUDGrey;
	}
	fTextSizeX = 75.0000000;
	fTextSizeY = 32.0000000;
	C.Style = 3;
	C.__NFUN_1606__(false);
	iWeapon = 0;
	J0x80F:

	// End:0xA0D [Loop If]
	if(__NFUN_150__(iWeapon, 4))
	{
		C.__NFUN_2626__(TextColor[iWeapon].R, TextColor[iWeapon].G, TextColor[iWeapon].B, TextColor[iWeapon].A);
		switch(iWeapon)
		{
			// End:0x8D6
			case 0:
				DrawTextCenteredInBox(C, strWeapon[iWeapon], __NFUN_175__(fPosX, __NFUN_172__(__NFUN_171__(fTextSizeX, fScaleX), 2.0000000)), __NFUN_175__(fPosY, __NFUN_171__(__NFUN_174__(float(50), fTextSizeY), fScaleY)), __NFUN_171__(fTextSizeX, fScaleX), __NFUN_171__(fTextSizeY, fScaleY));
				// End:0xA03
				break;
			// End:0x936
			case 1:
				DrawTextCenteredInBox(C, strWeapon[iWeapon], __NFUN_174__(fPosX, __NFUN_171__(float(35), fScaleX)), __NFUN_175__(fPosY, __NFUN_171__(__NFUN_172__(fTextSizeY, float(2)), fScaleY)), __NFUN_171__(fTextSizeX, fScaleX), __NFUN_171__(fTextSizeY, fScaleY));
				// End:0xA03
				break;
			// End:0x998
			case 2:
				DrawTextCenteredInBox(C, strWeapon[iWeapon], __NFUN_175__(fPosX, __NFUN_172__(__NFUN_171__(fTextSizeX, fScaleX), 2.0000000)), __NFUN_174__(fPosY, __NFUN_171__(float(50), fScaleY)), __NFUN_171__(fTextSizeX, fScaleX), __NFUN_171__(fTextSizeY, fScaleY));
				// End:0xA03
				break;
			// End:0xA00
			case 3:
				DrawTextCenteredInBox(C, strWeapon[iWeapon], __NFUN_175__(fPosX, __NFUN_171__(__NFUN_174__(float(35), fTextSizeX), fScaleX)), __NFUN_175__(fPosY, __NFUN_171__(__NFUN_172__(fTextSizeY, float(2)), fScaleY)), __NFUN_171__(fTextSizeX, fScaleX), __NFUN_171__(fTextSizeY, fScaleY));
				// End:0xA03
				break;
			// End:0xFFFF
			default:
				break;
		}
		__NFUN_165__(iWeapon);
		// [Loop Continue]
		goto J0x80F;
	}
	C.OrgX = 0.0000000;
	C.OrgY = 0.0000000;
	return;
}

defaultproperties
{
	m_ActionKey="InventoryMenu"
}
