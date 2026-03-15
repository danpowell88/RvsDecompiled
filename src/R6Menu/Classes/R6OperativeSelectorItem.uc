//=============================================================================
// R6OperativeSelectorItem - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// R6ColorPicker - Color picker for the writable map
//=============================================================================
class R6OperativeSelectorItem extends UWindowDialogControl;

var byte m_eHealth;
var int m_iOperativeIndex;
var int m_iTeam;
var const int NameX;
var const int NameY;
var const int SpecX;
var const int SpecY;
var const int WeaponX;
var const int WeaponY;
var const int WeaponHeight;
var const int LifeX;
var const int LifeY;
var bool m_bMouseOver;
var bool m_bIsDead;
var bool m_bIsSinglePlayer;
var R6Rainbow m_Operative;
var R6TeamMemberReplicationInfo m_MemberRepInfo;
var Sound m_OperativeSelectSnd;
var Material HealthIconTexture;
var Material DefaultFaceTexture;
var Color m_DarkColor;
var Color m_NormalColor;
var Plane DefaultFaceCoords;
var string m_szSpeciality;
var string m_WeaponsName[4];
var string m_szName;

function LMouseDown(float X, float Y)
{
	local R6PlayerController PlayerOwner;
	local R6RainbowTeam teamManager;

	// End:0x0B
	if(m_bIsDead)
	{
		return;
	}
	PlayerOwner = R6PlayerController(GetPlayerOwner());
	PlayerOwner.PlaySound(m_OperativeSelectSnd, 9);
	// End:0x5D
	if((!m_bIsSinglePlayer))
	{
		PlayerOwner.ChangeOperative(0, int(m_MemberRepInfo.m_iTeamPosition));		
	}
	else
	{
		// End:0x96
		if((!m_Operative.m_bIsPlayer))
		{
			teamManager = R6RainbowAI(m_Operative.Controller).m_TeamManager;			
		}
		else
		{
			teamManager = R6PlayerController(m_Operative.Controller).m_TeamManager;
		}
		PlayerOwner.ChangeOperative(teamManager.m_iRainbowTeamName, m_Operative.m_iID);
	}
	Root.ChangeCurrentWidget(0);
	return;
}

function SetCharacterInfo(R6Rainbow Character)
{
	local int iWeapon;

	m_Operative = Character;
	m_MemberRepInfo = none;
	m_bIsSinglePlayer = true;
	iWeapon = 0;
	J0x21:

	// End:0x12E [Loop If]
	if((iWeapon < 4))
	{
		// End:0x73
		if((m_Operative.m_WeaponsCarried[iWeapon] != none))
		{
			m_WeaponsName[iWeapon] = m_Operative.m_WeaponsCarried[iWeapon].m_WeaponShortName;
			// [Explicit Continue]
			goto J0x124;
		}
		// End:0xCD
		if(((iWeapon == 2) && (m_Operative.m_szPrimaryItem != "")))
		{
			m_WeaponsName[iWeapon] = Localize(m_Operative.m_szPrimaryItem, "ID_NAME", "R6Gadgets");
			// [Explicit Continue]
			goto J0x124;
		}
		// End:0x124
		if(((iWeapon == 3) && (m_Operative.m_szSecondaryItem != "")))
		{
			m_WeaponsName[iWeapon] = Localize(m_Operative.m_szSecondaryItem, "ID_NAME", "R6Gadgets");
		}
		J0x124:

		(iWeapon++);
		// [Loop Continue]
		goto J0x21;
	}
	return;
}

function SetCharacterInfoMP(R6TeamMemberReplicationInfo repInfo)
{
	m_MemberRepInfo = repInfo;
	m_Operative = none;
	m_bIsSinglePlayer = false;
	// End:0x62
	if((m_MemberRepInfo.m_PrimaryWeapon != ""))
	{
		m_WeaponsName[0] = Localize(m_MemberRepInfo.m_PrimaryWeapon, "ID_NAME", "R6Weapons");		
	}
	else
	{
		m_WeaponsName[0] = Localize("MISC", "ID_EMPTY", "R6Common");
	}
	// End:0xD2
	if((m_MemberRepInfo.m_SecondaryWeapon != ""))
	{
		m_WeaponsName[1] = Localize(m_MemberRepInfo.m_SecondaryWeapon, "ID_NAME", "R6Weapons");		
	}
	else
	{
		m_WeaponsName[1] = Localize("MISC", "ID_EMPTY", "R6Common");
	}
	// End:0x140
	if((m_MemberRepInfo.m_PrimaryGadget != ""))
	{
		m_WeaponsName[2] = Localize(m_MemberRepInfo.m_PrimaryGadget, "ID_NAME", "R6Gadgets");
	}
	// End:0x186
	if((m_MemberRepInfo.m_SecondaryGadget != ""))
	{
		m_WeaponsName[3] = Localize(m_MemberRepInfo.m_SecondaryGadget, "ID_NAME", "R6Gadgets");
	}
	return;
}

function MouseEnter()
{
	super.MouseEnter();
	m_bMouseOver = true;
	return;
}

function MouseLeave()
{
	super.MouseLeave();
	m_bMouseOver = false;
	return;
}

function UpdateGadgets()
{
	local bool bIsPrimaryGadgetEmpty, bIsPrimaryGadgetSet, bIsSecondaryGadgetEmpty, bIsSecondaryGadgetSet;

	// End:0xA6
	if((m_Operative.m_WeaponsCarried[2] != none))
	{
		// End:0x75
		if(m_Operative.m_WeaponsCarried[2].HasAmmo())
		{
			m_WeaponsName[2] = Localize(m_Operative.m_WeaponsCarried[2].m_NameID, "ID_NAME", "R6Gadgets");			
		}
		else
		{
			m_WeaponsName[2] = Localize("MISC", "ID_EMPTY", "R6Common");
		}
		bIsPrimaryGadgetSet = true;
	}
	// End:0x14C
	if((m_Operative.m_WeaponsCarried[3] != none))
	{
		// End:0x11B
		if(m_Operative.m_WeaponsCarried[3].HasAmmo())
		{
			m_WeaponsName[3] = Localize(m_Operative.m_WeaponsCarried[3].m_NameID, "ID_NAME", "R6Gadgets");			
		}
		else
		{
			m_WeaponsName[3] = Localize("MISC", "ID_EMPTY", "R6Common");
		}
		bIsSecondaryGadgetSet = true;
	}
	// End:0x1E7
	if(m_Operative.m_bHasLockPickKit)
	{
		// End:0x1A4
		if((!bIsPrimaryGadgetSet))
		{
			m_WeaponsName[2] = Localize("LOCKPICKKIT", "ID_NAME", "R6Gadgets");
			bIsPrimaryGadgetSet = true;			
		}
		else
		{
			// End:0x1E7
			if((!bIsSecondaryGadgetSet))
			{
				m_WeaponsName[3] = Localize("LOCKPICKKIT", "ID_NAME", "R6Gadgets");
				bIsSecondaryGadgetSet = true;
			}
		}
	}
	// End:0x280
	if(m_Operative.m_bHasDiffuseKit)
	{
		// End:0x23E
		if((!bIsPrimaryGadgetSet))
		{
			m_WeaponsName[2] = Localize("DIFFUSEKIT", "ID_NAME", "R6Gadgets");
			bIsPrimaryGadgetSet = true;			
		}
		else
		{
			// End:0x280
			if((!bIsSecondaryGadgetSet))
			{
				m_WeaponsName[3] = Localize("DIFFUSEKIT", "ID_NAME", "R6Gadgets");
				bIsSecondaryGadgetSet = true;
			}
		}
	}
	// End:0x31F
	if(m_Operative.m_bHasElectronicsKit)
	{
		// End:0x2DA
		if((!bIsPrimaryGadgetSet))
		{
			m_WeaponsName[2] = Localize("ELECTRONICKIT", "ID_NAME", "R6Gadgets");
			bIsPrimaryGadgetSet = true;			
		}
		else
		{
			// End:0x31F
			if((!bIsSecondaryGadgetSet))
			{
				m_WeaponsName[3] = Localize("ELECTRONICKIT", "ID_NAME", "R6Gadgets");
				bIsSecondaryGadgetSet = true;
			}
		}
	}
	// End:0x3B2
	if(m_Operative.m_bHaveGasMask)
	{
		// End:0x373
		if((!bIsPrimaryGadgetSet))
		{
			m_WeaponsName[2] = Localize("GASMASK", "ID_NAME", "R6Gadgets");
			bIsPrimaryGadgetSet = true;			
		}
		else
		{
			// End:0x3B2
			if((!bIsSecondaryGadgetSet))
			{
				m_WeaponsName[3] = Localize("GASMASK", "ID_NAME", "R6Gadgets");
				bIsSecondaryGadgetSet = true;
			}
		}
	}
	// End:0x3E6
	if((!bIsPrimaryGadgetSet))
	{
		m_WeaponsName[2] = Localize("MISC", "ID_EMPTY", "R6Common");
	}
	// End:0x41A
	if((!bIsSecondaryGadgetSet))
	{
		m_WeaponsName[3] = Localize("MISC", "ID_EMPTY", "R6Common");
	}
	return;
}

function UpdatePosition()
{
	WinTop = float(((Class'R6Menu.R6MenuInGameOperativeSelectorWidget'.default.c_OutsideMarginY + Class'R6Menu.R6MenuInGameOperativeSelectorWidget'.default.c_InsideMarginY) + (m_Operative.m_iID * (Class'R6Menu.R6MenuInGameOperativeSelectorWidget'.default.c_InsideMarginY + Class'R6Menu.R6MenuInGameOperativeSelectorWidget'.default.c_RowHeight))));
	return;
}

function UpdatePositionMP()
{
	// End:0x63
	if((m_MemberRepInfo != none))
	{
		WinTop = float(((Class'R6Menu.R6MenuInGameOperativeSelectorWidget'.default.c_OutsideMarginY + Class'R6Menu.R6MenuInGameOperativeSelectorWidget'.default.c_InsideMarginY) + (int(m_MemberRepInfo.m_iTeamPosition) * (Class'R6Menu.R6MenuInGameOperativeSelectorWidget'.default.c_InsideMarginY + Class'R6Menu.R6MenuInGameOperativeSelectorWidget'.default.c_RowHeight))));
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local int iLifeU, iWeapon;
	local bool bIsDead, bCurrentSelection;
	local byte NameAlpha;
	local Color NameColor, NameBackgroundColor;
	local byte NameBackgroundAlpha, SpecAlpha;
	local Color SpecColor, SpecAndWeaponBackgroundColor;
	local byte SpecAndWeaponBackgroundAlpha;
	local Color WeaponColor;
	local byte WeaponAlpha, FaceAlpha;
	local Color LineColor;
	local byte LineAlpha;
	local string Name;
	local bool bIsPrimaryGadgetEmpty, bIsSecondaryGadgetEmpty;
	local float fPosX, fPosY;
	local PlayerController PlayerOwner;

	PlayerOwner = GetPlayerOwner();
	// End:0x8A
	if(m_bIsSinglePlayer)
	{
		// End:0x38
		if((PlayerOwner.ViewTarget == m_Operative))
		{
			bCurrentSelection = true;			
		}
		else
		{
			bCurrentSelection = false;
		}
		m_eHealth = m_Operative.m_eHealth;
		m_bIsDead = (int(m_eHealth) >= int(m_Operative.2));
		UpdateGadgets();
		bIsPrimaryGadgetEmpty = false;
		bIsSecondaryGadgetEmpty = false;		
	}
	else
	{
		// End:0xBB
		if((m_MemberRepInfo == R6Pawn(PlayerOwner.Pawn).m_TeamMemberRepInfo))
		{
			bCurrentSelection = true;			
		}
		else
		{
			bCurrentSelection = false;
		}
		m_eHealth = m_MemberRepInfo.m_eHealth;
		m_bIsDead = (int(m_eHealth) >= int(PlayerOwner.Pawn.2));
		bIsPrimaryGadgetEmpty = m_MemberRepInfo.m_bIsPrimaryGadgetEmpty;
		bIsSecondaryGadgetEmpty = m_MemberRepInfo.m_bIsSecondaryGadgetEmpty;
	}
	iLifeU = Min(int(m_eHealth), 2);
	C.Style = 5;
	LineColor = m_NormalColor;
	// End:0x1D6
	if((m_bIsDead == true))
	{
		NameColor = m_NormalColor;
		NameAlpha = 128;
		NameBackgroundColor = m_DarkColor;
		NameBackgroundAlpha = byte(255);
		SpecColor = m_NormalColor;
		SpecAlpha = 128;
		WeaponColor = m_NormalColor;
		WeaponAlpha = 128;
		SpecAndWeaponBackgroundColor = m_DarkColor;
		SpecAndWeaponBackgroundAlpha = 128;
		FaceAlpha = 128;
		LineAlpha = 128;		
	}
	else
	{
		// End:0x283
		if(m_bMouseOver)
		{
			NameColor = m_DarkColor;
			NameAlpha = byte(255);
			NameBackgroundColor = m_NormalColor;
			NameBackgroundAlpha = byte(255);
			SpecColor = Root.Colors.White;
			SpecAlpha = byte(255);
			WeaponColor = Root.Colors.White;
			WeaponAlpha = byte(255);
			SpecAndWeaponBackgroundColor = m_DarkColor;
			SpecAndWeaponBackgroundAlpha = byte(255);
			FaceAlpha = byte(255);
			LineAlpha = byte(255);			
		}
		else
		{
			// End:0x33E
			if(bCurrentSelection)
			{
				NameColor = Root.Colors.White;
				NameAlpha = byte(255);
				NameBackgroundColor = m_NormalColor;
				NameBackgroundAlpha = 128;
				SpecColor = Root.Colors.White;
				SpecAlpha = byte(255);
				WeaponColor = Root.Colors.White;
				WeaponAlpha = byte(255);
				SpecAndWeaponBackgroundColor = m_NormalColor;
				SpecAndWeaponBackgroundAlpha = 128;
				FaceAlpha = byte(255);
				LineAlpha = byte(255);				
			}
			else
			{
				NameColor = m_NormalColor;
				NameAlpha = byte(255);
				NameBackgroundColor = m_DarkColor;
				NameBackgroundAlpha = byte(255);
				SpecColor = m_NormalColor;
				SpecAlpha = byte(255);
				WeaponColor = m_NormalColor;
				WeaponAlpha = byte(255);
				SpecAndWeaponBackgroundColor = m_DarkColor;
				SpecAndWeaponBackgroundAlpha = 128;
				FaceAlpha = byte(255);
				LineAlpha = byte(255);
			}
		}
	}
	C.DrawColor = NameBackgroundColor;
	C.DrawColor.A = NameBackgroundAlpha;
	DrawStretchedTextureSegment(C, 40.0000000, 1.0000000, (WinWidth - float(41)), 21.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
	Name = GetCharacterName();
	C.TextSize(Name, fPosX, fPosY);
	C.SetPos((float(NameX) - (fPosX / 2.0000000)), float(NameY));
	C.Font = Root.Fonts[8];
	C.DrawColor = NameColor;
	C.DrawColor.A = NameAlpha;
	C.DrawText(Name);
	C.SetPos(float(LifeX), float(LifeY));
	C.DrawTile(HealthIconTexture, 10.0000000, 10.0000000, (31.0000000 + float((11 * iLifeU))), 29.0000000, 10.0000000, 10.0000000);
	C.DrawColor = SpecAndWeaponBackgroundColor;
	C.DrawColor.A = SpecAndWeaponBackgroundAlpha;
	DrawStretchedTextureSegment(C, 40.0000000, 23.0000000, (WinWidth - float(40)), 20.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
	DrawStretchedTextureSegment(C, 1.0000000, 44.0000000, (WinWidth - float(2)), 44.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
	C.DrawColor = LineColor;
	C.DrawColor.A = LineAlpha;
	DrawStretchedTextureSegment(C, 1.0000000, 0.0000000, (WinWidth - float(2)), 1.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
	DrawStretchedTextureSegment(C, 1.0000000, 43.0000000, (WinWidth - float(2)), 1.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
	DrawStretchedTextureSegment(C, 1.0000000, (WinHeight - float(1)), (WinWidth - float(2)), 1.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
	DrawStretchedTextureSegment(C, 40.0000000, 22.0000000, (WinWidth - float(38)), 1.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
	DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, 1.0000000, WinHeight, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
	DrawStretchedTextureSegment(C, (WinWidth - float(1)), 0.0000000, 1.0000000, WinHeight, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
	DrawStretchedTextureSegment(C, 39.0000000, 0.0000000, 1.0000000, 43.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
	C.SetPos(1.0000000, 1.0000000);
	C.DrawColor = Root.Colors.White;
	C.DrawColor.A = FaceAlpha;
	// End:0x8FB
	if(m_bIsSinglePlayer)
	{
		C.DrawTile(m_Operative.m_FaceTexture, 38.0000000, 42.0000000, m_Operative.m_FaceCoords.X, m_Operative.m_FaceCoords.Y, m_Operative.m_FaceCoords.Z, m_Operative.m_FaceCoords.W);
		C.DrawColor = SpecColor;
		C.DrawColor.A = SpecAlpha;
		C.TextSize(m_szSpeciality, fPosX, fPosY);
		C.SetPos((float(SpecX) - (fPosX / 2.0000000)), float(SpecY));
		C.DrawText(m_szSpeciality);		
	}
	else
	{
		C.DrawTile(DefaultFaceTexture, 38.0000000, 42.0000000, DefaultFaceCoords.X, DefaultFaceCoords.Y, DefaultFaceCoords.Z, DefaultFaceCoords.W);
	}
	C.DrawColor = WeaponColor;
	C.DrawColor.A = WeaponAlpha;
	C.Font = Root.Fonts[6];
	iWeapon = 0;
	J0x992:

	// End:0x9E7 [Loop If]
	if((iWeapon < 2))
	{
		C.SetPos(float(WeaponX), float((WeaponY + (WeaponHeight * iWeapon))));
		C.DrawText(m_WeaponsName[iWeapon]);
		(iWeapon++);
		// [Loop Continue]
		goto J0x992;
	}
	C.SetPos(float(WeaponX), float((WeaponY + (WeaponHeight * 2))));
	// End:0xA44
	if(bIsPrimaryGadgetEmpty)
	{
		C.DrawText(Localize("MISC", "ID_EMPTY", "R6Common"));		
	}
	else
	{
		C.DrawText(m_WeaponsName[iWeapon]);
	}
	C.SetPos(float(WeaponX), float((WeaponY + (WeaponHeight * 3))));
	// End:0xAB8
	if(bIsSecondaryGadgetEmpty)
	{
		C.DrawText(Localize("MISC", "ID_EMPTY", "R6Common"));		
	}
	else
	{
		C.DrawText(m_WeaponsName[3]);
	}
	return;
}

function string GetCharacterName()
{
	// End:0x26
	if(m_bIsSinglePlayer)
	{
		// End:0x23
		if((m_Operative != none))
		{
			return m_Operative.m_CharacterName;
		}		
	}
	else
	{
		return m_MemberRepInfo.m_CharacterName;
	}
	return;
}

defaultproperties
{
	NameX=119
	NameY=6
	SpecX=119
	SpecY=26
	WeaponX=5
	WeaponY=44
	WeaponHeight=10
	LifeX=44
	LifeY=6
	m_OperativeSelectSnd=Sound'SFX_Menus.Play_Rose_Select'
	HealthIconTexture=Texture'R6MenuTextures.Credits.TeamBarIcon'
	DefaultFaceTexture=Texture'R6MenuOperative.RS6_Memeber_01'
	DefaultFaceCoords=(W=42.0000000,X=472.0000000,Y=308.0000000,Z=38.0000000)
}
