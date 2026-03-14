//=============================================================================
// ZoneInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// ZoneInfo, the built-in Unreal class for defining properties
// of zones.  If you place one ZoneInfo actor in a
// zone you have partioned, the ZoneInfo defines the 
// properties of the zone.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class ZoneInfo extends Info
    native
    placeable
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var(ZoneLight) byte AmbientBrightness;
// NEW IN 1.60
var(ZoneLight) byte AmbientHue;
// NEW IN 1.60
var(ZoneLight) byte AmbientSaturation;
//#ifdef R6SOUND
var(R6Sound) byte m_SoundZone;
var() const bool bFogZone;  // Zone is fog-filled.
var() bool bTerrainZone;  // There is terrain in this zone.
var() bool bDistanceFog;  // There is distance fog in this zone.
var() bool bClearToFogColor;  // Clear to fog color if distance fog is enabled.
var() bool m_bInDoor;
var bool m_bAlreadyPlayMusic;
// R6CODE
var bool m_bAlternateEmittersActive;
var(ZoneLight) float DistanceFogStart;
var(ZoneLight) float DistanceFogEnd;
var(ZoneLight) float TexUPanSpeed;
// NEW IN 1.60
var(ZoneLight) float TexVPanSpeed;
var SkyZoneInfo SkyZone;  // Optional sky zone containing this zone's sky.
var(ZoneLight) const Texture EnvironmentMap;
var(ZoneSound) editinline I3DL2Listener ZoneEffect;
var(R6Sound) Sound m_SinglePlayerMusic;
var() name ZoneTag;
var const array<TerrainInfo> Terrains;
var(R6Sound) array<Sound> m_StartingSounds;
var(R6Sound) array<Sound> m_EnterSounds;
var(R6Sound) array<Sound> m_ExitSounds;
var(R6Weather) array<Emitter> m_AlternateWeatherEmitters;
var(ZoneLight) Color DistanceFogColor;
// #ifdef R6ZONEBOUND
// Set in the editor  "UBOOL UEditorEngine::Exec_BSP( const TCHAR* Str, FOutputDevice& Ar )"
var Vector m_vBoundLocation;  // the "Min" vertex position
var Vector m_vBoundNormal;  // AA-oriented, Vect(0,0,1)
var Vector m_vBoundScale;  // ... == size

// Export UZoneInfo::execZoneActors(FFrame&, void* const)
// Iterate through all actors in this zone.
native(308) final iterator function ZoneActors(Class<Actor> BaseClass, out Actor Actor);

simulated function LinkToSkybox()
{
	local SkyZoneInfo TempSkyZone;

	// End:0x21
	foreach __NFUN_304__(Class'Engine.SkyZoneInfo', TempSkyZone, 'None')
	{
		SkyZone = TempSkyZone;		
	}	
	// End:0x66
	foreach __NFUN_304__(Class'Engine.SkyZoneInfo', TempSkyZone, 'None')
	{
		// End:0x65
		if(__NFUN_242__(TempSkyZone.bHighDetail, Level.bHighDetailMode))
		{
			SkyZone = TempSkyZone;
		}		
	}	
	return;
}

simulated function PreBeginPlay()
{
	super(Actor).PreBeginPlay();
	LinkToSkybox();
	return;
}

simulated function ResetOriginalData()
{
	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(false);
	}
	super(Actor).ResetOriginalData();
	m_bAlreadyPlayMusic = false;
	return;
}

// When an actor enters this zone.
simulated event ActorEntered(Actor Other)
{
	local int iSoundNb;
	local Controller C;

	// End:0x13A
	if(__NFUN_130__(Level.m_bPlaySound, __NFUN_155__(m_EnterSounds.Length, 0)))
	{
		// End:0x50
		if(Other.__NFUN_303__('R6Pawn'))
		{
			C = Pawn(Other).Controller;			
		}
		else
		{
			// End:0x74
			if(Other.__NFUN_303__('R6PlayerController'))
			{
				C = Controller(Other);
			}
		}
		// End:0x13A
		if(__NFUN_119__(C, none))
		{
			C.m_CurrentAmbianceObject = self;
			C.m_bUseExitSounds = false;
			// End:0x13A
			if(__NFUN_130__(__NFUN_119__(PlayerController(C), none), __NFUN_119__(Viewport(PlayerController(C).Player), none)))
			{
				iSoundNb = 0;
				J0xD7:

				// End:0x101 [Loop If]
				if(__NFUN_150__(iSoundNb, m_EnterSounds.Length))
				{
					__NFUN_264__(m_EnterSounds[iSoundNb], 11);
					__NFUN_165__(iSoundNb);
					// [Loop Continue]
					goto J0xD7;
				}
				// End:0x13A
				if(__NFUN_130__(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)), __NFUN_129__(m_bAlreadyPlayMusic)))
				{
					m_bAlreadyPlayMusic = true;
					PlayMusic(m_SinglePlayerMusic);
				}
			}
		}
	}
	return;
}

// When an actor leaves this zone.
simulated event ActorLeaving(Actor Other)
{
	local int iSoundNb;
	local Controller C;

	// End:0x101
	if(__NFUN_130__(Level.m_bPlaySound, __NFUN_155__(m_ExitSounds.Length, 0)))
	{
		// End:0x50
		if(Other.__NFUN_303__('R6Pawn'))
		{
			C = Pawn(Other).Controller;			
		}
		else
		{
			// End:0x74
			if(Other.__NFUN_303__('R6PlayerController'))
			{
				C = Controller(Other);
			}
		}
		// End:0x101
		if(__NFUN_119__(C, none))
		{
			C.m_CurrentAmbianceObject = self;
			C.m_bUseExitSounds = true;
			// End:0x101
			if(__NFUN_130__(__NFUN_119__(PlayerController(C), none), __NFUN_119__(Viewport(PlayerController(C).Player), none)))
			{
				iSoundNb = 0;
				J0xD7:

				// End:0x101 [Loop If]
				if(__NFUN_150__(iSoundNb, m_ExitSounds.Length))
				{
					__NFUN_264__(m_ExitSounds[iSoundNb], 11);
					__NFUN_165__(iSoundNb);
					// [Loop Continue]
					goto J0xD7;
				}
			}
		}
	}
	return;
}

defaultproperties
{
	AmbientSaturation=255
	DistanceFogStart=3000.0000000
	DistanceFogEnd=8000.0000000
	TexUPanSpeed=1.0000000
	TexVPanSpeed=1.0000000
	DistanceFogColor=(R=128,G=128,B=128,A=0)
	bStatic=true
	bNoDelete=true
	m_b3DSound=false
	Texture=Texture'Engine.S_ZoneInfo'
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var d
