// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Menu.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6WindowButtonMPInGame extends R6WindowButton;

// --- Enums ---
enum eButInGameActionType
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var eButInGameActionType m_eButInGame_Action;
// ^ NEW IN 1.60
var Region m_ROverButton;
var Region m_ROverButtonFade;
var Texture m_TOverButton;

// --- Functions ---
simulated function Click(float Y, float X) {}

defaultproperties
{
}
