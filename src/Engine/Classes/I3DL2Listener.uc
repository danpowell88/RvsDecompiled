//=============================================================================
// I3DL2Listener - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// I3DL2Listener: Base class for I3DL2 room effects.
//=============================================================================
class I3DL2Listener extends Object
	abstract
	native
	editinlinenew;

var() int Room;
var() int RoomHF;
var() int Reflections;
var() int Reverb;
var() bool bDecayTimeScale;
var() bool bReflectionsScale;
var() bool bReflectionsDelayScale;
var() bool bReverbScale;
var() bool bReverbDelayScale;
var() bool bDecayHFLimit;
var() float EnvironmentSize;
var() float EnvironmentDiffusion;
var() float DecayTime;
var() float DecayHFRatio;
var() float ReflectionsDelay;
var() float ReverbDelay;
var() float RoomRolloffFactor;
var() float AirAbsorptionHF;
var transient int Environment;
var transient int Updated;

defaultproperties
{
	Room=-1000
	RoomHF=-100
	Reflections=-2602
	Reverb=200
	bDecayTimeScale=true
	bReflectionsScale=true
	bReflectionsDelayScale=true
	bReverbScale=true
	bReverbDelayScale=true
	bDecayHFLimit=true
	EnvironmentSize=7.5000000
	EnvironmentDiffusion=1.0000000
	DecayTime=1.4900000
	DecayHFRatio=0.8300000
	ReflectionsDelay=0.0070000
	ReverbDelay=0.0110000
	AirAbsorptionHF=-5.0000000
}
