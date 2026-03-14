// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class Ladder extends SmallNavigationPoint
    native;

#exec Texture Import File=Textures\Ladder.pcx Name=S_Ladder Mips=Off MASKED=1

// --- Variables ---
var LadderVolume MyLadder;
var Ladder LadderList;

// --- Functions ---
event bool SuggestMovePreparation(Pawn Other) {}

defaultproperties
{
}
