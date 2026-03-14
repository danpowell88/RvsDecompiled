//=============================================================================
// ZoneInfo, the built-in Unreal class for defining properties
// of zones.  If you place one ZoneInfo actor in a
// zone you have partioned, the ZoneInfo defines the 
// properties of the zone.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class ZoneInfo extends Info
    native;

#exec Texture Import File=Textures\ZoneInfo.pcx Name=S_ZoneInfo Mips=Off MASKED=1

// --- Variables ---
var name ZoneTag;
// ^ NEW IN 1.60
var array<array> m_EnterSounds;
var array<array> m_ExitSounds;
var bool m_bAlreadyPlayMusic;
// Optional sky zone containing this zone's sky.
var SkyZoneInfo SkyZone;
var Sound m_SinglePlayerMusic;
var array<array> m_AlternateWeatherEmitters;
// ^ NEW IN 1.60
// R6CODE
var bool m_bAlternateEmittersActive;
var bool m_bInDoor;
var array<array> m_StartingSounds;
//#ifdef R6SOUND
var byte m_SoundZone;
// ... == size
var Vector m_vBoundScale;
// AA-oriented, Vect(0,0,1)
var Vector m_vBoundNormal;
// #ifdef R6ZONEBOUND
// Set in the editor  "UBOOL UEditorEngine::Exec_BSP( const TCHAR* Str, FOutputDevice& Ar )"
// the "Min" vertex position
var Vector m_vBoundLocation;
var I3DL2Listener ZoneEffect;
// ^ NEW IN 1.60
var float TexVPanSpeed;
// ^ NEW IN 1.60
var float TexUPanSpeed;
// ^ NEW IN 1.60
var const Texture EnvironmentMap;
// ^ NEW IN 1.60
var float DistanceFogEnd;
// ^ NEW IN 1.60
var float DistanceFogStart;
// ^ NEW IN 1.60
var Color DistanceFogColor;
// ^ NEW IN 1.60
var byte AmbientSaturation;
// ^ NEW IN 1.60
var byte AmbientHue;
// ^ NEW IN 1.60
var byte AmbientBrightness;
// ^ NEW IN 1.60
var const array<array> Terrains;
var bool bClearToFogColor;
// ^ NEW IN 1.60
var bool bDistanceFog;
// ^ NEW IN 1.60
var bool bTerrainZone;
// ^ NEW IN 1.60
var const bool bFogZone;
// ^ NEW IN 1.60

// --- Functions ---
simulated function PreBeginPlay() {}
simulated function ResetOriginalData() {}
// When an actor leaves this zone.
simulated event ActorLeaving(Actor Other) {}
// When an actor enters this zone.
simulated event ActorEntered(Actor Other) {}
final native iterator function ZoneActors(class<Actor> BaseClass, out Actor Actor) {}
// ^ NEW IN 1.60
simulated function LinkToSkybox() {}

defaultproperties
{
}
