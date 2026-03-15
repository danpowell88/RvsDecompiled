//=============================================================================
// WaveTexture - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// WaveTexture: Simple phongish water surface.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class WaveTexture extends WaterTexture
    native
    noexport
    safereplace
    hidecategories(Object);

var(WaterPaint) byte BumpMapLight;
var(WaterPaint) byte BumpMapAngle;
var(WaterPaint) byte PhongRange;
var(WaterPaint) byte PhongSize;

