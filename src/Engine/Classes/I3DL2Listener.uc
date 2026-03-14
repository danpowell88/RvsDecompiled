//=============================================================================
// I3DL2Listener: Base class for I3DL2 room effects.
//=============================================================================
class I3DL2Listener extends Object
    native
    abstract;

// --- Variables ---
var float EnvironmentSize;
// ^ NEW IN 1.60
var float EnvironmentDiffusion;
// ^ NEW IN 1.60
var int Room;
// ^ NEW IN 1.60
var int RoomHF;
// ^ NEW IN 1.60
var float DecayTime;
// ^ NEW IN 1.60
var float DecayHFRatio;
// ^ NEW IN 1.60
var int Reflections;
// ^ NEW IN 1.60
var float ReflectionsDelay;
// ^ NEW IN 1.60
var int Reverb;
// ^ NEW IN 1.60
var float ReverbDelay;
// ^ NEW IN 1.60
var float RoomRolloffFactor;
// ^ NEW IN 1.60
var float AirAbsorptionHF;
// ^ NEW IN 1.60
var bool bDecayTimeScale;
// ^ NEW IN 1.60
var bool bReflectionsScale;
// ^ NEW IN 1.60
var bool bReflectionsDelayScale;
// ^ NEW IN 1.60
var bool bReverbScale;
// ^ NEW IN 1.60
var bool bReverbDelayScale;
// ^ NEW IN 1.60
var bool bDecayHFLimit;
// ^ NEW IN 1.60
var transient int Environment;
var transient int Updated;

defaultproperties
{
}
