//=============================================================================
// Player start location.
//=============================================================================
class PlayerStart extends SmallNavigationPoint
    native;

#exec Texture Import File=Textures\S_Player.pcx Name=S_Player Mips=Off MASKED=1

// --- Variables ---
var bool bSinglePlayerStart;
var bool bEnabled;
var byte TeamNumber;
var bool bCoopStart;

defaultproperties
{
}
