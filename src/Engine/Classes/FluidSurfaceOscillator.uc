//=============================================================================
// FluidSurfaceOscillator.
//=============================================================================
class FluidSurfaceOscillator extends Actor
    native;

// --- Variables ---
var FluidSurfaceInfo FluidInfo;
// ^ NEW IN 1.60
var float Frequency;
// ^ NEW IN 1.60
var byte Phase;
// ^ NEW IN 1.60
var float Strength;
// ^ NEW IN 1.60
var float Radius;
// ^ NEW IN 1.60
var transient const float OscTime;

defaultproperties
{
}
