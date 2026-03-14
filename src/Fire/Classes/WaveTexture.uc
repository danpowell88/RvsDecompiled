//=============================================================================
// WaveTexture: Simple phongish water surface.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class WaveTexture extends WaterTexture
    native
    noexport;

// --- Variables ---
var byte BumpMapLight;
var byte BumpMapAngle;
var byte PhongRange;
var byte PhongSize;

defaultproperties
{
}
