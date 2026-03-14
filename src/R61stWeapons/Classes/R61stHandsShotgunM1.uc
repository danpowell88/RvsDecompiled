//===============================================================================
//  [R61stHandsShotgunM1]   
//===============================================================================
class R61stHandsShotgunM1 extends R61stHandsGripShotgun;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

// --- Variables ---
var bool m_bReloadCycle;
//To play Reload_e on reload empty
var bool m_bPlayedEnd;

// --- Functions ---
function PostBeginPlay() {}

state Reloading
{
    simulated event AnimEnd(int Channel) {}
    simulated function BeginState() {}
    function EndState() {}
}

defaultproperties
{
}
