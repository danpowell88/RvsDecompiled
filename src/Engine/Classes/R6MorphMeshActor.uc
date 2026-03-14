// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6MorphMeshActor extends Actor
    native;

// --- Enums ---
enum EMvtStat
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var bool m_bMorph;
var float MorphAlpha;
var EMvtStat MvtStat;
var int b_sensMorph;
var StaticMesh MorphMesh;
var int SkinsIndex;
var float MorphDeltaAlpha;
var bool m_bBlockCoronas;

// --- Functions ---
function int R6TakeDamage(optional int iBulletGoup, int iBulletToArmorModifier, Vector vMomentum, Vector vHitLocation, Pawn instigatedBy, int iStunValue, int iKillValue) {}
event PreBeginPlay() {}
function Tick(float DeltaTime) {}

defaultproperties
{
}
