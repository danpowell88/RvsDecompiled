// ===================================================================
//  WaterTexture: Simple phongish water surface.
//  This is a built-in Unreal class and it shouldn't be modified.
// ===================================================================
class IceTexture extends FractalTexture
    native
    noexport;

// --- Enums ---
enum PanningType
{
    SLIDE_Linear,
	SLIDE_Circular,
	SLIDE_Gestation,
	SLIDE_WavyX,
	SLIDE_WavyY,
};
enum TimingType
{
	TIME_FrameRateSync,
	TIME_RealTimeScroll,
};

// --- Variables ---
var Texture GlassTexture;
// ^ NEW IN 1.60
var Texture SourceTexture;
// ^ NEW IN 1.60
var PanningType PanningStyle;
// ^ NEW IN 1.60
var TimingType TimeMethod;
// ^ NEW IN 1.60
var byte HorizPanSpeed;
// ^ NEW IN 1.60
var byte VertPanSpeed;
// ^ NEW IN 1.60
var byte Frequency;
// ^ NEW IN 1.60
var byte Amplitude;
// ^ NEW IN 1.60
var bool MoveIce;
// ^ NEW IN 1.60
var float MasterCount;
var float UDisplace;
var float VDisplace;
var float UPosition;
var float VPosition;
var transient float TickAccu;
var transient int OldUDisplace;
var transient int OldVDisplace;
var transient Texture OldSourceTex;
var transient int LocalSource;
var transient int ForceRefresh;
var transient Texture OldGlassTex;

defaultproperties
{
}
