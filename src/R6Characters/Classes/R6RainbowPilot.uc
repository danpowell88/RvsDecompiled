//=============================================================================
// R6RainbowPilot - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6RainbowPilot.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/15 * Created by Rima Brek
//=============================================================================
class R6RainbowPilot extends R6RainbowPawn;

// NEW IN 1.60
simulated event PostBeginPlay()
{
	m_bUseSpecialSkin = true;
	super.PostBeginPlay();
	return;
}

simulated function SetRainbowFaceTexture()
{
	// End:0x8B
	if(bIsFemale)
	{
		SetFemaleParameters();
		Skins[1] = Texture(DynamicLoadObject("R6Characters_t.Rainbow.R6RPilotHeadF", Class'Engine.Texture'));
		// End:0x6C
		if((m_Helmet != none))
		{
			m_Helmet.DrawScale = 1.0000000;
		}
		// End:0x8B
		if((m_NightVision != none))
		{
			m_NightVision.DrawScale = 1.1000000;
		}
	}
	return;
}

simulated function AttachNightVision()
{
	super(R6Rainbow).AttachNightVision();
	m_NightVision.SetRelativeLocation(vect(-1.0000000, -1.0000000, 0.0000000));
	return;
}

defaultproperties
{
	m_bScaleGasMaskForFemale=false
	m_GasMaskClass=Class'R6Engine.R6PilotGasMask'
	m_NightVisionClass=Class'R6Engine.R6PilotNightVision'
	m_eArmorType=2
	m_HelmetClass=Class'R6Characters.R6RPilotHelmet'
	Mesh=SkeletalMesh'R6Rainbow_UKX.PilotMesh'
	KParams=KarmaParamsSkel'R6Characters.KarmaParamsSkel247'
	Skins=/* Array type was not detected. */
}
