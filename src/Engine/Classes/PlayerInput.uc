//=============================================================================
// PlayerInput
// Object within playercontroller that manages player input.
// only spawned on client
//=============================================================================
class PlayerInput extends Object
    native
    transient
    config(User);

// --- Variables ---
// max double click interval for double click move
var float DoubleClickTimer;
var float OldSamples[4];
// ^ NEW IN 1.60
var config globalconfig float MouseSamplingTime;
var float SamplingTime[2];
// ^ NEW IN 1.60
var config globalconfig float DoubleClickTime;
var int MouseSamples[2];
// Mouse smoothing
var config globalconfig byte MouseSmoothingMode;
var float SmoothedMouse[2];
// used for doubleclick move
var bool bWasForward;
var bool bWasBack;
var bool bWasLeft;
var bool bWasRight;
var float MaybeTime[2];
// ^ NEW IN 1.60
var float ZeroTime[2];
// ^ NEW IN 1.60
var bool bEdgeForward;
var bool bEdgeBack;
var bool bEdgeLeft;
var bool bEdgeRight;
//#ifndef R6CODE
//var globalconfig float  MouseSmoothingStrength;
//#endif // #ifndef R6CODE
var config globalconfig float MouseSensitivity;
var bool bAdjustSampling;
//#ifndef R6CODE
//var globalconfig	bool	bInvertMouse;
//#else
var bool bInvertMouse;

// --- Functions ---
exec function SetSmoothingMode(byte B) {}
function UpdateSensitivity(float f) {}
function ChangeSnapView(bool B) {}
// check for double click move
function EDoubleClickDir CheckForDoubleClickMove(float DeltaTime) {}
// ^ NEW IN 1.60
// Postprocess the player's input.
event PlayerInput(float DeltaTime) {}
function float SmoothMouse(int Index, float aMouse, float DeltaTime, out byte SampleCount) {}
// ^ NEW IN 1.60
//#ifdef R6CODE
function UpdateMouseOptions() {}
exec function SetSmoothingStrength(float f) {}

defaultproperties
{
}
