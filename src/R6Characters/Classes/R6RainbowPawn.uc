//=============================================================================
// R6RainbowPawn - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6RainbowPawn.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/15 * Created by Rima Brek
//=============================================================================
class R6RainbowPawn extends R6Rainbow
    abstract;

simulated event PostBeginPlay()
{
	// End:0x3F
	if(((int(Level.NetMode) == int(NM_DedicatedServer)) || (int(Level.NetMode) == int(NM_ListenServer))))
	{
		m_iTeam = m_iDefaultTeam;
	}
	// End:0x151
	if((m_bUseSpecialSkin == false))
	{
		// End:0xE3
		if(((m_iDefaultTeam == 3) && (int(Level.NetMode) != int(NM_Standalone))))
		{
			Skins[0] = Level.RedTeamSkin;
			Skins[1] = Level.RedHeadSkin;
			Skins[2] = Level.RedGogglesSkin;
			Skins[5] = Level.RedHandSkin;
			LinkMesh(Level.RedMesh);			
		}
		else
		{
			Skins[0] = Level.GreenTeamSkin;
			Skins[1] = Level.GreenHeadSkin;
			Skins[2] = Level.GreenGogglesSkin;
			Skins[5] = Level.GreenHandSkin;
			LinkMesh(Level.GreenMesh);
		}
	}
	LinkSkelAnim(MeshAnimation'R6Rainbow_UKX.RainbowAnim');
	super.PostBeginPlay();
	return;
}

simulated event PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	return;
}

simulated function SetFemaleParameters()
{
	SetPawnScale(0.9500000);
	m_fAttachFactor = 0.9500000;
	m_fPrePivotPawnInitialOffset = -4.0000000;
	// End:0x48
	if((int(Level.NetMode) != int(NM_Client)))
	{
		(PrePivot.Z += m_fPrePivotPawnInitialOffset);
	}
	return;
}

simulated function SetRainbowFaceTexture()
{
	local int iFaceIndex;
	local string aFaceTexture;
	local Texture aTexture;

	// End:0x5F
	if(bShowLog)
	{
		Log(((((string(self) $ " SetRainbowFaceTexture() : bIsFemale =") $ string(bIsFemale)) $ " m_iOperativeID=") $ string(m_iOperativeID)));
	}
	iFaceIndex = 3;
	// End:0xB4
	if(bIsFemale)
	{
		SetFemaleParameters();
		// End:0x95
		if((m_Helmet != none))
		{
			m_Helmet.DrawScale = 1.0000000;
		}
		// End:0xB4
		if((m_NightVision != none))
		{
			m_NightVision.DrawScale = 1.0000000;
		}
	}
	switch(m_iOperativeID)
	{
		// End:0xF6
		case 0:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceArnavisca";
			// End:0x775
			break;
		// End:0x133
		case 1:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceBeckenbauer";
			// End:0x775
			break;
		// End:0x16C
		case 2:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceBogart";
			// End:0x775
			break;
		// End:0x1A4
		case 3:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceBurke";
			// End:0x775
			break;
		// End:0x1DD
		case 4:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceChaves";
			// End:0x775
			break;
		// End:0x217
		case 5:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceDuBarry";
			// End:0x775
			break;
		// End:0x251
		case 6:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceFilatov";
			// End:0x775
			break;
		// End:0x28B
		case 7:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceGalanos";
			// End:0x775
			break;
		// End:0x2C4
		case 8:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceHaider";
			// End:0x775
			break;
		// End:0x2FD
		case 9:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceHanley";
			// End:0x775
			break;
		// End:0x335
		case 10:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceHomer";
			// End:0x775
			break;
		// End:0x370
		case 11:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceLofquist";
			// End:0x775
			break;
		// End:0x3AB
		case 12:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceLoiselle";
			// End:0x775
			break;
		// End:0x3E5
		case 13:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceMaldini";
			// End:0x775
			break;
		// End:0x41F
		case 14:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceMcAllen";
			// End:0x775
			break;
		// End:0x458
		case 15:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceMorris";
			// End:0x775
			break;
		// End:0x490
		case 16:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceMurad";
			// End:0x775
			break;
		// End:0x4C9
		case 17:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceNarino";
			// End:0x775
			break;
		// End:0x503
		case 18:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceNoronha";
			// End:0x775
			break;
		// End:0x53D
		case 19:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceNovikov";
			// End:0x775
			break;
		// End:0x577
		case 20:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceSuo_Won";
			// End:0x775
			break;
		// End:0x5B2
		case 21:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFacePetersen";
			// End:0x775
			break;
		// End:0x5EA
		case 22:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFacePrice";
			// End:0x775
			break;
		// End:0x626
		case 23:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceRakuzanka";
			// End:0x775
			break;
		// End:0x660
		case 24:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceRaymond";
			// End:0x775
			break;
		// End:0x699
		case 25:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceWalter";
			// End:0x775
			break;
		// End:0x6D1
		case 26:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceWeber";
			// End:0x775
			break;
		// End:0x707
		case 27:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceWoo";
			// End:0x775
			break;
		// End:0x740
		case 28:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceYakoby";
			// End:0x775
			break;
		// End:0xFFFF
		default:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceReserve";
			break;
	}
	// End:0x7A2
	if((aFaceTexture != ""))
	{
		Skins[iFaceIndex] = Texture(DynamicLoadObject(aFaceTexture, Class'Engine.Texture'));
	}
	return;
}

defaultproperties
{
	m_FOVClass=Class'R6Characters.R6FieldOfView'
	KParams=KarmaParamsSkel'R6Characters.KarmaParamsSkel213'
}
