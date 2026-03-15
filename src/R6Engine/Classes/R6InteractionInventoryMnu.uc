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
	if(((((iChoice < 0) || (iChoice > 3)) || (m_Player.m_pawn.m_WeaponsCarried[iChoice] == none)) || (!m_Player.m_pawn.m_WeaponsCarried[iChoice].HasAmmo())))
	{
		return false;
	}
	return true;
	return;
}

function SetMenuChoice(int iChoice)
{
	// End:0x27
	if(((iChoice < 0) || (iChoice > 3)))
	{
		m_iCurrentMnuChoice = -1;		
	}
	else
	{
		// End:0x84
		if(((m_Player.m_pawn.m_WeaponsCarried[iChoice] != none) && m_Player.m_pawn.m_WeaponsCarried[iChoice].HasAmmo()))
		{
			m_iCurrentMnuChoice = iChoice;			
		}
		else
		{
			SetMenuChoice((iChoice - 1));
		}
	}
	return;
}

function ItemClicked(int iItem)
{
	// End:0x33
	if(bShowLog)
	{
		Log("**** LeftMouse -> Change weapon ! ****");
	}
	// End:0x5B
	if((iItem != -1))
	{
		m_Player.SwitchWeapon(byte((iItem + 1)));
	}
	return;
}

function PostRender(Canvas C)
{
	C.UseVirtualSize(true);
	DrawInventoryMenu(C);
	C.UseVirtualSize(false);
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
	if((m_Player == none))
	{
		return;
	}
	// End:0x35
	if((m_Player.bOnlySpectator || m_Player.bCheatFlying))
	{
		return;
	}
	PlayerPawn = m_Player.m_pawn;
	// End:0x63
	if(((PlayerPawn == none) || (!bVisible)))
	{
		return;
	}
	DrawRoseDesVents(C, m_iCurrentMnuChoice);
	fScaleX = (float(C.SizeX) / 800.0000000);
	fScaleY = (float(C.SizeY) / 600.0000000);
	fPosX = ((float(C.SizeX) / 2.0000000) + fScaleX);
	fPosY = ((float(C.SizeY) / 2.0000000) + fScaleY);
	iWeapon = 0;
	J0xFC:

	// End:0x22C [Loop If]
	if((iWeapon < 2))
	{
		// End:0x1CA
		if((PlayerPawn.m_WeaponsCarried[iWeapon] != none))
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

		(iWeapon++);
		// [Loop Continue]
		goto J0xFC;
	}
	pWeapon = PlayerPawn.m_WeaponsCarried[2];
	// End:0x2C4
	if(((pWeapon != none) && pWeapon.HasAmmo()))
	{
		strWeapon[2] = Localize(pWeapon.m_NameID, "ID_NAME", "R6Gadgets");
		bPrimaryGadgetSet = true;
		TextColor[2] = m_Player.m_TeamManager.Colors.HUDWhite;
	}
	pWeapon = PlayerPawn.m_WeaponsCarried[3];
	// End:0x35C
	if(((pWeapon != none) && pWeapon.HasAmmo()))
	{
		strWeapon[3] = Localize(pWeapon.m_NameID, "ID_NAME", "R6Gadgets");
		bSecondaryGadgetSet = true;
		TextColor[3] = m_Player.m_TeamManager.Colors.HUDWhite;
	}
	// End:0x449
	if(PlayerPawn.m_bHasLockPickKit)
	{
		// End:0x3DD
		if((!bPrimaryGadgetSet))
		{
			strWeapon[2] = Localize("LOCKPICKKIT", "ID_NAME", "R6Gadgets");
			bPrimaryGadgetSet = true;
			TextColor[2] = m_Player.m_TeamManager.Colors.HUDGrey;			
		}
		else
		{
			// End:0x449
			if((!bSecondaryGadgetSet))
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
		if((!bPrimaryGadgetSet))
		{
			strWeapon[2] = Localize("DIFFUSEKIT", "ID_NAME", "R6Gadgets");
			bPrimaryGadgetSet = true;
			TextColor[2] = m_Player.m_TeamManager.Colors.HUDGrey;			
		}
		else
		{
			// End:0x534
			if((!bSecondaryGadgetSet))
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
		if((!bPrimaryGadgetSet))
		{
			strWeapon[2] = Localize("ELECTRONICKIT", "ID_NAME", "R6Gadgets");
			bPrimaryGadgetSet = true;
			TextColor[2] = m_Player.m_TeamManager.Colors.HUDGrey;			
		}
		else
		{
			// End:0x625
			if((!bSecondaryGadgetSet))
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
		if((!bPrimaryGadgetSet))
		{
			strWeapon[2] = Localize("GASMASK", "ID_NAME", "R6Gadgets");
			bPrimaryGadgetSet = true;
			TextColor[2] = m_Player.m_TeamManager.Colors.HUDGrey;			
		}
		else
		{
			// End:0x70A
			if((!bSecondaryGadgetSet))
			{
				strWeapon[3] = Localize("GASMASK", "ID_NAME", "R6Gadgets");
				bSecondaryGadgetSet = true;
				TextColor[3] = m_Player.m_TeamManager.Colors.HUDGrey;
			}
		}
	}
	// End:0x76F
	if((!bPrimaryGadgetSet))
	{
		strWeapon[2] = Localize("MISC", "ID_EMPTY", "R6Common");
		bPrimaryGadgetSet = true;
		TextColor[2] = m_Player.m_TeamManager.Colors.HUDGrey;
	}
	// End:0x7D4
	if((!bSecondaryGadgetSet))
	{
		strWeapon[3] = Localize("MISC", "ID_EMPTY", "R6Common");
		bSecondaryGadgetSet = true;
		TextColor[3] = m_Player.m_TeamManager.Colors.HUDGrey;
	}
	fTextSizeX = 75.0000000;
	fTextSizeY = 32.0000000;
	C.Style = 3;
	C.UseVirtualSize(false);
	iWeapon = 0;
	J0x80F:

	// End:0xA0D [Loop If]
	if((iWeapon < 4))
	{
		C.SetDrawColor(TextColor[iWeapon].R, TextColor[iWeapon].G, TextColor[iWeapon].B, TextColor[iWeapon].A);
		switch(iWeapon)
		{
			// End:0x8D6
			case 0:
				DrawTextCenteredInBox(C, strWeapon[iWeapon], (fPosX - ((fTextSizeX * fScaleX) / 2.0000000)), (fPosY - ((float(50) + fTextSizeY) * fScaleY)), (fTextSizeX * fScaleX), (fTextSizeY * fScaleY));
				// End:0xA03
				break;
			// End:0x936
			case 1:
				DrawTextCenteredInBox(C, strWeapon[iWeapon], (fPosX + (float(35) * fScaleX)), (fPosY - ((fTextSizeY / float(2)) * fScaleY)), (fTextSizeX * fScaleX), (fTextSizeY * fScaleY));
				// End:0xA03
				break;
			// End:0x998
			case 2:
				DrawTextCenteredInBox(C, strWeapon[iWeapon], (fPosX - ((fTextSizeX * fScaleX) / 2.0000000)), (fPosY + (float(50) * fScaleY)), (fTextSizeX * fScaleX), (fTextSizeY * fScaleY));
				// End:0xA03
				break;
			// End:0xA00
			case 3:
				DrawTextCenteredInBox(C, strWeapon[iWeapon], (fPosX - ((float(35) + fTextSizeX) * fScaleX)), (fPosY - ((fTextSizeY / float(2)) * fScaleY)), (fTextSizeX * fScaleX), (fTextSizeY * fScaleY));
				// End:0xA03
				break;
			// End:0xFFFF
			default:
				break;
		}
		(iWeapon++);
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
