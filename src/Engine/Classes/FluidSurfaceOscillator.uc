//=============================================================================
// FluidSurfaceOscillator - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// FluidSurfaceOscillator.
//=============================================================================
class FluidSurfaceOscillator extends Actor
    native
    placeable;

var() byte Phase;
var() float Frequency;
var() float Strength;
var() float Radius;
// FluidSurface to oscillate
var() edfindable FluidSurfaceInfo FluidInfo;
var const transient float OscTime;

defaultproperties
{
	Frequency=1.0000000
	Strength=10.0000000
	bHidden=true
}
