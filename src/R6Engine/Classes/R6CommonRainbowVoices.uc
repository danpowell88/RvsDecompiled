// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6CommonRainbowVoices extends R6Voices;

// --- Variables ---
var Sound m_sndSuffocation;      // Voice line played when the pawn is suffocating (smoke/gas)
// ^ NEW IN 1.60
var Sound m_sndCoughOxygene;     // Coughing voice line triggered when oxygen is low
// ^ NEW IN 1.60
var Sound m_sndEntersGas;
var Sound m_sndGoesDown;
var Sound m_sndTakeWound;
var Sound m_sndTerroristDown;
var Sound m_sndEntersSmoke;

// --- Functions ---
function PlayCommonRainbowVoices(R6Pawn aPawn, ECommonRainbowVoices eRainbowVoices) {}

defaultproperties
{
}
