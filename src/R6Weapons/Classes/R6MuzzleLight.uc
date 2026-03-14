//=============================================================================
// R6MuzzleLight.
//=============================================================================
class R6MuzzleLight extends Light;

// --- Constants ---
const LightExistence = 0.04;

// --- Variables ---
var float m_fExistForHowlong;

// --- Functions ---
//Tick is used to make sure the light is displayed at least once under low FPS
simulated function Tick(float fDeltaTime) {}

defaultproperties
{
}
